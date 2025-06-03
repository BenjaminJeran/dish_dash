// lib/models/user_challenge.dart
import 'package:dish_dash/models/challenge.dart'; // Make sure to import your Challenge model

class UserChallenge {
  final String id;
  final String userId;
  final String challengeId;
  final DateTime joinedAt;
  final int currentDay;
  final DateTime? lastCompletedDayAt; // Nullable
  final bool isCompleted;
  final Challenge? challenge; // Add the related Challenge object

  UserChallenge({
    required this.id,
    required this.userId,
    required this.challengeId,
    required this.joinedAt,
    required this.currentDay,
    this.lastCompletedDayAt, // Nullable parameter
    required this.isCompleted,
    this.challenge, // Make it nullable initially, but populated when fetched with join
  });

  factory UserChallenge.fromJson(Map<String, dynamic> json) {
    // Check if 'challenges' key exists and is not null (from the join)
    final Challenge? relatedChallenge = json['challenges'] != null
        ? Challenge.fromJson(json['challenges'] as Map<String, dynamic>)
        : null;

    return UserChallenge(
      id: json['id'],
      userId: json['user_id'],
      challengeId: json['challenge_id'],
      joinedAt: DateTime.parse(json['joined_at']),
      currentDay: json['current_day'],
      lastCompletedDayAt: json['last_completed_day_at'] != null
          ? DateTime.parse(json['last_completed_day_at'])
          : null,
      isCompleted: json['is_completed'],
      challenge: relatedChallenge, // Assign the parsed challenge
    );
  }

  // Helper to get durationDays easily
  int get durationDays => challenge?.durationDays ?? 0;
}