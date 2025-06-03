// lib/services/challenge_service.dart
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:dish_dash/models/challenge.dart';
import 'package:dish_dash/models/user_challenge.dart';

class ChallengeService {
  final SupabaseClient _supabase = Supabase.instance.client;

  // --- Public Challenges ---

  Future<List<Challenge>> fetchAllChallenges() async {
    try {
      // Removed .execute()
      final List<dynamic> data = await _supabase
          .from('challenges')
          .select()
          .order('created_at', ascending: false);

      return data.map((json) => Challenge.fromJson(json)).toList();
    } on PostgrestException catch (e) {
      print('Error fetching challenges: ${e.message}');
      rethrow;
    } catch (e) {
      print('An unexpected error occurred: $e');
      rethrow;
    }
  }

  // --- User's Challenges ---

  Future<List<UserChallenge>> fetchUserChallenges(String userId) async {
    try {
      // Removed .execute()
      final List<dynamic> data = await _supabase
          .from('user_challenges')
          .select('*, challenges(*)') // Select user_challenge data AND related challenge data
          .eq('user_id', userId);

      // When using 'select(*, table_name(*))', the foreign table data is nested
      return data.map((json) {
        return UserChallenge.fromJson(json);
      }).toList();
    } on PostgrestException catch (e) {
      print('Error fetching user challenges: ${e.message}');
      rethrow;
    } catch (e) {
      print('An unexpected error occurred: $e');
      rethrow;
    }
  }

  Future<UserChallenge?> joinChallenge(String challengeId) async {
    final String? userId = _supabase.auth.currentUser?.id;
    if (userId == null) {
      throw Exception('User not logged in.');
    }

    try {
      // Removed .execute()
      final Map<String, dynamic> data = await _supabase
          .from('user_challenges')
          .insert({
            'user_id': userId,
            'challenge_id': challengeId,
            'current_day': 0, // Start at day 0 or 1, as per your logic
            'is_completed': false,
          })
          .select() // Select the newly inserted row
          .single(); // Expect a single row

      return UserChallenge.fromJson(data);
    } on PostgrestException catch (e) {
      print('Error joining challenge: ${e.message}');
      // Handle unique constraint error specifically if needed (user already joined)
      if (e.message.contains('duplicate key value violates unique constraint')) {
        throw Exception('You have already joined this challenge.');
      }
      rethrow;
    } catch (e) {
      print('An unexpected error occurred: $e');
      rethrow;
    }
  }

  Future<UserChallenge> markDayComplete(UserChallenge userChallenge) async {
    final String? userId = _supabase.auth.currentUser?.id;
    if (userId == null || userId != userChallenge.userId) {
      throw Exception('Unauthorized action.');
    }

    // Basic check for already completed
    if (userChallenge.isCompleted) {
      throw Exception('This challenge is already completed.');
    }

    // Ensure challenge details are available for durationDays
    if (userChallenge.challenge == null) {
      // This should ideally not happen if fetchUserChallenges is used correctly
      // but as a fallback, you might need to fetch the challenge details here
      throw Exception('Challenge details not available for this user challenge.');
    }

    // Logic for consecutive days (IMPORTANT)
    final DateTime today = DateTime.now();
    final DateTime yesterday = today.subtract(const Duration(days: 1));

    bool canMarkComplete = false;
    if (userChallenge.currentDay == 0) { // First day, can always mark
      canMarkComplete = true;
    } else if (userChallenge.lastCompletedDayAt != null) {
      // Check if last completion was yesterday or today (already marked for today)
      final DateTime lastCompletedDate = userChallenge.lastCompletedDayAt!;

      // Normalize dates to compare only year, month, day
      final DateTime normalizedToday = DateTime(today.year, today.month, today.day);
      final DateTime normalizedYesterday = DateTime(yesterday.year, yesterday.month, yesterday.day);
      final DateTime normalizedLastCompletedDate = DateTime(lastCompletedDate.year, lastCompletedDate.month, lastCompletedDate.day);


      if (normalizedLastCompletedDate.isAtSameMomentAs(normalizedToday)) {
        throw Exception('You have already marked today\'s progress.');
      }
      if (normalizedLastCompletedDate.isAtSameMomentAs(normalizedYesterday)) {
        canMarkComplete = true;
      }
    }

    if (!canMarkComplete) {
      throw Exception('You can only mark progress for today or if starting new. A day was missed or an invalid date was recorded.');
    }

    final int newCurrentDay = userChallenge.currentDay + 1;
    // Now using userChallenge.durationDays which is populated from the nested challenge object
    final bool newIsCompleted = newCurrentDay >= userChallenge.durationDays;

    try {
      // Removed .execute()
      final Map<String, dynamic> data = await _supabase
          .from('user_challenges')
          .update({
            'current_day': newCurrentDay,
            'last_completed_day_at': today.toIso8601String().substring(0, 10), // Store only date
            'is_completed': newIsCompleted,
          })
          .eq('id', userChallenge.id)
          .select() // Select the updated row
          .single();

      return UserChallenge.fromJson(data);
    } on PostgrestException catch (e) {
      print('Error marking day complete: ${e.message}');
      rethrow;
    } catch (e) {
      print('An unexpected error occurred: $e');
      rethrow;
    }
  }
}