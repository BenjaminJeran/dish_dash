// pages/auth/register_screen.dart
import 'package:flutter/material.dart';
// No need to import AppColors directly here if using Theme.of(context) or relying on global theme

class RegisterScreen extends StatelessWidget {
  const RegisterScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final _formKey =
        GlobalKey<FormState>(); // Still good practice for form validation
    return Scaffold(
      // AppBar will inherit styling from ThemeData.appBarTheme
      appBar: AppBar(
        title: const Text('Registracija'),
      ), // "Register" in Slovenian
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: SingleChildScrollView(
            // Added SingleChildScrollView
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                // Email Input Field
                TextFormField(
                  decoration: const InputDecoration(
                    labelText: 'E-pošta', // "Email" in Slovenian
                  ),
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Prosim vnesite e-pošto'; // "Please enter your email"
                    }
                    // You might add email format validation here
                    return null;
                  },
                  style: TextStyle(
                    color: Theme.of(context).colorScheme.onBackground,
                  ),
                ),
                const SizedBox(height: 12),
                // Password Input Field
                TextFormField(
                  decoration: const InputDecoration(
                    labelText: 'Geslo', // "Password" in Slovenian
                  ),
                  obscureText: true,
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Prosim vnesite geslo'; // "Please enter your password"
                    }
                    // You might add password strength validation here
                    return null;
                  },
                  style: TextStyle(
                    color: Theme.of(context).colorScheme.onBackground,
                  ),
                ),
                const SizedBox(height: 12),
                // Confirm Password Input Field
                TextFormField(
                  decoration: const InputDecoration(
                    labelText:
                        'Potrdi geslo', // "Confirm Password" in Slovenian
                  ),
                  obscureText: true,
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Prosim potrdite geslo'; // "Please confirm your password"
                    }
                    // TODO: Add logic to compare with the first password field
                    return null;
                  },
                  style: TextStyle(
                    color: Theme.of(context).colorScheme.onBackground,
                  ),
                ),
                const SizedBox(height: 24),
                // Register Button
                ElevatedButton(
                  onPressed: () {
                    if (_formKey.currentState!.validate()) {
                      // Add register logic here
                      print('Register button pressed');
                      // After successful registration, you might navigate back to login
                      // Navigator.pop(context);
                    }
                  },
                  // Style is inherited from ElevatedButtonThemeData in main.dart
                  child: const Text('Registracija'), // "Register" in Slovenian
                ),
                const SizedBox(height: 12),
                TextButton(
                  // Added back button for register screen
                  onPressed: () {
                    Navigator.pop(context); // Go back to Login screen
                  },
                  child: const Text("Nazaj na prijavo"), // "Back to Login"
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
