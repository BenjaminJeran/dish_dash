import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:dish_dash/colors/app_colors.dart';
import 'package:dish_dash/models/recipe.dart';
import 'package:dish_dash/pages/recipes/recipe_details/recipe_details_screen.dart';

class HomeContentScreen extends StatefulWidget {
  const HomeContentScreen({super.key});

  @override
  State<HomeContentScreen> createState() => _HomeContentScreenState();
}

class _HomeContentScreenState extends State<HomeContentScreen> {
  final SupabaseClient supabase = Supabase.instance.client;
  List<Recipe> _recommendedRecipes = [];
  bool _isLoading = true;
  String? _errorMessage;

  @override
  void initState() {
    super.initState();
    _fetchRecommendedRecipes();
  }

  Future<void> _fetchRecommendedRecipes() async {
    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    try {
      final List<dynamic> data = await supabase.rpc(
        'get_recommended_recipes_random',
        params: {'num_recipes': 15},
      );

      final List<Map<String, dynamic>> recipeMaps =
          List<Map<String, dynamic>>.from(data);

      setState(() {
        _recommendedRecipes =
            recipeMaps.map((map) => Recipe.fromMap(map)).toList();
        _isLoading = false;
      });
    } on PostgrestException catch (e) {
      setState(() {
        _errorMessage = 'Napaka pri nalaganju priporočenih receptov: ${e.message}';
        _isLoading = false;
      });
      print('Supabase Error: ${e.message}');
    } catch (e) {
      setState(() {
        _errorMessage = 'Prišlo je do nepričakovanih napake pri nalaganju priporočenih receptov: $e';
        _isLoading = false;
      });
      print('General Error: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : _errorMessage != null
              ? Center(
                  child: Padding(
                    padding: const EdgeInsets.all(20.0),
                    child: Text(
                      _errorMessage!,
                      textAlign: TextAlign.center,
                      style: TextStyle(color: AppColors.tomatoRed, fontSize: 16),
                    ),
                  ),
                )
              : _recommendedRecipes.isEmpty
                  ? Center(
                      child: Text(
                        'Trenutno ni na voljo nobenih priporočenih receptov.',
                        style: TextStyle(fontSize: 18, color: AppColors.dimGray),
                      ),
                    )
                  : RefreshIndicator(
                      onRefresh: _fetchRecommendedRecipes,
                      child: ListView.builder(
                        padding: const EdgeInsets.all(16.0),
                        itemCount: _recommendedRecipes.length,
                        itemBuilder: (context, index) {
                          final recipe = _recommendedRecipes[index];
                          return _buildSmallRecipeCard(context, recipe);
                        },
                      ),
                    ),
    );
  }

  Widget _buildSmallRecipeCard(
    BuildContext context,
    Recipe recipe,
  ) {
    return Card(
      elevation: 2.0,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
      margin: const EdgeInsets.only(bottom: 15),
      child: InkWell(
        onTap: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => RecipeDetailsScreen(recipe: recipe),
            ),
          );
        },
        borderRadius: BorderRadius.circular(10),
        child: Padding(
          padding: const EdgeInsets.all(12.0),
          child: Row(
            children: [
              ClipRRect(
                borderRadius: BorderRadius.circular(8),
                child: recipe.imageUrl.startsWith('http')
                    ? Image.network(
                        recipe.imageUrl,
                        width: 80,
                        height: 80,
                        fit: BoxFit.cover,
                        errorBuilder: (context, error, stackTrace) =>
                            Container(
                          width: 80,
                          height: 80,
                          color: AppColors.paleGray,
                          child: Icon(Icons.broken_image,
                              color: AppColors.dimGray),
                        ),
                      )
                    : Image.asset(
                        recipe.imageUrl,
                        width: 80,
                        height: 80,
                        fit: BoxFit.cover,
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
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: AppColors.charcoal,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 8),
                    Row(
                      children: [
                        Icon(
                          Icons.access_time,
                          size: 16,
                          color: AppColors.dimGray,
                        ),
                        const SizedBox(width: 4),
                        Text(
                          '${recipe.cookingTime} min',
                          style: TextStyle(
                            color: AppColors.dimGray,
                            fontSize: 13,
                          ),
                        ),
                        const SizedBox(width: 12),
                        Icon(Icons.people, size: 16, color: AppColors.dimGray),
                        const SizedBox(width: 4),
                        Text(
                          '${recipe.servings} servings',
                          style: TextStyle(
                            color: AppColors.dimGray,
                            fontSize: 13,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              Icon(Icons.arrow_forward_ios, size: 18, color: AppColors.dimGray),
            ],
          ),
        ),
      ),
    );
  }
}