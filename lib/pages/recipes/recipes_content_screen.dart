// lib/pages/recipes/recipes_content_screen.dart
import 'package:flutter/material.dart';
import 'package:dish_dash/colors/app_colors.dart';

class RecipesContentScreen extends StatelessWidget {
  const RecipesContentScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        leading: null,
        automaticallyImplyLeading: false,
        title: Text(
          'Moji Recepti',
          style: Theme.of(context).appBarTheme.titleTextStyle,
        ), // "My Recipes"
        centerTitle: true,
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.menu_book, size: 80, color: AppColors.dimGray),
            const SizedBox(height: 20),
            Text(
              'Tukaj bodo vaši shranjeni recepti.', // "Your saved recipes will be here."
              style: TextStyle(fontSize: 20, color: AppColors.dimGray),
            ),
          ],
        ),
      ),
    );
  }
}
