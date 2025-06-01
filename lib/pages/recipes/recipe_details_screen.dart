import 'package:flutter/material.dart';
import 'package:dish_dash/colors/app_colors.dart';
import 'package:dish_dash/models/recipe.dart'; 
import 'package:dish_dash/pages/profile_page_screen.dart'; 

class RecipeDetailsScreen extends StatelessWidget {
  final Recipe recipe;

  const RecipeDetailsScreen({super.key, required this.recipe});

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
                  child: recipe.imageUrl.startsWith('http')
                      ? Image.network( 
                          recipe.imageUrl,
                          width: double.infinity,
                          height: 250,
                          fit: BoxFit.cover,
                          errorBuilder: (context, error, stackTrace) =>
                              Container( 
                                width: double.infinity,
                                height: 250,
                                color: AppColors.paleGray,
                                child: Icon(Icons.broken_image,
                                    color: AppColors.dimGray, size: 50),
                              ),
                        )
                      : Image.asset(
                          recipe.imageUrl,
                          width: double.infinity,
                          height: 250,
                          fit: BoxFit.cover,
                          errorBuilder: (context, error, stackTrace) =>
                              Container( 
                                width: double.infinity,
                                height: 250,
                                color: AppColors.paleGray,
                                child: Icon(Icons.image_not_supported,
                                    color: AppColors.dimGray, size: 50),
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
                        Icons.favorite_border,
                        color: AppColors.tomatoRed,
                      ),
                      onPressed: () {
                        print('Favorite button pressed for ${recipe.name}');
                      },
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
                    recipe.name,
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
                        '${recipe.cookingTime} min',
                        style: TextStyle(
                          color: AppColors.dimGray,
                          fontSize: 16,
                        ),
                      ),
                      const SizedBox(width: 16),
                      Icon(Icons.people, size: 20, color: AppColors.dimGray),
                      const SizedBox(width: 4),
                      Text(
                        '${recipe.servings} servings',
                        style: TextStyle(
                          color: AppColors.dimGray,
                          fontSize: 16,
                        ),
                      ),
                    ],
                  ),
                 
                  if (recipe.category.isNotEmpty) 
                    Padding(
                      padding: const EdgeInsets.only(top: 8.0),
                      child: Row(
                        children: [
                          Icon(Icons.category, size: 20, color: AppColors.dimGray),
                          const SizedBox(width: 4),
                          Text(
                            'Kategorija: ${recipe.category}', 
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
                    recipe.description, 
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
                      children: recipe.ingredients
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
                      children: recipe.instructions.asMap().entries.map((entry) {
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

                  // Edit Button
                  Center(
                    child: ElevatedButton(
                      onPressed: () {
                        print('Uredi button pressed for ${recipe.name}');
                        // TODO
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

                  // "Add to cart" (Dodaj v košarico) Button/Text
                  Center(
                    child: GestureDetector(
                      onTap: () {
                        print('Dodaj v košarico pressed for ${recipe.name}');
                        if (recipe.ingredients.isNotEmpty) {
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(
                              content: Text(
                                'Dodano v nakupovalni seznam: ${recipe.ingredients.join(', ')}',
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