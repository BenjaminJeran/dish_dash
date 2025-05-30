import 'package:dish_dash/pages/settings_screen.dart';
import 'package:flutter/material.dart';
import 'package:dish_dash/colors/app_colors.dart'; // Ensure this path is correct

class ProfilePageScreen extends StatefulWidget {
  const ProfilePageScreen({super.key});

  @override
  State<ProfilePageScreen> createState() => _ProfilePageScreenState();
}

class _ProfilePageScreenState extends State<ProfilePageScreen> {
  // You might fetch this data from a user model or database
  final String _userName = 'Miha Klančnik';
  final String _userProfession = 'Profesionalni kuhar';
  String _aboutMeText = 'O meni'; // Placeholder for "About me"
  final double _cookingChallengeProgress = 0.75; // 75% progress

  // A controller for the "About me" text field if it needs to be editable
  final TextEditingController _aboutMeController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _aboutMeController.text = _aboutMeText;
  }

  @override
  void dispose() {
    _aboutMeController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () {
            Navigator.pop(context); // Navigate back to the previous screen
          },
        ),
        title: Center(
          child: Image.asset('assets/logo.png', height: 80), // Your app logo
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.settings), // Settings icon
            onPressed: () {
              // TODO: Navigate to settings screen
              print('Settings icon pressed');
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => const SettingsScreen()),
              );
            },
          ),
        ],
        elevation: 0,
        backgroundColor: Colors.transparent,
        foregroundColor: AppColors.charcoal,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(horizontal: 20.0, vertical: 10.0),
        child: Column(
          children: [
            // Profile Picture
            CircleAvatar(
              radius: 60,
              backgroundColor: AppColors.paleGray, // Placeholder background
              backgroundImage: const AssetImage(
                'assets/images/onboarding_1.png',
              ), // Placeholder image
              // You would use NetworkImage or FileImage for actual user photos
              // Example: NetworkImage('https://example.com/user_profile_pic.jpg'),
            ),
            const SizedBox(height: 15),

            // User Name and Edit Icon
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  _userName,
                  style: TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                    color: AppColors.charcoal,
                  ),
                ),
                const SizedBox(width: 8),
                GestureDetector(
                  onTap: () {
                    // TODO: Implement name editing logic
                    print('Edit name pressed');
                  },
                  child: Icon(Icons.edit, size: 20, color: AppColors.dimGray),
                ),
              ],
            ),
            Text(
              _userProfession,
              style: TextStyle(fontSize: 16, color: AppColors.dimGray),
            ),
            const SizedBox(height: 30),

            // About Me section
            Align(
              alignment: Alignment.centerLeft,
              child: Container(
                padding: const EdgeInsets.all(15),
                decoration: BoxDecoration(
                  color: AppColors.paleGray,
                  borderRadius: BorderRadius.circular(10),
                ),
                child: TextField(
                  controller: _aboutMeController,
                  maxLines: 5, // Allow multiple lines
                  decoration: InputDecoration(
                    hintText: 'O meni',
                    hintStyle: TextStyle(color: AppColors.dimGray),
                    border: InputBorder.none, // No border for a clean look
                    isDense: true, // Reduces vertical space
                    contentPadding: EdgeInsets.zero, // No internal padding
                  ),
                  style: TextStyle(fontSize: 16, color: AppColors.charcoal),
                  onChanged: (text) {
                    setState(() {
                      _aboutMeText = text; // Update the state when text changes
                    });
                  },
                  // You might want to make this read-only and add an edit button
                  // readOnly: true,
                ),
              ),
            ),
            const SizedBox(height: 30),

            // Cooking Challenges section
            Align(
              alignment: Alignment.centerLeft,
              child: Text(
                'Kuharski izzivi',
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  color: AppColors.charcoal,
                ),
              ),
            ),
            const SizedBox(height: 10),
            // Progress Bar
            LinearProgressIndicator(
              value: _cookingChallengeProgress, // Current progress (0.0 to 1.0)
              backgroundColor: AppColors.paleGray,
              valueColor: AlwaysStoppedAnimation<Color>(AppColors.leafGreen),
              minHeight: 25, // Height of the progress bar
              borderRadius: BorderRadius.circular(10), // Rounded corners
            ),
            // Display percentage on top of the progress bar
            Transform.translate(
              offset: const Offset(0, -25), // Adjust offset to overlay text
              child: SizedBox(
                height: 25,
                child: Align(
                  alignment: Alignment.center,
                  child: Text(
                    '${(_cookingChallengeProgress * 100).toInt()}%',
                    style: TextStyle(
                      color: AppColors.charcoal, // Text color
                      fontWeight: FontWeight.bold,
                      fontSize: 16,
                    ),
                  ),
                ),
              ),
            ),
            const SizedBox(height: 20), // Adjust spacing
          ],
        ),
      ),
    );
  }
}
