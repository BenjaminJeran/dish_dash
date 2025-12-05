import 'package:dish_dash/pages/auth/login_screen.dart';
import 'package:dish_dash/pages/profile/profile_page_screen.dart';
import 'package:dish_dash/pages/recipes/shopping_list_screen.dart';
import 'package:dish_dash/pages/settings/about_screen.dart';
import 'package:dish_dash/pages/settings/settings_screen.dart';
import 'package:flutter/material.dart';
import 'package:dish_dash/colors/app_colors.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:dish_dash/pages/settings/preferences_screen.dart';
import 'package:dish_dash/pages/explore/explore_content_screen.dart';
import 'package:dish_dash/pages/recipes/recipes_content_screen.dart';
import 'package:dish_dash/pages/recipes/create_recipe_screen.dart';
import 'package:dish_dash/pages/challenges/cooking_challenge_screen.dart';

class MainTabScreen extends StatefulWidget {
  const MainTabScreen({super.key});

  @override
  State<MainTabScreen> createState() => _MainTabScreenState();
}

class _MainTabScreenState extends State<MainTabScreen> {
  int _selectedIndex = 0;

  static const List<Widget> _widgetOptions = <Widget>[
    ExploreContentScreen(),
    RecipesContentScreen(),
    CookingChallengeScreen(),
  ];

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        leading: Builder(
          builder:
              (context) => IconButton(
                icon: const Icon(Icons.menu),
                onPressed: () {
                  Scaffold.of(context).openDrawer();
                },
              ),
        ),
        title: SizedBox(
          height: 80,
          child: Center(child: Image.asset('assets/logo.png', height: 80)),
        ),
        centerTitle: true,
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
        elevation: 0,
        backgroundColor: Colors.transparent,
        foregroundColor: AppColors.charcoal,
      ),
      body: _widgetOptions.elementAt(_selectedIndex),
      drawer: Drawer(
        backgroundColor: AppColors.white,
        child: ListView(
          padding: EdgeInsets.zero,
          children: <Widget>[
            DrawerHeader(
              decoration: BoxDecoration(color: AppColors.leafGreen),
              child: const Text(
                'Meni Dish Dash',
                style: TextStyle(color: AppColors.white, fontSize: 24),
              ),
            ), // Removed the extra parenthesis here
            ListTile(
              leading: const Icon(Icons.settings),
              title: const Text('Nastavitve'),
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => const SettingsScreen(),
                  ),
                );
              },
            ),
            ListTile(
              leading: const Icon(Icons.info),
              title: const Text('O aplikaciji'),
              onTap:
                  () => {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => const AboutScreen(),
                      ),
                    ),
                  },
            ),
            ListTile(
              leading: const Icon(Icons.shopping_bag),
              title: const Text("Nakupovalni seznam"),
              onTap:
                  () => {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => const ShoppingListScreen(),
                      ),
                    ),
                  },
            ),
            ListTile(
              leading: const Icon(Icons.favorite),
              title: const Text("Preference"),
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => const PreferencesScreen(),
                  ),
                );
              },
            ),
            ListTile(
              leading: const Icon(Icons.logout),
              title: const Text('Odjava'),
              onTap: () async {
                try {
                  await Supabase.instance.client.auth.signOut();

                  if (mounted) {
                    Navigator.pushReplacement(
                      context,
                      MaterialPageRoute(
                        builder: (context) => const LoginScreen(),
                      ),
                    );
                  }
                } catch (e) {
                  print("Napaka med odjavo: $e");
                  if (mounted) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(content: Text('Napaka pri odjavi: $e')),
                    );
                  }
                }
              },
            ),
          ],
        ),
      ),
      bottomNavigationBar: BottomAppBar(
        color: AppColors.white,
        surfaceTintColor: AppColors.white,
        shadowColor: AppColors.paleGray,
        elevation: 5.0,
        shape: const CircularNotchedRectangle(),
        notchMargin: 8.0,
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceAround,
          children: <Widget>[
            _buildNavItem(0, Icons.search, 'Raziskuj'),
            _buildNavItem(1, Icons.menu_book, 'Recepti'),
            _buildNavItem(2, Icons.stars, 'Izzivi'),
          ],
        ),
      ),
      floatingActionButton: Padding(
        padding: const EdgeInsets.only(bottom: 50.0),
        child: SizedBox(
          width: 70.0,
          height: 70.0,
          child: FloatingActionButton(
            key: const Key('createRecipeFAB'),
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => const CreateRecipeScreen(),
                ),
              );
            },
            backgroundColor: AppColors.leafGreen,
            shape: const CircleBorder(),
            child: const Icon(Icons.add, color: AppColors.white, size: 35.0),
          ),
        ),
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.endDocked,
    );
  }

  Widget _buildNavItem(int index, IconData icon, String label) {
    bool isSelected = _selectedIndex == index;
    return Expanded(
      child: InkWell(
        onTap: () => _onItemTapped(index),
        customBorder: const CircleBorder(),
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 4.0),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: <Widget>[
              Icon(
                icon,
                color: isSelected ? AppColors.leafGreen : AppColors.dimGray,
                size: 26,
              ),
              const SizedBox(height: 2),
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
