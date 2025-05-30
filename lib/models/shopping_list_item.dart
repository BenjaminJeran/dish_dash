import 'package:cloud_firestore/cloud_firestore.dart';

class ShoppingListItem {
  String? id; // Nullable for new items before saving to Firestore
  String name;
  int quantity;
  bool isChecked;

  ShoppingListItem({
    this.id,
    required this.name,
    this.quantity = 1,
    this.isChecked = false,
  });

  // Factory constructor to create a ShoppingListItem from a Firestore document
  factory ShoppingListItem.fromFirestore(
    DocumentSnapshot<Map<String, dynamic>> snapshot,
    SnapshotOptions? options,
  ) {
    final data = snapshot.data();
    return ShoppingListItem(
      id: snapshot.id, // Set the ID from the document snapshot
      name: data?['name'],
      quantity: data?['quantity'] ?? 1,
      isChecked: data?['isChecked'] ?? false,
    );
  }

  // Method to convert a ShoppingListItem to a map for Firestore
  Map<String, dynamic> toFirestore() {
    return {
      'name': name,
      'quantity': quantity,
      'isChecked': isChecked,
      'timestamp': FieldValue.serverTimestamp(), // Add a timestamp for ordering
    };
  }
}
