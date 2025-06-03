import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'dart:io';

import 'package:dish_dash/colors/app_colors.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class CreateRecipeScreen extends StatefulWidget {
  const CreateRecipeScreen({super.key});

  @override
  State<CreateRecipeScreen> createState() => _CreateRecipeScreenState();
}

class _CreateRecipeScreenState extends State<CreateRecipeScreen> {
  final SupabaseClient supabase = Supabase.instance.client;

  final TextEditingController _recipeNameController = TextEditingController();
  final TextEditingController _descriptionController = TextEditingController();
  final TextEditingController _cookingTimeController = TextEditingController();
  final TextEditingController _servingsController = TextEditingController();

  final List<TextEditingController> _ingredientControllers = [];
  final List<TextEditingController> _instructionControllers = [];

  String? _selectedCategory;
  final List<String> _categories = [
    'Zajtrk',
    'Kosilo',
    'Večerja',
    'Sladica',
    'Prigrizek',
    'Drugo',
  ];

  XFile? _selectedImage;
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    _ingredientControllers.add(TextEditingController());
    _instructionControllers.add(TextEditingController());
  }

  @override
  void dispose() {
    _recipeNameController.dispose();
    _descriptionController.dispose();
    _cookingTimeController.dispose();
    _servingsController.dispose();

    for (var controller in _ingredientControllers) {
      controller.dispose();
    }
    for (var controller in _instructionControllers) {
      controller.dispose();
    }
    super.dispose();
  }

  Future<void> _pickImage() async {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Izberi vir slike'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: <Widget>[
              ListTile(
                leading: const Icon(Icons.photo_library),
                title: const Text('Galerija'),
                onTap: () {
                  Navigator.of(context).pop();
                  _getImage(ImageSource.gallery);
                },
              ),
              ListTile(
                leading: const Icon(Icons.camera_alt),
                title: const Text('Kamera'),
                onTap: () {
                  Navigator.of(context).pop();
                  _getImage(ImageSource.camera);
                },
              ),
              // Option to remove selected image
              if (_selectedImage != null)
                ListTile(
                  leading: const Icon(Icons.delete_forever, color: Colors.red),
                  title: const Text('Odstrani sliko', style: TextStyle(color: Colors.red)),
                  onTap: () {
                    setState(() {
                      _selectedImage = null;
                    });
                    Navigator.of(context).pop();
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text('Slika odstranjena.')),
                    );
                  },
                ),
            ],
          ),
        );
      },
    );
  }

  Future<void> _getImage(ImageSource source) async {
    final ImagePicker picker = ImagePicker();
    final XFile? image = await picker.pickImage(source: source);

    if (image != null) {
      setState(() {
        _selectedImage = image;
      });
      print('Image selected: ${image.path}');
    }
  }

  // --- Supabase Image Upload ---
  Future<String?> _uploadImageToSupabaseStorage(XFile imageFile) async {
    try {
      final String fileName =
          '${supabase.auth.currentUser!.id}/${DateTime.now().millisecondsSinceEpoch}.jpg';

      await supabase.storage
          .from('recipe-images')
          .upload(
            fileName,
            File(imageFile.path),
            fileOptions: const FileOptions(cacheControl: '3600', upsert: false),
          );

      final String imageUrl =
          supabase.storage.from('recipe-images').getPublicUrl(fileName);

      return imageUrl;
    } on StorageException catch (e) {
      print('Supabase Storage Error: ${e.message}');
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              'Napaka pri nalaganju slike: ${e.message}',
            ),
          ),
        );
      }
      return null;
    } catch (e) {
      print('General Image Upload Error: $e');
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text(
              'Nepričakovana napaka pri nalaganju slike.',
            ),
          ),
        );
      }
      return null;
    }
  }

  // --- Dynamic Field Management for Ingredients and Instructions ---
  void _addIngredientField() {
    setState(() {
      _ingredientControllers.add(TextEditingController());
    });
  }

  void _removeIngredientField(int index) {
    setState(() {
      if (_ingredientControllers.length > 1) {
        _ingredientControllers[index].dispose();
        _ingredientControllers.removeAt(index);
      } else {
        _ingredientControllers[index].clear();
      }
    });
  }

  void _addInstructionField() {
    setState(() {
      _instructionControllers.add(TextEditingController());
    });
  }

  void _removeInstructionField(int index) {
    setState(() {
      if (_instructionControllers.length > 1) {
        _instructionControllers[index].dispose();
        _instructionControllers.removeAt(index);
      } else {
        _instructionControllers[index].clear();
      }
    });
  }

  // --- Add Recipe Logic ---
  Future<void> _addRecipe() async {
    setState(() {
      _isLoading = true;
    });

    final recipeName = _recipeNameController.text.trim();
    final description = _descriptionController.text.trim();

    final ingredientsList = _ingredientControllers
        .map((controller) => controller.text.trim())
        .where((text) => text.isNotEmpty)
        .toList();

    final instructionsList = _instructionControllers
        .map((controller) => controller.text.trim())
        .where((text) => text.isNotEmpty)
        .toList();

    final cookingTime = _cookingTimeController.text.trim();
    final servings = _servingsController.text.trim();
    final category = _selectedCategory;
    final userId = supabase.auth.currentUser?.id;

    // --- VALIDATION ---
    if (recipeName.isEmpty ||
        description.isEmpty ||
        ingredientsList.isEmpty ||
        instructionsList.isEmpty ||
        cookingTime.isEmpty ||
        servings.isEmpty ||
        category == null) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text(
                'Prosim izpolnite vsa obvezna polja (ime, opis, sestavine, navodila, čas, porcije, kategorija).'),
          ),
        );
      }
      setState(() {
        _isLoading = false;
      });
      return;
    }

    if (userId == null) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text(
              'Uporabnik ni prijavljen. Prosim prijavite se.',
            ),
          ),
        );
      }
      setState(() {
        _isLoading = false;
      });
      return;
    }

    String? imageUrl;

    // --- CONDITIONAL IMAGE UPLOAD & PREPARATION OF DATA MAP ---
    if (_selectedImage != null) {
      try {
        imageUrl = await _uploadImageToSupabaseStorage(_selectedImage!);
        if (imageUrl == null) {
          // If image upload failed, stop the process
          setState(() {
            _isLoading = false;
          });
          return;
        }
      } catch (e) {
        print('Error during image upload: $e');
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Napaka pri nalaganju slike.'),
            ),
          );
        }
        setState(() {
          _isLoading = false;
        });
        return;
      }
    }

    // Prepare the data map for insertion
    final Map<String, dynamic> recipeData = {
      'name': recipeName,
      'description': description,
      'ingredients': ingredientsList,
      'instructions': instructionsList,
      'cooking_time': cookingTime,
      'servings': servings,
      'category': category,
      'user_id': userId,
      'created_at': DateTime.now().toIso8601String(),
    };

    // ONLY ADD 'image_url' to the map if an image was selected and uploaded successfully
    if (imageUrl != null) {
      recipeData['image_url'] = imageUrl;
    }
    // If imageUrl is null, 'image_url' key is completely omitted from the map,
    // which will trigger Supabase to use the column's DEFAULT value.

    // Save recipe to Supabase Database
    try {
      await supabase.from('recipes').insert(recipeData);

      print('Submitting Recipe:');
      print('   Name: $recipeName');
      print('   Description: $description');
      print('   Ingredients: $ingredientsList');
      print('   Instructions: $instructionsList');
      print('   Cooking Time: $cookingTime');
      print('   Servings: $servings');
      print('   Category: $category');
      print('   Image URL: ${imageUrl ?? 'No image selected, using default if set in DB'}'); // Clarified print message
      print('   User ID: $userId');

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Recept uspešno dodan!'),
          ),
        );
      }

      // Clear all fields after successful submission
      _recipeNameController.clear();
      _descriptionController.clear();
      _cookingTimeController.clear();
      _servingsController.clear();

      for (var controller in _ingredientControllers) {
        controller.dispose();
      }
      _ingredientControllers.clear();
      _ingredientControllers.add(TextEditingController());

      for (var controller in _instructionControllers) {
        controller.dispose();
      }
      _instructionControllers.clear();
      _instructionControllers.add(TextEditingController());

      setState(() {
        _selectedCategory = null;
        _selectedImage = null; // Clear selected image
      });
    } on PostgrestException catch (e) {
      print('Supabase Database Error: ${e.message}');
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              'Napaka pri shranjevanju recepta: ${e.message}',
            ),
          ),
        );
      }
    } catch (e) {
      print('General Recipe Save Error: $e');
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text(
              'Nepričakovana napaka pri shranjevanju recepta.',
            ),
          ),
        );
      }
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  // --- Reusable Input Field Widget ---
  Widget _buildInputField({
    required TextEditingController controller,
    required String hintText,
    TextInputType keyboardType = TextInputType.text,
    int? maxLines = 1,
    int? minLines = 1,
  }) {
    return Container(
      decoration: BoxDecoration(
        color: AppColors.paleGray,
        borderRadius: BorderRadius.circular(10),
      ),
      child: TextField(
        controller: controller,
        keyboardType: keyboardType,
        maxLines: maxLines,
        minLines: minLines,
        decoration: InputDecoration(
          hintText: hintText,
          hintStyle: TextStyle(
            color: AppColors.dimGray,
          ),
          contentPadding: const EdgeInsets.symmetric(
            horizontal: 20,
            vertical: 15,
          ),
          border: InputBorder.none,
        ),
        style: TextStyle(color: AppColors.charcoal),
      ),
    );
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
            icon: const Icon(Icons.person),
            onPressed: () {
              print('Profile icon pressed');
              // Navigate to profile screen or show user info
            },
          ),
        ],
        elevation: 0,
        backgroundColor: Colors.transparent,
        foregroundColor: AppColors.charcoal,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Ustvari recept',
              style: TextStyle(
                fontSize: 30,
                fontWeight: FontWeight.bold,
                color: AppColors.charcoal,
              ),
            ),
            const SizedBox(height: 30),

            _buildInputField(
              controller: _recipeNameController,
              hintText: 'Ime recepta',
              keyboardType: TextInputType.text,
            ),
            const SizedBox(height: 20),

            _buildInputField(
              controller: _descriptionController,
              hintText: 'Kratek opis recepta',
              keyboardType: TextInputType.multiline,
              maxLines: null,
              minLines: 3,
            ),
            const SizedBox(height: 20),

            // --- Dynamic Ingredients Input ---
            Text(
              'Sestavine',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: AppColors.charcoal,
              ),
            ),
            const SizedBox(height: 10),
            Column(
              children: _ingredientControllers.asMap().entries.map((entry) {
                int idx = entry.key;
                TextEditingController controller = entry.value;
                return Padding(
                  padding: const EdgeInsets.only(bottom: 10.0),
                  child: Row(
                    children: [
                      Expanded(
                        child: _buildInputField(
                          controller: controller,
                          hintText: 'Sestavina ${idx + 1}',
                          keyboardType: TextInputType.text,
                        ),
                      ),
                      if (_ingredientControllers.length > 1 || controller.text.isNotEmpty) // Show remove button if more than one field or if the current field has text
                        IconButton(
                          icon: Icon(Icons.remove_circle_outline,
                              color: AppColors.tomatoRed),
                          onPressed: () => _removeIngredientField(idx),
                        ),
                    ],
                  ),
                );
              }).toList(),
            ),
            Align(
              alignment: Alignment.centerRight,
              child: TextButton.icon(
                onPressed: _addIngredientField,
                icon: Icon(Icons.add, color: AppColors.leafGreen),
                label: Text('Dodaj sestavino',
                    style: TextStyle(color: AppColors.leafGreen)),
              ),
            ),
            const SizedBox(height: 20),

            // --- Dynamic Instructions Input ---
            Text(
              'Navodila za pripravo',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: AppColors.charcoal,
              ),
            ),
            const SizedBox(height: 10),
            Column(
              children: _instructionControllers.asMap().entries.map((entry) {
                int idx = entry.key;
                TextEditingController controller = entry.value;
                return Padding(
                  padding: const EdgeInsets.only(bottom: 10.0),
                  child: Row(
                    children: [
                      Expanded(
                        child: _buildInputField(
                          controller: controller,
                          hintText: 'Korak ${idx + 1}',
                          keyboardType: TextInputType.multiline,
                          maxLines: null,
                          minLines: 1,
                        ),
                      ),
                      if (_instructionControllers.length > 1 || controller.text.isNotEmpty) // Same logic for showing remove button
                        IconButton(
                          icon: Icon(Icons.remove_circle_outline,
                              color: AppColors.tomatoRed),
                          onPressed: () => _removeInstructionField(idx),
                        ),
                    ],
                  ),
                );
              }).toList(),
            ),
            Align(
              alignment: Alignment.centerRight,
              child: TextButton.icon(
                onPressed: _addInstructionField,
                icon: Icon(Icons.add, color: AppColors.leafGreen),
                label: Text('Dodaj korak',
                    style: TextStyle(color: AppColors.leafGreen)),
              ),
            ),
            const SizedBox(height: 20),

            // --- Cooking Time & Servings ---
            Row(
              children: [
                Expanded(
                  child: _buildInputField(
                    controller: _cookingTimeController,
                    hintText: 'Čas kuhanja (npr. 30 minut)',
                    keyboardType: TextInputType.text,
                    maxLines: 1,
                  ),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: _buildInputField(
                    controller: _servingsController,
                    hintText: 'Št. porcij (npr. 4 osebe)',
                    keyboardType: TextInputType.text,
                    maxLines: 1,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 20),

            // --- Category Dropdown & Image Upload Button ---
            Row(
              children: [
                Expanded(
                  flex: 3,
                  child: Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 12,
                      vertical: 4,
                    ),
                    decoration: BoxDecoration(
                      color: AppColors.paleGray,
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: DropdownButtonHideUnderline(
                      child: DropdownButton<String>(
                        value: _selectedCategory,
                        hint: Text(
                          'Kategorija',
                          style: TextStyle(color: AppColors.dimGray),
                        ),
                        icon: Icon(
                          Icons.keyboard_arrow_down,
                          color: AppColors.dimGray,
                        ),
                        isExpanded: true,
                        style: TextStyle(
                          color: AppColors.charcoal,
                          fontSize: 16,
                        ),
                        onChanged: (String? newValue) {
                          setState(() {
                            _selectedCategory = newValue;
                          });
                        },
                        items: _categories.map<DropdownMenuItem<String>>(
                          (
                            String value,
                          ) {
                            return DropdownMenuItem<String>(
                              value: value,
                              child: Text(value),
                            );
                          },
                        ).toList(),
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 10),
                Expanded(
                  flex: 2,
                  child: ElevatedButton.icon(
                    onPressed: _pickImage,
                    icon: Icon(
                      Icons.upload_file,
                      color: AppColors.charcoal,
                    ),
                    label: Text(
                      _selectedImage != null
                          ? 'Slika izbrana!'
                          : 'Dodaj sliko (neobvezno)',
                      style: TextStyle(color: AppColors.charcoal, fontSize: _selectedImage != null ? 12 : 14),
                      overflow: TextOverflow.ellipsis,
                    ),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.paleGray,
                      foregroundColor: AppColors.charcoal,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10),
                      ),
                      padding: const EdgeInsets.symmetric(vertical: 16),
                    ),
                  ),
                ),
              ],
            ),
            // Display selected image if it exists
            if (_selectedImage != null)
              Padding(
                padding: const EdgeInsets.only(top: 10.0),
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(10),
                  child: Image.file(
                    File(
                      _selectedImage!.path,
                    ),
                    height: 100,
                    width: 100,
                    fit: BoxFit.cover,
                  ),
                ),
              ),
            const SizedBox(height: 30),

            // --- Add Recipe Button ---
            ElevatedButton(
              onPressed: _isLoading ? null : _addRecipe,
              style: ElevatedButton.styleFrom(
                minimumSize: const Size(
                  double.infinity,
                  50,
                ),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10),
                ),
              ),
              child: _isLoading
                  ? const CircularProgressIndicator(
                      color: Colors.white,
                    )
                  : const Text(
                      'Dodaj recept',
                      style: TextStyle(
                        color: AppColors.white,
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
            ),
          ],
        ),
      ),
    );
  }
}