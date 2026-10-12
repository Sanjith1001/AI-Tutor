import 'package:flutter/material.dart';
import '../services/auth_backend_service.dart';
import '../services/activity_service.dart';
import '../themes/index.dart';
import 'login_screen.dart';
import 'notification_settings_screen.dart';
import 'privacy_settings_screen.dart';
import 'enhanced_vark_quiz_screen.dart';
import 'dynamic_assessment_screen.dart';
import 'edit_profile_screen.dart';

class EnhancedProfileScreen extends StatefulWidget {
  const EnhancedProfileScreen({super.key});

  @override
  State<EnhancedProfileScreen> createState() => _EnhancedProfileScreenState();
}

class _EnhancedProfileScreenState extends State<EnhancedProfileScreen> {
  Map<String, dynamic> _userData = {};
  Map<String, dynamic> _learningPreferences = {};
  bool _isLoading = true;
  double _profileCompletion = 0.0;
  int _selectedTabIndex = 0;

  // Available avatars (using emoji as local avatars)
  List<String> _availableAvatars = [
    'assets/avatars/avatar_1.png',
    'assets/avatars/avatar_2.png',
    'assets/avatars/avatar_3.png',
    'assets/avatars/avatar_4.png',
    'assets/avatars/avatar_5.png',
    'assets/avatars/avatar_6.png',
    'assets/avatars/avatar_7.png',
    'assets/avatars/avatar_8.png',
    'assets/avatars/avatar_9.png',
    'assets/avatars/avatar_10.png',
    'assets/avatars/avatar_11.png',
    'assets/avatars/avatar_12.png',
    'assets/avatars/avatar_13.png',
    'assets/avatars/avatar_14.png',
    'assets/avatars/avatar_15.png',
    'assets/avatars/avatar_16.png',
  ];

  List<String> _profileTabs = [
    'Personal Info',
    'Learning Preferences',
    'Account Actions',
    'Settings'
  ];

  @override
  void initState() {
    super.initState();
    _loadUserData();
  }

  Future<void> _loadUserData() async {
    try {
      setState(() => _isLoading = true);

      final userData = await AuthBackendService.getCurrentUser();
      final learningStyle = await ActivityService.getLearningStyle();
      final skillLevel = await ActivityService.getSkillLevel();

      if (mounted) {
        setState(() {
          _userData = userData ?? _getDefaultUserData();
          _learningPreferences = {
            'vark_style': learningStyle,
            'skill_level': skillLevel,
            'goals': '',
            'topics': <String>[],
            'language': 'English',
          };
          _profileCompletion = _calculateProfileCompletion();
          _isLoading = false;
        });
      }
    } catch (e) {
      print('Error loading user data: $e');
      if (mounted) {
        setState(() {
          _userData = _getDefaultUserData();
          _learningPreferences = {
            'vark_style': null,
            'skill_level': null,
            'goals': '',
            'topics': <String>[],
            'language': 'English',
          };
          _profileCompletion = _calculateProfileCompletion();
          _isLoading = false;
        });
      }
    }
  }

  Map<String, dynamic> _getDefaultUserData() {
    return {
      'full_name': 'John Doe',
      'email': 'john.doe@bytebrain.com',
      'role': 'Premium User',
      'bio': 'AI Enthusiast | Lifelong Learner',
      'profile_image_url': null,
      'selected_avatar': 'assets/avatars/avatar_1.png', // Default avatar
    };
  }

  double _calculateProfileCompletion() {
    int completedFields = 0;
    int totalFields = 8;

    // Personal Info (4 fields)
    if ((_userData['name'] ?? _userData['full_name'])?.isNotEmpty == true) completedFields++;
    if (_userData['bio']?.isNotEmpty == true) completedFields++;
    if (_userData['selected_avatar']?.isNotEmpty == true) completedFields++;
    if (_userData['email']?.isNotEmpty == true) completedFields++;

    // Learning Preferences (4 fields)
    if (_learningPreferences['vark_style'] != null) completedFields++;
    if (_learningPreferences['skill_level'] != null) completedFields++;
    if (_learningPreferences['goals']?.isNotEmpty == true) completedFields++;
    if (_learningPreferences['topics']?.isNotEmpty == true) completedFields++;

    return (completedFields / totalFields) * 100;
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    if (_isLoading) {
      return Scaffold(
        backgroundColor: theme.scaffoldBackgroundColor,
        body: Center(
          child: CircularProgressIndicator(color: theme.colorScheme.primary),
        ),
      );
    }

    return Scaffold(
      backgroundColor: theme.scaffoldBackgroundColor,
      body: RefreshIndicator(
        onRefresh: _loadUserData,
        color: theme.colorScheme.primary,
        child: CustomScrollView(
          slivers: [
            // Collapsible App Bar
            SliverAppBar(
              backgroundColor: theme.scaffoldBackgroundColor,
              elevation: 0,
              floating: true,
              pinned: false,
              snap: true,
              expandedHeight: 60,
              title: Text(
                'Profile',
                style: theme.textTheme.headlineMedium?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),

            // Profile Content
            SliverToBoxAdapter(
              child: Column(
                children: [
                  // Profile Header
                  _buildProfileHeader(),

                  // Profile Completion
                  Padding(
                    padding: const EdgeInsets.all(20),
                    child: _buildProfileCompletion(),
                  ),

                  // Tab Navigation (Sticky)
                  Container(
                    margin: const EdgeInsets.symmetric(horizontal: 20),
                    decoration: BoxDecoration(
                      color: isDark ? AppColors.darkSurface : Colors.grey.shade100,
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: SingleChildScrollView(
                      scrollDirection: Axis.horizontal,
                      child: Row(
                        children: _profileTabs.asMap().entries.map((entry) {
                          int index = entry.key;
                          String tab = entry.value;
                          bool isSelected = _selectedTabIndex == index;

                          return GestureDetector(
                            onTap: () =>
                                setState(() => _selectedTabIndex = index),
                            child: Container(
                              padding: const EdgeInsets.symmetric(
                                  horizontal: 16, vertical: 12),
                              margin: const EdgeInsets.all(4),
                              decoration: BoxDecoration(
                                color: isSelected
                                    ? AppColors.primary
                                    : Colors.transparent,
                                borderRadius: BorderRadius.circular(8),
                              ),
                              child: Text(
                                tab,
                                style: TextStyle(
                                  color: isSelected
                                      ? Colors.white
                                      : (isDark ? AppColors.darkTextSecondary : Colors.grey.shade700),
                                  fontWeight: isSelected
                                      ? FontWeight.w600
                                      : FontWeight.normal,
                                  fontSize: 12,
                                ),
                              ),
                            ),
                          );
                        }).toList(),
                      ),
                    ),
                  ),

                  // Tab Content
                  Padding(
                    padding: const EdgeInsets.all(20),
                    child: _buildTabContent(),
                  ),

                  // Bottom spacing for better scrolling
                  const SizedBox(height: 100),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTabContent() {
    switch (_selectedTabIndex) {
      case 0:
        return _buildPersonalInfoTab();
      case 1:
        return _buildLearningPreferencesTab();
      case 2:
        return _buildAccountActionsTab();
      case 3:
        return _buildSettingsTab();
      default:
        return _buildPersonalInfoTab();
    }
  }

  Widget _buildPersonalInfoTab() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildSectionTitle('Personal Information'),
        const SizedBox(height: 20),
        _buildEditableInfoSection(),
      ],
    );
  }

  Widget _buildLearningPreferencesTab() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildSectionTitle('Learning Preferences'),
        const SizedBox(height: 20),
        _buildLearningPreferencesSection(),
      ],
    );
  }

  Widget _buildAccountActionsTab() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildSectionTitle('Account Actions'),
        const SizedBox(height: 20),
        _buildAccountActionsSection(),
      ],
    );
  }

  Widget _buildSettingsTab() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildSectionTitle('Settings'),
        const SizedBox(height: 20),
        _buildSettingsSection(),
      ],
    );
  }

  Widget _buildSectionTitle(String title) {
    final theme = Theme.of(context);
    return Text(
      title,
      style: theme.textTheme.titleLarge?.copyWith(
        fontWeight: FontWeight.bold,
      ),
    );
  }

  Widget _buildProfileHeader() {
    return Padding(
      padding: const EdgeInsets.all(20),
      child: Column(
        children: [
          // Profile Avatar
          GestureDetector(
            onTap: _showAvatarSelectionDialog,
            child: Container(
              width: 120,
              height: 120,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: Colors.grey.shade200,
                border: Border.all(color: Colors.grey.shade300, width: 2),
              ),
              child: Stack(
                children: [
                  _buildProfileAvatar(),
                  Positioned(
                    bottom: 0,
                    right: 0,
                    child: Container(
                      width: 32,
                      height: 32,
                      decoration: BoxDecoration(
                        color: AppColors.primary,
                        shape: BoxShape.circle,
                        border: Border.all(color: Colors.white, width: 2),
                      ),
                      child: const Icon(
                        Icons.edit,
                        color: Colors.white,
                        size: 16,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 20),

          // Name
          Text(
            _userData['name'] ?? _userData['full_name'] ?? 'Unknown User',
            style: const TextStyle(
              fontSize: 32,
              fontWeight: FontWeight.bold,
              color: Colors.black,
            ),
          ),
          const SizedBox(height: 8),

          // Bio
          Text(
            _userData['bio'] ?? 'AI Enthusiast | Lifelong Learner',
            style: TextStyle(
              fontSize: 16,
              color: Colors.grey.shade600,
            ),
          ),
          const SizedBox(height: 12),

          // Role Badge
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
            decoration: BoxDecoration(
              color: AppColors.primary,
              borderRadius: BorderRadius.circular(20),
            ),
            child: Text(
              _userData['role'] ?? 'Premium User',
              style: const TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.w600,
                fontSize: 14,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildProfileAvatar() {
    if (_userData['profile_image_url']?.isNotEmpty == true) {
      return ClipOval(
        child: Image.network(
          _userData['profile_image_url'],
          width: 120,
          height: 120,
          fit: BoxFit.cover,
          errorBuilder: (context, error, stackTrace) => _buildDefaultAvatar(),
        ),
      );
    }
    return _buildDefaultAvatar();
  }

  Widget _buildDefaultAvatar() {
    final selectedAvatar =
        _userData['selected_avatar'] ?? 'assets/avatars/avatar_1.png';
    return ClipOval(
      child: Image.asset(
        selectedAvatar,
        width: 120,
        height: 120,
        fit: BoxFit.cover,
        errorBuilder: (context, error, stackTrace) {
          // Fallback to a default avatar if image fails to load
          return Container(
            width: 120,
            height: 120,
            decoration: BoxDecoration(
              color: Colors.grey.shade300,
              shape: BoxShape.circle,
            ),
            child: Icon(
              Icons.person,
              size: 60,
              color: Colors.grey.shade600,
            ),
          );
        },
      ),
    );
  }

  Widget _buildProfileCompletion() {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return Column(
      children: [
        Row(
          children: [
            const Icon(Icons.favorite, color: AppColors.primary, size: 20),
            const SizedBox(width: 12),
            Text(
              'Profile Completion: ${_profileCompletion.round()}%',
              style: theme.textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.w600,
              ),
            ),
          ],
        ),
        const SizedBox(height: 16),

        // Progress Bar
        Container(
          height: 8,
          decoration: BoxDecoration(
            color: isDark ? AppColors.darkSurfaceVariant : Colors.grey.shade200,
            borderRadius: BorderRadius.circular(4),
          ),
          child: FractionallySizedBox(
            alignment: Alignment.centerLeft,
            widthFactor: _profileCompletion / 100,
            child: Container(
              decoration: BoxDecoration(
                color: AppColors.primary,
                borderRadius: BorderRadius.circular(4),
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildEditableInfoSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildEditableField('Name', _userData['name'] ?? _userData['full_name'] ?? '', () {
          _showEditDialog('Name', _userData['name'] ?? _userData['full_name'] ?? '', (value) {
            setState(() {
              _userData['name'] = value;
              _userData['full_name'] = value; // Keep both for compatibility
              _profileCompletion = _calculateProfileCompletion();
            });
          });
        }),
        const SizedBox(height: 16),
        _buildEditableField('Bio', _userData['bio'] ?? '', () {
          _showEditDialog('Bio', _userData['bio'] ?? '', (value) {
            setState(() {
              _userData['bio'] = value;
              _profileCompletion = _calculateProfileCompletion();
            });
          });
        }),
        const SizedBox(height: 16),
        _buildEditableField('Role', _userData['role'] ?? '', () {
          _showEditDialog('Role', _userData['role'] ?? '', (value) {
            setState(() {
              _userData['role'] = value;
            });
          });
        }),
        const SizedBox(height: 16),
        _buildEditableField('Email', _userData['email'] ?? '', () {
          _showEditDialog('Email', _userData['email'] ?? '', (value) {
            setState(() {
              _userData['email'] = value;
              _profileCompletion = _calculateProfileCompletion();
            });
          });
        }),
      ],
    );
  }

  Widget _buildEditableField(String label, String value, VoidCallback onEdit) {
    return Card(
      elevation: 2,
      child: ListTile(
        title: Text(label, style: const TextStyle(fontWeight: FontWeight.w600)),
        subtitle: Text(value.isEmpty ? 'Not set' : value),
        trailing: IconButton(
          icon: const Icon(Icons.edit, size: 16),
          onPressed: onEdit,
        ),
      ),
    );
  }

  Widget _buildLearningPreferencesSection() {
    return Column(
      children: [
        _buildPreferenceCard(
            'VARK Learning Style',
            _learningPreferences['vark_style'] ?? 'Not assessed',
            Icons.psychology,
            () => Navigator.push(
                context,
                MaterialPageRoute(
                    builder: (context) => const EnhancedVARKQuizScreen()))),
        const SizedBox(height: 16),
        _buildPreferenceCard(
            'Skill Level',
            _learningPreferences['skill_level'] ?? 'Not assessed',
            Icons.trending_up,
            () => Navigator.push(
                context,
                MaterialPageRoute(
                    builder: (context) => const DynamicAssessmentScreen()))),
        const SizedBox(height: 16),
        _buildEditablePreferenceCard(
            'Learning Goals',
            _learningPreferences['goals'] ?? '',
            Icons.flag,
            (value) => setState(() => _learningPreferences['goals'] = value)),
        const SizedBox(height: 16),
        _buildTopicsPreferenceCard(),
        const SizedBox(height: 16),
        _buildLanguagePreferenceCard(),
      ],
    );
  }

  Widget _buildPreferenceCard(
      String title, String value, IconData icon, VoidCallback onTap) {
    return Card(
      elevation: 2,
      child: ListTile(
        leading: Icon(icon, color: AppColors.primary),
        title: Text(title, style: const TextStyle(fontWeight: FontWeight.w600)),
        subtitle: Text(value),
        trailing: const Icon(Icons.arrow_forward_ios, size: 16),
        onTap: onTap,
      ),
    );
  }

  Widget _buildEditablePreferenceCard(
      String title, String value, IconData icon, Function(String) onSave) {
    return Card(
      elevation: 2,
      child: ListTile(
        leading: Icon(icon, color: AppColors.primary),
        title: Text(title, style: const TextStyle(fontWeight: FontWeight.w600)),
        subtitle: Text(value.isEmpty ? 'Not set' : value),
        trailing: IconButton(
          icon: const Icon(Icons.edit, size: 16),
          onPressed: () => _showEditDialog(title, value, onSave),
        ),
      ),
    );
  }

  Widget _buildTopicsPreferenceCard() {
    final topics = List<String>.from(_learningPreferences['topics'] ?? []);
    return Card(
      elevation: 2,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(Icons.topic, color: AppColors.primary),
                const SizedBox(width: 12),
                const Text('Preferred Topics',
                    style: TextStyle(fontWeight: FontWeight.w600)),
              ],
            ),
            const SizedBox(height: 12),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: [
                ...topics.map((topic) => Chip(
                      label: Text(topic),
                      onDeleted: () {
                        setState(() {
                          topics.remove(topic);
                          _learningPreferences['topics'] = topics;
                        });
                      },
                    )),
                ActionChip(
                  label: const Text('Add Topic'),
                  onPressed: _showAddTopicDialog,
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildLanguagePreferenceCard() {
    final languages = [
      'English',
      'Hindi',
      'Spanish',
      'French',
      'German',
      'Chinese'
    ];
    return Card(
      elevation: 2,
      child: ListTile(
        leading: Icon(Icons.language, color: AppColors.primary),
        title: const Text('Language Preference',
            style: TextStyle(fontWeight: FontWeight.w600)),
        subtitle: Text(_learningPreferences['language'] ?? 'English'),
        trailing: DropdownButton<String>(
          value: _learningPreferences['language'] ?? 'English',
          items: languages
              .map((lang) => DropdownMenuItem(value: lang, child: Text(lang)))
              .toList(),
          onChanged: (value) =>
              setState(() => _learningPreferences['language'] = value),
        ),
      ),
    );
  }

  Widget _buildAccountActionsSection() {
    return Column(
      children: [
        _buildActionCard(
            'Edit Profile', Icons.edit, () => _navigateToEditProfile()),
        const SizedBox(height: 12),
        _buildActionCard('Security Settings', Icons.security, () {}),
        const SizedBox(height: 12),
        _buildActionCard('Deactivate Account', Icons.person_off,
            () => _showDeactivateDialog()),
        const SizedBox(height: 12),
        _buildActionCard('Logout', Icons.logout, () => _showLogoutDialog(),
            isDestructive: true),
      ],
    );
  }

  Widget _buildActionCard(String title, IconData icon, VoidCallback onTap,
      {bool isDestructive = false}) {
    return Card(
      elevation: 2,
      child: ListTile(
        leading:
            Icon(icon, color: isDestructive ? Colors.red : AppColors.primary),
        title: Text(title,
            style: TextStyle(
              fontWeight: FontWeight.w600,
              color: isDestructive ? Colors.red : Colors.black,
            )),
        trailing: const Icon(Icons.arrow_forward_ios, size: 16),
        onTap: onTap,
      ),
    );
  }

  Widget _buildSettingsSection() {
    return Column(
      children: [
        _buildSettingCard('Notifications', Icons.notifications,
            () => _navigateToNotificationSettings()),
        const SizedBox(height: 12),
        _buildSettingCard('Theme Settings', Icons.palette,
            () => _showThemeSelectionDialog()),
        const SizedBox(height: 12),
        _buildSettingCard('Privacy Settings', Icons.privacy_tip,
            () => _navigateToPrivacySettings()),
        const SizedBox(height: 12),
        _buildSettingCard('Data Export', Icons.download, () {}),
      ],
    );
  }

  void _showThemeSelectionDialog() {
    showDialog(
      context: context,
      builder: (context) {
        final theme = Theme.of(context);
        return AlertDialog(
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
          title: Text(
            'Select Theme Mode',
            style: theme.textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold),
          ),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              _buildThemeOptionTile(context, 'System Default', ThemeMode.system, Icons.brightness_auto),
              _buildThemeOptionTile(context, 'Light Mode', ThemeMode.light, Icons.light_mode),
              _buildThemeOptionTile(context, 'Dark Mode', ThemeMode.dark, Icons.dark_mode),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Close'),
            ),
          ],
        );
      },
    );
  }

  Widget _buildThemeOptionTile(BuildContext context, String title, ThemeMode mode, IconData icon) {
    final currentMode = ThemeManager().themeModeNotifier.value;
    final isSelected = currentMode == mode;
    
    return ListTile(
      leading: Icon(icon, color: isSelected ? AppColors.primary : null),
      title: Text(
        title,
        style: TextStyle(
          fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
        ),
      ),
      trailing: isSelected ? const Icon(Icons.check, color: AppColors.primary) : null,
      onTap: () {
        ThemeManager().setThemeMode(mode);
        Navigator.pop(context);
      },
    );
  }

  Widget _buildSettingCard(String title, IconData icon, VoidCallback onTap) {
    return Card(
      elevation: 2,
      child: ListTile(
        leading: Icon(icon, color: AppColors.primary),
        title: Text(title, style: const TextStyle(fontWeight: FontWeight.w600)),
        trailing: const Icon(Icons.arrow_forward_ios, size: 16),
        onTap: onTap,
      ),
    );
  }

  // Helper Methods
  void _showAvatarSelectionDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Choose Your Avatar'),
        content: SizedBox(
          width: double.maxFinite,
          height: 400,
          child: GridView.builder(
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 4,
              crossAxisSpacing: 12,
              mainAxisSpacing: 12,
              childAspectRatio: 1,
            ),
            itemCount: _availableAvatars.length,
            itemBuilder: (context, index) {
              final avatar = _availableAvatars[index];
              final isSelected = _userData['selected_avatar'] == avatar;

              return GestureDetector(
                onTap: () {
                  setState(() {
                    _userData['selected_avatar'] = avatar;
                    _profileCompletion = _calculateProfileCompletion();
                  });
                  Navigator.pop(context);
                },
                child: Container(
                  decoration: BoxDecoration(
                    color: isSelected
                        ? AppColors.primary.withOpacity(0.1)
                        : Colors.grey.shade50,
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(
                      color:
                          isSelected ? AppColors.primary : Colors.grey.shade300,
                      width: isSelected ? 2 : 1,
                    ),
                  ),
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(12),
                    child: Image.asset(
                      avatar,
                      width: double.infinity,
                      height: double.infinity,
                      fit: BoxFit.cover,
                      errorBuilder: (context, error, stackTrace) {
                        return Container(
                          width: double.infinity,
                          height: double.infinity,
                          color: Colors.grey.shade300,
                          child: Icon(
                            Icons.person,
                            size: 32,
                            color: Colors.grey.shade600,
                          ),
                        );
                      },
                    ),
                  ),
                ),
              );
            },
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
        ],
      ),
    );
  }

  void _showEditDialog(
      String field, String currentValue, Function(String) onSave) {
    final controller = TextEditingController(text: currentValue);

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Edit $field'),
        content: TextField(
          controller: controller,
          decoration: InputDecoration(
            labelText: field,
            border: const OutlineInputBorder(),
          ),
          maxLines: field == 'Bio' ? 3 : 1,
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () {
              onSave(controller.text);
              Navigator.pop(context);
            },
            child: const Text('Save'),
          ),
        ],
      ),
    );
  }

  void _showAddTopicDialog() {
    final controller = TextEditingController();
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Add Learning Topic'),
        content: TextField(
          controller: controller,
          decoration: const InputDecoration(
            labelText: 'Topic',
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
              if (controller.text.isNotEmpty) {
                setState(() {
                  final topics =
                      List<String>.from(_learningPreferences['topics'] ?? []);
                  topics.add(controller.text);
                  _learningPreferences['topics'] = topics;
                });
              }
              Navigator.pop(context);
            },
            child: const Text('Add'),
          ),
        ],
      ),
    );
  }

  void _showDeactivateDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Deactivate Account'),
        content: const Text(
            'Are you sure you want to deactivate your account? This action can be reversed by logging in again.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(context);
              // Implement deactivation logic
            },
            style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
            child: const Text('Deactivate'),
          ),
        ],
      ),
    );
  }

  void _showLogoutDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: const Text('Logout'),
        content: const Text('Are you sure you want to logout?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () async {
              Navigator.pop(context);
              await _performLogout();
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.primary,
              foregroundColor: Colors.white,
            ),
            child: const Text('Logout'),
          ),
        ],
      ),
    );
  }

  Future<void> _performLogout() async {
    try {
      await AuthBackendService.logoutUser();
      await ActivityService.clearUserData();

      if (mounted) {
        Navigator.of(context).pushAndRemoveUntil(
          MaterialPageRoute(builder: (context) => const ByteBrainLoginScreen()),
          (route) => false,
        );
      }
    } catch (e) {
      print('Error during logout: $e');
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Error during logout. Please try again.'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  // Navigation Methods
  void _navigateToEditProfile() {
    Navigator.push(
      context,
      MaterialPageRoute(
          builder: (context) => EditProfileScreen(user: _userData)),
    ).then((updatedUser) {
      if (updatedUser != null) {
        setState(() {
          _userData = {..._userData, ...updatedUser};
          _profileCompletion = _calculateProfileCompletion();
        });
      }
    });
  }

  void _navigateToNotificationSettings() {
    Navigator.push(
      context,
      MaterialPageRoute(
          builder: (context) => const NotificationSettingsScreen()),
    );
  }

  void _navigateToPrivacySettings() {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => const PrivacySettingsScreen()),
    );
  }
}
