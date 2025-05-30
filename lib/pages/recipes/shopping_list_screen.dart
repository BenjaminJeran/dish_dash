// lib/pages/shopping_list_screen.dart
import 'package:flutter/material.dart';
import 'package:dish_dash/colors/app_colors.dart';
import 'package:dish_dash/models/shopping_list_item.dart'; // Import your new model

class ShoppingListScreen extends StatefulWidget {
  const ShoppingListScreen({super.key});

  @override
  State<ShoppingListScreen> createState() => _ShoppingListScreenState();
}

class _ShoppingListScreenState extends State<ShoppingListScreen> {
  final List<ShoppingListItem> _shoppingItems = [
    ShoppingListItem(name: 'Jajca', quantity: 2),
    ShoppingListItem(name: 'Banane', quantity: 1),
    ShoppingListItem(name: 'Mleko', quantity: 1),
  ];

  final TextEditingController _newItemController = TextEditingController();

  @override
  void dispose() {
    _newItemController.dispose();
    super.dispose();
  }

  void _addItem() {
    final newItemName = _newItemController.text.trim();
    if (newItemName.isNotEmpty) {
      setState(() {
        int existingIndex = _shoppingItems.indexWhere(
          (item) => item.name.toLowerCase() == newItemName.toLowerCase(),
        );
        if (existingIndex != -1) {
          _shoppingItems[existingIndex].quantity++;
        } else {
          _shoppingItems.add(ShoppingListItem(name: newItemName));
        }
        _newItemController.clear();
      });
    }
  }

  void _deleteItem(int index) {
    setState(() {
      _shoppingItems.removeAt(index);
    });
  }

  void _incrementQuantity(int index) {
    setState(() {
      _shoppingItems[index].quantity++;
    });
  }

  void _decrementQuantity(int index) {
    setState(() {
      if (_shoppingItems[index].quantity > 1) {
        _shoppingItems[index].quantity--;
      } else {
        _deleteItem(index);
      }
    });
  }

  // New method to toggle item's checked status
  void _toggleChecked(int index) {
    setState(() {
      _shoppingItems[index].isChecked = !_shoppingItems[index].isChecked;
    });
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
        title: Center(child: Image.asset('assets/logo.png', height: 80)),
        actions: [
          IconButton(
            icon: const Icon(Icons.person),
            onPressed: () {
              print('Profile icon pressed');
              // Navigator.push(context, MaterialPageRoute(builder: (context) => const ProfilePageScreen()));
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
              child: ListView.builder(
                itemCount: _shoppingItems.length,
                itemBuilder: (context, index) {
                  final item = _shoppingItems[index]; // Get the item
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
                          // Checkbox for the item
                          GestureDetector(
                            onTap: () => _toggleChecked(index),
                            child: Icon(
                              item.isChecked
                                  ? Icons.check_box
                                  : Icons.check_box_outline_blank,
                              color:
                                  item.isChecked
                                      ? AppColors
                                          .leafGreen // Checked color
                                      : AppColors.dimGray, // Unchecked color
                            ),
                          ),
                          const SizedBox(width: 10),
                          Expanded(
                            child: Text(
                              item.name, // Display item name
                              style: TextStyle(
                                fontSize: 18,
                                color: AppColors.charcoal,
                                decoration:
                                    item.isChecked
                                        ? TextDecoration
                                            .lineThrough // Strikethrough if checked
                                        : TextDecoration.none,
                                decorationColor: AppColors.charcoal,
                              ),
                            ),
                          ),
                          // Quantity controls
                          Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              GestureDetector(
                                onTap: () => _decrementQuantity(index),
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
                                  '${item.quantity}', // Display quantity
                                  style: TextStyle(
                                    fontSize: 18,
                                    fontWeight: FontWeight.bold,
                                    color: AppColors.charcoal,
                                  ),
                                ),
                              ),
                              GestureDetector(
                                onTap: () => _incrementQuantity(index),
                                child: Icon(
                                  Icons.add_circle_outline,
                                  color: AppColors.dimGray,
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(width: 10),
                          GestureDetector(
                            onTap: () => _deleteItem(index),
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
            ),
            const SizedBox(height: 20),
            // "Share List" Button
            Center(
              child: ElevatedButton(
                onPressed: () {
                  print('Share list pressed');
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text('Funkcija deljenja se razvija!'),
                    ),
                  );
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
