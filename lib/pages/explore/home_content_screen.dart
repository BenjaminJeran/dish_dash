import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:dish_dash/colors/app_colors.dart';
import 'package:dish_dash/models/recipe.dart';
import 'package:dish_dash/components/recipe_card.dart';

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
        'get_recommended_recipes_random_likes', 
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
      print('Supabase Error in _fetchRecommendedRecipes: ${e.message}');
    } catch (e) {
      setState(() {
        _errorMessage = 'Prišlo je do nepričakovanih napake pri nalaganju priporočenih receptov: $e';
        _isLoading = false;
      });
      print('General Error in _fetchRecommendedRecipes: $e');
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
                          return RecipeCard(recipe: recipe);
                        },
                      ),
                    ),
    );
  }
}
//OPA