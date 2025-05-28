// lib/pages/home/home_content_screen.dart
import 'package:dish_dash/pages/profile_page_screen.dart';
import 'package:flutter/material.dart';
import 'package:dish_dash/colors/app_colors.dart'; // Import custom colors

class HomeContentScreen extends StatelessWidget {
  const HomeContentScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        // AppBar will get its styling from ThemeData in main.dart
        leading: null, // No back button on the main tab screen
        automaticallyImplyLeading:
            false, // Prevents Flutter from adding a back button automatically
        title: Center(
          child: Text(
            'DishDash', // Placeholder for logo if image is removed
            style: TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.bold,
              color: AppColors.charcoal, // Or your desired color
            ),
          ),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.person),
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => const ProfilePageScreen(),
                ),
              );
            },
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Large Recipe Card (from your screenshot)
            Card(
              elevation: 4.0,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(15),
              ),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(15),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Image.asset removed here
                    Padding(
                      padding: const EdgeInsets.all(16.0),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Langoustine Plat', // Example text from screenshot
                            style: TextStyle(
                              fontSize: 22,
                              fontWeight: FontWeight.bold,
                              color: AppColors.charcoal,
                            ),
                          ),
                          const SizedBox(height: 8),
                          Row(
                            children: [
                              Icon(
                                Icons.access_time,
                                size: 18,
                                color: AppColors.dimGray,
                              ),
                              const SizedBox(width: 4),
                              Text(
                                '30 min',
                                style: TextStyle(
                                  color: AppColors.dimGray,
                                  fontSize: 14,
                                ),
                              ),
                              const SizedBox(width: 16),
                              Icon(
                                Icons.people,
                                size: 18,
                                color: AppColors.dimGray,
                              ),
                              const SizedBox(width: 4),
                              Text(
                                '2 servings',
                                style: TextStyle(
                                  color: AppColors.dimGray,
                                  fontSize: 14,
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 20),

            // Smaller Recipe Cards
            _buildSmallRecipeCard(
              context,
              // 'assets/recipe_small_placeholder_1.png', // Image path removed
              'Jagodni Sladoled', // Strawberry Ice Cream
              '15 min',
              '4 servings',
            ),
            const SizedBox(height: 15),
            _buildSmallRecipeCard(
              context,
              // 'assets/recipe_small_placeholder_2.png', // Image path removed
              'Špageti Carbonara', // Spaghetti Carbonara
              '15 min',
              '4 servings',
            ),
            // Add more as needed
            const SizedBox(height: 50), // Space for FAB
          ],
        ),
      ),
    );
  }

  Widget _buildSmallRecipeCard(
    BuildContext context,
    // String imagePath, // imagePath parameter removed
    String title,
    String time,
    String servings,
  ) {
    return Card(
      elevation: 2.0,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
      child: InkWell(
        onTap: () {
          // TODO: Navigate to Recipe Detail Screen
          print('Tapped on $title');
        },
        borderRadius: BorderRadius.circular(10), // Match card border radius
        child: Padding(
          padding: const EdgeInsets.all(12.0),
          child: Row(
            children: [
              // ClipRRect for Image.asset removed here
              // const SizedBox(width: 15), // Original SizedBox might be too large without image
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: AppColors.charcoal,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 8),
                    Row(
                      children: [
                        Icon(
                          Icons.access_time,
                          size: 16,
                          color: AppColors.dimGray,
                        ),
                        const SizedBox(width: 4),
                        Text(
                          time,
                          style: TextStyle(
                            color: AppColors.dimGray,
                            fontSize: 13,
                          ),
                        ),
                        const SizedBox(width: 12),
                        Icon(Icons.people, size: 16, color: AppColors.dimGray),
                        const SizedBox(width: 4),
                        Text(
                          servings,
                          style: TextStyle(
                            color: AppColors.dimGray,
                            fontSize: 13,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              Icon(Icons.arrow_forward_ios, size: 18, color: AppColors.dimGray),
            ],
          ),
        ),
      ),
    );
  }
}
