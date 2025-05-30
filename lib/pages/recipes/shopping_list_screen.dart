// lib/pages/shopping_list_screen.dart
import 'package:dish_dash/pages/profile_page_screen.dart';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart'; // Import Firebase Auth
import 'package:dish_dash/colors/app_colors.dart';
import 'package:dish_dash/models/shopping_list_item.dart'; // Import your updated model

class ShoppingListScreen extends StatefulWidget {
  const ShoppingListScreen({super.key});

  @override
  State<ShoppingListScreen> createState() => _ShoppingListScreenState();
}

class _ShoppingListScreenState extends State<ShoppingListScreen> {
  final TextEditingController _newItemController = TextEditingController();
  final FirebaseAuth _auth = FirebaseAuth.instance; // Firebase Auth instance
  final FirebaseFirestore _firestore =
      FirebaseFirestore.instance; // Firestore instance

  // Dobim id trenutnega uporabnika
  String? get userId => _auth.currentUser?.uid;

  // pot kolekcije je 'users/{userId}/shoppingLists'
  CollectionReference<ShoppingListItem> get _userShoppingListCollection {
    if (userId == null) {
      throw Exception("User not logged in!");
    }
    return _firestore
        .collection('users')
        .doc(userId)
        .collection('shoppingLists')
        .withConverter<ShoppingListItem>(
          fromFirestore: ShoppingListItem.fromFirestore,
          toFirestore: (item, options) => item.toFirestore(),
        );
  }

  @override
  void dispose() {
    _newItemController.dispose();
    super.dispose();
  }

  Future<void> _addItem() async {
    final newItemName = _newItemController.text.trim();
    if (newItemName.isNotEmpty && userId != null) {
      final querySnapshot =
          await _userShoppingListCollection
              .where('name', isEqualTo: newItemName)
              .limit(1)
              .get();

      if (querySnapshot.docs.isNotEmpty) {
        final existingItemDoc = querySnapshot.docs.first;
        final existingItem = existingItemDoc.data();
        await _userShoppingListCollection.doc(existingItem.id).update({
          'quantity': existingItem.quantity + 1,
        });
      } else {
        final newItem = ShoppingListItem(name: newItemName);
        await _userShoppingListCollection.add(newItem);
      }
      _newItemController.clear();
    } else if (userId == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Please log in to add items to your list.'),
        ),
      );
    }
  }

  Future<void> _deleteItem(String itemId) async {
    if (userId != null) {
      await _userShoppingListCollection.doc(itemId).delete();
    }
  }

  Future<void> _incrementQuantity(ShoppingListItem item) async {
    if (userId != null && item.id != null) {
      await _userShoppingListCollection.doc(item.id).update({
        'quantity': item.quantity + 1,
      });
    }
  }

  Future<void> _decrementQuantity(ShoppingListItem item) async {
    if (userId != null && item.id != null) {
      if (item.quantity > 1) {
        await _userShoppingListCollection.doc(item.id).update({
          'quantity': item.quantity - 1,
        });
      } else {
        await _deleteItem(item.id!);
      }
    }
  }

  Future<void> _toggleChecked(ShoppingListItem item) async {
    if (userId != null && item.id != null) {
      await _userShoppingListCollection.doc(item.id).update({
        'isChecked': !item.isChecked,
      });
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
        title: Center(child: Image.asset('assets/logo.png', height: 80)),
        actions: [
          IconButton(
            icon: const Icon(Icons.person),
            onPressed: () {
              print('Profile icon pressed');
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
              // StreamBuilder za realtime posodobitve seznama
              child:
                  userId == null
                      ? const Center(
                        child: Text(
                          'Please log in to view your shopping list.',
                        ),
                      )
                      : StreamBuilder<QuerySnapshot<ShoppingListItem>>(
                        stream:
                            _userShoppingListCollection
                                .orderBy('timestamp', descending: false)
                                .snapshots(),
                        builder: (context, snapshot) {
                          if (snapshot.hasError) {
                            return Center(
                              child: Text('Error: ${snapshot.error}'),
                            );
                          }

                          if (snapshot.connectionState ==
                              ConnectionState.waiting) {
                            return const Center(
                              child: CircularProgressIndicator(),
                            );
                          }

                          final shoppingItems =
                              snapshot.data?.docs
                                  .map((doc) => doc.data())
                                  .toList() ??
                              [];

                          if (shoppingItems.isEmpty) {
                            return const Center(
                              child: Text('Your shopping list is empty!'),
                            );
                          }

                          return ListView.builder(
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
                                                    ? TextDecoration.lineThrough
                                                    : TextDecoration.none,
                                            decorationColor: AppColors.charcoal,
                                          ),
                                        ),
                                      ),

                                      Row(
                                        mainAxisSize: MainAxisSize.min,
                                        children: [
                                          GestureDetector(
                                            onTap:
                                                () => _decrementQuantity(item),
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
                                            onTap:
                                                () => _incrementQuantity(item),
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
                          );
                        },
                      ),
            ),
            const SizedBox(height: 20),
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
