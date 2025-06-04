// lib/pages/challenges/browse_challenges_screen.dart
import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:dish_dash/colors/app_colors.dart';
import 'package:dish_dash/models/challenge.dart';
import 'package:dish_dash/services/challenge_service.dart';
import 'package:dish_dash/helpers/toast_manager.dart';

class BrowseChallengesScreen extends StatefulWidget {
  const BrowseChallengesScreen({super.key});

  @override
  State<BrowseChallengesScreen> createState() => _BrowseChallengesScreenState();
}

class _BrowseChallengesScreenState extends State<BrowseChallengesScreen> {
  final ChallengeService _challengeService = ChallengeService();
  late Future<List<Challenge>> _allChallengesFuture;
  late Future<Set<String>> _joinedChallengeIdsFuture;
  final _supabase = Supabase.instance.client;

  @override
  void initState() {
    super.initState();
    _fetchChallengesAndJoinedChallenges();
  }

  void _fetchChallengesAndJoinedChallenges() {
    final userId = _supabase.auth.currentUser?.id;

    _allChallengesFuture = _challengeService.fetchAllChallenges();

    if (userId != null) {
      _joinedChallengeIdsFuture = _challengeService
          .fetchUserChallenges(userId)
          .then(
            (userChallenges) =>
                userChallenges.map((uc) => uc.challengeId).toSet(),
          );
    } else {
      _joinedChallengeIdsFuture = Future.value({});
    }
  }

  String _formatErrorMessage(dynamic error) {
    String errorMessage = error.toString();
    if (errorMessage.startsWith('Exception: ')) {
      return errorMessage.substring('Exception: '.length);
    }
    return errorMessage;
  }

  Future<void> _joinChallenge(Challenge challenge) async {
    if (_supabase.auth.currentUser == null) {
      if (mounted) {
        ToastManager.showInfoToast(
          context,
          'Prosimo, prijavite se za pridružitev izzivom.',
        );
      }
      return;
    }

    try {
      await _challengeService.joinChallenge(challenge.id);
      if (mounted) {
        ToastManager.showSuccessToast(
          context,
          'Uspešno ste se pridružili izzivu "${challenge.title}"!',
        );
        Navigator.pop(context, true);
      }
    } catch (e) {
      if (mounted) {
        ToastManager.showErrorToast(
          context,
          'Pridružitev izzivu ni uspela: ${_formatErrorMessage(e)}',
        );
        _fetchChallengesAndJoinedChallenges();
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Brskaj po izzivih'),
        centerTitle: true,
        backgroundColor: Colors.transparent,
        elevation: 0,
        foregroundColor: AppColors.charcoal,
      ),
      body: FutureBuilder<List<dynamic>>(
        future: Future.wait([_allChallengesFuture, _joinedChallengeIdsFuture]),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          } else if (snapshot.hasError) {
            return Center(
              child: Text(
                'Napaka pri nalaganju izzivov: ${_formatErrorMessage(snapshot.error)}',
              ),
            );
          } else {
            final List<Challenge> allChallenges =
                snapshot.data![0] as List<Challenge>;
            final Set<String> joinedChallengeIds =
                snapshot.data![1] as Set<String>;

            final List<Challenge> availableChallenges =
                allChallenges
                    .where(
                      (challenge) => !joinedChallengeIds.contains(challenge.id),
                    )
                    .toList();

            if (availableChallenges.isEmpty) {
              return const Center(
                child: Padding(
                  padding: EdgeInsets.all(16.0),
                  child: Text(
                    'Ni novih izzivov. Pridružili ste se vsem ali pa trenutno ni razpoložljivih izzivov.',
                    textAlign: TextAlign.center,
                    style: TextStyle(fontSize: 16, color: AppColors.dimGray),
                  ),
                ),
              );
            } else {
              return ListView.builder(
                padding: const EdgeInsets.all(16.0),
                itemCount: availableChallenges.length,
                itemBuilder: (context, index) {
                  final challenge = availableChallenges[index];
                  return Card(
                    margin: const EdgeInsets.only(bottom: 16.0),
                    elevation: 3,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Padding(
                      padding: const EdgeInsets.all(16.0),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            challenge.title,
                            style: const TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                              color: AppColors.charcoal,
                            ),
                          ),
                          const SizedBox(height: 8),
                          Text(
                            challenge.description,
                            style: const TextStyle(
                              fontSize: 14,
                              color: AppColors.dimGray,
                            ),
                          ),
                          const SizedBox(height: 8),
                          Text(
                            'Trajanje: ${challenge.durationDays} dni',
                            style: const TextStyle(
                              fontSize: 14,
                              fontStyle: FontStyle.italic,
                              color: AppColors.dimGray,
                            ),
                          ),
                          const SizedBox(height: 16),
                          Align(
                            alignment: Alignment.bottomRight,
                            child: ElevatedButton(
                              onPressed: () => _joinChallenge(challenge),
                              style: ElevatedButton.styleFrom(
                                backgroundColor: AppColors.leafGreen,
                                foregroundColor: AppColors.white,
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(8),
                                ),
                              ),
                              child: const Text('Pridruži se izzivu'),
                            ),
                          ),
                        ],
                      ),
                    ),
                  );
                },
              );
            }
          }
        },
      ),
    );
  }
}