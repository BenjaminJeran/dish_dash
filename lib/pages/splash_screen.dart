// lib/pages/splash_screen.dart
import 'package:dish_dash/pages/auth/login_screen.dart';
import 'package:dish_dash/pages/main_tab_screen.dart';
import 'package:flutter/material.dart';
import 'package:dish_dash/pages/onboarding_screen.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:firebase_auth/firebase_auth.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<Offset> _animation;

  @override
  void initState() {
    super.initState();

    _controller = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 1),
    )..repeat(reverse: true);

    _animation = Tween<Offset>(
      begin: const Offset(0, 0),
      end: const Offset(0, -0.05),
    ).animate(CurvedAnimation(parent: _controller, curve: Curves.easeInOut));

    _initializeApp();
  }

  bool _checkUserStatus() {
    return FirebaseAuth.instance.currentUser != null;
  }

  Future<void> _initializeApp() async {
    final prefs = await SharedPreferences.getInstance();
    final bool hasSeenOnboarding = prefs.getBool('hasSeenOnboarding') ?? false;

    Future.delayed(const Duration(seconds: 2), () {
      if (!hasSeenOnboarding) {
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (context) => const OnboardingScreen()),
        );
        prefs.setBool('hasSeenOnboarding', true);
      } else {
        if (_checkUserStatus()) {
          Navigator.pushReplacement(
            context,
            MaterialPageRoute(builder: (context) => const MainTabScreen()),
          );
        } else {
          Navigator.pushReplacement(
            context,
            MaterialPageRoute(builder: (context) => const LoginScreen()),
          );
        }
      }
    });
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Theme.of(context).colorScheme.onPrimary,
      body: Center(
        child: SlideTransition(
          position: _animation,
          child: Image.asset('assets/logo.png', width: 270, height: 270),
        ),
      ),
    );
  }
}
