// lib/pages/challenges/cooking_challenge_screen.dart
import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:dish_dash/colors/app_colors.dart';
import 'package:dish_dash/models/user_challenge.dart';
import 'package:dish_dash/services/challenge_service.dart';
import 'package:dish_dash/pages/challenges/browse_challenges_screen.dart';
import 'package:dish_dash/helpers/toast_manager.dart'; // <--- ADD THIS IMPORT

// This widget can be put in a separate 'widgets' folder if preferred for reusability
// For now, it's defined here.
class OverallCookingProgressBar extends StatelessWidget {
  final double progress;
  final String title;

  const OverallCookingProgressBar({
    super.key,
    required this.progress,
    this.title = 'Kuharski izziv',
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title,
          style: const TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
              color: AppColors.charcoal),
        ),
        const SizedBox(height: 12),
        ClipRRect(
          borderRadius: BorderRadius.circular(15), // Larger border radius
          child: LinearProgressIndicator(
            value: progress,
            minHeight: 25, // Taller progress bar
            backgroundColor: AppColors.paleGray, // Lighter background
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
        const SizedBox(height: 16), // Space before challenge list
      ],
    );
  }
}

class CookingChallengeScreen extends StatefulWidget {
  const CookingChallengeScreen({super.key});

  @override
  State<CookingChallengeScreen> createState() => _CookingChallengeScreenState();
}

class _CookingChallengeScreenState extends State<CookingChallengeScreen> {
  final ChallengeService _challengeService = ChallengeService();
  late Future<List<UserChallenge>> _userChallengesFuture;
  final _supabase = Supabase.instance.client;

  @override
  void initState() {
    super.initState();
    _fetchUserChallenges();
  }

  void _fetchUserChallenges() {
    final userId = _supabase.auth.currentUser?.id;
    if (userId != null) {
      setState(() {
        _userChallengesFuture = _challengeService.fetchUserChallenges(userId);
      });
    } else {
      // Handle not logged in state, perhaps redirect to login or show an empty state
      setState(() {
        _userChallengesFuture = Future.value([]); // Return an empty list
      });
      // Using ToastManager for user-facing message
      if (mounted) {
        ToastManager.showInfoToast(context, 'Please log in to view challenges.');
      }
    }
  }

  Future<void> _markDayComplete(UserChallenge userChallenge) async {
    try {
      await _challengeService.markDayComplete(userChallenge);
      if (mounted) {
        // Replaced ScaffoldMessenger with ToastManager for success notification
        ToastManager.showSuccessToast(
          context,
          'Day ${userChallenge.currentDay + 1} of "${userChallenge.challenge?.title}" marked complete!',
        );
        _fetchUserChallenges(); // Refresh the list after update
      }
    } catch (e) {
      if (mounted) {
        // Replaced ScaffoldMessenger with ToastManager for error notification
        ToastManager.showErrorToast(
          context,
          'Failed to mark day complete: ${e.toString()}',
        );
      }
    }
  }

  // Helper to calculate overall progress from all user challenges
  double _calculateOverallProgress(List<UserChallenge> challenges) {
    if (challenges.isEmpty) return 0.0;

    int totalPossibleDays = 0;
    int totalCompletedDays = 0;

    for (var uc in challenges) {
      // Consider all challenges (active and completed) for the overall bar
      if (uc.challenge != null) {
        totalPossibleDays += uc.durationDays;
        totalCompletedDays += uc.currentDay;
      }
    }

    if (totalPossibleDays == 0) return 0.0;
    return totalCompletedDays / totalPossibleDays;
  }

  // Method to navigate to the browse challenges screen
  void _navigateToBrowseChallenges() async {
    // Navigator.push returns a Future that completes when the pushed route is popped.
    // We can use its result to check if a challenge was joined and then refresh.
    final bool? challengeJoined = await Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => const BrowseChallengesScreen()),
    );

    // If challengeJoined is true, it means a challenge was successfully joined
    // on the BrowseChallengesScreen, so we should refresh the current screen.
    if (challengeJoined == true) {
      _fetchUserChallenges(); // Refresh challenges if a new one was joined
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Kuharski izziv'), // App bar title for this screen
        centerTitle: true,
        backgroundColor: Colors.transparent, // Match your app bar style
        elevation: 0,
        foregroundColor: AppColors.charcoal, // Match your app bar style
        actions: [
          // Add a button to browse challenges even if some are active
          IconButton(
            icon: const Icon(Icons.add_circle_outline),
            tooltip: 'Browse New Challenges', // Accessibility text
            onPressed: _navigateToBrowseChallenges,
          ),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16.0),
        child: FutureBuilder<List<UserChallenge>>(
          future: _userChallengesFuture,
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return const Center(child: CircularProgressIndicator());
            } else if (snapshot.hasError) {
              // Using ToastManager for error notification
              if (snapshot.connectionState != ConnectionState.done || !snapshot.hasData || snapshot.data!.isEmpty) {
                 ToastManager.showErrorToast(context, 'Failed to load challenges: ${snapshot.error}');
              }
              return Center(child: Text('Error: ${snapshot.error}'));
            } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
              // Display when no active challenges are found for the user
              return Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Text(
                      'No active challenges. Join one now!',
                      textAlign: TextAlign.center,
                      style: TextStyle(fontSize: 16, color: AppColors.dimGray),
                    ),
                    const SizedBox(height: 20),
                    ElevatedButton.icon(
                      onPressed: _navigateToBrowseChallenges, // Navigate to browse screen
                      icon: const Icon(Icons.add_circle_outline),
                      label: const Text('Find New Challenges'),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppColors.leafGreen,
                        foregroundColor: AppColors.white,
                        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                      ),
                    ),
                  ],
                ),
              );
            } else {
              // Display active challenges and overall progress
              final List<UserChallenge> userChallenges = snapshot.data!;
              final double overallProgress = _calculateOverallProgress(userChallenges);

              return Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  OverallCookingProgressBar(progress: overallProgress), // Overall progress bar at the top
                  Expanded(
                    child: ListView.builder(
                      itemCount: userChallenges.length,
                      itemBuilder: (context, index) {
                        final userChallenge = userChallenges[index];
                        final challengeTitle =
                            userChallenge.challenge?.title ?? 'Unknown Challenge';
                        final totalDays = userChallenge.durationDays;
                        final currentDay = userChallenge.currentDay;
                        // Calculate individual challenge progress, clamping to avoid >100%
                        final progress = totalDays > 0 ? (currentDay / totalDays).clamp(0.0, 1.0) : 0.0;

                        return Card(
                          margin: const EdgeInsets.symmetric(vertical: 8.0),
                          elevation: 2,
                          shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12)),
                          child: Padding(
                            padding: const EdgeInsets.all(16.0),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Row(
                                  children: [
                                    Expanded(
                                      child: Column(
                                        crossAxisAlignment: CrossAxisAlignment.start,
                                        children: [
                                          Text(
                                            challengeTitle,
                                            style: const TextStyle(
                                              fontSize: 16,
                                              fontWeight: FontWeight.bold,
                                              color: AppColors.charcoal,
                                            ),
                                          ),
                                          const SizedBox(height: 4),
                                          Text(
                                            userChallenge.isCompleted
                                                ? 'Completed!'
                                                : 'Day $currentDay of $totalDays',
                                            style: TextStyle(
                                              fontSize: 14,
                                              color: userChallenge.isCompleted ? AppColors.leafGreen : AppColors.dimGray,
                                              fontWeight: userChallenge.isCompleted ? FontWeight.bold : FontWeight.normal,
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                    const SizedBox(width: 10),
                                    // Circular progress indicator for individual challenge
                                    SizedBox(
                                      width: 40,
                                      height: 40,
                                      child: CircularProgressIndicator(
                                        value: progress,
                                        backgroundColor: AppColors.paleGray,
                                        valueColor: AlwaysStoppedAnimation<Color>(
                                          userChallenge.isCompleted ? AppColors.leafGreen : AppColors.leafGreen,
                                        ),
                                        strokeWidth: 5,
                                      ),
                                    ),
                                  ],
                                ),
                                const SizedBox(height: 12),
                                // Mark Day Complete Button (only visible if not completed)
                                if (!userChallenge.isCompleted && userChallenge.currentDay < totalDays)
                                  Align(
                                    alignment: Alignment.bottomRight,
                                    child: ElevatedButton(
                                      onPressed: () => _markDayComplete(userChallenge),
                                      style: ElevatedButton.styleFrom(
                                        backgroundColor: AppColors.leafGreen,
                                        foregroundColor: AppColors.white,
                                        shape: RoundedRectangleBorder(
                                            borderRadius:
                                                BorderRadius.circular(8)),
                                      ),
                                      child: const Text('Mark Day Complete'),
                                    ),
                                  )
                                else if (userChallenge.isCompleted)
                                  // Message when challenge is completed
                                  const Align(
                                    alignment: Alignment.bottomRight,
                                    child: Padding(
                                      padding: EdgeInsets.only(top: 8.0),
                                      child: Text(
                                        'Challenge Completed!',
                                        style: TextStyle(
                                          color: AppColors.leafGreen,
                                          fontWeight: FontWeight.bold,
                                        ),
                                      ),
                                    ),
                                  ),
                              ],
                            ),
                          ),
                        );
                      },
                    ),
                  ),
                ],
              );
            }
          },
        ),
      ),
    );
  }
}