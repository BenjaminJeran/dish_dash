import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class NewPasswordScreen extends StatefulWidget {
  const NewPasswordScreen({super.key});

  @override
  State<NewPasswordScreen> createState() => _NewPasswordScreenState();
}

class _NewPasswordScreenState extends State<NewPasswordScreen> {
  final _formKey = GlobalKey<FormState>();
  final _passwordController = TextEditingController();
  bool _isSubmitting = false;

  Future<void> _updatePassword() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isSubmitting = true);

    try {
      final response = await Supabase.instance.client.auth.updateUser(
        UserAttributes(password: _passwordController.text),
      );

      setState(() => _isSubmitting = false);

      if (response.user != null) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Geslo uspešno posodobljeno.')),
        );
        Navigator.pushReplacementNamed(context, '/login');
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Neznana napaka pri posodabljanju gesla.')),
        );
      }
    } catch (e) {
      setState(() => _isSubmitting = false);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Napaka: ${e.toString()}')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Nova Gesla')),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: Column(
            children: [
              const Text(
                'Vnesite novo geslo',
                style: TextStyle(fontSize: 18),
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _passwordController,
                obscureText: true,
                decoration: const InputDecoration(
                  labelText: 'Novo geslo',
                  border: OutlineInputBorder(),
                ),
                validator: (value) {
                  if (value == null || value.length < 6) {
                    return 'Geslo mora imeti vsaj 6 znakov';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 24),
              ElevatedButton(
                onPressed: _isSubmitting ? null : _updatePassword,
                child: const Text('Posodobi geslo'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
