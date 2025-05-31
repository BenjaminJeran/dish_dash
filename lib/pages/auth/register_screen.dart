import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart'; // Import Supabase

// You can now remove this import as it's no longer used in this file
// import 'package:firebase_auth/firebase_auth.dart';

class RegisterScreen extends StatefulWidget {
  const RegisterScreen({super.key});

  @override
  State<RegisterScreen> createState() => _RegisterScreenState();
}

class _RegisterScreenState extends State<RegisterScreen> {
  final _formKey = GlobalKey<FormState>();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  final TextEditingController _confirmPasswordController =
      TextEditingController();

  bool _obscurePassword = true;
  bool _obscureConfirmPassword = true;
  bool _isLoading = false; // To show a loading indicator

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    _confirmPasswordController.dispose();
    super.dispose();
  }

  Future<void> _register() async {
    if (_formKey.currentState!.validate()) {
      // Check if passwords match
      if (_passwordController.text.trim() !=
          _confirmPasswordController.text.trim()) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Gesli se ne ujemata.'), // Passwords do not match.
            ),
          );
        }
        return;
      }

      setState(() {
        _isLoading = true; // Start loading
      });

      try {
        // --- SUPABASE REGISTRATION CALL ---
        final AuthResponse response = await Supabase.instance.client.auth
            .signUp(
              email: _emailController.text.trim(),
              password: _passwordController.text.trim(),
            );

        // Supabase signUp requires email confirmation by default.
        // The user object might be null or contain the user depending on the email confirmation settings.
        // It's good practice to inform the user about email verification.

        if (response.user != null) {
          if (mounted) {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(
                content: Text(
                  'Registracija uspešna! Prosimo, preverite e-pošto za potrditev.',
                ), // Registration successful! Please check your email for confirmation.
              ),
            );
            Navigator.pop(context); // Go back to the login screen
          }
        } else {
          // This else block might be hit if the user is created but no session is returned
          // because email confirmation is required.
          if (mounted) {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(
                content: Text(
                  'Registracija uspešna, vendar se niste prijavili. Preverite e-pošto za potrditev.',
                ), // Registration successful, but not logged in. Check email for confirmation.
              ),
            );
            Navigator.pop(context);
          }
        }
      } on AuthException catch (e) {
        String message;
        // Supabase AuthException codes for registration might include:
        // 'User already registered', 'Email rate limit exceeded', 'Invalid email'
        if (e.message.contains('User already registered')) {
          message =
              'E-poštni naslov je že v uporabi.'; // The email address is already in use.
        } else if (e.message.contains('Email rate limit exceeded')) {
          message =
              'Preveč poskusov registracije. Poskusite znova kasneje.'; // Too many registration attempts. Try again later.
        } else if (e.message.contains('Invalid email')) {
          message =
              'E-poštni naslov ni pravilno oblikovan.'; // The email address is badly formatted.
        } else if (e.message.contains(
          'Password should be at least 6 characters',
        )) {
          message =
              'Geslo mora imeti vsaj 6 znakov.'; // Password must be at least 6 characters.
        } else {
          message =
              'Napaka pri registraciji: ${e.message}'; // Generic error message
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
      body: Center(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 16.0),
          child: Form(
            key: _formKey,
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                // Screen Title
                const Text(
                  'Registracija',
                  style: TextStyle(fontSize: 26, fontWeight: FontWeight.bold),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 40),

                // Email Input Field
                TextFormField(
                  controller: _emailController, // Assign controller
                  keyboardType:
                      TextInputType.emailAddress, // Optimize keyboard for email
                  decoration: const InputDecoration(
                    labelText: 'E-pošta',
                    border: OutlineInputBorder(),
                    floatingLabelBehavior: FloatingLabelBehavior.auto,
                  ),
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Prosim vnesite e-pošto';
                    }
                    if (!RegExp(r'^[^@]+@[^@]+\.[^@]+').hasMatch(value)) {
                      return 'Prosim vnesite veljaven e-poštni naslov'; // Please enter a valid email address
                    }
                    return null;
                  },
                  style: TextStyle(
                    color: Theme.of(context).colorScheme.onSurface,
                  ),
                ),
                const SizedBox(height: 20),

                // Password Input Field with Eye Icon
                TextFormField(
                  controller: _passwordController, // Assign controller
                  obscureText: _obscurePassword,
                  decoration: InputDecoration(
                    labelText: 'Geslo',
                    border: const OutlineInputBorder(),
                    floatingLabelBehavior: FloatingLabelBehavior.auto,
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
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Prosim vnesite geslo';
                    }
                    if (value.length < 6) {
                      return 'Geslo mora imeti vsaj 6 znakov'; // Password must be at least 6 characters.
                    }
                    return null;
                  },
                  style: TextStyle(
                    color: Theme.of(context).colorScheme.onSurface,
                  ),
                ),
                const SizedBox(height: 20),

                // Confirm Password Input Field with Eye Icon
                TextFormField(
                  controller: _confirmPasswordController, // Assign controller
                  obscureText: _obscureConfirmPassword,
                  decoration: InputDecoration(
                    labelText: 'Potrdi geslo',
                    border: const OutlineInputBorder(),
                    floatingLabelBehavior: FloatingLabelBehavior.auto,
                    suffixIcon: IconButton(
                      icon: Icon(
                        _obscureConfirmPassword
                            ? Icons.visibility_off
                            : Icons.visibility,
                      ),
                      onPressed: () {
                        setState(() {
                          _obscureConfirmPassword = !_obscureConfirmPassword;
                        });
                      },
                    ),
                  ),
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Prosim potrdite geslo';
                    }
                    // This check will be done in the _register method for better user feedback
                    return null;
                  },
                  style: TextStyle(
                    color: Theme.of(context).colorScheme.onSurface,
                  ),
                ),
                const SizedBox(height: 32),

                // Register Button
                ElevatedButton(
                  onPressed:
                      _isLoading
                          ? null
                          : _register, // Disable button while loading
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
                          : const Text('Registracija'),
                ),
                const SizedBox(height: 12),

                // Back to Login Link
                TextButton(
                  onPressed: () {
                    Navigator.pop(context);
                  },
                  child: const Text("Nazaj na prijavo"),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
