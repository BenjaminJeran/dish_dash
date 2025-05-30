// lib/models/shopping_list_item.dart
class ShoppingListItem {
  String name;
  int quantity;
  bool isChecked; // Added to track if an item is checked off in the list

  ShoppingListItem({
    required this.name,
    this.quantity = 1,
    this.isChecked = false,
  });

  // Optional: Add a factory constructor for creating from JSON
  factory ShoppingListItem.fromJson(Map<String, dynamic> json) {
    return ShoppingListItem(
      name: json['name'] as String,
      quantity: json['quantity'] as int? ?? 1, // Default to 1 if null
      isChecked:
          json['isChecked'] as bool? ?? false, // Default to false if null
    );
  }

  // Optional: Add a method to convert to JSON
  Map<String, dynamic> toJson() {
    return {'name': name, 'quantity': quantity, 'isChecked': isChecked};
  }

  // Optional: Add copyWith for immutable updates
  ShoppingListItem copyWith({String? name, int? quantity, bool? isChecked}) {
    return ShoppingListItem(
      name: name ?? this.name,
      quantity: quantity ?? this.quantity,
      isChecked: isChecked ?? this.isChecked,
    );
  }
}
