import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class ResetPasswordScreen extends StatelessWidget {
  const ResetPasswordScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final formKey = GlobalKey<FormState>();
    final emailController = TextEditingController();

    return Scaffold(
      appBar: AppBar(
        title: Image.asset('assets/logo.png', height: 93, width: 93),
        centerTitle: true,
        elevation: 0,
        backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      ),
      body: Center(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(16.0),
          child: Form(
            key: formKey,
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Text(
                  'Pozabljeno geslo?',
                  style: TextStyle(fontSize: 26, fontWeight: FontWeight.bold),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 24),
                const Text(
                  'Vnesite svoj e-poštni naslov za prejem povezave za ponastavitev gesla.',
                  style: TextStyle(fontSize: 16),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 24),
                TextFormField(
                  controller: emailController,
                  decoration: const InputDecoration(
                    labelText: 'E-pošta',
                    border: OutlineInputBorder(),
                    floatingLabelBehavior: FloatingLabelBehavior.auto,
                  ),
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Prosim vnesite e-pošto';
                    }
                    return null;
                  },
                  style: TextStyle(
                    color: Theme.of(context).colorScheme.onSurface,
                  ),
                ),
                const SizedBox(height: 24),
                ElevatedButton(
                  onPressed: () async {
                    if (formKey.currentState!.validate()) {
                      final email = emailController.text.trim();
                      final supabase = Supabase.instance.client;

                      try {
                        await supabase.auth.resetPasswordForEmail(
                          email,
                          redirectTo: 'myapp://reset-password',
                        );
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(
                            content: Text(
                              'Povezava za ponastavitev gesla je bila poslana.',
                            ),
                          ),
                        );
                        Navigator.pop(context); 
                      } catch (error) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(
                            content: Text('Napaka: $error'),
                            backgroundColor: Colors.red,
                          ),
                        );
                      }
                    }
                  },
                  child: const Text('Pošlji'), 
                ),
                const SizedBox(height: 12),
                TextButton(
                  onPressed: () => Navigator.pop(context),
                  child: const Text('Nazaj na prijavo'), 
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
