import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:dish_dash/colors/app_colors.dart';
import 'package:dish_dash/models/user_challenge.dart';
import 'package:dish_dash/services/challenge_service.dart';

class CookingChallengeBar extends StatefulWidget {
  const CookingChallengeBar({super.key});

  @override
  State<CookingChallengeBar> createState() => _CookingChallengeBarState();
}

class _CookingChallengeBarState extends State<CookingChallengeBar> {
  final _supabase = Supabase.instance.client;
  final ChallengeService _challengeService = ChallengeService();
  late Future<List<UserChallenge>> _userChallengesFuture;

  @override
  void initState() {
    super.initState();
    _fetchUserChallenges();
  }

  void _fetchUserChallenges() {
    final userId = _supabase.auth.currentUser?.id;
    if (userId != null) {
      _userChallengesFuture = _challengeService.fetchUserChallenges(userId);
    } else {
      _userChallengesFuture = Future.value([]);
    }
  }

  double _calculateOverallProgress(List<UserChallenge> challenges) {
    if (challenges.isEmpty) return 0.0;

    int totalPossibleDays = 0;
    int totalCompletedDays = 0;

    for (var uc in challenges) {
      if (uc.challenge != null) {
        totalPossibleDays += uc.durationDays;
        totalCompletedDays += uc.currentDay;
      }
    }

    if (totalPossibleDays == 0) return 0.0;
    return totalCompletedDays / totalPossibleDays;
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<List<UserChallenge>>(
      future: _userChallengesFuture,
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        } else if (snapshot.hasError || !snapshot.hasData) {
          return const Text('Napaka pri nalaganju izziva');
        } else {
          final progress = _calculateOverallProgress(snapshot.data!);
          return Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'Kuharski izziv',
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  color: AppColors.charcoal,
                ),
              ),
              const SizedBox(height: 12),
              ClipRRect(
                borderRadius: BorderRadius.circular(15),
                child: LinearProgressIndicator(
                  value: progress,
                  minHeight: 25,
                  backgroundColor: AppColors.paleGray,
                  valueColor:
                      const AlwaysStoppedAnimation<Color>(AppColors.leafGreen),
                ),
              ),
              const SizedBox(height: 8),
              Center(
                child: Text(
                  '${(progress * 100).toStringAsFixed(0)}%',
                  style: const TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: AppColors.charcoal,
                  ),
                ),
              ),
              const SizedBox(height: 16),
            ],
          );
        }
      },
    );
  }
}
