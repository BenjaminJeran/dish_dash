import 'package:dish_dash/pages/recipes/shopping_list_screen.dart';
import 'package:flutter/material.dart';
import 'package:dish_dash/pages/auth/login_screen.dart';
import 'package:dish_dash/colors/app_colors.dart';
import 'package:dish_dash/pages/onboarding_screen.dart'; // Import your onboarding screen
import 'package:dish_dash/pages/splash_screen.dart'; // Import your splash screen

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Recipe App',
      themeMode: ThemeMode.light,
      theme: ThemeData(
        primaryColor: AppColors.leafGreen,

        // Globalne barve
        colorScheme: ColorScheme.fromSeed(
          seedColor: AppColors.leafGreen,
          primary: AppColors.leafGreen,
          secondary: AppColors.lime,
          surface: AppColors.softCream,
          error: AppColors.tomatoRed,
          onPrimary: AppColors.white,
          onSecondary: AppColors.charcoal,
          onSurface: AppColors.charcoal,
          onError: AppColors.white,
        ).copyWith(
          // Ensure consistent usage of your neutral colors where appropriate
          tertiary: AppColors.oliveGreen,
          onTertiary: AppColors.white,
        ),

        appBarTheme: const AppBarTheme(
          backgroundColor: Colors.transparent,
          elevation: 0,
          foregroundColor: AppColors.charcoal,
          titleTextStyle: TextStyle(
            color: AppColors.charcoal,
            fontSize: 20,
            fontWeight: FontWeight.bold,
          ),
          centerTitle: true, // Center the title by default if you want
        ),

        // Define Input Field Theme for consistency (TextFormField will pick this up)
        inputDecorationTheme: InputDecorationTheme(
          filled: true,
          fillColor: AppColors.paleGray, // Background color for input fields
          border: InputBorder.none, // Removes default underline
          enabledBorder: OutlineInputBorder(
            // Border when enabled but not focused
            borderRadius: BorderRadius.circular(10),
            borderSide: BorderSide.none, // No visible border line
          ),
          focusedBorder: OutlineInputBorder(
            // Border when focused
            borderRadius: BorderRadius.circular(10),
            borderSide: BorderSide.none, // No visible border line
          ),
          errorBorder: OutlineInputBorder(
            // Border for validation errors
            borderRadius: BorderRadius.circular(10),
            borderSide: BorderSide(color: AppColors.tomatoRed, width: 1.0),
          ),
          focusedErrorBorder: OutlineInputBorder(
            // Border for validation errors when focused
            borderRadius: BorderRadius.circular(10),
            borderSide: BorderSide(color: AppColors.tomatoRed, width: 1.5),
          ),
          hintStyle: TextStyle(color: AppColors.dimGray), // Hint text color
          contentPadding: const EdgeInsets.symmetric(
            horizontal: 20,
            vertical: 15,
          ),
        ),

        // Define ElevatedButton Theme (Login/Register buttons)
        elevatedButtonTheme: ElevatedButtonThemeData(
          style: ElevatedButton.styleFrom(
            backgroundColor:
                AppColors.leafGreen, // Default background for ElevatedButtons
            foregroundColor: AppColors.white, // Default text color
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(10),
            ),
            padding: const EdgeInsets.symmetric(
              vertical: 15,
              horizontal: 20,
            ), // Consistent button padding
            textStyle: const TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
            ),
          ),
        ),

        textButtonTheme: TextButtonThemeData(
          style: TextButton.styleFrom(
            foregroundColor: AppColors.leafGreen,
            textStyle: const TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w500,
            ),
          ),
        ),

        // Optionally, define global Text Theme if you have specific fonts/sizes
        textTheme: const TextTheme(
          // Example for app-wide text styles. You can customize these.
          // headlineLarge: TextStyle(fontSize: 32, fontWeight: FontWeight.bold, color: AppColors.charcoal),
          // titleLarge: TextStyle(fontSize: 22, fontWeight: FontWeight.bold, color: AppColors.charcoal),
          // bodyLarge: TextStyle(fontSize: 16, color: AppColors.charcoal),
          // bodyMedium: TextStyle(fontSize: 14, color: AppColors.dimGray),
        ),

        useMaterial3: true, // Enable Material 3 design features
      ),
      //home: const OnboardingScreen(),
      home: const SplashScreen(), // Your app starts with the LoginScreen
      // For now, we keep MaterialPageRoute navigation, but keep GoRouter in mind for later!
    );
  }
}
