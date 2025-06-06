// lib/services/challenge_service.dart
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:dish_dash/models/challenge.dart';
import 'package:dish_dash/models/user_challenge.dart';

class ChallengeService {
  final SupabaseClient _supabase = Supabase.instance.client;

  Future<List<Challenge>> fetchAllChallenges() async {
    try {
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


  Future<List<UserChallenge>> fetchUserChallenges(String userId) async {
    try {
      final List<dynamic> data = await _supabase
          .from('user_challenges')
          .select('*, challenges(*)') 
          .eq('user_id', userId);

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
      final Map<String, dynamic> data = await _supabase
          .from('user_challenges')
          .insert({
            'user_id': userId,
            'challenge_id': challengeId,
            'current_day': 0, 
            'is_completed': false,
          })
          .select() 
          .single();

      return UserChallenge.fromJson(data);
    } on PostgrestException catch (e) {
      print('Error joining challenge: ${e.message}');
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

    if (userChallenge.isCompleted) {
      throw Exception('This challenge is already completed.');
    }

    if (userChallenge.challenge == null) {
      throw Exception('Challenge details not available for this user challenge.');
    }

    final DateTime today = DateTime.now();
    final DateTime yesterday = today.subtract(const Duration(days: 1));

    bool canMarkComplete = false;
    if (userChallenge.currentDay == 0) {
      canMarkComplete = true;
    } else if (userChallenge.lastCompletedDayAt != null) {
      final DateTime lastCompletedDate = userChallenge.lastCompletedDayAt!;

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
    final bool newIsCompleted = newCurrentDay >= userChallenge.durationDays;

    try {
      final Map<String, dynamic> data = await _supabase
          .from('user_challenges')
          .update({
            'current_day': newCurrentDay,
            'last_completed_day_at': today.toIso8601String().substring(0, 10),
            'is_completed': newIsCompleted,
          })
          .eq('id', userChallenge.id)
          .select()
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

   Future<void> leaveChallenge(String userChallengeId) async {
    final userId = _supabase.auth.currentUser?.id;
    if (userId == null) {
      throw Exception('User not authenticated.');
    }

    try {
      await _supabase
          .from('user_challenges')
          .delete()
          .eq('id', userChallengeId)
          .eq('user_id', userId); 
    } catch (e) {
      print('Error leaving challenge: $e');
      rethrow;
    }
  }
}


