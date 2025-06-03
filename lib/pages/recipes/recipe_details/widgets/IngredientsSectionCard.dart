// lib/widgets/ingredients_section_card.dart
import 'package:flutter/material.dart';
import 'package:dish_dash/colors/app_colors.dart';

class IngredientsSectionCard extends StatelessWidget {
  final String emoji;
  final List<String> ingredients;

  const IngredientsSectionCard({
    super.key,
    required this.emoji,
    required this.ingredients,
  });

  @override
  Widget build(BuildContext context) {
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
            width: 35,
            height: 35,
            decoration: BoxDecoration(
              color: AppColors.leafGreen,
              shape: BoxShape.circle,
            ),
            child: Center(
              child: Text(
                emoji,
                style: TextStyle(
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
                  'Sestavine',
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    color: AppColors.charcoal,
                  ),
                ),
                const SizedBox(height: 10),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: ingredients
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
              ],
            ),
          ),
        ],
      ),
    );
  }
}