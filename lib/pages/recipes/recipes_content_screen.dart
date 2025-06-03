import 'package:flutter/material.dart';
import 'package:dish_dash/colors/app_colors.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:dish_dash/models/recipe.dart';
import 'package:dish_dash/pages/recipes/recipe_details/recipe_details_screen.dart';

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
        throw Exception('Uporabnik ni prijavljen.');
      }

      final List<Map<String, dynamic>> recipes = await supabase
          .from('recipes')
          .select()
          .eq('user_id', userId)
          .order('created_at', ascending: false);

      return recipes;
    } on PostgrestException catch (e) {
      print('Supabase Database Error fetching recipes: ${e.message}');
      throw Exception(
        'Napaka pri nalaganju receptov: ${e.message}',
      );
    } catch (e) {
      print('General error fetching recipes: $e');
      throw Exception(
        'Nepričakovana napaka pri nalaganju receptov.',
      );
    }
  }

  // Changed parameter type from int to String
  Future<void> _deleteRecipe(String recipeId) async {
    try {
      await supabase.from('recipes').delete().eq('id', recipeId); // Pass String ID directly
      // After successful deletion, refresh the list of recipes
      setState(() {
        _recipesFuture = _fetchRecipes();
      });
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              'Recept je bil uspešno izbrisan.',
              style: TextStyle(color: AppColors.white),
            ),
            backgroundColor: AppColors.leafGreen,
          ),
        );
      }
    } on PostgrestException catch (e) {
      print('Supabase Database Error deleting recipe: ${e.message}');
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              'Napaka pri brisanju recepta: ${e.message}',
              style: TextStyle(color: AppColors.white),
            ),
            backgroundColor: AppColors.tomatoRed,
          ),
        );
      }
    } catch (e) {
      print('General error deleting recipe: $e');
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              'Nepričakovana napaka pri brisanju recepta.',
              style: TextStyle(color: AppColors.white),
            ),
            backgroundColor: AppColors.tomatoRed,
          ),
        );
      }
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
                color: AppColors.leafGreen,
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
                    'Napaka: ${snapshot.error}',
                    textAlign: TextAlign.center,
                    style: TextStyle(fontSize: 18, color: AppColors.tomatoRed),
                  ),
                  const SizedBox(height: 20),
                  ElevatedButton(
                    onPressed: () {
                      setState(() {
                        _recipesFuture = _fetchRecipes();
                      });
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.leafGreen,
                      foregroundColor: AppColors.white,
                    ),
                    child: const Text('Poskusi ponovno'),
                  ),
                ],
              ),
            );
          } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.menu_book, size: 80, color: AppColors.dimGray),
                  const SizedBox(height: 20),
                  Text(
                    'Trenutno še nimate shranjenih receptov.',
                    style: TextStyle(fontSize: 20, color: AppColors.dimGray),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 10),
                  Text(
                    'Začnite z dodajanjem svojega prvega recepta!',
                    style: TextStyle(fontSize: 16, color: AppColors.dimGray),
                    textAlign: TextAlign.center,
                  ),
                ],
              ),
            );
          } else {
            final recipesData = snapshot.data!;
            return ListView.builder(
              padding: const EdgeInsets.all(16.0),
              itemCount: recipesData.length,
              itemBuilder: (context, index) {
                final recipeMap = recipesData[index];
                final recipe = Recipe.fromMap(recipeMap);

                return Dismissible(
                  key: ValueKey(recipe.id), 
                  direction: DismissDirection.endToStart,
                  background: Container(
                    alignment: Alignment.centerRight,
                    padding: const EdgeInsets.symmetric(horizontal: 20),
                    decoration: BoxDecoration(
                      color: AppColors.tomatoRed,
                      borderRadius: BorderRadius.circular(15),
                    ),
                    child: const Icon(Icons.delete, color: Colors.white, size: 36),
                  ),
                  confirmDismiss: (direction) async {
                    return await showDialog(
                      context: context,
                      builder: (BuildContext context) {
                        return AlertDialog(
                          title: Text(
                            'Potrdi izbris',
                            style: TextStyle(color: AppColors.charcoal),
                          ),
                          content: Text(
                            'Ali ste prepričani, da želite izbrisati ta recept?',
                            style: TextStyle(color: AppColors.dimGray),
                          ),
                          actions: <Widget>[
                            TextButton(
                              onPressed: () => Navigator.of(context).pop(false),
                              child: Text(
                                'Prekliči',
                                style: TextStyle(color: AppColors.dimGray),
                              ),
                            ),
                            TextButton(
                              onPressed: () => Navigator.of(context).pop(true),
                              child: Text(
                                'Izbriši',
                                style: TextStyle(color: AppColors.tomatoRed),
                              ),
                            ),
                          ],
                        );
                      },
                    );
                  },
                  onDismissed: (direction) {
                    _deleteRecipe(recipe.id); 
                  },
                  child: Card(
                    margin: const EdgeInsets.symmetric(vertical: 10.0),
                    elevation: 4,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(15),
                    ),
                    child: InkWell(
                      onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => RecipeDetailsScreen(recipe: recipe),
                          ),
                        );
                      },
                      borderRadius: BorderRadius.circular(
                        15,
                      ),
                      child: Padding(
                        padding: const EdgeInsets.all(12.0),
                        child: Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            if (recipe.imageUrl.isNotEmpty)
                              ClipRRect(
                                borderRadius: BorderRadius.circular(10),
                                child: Image.network(
                                  recipe.imageUrl,
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
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    recipe.name,
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
                                    recipe.description,
                                    style: TextStyle(
                                      fontSize: 14,
                                      color: AppColors.dimGray,
                                    ),
                                    maxLines: 3,
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                  const SizedBox(height: 10),
                                  Container(
                                    padding: const EdgeInsets.symmetric(
                                      horizontal: 8,
                                      vertical: 4,
                                    ),
                                    decoration: BoxDecoration(
                                      color:
                                          AppColors.leafGreen.withOpacity(0.2),
                                      borderRadius: BorderRadius.circular(8),
                                    ),
                                    child: Text(
                                      recipe.category,
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