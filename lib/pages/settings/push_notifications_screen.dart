// lib/pages/settings/push_notifications_screen.dart
import 'package:flutter/material.dart';
import 'package:dish_dash/colors/app_colors.dart';

class PushNotificationsScreen extends StatelessWidget {
  const PushNotificationsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => Navigator.pop(context),
        ),
        title: SizedBox(
          height: 80,
          child: Center(child: Image.asset('assets/logo.png', height: 80)),
        ),
        centerTitle: true,
        actions: const [SizedBox(width: 50)],
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
                'Prilagodi svoje nastavitve obvestil.',
                textAlign: TextAlign.center,
                style: TextStyle(fontSize: 18, color: Colors.grey),
              ),
              SizedBox(height: 10),
              Text(
                'Tukaj lahko omogočiš ali onemogočiš različne vrste opozoril, zvokov in vibracij.',
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