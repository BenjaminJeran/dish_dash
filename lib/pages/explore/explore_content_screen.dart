// lib/pages/explore/explore_content_screen.dart
import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:dish_dash/colors/app_colors.dart';
import 'package:dish_dash/models/recipe.dart';
import 'package:dish_dash/components/recipe_card.dart'; // Import the new RecipeCard component

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

  // UPDATED CATEGORIES TO MATCH YOUR CREATE SCREEN
  final List<Map<String, String>> _categories = [
    {'name': 'Zajtrk', 'image': 'assets/logo.png'},
    {'name': 'Kosilo', 'image': 'assets/logo.png'},
    {'name': 'Večerja', 'image': 'assets/logo.png'},
    {'name': 'Sladica', 'image': 'assets/logo.png'},
    {'name': 'Prigrizek', 'image': 'assets/logo.png'},
    {'name': 'Drugo', 'image': 'assets/logo.png'},
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
    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    try {
      var query = supabase.from('recipes').select();

      if (_searchQuery.isNotEmpty) {
        // Using `ilike` for case-insensitive search
        query = query.ilike('name', '%$_searchQuery%');
      }

      if (_selectedCategory != null) {
        query = query.eq('category', _selectedCategory!);
      }

      final List<Map<String, dynamic>> data = await query;

      setState(() {
        _filteredRecipes = data.map((map) => Recipe.fromMap(map)).toList();
        _isLoading = false;
      });
    } on PostgrestException catch (e) {
      setState(() {
        _errorMessage = 'Napaka pri nalaganju receptov: ${e.message}';
        _isLoading = false;
      });
      print('Supabase Error: ${e.message}');
    } catch (e) {
      setState(() {
        _errorMessage = 'Prišlo je do nepričakovanih napake pri nalaganju receptov: $e';
        _isLoading = false;
      });
      print('General Error: $e');
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
      // Toggle category selection
      _selectedCategory = categoryName == _selectedCategory ? null : categoryName;
    });
    _fetchFilteredRecipes();
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
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
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
                              'Ni najdenih receptov za izbrane filtre.',
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
                                // Use the reusable RecipeCard component here
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
