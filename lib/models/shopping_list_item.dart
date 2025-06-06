import 'package:flutter/material.dart'; 

class ShoppingListItem {
  final String? id;
  final String name;
  final int quantity;
  final bool isChecked;
  final DateTime?
  createdAt; 

  ShoppingListItem({
    this.id, 
    required this.name,
    this.quantity = 1,
    this.isChecked = false,
    this.createdAt,
  });

  factory ShoppingListItem.fromSupabase(Map<String, dynamic> data) {

    return ShoppingListItem(
      id: data['id'] as String?, 
      name: data['name'] as String,
      quantity: data['quantity'] as int,
      isChecked: data['is_checked'] as bool,
      createdAt:
          data['created_at'] != null
              ? DateTime.parse(
                data['created_at'].toString(),
              ) 
              : null,
    );
  }

  Map<String, dynamic> toSupabase() {
    return {
      'name': name,
      'quantity': quantity,
      'is_checked': isChecked,
    };
  }
  
  ShoppingListItem copyWith({
    String? id,
    String? name,
    int? quantity,
    bool? isChecked,
    DateTime? createdAt,
  }) {
    return ShoppingListItem(
      id: id ?? this.id,
      name: name ?? this.name,
      quantity: quantity ?? this.quantity,
      isChecked: isChecked ?? this.isChecked,
      createdAt: createdAt ?? this.createdAt,
    );
  }
}
