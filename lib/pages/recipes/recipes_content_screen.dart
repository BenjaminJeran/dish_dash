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
      if (mounted) { 
        setState(() {
          _userRecipes = recipesData.map((map) => Recipe.fromMap(map)).toList();
        });
      }
      return recipesData;
    } on PostgrestException catch (e) {
      print('Supabase Database napaka pri pridobivanju receptov: ${e.message}');
      throw Exception('Napaka pri nalaganju vaših receptov: ${e.message}');
    } catch (e) {
      print('Splosna napaka: $e');
      throw Exception('Nepričakovana napaka pri nalaganju vaših receptov.');
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
      if (mounted) {  
        setState(() {
          _likedRecipes =
              likedRecipesData.map((map) => Recipe.fromMap(map)).toList();
        });
      }
      return likedRecipesData;
    } on PostgrestException catch (e) {
      print('Napaka pri pridobivanju vseckanih podatkov: ${e.message}');
      throw Exception('Napaka pri nalaganju všečkanih receptov: ${e.message}');
    } catch (e) {
      print('Splosna napaka: $e');
      throw Exception('Nepričakovana napaka pri nalaganju všečkanih receptov.');
    }
  }

  Future<void> _deleteRecipe(String recipeId) async {
    try {
      final int index = _userRecipes.indexWhere(
        (recipe) => recipe.id == recipeId,
      );
      if (index != -1) {
        _userRecipes.removeAt(index);
        if (mounted) { 
          setState(() {});
        }
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
      if (mounted) {
        setState(() {
          _userRecipesFuture = _fetchUserRecipes();
        });
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
      if (mounted) { 
        setState(() {
          _userRecipesFuture = _fetchUserRecipes();
        });
      }
    }
  }

  void _editRecipe(Recipe recipe) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => UpdateRecipeScreen(recipe: recipe),
      ),
    ).then((_) {
      if (mounted) { 
        _fetchUserRecipes();
      }
    });
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
            _buildRecipeList(
              _userRecipesFuture,
              _userRecipes,
              (recipeId) => _deleteRecipe(recipeId),
              _editRecipe,
              'Trenutno še nimate shranjenih receptov.',
            ),
            _buildRecipeList(
              _likedRecipesFuture,
              _likedRecipes,
              null,
              null,
              'Trenutno še nimate všečkanih receptov.',
            ),
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
            child: CircularProgressIndicator(color: AppColors.leafGreen),
          );
        } else if (snapshot.hasError) {
          return Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(Icons.error_outline, size: 80, color: AppColors.tomatoRed),
                const SizedBox(height: 20),
                Text(
                  'Napaka: ${snapshot.error}',
                  textAlign: TextAlign.center,
                  style: TextStyle(fontSize: 18, color: AppColors.tomatoRed),
                ),
                const SizedBox(height: 20),
                ElevatedButton(
                  onPressed: () {
                    if (mounted) {
                      setState(() {
                        if (future == _userRecipesFuture) {
                          _userRecipesFuture = _fetchUserRecipes();
                        } else if (future == _likedRecipesFuture) {
                          _likedRecipesFuture = _fetchLikedRecipes();
                        }
                      });
                    }
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
                  padding: const EdgeInsets.only(bottom: 20.0),
                  child: Dismissible(
                    key: ValueKey(recipe.id),
                    direction: DismissDirection.horizontal,
                    background: Container(
                      alignment: Alignment.centerLeft,
                      padding: const EdgeInsets.symmetric(horizontal: 20),
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          colors: [
                            AppColors.charcoal,
                            AppColors.charcoal.withOpacity(0.8),
                          ],
                          begin: Alignment.centerLeft,
                          end: Alignment.centerRight,
                        ),
                        borderRadius: BorderRadius.circular(16),
                      ),
                      child: const Icon(
                        Icons.edit_rounded,
                        color: Colors.white,
                        size: 32,
                      ),
                    ),
                    secondaryBackground: Container(
                      alignment: Alignment.centerRight,
                      padding: const EdgeInsets.symmetric(horizontal: 20),
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          colors: [
                            AppColors.tomatoRed.withOpacity(0.8),
                            AppColors.tomatoRed,
                          ],
                          begin: Alignment.centerLeft,
                          end: Alignment.centerRight,
                        ),
                        borderRadius: BorderRadius.circular(16),
                      ),
                      child: const Icon(
                        Icons.delete_rounded,
                        color: Colors.white,
                        size: 32,
                      ),
                    ),
                    confirmDismiss: (direction) async {
                      if (direction == DismissDirection.endToStart) {
                        return await showDialog(
                          context: context,
                          builder: (BuildContext context) {
                            return AlertDialog(
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(20),
                              ),
                              title: Text(
                                'Potrdi izbris',
                                style: TextStyle(
                                  color: AppColors.charcoal,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              content: Text(
                                'Ali ste prepričani, da želite izbrisati ta recept?',
                                style: TextStyle(color: AppColors.dimGray),
                              ),
                              actions: <Widget>[
                                TextButton(
                                  onPressed:
                                      () => Navigator.of(context).pop(false),
                                  style: TextButton.styleFrom(
                                    shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(12),
                                    ),
                                  ),
                                  child: Text(
                                    'Prekliči',
                                    style: TextStyle(color: AppColors.dimGray),
                                  ),
                                ),
                                ElevatedButton(
                                  onPressed:
                                      () => Navigator.of(context).pop(true),
                                  style: ElevatedButton.styleFrom(
                                    backgroundColor: AppColors.tomatoRed,
                                    foregroundColor: Colors.white,
                                    shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(12),
                                    ),
                                  ),
                                  child: const Text('Izbriši'),
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
                    child: _buildModernRecipeCard(recipe),
                  ),
                );
              } else {
                return Padding(
                  padding: const EdgeInsets.only(bottom: 20.0),
                  child: _buildModernRecipeCard(recipe),
                );
              }
            },
          );
        }
      },
    );
  }

  Widget _buildModernRecipeCard(Recipe recipe) {
    return Container(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.06),
            blurRadius: 12,
            offset: const Offset(0, 4),
            spreadRadius: 1,
          ),
        ],
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: () {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => RecipeDetailsScreen(recipe: recipe),
              ),
            );
          },
          borderRadius: BorderRadius.circular(16),
          child: Container(
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(16),
              border: Border.all(
                color: AppColors.leafGreen.withOpacity(0.1),
                width: 1,
              ),
            ),
            child: IntrinsicHeight(
              child: Row(
                crossAxisAlignment:
                    CrossAxisAlignment.stretch, 
                children: [
                  Container(
                    width: 120,
                    decoration: BoxDecoration(
                      borderRadius: const BorderRadius.only(
                        topLeft: Radius.circular(16),
                        bottomLeft: Radius.circular(16),
                      ),
                    ),
                    child: ClipRRect(
                      borderRadius: const BorderRadius.only(
                        topLeft: Radius.circular(16),
                        bottomLeft: Radius.circular(16),
                      ),
                      child: recipe.imageUrl.isNotEmpty
                          ? Image.network(
                              recipe.imageUrl,
                              width: 120,
                              fit:
                                  BoxFit
                                      .cover, 
                              errorBuilder: (context, error, stackTrace) {
                                return _buildCompactImagePlaceholder();
                              },
                            )
                          : _buildCompactImagePlaceholder(),
                    ),
                  ),
                  Expanded(
                    child: Padding(
                      padding: const EdgeInsets.all(16),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Expanded(
                                child: Text(
                                  recipe.name,
                                  style: TextStyle(
                                    fontSize: 18,
                                    fontWeight: FontWeight.bold,
                                    color: AppColors.charcoal,
                                    height: 1.2,
                                  ),
                                  maxLines: 2,
                                  overflow: TextOverflow.ellipsis,
                                ),
                              ),
                              const SizedBox(width: 12),
                              Container(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 8,
                                  vertical: 4,
                                ),
                                decoration: BoxDecoration(
                                  color: AppColors.leafGreen,
                                  borderRadius: BorderRadius.circular(12),
                                  boxShadow: [
                                    BoxShadow(
                                      color: AppColors.leafGreen.withOpacity(
                                        0.3,
                                      ),
                                      blurRadius: 4,
                                      offset: const Offset(0, 1),
                                    ),
                                  ],
                                ),
                                child: Text(
                                  recipe.category,
                                  style: const TextStyle(
                                    fontSize: 10,
                                    color: Colors.white,
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 6),
                          Text(
                            recipe.description,
                            style: TextStyle(
                              fontSize: 14,
                              color: AppColors.dimGray,
                              height: 1.3,
                            ),
                            maxLines: 2,
                            overflow: TextOverflow.ellipsis,
                          ),
                          const SizedBox(height: 12),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Container(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 8,
                                  vertical: 4,
                                ),
                                decoration: BoxDecoration(
                                  color: AppColors.leafGreen.withOpacity(0.1),
                                  borderRadius: BorderRadius.circular(8),
                                ),
                                child: Row(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    Icon(
                                      Icons.schedule_rounded,
                                      size: 12,
                                      color: AppColors.leafGreen,
                                    ),
                                    const SizedBox(width: 3),
                                    Text(
                                      '${recipe.cookingTime} min',
                                      style: TextStyle(
                                        fontSize: 10,
                                        color: AppColors.leafGreen,
                                        fontWeight: FontWeight.w500,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                              Container(
                                padding: const EdgeInsets.all(6),
                                decoration: BoxDecoration(
                                  color: AppColors.leafGreen.withOpacity(0.1),
                                  borderRadius: BorderRadius.circular(8),
                                ),
                                child: Icon(
                                  Icons.arrow_forward_rounded,
                                  size: 14,
                                  color: AppColors.leafGreen,
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildCompactImagePlaceholder() {
    return Container(
      width: 120,
      height: 120,
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            AppColors.leafGreen.withOpacity(0.1),
            AppColors.leafGreen.withOpacity(0.2),
          ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.restaurant_rounded,
            size: 32,
            color: AppColors.leafGreen.withOpacity(0.6),
          ),
          const SizedBox(height: 4),
          Text(
            'Ni slike',
            style: TextStyle(
              color: AppColors.leafGreen.withOpacity(0.8),
              fontSize: 10,
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }
}