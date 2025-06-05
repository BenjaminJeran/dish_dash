// lib/components/recipe_card.dart
import 'package:flutter/material.dart';
import 'package:dish_dash/colors/app_colors.dart';
import 'package:dish_dash/models/recipe.dart';
import 'package:dish_dash/pages/recipes/recipe_details/recipe_details_screen.dart';

class RecipeCard extends StatelessWidget {
  final Recipe recipe;

  const RecipeCard({
    super.key,
    required this.recipe,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 4.0,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
      margin: const EdgeInsets.only(bottom: 15),
      clipBehavior: Clip.antiAlias,
      child: InkWell(
        onTap: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => RecipeDetailsScreen(recipe: recipe),
            ),
          );
        },
        child: SizedBox(
          height: 160, 
          child: Stack(
            children: [
              Positioned.fill(
                child: recipe.imageUrl.startsWith('http')
                    ? Image.network(
                        recipe.imageUrl,
                        fit: BoxFit.cover,
                        errorBuilder: (context, error, stackTrace) =>
                            Container(
                          color: AppColors.paleGray,
                          child: Icon(Icons.broken_image,
                              color: AppColors.dimGray, size: 40), 
                        ),
                      )
                    : Image.asset(
                        recipe.imageUrl,
                        fit: BoxFit.cover,
                      ),
              ),
              Positioned.fill(
                child: Container(
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      begin: Alignment.topCenter,
                      end: Alignment.bottomCenter,
                      colors: [
                        Colors.black.withOpacity(0.0),
                        Colors.black.withOpacity(0.6),
                      ],
                    ),
                  ),
                ),
              ),
              Positioned(
                bottom: 12, 
                left: 12, 
                right: 12, 
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      recipe.name,
                      style: const TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 6), 
                    Row(
                      children: [
                        Icon(
                          Icons.access_time,
                          size: 16, 
                          color: AppColors.paleGray,
                        ),
                        const SizedBox(width: 4),
                        Text(
                          '${recipe.cookingTime} min',
                          style: TextStyle(
                            color: AppColors.paleGray,
                            fontSize: 12, 
                          ),
                        ),
                        const SizedBox(width: 10), 
                        Icon(Icons.people, size: 16, color: AppColors.paleGray),
                        const SizedBox(width: 4),
                        Text(
                          '${recipe.servings} servings',
                          style: TextStyle(
                            color: AppColors.paleGray,
                            fontSize: 12,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              Positioned(
                top: 12, 
                right: 12, 
                child: Icon(Icons.arrow_forward, size: 24, color: Colors.white), 
              ),
            ],
          ),
        ),
      ),
    );
  }
}
// A SM FAJN NAREDU FANTA A
//- MIHA