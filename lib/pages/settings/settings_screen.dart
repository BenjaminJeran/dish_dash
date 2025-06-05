import 'package:dish_dash/pages/auth/login_screen.dart';
import 'package:flutter/material.dart';
import 'package:dish_dash/colors/app_colors.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:dish_dash/pages/settings/privacy_screen.dart';
import 'package:dish_dash/pages/settings/push_notifications_screen.dart';
import 'package:dish_dash/pages/settings/about_screen.dart';

class SettingsScreen extends StatefulWidget {
  const SettingsScreen({super.key});

  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
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
          ),
        ),
        centerTitle: true,
        actions: const [
          SizedBox(width: 50),
        ],
        elevation: 0,
        backgroundColor: Colors.transparent,
        foregroundColor: AppColors.charcoal,
      ),
      body: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 20.0, vertical: 35.0),
        child: Column(
          children: [
            _buildSettingsOption(
              context,
              icon: Icons.vpn_key_outlined,
              text: 'Zasebnost',
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => const PrivacyScreen(),
                  ),
                );
              },
            ),
            const SizedBox(height: 10),
            _buildSettingsOption(
              context,
              icon: Icons.notifications_none,
              text: 'Potisna obvestila',
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => const PushNotificationsScreen(),
                  ),
                );
              },
            ),
            const SizedBox(height: 10),
            _buildSettingsOption(
              context,
              icon: Icons.info_outline, // Zamenjana ikona za "O aplikaciji"
              text: 'O aplikaciji',
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => const AboutScreen()),
                );
              },
            ),
            const SizedBox(height: 10),
            _buildSettingsOption(
              context,
              icon: Icons.logout,
              text: 'Odjava',
              onTap: () async {
                try {
                  await Supabase.instance.client.auth.signOut();
                  if (mounted) {
                    Navigator.pushReplacement(
                      context,
                      MaterialPageRoute(
                        builder: (context) => const LoginScreen(),
                      ),
                    );
                  }
                } catch (e) {
                  print("Napaka med odjavo: $e");
                  if (mounted) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(content: Text('Napaka pri odjavi: $e')),
                    );
                  }
                }
              },
            ),
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