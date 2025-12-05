import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'dart:io';
import 'package:dish_dash/colors/app_colors.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:dish_dash/helpers/toast_manager.dart';

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

  String? _selectedCuisine;
  final List<String> _cuisines = [
    'Italijanska',
    'Azijska',
    'Indijska',
    'Francoska',
    'Mehiška',
    'Sredozemska',
    'Ameriška',
    'Bližnjevzhodna',
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
          key: const Key('imageSourceDialog'), // Key for the dialog
          title: const Text('Izberi vir slike'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: <Widget>[
              ListTile(
                key: const Key('galleryListTile'), // Key for Gallery option
                leading: const Icon(Icons.photo_library),
                title: const Text('Galerija'),
                onTap: () {
                  Navigator.of(context).pop();
                  _getImage(ImageSource.gallery);
                },
              ),
              ListTile(
                key: const Key('cameraListTile'), // Key for Camera option
                leading: const Icon(Icons.camera_alt),
                title: const Text('Kamera'),
                onTap: () {
                  Navigator.of(context).pop();
                  _getImage(ImageSource.camera);
                },
              ),
              if (_selectedImage != null)
                ListTile(
                  key: const Key(
                    'removeImageTile',
                  ), // Key for Remove Image option
                  leading: const Icon(Icons.delete_forever, color: Colors.red),
                  title: const Text(
                    'Odstrani sliko',
                    style: TextStyle(color: Colors.red),
                  ),
                  onTap: () {
                    setState(() {
                      _selectedImage = null;
                    });
                    Navigator.of(context).pop();
                    ToastManager.showInfoToast(context, 'Slika odstranjena.');
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

      final String imageUrl = supabase.storage
          .from('recipe-images')
          .getPublicUrl(fileName);

      return imageUrl;
    } on StorageException catch (e) {
      print('Supabase Storage Error: ${e.message}');
      if (mounted) {
        ToastManager.showErrorToast(
          context,
          'Napaka pri nalaganju slike: ${e.message}',
        );
      }
      return null;
    } catch (e) {
      print('General Image Upload Error: $e');
      if (mounted) {
        ToastManager.showErrorToast(
          context,
          'Nepričakovana napaka pri nalaganju slike.',
        );
      }
      return null;
    }
  }

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

  Future<void> _addRecipe() async {
    setState(() {
      _isLoading = true;
    });

    final recipeName = _recipeNameController.text.trim();
    final description = _descriptionController.text.trim();

    final ingredientsList =
        _ingredientControllers
            .map((controller) => controller.text.trim())
            .where((text) => text.isNotEmpty)
            .toList();

    final instructionsList =
        _instructionControllers
            .map((controller) => controller.text.trim())
            .where((text) => text.isNotEmpty)
            .toList();

    final cookingTime = _cookingTimeController.text.trim();
    final servings = _servingsController.text.trim();
    final category = _selectedCategory;
    final userId = supabase.auth.currentUser?.id;

    if (recipeName.isEmpty ||
        description.isEmpty ||
        ingredientsList.isEmpty ||
        instructionsList.isEmpty ||
        cookingTime.isEmpty ||
        servings.isEmpty ||
        category == null ||
        _selectedCuisine == null) {
      if (mounted) {
        ToastManager.showErrorToast(
          context,
          'Prosim izpolnite vsa obvezna polja (ime, opis, sestavine, navodila, čas, porcije, kategorija, kuhinja).',
        );
      }
      setState(() {
        _isLoading = false;
      });
      return;
    }

    if (userId == null) {
      if (mounted) {
        ToastManager.showErrorToast(
          context,
          'Uporabnik ni prijavljen. Prosim prijavite se.',
        );
      }
      setState(() {
        _isLoading = false;
      });
      return;
    }

    String? imageUrl;

    if (_selectedImage != null) {
      try {
        imageUrl = await _uploadImageToSupabaseStorage(_selectedImage!);
        if (imageUrl == null) {
          setState(() {
            _isLoading = false;
          });
          return;
        }
      } catch (e) {
        print('Error during image upload: $e');
        if (mounted) {
          ToastManager.showErrorToast(context, 'Napaka pri nalaganju slike.');
        }
        setState(() {
          _isLoading = false;
        });
        return;
      }
    }

    final Map<String, dynamic> recipeData = {
      'name': recipeName,
      'description': description,
      'ingredients': ingredientsList,
      'instructions': instructionsList,
      'cooking_time': cookingTime,
      'servings': servings,
      'category': category,
      'cuisine': _selectedCuisine,
      'user_id': userId,
      'created_at': DateTime.now().toIso8601String(),
    };

    if (imageUrl != null) {
      recipeData['image_url'] = imageUrl;
    }

    try {
      await supabase.from('recipes').insert(recipeData);

      print('Submitting Recipe:');
      print('    Name: $recipeName');
      print('    Description: $description');
      print('    Ingredients: $ingredientsList');
      print('    Instructions: $instructionsList');
      print('    Cooking Time: $cookingTime');
      print('    Servings: $servings');
      print('    Category: $category');
      print(
        '    Image URL: ${imageUrl ?? 'No image selected, using default if set in DB'}',
      );
      print('    User ID: $userId');

      if (mounted) {
        ToastManager.showSuccessToast(context, 'Recept uspešno dodan!');
      }

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
        _selectedCuisine = null;
        _selectedImage = null;
      });

      if (mounted) {
        Navigator.pop(context, true);
      }
    } on PostgrestException catch (e) {
      print('Supabase Database Error: ${e.message}');
      if (mounted) {
        ToastManager.showErrorToast(
          context,
          'Napaka pri shranjevanju recepta: ${e.message}',
        );
      }
    } catch (e) {
      print('General Recipe Save Error: $e');
      if (mounted) {
        ToastManager.showErrorToast(
          context,
          'Nepričakovana napaka pri shranjevanju recepta.',
        );
      }
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  Widget _buildInputField({
    required TextEditingController controller,
    required String hintText,
    TextInputType keyboardType = TextInputType.text,
    int? maxLines = 1,
    int? minLines = 1,
    required Key key, // Added required Key parameter
  }) {
    return Container(
      decoration: BoxDecoration(
        color: AppColors.paleGray,
        borderRadius: BorderRadius.circular(10),
      ),
      child: TextField(
        key: key, // Using the passed key
        controller: controller,
        keyboardType: keyboardType,
        maxLines: maxLines,
        minLines: minLines,
        decoration: InputDecoration(
          hintText: hintText,
          hintStyle: TextStyle(color: AppColors.dimGray),
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
          key: const Key('backButton'), // Key for back button
          icon: const Icon(Icons.arrow_back),
          onPressed: () {
            Navigator.pop(context);
          },
        ),
        title: Center(child: Image.asset('assets/logo.png', height: 80)),
        actions: [
          IconButton(
            key: const Key('profileButton'), // Key for profile icon
            icon: const Icon(Icons.person),
            onPressed: () {
              print('Profile icon pressed');
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
              key: const Key('recipeNameInput'), // Key added
              controller: _recipeNameController,
              hintText: 'Ime recepta',
              keyboardType: TextInputType.text,
            ),
            const SizedBox(height: 20),
            _buildInputField(
              key: const Key('descriptionInput'), // Key added
              controller: _descriptionController,
              hintText: 'Kratek opis recepta',
              keyboardType: TextInputType.multiline,
              maxLines: null,
              minLines: 3,
            ),
            const SizedBox(height: 20),
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
              key: const Key('ingredientsList'), // Key for the ingredients list
              children:
                  _ingredientControllers.asMap().entries.map((entry) {
                    int idx = entry.key;
                    TextEditingController controller = entry.value;
                    return Padding(
                      padding: const EdgeInsets.only(bottom: 10.0),
                      child: Row(
                        key: Key(
                          'ingredientRow_$idx',
                        ), // Key for each ingredient row
                        children: [
                          Expanded(
                            child: _buildInputField(
                              key: Key(
                                'ingredientInput_$idx',
                              ), // Key added for ingredient input
                              controller: controller,
                              hintText: 'Sestavina ${idx + 1}',
                              keyboardType: TextInputType.text,
                            ),
                          ),
                          IconButton(
                            key: Key(
                              'removeIngredientButton_$idx',
                            ), // Key for remove ingredient button
                            icon: Icon(
                              Icons.remove_circle_outline,
                              color: AppColors.tomatoRed,
                            ),
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
                key: const Key(
                  'addIngredientButton',
                ), // Key for add ingredient button
                onPressed: _addIngredientField,
                icon: Icon(Icons.add, color: AppColors.leafGreen),
                label: Text(
                  'Dodaj sestavino',
                  style: TextStyle(color: AppColors.leafGreen),
                ),
              ),
            ),
            const SizedBox(height: 20),
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
              key: const Key(
                'instructionsList',
              ), // Key for the instructions list
              children:
                  _instructionControllers.asMap().entries.map((entry) {
                    int idx = entry.key;
                    TextEditingController controller = entry.value;
                    return Padding(
                      padding: const EdgeInsets.only(bottom: 10.0),
                      child: Row(
                        key: Key(
                          'instructionRow_$idx',
                        ), // Key for each instruction row
                        children: [
                          Expanded(
                            child: _buildInputField(
                              key: Key(
                                'instructionInput_$idx',
                              ), // Key added for instruction input
                              controller: controller,
                              hintText: 'Korak ${idx + 1}',
                              keyboardType: TextInputType.multiline,
                              maxLines: null,
                              minLines: 1,
                            ),
                          ),
                          IconButton(
                            key: Key(
                              'removeInstructionButton_$idx',
                            ), // Key for remove instruction button
                            icon: Icon(
                              Icons.remove_circle_outline,
                              color: AppColors.tomatoRed,
                            ),
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
                key: const Key(
                  'addInstructionButton',
                ), // Key for add instruction button
                onPressed: _addInstructionField,
                icon: Icon(Icons.add, color: AppColors.leafGreen),
                label: Text(
                  'Dodaj korak',
                  style: TextStyle(color: AppColors.leafGreen),
                ),
              ),
            ),
            const SizedBox(height: 20),
            Row(
              children: [
                Expanded(
                  child: _buildInputField(
                    key: const Key('cookingTimeInput'), // Key added
                    controller: _cookingTimeController,
                    hintText: 'Čas kuhanja (npr. 30 minut)',
                    keyboardType: TextInputType.text,
                    maxLines: 1,
                  ),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: _buildInputField(
                    key: const Key('servingsInput'), // Key added
                    controller: _servingsController,
                    hintText: 'Št. porcij (npr. 4 osebe)',
                    keyboardType: TextInputType.text,
                    maxLines: 1,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 20),
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Expanded(
                  flex: 2,
                  child: Column(
                    children: [
                      Container(
                        key: const Key('cuisineDropdownContainer'), // Key added
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
                            key: const Key('cuisineDropdown'), // Key added
                            value: _selectedCuisine,
                            hint: Text(
                              'Kuhinja',
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
                                _selectedCuisine = newValue;
                              });
                            },
                            items:
                                _cuisines.map<DropdownMenuItem<String>>((
                                  String value,
                                ) {
                                  return DropdownMenuItem<String>(
                                    key: Key(
                                      'cuisineItem_$value',
                                    ), // Key added for dropdown items
                                    value: value,
                                    child: Text(value),
                                  );
                                }).toList(),
                          ),
                        ),
                      ),
                      const SizedBox(height: 10),
                      Container(
                        key: const Key(
                          'categoryDropdownContainer',
                        ), // Key added
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
                            key: const Key('categoryDropdown'), // Key added
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
                            items:
                                _categories.map<DropdownMenuItem<String>>((
                                  String value,
                                ) {
                                  return DropdownMenuItem<String>(
                                    key: Key(
                                      'categoryItem_$value',
                                    ), // Key added for dropdown items
                                    value: value,
                                    child: Text(value),
                                  );
                                }).toList(),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(width: 10),
                Expanded(
                  flex: 1,
                  child: ElevatedButton.icon(
                    key: const Key(
                      'imagePickButton',
                    ), // Key changed to a more descriptive name
                    onPressed: _pickImage,
                    icon: Icon(Icons.upload_file, color: AppColors.charcoal),
                    label: Text(
                      _selectedImage != null
                          ? 'Slika izbrana!'
                          : 'Dodaj sliko (neobvezno)',
                      style: TextStyle(
                        color: AppColors.charcoal,
                        fontSize: _selectedImage != null ? 12 : 14,
                      ),
                      overflow: TextOverflow.ellipsis,
                      textAlign: TextAlign.center,
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
            if (_selectedImage != null)
              Padding(
                key: const Key(
                  'selectedImagePreview',
                ), // Key added for image preview
                padding: const EdgeInsets.only(top: 20.0),
                child: Center(
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(10),
                    child: Image.file(
                      File(_selectedImage!.path),
                      height: 150,
                      width: 150,
                      fit: BoxFit.cover,
                    ),
                  ),
                ),
              ),
            const SizedBox(height: 30),
            ElevatedButton(
              key: const Key('saveRecipeButton'), // Key added
              onPressed: _isLoading ? null : _addRecipe,
              style: ElevatedButton.styleFrom(
                minimumSize: const Size(double.infinity, 50),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10),
                ),
              ),
              child:
                  _isLoading
                      ? const CircularProgressIndicator(color: Colors.white)
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
