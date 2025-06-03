import 'package:flutter/material.dart';
import 'package:dish_dash/colors/app_colors.dart'; // Ensure this path is correct

class PrivacyScreen extends StatelessWidget {
  const PrivacyScreen({super.key});

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
              Icon(Icons.vpn_key_outlined, size: 80, color: Colors.grey),
              SizedBox(height: 20),
              Text(
                'Manage your privacy settings here.',
                textAlign: TextAlign.center,
                style: TextStyle(fontSize: 18, color: Colors.grey),
              ),
              SizedBox(height: 10),
              Text(
                'This section would typically include options for data usage, personalization, and account visibility.',
                textAlign: TextAlign.center,
                style: TextStyle(fontSize: 14, color: Colors.grey),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
