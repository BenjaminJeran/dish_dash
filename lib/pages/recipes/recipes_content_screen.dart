// lib/pages/recipes/recipes_content_screen.dart
import 'package:flutter/material.dart';
import 'package:dish_dash/colors/app_colors.dart';
import 'package:supabase_flutter/supabase_flutter.dart'; // Import Supabase

class RecipesContentScreen extends StatefulWidget {
  const RecipesContentScreen({super.key});

  @override
  State<RecipesContentScreen> createState() => _RecipesContentScreenState();
}

class _RecipesContentScreenState extends State<RecipesContentScreen> {
  final SupabaseClient supabase = Supabase.instance.client;
  Future<List<Map<String, dynamic>>>? _recipesFuture;

  @override
  void initState() {
    super.initState();
    _recipesFuture = _fetchRecipes();
  }

  Future<List<Map<String, dynamic>>> _fetchRecipes() async {
    try {
      final userId = supabase.auth.currentUser?.id;

      if (userId == null) {
        throw Exception('Uporabnik ni prijavljen.'); // User not logged in.
      }

      // Fetch recipes associated with the current user ID
      // Assuming your 'recipes' table has a 'user_id' column
      final List<Map<String, dynamic>> recipes = await supabase
          .from('recipes')
          .select()
          .eq('user_id', userId) // Filter by the current user's ID
          .order('created_at', ascending: false); // Order by creation date

      return recipes;
    } on PostgrestException catch (e) {
      print('Supabase Database Error fetching recipes: ${e.message}');
      throw Exception(
        'Napaka pri nalaganju receptov: ${e.message}',
      ); // Error loading recipes
    } catch (e) {
      print('General error fetching recipes: $e');
      throw Exception(
        'Nepričakovana napaka pri nalaganju receptov.',
      ); // Unexpected error loading recipes
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: FutureBuilder<List<Map<String, dynamic>>>(
        future: _recipesFuture,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return Center(
              child: CircularProgressIndicator(
                color: AppColors.leafGreen, // Use your app's primary color
              ),
            );
          } else if (snapshot.hasError) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    Icons.error_outline,
                    size: 80,
                    color: AppColors.tomatoRed,
                  ),
                  const SizedBox(height: 20),
                  Text(
                    'Napaka: ${snapshot.error}', // Error: [error message]
                    textAlign: TextAlign.center,
                    style: TextStyle(fontSize: 18, color: AppColors.tomatoRed),
                  ),
                  const SizedBox(height: 20),
                  ElevatedButton(
                    onPressed: () {
                      setState(() {
                        _recipesFuture = _fetchRecipes(); // Retry fetching
                      });
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.leafGreen,
                      foregroundColor: AppColors.white,
                    ),
                    child: const Text('Poskusi ponovno'), // Try again
                  ),
                ],
              ),
            );
          } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
            // No recipes found or data is empty
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.menu_book, size: 80, color: AppColors.dimGray),
                  const SizedBox(height: 20),
                  Text(
                    'Trenutno še nimate shranjenih receptov.', // "You currently have no saved recipes."
                    style: TextStyle(fontSize: 20, color: AppColors.dimGray),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 10),
                  Text(
                    'Začnite z dodajanjem svojega prvega recepta!', // "Start by adding your first recipe!"
                    style: TextStyle(fontSize: 16, color: AppColors.dimGray),
                    textAlign: TextAlign.center,
                  ),
                ],
              ),
            );
          } else {
            // Recipes are available, display them
            final recipes = snapshot.data!;
            return ListView.builder(
              padding: const EdgeInsets.all(16.0),
              itemCount: recipes.length,
              itemBuilder: (context, index) {
                final recipe = recipes[index];
                final imageUrl = recipe['image_url'];
                final recipeName =
                    recipe['name'] ?? 'Neznano ime'; // Unknown name
                final description =
                    recipe['description'] ?? 'Ni opisa.'; // No description
                final category =
                    recipe['category'] ?? 'Neznano'; // Unknown category

                return Card(
                  margin: const EdgeInsets.symmetric(vertical: 10.0),
                  elevation: 4,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(15),
                  ),
                  // Using InkWell for a ripple effect when tapped, similar to your nav items
                  child: InkWell(
                    onTap: () {
                      // TODO: Implement navigation to a detailed recipe view
                      print('Recipe tapped: $recipeName');
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(content: Text('Tapped on ${recipeName}')),
                      );
                    },
                    borderRadius: BorderRadius.circular(
                      15,
                    ), // Match Card's border radius
                    child: Padding(
                      padding: const EdgeInsets.all(12.0),
                      child: Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          // Recipe Image
                          if (imageUrl != null && imageUrl.isNotEmpty)
                            ClipRRect(
                              borderRadius: BorderRadius.circular(10),
                              child: Image.network(
                                imageUrl,
                                width: 100,
                                height: 100,
                                fit: BoxFit.cover,
                                errorBuilder: (context, error, stackTrace) {
                                  return Container(
                                    width: 100,
                                    height: 100,
                                    color: AppColors.paleGray,
                                    child: Icon(
                                      Icons.broken_image,
                                      color: AppColors.dimGray,
                                    ),
                                  );
                                },
                              ),
                            )
                          else
                            Container(
                              width: 100,
                              height: 100,
                              decoration: BoxDecoration(
                                color: AppColors.paleGray,
                                borderRadius: BorderRadius.circular(10),
                              ),
                              child: Icon(
                                Icons.fastfood,
                                size: 50,
                                color: AppColors.dimGray,
                              ),
                            ),
                          const SizedBox(width: 15),
                          // Recipe Details
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  recipeName,
                                  style: TextStyle(
                                    fontSize: 20,
                                    fontWeight: FontWeight.bold,
                                    color: AppColors.charcoal,
                                  ),
                                  maxLines: 2,
                                  overflow: TextOverflow.ellipsis,
                                ),
                                const SizedBox(height: 5),
                                Text(
                                  description,
                                  style: TextStyle(
                                    fontSize: 14,
                                    color: AppColors.dimGray,
                                  ),
                                  maxLines: 3,
                                  overflow: TextOverflow.ellipsis,
                                ),
                                const SizedBox(height: 10),
                                // Category Tag
                                Container(
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: 8,
                                    vertical: 4,
                                  ),
                                  decoration: BoxDecoration(
                                    color:
                                        AppColors
                                            .leafGreen, // A lighter version of leafGreen for tags
                                    borderRadius: BorderRadius.circular(8),
                                  ),
                                  child: Text(
                                    category,
                                    style: TextStyle(
                                      fontSize: 12,
                                      color: AppColors.charcoal,
                                      fontWeight: FontWeight.w600,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                );
              },
            );
          }
        },
      ),
    );
  }
}
