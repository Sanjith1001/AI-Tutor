import 'package:flutter/material.dart';
import '../themes/index.dart';

class PrivacySettingsScreen extends StatefulWidget {
  const PrivacySettingsScreen({super.key});

  @override
  State<PrivacySettingsScreen> createState() => _PrivacySettingsScreenState();
}

class _PrivacySettingsScreenState extends State<PrivacySettingsScreen> {
  bool _profileVisibility = true;
  bool _activityTracking = true;
  bool _dataCollection = false;
  bool _analyticsSharing = false;
  bool _marketingEmails = false;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: const Text('Privacy Settings'),
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
              'Control your privacy and data preferences',
              style: AppTypography.bodyMedium.copyWith(
                color: AppColors.textSecondary,
              ),
            ),
            const SizedBox(height: 24),

            // Profile Privacy Section
            _buildSectionCard(
              title: 'Profile Privacy',
              subtitle: 'Control who can see your profile information',
              children: [
                _buildSwitchTile(
                  title: 'Public Profile',
                  subtitle: 'Allow others to view your learning profile',
                  value: _profileVisibility,
                  onChanged: (value) =>
                      setState(() => _profileVisibility = value),
                ),
              ],
            ),

            const SizedBox(height: 20),

            // Data & Analytics Section
            _buildSectionCard(
              title: 'Data & Analytics',
              subtitle: 'Manage how your data is used',
              children: [
                _buildSwitchTile(
                  title: 'Activity Tracking',
                  subtitle: 'Track your learning progress and activities',
                  value: _activityTracking,
                  onChanged: (value) =>
                      setState(() => _activityTracking = value),
                ),
                _buildSwitchTile(
                  title: 'Data Collection',
                  subtitle:
                      'Allow collection of usage data for app improvement',
                  value: _dataCollection,
                  onChanged: (value) => setState(() => _dataCollection = value),
                ),
                _buildSwitchTile(
                  title: 'Analytics Sharing',
                  subtitle: 'Share anonymized analytics with third parties',
                  value: _analyticsSharing,
                  onChanged: (value) =>
                      setState(() => _analyticsSharing = value),
                ),
              ],
            ),

            const SizedBox(height: 20),

            // Marketing Section
            _buildSectionCard(
              title: 'Marketing',
              subtitle: 'Control marketing communications',
              children: [
                _buildSwitchTile(
                  title: 'Marketing Emails',
                  subtitle: 'Receive promotional emails and offers',
                  value: _marketingEmails,
                  onChanged: (value) =>
                      setState(() => _marketingEmails = value),
                ),
              ],
            ),

            const SizedBox(height: 20),

            // Data Management Section
            _buildSectionCard(
              title: 'Data Management',
              subtitle: 'Manage your personal data',
              children: [
                _buildActionTile(
                  title: 'Download My Data',
                  subtitle: 'Get a copy of all your data',
                  icon: Icons.download,
                  onTap: _downloadData,
                ),
                _buildActionTile(
                  title: 'Delete Account',
                  subtitle: 'Permanently delete your account and data',
                  icon: Icons.delete_forever,
                  onTap: _showDeleteAccountDialog,
                  isDestructive: true,
                ),
              ],
            ),

            const SizedBox(height: 32),

            // Save Button
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: _saveSettings,
                style: AuthScreenStyles.primaryButtonStyle,
                child: const Text('Save Settings'),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSectionCard({
    required String title,
    required String subtitle,
    required List<Widget> children,
  }) {
    return Container(
      padding: CommonStyles.largePadding,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: CommonStyles.mediumBorderRadius,
        boxShadow: CommonStyles.cardShadow,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: AppTypography.titleMedium.copyWith(
              color: AppColors.textPrimary,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            subtitle,
            style: AppTypography.bodySmall.copyWith(
              color: AppColors.textSecondary,
            ),
          ),
          const SizedBox(height: 16),
          ...children,
        ],
      ),
    );
  }

  Widget _buildSwitchTile({
    required String title,
    required String subtitle,
    required bool value,
    required ValueChanged<bool> onChanged,
  }) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: AppTypography.bodyMedium.copyWith(
                    color: AppColors.textPrimary,
                    fontWeight: FontWeight.w500,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  subtitle,
                  style: AppTypography.bodySmall.copyWith(
                    color: AppColors.textSecondary,
                  ),
                ),
              ],
            ),
          ),
          Switch(
            value: value,
            onChanged: onChanged,
            activeThumbColor: AppColors.primary,
          ),
        ],
      ),
    );
  }

  Widget _buildActionTile({
    required String title,
    required String subtitle,
    required IconData icon,
    required VoidCallback onTap,
    bool isDestructive = false,
  }) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: InkWell(
        onTap: onTap,
        borderRadius: CommonStyles.smallBorderRadius,
        child: Padding(
          padding: const EdgeInsets.all(8),
          child: Row(
            children: [
              Icon(
                icon,
                color: isDestructive ? AppColors.error : AppColors.primary,
                size: 24,
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      style: AppTypography.bodyMedium.copyWith(
                        color: isDestructive
                            ? AppColors.error
                            : AppColors.textPrimary,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      subtitle,
                      style: AppTypography.bodySmall.copyWith(
                        color: AppColors.textSecondary,
                      ),
                    ),
                  ],
                ),
              ),
              Icon(
                Icons.arrow_forward_ios,
                color: AppColors.textTertiary,
                size: 16,
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _downloadData() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Download Data'),
        content: const Text(
            'Your data will be prepared and sent to your email address within 24 hours.'),
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
                    'Data download request submitted!'),
              );
            },
            child: const Text('Request Download'),
          ),
        ],
      ),
    );
  }

  void _showDeleteAccountDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Delete Account'),
        content: const Text(
          'Are you sure you want to delete your account? This action cannot be undone and all your data will be permanently removed.',
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
                CommonStyles.errorSnackBar(
                    'Account deletion is not available in demo mode'),
              );
            },
            style: ElevatedButton.styleFrom(backgroundColor: AppColors.error),
            child: const Text('Delete Account'),
          ),
        ],
      ),
    );
  }

  void _saveSettings() {
    ScaffoldMessenger.of(context).showSnackBar(
      CommonStyles.successSnackBar('Privacy settings saved!'),
    );
  }
}
