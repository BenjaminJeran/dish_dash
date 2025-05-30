// lib/pages/splash_screen.dart
import 'package:dish_dash/pages/auth/login_screen.dart';
import 'package:flutter/material.dart';
import 'package:dish_dash/pages/onboarding_screen.dart';
import 'package:shared_preferences/shared_preferences.dart';

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

    // Animation setup
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 1), // How long 1 full bob takes
    )..repeat(reverse: true); // Repeats up and down

    _animation = Tween<Offset>(
      begin: const Offset(0, 0),
      end: const Offset(0, -0.05), // Slight upward motion
    ).animate(CurvedAnimation(parent: _controller, curve: Curves.easeInOut));
    _checkOnboardingStatus();
  }

  Future<void> _checkOnboardingStatus() async {
    final prefs = await SharedPreferences.getInstance();
    final bool hasSeenOnboarding = prefs.getBool('hasSeenOnboarding') ?? false;

    Future.delayed(const Duration(seconds: 2), () {
      if (hasSeenOnboarding) {
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (context) => const LoginScreen()),
        );
      } else {
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (context) => const OnboardingScreen()),
        );
        prefs.setBool('hasSeenOnboarding', true);
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
