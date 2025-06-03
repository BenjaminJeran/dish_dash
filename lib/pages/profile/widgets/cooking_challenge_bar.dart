import 'package:flutter/material.dart';
import 'package:dish_dash/colors/app_colors.dart';

class CookingChallengeBar extends StatelessWidget {
  final double progress; // value between 0.0 and 1.0

  const CookingChallengeBar({super.key, required this.progress});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Kuharski izziv',
          style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 8),
        ClipRRect(
          borderRadius: BorderRadius.circular(10),
          child: LinearProgressIndicator(
            value: progress,
            minHeight: 12,
            backgroundColor: AppColors.white,
            valueColor: AlwaysStoppedAnimation<Color>(AppColors.leafGreen),
          ),
        ),
        const SizedBox(height: 8),
        Text('${(progress * 100).toStringAsFixed(0)}% kompletirano'),
      ],
    );
  }
}
