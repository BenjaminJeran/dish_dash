
import 'package:flutter/material.dart';
import 'package:dish_dash/colors/app_colors.dart';
import 'package:dish_dash/models/recipe.dart'; 

class RecipeInfoSection extends StatelessWidget {
  final Recipe recipe;
  final int likesCount;

  const RecipeInfoSection({
    super.key,
    required this.recipe,
    required this.likesCount,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
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
            const SizedBox(width: 16),
            Icon(Icons.favorite, size: 20, color: AppColors.tomatoRed),
            const SizedBox(width: 4),
            Text(
              '$likesCount',
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
                Icon(
                  Icons.category,
                  size: 20,
                  color: AppColors.dimGray,
                ),
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
      ],
    );
  }
}