// lib/pages/shopping_list_screen.dart
import 'package:dish_dash/pages/profile/profile_page_screen.dart';
import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:dish_dash/colors/app_colors.dart';
import 'package:dish_dash/models/shopping_list_item.dart';
import 'package:dish_dash/services/shopping_list_service.dart'; 

class ShoppingListScreen extends StatefulWidget {
  const ShoppingListScreen({super.key});

  @override
  State<ShoppingListScreen> createState() => _ShoppingListScreenState();
}

class _ShoppingListScreenState extends State<ShoppingListScreen> {
  final TextEditingController _newItemController = TextEditingController();
  late final ShoppingListService _shoppingListService; 

  String? get _userId => Supabase.instance.client.auth.currentUser?.id;

  @override
  void initState() {
    super.initState();
    _shoppingListService = ShoppingListService(Supabase.instance.client);
  }

  @override
  void dispose() {
    _newItemController.dispose();
    super.dispose();
  }

  void _showSnackBar(String message, {Duration duration = const Duration(seconds: 1)}) {
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(message), duration: duration),
      );
    }
  }


  void _showErrorSnackBar(String message) {
    _showSnackBar(message); 
  }

  Future<void> _addItem() async {
    final newItemName = _newItemController.text.trim();
    if (_userId == null) {
      _showSnackBar('Please log in to add items to your list.');
      return;
    }

    if (newItemName.isNotEmpty) {
      try {
        await _shoppingListService.addItem(_userId!, newItemName);
        _newItemController.clear();
      } catch (e) {
        _showErrorSnackBar('Error adding item: $e');
        print('Error adding item: $e'); 
      }
    }
  }

  Future<void> _deleteItem(String itemId) async {
    if (_userId == null) return;
    _showSnackBar('Deleting item...');
    try {
      await _shoppingListService.deleteItem(_userId!, itemId);
      _refreshList(); 
    } catch (e) {
      _showErrorSnackBar('Error deleting item: $e');
      print('Error deleting item: $e');
    }
  }

  Future<void> _incrementQuantity(ShoppingListItem item) async {
    if (_userId == null || item.id == null) return;
    try {
      await _shoppingListService.incrementQuantity(_userId!, item.id!, item.quantity);
    } catch (e) {
      _showErrorSnackBar('Error incrementing quantity: $e');
      print('Error incrementing quantity: $e');
    }
  }

  Future<void> _decrementQuantity(ShoppingListItem item) async {
    if (_userId == null || item.id == null) return;
    try {
      if (item.quantity > 1) {
        await _shoppingListService.decrementQuantity(_userId!, item.id!, item.quantity);
      } else {
        await _deleteItem(item.id!);
      }
    } catch (e) {
      _showErrorSnackBar('Error decrementing quantity: $e');
      print('Error decrementing quantity: $e');
    }
  }

  Future<void> _toggleChecked(ShoppingListItem item) async {
    if (_userId == null || item.id == null) return;
    try {
      await _shoppingListService.toggleChecked(_userId!, item.id!, item.isChecked);
    } catch (e) {
      _showErrorSnackBar('Error toggling checked status: $e');
      print('Error toggling checked status: $e');
    }
  }

  Future<void> _refreshList() async {
    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    final String? currentUserId = _userId; 

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
              child: currentUserId == null
                  ? const Center(
                      child: Text(
                        'Please log in to view your shopping list.',
                      ),
                    )
                  : StreamBuilder<List<ShoppingListItem>>( 
                      stream: _shoppingListService.getShoppingListStream(currentUserId),
                      builder: (context, snapshot) {
                        if (snapshot.hasError) {
                          return Center(
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Text('Error: ${snapshot.error}'),
                                ElevatedButton(
                                  onPressed: _refreshList,
                                  child: const Text('Retry'),
                                ),
                              ],
                            ),
                          );
                        }

                        if (snapshot.connectionState == ConnectionState.waiting) {
                          return const Center(
                            child: CircularProgressIndicator(),
                          );
                        }

                        final shoppingItems = snapshot.data ?? [];

                        if (shoppingItems.isEmpty) {
                          return Center(
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                const Text('Your shopping list is empty!'),
                                const SizedBox(height: 10),
                                ElevatedButton(
                                  onPressed: _refreshList,
                                  child: const Text('Refresh'),
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
                                          color: item.isChecked
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
                                            decoration: item.isChecked
                                                ? TextDecoration.lineThrough
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
                                            onTap: () =>
                                                _decrementQuantity(item),
                                            child: Icon(
                                              Icons.remove_circle_outline,
                                              color: AppColors.dimGray,
                                            ),
                                          ),
                                          Padding(
                                            padding: const EdgeInsets.symmetric(
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
                                            onTap: () =>
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
          
          ],
        ),
      ),
    );
  }
}