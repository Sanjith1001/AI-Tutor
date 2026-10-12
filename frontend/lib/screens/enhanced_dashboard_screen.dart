import 'package:flutter/material.dart';
import '../services/activity_service.dart';
import '../themes/index.dart';

class EnhancedDashboardScreen extends StatefulWidget {
  const EnhancedDashboardScreen({Key? key}) : super(key: key);

  @override
  State<EnhancedDashboardScreen> createState() =>
      _EnhancedDashboardScreenState();
}

class _EnhancedDashboardScreenState extends State<EnhancedDashboardScreen>
    with WidgetsBindingObserver {
  Map<String, dynamic> _stats = {};
  List<Map<String, dynamic>> _recentActivities = [];
  String? _learningStyle;
  String? _skillLevel;
  double _averageScore = 0.0;
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    _loadDashboardData();
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.resumed) {
      debugPrint('📊 [Dashboard] App resumed, refreshing stats...');
      _loadDashboardData();
    }
  }

  Future<void> _loadDashboardData() async {
    try {
      final needsRefresh = await ActivityService.needsRefresh();
      if (needsRefresh) {
        debugPrint('📊 [Dashboard] User changed, refreshing activities...');
      }

      debugPrint('📊 [Dashboard] Loading dashboard data...');

      final stats = await ActivityService.getStats().catchError((e) {
        debugPrint('❌ [Dashboard] Error loading stats: $e');
        return <String, dynamic>{
          'coursesCompleted': 0,
          'quizzesTaken': 0,
          'modulesCompleted': 0,
          'totalScore': 0,
          'totalQuizzes': 0,
          'assessmentsTaken': 0,
          'averageScore': 0.0,
        };
      });

      debugPrint('✅ [Dashboard] Stats loaded: $stats');

      final activities =
          await ActivityService.getRecentActivities(limit: 10).catchError((e) {
        debugPrint('❌ [Dashboard] Error loading activities: $e');
        return <Map<String, dynamic>>[];
      });

      debugPrint('✅ [Dashboard] Activities loaded: ${activities.length} items');

      final learningStyle =
          await ActivityService.getLearningStyle().catchError((e) {
        debugPrint('❌ [Dashboard] Error loading learning style: $e');
        return null;
      });

      final skillLevel = await ActivityService.getSkillLevel().catchError((e) {
        debugPrint('❌ [Dashboard] Error loading skill level: $e');
        return null;
      });

      final statsAverage = stats['averageScore'];
      final averageScore = statsAverage is num ? statsAverage.toDouble() : 0.0;

      debugPrint('📊 [Dashboard] Average score: $averageScore');

      if (mounted) {
        setState(() {
          _stats = stats;
          _recentActivities = activities;
          _learningStyle = learningStyle;
          _skillLevel = skillLevel;
          _averageScore = averageScore;
          _isLoading = false;
        });
      }
    } catch (e) {
      debugPrint('❌ [Dashboard] Error loading dashboard data: $e');
      if (mounted) {
        setState(() {
          _stats = {
            'coursesCompleted': 0,
            'quizzesTaken': 0,
            'modulesCompleted': 0,
            'totalScore': 0,
            'totalQuizzes': 0,
            'assessmentsTaken': 0,
          };
          _recentActivities = [];
          _learningStyle = null;
          _skillLevel = null;
          _averageScore = 0.0;
          _isLoading = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    if (_isLoading) {
      return Scaffold(
        backgroundColor: theme.scaffoldBackgroundColor,
        body: Center(
          child: CircularProgressIndicator(color: theme.colorScheme.primary),
        ),
      );
    }

    final dynamic testsTakenRaw =
        _stats['assessmentsTaken'] ?? _stats['quizzesTaken'] ?? 0;
    final int testsTaken =
        testsTakenRaw is num ? testsTakenRaw.toInt() : int.tryParse('$testsTakenRaw') ?? 0;

    return Scaffold(
      backgroundColor: theme.scaffoldBackgroundColor,
      body: RefreshIndicator(
        onRefresh: _loadDashboardData,
        color: theme.colorScheme.primary,
        child: SingleChildScrollView(
          child: Column(
            children: [
              // Hero Section with Gradient Background
              _buildHeroSection(),

              // Main Content
              Padding(
                padding: const EdgeInsets.symmetric(
                    horizontal: 16.0, vertical: 20.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Statistics Overview',
                      style: theme.textTheme.headlineSmall?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 20),
                    
                    // Stats Cards Grid - Adjusted aspect ratio to prevent layout overflow
                    GridView.count(
                      shrinkWrap: true,
                      physics: const NeverScrollableScrollPhysics(),
                      crossAxisCount: 2,
                      crossAxisSpacing: 16,
                      mainAxisSpacing: 16,
                      childAspectRatio: 1.3,
                      children: [
                        _buildStatCard(
                          icon: Icons.school,
                          title: 'Courses\nCompleted',
                          value: '${_stats['coursesCompleted'] ?? 0}',
                          color: Colors.green,
                        ),
                        _buildStatCard(
                          icon: Icons.quiz,
                          title: 'Tests\nTaken',
                          value: '$testsTaken',
                          color: Colors.red,
                        ),
                        _buildStatCard(
                          icon: Icons.trending_up,
                          title: 'Average\nScore',
                          value: '${_averageScore.toInt()}%',
                          color: Colors.orange,
                        ),
                        _buildStatCard(
                          icon: Icons.book_outlined,
                          title: 'Modules\nCompleted',
                          value: '${_stats['modulesCompleted'] ?? 0}',
                          color: Colors.indigo,
                        ),
                      ],
                    ),

                    const SizedBox(height: 32),

                    // Learning Profile Section
                    _buildLearningProfileSection(),

                    const SizedBox(height: 32),
                    
                    // Recent Activity Section
                    _buildRecentActivitySection(),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildHeroSection() {
    return Container(
      height: 200,
      width: double.infinity,
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [Color(0xFF6366F1), Color(0xFF8B5CF6)], // Consistent Indigo & Purple
        ),
        borderRadius: BorderRadius.only(
          bottomLeft: Radius.circular(30),
          bottomRight: Radius.circular(30),
        ),
      ),
      child: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20.0, vertical: 16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SizedBox(height: 10),
              Container(
                width: 50,
                height: 50,
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.2),
                  borderRadius: BorderRadius.circular(16),
                ),
                child: const Icon(
                  Icons.analytics,
                  color: Colors.white,
                  size: 26,
                ),
              ),
              const SizedBox(height: 16),
              const Text(
                'Learning Dashboard',
                style: TextStyle(
                  fontSize: 28,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                ),
              ),
              const SizedBox(height: 6),
              const Text(
                'Track your progress and achievements',
                style: TextStyle(
                  fontSize: 14,
                  color: Colors.white70,
                  fontWeight: FontWeight.w400,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildStatCard({
    required IconData icon,
    required String title,
    required String value,
    required Color color,
  }) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return Container(
      decoration: BoxDecoration(
        color: theme.cardColor,
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            theme.cardColor,
            color.withOpacity(isDark ? 0.08 : 0.03),
          ],
        ),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: color.withOpacity(isDark ? 0.25 : 0.15),
          width: 1,
        ),
        boxShadow: [
          BoxShadow(
            color: color.withOpacity(isDark ? 0.15 : 0.05),
            blurRadius: 15,
            offset: const Offset(0, 5),
          ),
          BoxShadow(
            color: Colors.black.withOpacity(isDark ? 0.2 : 0.03),
            blurRadius: 10,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              width: 40,
              height: 40,
              decoration: BoxDecoration(
                color: color.withOpacity(isDark ? 0.2 : 0.1),
                shape: BoxShape.circle,
                border: Border.all(
                  color: color.withOpacity(isDark ? 0.4 : 0.2),
                  width: 1,
                ),
              ),
              child: Icon(
                icon,
                color: color,
                size: 20,
              ),
            ),
            const Spacer(),
            Text(
              value,
              style: TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
                color: isDark ? theme.textTheme.bodyLarge?.color : color,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              title,
              style: theme.textTheme.bodySmall?.copyWith(
                fontWeight: FontWeight.w500,
              ),
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildLearningProfileSection() {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Learning Profile',
          style: theme.textTheme.headlineSmall?.copyWith(
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 20),
        Row(
          children: [
            Expanded(
              child: Container(
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  color: theme.cardColor,
                  gradient: LinearGradient(
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                    colors: [
                      theme.cardColor,
                      Colors.purple.withOpacity(isDark ? 0.08 : 0.03),
                    ],
                  ),
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(
                    color: Colors.purple.withOpacity(isDark ? 0.25 : 0.15),
                    width: 1,
                  ),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.purple.withOpacity(isDark ? 0.15 : 0.05),
                      blurRadius: 15,
                      offset: const Offset(0, 5),
                    ),
                  ],
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        const Icon(Icons.psychology, color: Colors.purple, size: 20),
                        const SizedBox(width: 8),
                        Text(
                          'Learning Style',
                          style: theme.textTheme.titleSmall?.copyWith(
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 8),
                    Text(
                      _learningStyle ?? 'Not Set',
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color: Colors.purple,
                      ),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Container(
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  color: theme.cardColor,
                  gradient: LinearGradient(
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                    colors: [
                      theme.cardColor,
                      Colors.teal.withOpacity(isDark ? 0.08 : 0.03),
                    ],
                  ),
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(
                    color: Colors.teal.withOpacity(isDark ? 0.25 : 0.15),
                    width: 1,
                  ),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.teal.withOpacity(isDark ? 0.15 : 0.05),
                      blurRadius: 15,
                      offset: const Offset(0, 5),
                    ),
                  ],
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        const Icon(Icons.school, color: Colors.teal, size: 20),
                        const SizedBox(width: 8),
                        Text(
                          'Skill Level',
                          style: theme.textTheme.titleSmall?.copyWith(
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 8),
                    Text(
                      _skillLevel ?? 'Not Set',
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color: Colors.teal,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ],
    );
  }

  String _formatActivityTimestamp(Map<String, dynamic> activity) {
    try {
      if (activity['timeAgo'] != null) {
        return activity['timeAgo'].toString();
      }

      if (activity['timestamp'] != null) {
        final timestamp = activity['timestamp'];
        if (timestamp is int) {
          return ActivityService.formatTimestamp(timestamp);
        } else if (timestamp is String) {
          try {
            final dateTime = DateTime.parse(timestamp);
            return ActivityService.formatTimestamp(
                dateTime.millisecondsSinceEpoch);
          } catch (e) {
            return 'Recently';
          }
        }
      }

      return 'Recently';
    } catch (e) {
      debugPrint('Error formatting timestamp: $e');
      return 'Recently';
    }
  }

  Widget _buildRecentActivitySection() {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Recent Activity',
          style: theme.textTheme.headlineSmall?.copyWith(
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 20),
        Container(
          decoration: BoxDecoration(
            color: theme.cardColor,
            borderRadius: BorderRadius.circular(20),
            border: Border.all(
              color: isDark ? AppColors.darkSurfaceVariant : AppColors.divider,
              width: 1,
            ),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(isDark ? 0.2 : 0.03),
                blurRadius: 15,
                offset: const Offset(0, 5),
              ),
            ],
          ),
          child: _recentActivities.isEmpty
              ? Container(
                  padding: const EdgeInsets.all(40),
                  child: Column(
                    children: [
                      Icon(
                        Icons.history,
                        size: 48,
                        color: isDark ? AppColors.darkTextTertiary : Colors.grey[400],
                      ),
                      const SizedBox(height: 16),
                      Text(
                        'No recent activity',
                        style: theme.textTheme.titleMedium?.copyWith(
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        'Start taking quizzes or courses to see your activity here!',
                        style: theme.textTheme.bodySmall,
                        textAlign: TextAlign.center,
                      ),
                    ],
                  ),
                )
              : ListView.separated(
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  itemCount: _recentActivities.length,
                  separatorBuilder: (context, index) => Divider(
                    color: isDark ? AppColors.darkSurfaceVariant : Colors.grey[100],
                    height: 1,
                  ),
                  itemBuilder: (context, index) {
                    final activity = _recentActivities[index];
                    return ListTile(
                      contentPadding: const EdgeInsets.symmetric(
                        horizontal: 20,
                        vertical: 8,
                      ),
                      leading: Container(
                        padding: const EdgeInsets.all(8),
                        decoration: BoxDecoration(
                          color: ActivityService.getActivityColor(
                                  activity['type']?.toString() ?? 'unknown')
                              .withOpacity(isDark ? 0.2 : 0.1),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Icon(
                          ActivityService.getActivityIcon(
                              activity['type']?.toString() ?? 'unknown'),
                          color: ActivityService.getActivityColor(
                              activity['type']?.toString() ?? 'unknown'),
                          size: 20,
                        ),
                      ),
                      title: Text(
                        activity['title']?.toString() ?? 'Unknown Activity',
                        style: theme.textTheme.bodyMedium?.copyWith(
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      subtitle: Text(
                        '${activity['description']?.toString() ?? 'No description'} • ${_formatActivityTimestamp(activity)}',
                        style: theme.textTheme.bodySmall?.copyWith(
                          color: isDark ? AppColors.darkTextSecondary : Colors.grey[600],
                        ),
                      ),
                      trailing: activity['metadata'] != null &&
                              activity['metadata']['score'] != null
                          ? Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 8,
                                vertical: 4,
                              ),
                              decoration: BoxDecoration(
                                color: Colors.green.withOpacity(isDark ? 0.2 : 0.1),
                                borderRadius: BorderRadius.circular(12),
                              ),
                              child: Text(
                                '${activity['metadata']['score']}%',
                                style: TextStyle(
                                  color: isDark ? Colors.green.shade400 : Colors.green.shade700,
                                  fontWeight: FontWeight.bold,
                                  fontSize: 12,
                                ),
                              ),
                            )
                          : null,
                    );
                  },
                ),
        ),
      ],
    );
  }
}
