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
  final _supabase = Supabase.instance.client;

  @override
  void initState() {
    super.initState();
    _allChallengesFuture = _challengeService.fetchAllChallenges();
  }

  Future<void> _joinChallenge(Challenge challenge) async {
    if (_supabase.auth.currentUser == null) {
      if (mounted) {
        ToastManager.showInfoToast(context, 'Please log in to join challenges.');
      }
      return;
    }

    try {
      await _challengeService.joinChallenge(challenge.id);
      if (mounted) {
        ToastManager.showSuccessToast(
          context,
          'Successfully joined "${challenge.title}"!',
        );
        Navigator.pop(context, true); // Signal success back to previous screen
      }
    } catch (e) {
      if (mounted) {
        ToastManager.showErrorToast(
          context,
          'Failed to join challenge: ${e.toString()}',
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Browse Challenges'),
        centerTitle: true,
        backgroundColor: Colors.transparent,
        elevation: 0,
        foregroundColor: AppColors.charcoal,
      ),
      body: FutureBuilder<List<Challenge>>(
        future: _allChallengesFuture,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          } else if (snapshot.hasError) {
            return Center(child: Text('Error: ${snapshot.error}'));
          } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
            return const Center(child: Text('No new challenges available.'));
          } else {
            return ListView.builder(
              padding: const EdgeInsets.all(16.0),
              itemCount: snapshot.data!.length,
              itemBuilder: (context, index) {
                final challenge = snapshot.data![index];
                return Card(
                  margin: const EdgeInsets.only(bottom: 16.0),
                  elevation: 3,
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12)),
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
                          'Duration: ${challenge.durationDays} days',
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
                                  borderRadius: BorderRadius.circular(8)),
                            ),
                            child: const Text('Join Challenge'),
                          ),
                        ),
                      ],
                    ),
                  ),
                );
              },
            );
          }
        },
      ),
    );
  }
}