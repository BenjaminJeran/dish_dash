import 'package:flutter/material.dart';
import 'package:dish_dash/colors/app_colors.dart';
import 'package:dish_dash/pages/splash_screen.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:dish_dash/pages/auth/new_password.dart'; 

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Supabase.initialize(
    url: 'https://hpeuvvghrjvtikkgdnql.supabase.co',
    anonKey:
        'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6ImhwZXV2dmdocmp2dGlra2dkbnFsIiwicm9sZSI6ImFub24iLCJpYXQiOjE3NDg3MTc5NzcsImV4cCI6MjA2NDI5Mzk3N30.X9WE_VvUhjF9ZU6FSDosCJda0mkqd_e1sjdJYt2haxo',
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
    //_setupAuthListener();
  }

  //void _setupAuthListener() {
  //  // Listen for changes in Supabase authentication state
  //  Supabase.instance.client.auth.onAuthStateChange.listen((data) {
  //    final AuthChangeEvent event = data.event;
  //    final Session? session = data.session;
//
  //    // Check if the event is a password recovery
  //    if (event == AuthChangeEvent.passwordRecovery) {
  //      // When a password recovery link is clicked, Supabase processes the deep link
  //      // and sets the session. We then navigate to the NewPasswordScreen.
  //      // The NewPasswordScreen will then use the established session to update the password.
  //      Navigator.of(context).pushReplacement(
  //        MaterialPageRoute(
  //          builder: (context) => const NewPasswordScreen(),
  //        ),
  //      );
  //    } else if (event == AuthChangeEvent.signedIn || event == AuthChangeEvent.initialSession) {
  //      // This block handles initial sign-in or when a user signs in normally.
  //      // You might want to navigate to a different screen (e.g., home screen) here.
  //      // For now, it's commented out as per your original code's intent.
  //      // if (session != null) {
  //      //   Navigator.of(context).pushAndRemoveUntil(
  //      //     MaterialPageRoute(builder: (context) => const HomeScreen()), // Replace with your home screen
  //      //     (Route<dynamic> route) => false,
  //      //   );
  //      // }
  //    }
  //  });
  //}

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
            backgroundColor:
                AppColors.leafGreen, 
            foregroundColor: AppColors.white, 
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(10),
            ),
            padding: const EdgeInsets.symmetric(
              vertical: 15,
              horizontal: 20,
            ), 
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
        textTheme: const TextTheme(
        ),

        useMaterial3: true,
      ),
      home: const SplashScreen(), 
    );
  }
}
