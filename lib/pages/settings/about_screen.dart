import 'package:flutter/material.dart';
import 'package:dish_dash/colors/app_colors.dart'; // Ensure this path is correct

class AboutScreen extends StatelessWidget {
  const AboutScreen({super.key});

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
        title: SizedBox(
          height: 80,
          child: Center(
            child: Image.asset('assets/logo.png', height: 80),
          ), // Your app logo
        ),
        centerTitle: true,
        actions: const [
          SizedBox(width: 50), // To balance the back button and center the logo
        ],
        elevation: 0,
        backgroundColor: Colors.transparent,
        foregroundColor: AppColors.charcoal,
      ),
      body: const Center(
        child: Padding(
          padding: EdgeInsets.all(20.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(Icons.info_outline, size: 80, color: Colors.grey),
              SizedBox(height: 20),
              Text(
                'Dish Dash App',
                style: TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                  color: Colors.black87,
                ),
              ),
              SizedBox(height: 10),
              Text(
                'Version 1.0.0',
                style: TextStyle(fontSize: 16, color: Colors.grey),
              ),
              SizedBox(height: 20),
              Text(
                'Dish Dash is your culinary companion, helping you explore new recipes and track your cooking challenges.',
                textAlign: TextAlign.center,
                style: TextStyle(fontSize: 16, color: Colors.black54),
              ),
              SizedBox(height: 20),
              Text(
                '© 2023 Dish Dash Inc. All rights reserved.',
                textAlign: TextAlign.center,
                style: TextStyle(fontSize: 12, color: Colors.grey),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
