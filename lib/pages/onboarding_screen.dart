import 'package:flutter/material.dart';
import 'package:dish_dash/colors/app_colors.dart';
import 'package:dish_dash/pages/auth/login_screen.dart';

class OnboardingScreen extends StatefulWidget {
  const OnboardingScreen({super.key});

  @override
  State<OnboardingScreen> createState() => _OnboardingScreenState();
}

class _OnboardingScreenState extends State<OnboardingScreen> {
  final PageController _pageController = PageController();
  int _currentPage = 0;

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  void _onPageChanged(int index) {
    setState(() {
      _currentPage = index;
    });
  }

  void _nextPage() {
    if (_currentPage < 2) {
      _pageController.nextPage(
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeIn,
      );
    } else {
      _navigateToLogin();
    }
  }

  void _navigateToLogin() {
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(builder: (context) => const LoginScreen()),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.softCream,
      body: Stack(
        children: [
          PageView(
            controller: _pageController,
            onPageChanged: _onPageChanged,
            children: [
              _buildOnboardingPage(
                imagePath: 'assets/images/onboarding_1.png',
                title: 'Izberi recept',
                description:
                    'Aplikacija ponuja nešteto zdravih in odličnih receptov, za vse težavnosti.',
              ),
              _buildOnboardingPage(
                imagePath: 'assets/images/onboarding_2.png',
                title: 'Shrani priljubljene',
                description:
                    'Z lahkoto shranite svoje najljubše recepte za hiter dostop in ustvarite osebno zbirko.',
              ),
              _buildOnboardingPage(
                imagePath: 'assets/images/onboarding_3.png',
                title: 'Deli in odkrij',
                description:
                    'Povežite se z drugimi, delite svoje kulinarične stvaritve in odkrijte nove ideje.',
              ),
            ],
          ),
          Positioned(
            top: MediaQuery.of(context).padding.top + 16,
            right: 16,
            child: GestureDetector(
              onTap: _navigateToLogin,
              child: const Icon(
                Icons.close,
                color: AppColors.charcoal,
                size: 28,
              ),
            ),
          ),
          Positioned(
            bottom: 40,
            left: 0,
            right: 0,
            child: Column(
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: List.generate(
                    3,
                    (index) => _buildDot(index: index),
                  ),
                ),
                const SizedBox(height: 30),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 20.0),
                  child: ElevatedButton(
                    onPressed: _nextPage,
                    child: Text(_currentPage == 2 ? 'Začnimo' : 'Nadaljuj'),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildOnboardingPage({
    required String imagePath,
    required String title,
    required String description,
  }) {
    return Padding(
      padding: const EdgeInsets.all(20.0),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Spacer(flex: 2), // Pushes content towards center-top
          Image.asset(
            imagePath,
            height:
                MediaQuery.of(context).size.height * 0.4, // Responsive height
            fit: BoxFit.contain,
          ),
          const SizedBox(height: 40),
          Text(
            title,
            style: const TextStyle(
              fontSize: 26,
              fontWeight: FontWeight.bold,
              color: AppColors.charcoal,
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 15),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20.0),
            child: Text(
              description,
              style: const TextStyle(fontSize: 16, color: AppColors.dimGray),
              textAlign: TextAlign.center,
            ),
          ),
          const Spacer(
            flex: 3,
          ), 
        ],
      ),
    );
  }

  Widget _buildDot({required int index}) {
    return AnimatedContainer(
      duration: const Duration(milliseconds: 300),
      margin: const EdgeInsets.symmetric(horizontal: 5.0),
      height: 10,
      width: _currentPage == index ? 24 : 10, 
      decoration: BoxDecoration(
        color: _currentPage == index ? AppColors.leafGreen : AppColors.paleGray,
        borderRadius: BorderRadius.circular(5),
      ),
    );
  }
}
