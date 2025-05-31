import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'dart:io';
import 'package:dish_dash/colors/app_colors.dart'; // Assuming this path is correct
import 'package:supabase_flutter/supabase_flutter.dart'; // Import Supabase

class CreateRecipeScreen extends StatefulWidget {
  const CreateRecipeScreen({super.key});

  @override
  State<CreateRecipeScreen> createState() => _CreateRecipeScreenState();
}

class _CreateRecipeScreenState extends State<CreateRecipeScreen> {
  // Supabase client instance
  final SupabaseClient supabase = Supabase.instance.client;

  // Text editing controllers for your input fields
  final TextEditingController _recipeNameController = TextEditingController();
  final TextEditingController _descriptionController = TextEditingController();
  final TextEditingController _ingredientsController = TextEditingController();

  // For the dropdown category
  String? _selectedCategory;
  final List<String> _categories = [
    'Zajtrk', // Breakfast
    'Kosilo', // Lunch
    'Večerja', // Dinner
    'Sladica', // Dessert
    'Prigrizek', // Snack
    'Drugo', // Other
  ];

  // Variable to store the selected image path (for display/upload later)
  XFile? _selectedImage;

  // State to manage loading indicator during submission
  bool _isLoading = false;

  @override
  void dispose() {
    _recipeNameController.dispose();
    _descriptionController.dispose();
    _ingredientsController.dispose();
    super.dispose();
  }

  // Function to handle image picking
  Future<void> _pickImage() async {
    final ImagePicker picker = ImagePicker();
    final XFile? image = await picker.pickImage(
      source: ImageSource.gallery,
    ); // You can also use ImageSource.camera

    if (image != null) {
      setState(() {
        _selectedImage = image;
      });
      print('Image selected: ${image.path}');
    }
  }

  // Function to upload image to Supabase Storage
  Future<String?> _uploadImageToSupabaseStorage(XFile imageFile) async {
    try {
      // Generate a unique file name for the image
      final String fileName =
          '${supabase.auth.currentUser!.id}/${DateTime.now().millisecondsSinceEpoch}.jpg';

      // Upload the image to the 'recipe-images' bucket
      // Ensure you have a bucket named 'recipe-images' in your Supabase Storage
      final String publicUrl = await supabase.storage
          .from('recipe-images') // Replace with your bucket name
          .upload(
            fileName,
            File(imageFile.path),
            fileOptions: const FileOptions(cacheControl: '3600', upsert: false),
          );

      // Get the public URL of the uploaded image
      final String imageUrl = supabase.storage
          .from('recipe-images')
          .getPublicUrl(fileName);

      return imageUrl;
    } on StorageException catch (e) {
      print('Supabase Storage Error: ${e.message}');
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            'Napaka pri nalaganju slike: ${e.message}',
          ), // Error uploading image
        ),
      );
      return null;
    } catch (e) {
      print('General Image Upload Error: $e');
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text(
            'Nepričakovana napaka pri nalaganju slike.',
          ), // Unexpected error uploading image
        ),
      );
      return null;
    }
  }

  // Function to handle adding the recipe
  Future<void> _addRecipe() async {
    setState(() {
      _isLoading = true; // Show loading indicator
    });

    final recipeName = _recipeNameController.text.trim();
    final description = _descriptionController.text.trim();
    final ingredients = _ingredientsController.text.trim();
    final category = _selectedCategory;
    final userId = supabase.auth.currentUser?.id; // Get current user ID

    // Basic validation
    if (recipeName.isEmpty ||
        description.isEmpty ||
        ingredients.isEmpty ||
        category == null ||
        _selectedImage == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Prosim izpolnite vsa polja in izberite sliko.'),
        ), // Please fill all fields and select an image.
      );
      setState(() {
        _isLoading = false;
      });
      return;
    }

    if (userId == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text(
            'Uporabnik ni prijavljen. Prosim prijavite se.',
          ), // User not logged in. Please log in.
        ),
      );
      setState(() {
        _isLoading = false;
      });
      return;
    }

    String? imageUrl;
    // 1. Upload _selectedImage to Supabase Storage
    try {
      imageUrl = await _uploadImageToSupabaseStorage(_selectedImage!);
      if (imageUrl == null) {
        // Image upload failed, return early
        setState(() {
          _isLoading = false;
        });
        return;
      }
    } catch (e) {
      print('Error during image upload: $e');
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Napaka pri nalaganju slike.'), // Error uploading image
        ),
      );
      setState(() {
        _isLoading = false;
      });
      return;
    }

    // 2. Save recipe data to Supabase Database
    try {
      await supabase.from('recipes').insert({
        // Replace 'recipes' with your table name
        'name': recipeName,
        'description': description,
        'ingredients': ingredients,
        'category': category,
        'image_url': imageUrl,
        'user_id': userId, // Associate recipe with the current user
        'created_at': DateTime.now().toIso8601String(), // Add a timestamp
      });

      print('Submitting Recipe:');
      print('  Name: $recipeName');
      print('  Description: $description');
      print('  Ingredients: $ingredients');
      print('  Category: $category');
      print('  Image URL: $imageUrl');
      print('  User ID: $userId');

      // Show a success message
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Recept uspešno dodan!'),
        ), // Recipe successfully added!
      );

      // Clear fields after successful submission
      _recipeNameController.clear();
      _descriptionController.clear();
      _ingredientsController.clear();
      setState(() {
        _selectedCategory = null;
        _selectedImage = null;
      });

      // Navigate back to previous screen or home feed after a short delay
      // Future.delayed(const Duration(seconds: 2), () {
      //   Navigator.pop(context);
      // });
    } on PostgrestException catch (e) {
      print('Supabase Database Error: ${e.message}');
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            'Napaka pri shranjevanju recepta: ${e.message}',
          ), // Error saving recipe
        ),
      );
    } catch (e) {
      print('General Recipe Save Error: $e');
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text(
            'Nepričakovana napaka pri shranjevanju recepta.',
          ), // Unexpected error saving recipe
        ),
      );
    } finally {
      setState(() {
        _isLoading = false; // Hide loading indicator
      });
    }
  }

  // Helper method to build consistent input fields
  Widget _buildInputField({
    required TextEditingController controller,
    required String hintText,
    TextInputType keyboardType = TextInputType.text,
    int? maxLines = 1,
    int? minLines = 1,
  }) {
    return Container(
      decoration: BoxDecoration(
        color: AppColors.paleGray, // Using your defined pale gray
        borderRadius: BorderRadius.circular(10), // Rounded corners
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
          ), // Using dim gray for hint text
          contentPadding: const EdgeInsets.symmetric(
            horizontal: 20,
            vertical: 15,
          ),
          border: InputBorder.none, // Removes default underline
        ),
        style: TextStyle(color: AppColors.charcoal), // Text input color
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      // --- AppBar ---
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () {
            Navigator.pop(context); // Go back to the previous screen
          },
        ),
        title: Center(child: Image.asset('assets/logo.png', height: 80)),
        actions: [
          IconButton(
            icon: const Icon(Icons.person),
            onPressed: () {
              // TODO: Navigate to profile screen
              print('Profile icon pressed');
            },
          ),
        ],
        elevation: 0, // No shadow under app bar
        backgroundColor: Colors.transparent, // Transparent background
        foregroundColor: AppColors.charcoal, // Color for icons in app bar
      ),
      // --- Body Content ---
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(
          20.0,
        ), // Padding around the entire content
        child: Column(
          crossAxisAlignment:
              CrossAxisAlignment.start, // Align text to the start
          children: [
            Text(
              'Ustvari recept', // "Create recipe" in Slovenian
              style: TextStyle(
                fontSize: 30,
                fontWeight: FontWeight.bold,
                color: AppColors.charcoal, // Title color
              ),
            ),
            const SizedBox(height: 30), // Space after title
            // Recipe Name Input Field
            _buildInputField(
              controller: _recipeNameController,
              hintText:
                  'Ime recepta', // "Recipe Name" in Slovenian (more descriptive)
              keyboardType: TextInputType.text,
            ),
            const SizedBox(height: 20),

            // Description/Instructions Input Field (from screenshot "Naziv" again, assuming it's for description)
            _buildInputField(
              controller: _descriptionController,
              hintText:
                  'Opis recepta / Navodila', // "Recipe description / Instructions" in Slovenian
              keyboardType: TextInputType.multiline,
              maxLines: null, // Allows unlimited lines
              minLines: 5, // Minimum 5 lines height
            ),
            const SizedBox(height: 20),

            // Ingredients Input Field (assuming this is the third large "Naziv" field)
            _buildInputField(
              controller: _ingredientsController,
              hintText:
                  'Sestavine (vsako v svojo vrstico)', // "Ingredients (each on its own line)"
              keyboardType: TextInputType.multiline,
              maxLines: null,
              minLines: 4, // Adjust min lines for ingredients
            ),
            const SizedBox(height: 20),

            // Category Dropdown and Image Upload Button Row
            Row(
              children: [
                Expanded(
                  flex: 3, // Category takes more space
                  child: Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 12,
                      vertical: 4,
                    ),
                    decoration: BoxDecoration(
                      color: AppColors.paleGray, // Light grey background
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: DropdownButtonHideUnderline(
                      // Hides the default underline
                      child: DropdownButton<String>(
                        value: _selectedCategory,
                        hint: Text(
                          'Kategorija',
                          style: TextStyle(color: AppColors.dimGray),
                        ), // "Category"
                        icon: Icon(
                          Icons.keyboard_arrow_down,
                          color: AppColors.dimGray,
                        ),
                        isExpanded: true,
                        style: TextStyle(
                          color: AppColors.charcoal,
                          fontSize: 16,
                        ), // Text color for selected item
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
                                value: value,
                                child: Text(value),
                              );
                            }).toList(),
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 10), // Space between dropdown and button
                Expanded(
                  flex: 2, // Image button takes less space
                  child: ElevatedButton.icon(
                    onPressed: _pickImage,
                    icon: Icon(
                      Icons.upload_file,
                      color: AppColors.charcoal,
                    ), // Upload icon
                    label: Text(
                      _selectedImage != null
                          ? 'Slika izbrana!'
                          : 'Dodaj sliko', // "Image selected!" or "Add image"
                      style: TextStyle(color: AppColors.charcoal),
                    ),
                    style: ElevatedButton.styleFrom(
                      backgroundColor:
                          AppColors.paleGray, // Light grey background
                      foregroundColor:
                          AppColors
                              .charcoal, // Text and icon color (overridden by label/icon color)
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10),
                      ),
                      padding: const EdgeInsets.symmetric(vertical: 16),
                    ),
                  ),
                ),
              ],
            ),
            if (_selectedImage !=
                null) // Show a small preview if an image is selected
              Padding(
                padding: const EdgeInsets.only(top: 10.0),
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(10),
                  child: Image.file(
                    File(
                      _selectedImage!.path,
                    ), // Use dart:io.File to display XFile
                    height: 100,
                    width: 100,
                    fit: BoxFit.cover,
                  ),
                ),
              ),
            const SizedBox(height: 30),

            // "Add Recipe" Button
            ElevatedButton(
              onPressed:
                  _isLoading ? null : _addRecipe, // Disable button when loading
              style: ElevatedButton.styleFrom(
                minimumSize: const Size(
                  double.infinity,
                  50,
                ), // Ensures full width and fixed height
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10),
                ),
              ),
              child:
                  _isLoading
                      ? const CircularProgressIndicator(
                        color: Colors.white,
                      ) // Show loading spinner
                      : const Text(
                        'Dodaj recept',
                        style: TextStyle(
                          color:
                              AppColors
                                  .white, // Keep text color white if that's your design
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
