import 'package:flutter/material.dart';
import 'package:dish_dash/colors/app_colors.dart';

class PrivacyScreen extends StatefulWidget {
  const PrivacyScreen({super.key});

  @override
  State<PrivacyScreen> createState() => _PrivacyScreenState();
}

class _PrivacyScreenState extends State<PrivacyScreen> {
  bool _isDataCollectionEnabled = true;
  bool _isPersonalizedAdsEnabled = false;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () {
            Navigator.pop(context);
          },
        ),
        title: SizedBox(
          height: 80,
          child: Center(
            child: Image.asset('assets/logo.png', height: 80),
          ), // Your app logo
        ),
        centerTitle: true,
        actions: const [
          SizedBox(width: 50), // To balance the back button and center the logo
        ],
        elevation: 0,
        backgroundColor: Colors.transparent,
        foregroundColor: AppColors.charcoal,
      ),
      body: SingleChildScrollView(
        // Use SingleChildScrollView for scrollability
        padding: const EdgeInsets.symmetric(horizontal: 20.0, vertical: 20.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Privacy Settings',
              style: TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
                color: AppColors.charcoal,
              ),
            ),
            const SizedBox(height: 30),
            // Option for Data Collection
            _buildPrivacyOption(
              title: 'Allow Data Collection',
              subtitle:
                  'Help us improve by allowing anonymous data collection. This data is used solely for app enhancement.',
              trailing: Switch(
                value: _isDataCollectionEnabled,
                onChanged: (bool value) {
                  setState(() {
                    _isDataCollectionEnabled = value;
                  });
                  // Here you would typically save the setting to SharedPreferences or a backend
                  _showSnackBar(
                    context,
                    'Data collection ' + (value ? 'enabled' : 'disabled'),
                  );
                },
                activeColor: AppColors.leafGreen,
                inactiveTrackColor: AppColors.leafGreen.withOpacity(0.5),
                inactiveThumbColor: AppColors.leafGreen,
              ),
            ),
            const SizedBox(height: 15),
            // Option for Personalized Ads
            /* _buildPrivacyOption(
              title: 'Personalized Advertisements',
              subtitle:
                  'Receive ads tailored to your interests based on your app usage. Turning this off will show generic ads.',
              trailing: Switch(
                value: _isPersonalizedAdsEnabled,
                onChanged: (bool value) {
                  setState(() {
                    _isPersonalizedAdsEnabled = value;
                  });
                  // Here you would typically save the setting
                  _showSnackBar(
                    context,
                    'Personalized ads ' + (value ? 'enabled' : 'disabled'),
                  );
                },
                activeColor: AppColors.leafGreen,
                inactiveTrackColor: AppColors.leafGreen.withOpacity(0.5),
                inactiveThumbColor: AppColors.leafGreen,
              ),
            ), */
            const SizedBox(height: 30),
            const Text(
              'Our Privacy Policy',
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: AppColors.charcoal,
              ),
            ),
            const SizedBox(height: 15),
            _buildPolicySection(
              title: '1. Information We Collect',
              content:
                  'We collect basic analytical data (e.g., app usage, crash reports) to improve app performance. We do NOT collect personally identifiable information such as your name, email, or precise location without your explicit consent.',
            ),
            const SizedBox(height: 10),
            _buildPolicySection(
              title: '2. How We Use Your Information',
              content:
                  'The data collected is used solely for internal analysis to enhance user experience, fix bugs, and develop new features. If personalized ads are enabled, data may be used to serve relevant advertisements.',
            ),
            const SizedBox(height: 10),
            _buildPolicySection(
              title: '3. Data Security',
              content:
                  'We implement industry-standard security measures to protect your data from unauthorized access, alteration, disclosure, or destruction. However, no internet transmission or electronic storage is 100% secure.',
            ),
            const SizedBox(height: 10),
            _buildPolicySection(
              title: '4. Third-Party Services',
              content:
                  'We may use third-party services (e.g., analytics providers, ad networks) that may collect information. These services have their own privacy policies, which we encourage you to review. We do not share your personal data with third parties for their marketing purposes without your consent.',
            ),
            const SizedBox(height: 10),
            _buildPolicySection(
              title: '5. Your Choices',
              content:
                  'You can manage your privacy settings within the app, including opting out of data collection and personalized ads, as shown above. You also have the right to request access to or deletion of any personal data we hold about you.',
            ),
            const SizedBox(height: 10),
            _buildPolicySection(
              title: '6. Changes to This Policy',
              content:
                  'We may update our Privacy Policy from time to time. We will notify you of any changes by posting the new Privacy Policy on this page. Your continued use of the app after such modifications will constitute your acknowledgment of the modified Policy and agreement to abide and be bound by the modified Policy.',
            ),
            const SizedBox(height: 10),
            _buildPolicySection(
              title: '7. Contact Us',
              content:
                  'If you have any questions or suggestions about our Privacy Policy, do not hesitate to contact us at support@dishdash.com.',
            ),
            const SizedBox(height: 30),
            Center(
              child: Text(
                'Last updated: June 3, 2025',
                style: TextStyle(
                  fontSize: 12,
                  color: AppColors.charcoal.withOpacity(0.6),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildPrivacyOption({
    required String title,
    required String subtitle,
    required Widget trailing,
  }) {
    return Container(
      decoration: BoxDecoration(
        color: AppColors.leafGreen,
        borderRadius: BorderRadius.circular(10),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.1),
            spreadRadius: 1,
            blurRadius: 3,
            offset: const Offset(0, 2), // changes position of shadow
          ),
        ],
      ),
      padding: const EdgeInsets.symmetric(horizontal: 15, vertical: 10),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: const TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.w600,
                    color: AppColors.charcoal,
                  ),
                ),
                const SizedBox(height: 5),
                Text(
                  subtitle,
                  style: TextStyle(
                    fontSize: 14,
                    color: AppColors.charcoal.withOpacity(0.7),
                  ),
                ),
              ],
            ),
          ),
          trailing,
        ],
      ),
    );
  }

  Widget _buildPolicySection({required String title, required String content}) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title,
          style: const TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w600,
            color: AppColors.charcoal,
          ),
        ),
        const SizedBox(height: 5),
        Text(
          content,
          style: TextStyle(
            fontSize: 14,
            color: AppColors.charcoal.withOpacity(0.8),
            height: 1.5,
          ),
        ),
      ],
    );
  }

  void _showSnackBar(BuildContext context, String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(message), duration: const Duration(seconds: 2)),
    );
  }
}
