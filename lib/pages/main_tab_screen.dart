// lib/pages/main_tab_screen.dart
import 'package:flutter/material.dart';
import 'package:dish_dash/colors/app_colors.dart'; // Import your custom colors

// Import the content screens for each tab
import 'package:dish_dash/pages/explore/home_content_screen.dart';
import 'package:dish_dash/pages/explore/explore_content_screen.dart';
import 'package:dish_dash/pages/recipes/recipes_content_screen.dart';
import 'package:dish_dash/pages/recipes/create_recipe_screen.dart'; // For the FAB

class MainTabScreen extends StatefulWidget {
  const MainTabScreen({Key? key}) : super(key: key);

  @override
  State<MainTabScreen> createState() => _MainTabScreenState();
}

class _MainTabScreenState extends State<MainTabScreen> {
  int _selectedIndex = 0; // Index for the selected tab

  static const List<Widget> _widgetOptions = <Widget>[
    HomeContentScreen(),
    ExploreContentScreen(),
    RecipesContentScreen(),
  ];

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: _widgetOptions.elementAt(_selectedIndex),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => const CreateRecipeScreen()),
          );
        },
        backgroundColor: AppColors.leafGreen,
        child: const Icon(Icons.add, color: AppColors.white),
        shape: const CircleBorder(),
      ),
      // MODIFIED: FAB location changed to endDocked
      floatingActionButtonLocation: FloatingActionButtonLocation.endDocked,
      bottomNavigationBar: BottomAppBar(
        color: AppColors.white,
        surfaceTintColor: AppColors.white,
        shadowColor: AppColors.paleGray,
        elevation: 5.0,
        shape:
            const CircularNotchedRectangle(), // Notch will now be at the end for the FAB
        notchMargin: 8.0, // Space between FAB and bar
        child: Row(
          // MODIFIED: mainAxisAlignment can be kept as spaceAround or changed
          // to spaceEvenly for potentially better visual balance with 3 items.
          // Let's try spaceAround first as it's common.
          mainAxisAlignment: MainAxisAlignment.spaceAround,
          children: <Widget>[
            _buildNavItem(0, Icons.home, 'Home'),
            _buildNavItem(1, Icons.search, 'Explore'),
            _buildNavItem(2, Icons.menu_book, 'Recipes'),
            // MODIFIED: Removed the fixed SizedBox(width: 48)
            // If the FAB is endDocked, it doesn't occupy space in the Row's center.
            // The three _buildNavItem widgets (which are Expanded)
            // will now distribute themselves across the available space.
          ],
        ),
      ),
    );
  }

  Widget _buildNavItem(int index, IconData icon, String label) {
    bool isSelected = _selectedIndex == index;
    return Expanded(
      child: InkWell(
        onTap: () => _onItemTapped(index),
        customBorder: const CircleBorder(),
        child: Padding(
          padding: const EdgeInsets.symmetric(
            vertical: 4.0,
          ), // Keep reduced padding
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: <Widget>[
              Icon(
                icon,
                color: isSelected ? AppColors.leafGreen : AppColors.dimGray,
                size: 26,
              ),
              const SizedBox(height: 2), // Keep reduced SizedBox
              Text(
                label,
                style: TextStyle(
                  color: isSelected ? AppColors.leafGreen : AppColors.dimGray,
                  fontSize: 12,
                  fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
