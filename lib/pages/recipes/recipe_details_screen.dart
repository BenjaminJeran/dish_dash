import 'package:flutter/material.dart';
import 'package:dish_dash/colors/app_colors.dart';
import 'package:dish_dash/models/recipe.dart';
import 'package:dish_dash/pages/profile/profile_page_screen.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class RecipeDetailsScreen extends StatefulWidget {
  final Recipe recipe;

  const RecipeDetailsScreen({super.key, required this.recipe});

  @override
  State<RecipeDetailsScreen> createState() => _RecipeDetailsScreenState();
}

class _RecipeDetailsScreenState extends State<RecipeDetailsScreen> {
  final SupabaseClient supabase = Supabase.instance.client;
  int _likesCount = 0;
  bool _isLikedByUser = false;
  String? _currentUserId;

  @override
  void initState() {
    super.initState();
    _currentUserId = supabase.auth.currentUser?.id;
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    _fetchLikeStatusAndCount();
  }


  Future<void> _fetchLikeStatusAndCount() async {
    if (_currentUserId == null) {
      print('User is not logged in. Cannot fetch personal like status.');
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
        print('Error fetching public likes count: ${e.message}');
        if (mounted) { 
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Error fetching public likes data: ${e.message}')),
          );
        }
      } catch (e) {
        print('An unexpected error occurred fetching public likes: $e');
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('An unexpected error occurred fetching public likes.')),
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
      print('Supabase Error fetching like data: ${e.message}');
      if (mounted) { // Context is safe to use here
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error fetching like data: ${e.message}')),
        );
      }
    } catch (e) {
      print('An unexpected error occurred: $e');
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('An unexpected error occurred.')),
        );
      }
    }
  }

  Future<void> _toggleLike() async {
    if (_currentUserId == null) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Please log in to like recipes.')),
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
        print('Recipe unliked!');
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
        print('Recipe liked!');
      }
    } on PostgrestException catch (e) {
      if (e.message.contains('duplicate key value violates unique constraint')) {
        print('User already liked this recipe.');
        _fetchLikeStatusAndCount(); 
      } else {
        print('Error toggling like: ${e.message}');
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Error: ${e.message}')),
          );
        }
      }
    } catch (e) {
      print('An unexpected error occurred during like toggle: $e');
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('An unexpected error occurred.')),
        );
      }
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
            Stack(
              children: [
                ClipRRect(
                  borderRadius: BorderRadius.circular(20),
                  child: widget.recipe.imageUrl.startsWith('http')
                      ? Image.network(
                          widget.recipe.imageUrl,
                          width: double.infinity,
                          height: 250,
                          fit: BoxFit.cover,
                          errorBuilder: (context, error, stackTrace) =>
                              Container(
                            width: double.infinity,
                            height: 250,
                            color: AppColors.paleGray,
                            child: Icon(
                              Icons.broken_image,
                              color: AppColors.dimGray,
                              size: 50,
                            ),
                          ),
                        )
                      : Image.asset(
                          widget.recipe.imageUrl,
                          width: double.infinity,
                          height: 250,
                          fit: BoxFit.cover,
                          errorBuilder: (context, error, stackTrace) =>
                              Container(
                            width: double.infinity,
                            height: 250,
                            color: AppColors.paleGray,
                            child: Icon(
                              Icons.image_not_supported,
                              color: AppColors.dimGray,
                              size: 50,
                            ),
                          ),
                        ),
                ),
                Positioned(
                  top: 10,
                  right: 10,
                  child: Container(
                    decoration: BoxDecoration(
                      color: Colors.white.withOpacity(0.8),
                      shape: BoxShape.circle,
                    ),
                    child: IconButton(
                      icon: Icon(
                        _isLikedByUser ? Icons.favorite : Icons.favorite_border,
                        color: AppColors.tomatoRed,
                      ),
                      onPressed: _toggleLike,
                    ),
                  ),
                ),
              ],
            ),
            Padding(
              padding: const EdgeInsets.all(20.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    widget.recipe.name,
                    style: TextStyle(
                      fontSize: 28,
                      fontWeight: FontWeight.bold,
                      color: AppColors.charcoal,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Row(
                    children: [
                      Icon(
                        Icons.access_time,
                        size: 20,
                        color: AppColors.dimGray,
                      ),
                      const SizedBox(width: 4),
                      Text(
                        '${widget.recipe.cookingTime} min',
                        style: TextStyle(
                          color: AppColors.dimGray,
                          fontSize: 16,
                        ),
                      ),
                      const SizedBox(width: 16),
                      Icon(Icons.people, size: 20, color: AppColors.dimGray),
                      const SizedBox(width: 4),
                      Text(
                        '${widget.recipe.servings} servings',
                        style: TextStyle(
                          color: AppColors.dimGray,
                          fontSize: 16,
                        ),
                      ),
                      const SizedBox(width: 16),
                      Icon(Icons.favorite, size: 20, color: AppColors.tomatoRed),
                      const SizedBox(width: 4),
                      Text(
                        '$_likesCount',
                        style: TextStyle(
                          color: AppColors.dimGray,
                          fontSize: 16,
                        ),
                      ),
                    ],
                  ),

                  if (widget.recipe.category.isNotEmpty)
                    Padding(
                      padding: const EdgeInsets.only(top: 8.0),
                      child: Row(
                        children: [
                          Icon(
                            Icons.category,
                            size: 20,
                            color: AppColors.dimGray,
                          ),
                          const SizedBox(width: 4),
                          Text(
                            'Kategorija: ${widget.recipe.category}',
                            style: TextStyle(
                              color: AppColors.dimGray,
                              fontSize: 16,
                            ),
                          ),
                        ],
                      ),
                    ),
                  const SizedBox(height: 15),
                  Text(
                    widget.recipe.description,
                    style: TextStyle(
                      fontSize: 16,
                      color: AppColors.charcoal,
                      height: 1.5,
                    ),
                  ),
                  const SizedBox(height: 30),

                  _buildStepCard(
                    context,
                    stepNumber: 1,
                    title: 'Sestavine',
                    content: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: widget.recipe.ingredients
                          .map(
                            (ingredient) => Padding(
                              padding: const EdgeInsets.only(bottom: 4.0),
                              child: Text(
                                '- $ingredient',
                                style: TextStyle(
                                  fontSize: 16,
                                  color: AppColors.charcoal,
                                ),
                              ),
                            ),
                          )
                          .toList(),
                    ),
                  ),
                  const SizedBox(height: 15),

                  _buildStepCard(
                    context,
                    stepNumber: 2,
                    title: 'Navodila za pripravo',
                    content: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: widget.recipe.instructions.asMap().entries.map((entry) {
                        int idx = entry.key;
                        String instruction = entry.value;
                        return Padding(
                          padding: const EdgeInsets.only(bottom: 8.0),
                          child: Text(
                            '${idx + 1}. $instruction',
                            style: TextStyle(
                              fontSize: 16,
                              color: AppColors.charcoal,
                            ),
                          ),
                        );
                      }).toList(),
                    ),
                  ),
                  const SizedBox(height: 30),

                  Center(
                    child: ElevatedButton(
                      onPressed: () {
                        print('Uredi button pressed for ${widget.recipe.name}');
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppColors.leafGreen,
                        minimumSize: Size(
                          MediaQuery.of(context).size.width * 0.8,
                          50,
                        ),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(10),
                        ),
                      ),
                      child: Text(
                        'Uredi',
                        style: TextStyle(
                          color: AppColors.white,
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(height: 15),

                  Center(
                    child: GestureDetector(
                      onTap: () {
                        print('Dodaj v košarico pressed for ${widget.recipe.name}');
                        if (widget.recipe.ingredients.isNotEmpty) {
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(
                              content: Text(
                                'Dodano v nakupovalni seznam: ${widget.recipe.ingredients.join(', ')}',
                              ),
                              duration: const Duration(seconds: 2),
                            ),
                          );
                        } else {
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(
                              content: Text(
                                'Ni sestavin za dodati v nakupovalni seznam.',
                              ),
                              duration: Duration(seconds: 2),
                            ),
                          );
                        }
                      },
                      child: Text(
                        'Dodaj v košarico',
                        style: TextStyle(
                          color: AppColors.leafGreen,
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                          decoration: TextDecoration.underline,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildStepCard(
    BuildContext context, {
    required int stepNumber,
    required String title,
    required Widget content,
  }) {
    return Container(
      decoration: BoxDecoration(
        color: AppColors.leafGreen.withOpacity(0.1),
        borderRadius: BorderRadius.circular(10),
      ),
      padding: const EdgeInsets.all(20),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 30,
            height: 30,
            decoration: BoxDecoration(
              color: AppColors.leafGreen,
              shape: BoxShape.circle,
            ),
            child: Center(
              child: Text(
                '$stepNumber',
                style: TextStyle(
                  color: AppColors.white,
                  fontWeight: FontWeight.bold,
                  fontSize: 18,
                ),
              ),
            ),
          ),
          const SizedBox(width: 15),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    color: AppColors.charcoal,
                  ),
                ),
                const SizedBox(height: 10),
                content,
              ],
            ),
          ),
        ],
      ),
    );
  }
}