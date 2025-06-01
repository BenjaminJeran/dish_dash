import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:dish_dash/pages/settings_screen.dart';
import 'package:flutter/material.dart';
import 'package:dish_dash/colors/app_colors.dart';
import 'package:image_picker/image_picker.dart';
import 'dart:io';
import 'dart:typed_data';
import 'package:flutter/foundation.dart' show kIsWeb;

class ProfilePageScreen extends StatefulWidget {
  const ProfilePageScreen({super.key});

  @override
  State<ProfilePageScreen> createState() => _ProfilePageScreenState();
}

class _ProfilePageScreenState extends State<ProfilePageScreen> {
  final SupabaseClient _supabase = Supabase.instance.client;
  final ImagePicker _imagePicker = ImagePicker();

  String _userName = 'Loading...';
  String _userProfession = 'Profesionalni kuhar';
  String _aboutMeText = 'O meni';
  String? _profileImageUrl;
  final double _cookingChallengeProgress = 0.75;

  final TextEditingController _userNameController = TextEditingController();
  final TextEditingController _aboutMeController = TextEditingController();

  bool _isEditingName = false;
  bool _isEditingAboutMe = false;
  bool _isLoading = true;
  bool _isUploadingImage = false;

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

    try {
      final User? user = _supabase.auth.currentUser;
      if (user != null) {
        final response =
            await _supabase
                .from('users')
                .select()
                .eq('id', user.id)
                .maybeSingle();

        if (response != null) {
          setState(() {
            _userName = response['name'] ?? 'No Name';
            _userProfession = response['profession'] ?? 'Not specified';
            _aboutMeText =
                response['about_me'] ?? 'Tell us something about yourself!';
            _profileImageUrl = response['profile_image_url'];
            _userNameController.text = _userName;
            _aboutMeController.text = _aboutMeText;
          });
        } else {
          // Create new user record
          await _supabase.from('users').insert({
            'id': user.id,
            'name': 'New User',
            'email': user.email,
            'profession': 'Profesionalni kuhar',
            'about_me': 'O meni',
            'created_at': DateTime.now().toIso8601String(),
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
    } catch (e) {
      print('Error fetching user data: $e');
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('Error loading profile: $e')));
    }

    setState(() {
      _isLoading = false;
    });
  }

  Future<void> _updateUserData(String field, dynamic value) async {
    final User? user = _supabase.auth.currentUser;
    if (user != null) {
      try {
        await _supabase
            .from('users')
            .update({
              field: value,
              'updated_at': DateTime.now().toIso8601String(),
            })
            .eq('id', user.id);

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

  Future<void> _showImageSourceDialog() async {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Select Image Source'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              ListTile(
                leading: const Icon(Icons.photo_library),
                title: const Text('Gallery'),
                onTap: () {
                  Navigator.pop(context);
                  _pickImageFromSource(ImageSource.gallery);
                },
              ),
              ListTile(
                leading: const Icon(Icons.camera_alt),
                title: const Text('Camera'),
                onTap: () {
                  Navigator.pop(context);
                  _pickImageFromSource(ImageSource.camera);
                },
              ),
            ],
          ),
        );
      },
    );
  }

  Future<void> _pickImageFromSource(ImageSource source) async {
    try {
      final XFile? pickedFile = await _imagePicker.pickImage(
        source: source,
        maxWidth: 800,
        maxHeight: 800,
        imageQuality: 85,
      );

      if (pickedFile == null) return;

      setState(() {
        _isUploadingImage = true;
      });

      final User? user = _supabase.auth.currentUser;
      if (user == null) {
        throw Exception('User not authenticated');
      }

      // Delete old image if exists
      if (_profileImageUrl != null) {
        try {
          final String oldFileName = _profileImageUrl!.split('/').last;
          await _supabase.storage.from('avatars').remove([
            'profiles/$oldFileName',
          ]);
        } catch (e) {
          print('Error deleting old image: $e');
        }
      }

      // Generate unique filename
      final String fileName =
          '${user.id}_${DateTime.now().millisecondsSinceEpoch}.jpg';
      final String filePath = 'profiles/$fileName';

      // Upload image to Supabase Storage
      late String uploadedPath;

      if (kIsWeb) {
        // For web, read as bytes
        final Uint8List imageBytes = await pickedFile.readAsBytes();
        uploadedPath = await _supabase.storage
            .from('avatars')
            .uploadBinary(filePath, imageBytes);
      } else {
        // For mobile, upload file directly
        final File imageFile = File(pickedFile.path);
        uploadedPath = await _supabase.storage
            .from('avatars')
            .upload(filePath, imageFile);
      }

      // Get public URL
      final String publicUrl = _supabase.storage
          .from('avatars')
          .getPublicUrl(filePath);

      // Update user profile with new image URL
      await _updateUserData('profile_image_url', publicUrl);

      setState(() {
        _profileImageUrl = publicUrl;
      });

      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('Profile picture updated!')));
    } catch (e) {
      print('Error uploading image: $e');
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('Failed to upload image: $e')));
    } finally {
      setState(() {
        _isUploadingImage = false;
      });
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
                    Stack(
                      children: [
                        CircleAvatar(
                          radius: 60,
                          backgroundColor: AppColors.paleGray,
                          backgroundImage:
                              _profileImageUrl != null
                                  ? NetworkImage(_profileImageUrl!)
                                  : const AssetImage(
                                        'assets/images/onboarding_1.png',
                                      )
                                      as ImageProvider,
                          child:
                              _isUploadingImage
                                  ? const CircularProgressIndicator(
                                    color: Colors.white,
                                    strokeWidth: 2,
                                  )
                                  : null,
                        ),
                        Positioned(
                          bottom: 0,
                          right: 0,
                          child: GestureDetector(
                            onTap:
                                _isUploadingImage
                                    ? null
                                    : _showImageSourceDialog,
                            child: Container(
                              padding: const EdgeInsets.all(8),
                              decoration: BoxDecoration(
                                color: AppColors.leafGreen,
                                shape: BoxShape.circle,
                                border: Border.all(
                                  color: Colors.white,
                                  width: 2,
                                ),
                              ),
                              child: Icon(
                                Icons.camera_alt,
                                color: Colors.white,
                                size: 20,
                              ),
                            ),
                          ),
                        ),
                      ],
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
                                          'about_me',
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
