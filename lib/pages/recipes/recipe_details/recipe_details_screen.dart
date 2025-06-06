// lib/pages/recipes/recipe_details_screen.dart
import 'package:dish_dash/pages/recipes/recipe_details/widgets/IngredientsSectionCard.dart';
import 'package:dish_dash/pages/recipes/recipe_details/widgets/PreparationStepsSectionCard.dart';

import 'package:dish_dash/pages/recipes/recipe_details/widgets/RecipeImageSection.dart';import 'package:dish_dash/pages/recipes/recipe_details/widgets/RecipeInfoSection.dart';
import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import 'package:dish_dash/colors/app_colors.dart';
import 'package:dish_dash/models/recipe.dart';
import 'package:dish_dash/pages/profile/profile_page_screen.dart';
import 'package:dish_dash/models/comment.dart'; 
import 'package:dish_dash/services/shopping_list_service.dart';

class RecipeDetailsScreen extends StatefulWidget {
  final Recipe recipe;

  const RecipeDetailsScreen({super.key, required this.recipe});

  @override
  State<RecipeDetailsScreen> createState() => _RecipeDetailsScreenState();
}

class _RecipeDetailsScreenState extends State<RecipeDetailsScreen> {
  final SupabaseClient supabase = Supabase.instance.client;
  late final ShoppingListService _shoppingListService;
  int _likesCount = 0;
  bool _isLikedByUser = false;
  String? _currentUserId;

  final TextEditingController _commentController = TextEditingController();
  List<Comment> _comments = [];
  bool _isLoadingComments = false;
  String? _commentErrorMessage;

  @override
  void initState() {
    super.initState();
    _currentUserId = supabase.auth.currentUser?.id;
    _shoppingListService = ShoppingListService(supabase);
    _fetchComments();
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    _fetchLikeStatusAndCount();
  }

  @override
  void dispose() {
    _commentController.dispose();
    super.dispose();
  }

  void _showSnackBar(String message, {Duration duration = const Duration(seconds: 1)}) {
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(message), duration: duration),
      );
    }
  }

  Future<void> _fetchLikeStatusAndCount() async {
    if (_currentUserId == null) {
      print('Uporabnik ni prijavljen. Ni mogoče pridobiti statusa všečkov.');
      try {
        final PostgrestResponse countResponse = await supabase
            .from('likes')
            .select()
            .eq('recipe_id', widget.recipe.id)
            .count(CountOption.exact);

        if (mounted) {
          setState(() {
            _likesCount = countResponse.count ?? 0;
          });
        }
      } on PostgrestException catch (e) {
        print('Napaka pri pridobivanju števila javnih všečkov: ${e.message}');
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Napaka pri pridobivanju podatkov o javnih všečkih: ${e.message}'),
            ),
          );
        }
      } catch (e) {
        print('Prišlo je do nepričakovane napake med pridobivanjem javnih všečkov: $e');
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text(
                'Prišlo je do nepričakovane napake med pridobivanjem javnih všečkov.',
              ),
            ),
          );
        }
      }
      return;
    }

    try {
      final PostgrestResponse countResponse = await supabase
          .from('likes')
          .select()
          .eq('recipe_id', widget.recipe.id)
          .count(CountOption.exact);

      final totalLikes = countResponse.count;

      final List<Map<String, dynamic>> userLikeData = await supabase
          .from('likes')
          .select('id')
          .eq('recipe_id', widget.recipe.id)
          .eq('user_id', _currentUserId!)
          .limit(1);

      final isLiked = userLikeData.isNotEmpty;

      if (mounted) {
        setState(() {
          _likesCount = totalLikes ?? 0;
          _isLikedByUser = isLiked;
        });
      }
    } on PostgrestException catch (e) {
      print('Supabase napaka pri pridobivanju podatkov o všečkih: ${e.message}');
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Napaka pri pridobivanju podatkov o všečkih: ${e.message}')),
        );
      }
    } catch (e) {
      print('Prišlo je do nepričakovane napake: $e');
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Prišlo je do nepričakovane napake.')),
        );
      }
    }
  }

  Future<void> _toggleLike() async {
    if (_currentUserId == null) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Prosimo, prijavite se, da lahko všečkate recepte.')),
        );
      }
      return;
    }

    try {
      if (_isLikedByUser) {
        await supabase
            .from('likes')
            .delete()
            .eq('user_id', _currentUserId!)
            .eq('recipe_id', widget.recipe.id);

        if (mounted) {
          setState(() {
            _isLikedByUser = false;
            _likesCount--;
          });
        }
        print('Receptu je bil odstranjen všeček!');
      } else {
        await supabase.from('likes').insert({
          'user_id': _currentUserId!,
          'recipe_id': widget.recipe.id,
        });

        if (mounted) {
          setState(() {
            _isLikedByUser = true;
            _likesCount++;
          });
        }
        print('Recept je bil všečkan!');
      }
    } on PostgrestException catch (e) {
      if (e.message.contains(
        'duplicate key value violates unique constraint',
      )) {
        print('Uporabnik je ta recept že všečkal.');
        _fetchLikeStatusAndCount();
      } else {
        print('Napaka pri preklapljanju všečka: ${e.message}');
        if (mounted) {
          ScaffoldMessenger.of(
            context,
          ).showSnackBar(SnackBar(content: Text('Napaka: ${e.message}')));
        }
      }
    } catch (e) {
      print('Prišlo je do nepričakovane napake med preklapljanjem všečka: $e');
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Prišlo je do nepričakovane napake.')),
        );
      }
    }
  }

  // Method to fetch comments
  Future<void> _fetchComments() async {
    setState(() {
      _isLoadingComments = true;
      _commentErrorMessage = null;
    });

    try {
      final List<dynamic> data = await supabase
          .from('comments')
          .select(
            '*, users(name)', // Select comment fields and user's name
          )
          .eq('recipe_id', widget.recipe.id)
          .order('created_at', ascending: true);

      final List<Comment> fetchedComments =
          data.map((map) {
            final commentMap = Map<String, dynamic>.from(map);
            return Comment.fromMap(commentMap);
          }).toList();

      if (mounted) {
        setState(() {
          _comments = fetchedComments;
          _isLoadingComments = false;
        });
      }
    } on PostgrestException catch (e) {
      print('Supabase napaka pri nalaganju komentarjev: ${e.message}');
      if (mounted) {
        setState(() {
          _commentErrorMessage =
              'Napaka pri nalaganju komentarjev: ${e.message}';
          _isLoadingComments = false;
        });
      }
    } catch (e) {
      print('Nepričakovana napaka pri nalaganju komentarjev: $e');
      if (mounted) {
        setState(() {
          _commentErrorMessage =
              'Nepričakovana napaka pri nalaganju komentarjev.';
          _isLoadingComments = false;
        });
      }
    }
  }

  Future<void> _postComment() async {
    final String commentText = _commentController.text.trim();

    if (commentText.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Komentar ne sme biti prazen.')),
      );
      return;
    }

    if (_currentUserId == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Prosimo, prijavite se za objavo komentarja.'),
        ),
      );
      return;
    }

    try {
      await supabase.from('comments').insert({
        'user_id': _currentUserId!,
        'recipe_id': widget.recipe.id,
        'comment_text': commentText,
      });

      _commentController.clear();
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              'Komentar uspešno objavljen!',
              style: TextStyle(color: AppColors.white),
            ),
            backgroundColor: AppColors.leafGreen,
          ),
        );
      }
      _fetchComments();
    } on PostgrestException catch (e) {
      print('Supabase napaka pri objavi komentarja: ${e.message}');
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              'Napaka pri objavi komentarja: ${e.message}',
              style: TextStyle(color: AppColors.white),
            ),
            backgroundColor: AppColors.tomatoRed,
          ),
        );
      }
    } catch (e) {
      print('Nepričakovana napaka pri objavi komentarja: $e');
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              'Nepričakovana napaka pri objavi komentarja.',
              style: TextStyle(color: AppColors.white),
            ),
            backgroundColor: AppColors.tomatoRed,
          ),
        );
      }
    }
  }

  Future<void> _deleteComment(String commentId) async {
    if (_currentUserId == null) {
      _showSnackBar('Za brisanje komentarja se morate prijaviti.');
      return;
    }

    try {
      await supabase
          .from('comments')
          .delete()
          .eq('id', commentId) 
          .eq('user_id', _currentUserId!); 

      if (mounted) {
        _showSnackBar('Komentar uspešno izbrisan!', duration: const Duration(seconds: 2));
      }
      _fetchComments(); 
    } on PostgrestException catch (e) {
      print('Supabase napaka pri brisanju komentarja: ${e.message}');
      if (mounted) {
        _showSnackBar('Napaka pri brisanju komentarja: ${e.message}');
      }
    } catch (e) {
      print('Nepričakovana napaka pri brisanju komentarja: $e');
      if (mounted) {
        _showSnackBar('Nepričakovana napaka pri brisanju komentarja.');
      }
    }
  }


  Future<void> _addIngredientsToShoppingList() async {
    if (_currentUserId == null) {
      _showSnackBar('Potrebno se je prijaviti za dodajanje sestavin v nakupovalni seznam.');
      return;
    }

    if (widget.recipe.ingredients.isEmpty) {
      _showSnackBar('Recept ne vsebuje sestavin.');
      return;
    }

    _showSnackBar('Dodajanje sestavin v nakupovalni seznam...');
    try {
      for (final ingredient in widget.recipe.ingredients) {
        await _shoppingListService.addItem(_currentUserId!, ingredient);
      }
      _showSnackBar('Sestavine dodane v nakupovalni seznam!', duration: const Duration(seconds: 2));
    } catch (e) {
      _showSnackBar('Napaka pri dodajanju sestavin: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () {
            Navigator.pop(context);
          },
        ),
        title: Center(child: Image.asset('assets/logo.png', height: 80)),
        actions: [
          IconButton(
            icon: const Icon(Icons.person),
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => const ProfilePageScreen(),
                ),
              );
            },
          ),
        ],
        elevation: 0,
        backgroundColor: Colors.transparent,
        foregroundColor: AppColors.charcoal,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.only(bottom: 20.0, top: 10.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            RecipeImageSection(
              imageUrl: widget.recipe.imageUrl,
              isLikedByUser: _isLikedByUser,
              onToggleLike: _toggleLike,
            ),
            Padding(
              padding: const EdgeInsets.all(20.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  RecipeInfoSection(
                    recipe: widget.recipe,
                    likesCount: _likesCount,
                  ),
                  const SizedBox(height: 30),

                  IngredientsSectionCard(
                    emoji: '🍎',
                    ingredients: widget.recipe.ingredients,
                  ),
                  const SizedBox(height: 15),

                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton.icon(
                      onPressed: _addIngredientsToShoppingList,
                      icon: const Icon(Icons.playlist_add),
                      label: const Text('Dodaj v nakupovalni seznam'),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppColors.leafGreen,
                        foregroundColor: AppColors.white,
                        padding: const EdgeInsets.symmetric(vertical: 15),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(10),
                        ),
                        textStyle: const TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(height: 15),

                  PreparationStepsSectionCard(
                    emoji: '👨‍🍳',
                    instructions: widget.recipe.instructions,
                  ),
                  const SizedBox(height: 30),

                  Text(
                    'Komentarji',
                    style: TextStyle(
                      fontSize: 22,
                      fontWeight: FontWeight.bold,
                      color: AppColors.charcoal,
                    ),
                  ),
                  const SizedBox(height: 15),

                  TextField(
                    controller: _commentController,
                    decoration: InputDecoration(
                      hintText: 'Napišite komentar...',
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(10.0),
                        borderSide: BorderSide.none,
                      ),
                      filled: true,
                      fillColor: AppColors.paleGray,
                      suffixIcon: IconButton(
                        icon: Icon(Icons.send, color: AppColors.leafGreen),
                        onPressed: _postComment,
                      ),
                      contentPadding: const EdgeInsets.symmetric(
                        vertical: 10,
                        horizontal: 15,
                      ),
                    ),
                    maxLines: null,
                  ),
                  const SizedBox(height: 20),

                  _isLoadingComments
                      ? Center(
                          child: CircularProgressIndicator(
                            color: AppColors.leafGreen,
                          ),
                        )
                      : _commentErrorMessage != null
                          ? Center(
                              child: Text(
                                _commentErrorMessage!,
                                textAlign: TextAlign.center,
                                style: TextStyle(
                                  color: AppColors.tomatoRed,
                                  fontSize: 16,
                                ),
                              ),
                            )
                          : _comments.isEmpty
                              ? Center(
                                  child: Text(
                                    'Trenutno še ni komentarjev. Bodite prvi!',
                                    style: TextStyle(
                                      fontSize: 16,
                                      color: AppColors.dimGray,
                                    ),
                                    textAlign: TextAlign.center,
                                  ),
                                )
                              : ListView.builder(
                                  shrinkWrap: true,
                                  physics:
                                      const NeverScrollableScrollPhysics(),
                                  itemCount: _comments.length,
                                  itemBuilder: (context, index) {
                                    final comment = _comments[index];
                                    final bool isCommentOwner =
                                        _currentUserId != null &&
                                            _currentUserId == comment.userId;

                                    return Card(
                                      margin: const EdgeInsets.only(bottom: 10),
                                      color: AppColors.paleGray,
                                      elevation: 1,
                                      shape: RoundedRectangleBorder(
                                        borderRadius: BorderRadius.circular(10),
                                      ),
                                      child: Padding(
                                        padding: const EdgeInsets.all(12.0),
                                        child: Column(
                                          crossAxisAlignment:
                                              CrossAxisAlignment.start,
                                          children: [
                                            Row(
                                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                              children: [
                                                Text(
                                                  comment.userName ??
                                                      'Neznan uporabnik',
                                                  style: TextStyle(
                                                    fontWeight: FontWeight.bold,
                                                    color: AppColors.charcoal,
                                                    fontSize: 16,
                                                  ),
                                                ),
              
                                                if (isCommentOwner)
                                                  IconButton(
                                                    icon: Icon(Icons.delete, color: AppColors.tomatoRed, size: 20),
                                                    onPressed: () => _deleteComment(comment.id),
                                                    padding: EdgeInsets.zero, 
                                                    constraints: BoxConstraints(), 
                                                  ),
                                              ],
                                            ),
                                            const SizedBox(height: 5),
                                            Text(
                                              comment.commentText,
                                              style: TextStyle(
                                                fontSize: 15,
                                                color: AppColors.dimGray,
                                              ),
                                            ),
                                            const SizedBox(height: 5),
                                            Align(
                                              alignment: Alignment.bottomRight,
                                              child: Text(
                                                '${comment.createdAt.day}.${comment.createdAt.month}.${comment.createdAt.year}',
                                                style: TextStyle(
                                                  fontSize: 12,
                                                  color: AppColors.dimGray,
                                                ),
                                              ),
                                            ),
                                          ],
                                        ),
                                      ),
                                    );
                                  },
                                ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}