// lib/services/shopping_list_service.dart
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:dish_dash/models/shopping_list_item.dart';

class ShoppingListService {
  final SupabaseClient _supabase;

  ShoppingListService(this._supabase);


  Stream<List<ShoppingListItem>> getShoppingListStream(String userId) {
    return _supabase
        .from('shopping_items')
        .stream(primaryKey: ['id'])
        .eq('user_id', userId)
        .order('created_at', ascending: true)
        .map((data) => data.map((itemData) => ShoppingListItem.fromSupabase(itemData)).toList());
  }

  Future<void> addItem(String userId, String itemName) async {
    final List<Map<String, dynamic>> existingItems = await _supabase
        .from('shopping_items')
        .select()
        .eq('user_id', userId)
        .eq('name', itemName)
        .limit(1);

    if (existingItems.isNotEmpty) {
      final existingItemData = existingItems.first;
      final currentQuantity = existingItemData['quantity'] as int;
      await _supabase
          .from('shopping_items')
          .update({'quantity': currentQuantity + 1})
          .eq('id', existingItemData['id'])
          .eq('user_id', userId);
    } else {
      final newItem = ShoppingListItem(name: itemName); 
      await _supabase.from('shopping_items').insert({
        'user_id': userId,
        'name': newItem.name,
        'quantity': newItem.quantity,
        'is_checked': newItem.isChecked,
      });
    }
  }


  Future<void> deleteItem(String userId, String itemId) async {
    await _supabase
        .from('shopping_items')
        .delete()
        .eq('id', itemId)
        .eq('user_id', userId);
  }

  Future<void> incrementQuantity(String userId, String itemId, int currentQuantity) async {
    await _supabase
        .from('shopping_items')
        .update({'quantity': currentQuantity + 1})
        .eq('id', itemId)
        .eq('user_id', userId);
  }

  Future<void> decrementQuantity(String userId, String itemId, int currentQuantity) async {
    await _supabase
        .from('shopping_items')
        .update({'quantity': currentQuantity - 1})
        .eq('id', itemId)
        .eq('user_id', userId);
  }

  Future<void> toggleChecked(String userId, String itemId, bool currentCheckedStatus) async {
    await _supabase
        .from('shopping_items')
        .update({'is_checked': !currentCheckedStatus})
        .eq('id', itemId)
        .eq('user_id', userId);
  }
}