import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:dish_dash/colors/app_colors.dart';
import 'package:dish_dash/models/recipe.dart';
import 'package:dish_dash/components/recipe_card.dart';

class ExploreContentScreen extends StatefulWidget {
  const ExploreContentScreen({super.key});

  @override
  State<ExploreContentScreen> createState() => _ExploreContentScreenState();
}

class _ExploreContentScreenState extends State<ExploreContentScreen> {
  final SupabaseClient supabase = Supabase.instance.client;
  List<Recipe> _filteredRecipes = [];
  bool _isLoading = true;
  String? _errorMessage;

  String _searchQuery = '';
  String? _selectedCategory;

  final TextEditingController _searchController = TextEditingController();

  final List<Map<String, String>> _categories = [
    {'name': 'Zajtrk', 'image': 'assets/images/breakfast.jpg'},
    {'name': 'Malica', 'image': 'assets/images/snack.jpg'},
    {'name': 'Kosilo', 'image': 'assets/images/lunch.jpg'},
    {'name': 'Večerja', 'image': 'assets/images/dinner.jpg'},
    {'name': 'Sladica', 'image': 'assets/images/dessert.jpg'},
    {'name': 'Prigrizek', 'image': 'assets/images/snack.jpg'},
    {'name': 'Drugo', 'image': 'assets/images/other.jpg'},
  ];

  @override
  void initState() {
    super.initState();
    _fetchFilteredRecipes();
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  Future<void> _fetchFilteredRecipes() async {
    if (!mounted) return;

    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    try {
      List<dynamic> data;

      if (_searchQuery.isEmpty && _selectedCategory == null) {
        data = await supabase.rpc(
          'get_recommended_recipes_random_likes',
          params: {'num_recipes': 15},
        );
      } else {
        final Map<String, dynamic> rpcParams = {
          'search_query': _searchQuery.isNotEmpty ? _searchQuery : null,
          'category_filter': _selectedCategory,
        };

        data = await supabase.rpc(
          'get_filtered_recipes_with_likes',
          params: rpcParams,
        );
      }

      final List<Map<String, dynamic>> recipeMaps =
          List<Map<String, dynamic>>.from(data);

      if (!mounted) return;
      setState(() {
        _filteredRecipes = recipeMaps.map((map) => Recipe.fromMap(map)).toList();
        _isLoading = false;
      });
    } on PostgrestException catch (e) {
      if (!mounted) return;
      setState(() {
        _errorMessage = 'Napaka pri nalaganju receptov: ${e.message}';
        _isLoading = false;
      });
      print('Supabase Error in _fetchFilteredRecipes: ${e.message}');
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _errorMessage = 'Prišlo je do nepričakovanih napake pri nalaganju receptov: $e';
        _isLoading = false;
      });
      print('General Error in _fetchFilteredRecipes: $e');
    }
  }

  void _onSearchChanged(String query) {
    setState(() {
      _searchQuery = query;
    });
    _fetchFilteredRecipes();
  }

  void _onCategorySelected(String categoryName) {
    setState(() {
      _selectedCategory = categoryName == _selectedCategory ? null : categoryName;
    });
    _fetchFilteredRecipes();
  }

  String _getRecipesListTitle() {
    if (_searchQuery.isNotEmpty && _selectedCategory != null) {
      return 'Rezultati iskanja in kategorije "${_selectedCategory!}"';
    } else if (_searchQuery.isNotEmpty) {
      return 'Rezultati iskanja';
    } else if (_selectedCategory != null) {
      return 'Recepti v kategoriji "${_selectedCategory!}"';
    } else {
      return 'Priporočeni recepti';
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: TextField(
              controller: _searchController,
              onChanged: _onSearchChanged,
              decoration: InputDecoration(
                hintText: 'Iskanje...',
                prefixIcon: const Icon(Icons.search),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(10.0),
                  borderSide: BorderSide.none,
                ),
                filled: true,
                fillColor: AppColors.paleGray,
                contentPadding: const EdgeInsets.symmetric(vertical: 0, horizontal: 15),
              ),
            ),
          ),
          SizedBox(
            height: 120,
            child: ListView.builder(
              scrollDirection: Axis.horizontal,
              padding: const EdgeInsets.symmetric(horizontal: 16.0),
              itemCount: _categories.length,
              itemBuilder: (context, index) {
                final category = _categories[index];
                final isSelected = _selectedCategory == category['name'];
                return GestureDetector(
                  onTap: () => _onCategorySelected(category['name']!),
                  child: Column(
                    children: [
                      Container(
                        margin: const EdgeInsets.symmetric(horizontal: 8.0),
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          border: isSelected
                              ? Border.all(color: AppColors.leafGreen, width: 3)
                              : null,
                          boxShadow: isSelected
                              ? [
                                  BoxShadow(
                                    color: AppColors.leafGreen.withOpacity(0.3),
                                    blurRadius: 6,
                                    spreadRadius: 2,
                                  ),
                                ]
                              : null,
                        ),
                        child: ClipOval(
                          child: Image.asset(
                            category['image']!,
                            width: 80,
                            height: 80,
                            fit: BoxFit.cover,
                            errorBuilder: (context, error, stackTrace) =>
                                Container(
                              width: 80,
                              height: 80,
                              color: AppColors.paleGray,
                              child: Icon(Icons.category,
                                  color: AppColors.dimGray),
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(height: 5),
                      Text(
                        category['name']!,
                        style: TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.bold,
                          color: isSelected ? AppColors.leafGreen : AppColors.charcoal,
                        ),
                      ),
                    ],
                  ),
                );
              },
            ),
          ),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  _getRecipesListTitle(),
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: AppColors.charcoal,
                  ),
                ),
                if (_searchQuery.isNotEmpty || _selectedCategory != null)
                  TextButton(
                    onPressed: () {
                      setState(() {
                        _searchController.clear();
                        _searchQuery = '';
                        _selectedCategory = null;
                      });
                      _fetchFilteredRecipes();
                    },
                    child: Text(
                      'Počisti filtre',
                      style: TextStyle(color: AppColors.tomatoRed),
                    ),
                  ),
              ],
            ),
          ),
          Expanded(
            child: _isLoading
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
                    : _filteredRecipes.isEmpty
                        ? Center(
                            child: Text(
                              _searchQuery.isEmpty && _selectedCategory == null
                                  ? 'Trenutno ni na voljo nobenih priporočenih receptov.'
                                  : 'Ni najdenih receptov za izbrane filtre.',
                              style: TextStyle(fontSize: 18, color: AppColors.dimGray),
                              textAlign: TextAlign.center,
                            ),
                          )
                        : RefreshIndicator(
                            onRefresh: _fetchFilteredRecipes,
                            child: ListView.builder(
                              padding: const EdgeInsets.all(16.0),
                              itemCount: _filteredRecipes.length,
                              itemBuilder: (context, index) {
                                final recipe = _filteredRecipes[index];
                                return RecipeCard(recipe: recipe);
                              },
                            ),
                          ),
          ),
        ],
      ),
    );
  }
}