import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'dart:io';

import 'package:dish_dash/colors/app_colors.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:dish_dash/models/recipe.dart'; 

class UpdateRecipeScreen extends StatefulWidget {
  final Recipe recipe; 

  const UpdateRecipeScreen({super.key, required this.recipe});

  @override
  State<UpdateRecipeScreen> createState() => _UpdateRecipeScreenState();
}

class _UpdateRecipeScreenState extends State<UpdateRecipeScreen> {
  final SupabaseClient supabase = Supabase.instance.client;

  late final TextEditingController _recipeNameController;
  late final TextEditingController _descriptionController;
  late final TextEditingController _cookingTimeController;
  late final TextEditingController _servingsController;

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
  String? _currentImageUrl;
  bool _isImageRemoved = false; 

  bool _isLoading = false; 

  @override
  void initState() {
    super.initState();

    _recipeNameController = TextEditingController(text: widget.recipe.name);
    _descriptionController = TextEditingController(text: widget.recipe.description);
    _cookingTimeController = TextEditingController(text: widget.recipe.cookingTime);
    _servingsController = TextEditingController(text: widget.recipe.servings);


    if (widget.recipe.ingredients.isNotEmpty) {
      for (var ingredient in widget.recipe.ingredients) {
        _ingredientControllers.add(TextEditingController(text: ingredient));
      }
    } else {
      _ingredientControllers.add(TextEditingController());
    }

    if (widget.recipe.instructions.isNotEmpty) {
      for (var instruction in widget.recipe.instructions) {
        _instructionControllers.add(TextEditingController(text: instruction));
      }
    } else {
      _instructionControllers.add(TextEditingController());
    }

    _selectedCategory = widget.recipe.category;
    _currentImageUrl = widget.recipe.imageUrl.isNotEmpty ? widget.recipe.imageUrl : null;
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
        
              if (_selectedImage != null || _currentImageUrl != null)
                ListTile(
                  leading: const Icon(Icons.delete_forever, color: Colors.red),
                  title: const Text('Odstrani sliko', style: TextStyle(color: Colors.red)),
                  onTap: () {
                    setState(() {
                      _selectedImage = null; 
                      _currentImageUrl = null;
                      _isImageRemoved = true; 
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
        _isImageRemoved = false; 
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

  Future<void> _updateRecipe() async {
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

    String? finalImageUrl;

    if (_selectedImage != null) {
      try {
        finalImageUrl = await _uploadImageToSupabaseStorage(_selectedImage!);
        if (finalImageUrl == null) {
          setState(() {
            _isLoading = false;
          });
          return; // Image upload failed
        }
      } catch (e) {
        print('Error during new image upload: $e');
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Napaka pri nalaganju nove slike.'),
            ),
          );
        }
        setState(() {
          _isLoading = false;
        });
        return;
      }
    } else if (_isImageRemoved) {
      // Existing image was explicitly removed by the user
      finalImageUrl = null;
    } else {
      // No new image selected and existing image not removed, keep current URL
      finalImageUrl = _currentImageUrl;
    }

    final Map<String, dynamic> recipeData = {
      'name': recipeName,
      'description': description,
      'ingredients': ingredientsList,
      'instructions': instructionsList,
      'cooking_time': cookingTime,
      'servings': servings,
      'category': category,
      'user_id': userId, 
      'image_url': finalImageUrl, 
    };

    try {

      // Perform the update operation using the recipe's ID
      await supabase.from('recipes').update(recipeData).eq('id', widget.recipe.id);

      print('Updating Recipe:');
      print('   ID: ${widget.recipe.id}');
      print('   Name: $recipeName');
      print('   Description: $description');
      print('   Ingredients: $ingredientsList');
      print('   Instructions: $instructionsList');
      print('   Cooking Time: $cookingTime');
      print('   Servings: $servings');
      print('   Category: $category');
      print('   Final Image URL: ${finalImageUrl ?? 'No image'}');
      print('   User ID: $userId');

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Recept uspešno posodobljen!'),
          ),
        );
        Navigator.pop(context);
      }
    } on PostgrestException catch (e) {
      print('Supabase Database Error updating recipe: ${e.message}');
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              'Napaka pri posodabljanju recepta: ${e.message}',
            ),
          ),
        );
      }
    } catch (e) {
      print('General Recipe Update Error: $e');
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text(
              'Nepričakovana napaka pri posodabljanju recepta.',
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
              'Uredi recept',
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
                      if (_ingredientControllers.length > 1 || controller.text.isNotEmpty)
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
                      if (_instructionControllers.length > 1 || controller.text.isNotEmpty)
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
                          (String value) {
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
                          ? 'Nova slika izbrana!'
                          : (_currentImageUrl != null ? 'Slika prisotna' : 'Dodaj sliko (neobvezno)'),
                      style: TextStyle(color: AppColors.charcoal, fontSize: 12),
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

            if (_selectedImage != null)
              Padding(
                padding: const EdgeInsets.only(top: 10.0),
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(10),
                  child: Image.file(
                    File(_selectedImage!.path),
                    height: 100,
                    width: 100,
                    fit: BoxFit.cover,
                  ),
                ),
              )
            else if (_currentImageUrl != null)
              Padding(
                padding: const EdgeInsets.only(top: 10.0),
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(10),
                  child: Image.network(
                    _currentImageUrl!,
                    height: 100,
                    width: 100,
                    fit: BoxFit.cover,
                    errorBuilder: (context, error, stackTrace) {
                      return Container(
                        height: 100,
                        width: 100,
                        color: AppColors.paleGray,
                        child: Icon(Icons.broken_image, color: AppColors.dimGray),
                      );
                    },
                  ),
                ),
              ),
            const SizedBox(height: 30),

            ElevatedButton(
              onPressed: _isLoading ? null : _updateRecipe,
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
                      'Posodobi recept', 
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