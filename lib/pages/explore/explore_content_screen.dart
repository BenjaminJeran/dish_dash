// lib/pages/explore/explore_content_screen.dart
import 'package:flutter/material.dart';
import 'package:dish_dash/colors/app_colors.dart';

class ExploreContentScreen extends StatelessWidget {
  const ExploreContentScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.search, size: 80, color: AppColors.dimGray),
            const SizedBox(height: 20),
            Text(
              'Raziščite nove recepte!', // "Explore new recipes!"
              style: TextStyle(fontSize: 20, color: AppColors.dimGray),
            ),
          ],
        ),
      ),
    );
  }
}
