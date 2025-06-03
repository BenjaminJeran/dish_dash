import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'dart:io';
import 'dart:typed_data';
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:dish_dash/colors/app_colors.dart';

class ProfileAvatar extends StatefulWidget {
  final String? imageUrl;
  final VoidCallback onImageUpdated;

  const ProfileAvatar({
    super.key,
    required this.imageUrl,
    required this.onImageUpdated,
  });

  @override
  State<ProfileAvatar> createState() => _ProfileAvatarState();
}

class _ProfileAvatarState extends State<ProfileAvatar> {
  final _supabase = Supabase.instance.client;
  final _imagePicker = ImagePicker();
  bool _isUploading = false;

  Future<void> _pickImage(ImageSource source) async {
    final user = _supabase.auth.currentUser;
    if (user == null) return;

    final pickedFile = await _imagePicker.pickImage(source: source);
    if (pickedFile == null) return;

    setState(() => _isUploading = true);

    final fileName = '${user.id}_${DateTime.now().millisecondsSinceEpoch}.jpg';
    final filePath = 'profiles/$fileName';

    if (kIsWeb) {
      final bytes = await pickedFile.readAsBytes();
      await _supabase.storage.from('avatars').uploadBinary(filePath, bytes);
    } else {
      final file = File(pickedFile.path);
      await _supabase.storage.from('avatars').upload(filePath, file);
    }

    final url = _supabase.storage.from('avatars').getPublicUrl(filePath);
    await _supabase
        .from('users')
        .update({'profile_image_url': url})
        .eq('id', user.id);

    setState(() => _isUploading = false);
    widget.onImageUpdated();
  }

  void _showSourceDialog() {
    showDialog(
      context: context,
      builder:
          (_) => AlertDialog(
            title: const Text('Choose source'),
            content: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                ListTile(
                  leading: const Icon(Icons.photo),
                  title: const Text('Gallery'),
                  onTap: () {
                    Navigator.pop(context);
                    _pickImage(ImageSource.gallery);
                  },
                ),
                ListTile(
                  leading: const Icon(Icons.camera_alt),
                  title: const Text('Camera'),
                  onTap: () {
                    Navigator.pop(context);
                    _pickImage(ImageSource.camera);
                  },
                ),
              ],
            ),
          ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        CircleAvatar(
          radius: 60,
          backgroundImage:
              widget.imageUrl != null
                  ? NetworkImage(widget.imageUrl!)
                  : const AssetImage('assets/images/onboarding_1.png')
                      as ImageProvider,
          child:
              _isUploading
                  ? const CircularProgressIndicator(color: Colors.white)
                  : null,
        ),
        Positioned(
          bottom: 0,
          right: 0,
          child: GestureDetector(
            onTap: _isUploading ? null : _showSourceDialog,
            child: Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: AppColors.leafGreen,
                shape: BoxShape.circle,
                border: Border.all(color: Colors.white, width: 2),
              ),
              child: const Icon(
                Icons.camera_alt,
                size: 20,
                color: Colors.white,
              ),
            ),
          ),
        ),
      ],
    );
  }
}
