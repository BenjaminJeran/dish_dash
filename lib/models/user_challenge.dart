
import 'package:dish_dash/models/challenge.dart'; 

class UserChallenge {
  final String id;
  final String userId;
  final String challengeId;
  final DateTime joinedAt;
  final int currentDay;
  final DateTime? lastCompletedDayAt;
  final bool isCompleted;
  final Challenge? challenge; 

  UserChallenge({
    required this.id,
    required this.userId,
    required this.challengeId,
    required this.joinedAt,
    required this.currentDay,
    this.lastCompletedDayAt, 
    required this.isCompleted,
    this.challenge, 
  });

  factory UserChallenge.fromJson(Map<String, dynamic> json) {
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
      challenge: relatedChallenge, 
    );
  }

  int get durationDays => challenge?.durationDays ?? 0;
}