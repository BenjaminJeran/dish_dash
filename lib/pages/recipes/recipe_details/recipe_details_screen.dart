import 'package:dish_dash/pages/recipes/recipe_details/widgets/IngredientsSectionCard.dart';
import 'package:dish_dash/pages/recipes/recipe_details/widgets/PreparationStepsSectionCard.dart';
import 'package:dish_dash/pages/recipes/recipe_details/widgets/RecipeImageSection.dart';
import 'package:dish_dash/pages/recipes/recipe_details/widgets/RecipeInfoSection.dart';
import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import 'package:dish_dash/colors/app_colors.dart';
import 'package:dish_dash/models/recipe.dart';
import 'package:dish_dash/pages/profile/profile_page_screen.dart';


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
      if (mounted) {
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

                  // Ingredients Section Card with emoji
                  IngredientsSectionCard(
                    emoji: '🍎', // You can choose any food emoji
                    ingredients: widget.recipe.ingredients,
                  ),
                  const SizedBox(height: 15),

                  // Preparation Steps Section Card with emoji
                  PreparationStepsSectionCard(
                    emoji: '👨‍🍳', // You can choose any cook/kitchen emoji
                    instructions: widget.recipe.instructions,
                  ),
                  const SizedBox(height: 30),

                  Center(
                    child: ElevatedButton(
                      onPressed: () {
                        print('Uredi button pressed for ${widget.recipe.name}');
                        // TODO: Implement actual edit functionality
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
}