import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:dish_dash/colors/app_colors.dart';
import 'package:dropdown_search/dropdown_search.dart';
import 'package:dish_dash/pages/profile/profile_page_screen.dart';
import 'package:dish_dash/helpers/toast_manager.dart';

class PreferencesScreen extends StatefulWidget {
  const PreferencesScreen({super.key});

  @override
  State<PreferencesScreen> createState() => _PreferencesScreenState();
}

class _PreferencesScreenState extends State<PreferencesScreen> {
  final _supabase = Supabase.instance.client;

  List<String> _selectedCuisines = [];

  final List<String> _availableCuisines = [
    'Italijanska',
    'Azijska',
    'Indijska',
    'Francoska',
    'Mehiška',
    'Sredozemska',
    'Ameriška',
    'Bližnjevzhodna',
  ];

  @override
  void initState() {
    super.initState();
    _loadPreferences();
  }

  Future<void> _loadPreferences() async {
  final user = _supabase.auth.currentUser;
  if (user == null) return;

  try {
    final data = await _supabase
        .from('users')
        .select('preferences')
        .eq('id', user.id)
        .maybeSingle(); 

    if (data != null && data['preferences'] != null) {
      final prefs = data['preferences'] as Map<String, dynamic>;
      _selectedCuisines = List<String>.from(prefs['cuisine'] ?? []);
    } else {
      _selectedCuisines = []; 
    }
  } catch (e) {
    if (mounted) {
      ToastManager.showErrorToast(
        context,
        'Napaka pri nalaganju preferenc: ${e.toString()}',
      );
    }
    _selectedCuisines = []; 
  } finally {
    setState(() {}); 
  }
}

  Future<void> _savePreferences() async {
    final user = _supabase.auth.currentUser;
    if (user == null) return;

    try {
      await _supabase
          .from('users')
          .update({
            'preferences': {
              'cuisine': _selectedCuisines,
            },
          })
          .eq('id', user.id);

      if (mounted) {
        ToastManager.showSuccessToast(context, 'Nastavitve uspešno shranjene!');
      }
    } catch (e) {
      if (mounted) {
        ToastManager.showErrorToast(
          context,
          'Napaka pri shranjevanju: ${e.toString()}',
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () {
            Navigator.pop(context);
          },
        ),
        title: SizedBox(
          height: 80,
          child: Center(child: Image.asset('assets/logo.png', height: 80)),
        ),
        centerTitle: true,
        actions: [
          IconButton(
            icon: const Icon(Icons.person),
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => const ProfilePageScreen(),
                ),
              );
            },
          ),
        ],
        elevation: 0,
        backgroundColor: Colors.transparent,
        foregroundColor: AppColors.charcoal,
      ),
      body: Center(
        child: SingleChildScrollView(
          child: Padding(
            padding: const EdgeInsets.all(20.0),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Text(
                  'Tvoje kulinarične nastavitve',
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    color: AppColors.charcoal,
                  ),
                ),
                const SizedBox(height: 20),
                DropdownSearch<String>.multiSelection(
                  items: _availableCuisines,
                  selectedItems: _selectedCuisines,
                  onChanged: (List<String> items) {
                    setState(() {
                      _selectedCuisines = items;
                    });
                  },
                  dropdownDecoratorProps: const DropDownDecoratorProps(
                    dropdownSearchDecoration: InputDecoration(
                      labelText: 'Izberi kuhinje',
                      border: OutlineInputBorder(),
                    ),
                  ),
                ),
                const SizedBox(height: 32),
                ElevatedButton(
                  onPressed: _savePreferences,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.leafGreen,
                  ),
                  child: const Text(
                    'Shrani nastavitve',
                    style: TextStyle(color: AppColors.white),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
