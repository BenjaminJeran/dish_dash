import 'package:flutter/material.dart';
import 'package:dish_dash/colors/app_colors.dart'; // Ensure this path is correct

class PushNotificationsScreen extends StatelessWidget {
  const PushNotificationsScreen({super.key});

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
              Icon(Icons.notifications_none, size: 80, color: Colors.grey),
              SizedBox(height: 20),
              Text(
                'Customize your notification preferences.',
                textAlign: TextAlign.center,
                style: TextStyle(fontSize: 18, color: Colors.grey),
              ),
              SizedBox(height: 10),
              Text(
                'You can enable or disable various types of alerts, sounds, and vibrations here.',
                textAlign: TextAlign.center,
                style: TextStyle(fontSize: 14, color: Colors.grey),
              ),
              // You could add SwitchListTile widgets here for actual toggles
            ],
          ),
        ),
      ),
    );
  }
}
