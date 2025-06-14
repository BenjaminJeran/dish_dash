import 'package:dish_dash/pages/DeepLinking.dart';
import 'package:flutter/material.dart';
import 'package:dish_dash/colors/app_colors.dart';
import 'package:dish_dash/pages/splash_screen.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:dish_dash/pages/auth/new_password.dart';

Future<void> main() async {


  WidgetsFlutterBinding.ensureInitialized();

  try {
    await dotenv.load(fileName: ".env"); 
  } catch (e) {
    throw Exception('Error loading .env file: $e'); 
  }

  final String apiKey = dotenv.env['ANON_KEY'] ?? 'default_key';

  await Supabase.initialize(
    url: 'https://hpeuvvghrjvtikkgdnql.supabase.co',
    anonKey:
        apiKey
  );
  runApp(const MyApp());
}

class MyApp extends StatefulWidget {
  const MyApp({super.key});

  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  @override
  void initState() {
    super.initState();
  }


  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Recipe App',
      themeMode: ThemeMode.light,
      theme: ThemeData(
        primaryColor: AppColors.leafGreen,
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
        ).copyWith(tertiary: AppColors.oliveGreen, onTertiary: AppColors.white),

        appBarTheme: const AppBarTheme(
          backgroundColor: Colors.transparent,
          elevation: 0,
          foregroundColor: AppColors.charcoal,
          titleTextStyle: TextStyle(
            color: AppColors.charcoal,
            fontSize: 20,
            fontWeight: FontWeight.bold,
          ),
          centerTitle: true,
        ),

        inputDecorationTheme: InputDecorationTheme(
          filled: true,
          fillColor: AppColors.paleGray,
          border: InputBorder.none,
          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(10),
            borderSide: BorderSide.none,
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(10),
            borderSide: BorderSide.none,
          ),
          errorBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(10),
            borderSide: BorderSide(color: AppColors.tomatoRed, width: 1.0),
          ),
          focusedErrorBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(10),
            borderSide: BorderSide(color: AppColors.tomatoRed, width: 1.5),
          ),
          hintStyle: TextStyle(color: AppColors.dimGray),
          contentPadding: const EdgeInsets.symmetric(
            horizontal: 20,
            vertical: 15,
          ),
        ),

        elevatedButtonTheme: ElevatedButtonThemeData(
          style: ElevatedButton.styleFrom(
            backgroundColor: AppColors.leafGreen,
            foregroundColor: AppColors.white,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(10),
            ),
            padding: const EdgeInsets.symmetric(vertical: 15, horizontal: 20),
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
        textTheme: const TextTheme(),

        useMaterial3: true,
      ),
      home: const DeepLinkHandlerScreen(),
    );
  }
}
