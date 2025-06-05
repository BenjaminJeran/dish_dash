import 'package:flutter/material.dart';
import 'package:dropdown_search/dropdown_search.dart';
import 'package:dish_dash/services/user_service.dart';
import 'package:dish_dash/colors/app_colors.dart';
import 'package:dish_dash/helpers/toast_manager.dart';

class PreferencesCard extends StatefulWidget {
  const PreferencesCard({super.key});

  @override
  State<PreferencesCard> createState() => _PreferencesCardState();
}

class _PreferencesCardState extends State<PreferencesCard> {
  final UserService _userService = UserService();
  Map<String, dynamic> _preferences = {};
  bool _loading = true;

  @override
  void initState() {
    super.initState();
    _loadPreferences();
  }

  Future<void> _loadPreferences() async {
    final prefs = await _userService.getUserPreferences();
    setState(() {
      _preferences = prefs ?? {};
      _loading = false;
    });
  }

  Future<void> _editPreferencesDialog() async {
    List<String> cuisines = List<String>.from(_preferences['cuisine'] ?? []);
    List<String> diets = List<String>.from(_preferences['diet'] ?? []);

    final List<String> availableCuisines = [
      'Italijanska',
      'Azijska',
      'Indijska',
      'Francoska',
      'Mehiška',
      'Sredozemska',
      'Ameriška',
      'Bližnjevzhodna',
    ];

    final List<String> availableDiets = [
      'Vegetarijanska',
      'Veganska',
      'Brez glutena',
      'Keto',
      'Paleo',
      'Brez mlečnih izdelkov',
      'Nizkohidratna',
    ];

    await showDialog(
      context: context,
      builder: (context) {
        return Dialog(
          backgroundColor: Colors.white,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
          insetPadding: const EdgeInsets.symmetric(
            horizontal: 24,
            vertical: 24,
          ),
          child: Padding(
            padding: const EdgeInsets.all(20),
            child: SingleChildScrollView(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Text(
                    'Uredi kulinarične preference',
                    style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                      color: AppColors.charcoal,
                    ),
                  ),
                  const SizedBox(height: 20),
                  Align(
                    alignment: Alignment.centerLeft,
                    child: Text(
                      'Kuhinje',
                      style: TextStyle(
                        fontWeight: FontWeight.w600,
                        fontSize: 16,
                        color: AppColors.charcoal,
                      ),
                    ),
                  ),
                  const SizedBox(height: 8),
                  DropdownSearch<String>.multiSelection(
                    items: availableCuisines,
                    selectedItems: cuisines,
                    onChanged: (items) => cuisines = items,
                    dropdownDecoratorProps: const DropDownDecoratorProps(
                      dropdownSearchDecoration: InputDecoration(
                        border: OutlineInputBorder(),
                        filled: true,
                      ),
                    ),
                  ),
                  const SizedBox(height: 20),
                  Align(
                    alignment: Alignment.centerLeft,
                    child: Text(
                      'Prehranske navade',
                      style: TextStyle(
                        fontWeight: FontWeight.w600,
                        fontSize: 16,
                        color: AppColors.charcoal,
                      ),
                    ),
                  ),
                  const SizedBox(height: 8),
                  DropdownSearch<String>.multiSelection(
                    items: availableDiets,
                    selectedItems: diets,
                    onChanged: (items) => diets = items,
                    dropdownDecoratorProps: const DropDownDecoratorProps(
                      dropdownSearchDecoration: InputDecoration(
                        border: OutlineInputBorder(),
                        filled: true,
                      ),
                    ),
                  ),
                  const SizedBox(height: 30),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      TextButton(
                        onPressed: () => Navigator.pop(context),
                        style: TextButton.styleFrom(
                          foregroundColor: AppColors.dimGray,
                        ),
                        child: const Text('Prekliči'),
                      ),
                      ElevatedButton(
                        onPressed: () async {
                          await _userService.updateUserPreferences({
                            'cuisine': cuisines,
                            'diet': diets,
                          });
                          if (mounted) {
                            Navigator.pop(context);
                            await _loadPreferences();
                            ToastManager.showSuccessToast(
                              context,
                              'Preference so bile shranjene!',
                            );
                          }
                        },
                        child: const Text('Shrani'),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    if (_loading) {
      return const Center(child: CircularProgressIndicator());
    }

    final cuisine =
        (_preferences['cuisine'] as List?)?.join(', ') ?? 'ni izbrano';
    final diet = (_preferences['diet'] as List?)?.join(', ') ?? 'ni izbrano';

    return Card(
      margin: const EdgeInsets.only(top: 10),
      elevation: 5,
      color: AppColors.softCream,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text(
                  'Preference',
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 20,
                    color: AppColors.charcoal,
                  ),
                ),
                IconButton(
                  icon: const Icon(Icons.edit, color: AppColors.charcoal),
                  onPressed: _editPreferencesDialog,
                ),
              ],
            ),
            const SizedBox(height: 10),
            Text(
              'Kuhinje: $cuisine',
              style: const TextStyle(color: AppColors.dimGray, fontSize: 16),
            ),
            const SizedBox(height: 5),
            Text(
              'Prehrane: $diet',
              style: const TextStyle(color: AppColors.dimGray, fontSize: 16),
            ),
          ],
        ),
      ),
    );
  }
}
