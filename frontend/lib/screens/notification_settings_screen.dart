import 'package:flutter/material.dart';
import '../themes/index.dart';

class NotificationSettingsScreen extends StatefulWidget {
  const NotificationSettingsScreen({super.key});

  @override
  State<NotificationSettingsScreen> createState() =>
      _NotificationSettingsScreenState();
}

class _NotificationSettingsScreenState
    extends State<NotificationSettingsScreen> {
  bool _pushNotifications = true;
  bool _emailNotifications = true;
  bool _courseReminders = true;
  bool _achievementAlerts = true;
  bool _weeklyProgress = false;
  bool _newContentAlerts = true;

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      backgroundColor: isDark ? AppColors.darkBackground : AppColors.background,
      appBar: AppBar(
        title: const Text('Notification Settings'),
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
              'Manage your notification preferences',
              style: AppTypography.bodyMedium.copyWith(
                color: isDark ? AppColors.darkTextSecondary : AppColors.textSecondary,
              ),
            ),
            const SizedBox(height: 24),

            // Push Notifications Section
            _buildSectionCard(
              title: 'Push Notifications',
              subtitle: 'Receive notifications on your device',
              children: [
                _buildSwitchTile(
                  title: 'Enable Push Notifications',
                  subtitle: 'Allow the app to send push notifications',
                  value: _pushNotifications,
                  onChanged: (value) =>
                      setState(() => _pushNotifications = value),
                ),
                _buildSwitchTile(
                  title: 'Course Reminders',
                  subtitle: 'Get reminded about your ongoing courses',
                  value: _courseReminders,
                  onChanged: (value) =>
                      setState(() => _courseReminders = value),
                ),
                _buildSwitchTile(
                  title: 'Achievement Alerts',
                  subtitle: 'Celebrate your learning milestones',
                  value: _achievementAlerts,
                  onChanged: (value) =>
                      setState(() => _achievementAlerts = value),
                ),
                _buildSwitchTile(
                  title: 'New Content Alerts',
                  subtitle: 'Be notified when new courses are available',
                  value: _newContentAlerts,
                  onChanged: (value) =>
                      setState(() => _newContentAlerts = value),
                ),
              ],
            ),

            const SizedBox(height: 20),

            // Email Notifications Section
            _buildSectionCard(
              title: 'Email Notifications',
              subtitle: 'Receive updates via email',
              children: [
                _buildSwitchTile(
                  title: 'Enable Email Notifications',
                  subtitle: 'Receive important updates via email',
                  value: _emailNotifications,
                  onChanged: (value) =>
                      setState(() => _emailNotifications = value),
                ),
                _buildSwitchTile(
                  title: 'Weekly Progress Report',
                  subtitle: 'Get a summary of your weekly learning progress',
                  value: _weeklyProgress,
                  onChanged: (value) => setState(() => _weeklyProgress = value),
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
          const SizedBox(height: 4),
          Text(
            subtitle,
            style: AppTypography.bodySmall.copyWith(
              color: isDark ? AppColors.darkTextSecondary : AppColors.textSecondary,
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
    final isDark = Theme.of(context).brightness == Brightness.dark;

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
          Switch(
            value: value,
            onChanged: onChanged,
            activeThumbColor: AppColors.primary,
          ),
        ],
      ),
    );
  }

  void _saveSettings() {
    // Here you would typically save the settings to local storage or API
    ScaffoldMessenger.of(context).showSnackBar(
      CommonStyles.successSnackBar('Notification settings saved!'),
    );
  }
}
