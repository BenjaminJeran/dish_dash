import 'dart:async';
import 'package:dish_dash/pages/auth/new_password.dart';
import 'package:dish_dash/pages/splash_screen.dart';
import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class DeepLinkHandlerScreen extends StatefulWidget {
  const DeepLinkHandlerScreen({super.key});

  @override
  State<DeepLinkHandlerScreen> createState() => _DeepLinkHandlerScreenState();
}

class _DeepLinkHandlerScreenState extends State<DeepLinkHandlerScreen> {
  bool _handledDeepLink = false;
  StreamSubscription<AuthState>? _authSubscription;
  Timer? _fallbackTimer;

  @override
  void initState() {
    super.initState();
    _handleInitialLink();
  }

  @override
  void dispose() {
    _authSubscription?.cancel();
    _fallbackTimer?.cancel();
    super.dispose();
  }

  Future<void> _handleInitialLink() async {
    await Future.delayed(const Duration(milliseconds: 500));
    
    if (!mounted) return;

    _authSubscription = Supabase.instance.client.auth.onAuthStateChange.listen((data) {
      final event = data.event;
      if (event == AuthChangeEvent.passwordRecovery && !_handledDeepLink && mounted) {
        _handledDeepLink = true;
        _fallbackTimer?.cancel(); 
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (context) => const NewPasswordScreen()),
        );
      }
    });

    _fallbackTimer = Timer(const Duration(seconds: 1), () {
      if (!_handledDeepLink && mounted) {
        _handledDeepLink = true;
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (context) => const SplashScreen()),
        );
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Theme.of(context).colorScheme.onPrimary,
      body: Center(
        child: Image.asset('assets/logo.png', width: 270, height: 270),
      ),
    );
  }
}