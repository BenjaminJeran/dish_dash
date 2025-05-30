import 'package:flutter/material.dart';
import 'package:dish_dash/colors/app_colors.dart'; // Ensure this path is correct

class SettingsScreen extends StatelessWidget {
  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () {
            Navigator.pop(
              context,
            ); // Navigate back to the previous screen (ProfilePageScreen)
          },
        ),
        title: Center(
          child: Image.asset('assets/logo.png', height: 80), // Your app logo
        ),
        // No actions needed on the right side for the settings page app bar based on the image
        actions: const [
          SizedBox(width: 50), // To balance the back button and center the logo
        ],
        elevation: 0,
        backgroundColor: Colors.transparent,
        foregroundColor: AppColors.charcoal,
      ),
      body: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 20.0, vertical: 10.0),
        child: Column(
          children: [
            // Settings Options List
            _buildSettingsOption(
              context,
              icon: Icons.vpn_key_outlined,
              text: 'Privacy',
              onTap: () {
                print('Privacy tapped');
                // TODO: Navigate to Privacy settings
              },
            ),
            const SizedBox(height: 10),
            _buildSettingsOption(
              context,
              icon: Icons.notifications_none,
              text: 'Push Notifications',
              onTap: () {
                print('Push Notifications tapped');
                // TODO: Navigate to Push Notifications settings
              },
            ),
            const SizedBox(height: 10),
            _buildSettingsOption(
              context,
              icon: Icons.favorite_border,
              text: 'About',
              onTap: () {
                print('About tapped');
                // TODO: Navigate to About page
              },
            ),
            const SizedBox(height: 10),
            _buildSettingsOption(
              context,
              icon: Icons.logout,
              text: 'Sign Out',
              onTap: () {
                print('Sign Out tapped');
                // TODO: Implement sign out logic (e.g., clear user session, navigate to login)
              },
            ),
            // Add more options as needed
          ],
        ),
      ),
    );
  }

  Widget _buildSettingsOption(
    BuildContext context, {
    required IconData icon,
    required String text,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        decoration: BoxDecoration(
          color: AppColors.leafGreen,
          borderRadius: BorderRadius.circular(10),
        ),
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 15),
        child: Row(
          children: [
            Icon(icon, color: AppColors.white),
            const SizedBox(width: 20),
            Expanded(
              child: Text(
                text,
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.w600,
                  color: AppColors.white,
                ),
              ),
            ),
            Icon(Icons.arrow_forward_ios, color: AppColors.white, size: 20),
          ],
        ),
      ),
    );
  }
}
