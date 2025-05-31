import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:dish_dash/pages/settings_screen.dart';
import 'package:flutter/material.dart';
import 'package:dish_dash/colors/app_colors.dart';

class ProfilePageScreen extends StatefulWidget {
  const ProfilePageScreen({super.key});

  @override
  State<ProfilePageScreen> createState() => _ProfilePageScreenState();
}

class _ProfilePageScreenState extends State<ProfilePageScreen> {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  String _userName = 'Loading...';
  String _userProfession = 'Profesionalni kuhar';
  String _aboutMeText = 'O meni';
  final double _cookingChallengeProgress = 0.75;

  final TextEditingController _userNameController = TextEditingController();
  final TextEditingController _aboutMeController = TextEditingController();

  bool _isEditingName = false;
  bool _isEditingAboutMe = false;
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _fetchUserData();
  }

  @override
  void dispose() {
    _userNameController.dispose();
    _aboutMeController.dispose();
    super.dispose();
  }

  Future<void> _fetchUserData() async {
    setState(() {
      _isLoading = true;
    });

    User? user = _auth.currentUser;
    if (user != null) {
      DocumentSnapshot userDoc =
          await _firestore.collection('users').doc(user.uid).get();

      if (userDoc.exists) {
        setState(() {
          _userName = userDoc.get('name') ?? 'No Name';
          _userProfession = userDoc.get('profession') ?? 'Not specified';
          _aboutMeText =
              userDoc.get('aboutMe') ?? 'Tell us something about yourself!';
          _userNameController.text = _userName;
          _aboutMeController.text = _aboutMeText;
        });
      } else {
        await _firestore.collection('users').doc(user.uid).set({
          'name': 'New User',
          'email': user.email,
          'profession': 'Profesionalni kuhar',
          'aboutMe': 'O meni',
          'createdAt': FieldValue.serverTimestamp(),
        });
        setState(() {
          _userName = 'New User';
          _userProfession = 'Profesionalni kuhar';
          _aboutMeText = 'O meni';
          _userNameController.text = _userName;
          _aboutMeController.text = _aboutMeText;
        });
      }
    } else {
      print('User not logged in!');
      setState(() {
        _userName = 'Guest';
        _userProfession = '';
        _aboutMeText = '';
      });
    }

    setState(() {
      _isLoading = false;
    });
  }

  Future<void> _updateUserData(String field, dynamic value) async {
    User? user = _auth.currentUser;
    if (user != null) {
      try {
        await _firestore.collection('users').doc(user.uid).update({
          field: value,
          'updatedAt': FieldValue.serverTimestamp(),
        });
        print('User data updated successfully: $field = $value');
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text('$field updated!')));
      } catch (e) {
        print('Error updating user data: $e');
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text('Failed to update $field.')));
      }
    }
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
        title: Center(child: Image.asset('assets/logo.png', height: 80)),
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
        elevation: 0,
        backgroundColor: Colors.transparent,
        foregroundColor: AppColors.charcoal,
      ),
      body:
          _isLoading
              ? const Center(child: CircularProgressIndicator())
              : SingleChildScrollView(
                padding: const EdgeInsets.symmetric(
                  horizontal: 20.0,
                  vertical: 10.0,
                ),
                child: Column(
                  children: [
                    CircleAvatar(
                      radius: 60,
                      backgroundColor: AppColors.paleGray,
                      backgroundImage: const AssetImage(
                        'assets/images/onboarding_1.png',
                      ),
                    ),
                    const SizedBox(height: 15),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        _isEditingName
                            ? Expanded(
                              child: TextField(
                                controller: _userNameController,
                                textAlign: TextAlign.center,
                                style: TextStyle(
                                  fontSize: 24,
                                  fontWeight: FontWeight.bold,
                                  color: AppColors.charcoal,
                                ),
                                decoration: InputDecoration(
                                  isDense: true,
                                  contentPadding: EdgeInsets.zero,
                                  border: UnderlineInputBorder(
                                    borderSide: BorderSide(
                                      color: AppColors.leafGreen,
                                    ),
                                  ),
                                ),
                                onSubmitted: (newValue) {
                                  setState(() {
                                    _userName = newValue;
                                    _isEditingName = false;
                                  });
                                  _updateUserData('name', newValue);
                                },
                              ),
                            )
                            : Text(
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
                            setState(() {
                              _isEditingName = !_isEditingName;
                              if (!_isEditingName) {
                                _updateUserData(
                                  'name',
                                  _userNameController.text,
                                );
                                _userName = _userNameController.text;
                              }
                            });
                          },
                          child: Icon(
                            _isEditingName ? Icons.check : Icons.edit,
                            size: 20,
                            color: AppColors.dimGray,
                          ),
                        ),
                      ],
                    ),
                    Text(
                      _userProfession,
                      style: TextStyle(fontSize: 16, color: AppColors.dimGray),
                    ),
                    const SizedBox(height: 30),

                    Align(
                      alignment: Alignment.centerLeft,
                      child: Container(
                        padding: const EdgeInsets.all(15),
                        decoration: BoxDecoration(
                          color: AppColors.paleGray,
                          borderRadius: BorderRadius.circular(10),
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Text(
                                  'O meni',
                                  style: TextStyle(
                                    fontSize: 18,
                                    fontWeight: FontWeight.bold,
                                    color: AppColors.charcoal,
                                  ),
                                ),
                                GestureDetector(
                                  onTap: () {
                                    setState(() {
                                      _isEditingAboutMe = !_isEditingAboutMe;
                                      if (!_isEditingAboutMe) {
                                        _updateUserData(
                                          'aboutMe',
                                          _aboutMeController.text,
                                        );
                                        _aboutMeText = _aboutMeController.text;
                                      }
                                    });
                                  },
                                  child: Icon(
                                    _isEditingAboutMe
                                        ? Icons.check
                                        : Icons.edit,
                                    size: 20,
                                    color: AppColors.dimGray,
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 10),
                            _isEditingAboutMe
                                ? TextField(
                                  controller: _aboutMeController,
                                  maxLines: 5,
                                  decoration: InputDecoration(
                                    hintText: 'Povejte nekaj o sebi...',
                                    hintStyle: TextStyle(
                                      color: AppColors.dimGray,
                                    ),
                                    border: InputBorder.none,
                                    isDense: true,
                                    contentPadding: EdgeInsets.zero,
                                  ),
                                  style: TextStyle(
                                    fontSize: 16,
                                    color: AppColors.charcoal,
                                  ),
                                )
                                : Text(
                                  _aboutMeText,
                                  style: TextStyle(
                                    fontSize: 16,
                                    color: AppColors.charcoal,
                                  ),
                                ),
                          ],
                        ),
                      ),
                    ),
                    const SizedBox(height: 30),

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
                    LinearProgressIndicator(
                      value: _cookingChallengeProgress,
                      backgroundColor: AppColors.paleGray,
                      valueColor: AlwaysStoppedAnimation<Color>(
                        AppColors.leafGreen,
                      ),
                      minHeight: 25,
                      borderRadius: BorderRadius.circular(10),
                    ),
                    Transform.translate(
                      offset: const Offset(0, -25),
                      child: SizedBox(
                        height: 25,
                        child: Align(
                          alignment: Alignment.center,
                          child: Text(
                            '${(_cookingChallengeProgress * 100).toInt()}%',
                            style: TextStyle(
                              color: AppColors.charcoal,
                              fontWeight: FontWeight.bold,
                              fontSize: 16,
                            ),
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(height: 20),
                  ],
                ),
              ),
    );
  }
}
