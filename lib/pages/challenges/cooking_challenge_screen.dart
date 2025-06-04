import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:dish_dash/colors/app_colors.dart';
import 'package:dish_dash/models/user_challenge.dart';
import 'package:dish_dash/services/challenge_service.dart';
import 'package:dish_dash/pages/challenges/browse_challenges_screen.dart';
import 'package:dish_dash/helpers/toast_manager.dart';

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
            valueColor: const AlwaysStoppedAnimation<Color>(
              AppColors.leafGreen,
            ),
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
      setState(() {
        _userChallengesFuture = Future.value([]);
      });
      if (mounted) {
        ToastManager.showInfoToast(context, 'Za ogled izzivov se prijavite.');
      }
    }
  }

  String _formatErrorMessage(dynamic error) {
    String errorMessage = error.toString();
    if (errorMessage.startsWith('Exception: ')) {
      return errorMessage.substring('Exception: '.length);
    }
    return errorMessage;
  }

  Future<void> _markDayComplete(UserChallenge userChallenge) async {
    try {
      await _challengeService.markDayComplete(userChallenge);
      if (mounted) {
        ToastManager.showSuccessToast(
          context,
          'Dan ${userChallenge.currentDay + 1} v izzivu "${userChallenge.challenge?.title}" označen kot dokončan!',
        );
        _fetchUserChallenges();
      }
    } catch (e) {
      if (mounted) {
        ToastManager.showErrorToast(
          context,
          'Označevanje dneva ni uspelo: ${_formatErrorMessage(e)}',
        );
      }
    }
  }

  Future<void> _leaveChallenge(UserChallenge userChallenge) async {
    try {
      await _challengeService.leaveChallenge(userChallenge.id);
      if (mounted) {
        ToastManager.showSuccessToast(
          context,
          'Uspešno ste zapustili izziv "${userChallenge.challenge?.title ?? 'izziv'}"!',
        );
        _fetchUserChallenges();
      }
    } catch (e) {
      if (mounted) {
        ToastManager.showErrorToast(
          context,
          'Zapustitev izziva ni uspela: ${_formatErrorMessage(e)}',
        );
        _fetchUserChallenges();
      }
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

  void _navigateToBrowseChallenges() async {
    final bool? challengeJoined = await Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => const BrowseChallengesScreen()),
    );

    if (challengeJoined == true) {
      _fetchUserChallenges();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Kuharski izziv'),
        centerTitle: true,
        backgroundColor: Colors.transparent,
        elevation: 0,
        foregroundColor: AppColors.charcoal,
        actions: const [],
      ),
      body: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16.0),
        child: FutureBuilder<List<UserChallenge>>(
          future: _userChallengesFuture,
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return const Center(child: CircularProgressIndicator());
            } else if (snapshot.hasError) {
              if (snapshot.connectionState != ConnectionState.done ||
                  !snapshot.hasData ||
                  snapshot.data!.isEmpty) {
                ToastManager.showErrorToast(
                  context,
                  'Napaka pri nalaganju izzivov: ${_formatErrorMessage(snapshot.error)}',
                );
              }
              return Center(
                child: Text('Napaka: ${_formatErrorMessage(snapshot.error)}'),
              );
            } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
              return Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Text(
                      'Ni aktivnih izzivov. Pridružite se enemu!',
                      textAlign: TextAlign.center,
                      style: TextStyle(fontSize: 16, color: AppColors.dimGray),
                    ),
                    const SizedBox(height: 20),
                    ElevatedButton.icon(
                      onPressed: _navigateToBrowseChallenges,
                      icon: const Icon(Icons.add_circle_outline),
                      label: const Text('Najdi nove izzive'),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppColors.leafGreen,
                        foregroundColor: AppColors.white,
                        padding: const EdgeInsets.symmetric(
                          horizontal: 20,
                          vertical: 12,
                        ),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(10),
                        ),
                      ),
                    ),
                  ],
                ),
              );
            } else {
              final List<UserChallenge> userChallenges = snapshot.data!;
              final double overallProgress = _calculateOverallProgress(
                userChallenges,
              );

              return Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  OverallCookingProgressBar(progress: overallProgress),
                  Expanded(
                    child: ListView.builder(
                      itemCount: userChallenges.length,
                      itemBuilder: (context, index) {
                        final userChallenge = userChallenges[index];
                        final challengeTitle =
                            userChallenge.challenge?.title ?? 'Neznan izziv';
                        final totalDays = userChallenge.durationDays;
                        final currentDay = userChallenge.currentDay;
                        final progress =
                            totalDays > 0
                                ? (currentDay / totalDays).clamp(0.0, 1.0)
                                : 0.0;

                        return Dismissible(
                          key: ValueKey(userChallenge.id),
                          direction: DismissDirection.endToStart,
                          background: Container(
                            alignment: Alignment.centerRight,
                            padding: const EdgeInsets.symmetric(horizontal: 20),
                            color: Colors.red,
                            child: const Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Icon(
                                  Icons.exit_to_app,
                                  color: Colors.white,
                                  size: 30,
                                ),
                                SizedBox(height: 4),
                                Text(
                                  'Zapusti',
                                  style: TextStyle(
                                    color: Colors.white,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ],
                            ),
                          ),
                          confirmDismiss: (direction) async {
                            return await showDialog(
                              context: context,
                              builder: (BuildContext context) {
                                return AlertDialog(
                                  title: const Text('Potrditev'),
                                  content: Text(
                                    'Ali ste prepričani, da želite zapustiti "${challengeTitle}"? To dejanje ni mogoče razveljaviti.',
                                  ),
                                  actions: <Widget>[
                                    TextButton(
                                      onPressed:
                                          () =>
                                              Navigator.of(context).pop(false),
                                      child: const Text('Prekliči'),
                                    ),
                                    ElevatedButton(
                                      onPressed:
                                          () => Navigator.of(context).pop(true),
                                      style: ElevatedButton.styleFrom(
                                        backgroundColor: Colors.red,
                                        foregroundColor: Colors.white,
                                      ),
                                      child: const Text('Zapusti'),
                                    ),
                                  ],
                                );
                              },
                            );
                          },
                          onDismissed: (direction) {
                            _leaveChallenge(userChallenge);
                          },
                          child: Card(
                            margin: const EdgeInsets.symmetric(vertical: 8.0),
                            elevation: 2,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: Padding(
                              padding: const EdgeInsets.all(16.0),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Row(
                                    children: [
                                      Expanded(
                                        child: Column(
                                          crossAxisAlignment:
                                              CrossAxisAlignment.start,
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
                                                  ? 'Zaključeno!'
                                                  : 'Dan $currentDay od $totalDays',
                                              style: TextStyle(
                                                fontSize: 14,
                                                color:
                                                    userChallenge.isCompleted
                                                        ? AppColors.leafGreen
                                                        : AppColors.dimGray,
                                                fontWeight:
                                                    userChallenge.isCompleted
                                                        ? FontWeight.bold
                                                        : FontWeight.normal,
                                              ),
                                            ),
                                          ],
                                        ),
                                      ),
                                      const SizedBox(width: 10),
                                      SizedBox(
                                        width: 40,
                                        height: 40,
                                        child: CircularProgressIndicator(
                                          value: progress,
                                          backgroundColor: AppColors.paleGray,
                                          valueColor:
                                              AlwaysStoppedAnimation<Color>(
                                                AppColors.leafGreen,
                                              ),
                                          strokeWidth: 5,
                                        ),
                                      ),
                                    ],
                                  ),
                                  const SizedBox(height: 12),
                                  if (!userChallenge.isCompleted &&
                                      userChallenge.currentDay < totalDays)
                                    Align(
                                      alignment: Alignment.bottomRight,
                                      child: ElevatedButton(
                                        onPressed:
                                            () =>
                                                _markDayComplete(userChallenge),
                                        style: ElevatedButton.styleFrom(
                                          backgroundColor: AppColors.leafGreen,
                                          foregroundColor: AppColors.white,
                                          shape: RoundedRectangleBorder(
                                            borderRadius: BorderRadius.circular(
                                              8,
                                            ),
                                          ),
                                        ),
                                        child: const Text(
                                          'Označi dan kot zaključen',
                                        ),
                                      ),
                                    )
                                  else if (userChallenge.isCompleted)
                                    const Align(
                                      alignment: Alignment.bottomRight,
                                      child: Padding(
                                        padding: EdgeInsets.only(top: 8.0),
                                        child: Text(
                                          'Izziv zaključen!',
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
                          ),
                        );
                      },
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.symmetric(vertical: 20.0),
                    child: Center(
                      child: ElevatedButton.icon(
                        onPressed: _navigateToBrowseChallenges,
                        icon: const Icon(Icons.add_circle_outline),
                        label: const Text('Najdi več izzivov'),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: AppColors.leafGreen,
                          foregroundColor: AppColors.white,
                          padding: const EdgeInsets.symmetric(
                            horizontal: 24,
                            vertical: 14,
                          ),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                          textStyle: const TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
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