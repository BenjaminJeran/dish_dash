import 'package:flutter/material.dart';
import 'package:dish_dash/colors/app_colors.dart';

class RecipeImageSection extends StatelessWidget {
  final String imageUrl;
  final bool isLikedByUser;
  final VoidCallback onToggleLike;

  const RecipeImageSection({
    super.key,
    required this.imageUrl,
    required this.isLikedByUser,
    required this.onToggleLike,
  });

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        ClipRRect(
          borderRadius: BorderRadius.circular(20),
          child: imageUrl.startsWith('http')
              ? Image.network(
                  imageUrl,
                  width: double.infinity,
                  height: 250,
                  fit: BoxFit.cover,
                  errorBuilder: (context, error, stackTrace) => Container(
                    width: double.infinity,
                    height: 250,
                    color: AppColors.paleGray,
                    child: Icon(
                      Icons.broken_image,
                      color: AppColors.dimGray,
                      size: 50,
                    ),
                  ),
                )
              : Image.asset(
                  imageUrl,
                  width: double.infinity,
                  height: 250,
                  fit: BoxFit.cover,
                  errorBuilder: (context, error, stackTrace) => Container(
                    width: double.infinity,
                    height: 250,
                    color: AppColors.paleGray,
                    child: Icon(
                      Icons.image_not_supported,
                      color: AppColors.dimGray,
                      size: 50,
                    ),
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
                isLikedByUser ? Icons.favorite : Icons.favorite_border,
                color: AppColors.tomatoRed,
              ),
              onPressed: onToggleLike,
            ),
          ),
        ),
      ],
    );
  }
}