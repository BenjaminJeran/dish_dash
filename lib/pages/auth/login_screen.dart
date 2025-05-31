import 'package:flutter/material.dart';
import 'package:dish_dash/pages/auth/register_screen.dart';
import 'package:dish_dash/pages/auth/reset_password.dart';
import 'package:dish_dash/pages/main_tab_screen.dart';
import 'package:supabase_flutter/supabase_flutter.dart'; // Import Supabase

// You can now remove this import as it's no longer used in this file
// import 'package:firebase_auth/firebase_auth.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  bool _obscurePassword = true;
  bool _isLoading = false; // To show a loading indicator

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  Future<void> _login() async {
    setState(() {
      _isLoading = true; // Start loading
    });

    try {
      // --- SUPABASE LOGIN CALL ---
      final AuthResponse response = await Supabase.instance.client.auth
          .signInWithPassword(
            email: _emailController.text.trim(),
            password: _passwordController.text.trim(),
          );

      // Supabase signInWithPassword returns an AuthResponse.
      // If successful, 'session' and 'user' will not be null.
      if (response.user != null) {
        if (mounted) {
          Navigator.pushReplacement(
            context,
            MaterialPageRoute(builder: (context) => const MainTabScreen()),
          );
        }
      } else {
        // This 'else' block might be hit if the email is unconfirmed,
        // or other non-exception errors occur. Supabase errors are usually
        // thrown as AuthException.
        // For simplicity, we'll let the catch block handle most errors.
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Prijava ni uspela. Preverite poverilnice.'),
            ),
          );
        }
      }
    } on AuthException catch (e) {
      String message;
      // Supabase AuthException codes can be different from Firebase.
      // Common ones include 'invalid_credentials', 'email_not_confirmed', etc.
      // You might need to check Supabase documentation for exact error codes
      // or inspect 'e.message' for more specific handling.
      if (e.message.contains('Invalid login credentials')) {
        message = 'Napačen e-poštni naslov ali geslo.'; // Invalid credentials
      } else if (e.message.contains('Email not confirmed')) {
        message =
            'E-poštni naslov ni potrjen. Preverite svoj nabiralnik.'; // Email not confirmed
      } else {
        message = 'Napaka pri prijavi: ${e.message}'; // Generic error message
      }

      if (mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text(message)));
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Prišlo je do nepričakovane napake: $e'),
          ), // An unexpected error occurred.
        );
      }
    } finally {
      setState(() {
        _isLoading = false; // Stop loading regardless of success or failure
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Image.asset('assets/logo.png', height: 93, width: 93),
        centerTitle: true,
        elevation: 0,
        backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      ),
      body: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 8.0),
        child: Center(
          child: SingleChildScrollView(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                // Title
                const Text(
                  'Prijava',
                  style: TextStyle(fontSize: 26, fontWeight: FontWeight.bold),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 40), // Extra spacing added here
                // Email Field
                TextFormField(
                  controller: _emailController, // Assign controller
                  keyboardType:
                      TextInputType.emailAddress, // Optimize keyboard for email
                  decoration: const InputDecoration(
                    labelText: 'E-pošta',
                    floatingLabelBehavior: FloatingLabelBehavior.auto,
                    border: OutlineInputBorder(),
                  ),
                  style: TextStyle(
                    color: Theme.of(context).colorScheme.onSurface,
                  ),
                ),
                const SizedBox(height: 20),

                // Password Field with Eye Icon
                TextFormField(
                  controller: _passwordController, // Assign controller
                  obscureText: _obscurePassword,
                  decoration: InputDecoration(
                    labelText: 'Geslo',
                    floatingLabelBehavior: FloatingLabelBehavior.auto,
                    border: const OutlineInputBorder(),
                    suffixIcon: IconButton(
                      icon: Icon(
                        _obscurePassword
                            ? Icons.visibility_off
                            : Icons.visibility,
                      ),
                      onPressed: () {
                        setState(() {
                          _obscurePassword = !_obscurePassword;
                        });
                      },
                    ),
                  ),
                  style: TextStyle(
                    color: Theme.of(context).colorScheme.onSurface,
                  ),
                ),
                const SizedBox(height: 12),

                // Forgotten Password Link
                Align(
                  alignment: Alignment.centerRight,
                  child: TextButton(
                    onPressed: () {
                      Navigator.of(context).push(
                        MaterialPageRoute(
                          builder: (context) => const ResetPasswordScreen(),
                        ),
                      );
                    },
                    child: const Text("Ste pozabili geslo?"),
                  ),
                ),

                // Register Link
                Align(
                  alignment: Alignment.centerRight,
                  child: TextButton(
                    onPressed: () {
                      Navigator.of(context).push(
                        MaterialPageRoute(
                          builder: (context) => const RegisterScreen(),
                        ),
                      );
                    },
                    child: const Text("Nimate računa? Registracija"),
                  ),
                ),
                const SizedBox(height: 20),

                // Login Button
                ElevatedButton(
                  onPressed:
                      _isLoading
                          ? null
                          : _login, // Disable button while loading
                  child:
                      _isLoading
                          ? const SizedBox(
                            width: 24,
                            height: 24,
                            child: CircularProgressIndicator(
                              color: Colors.white,
                              strokeWidth: 2,
                            ),
                          )
                          : const Text('Prijava'),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
