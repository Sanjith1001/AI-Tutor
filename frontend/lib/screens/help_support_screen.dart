import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';
import '../themes/index.dart';

class HelpSupportScreen extends StatelessWidget {
  const HelpSupportScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      backgroundColor: isDark ? AppColors.darkBackground : AppColors.background,
      appBar: AppBar(
        title: const Text('Help & Support'),
        backgroundColor: AppColors.primary,
        foregroundColor: Colors.white,
        elevation: 0,
      ),
      body: SingleChildScrollView(
        padding: CommonStyles.extraLargePadding,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'We\'re here to help you succeed in your learning journey',
              style: AppTypography.bodyMedium.copyWith(
                color: isDark ? AppColors.darkTextSecondary : AppColors.textSecondary,
              ),
            ),
            const SizedBox(height: 24),

            // Quick Help Section
            _buildSectionCard(
              title: 'Quick Help',
              children: [
                _buildHelpTile(
                  title: 'Getting Started Guide',
                  subtitle: 'Learn how to use ByteBrain effectively',
                  icon: Icons.play_circle_outline,
                  onTap: () => _showGettingStarted(context),
                ),
                _buildHelpTile(
                  title: 'Frequently Asked Questions',
                  subtitle: 'Find answers to common questions',
                  icon: Icons.help_outline,
                  onTap: () => _showFAQ(context),
                ),
                _buildHelpTile(
                  title: 'Learning Tips',
                  subtitle: 'Maximize your learning potential',
                  icon: Icons.lightbulb_outline,
                  onTap: () => _showLearningTips(context),
                ),
              ],
            ),

            const SizedBox(height: 20),

            // Contact Support Section
            _buildSectionCard(
              title: 'Contact Support',
              children: [
                _buildHelpTile(
                  title: 'Send Feedback',
                  subtitle: 'Share your thoughts and suggestions',
                  icon: Icons.feedback_outlined,
                  onTap: () => _sendFeedback(context),
                ),
                _buildHelpTile(
                  title: 'Report a Bug',
                  subtitle: 'Help us improve the app',
                  icon: Icons.bug_report_outlined,
                  onTap: () => _reportBug(context),
                ),
                _buildHelpTile(
                  title: 'Email Support',
                  subtitle: 'support@bytebrain.com',
                  icon: Icons.email_outlined,
                  onTap: () => _launchEmail(),
                ),
              ],
            ),

            const SizedBox(height: 20),

            // App Information Section
            _buildSectionCard(
              title: 'App Information',
              children: [
                _buildInfoTile('Version', '1.0.0'),
                _buildInfoTile('Last Updated', 'October 2024'),
                _buildInfoTile('Platform', 'Flutter'),
              ],
            ),

            const SizedBox(height: 20),

            // Legal Section
            _buildSectionCard(
              title: 'Legal',
              children: [
                _buildHelpTile(
                  title: 'Terms of Service',
                  subtitle: 'Read our terms and conditions',
                  icon: Icons.description_outlined,
                  onTap: () => _showTerms(context),
                ),
                _buildHelpTile(
                  title: 'Privacy Policy',
                  subtitle: 'Learn how we protect your data',
                  icon: Icons.privacy_tip_outlined,
                  onTap: () => _showPrivacyPolicy(context),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSectionCard({
    required String title,
    required List<Widget> children,
  }) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Container(
      padding: CommonStyles.largePadding,
      decoration: BoxDecoration(
        color: isDark ? AppColors.darkSurface : Colors.white,
        borderRadius: CommonStyles.mediumBorderRadius,
        boxShadow: CommonStyles.cardShadow,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: AppTypography.titleMedium.copyWith(
              color: isDark ? AppColors.darkTextPrimary : AppColors.textPrimary,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 16),
          ...children,
        ],
      ),
    );
  }

  Widget _buildHelpTile({
    required String title,
    required String subtitle,
    required IconData icon,
    required VoidCallback onTap,
  }) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return InkWell(
      onTap: onTap,
      borderRadius: CommonStyles.smallBorderRadius,
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 8),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: AppColors.primary.withValues(alpha: 0.1),
                borderRadius: CommonStyles.smallBorderRadius,
              ),
              child: Icon(
                icon,
                color: AppColors.primary,
                size: 20,
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: AppTypography.bodyMedium.copyWith(
                      color: isDark ? AppColors.darkTextPrimary : AppColors.textPrimary,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    subtitle,
                    style: AppTypography.bodySmall.copyWith(
                      color: isDark ? AppColors.darkTextSecondary : AppColors.textSecondary,
                    ),
                  ),
                ],
              ),
            ),
            Icon(
              Icons.arrow_forward_ios,
              color: isDark ? AppColors.darkTextTertiary : AppColors.textTertiary,
              size: 16,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildInfoTile(String label, String value) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            label,
            style: AppTypography.bodyMedium.copyWith(
              color: isDark ? AppColors.darkTextPrimary : AppColors.textPrimary,
              fontWeight: FontWeight.w500,
            ),
          ),
          Text(
            value,
            style: AppTypography.bodyMedium.copyWith(
              color: isDark ? AppColors.darkTextSecondary : AppColors.textSecondary,
            ),
          ),
        ],
      ),
    );
  }

  void _showGettingStarted(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Getting Started'),
        content: const SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              Text('Welcome to ByteBrain! Here\'s how to get started:'),
              SizedBox(height: 16),
              Text(
                  '1. Complete the VARK assessment to determine your learning style'),
              SizedBox(height: 8),
              Text('2. Take the skill assessment to gauge your current level'),
              SizedBox(height: 8),
              Text(
                  '3. Generate AI-powered courses tailored to your preferences'),
              SizedBox(height: 8),
              Text('4. Track your progress on the dashboard'),
              SizedBox(height: 8),
              Text('5. Continue learning and achieve your goals!'),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Got it!'),
          ),
        ],
      ),
    );
  }

  void _showFAQ(BuildContext context) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => const FAQScreen(),
      ),
    );
  }

  void _showLearningTips(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Learning Tips'),
        content: const SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              Text('💡 Set aside dedicated time for learning each day'),
              SizedBox(height: 8),
              Text('📝 Take notes while studying to improve retention'),
              SizedBox(height: 8),
              Text('🎯 Set specific, achievable learning goals'),
              SizedBox(height: 8),
              Text('🔄 Review material regularly to reinforce learning'),
              SizedBox(height: 8),
              Text('👥 Join study groups or find learning partners'),
              SizedBox(height: 8),
              Text('🎉 Celebrate your progress and achievements'),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Thanks!'),
          ),
        ],
      ),
    );
  }

  void _sendFeedback(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Send Feedback'),
        content: const TextField(
          maxLines: 4,
          decoration: InputDecoration(
            hintText: 'Share your thoughts and suggestions...',
            border: OutlineInputBorder(),
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(context);
              ScaffoldMessenger.of(context).showSnackBar(
                CommonStyles.successSnackBar('Thank you for your feedback!'),
              );
            },
            child: const Text('Send'),
          ),
        ],
      ),
    );
  }

  void _reportBug(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Report a Bug'),
        content: const TextField(
          maxLines: 4,
          decoration: InputDecoration(
            hintText: 'Describe the issue you encountered...',
            border: OutlineInputBorder(),
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(context);
              ScaffoldMessenger.of(context).showSnackBar(
                CommonStyles.successSnackBar(
                    'Bug report submitted. Thank you!'),
              );
            },
            child: const Text('Submit'),
          ),
        ],
      ),
    );
  }

  void _launchEmail() async {
    final Uri emailUri = Uri(
      scheme: 'mailto',
      path: 'support@bytebrain.com',
      query: 'subject=ByteBrain Support Request',
    );

    if (await canLaunchUrl(emailUri)) {
      await launchUrl(emailUri);
    }
  }

  void _showTerms(BuildContext context) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => const LegalDocumentScreen(
          title: 'Terms of Service',
          content: 'Terms of Service content would go here...',
        ),
      ),
    );
  }

  void _showPrivacyPolicy(BuildContext context) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => const LegalDocumentScreen(
          title: 'Privacy Policy',
          content: 'Privacy Policy content would go here...',
        ),
      ),
    );
  }
}

class FAQScreen extends StatelessWidget {
  const FAQScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final faqs = [
      {
        'question': 'How do I take the VARK assessment?',
        'answer':
            'Go to the home screen and look for the VARK assessment card. Tap "Start Assessment" to begin the quiz that will determine your learning style.',
      },
      {
        'question': 'Can I retake assessments?',
        'answer':
            'Yes! You can retake both the VARK and skill assessments at any time from the profile screen.',
      },
      {
        'question': 'How are courses generated?',
        'answer':
            'Our AI uses your learning style, skill level, and preferences to create personalized courses tailored specifically for you.',
      },
      {
        'question': 'Is my data secure?',
        'answer':
            'Yes, we take data security seriously. All your personal information and learning data is encrypted and stored securely.',
      },
      {
        'question': 'Can I use the app offline?',
        'answer':
            'Some features work offline, but you\'ll need an internet connection to generate new courses and sync your progress.',
      },
    ];

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: const Text('FAQ'),
        backgroundColor: AppColors.primary,
        foregroundColor: Colors.white,
      ),
      body: ListView.builder(
        padding: CommonStyles.extraLargePadding,
        itemCount: faqs.length,
        itemBuilder: (context, index) {
          final faq = faqs[index];
          return Card(
            margin: const EdgeInsets.only(bottom: 12),
            child: ExpansionTile(
              title: Text(
                faq['question']!,
                style: AppTypography.bodyMedium.copyWith(
                  fontWeight: FontWeight.w600,
                ),
              ),
              children: [
                Padding(
                  padding: CommonStyles.largePadding,
                  child: Text(
                    faq['answer']!,
                    style: AppTypography.bodyMedium.copyWith(
                      color: AppColors.textSecondary,
                    ),
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}

class LegalDocumentScreen extends StatelessWidget {
  final String title;
  final String content;

  const LegalDocumentScreen({
    super.key,
    required this.title,
    required this.content,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: Text(title),
        backgroundColor: AppColors.primary,
        foregroundColor: Colors.white,
      ),
      body: SingleChildScrollView(
        padding: CommonStyles.extraLargePadding,
        child: Text(
          content,
          style: AppTypography.bodyMedium,
        ),
      ),
    );
  }
}
