// lib/pages/shopping_list_screen.dart
import 'package:dish_dash/pages/profile/profile_page_screen.dart';
import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:dish_dash/colors/app_colors.dart';
import 'package:dish_dash/models/shopping_list_item.dart';

class ShoppingListScreen extends StatefulWidget {
  const ShoppingListScreen({super.key});

  @override
  State<ShoppingListScreen> createState() => _ShoppingListScreenState();
}

class _ShoppingListScreenState extends State<ShoppingListScreen> {
  final TextEditingController _newItemController = TextEditingController();
  final SupabaseClient _supabase = Supabase.instance.client;

  String? get userId => _supabase.auth.currentUser?.id;

  @override
  void dispose() {
    _newItemController.dispose();
    super.dispose();
  }

  Future<void> _addItem() async {
    final newItemName = _newItemController.text.trim();
    if (userId == null) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text(
              'Prosimo, prijavite se, da dodate elemente na seznam.',
            ),
          ),
        );
      }
      return;
    }

    if (newItemName.isNotEmpty) {
      try {
        final currentUserId = userId!;

        final List<Map<String, dynamic>> existingItems = await _supabase
            .from('shopping_items')
            .select()
            .eq('user_id', currentUserId)
            .eq('name', newItemName)
            .limit(1);

        if (existingItems.isNotEmpty) {
          final existingItemData = existingItems.first;
          final currentQuantity = existingItemData['quantity'] as int;
          await _supabase
              .from('shopping_items')
              .update({'quantity': currentQuantity + 1})
              .eq('id', existingItemData['id'])
              .eq('user_id', currentUserId);
        } else {
          final newItem = ShoppingListItem(name: newItemName);
          await _supabase.from('shopping_items').insert({
            'user_id': currentUserId,
            'name': newItem.name,
            'quantity': newItem.quantity,
            'is_checked': newItem.isChecked,
          });
        }
        _newItemController.clear();
      } catch (e) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Napaka pri dodajanju elementa: $e')),
          );
        }
        print('Napaka pri dodajanju elementa: $e');
      }
    }
  }

  Future<void> _deleteItem(String itemId) async {
    if (userId == null) return;

    try {
      final currentUserId = userId!;

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Brišem element...'),
            duration: Duration(seconds: 1),
          ),
        );
      }

      final response = await _supabase
          .from('shopping_items')
          .delete()
          .eq('id', itemId)
          .eq('user_id', currentUserId);

      if (mounted) {
        _refreshList();
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Napaka pri brisanju elementa: $e')),
        );
      }
      print('Napaka pri brisanju elementa: $e');
    }
  }

  Future<void> _refreshList() async {
    setState(() {});
  }

  Future<void> _incrementQuantity(ShoppingListItem item) async {
    if (userId == null || item.id == null) return;
    try {
      final currentUserId = userId!;
      final currentItemId = item.id!;

      await _supabase
          .from('shopping_items')
          .update({'quantity': item.quantity + 1})
          .eq('id', currentItemId)
          .eq('user_id', currentUserId);
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Napaka pri povečevanju količine: $e')),
        );
      }
      print('Napaka pri povečevanju količine: $e');
    }
  }

  Future<void> _decrementQuantity(ShoppingListItem item) async {
    if (userId == null || item.id == null) return;
    try {
      final currentUserId = userId!;
      final currentItemId = item.id!;

      if (item.quantity > 1) {
        await _supabase
            .from('shopping_items')
            .update({'quantity': item.quantity - 1})
            .eq('id', currentItemId)
            .eq('user_id', currentUserId);
      } else {
        await _deleteItem(currentItemId);
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Napaka pri zmanjševanju količine: $e')),
        );
      }
      print('Napaka pri zmanjševanju količine: $e');
    }
  }

  Future<void> _toggleChecked(ShoppingListItem item) async {
    if (userId == null || item.id == null) return;
    try {
      final currentUserId = userId!;
      final currentItemId = item.id!;

      await _supabase
          .from('shopping_items')
          .update({'is_checked': !item.isChecked})
          .eq('id', currentItemId)
          .eq('user_id', currentUserId);
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Napaka pri spreminjanju statusa: $e')),
        );
      }
      print('Napaka pri spreminjanju statusa: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    final String? currentUserId = userId;

    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () {
            Navigator.pop(context);
          },
        ),
        title: Center(child: Image.asset('assets/logo.png', height: 80)),
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
      body: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 20.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Nakupovalni seznam',
              style: TextStyle(
                fontSize: 30,
                fontWeight: FontWeight.bold,
                color: AppColors.charcoal,
              ),
            ),
            const SizedBox(height: 30),
            Row(
              children: [
                Expanded(
                  child: Container(
                    decoration: BoxDecoration(
                      color: AppColors.paleGray,
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: TextField(
                      controller: _newItemController,
                      decoration: InputDecoration(
                        hintText: 'Dodaj nov element',
                        hintStyle: TextStyle(color: AppColors.dimGray),
                        contentPadding: const EdgeInsets.symmetric(
                          horizontal: 20,
                          vertical: 15,
                        ),
                        border: InputBorder.none,
                      ),
                      style: TextStyle(color: AppColors.charcoal),
                      onSubmitted: (value) => _addItem(),
                    ),
                  ),
                ),
                const SizedBox(width: 10),
                GestureDetector(
                  onTap: _addItem,
                  child: Container(
                    width: 50,
                    height: 50,
                    decoration: BoxDecoration(
                      color: AppColors.leafGreen,
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: Icon(Icons.add, color: AppColors.white, size: 30),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 20),
            Expanded(
              child:
                  currentUserId == null
                      ? const Center(
                        child: Text(
                          'Prosimo, prijavite se, da si ogledate svoj nakupovalni seznam.',
                        ),
                      )
                      : StreamBuilder<List<Map<String, dynamic>>>(
                        stream: _supabase
                            .from('shopping_items')
                            .stream(primaryKey: ['id'])
                            .eq('user_id', currentUserId)
                            .order('created_at', ascending: true),
                        builder: (context, snapshot) {
                          if (snapshot.hasError) {
                            return Center(
                              child: Column(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Text('Napaka: ${snapshot.error}'),
                                  ElevatedButton(
                                    onPressed: _refreshList,
                                    child: const Text('Poskusi znova'),
                                  ),
                                ],
                              ),
                            );
                          }

                          if (snapshot.connectionState ==
                              ConnectionState.waiting) {
                            return const Center(
                              child: CircularProgressIndicator(),
                            );
                          }

                          final shoppingItems =
                              snapshot.data
                                  ?.map(
                                    (itemData) =>
                                        ShoppingListItem.fromSupabase(itemData),
                                  )
                                  .toList() ??
                              [];

                          if (shoppingItems.isEmpty) {
                            return Center(
                              child: Column(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  const Text(
                                    'Vaš nakupovalni seznam je prazen!',
                                  ),
                                  const SizedBox(height: 10),
                                  ElevatedButton(
                                    onPressed: _refreshList,
                                    child: const Text('Osveži'),
                                  ),
                                ],
                              ),
                            );
                          }

                          return RefreshIndicator(
                            onRefresh: _refreshList,
                            child: ListView.builder(
                              itemCount: shoppingItems.length,
                              itemBuilder: (context, index) {
                                final item = shoppingItems[index];
                                return Padding(
                                  padding: const EdgeInsets.only(bottom: 15.0),
                                  child: Container(
                                    decoration: BoxDecoration(
                                      color: AppColors.paleGray,
                                      borderRadius: BorderRadius.circular(10),
                                    ),
                                    padding: const EdgeInsets.symmetric(
                                      horizontal: 20,
                                      vertical: 15,
                                    ),
                                    child: Row(
                                      children: [
                                        GestureDetector(
                                          onTap: () => _toggleChecked(item),
                                          child: Icon(
                                            item.isChecked
                                                ? Icons.check_box
                                                : Icons.check_box_outline_blank,
                                            color:
                                                item.isChecked
                                                    ? AppColors.leafGreen
                                                    : AppColors.dimGray,
                                          ),
                                        ),
                                        const SizedBox(width: 10),
                                        Expanded(
                                          child: Text(
                                            item.name,
                                            style: TextStyle(
                                              fontSize: 18,
                                              color: AppColors.charcoal,
                                              decoration:
                                                  item.isChecked
                                                      ? TextDecoration
                                                          .lineThrough
                                                      : TextDecoration.none,
                                              decorationColor:
                                                  AppColors.charcoal,
                                            ),
                                          ),
                                        ),
                                        Row(
                                          mainAxisSize: MainAxisSize.min,
                                          children: [
                                            GestureDetector(
                                              onTap:
                                                  () =>
                                                      _decrementQuantity(item),
                                              child: Icon(
                                                Icons.remove_circle_outline,
                                                color: AppColors.dimGray,
                                              ),
                                            ),
                                            Padding(
                                              padding:
                                                  const EdgeInsets.symmetric(
                                                    horizontal: 8.0,
                                                  ),
                                              child: Text(
                                                '${item.quantity}',
                                                style: TextStyle(
                                                  fontSize: 18,
                                                  fontWeight: FontWeight.bold,
                                                  color: AppColors.charcoal,
                                                ),
                                              ),
                                            ),
                                            GestureDetector(
                                              onTap:
                                                  () =>
                                                      _incrementQuantity(item),
                                              child: Icon(
                                                Icons.add_circle_outline,
                                                color: AppColors.dimGray,
                                              ),
                                            ),
                                          ],
                                        ),
                                        const SizedBox(width: 10),
                                        GestureDetector(
                                          onTap: () => _deleteItem(item.id!),
                                          child: Icon(
                                            Icons.delete_outline,
                                            color: AppColors.tomatoRed,
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                );
                              },
                            ),
                          );
                        },
                      ),
            ),
            const SizedBox(height: 20),
            Center(
              child: ElevatedButton(
                onPressed: () {
                  print('Deli seznam pritisnjen');
                  if (mounted) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                        content: Text('Funkcija deljenja se razvija!'),
                      ),
                    );
                  }
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.leafGreen,
                  minimumSize: const Size(double.infinity, 50),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10),
                  ),
                ),
                child: Text(
                  'Deli seznam',
                  style: TextStyle(
                    color: AppColors.white,
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ),
            const SizedBox(height: 20),
          ],
        ),
      ),
    );
  }
}
