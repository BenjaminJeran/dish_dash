import 'package:flutter/material.dart';
import 'package:dish_dash/colors/app_colors.dart';
import 'package:dish_dash/services/user_service.dart';
import 'package:dish_dash/pages/settings/settings_screen.dart';
import 'widgets/profile_avatar.dart';
import 'widgets/editable_text_field.dart';
import 'widgets/about_me_card.dart';
import 'widgets/cooking_challenge_bar.dart';

class ProfilePageScreen extends StatefulWidget {
  const ProfilePageScreen({super.key});

  @override
  State<ProfilePageScreen> createState() => _ProfilePageScreenState();
}

class _ProfilePageScreenState extends State<ProfilePageScreen> {
  final UserService _userService = UserService();

  String userName = 'Loading...';
  String profession = '';
  String aboutMe = '';
  String? profileImageUrl;
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadUserData();
  }

  Future<void> _loadUserData() async {
    setState(() => isLoading = true);

    final data = await _userService.getUserProfile();

    if (data == null) {
      await _userService.createDefaultUser();
      return _loadUserData();
    }

    setState(() {
      userName = data['name'] ?? 'New User';
      profession = data['profession'] ?? '';
      aboutMe = data['about_me'] ?? '';
      profileImageUrl = data['profile_image_url'];
      isLoading = false;
    });
  }

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
          child: Center(child: Image.asset('assets/logo.png', height: 80)),
        ),
        centerTitle: true,
        actions: [
          IconButton(
            icon: const Icon(Icons.settings),
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => const SettingsScreen()),
              );
            },
          ),
        ],
        backgroundColor: Colors.transparent,
        foregroundColor: AppColors.charcoal,
        elevation: 0,
      ),
      body:
          isLoading
              ? const Center(child: CircularProgressIndicator())
              : SingleChildScrollView(
                padding: const EdgeInsets.all(20),
                child: Column(
                  children: [
                    ProfileAvatar(
                      imageUrl: profileImageUrl,
                      onImageUpdated: _loadUserData,
                    ),
                    const SizedBox(height: 15),
                    EditableTextField(
                      value: userName,
                      onChanged: (val) async {
                        await _userService.updateUserField('name', val);
                        setState(() => userName = val);
                      },
                      style: TextStyle(
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                        color: AppColors.charcoal,
                      ),
                    ),
                    Text(
                      profession,
                      style: TextStyle(color: AppColors.dimGray),
                    ),
                    const SizedBox(height: 20),
                    AboutMeCard(
                      text: aboutMe,
                      onChanged: (val) async {
                        await _userService.updateUserField('about_me', val);
                        setState(() => aboutMe = val);
                      },
                    ),
                    const SizedBox(height: 20),
                    const CookingChallengeBar(progress: 0.75),
                  ],
                ),
              ),
    );
  }
}
