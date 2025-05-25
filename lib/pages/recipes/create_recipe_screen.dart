import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'dart:io';
import 'package:dish_dash/colors/app_colors.dart';

class CreateRecipeScreen extends StatefulWidget {
  const CreateRecipeScreen({Key? key}) : super(key: key);

  @override
  State<CreateRecipeScreen> createState() => _CreateRecipeScreenState();
}

class _CreateRecipeScreenState extends State<CreateRecipeScreen> {
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
      // Here you might want to display a preview of the image
    }
  }

  // Function to handle adding the recipe
  void _addRecipe() {
    final recipeName = _recipeNameController.text.trim();
    final description = _descriptionController.text.trim();
    final ingredients = _ingredientsController.text.trim();
    final category = _selectedCategory;

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
      return;
    }

    // TODO: Implement actual logic to save the recipe to your backend
    // This will involve:
    // 1. Uploading _selectedImage to Firebase Storage/Supabase Storage
    // 2. Getting the image URL
    // 3. Saving recipe data (name, description, ingredients, category, image URL, user ID) to Firestore/Supabase Database

    print('Submitting Recipe:');
    print('  Name: $recipeName');
    print('  Description: $description');
    print('  Ingredients: $ingredients');
    print('  Category: $category');
    print('  Image Path: ${_selectedImage?.path}');

    // Show a success message and/or navigate back
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Recept uspešno dodan!'),
      ), // Recipe successfully added!
    );

    // Clear fields after successful submission (optional)
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
        title: Center(
          child: Image.asset(
            'assets/logo.png', // Replace with your actual logo asset path
            height: 40, // Adjust height as needed based on your logo size
          ),
        ),
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
              minLines: 8, // Adjust min lines for ingredients
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
            Container(
              width: double.infinity, // Full width button
              height: 50, // Fixed height for the button
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(10),
                gradient: const LinearGradient(
                  // Gradient background for the button
                  colors: [
                    AppColors.lime, // Lighter green
                    AppColors.leafGreen, // Darker green
                  ],
                  begin: Alignment.centerLeft,
                  end: Alignment.centerRight,
                ),
              ),
              child: ElevatedButton(
                onPressed: _addRecipe,
                style: ElevatedButton.styleFrom(
                  backgroundColor:
                      Colors
                          .transparent, // Make button transparent to show gradient
                  shadowColor: Colors.transparent, // No shadow
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10),
                  ),
                  padding: EdgeInsets.zero, // Remove default padding
                ),
                child: const Text(
                  'Dodaj recept', // "Add recipe" in Slovenian
                  style: TextStyle(
                    color: AppColors.white,
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
      // --- Bottom Navigation Bar ---
      bottomNavigationBar: BottomNavigationBar(
        currentIndex:
            1, // You'll need to set this dynamically based on the current screen
        onTap: (index) {
          // TODO: Implement navigation logic for bottom bar items
          // This should navigate to your main screens (Home, Explore, Recipes List)
          // Use Navigator.pushReplacementNamed to replace the current screen,
          // or Navigator.pop() and then Navigator.pushNamed if you want to pop
          // this screen off the stack first.
          print('Bottom nav item tapped: $index');
          if (index == 0) {
            // Navigator.pushReplacementNamed(context, '/home');
          } else if (index == 1) {
            // This might be the 'Add Recipe' screen itself, or 'Explore'
            // If it's this screen, you don't need to navigate.
            // If it's 'Explore', then:
            // Navigator.pushReplacementNamed(context, '/explore');
          } else if (index == 2) {
            // Navigator.pushReplacementNamed(context, '/recipes_list');
          }
        },
        selectedItemColor: AppColors.leafGreen, // Your primary green color
        unselectedItemColor: AppColors.dimGray,
        backgroundColor:
            AppColors.white, // Assuming a white background for the nav bar
        items: const [
          BottomNavigationBarItem(icon: Icon(Icons.home), label: 'Home'),
          BottomNavigationBarItem(
            icon: Icon(
              Icons.search,
            ), // Changed from Restaurant to Search based on typical social media pattern
            label: 'Explore',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.menu_book), // More recipe-specific icon
            label: 'Moji recepti', // My Recipes
          ),
        ],
      ),
    );
  }
}
