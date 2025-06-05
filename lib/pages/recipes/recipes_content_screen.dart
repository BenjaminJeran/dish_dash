import 'package:dish_dash/pages/recipes/update_recipe_screen.dart';
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
  Future<List<Map<String, dynamic>>>? _userRecipesFuture;
  Future<List<Map<String, dynamic>>>? _likedRecipesFuture; 

  List<Recipe> _userRecipes = [];
  List<Recipe> _likedRecipes = []; 

  @override
  void initState() {
    super.initState();
    _userRecipesFuture = _fetchUserRecipes();
    _likedRecipesFuture = _fetchLikedRecipes(); 
  }

  Future<List<Map<String, dynamic>>> _fetchUserRecipes() async {
    try {
      final userId = supabase.auth.currentUser?.id;

      if (userId == null) {
        throw Exception('Uporabnik ni prijavljen.');
      }

      final List<dynamic> data = await supabase
          .from('recipes')
          .select()
          .eq('user_id', userId)
          .order('created_at', ascending: false);

      final List<Map<String, dynamic>> recipesData =
          List<Map<String, dynamic>>.from(data);

      setState(() {
        _userRecipes = recipesData.map((map) => Recipe.fromMap(map)).toList();
      });

      return recipesData;
    } on PostgrestException catch (e) {
      print('Supabase Database napaka pri pridobivanju receptov: ${e.message}');
      throw Exception(
        'Napaka pri nalaganju vaših receptov: ${e.message}',
      );
    } catch (e) {
      print('Splosna napaka: $e');
      throw Exception(
        'Nepričakovana napaka pri nalaganju vaših receptov.',
      );
    }
  }

  Future<List<Map<String, dynamic>>> _fetchLikedRecipes() async {
    try {
      final userId = supabase.auth.currentUser?.id;

      if (userId == null) {
        throw Exception('Uporabnik ni prijavljen.');
      }

      final List<dynamic> data = await supabase.rpc(
        'get_liked_recipes_by_user',
        params: {'p_user_id': userId},
      );

      final List<Map<String, dynamic>> likedRecipesData =
          List<Map<String, dynamic>>.from(data);

      setState(() {
        _likedRecipes =
            likedRecipesData.map((map) => Recipe.fromMap(map)).toList();
      });

      return likedRecipesData;
    } on PostgrestException catch (e) {
      print('Napaka pri pridobivanju vseckanih podatkov: ${e.message}');
      throw Exception(
        'Napaka pri nalaganju všečkanih receptov: ${e.message}',
      );
    } catch (e) {
      print('Splosna napaka: $e');
      throw Exception(
        'Nepričakovana napaka pri nalaganju všečkanih receptov.',
      );
      // You might want to handle this error by showing a message to the user
      // or returning an empty list.
    }
  }

  Future<void> _deleteRecipe(String recipeId) async {
    try {
      final int index = _userRecipes.indexWhere((recipe) => recipe.id == recipeId);
      if (index != -1) {
        _userRecipes.removeAt(index);
        setState(() {}); 

        await supabase.from('recipes').delete().eq('id', recipeId);

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
      setState(() {
        _userRecipesFuture = _fetchUserRecipes(); 
      });
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
      setState(() {
        _userRecipesFuture = _fetchUserRecipes(); 
      });
    }
  }

  void _editRecipe(Recipe recipe) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => UpdateRecipeScreen(recipe: recipe),
      ),
    ).then((_) => _fetchUserRecipes()); 
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            'Uredi recept: ${recipe.name}',
            style: TextStyle(color: AppColors.white),
          ),
          backgroundColor: AppColors.paleLime,
        ),
      );
    }
    print('Edit recipe: ${recipe.name}');
  }

  @override
  Widget build(BuildContext context) {
    return DefaultTabController( 
      length: 2, 
      child: Scaffold(
        appBar: AppBar(
          title: Text(
            'Moji recepti',
            style: TextStyle(
              color: AppColors.charcoal,
              fontSize: 24,
              fontWeight: FontWeight.bold,
            ),
          ),
          bottom: TabBar(
            labelColor: AppColors.leafGreen,
            unselectedLabelColor: AppColors.dimGray,
            indicatorColor: AppColors.leafGreen,
            tabs: const [
              Tab(text: 'Moji Recepti'),
              Tab(text: 'Všečkani Recepti'),
            ],
          ),
        ),
        body: TabBarView(
          children: [
            _buildRecipeList(_userRecipesFuture, _userRecipes, (recipeId) => _deleteRecipe(recipeId), _editRecipe, 'Trenutno še nimate shranjenih receptov.'),
            _buildRecipeList(_likedRecipesFuture, _likedRecipes, null, null, 'Trenutno še nimate všečkanih receptov.'),
          ],
        ),
      ),
    );
  }


  Widget _buildRecipeList(
    Future<List<Map<String, dynamic>>>? future,
    List<Recipe> recipes,
    Function(String)? onDelete,
    Function(Recipe)? onEdit,
    String emptyMessage,
  ) {
    return FutureBuilder<List<Map<String, dynamic>>>(
      future: future,
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
                      if (future == _userRecipesFuture) {
                         _userRecipesFuture = _fetchUserRecipes();
                      } else if (future == _likedRecipesFuture) {
                         _likedRecipesFuture = _fetchLikedRecipes();
                      }
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
        } else if (!snapshot.hasData || recipes.isEmpty) {
          return Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(Icons.menu_book, size: 80, color: AppColors.dimGray),
                const SizedBox(height: 20),
                Text(
                  emptyMessage,
                  style: TextStyle(fontSize: 20, color: AppColors.dimGray),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 10),
                if (future == _userRecipesFuture)
                  Text(
                    'Začnite z dodajanjem svojega prvega recepta!',
                    style: TextStyle(fontSize: 16, color: AppColors.dimGray),
                    textAlign: TextAlign.center,
                  ),
              ],
            ),
          );
        } else {
          return ListView.builder(
            padding: const EdgeInsets.all(16.0),
            itemCount: recipes.length,
            itemBuilder: (context, index) {
              final recipe = recipes[index];

              if (onDelete != null && onEdit != null) {
                return Padding(
                  padding: const EdgeInsets.only(bottom: 16.0),
                  child: Dismissible(
                    key: ValueKey(recipe.id),
                    direction: DismissDirection.horizontal,
                    background: Container(
                      alignment: Alignment.centerLeft,
                      padding: const EdgeInsets.symmetric(horizontal: 20),
                      decoration: BoxDecoration(
                        color: AppColors.charcoal,
                        borderRadius: BorderRadius.circular(15),
                      ),
                      child: const Icon(Icons.edit, color: Colors.white, size: 36),
                    ),
                    secondaryBackground: Container(
                      alignment: Alignment.centerRight,
                      padding: const EdgeInsets.symmetric(horizontal: 20),
                      decoration: BoxDecoration(
                        color: AppColors.tomatoRed,
                        borderRadius: BorderRadius.circular(15),
                      ),
                      child: const Icon(Icons.delete, color: Colors.white, size: 36),
                    ),
                    confirmDismiss: (direction) async {
                      if (direction == DismissDirection.endToStart) {
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
                      } else if (direction == DismissDirection.startToEnd) {
                        onEdit(recipe);
                        return false;
                      }
                      return false;
                    },
                    onDismissed: (direction) {
                      if (direction == DismissDirection.endToStart) {
                        onDelete(recipe.id);
                      }
                    },
                    child: _buildRecipeCardContent(recipe),
                  ),
                );
              } else {
                
                return Padding(
                  padding: const EdgeInsets.only(bottom: 16.0),
                  child: _buildRecipeCardContent(recipe),
                );
              }
            },
          );
        }
      },
    );
  }

  Widget _buildRecipeCardContent(Recipe recipe) {
    return Card(
      margin: EdgeInsets.zero,
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
        borderRadius: BorderRadius.circular(15),
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
                        color: AppColors.leafGreen.withOpacity(0.2),
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
    );
  }
}