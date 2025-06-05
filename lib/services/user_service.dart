import 'package:supabase_flutter/supabase_flutter.dart';

class UserService {
  final SupabaseClient _supabase = Supabase.instance.client;

  Future<Map<String, dynamic>?> getUserProfile() async {
    final user = _supabase.auth.currentUser;
    if (user == null) return null;

    final response =
        await _supabase.from('users').select().eq('id', user.id).maybeSingle();

    return response;
  }

  Future<void> updateUserField(String field, dynamic value) async {
    final user = _supabase.auth.currentUser;
    if (user == null) return;

    await _supabase
        .from('users')
        .update({field: value, 'updated_at': DateTime.now().toIso8601String()})
        .eq('id', user.id);
  }

  Future<void> createDefaultUser() async {
    final user = _supabase.auth.currentUser;
    if (user == null) return;

    await _supabase.from('users').insert({
      'id': user.id,
      'name': 'New User',
      'email': user.email,
      'profession': 'Profesionalni kuhar',
      'about_me': 'O meni',
      'created_at': DateTime.now().toIso8601String(),
    });
  }

  Future<Map<String, dynamic>?> getUserPreferences() async {
    final user = Supabase.instance.client.auth.currentUser;
    if (user == null) return null;

    final response =
        await Supabase.instance.client
            .from('users')
            .select('preferences')
            .eq('id', user.id)
            .single();

    return response['preferences'] ?? {};
  }

  Future<void> updateUserPreferences(Map<String, dynamic> preferences) async {
    final user = Supabase.instance.client.auth.currentUser;
    if (user == null) return;

    await Supabase.instance.client
        .from('users')
        .update({'preferences': preferences})
        .eq('id', user.id);
  }
}
