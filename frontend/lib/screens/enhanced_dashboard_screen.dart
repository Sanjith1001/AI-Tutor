import 'package:flutter/material.dart';
import '../services/activity_service.dart';

class EnhancedDashboardScreen extends StatefulWidget {
  const EnhancedDashboardScreen({Key? key}) : super(key: key);

  @override
  State<EnhancedDashboardScreen> createState() =>
      _EnhancedDashboardScreenState();
}

class _EnhancedDashboardScreenState extends State<EnhancedDashboardScreen> {
  Map<String, dynamic> _stats = {};
  List<Map<String, dynamic>> _recentActivities = [];
  String? _learningStyle;
  String? _skillLevel;
  double _averageScore = 0.0;
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadDashboardData();
  }

  Future<void> _loadDashboardData() async {
    try {
      // Check if user has changed and refresh data if needed
      final needsRefresh = await ActivityService.needsRefresh();
      if (needsRefresh) {
        print('User changed, refreshing activities...');
      }

      // Load data with individual error handling
      final stats = await ActivityService.getStats().catchError((e) {
        print('Error loading stats: $e');
        return <String, dynamic>{
          'coursesCompleted': 0,
          'quizzesTaken': 0,
          'modulesCompleted': 0,
          'totalScore': 0,
          'totalQuizzes': 0,
          'assessmentsTaken': 0,
        };
      });

      final activities =
          await ActivityService.getRecentActivities(limit: 10).catchError((e) {
        print('Error loading activities: $e');
        return <Map<String, dynamic>>[];
      });

      final learningStyle =
          await ActivityService.getLearningStyle().catchError((e) {
        print('Error loading learning style: $e');
        return null;
      });

      final skillLevel = await ActivityService.getSkillLevel().catchError((e) {
        print('Error loading skill level: $e');
        return null;
      });

      final averageScore =
          await ActivityService.getAverageScore().catchError((e) {
        print('Error loading average score: $e');
        return 0.0;
      });

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
      print('Error loading dashboard data: $e');
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
    if (_isLoading) {
      return const Scaffold(
        backgroundColor: Colors.white,
        body: Center(
          child: CircularProgressIndicator(color: Colors.red),
        ),
      );
    }

    return Scaffold(
      backgroundColor: const Color(0xFFF8F9FA),
      body: RefreshIndicator(
        onRefresh: _loadDashboardData,
        color: Colors.red,
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
                    // Stats Overview Section
                    const Text(
                      'Statistics Overview',
                      style: TextStyle(
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                        color: Color(0xFF2D3748),
                      ),
                    ),
                    const SizedBox(height: 20),
                    // Stats Cards Grid
                    GridView.count(
                      shrinkWrap: true,
                      physics: const NeverScrollableScrollPhysics(),
                      crossAxisCount: 2,
                      crossAxisSpacing: 16,
                      mainAxisSpacing: 16,
                      childAspectRatio: 3.2,
                      children: [
                        _buildStatCard(
                          icon: Icons.school,
                          title: 'Courses\nCompleted',
                          value: '${_stats['coursesCompleted'] ?? 0}',
                          color: Colors.green,
                        ),
                        _buildStatCard(
                          icon: Icons.quiz,
                          title: 'Quizzes\nTaken',
                          value: '${_stats['quizzesTaken'] ?? 0}',
                          color: Colors.blue,
                        ),
                        _buildStatCard(
                          icon: Icons.trending_up,
                          title: 'Average\nScore',
                          value: '${_averageScore.toInt()}%',
                          color: Colors.orange,
                        ),
                        _buildStatCard(
                          icon: Icons.access_time,
                          title: 'Study\nTime',
                          value: '${(_stats['totalStudyTime'] ?? 0)}h',
                          color: Colors.purple,
                        ),
                      ],
                    ),

                    const SizedBox(height: 32),

                    // Learning Profile Section
                    _buildLearningProfileSection(),

                    const SizedBox(height: 32), // Recent Activity Section
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
          colors: [Color(0xFF667eea), Color(0xFF764ba2)],
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
              // Dashboard Icon
              Container(
                width: 50,
                height: 50,
                decoration: BoxDecoration(
                  color: Colors.white.withValues(alpha: 0.2),
                  borderRadius: BorderRadius.circular(16),
                ),
                child: const Icon(
                  Icons.analytics,
                  color: Colors.white,
                  size: 26,
                ),
              ),
              const SizedBox(height: 16),
              // Main Title
              const Text(
                'Learning Dashboard',
                style: TextStyle(
                  fontSize: 28,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                ),
              ),
              const SizedBox(height: 6),
              // Subtitle
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
    return Container(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            Colors.white,
            color.withValues(alpha: 0.05),
          ],
        ),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: color.withValues(alpha: 0.2),
          width: 1,
        ),
        boxShadow: [
          BoxShadow(
            color: color.withValues(alpha: 0.1),
            blurRadius: 15,
            offset: const Offset(0, 5),
          ),
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
            blurRadius: 10,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Glowing Icon Container
            Container(
              width: 50,
              height: 50,
              decoration: BoxDecoration(
                gradient: RadialGradient(
                  colors: [
                    color.withValues(alpha: 0.3),
                    color.withValues(alpha: 0.1),
                  ],
                ),
                shape: BoxShape.circle,
                border: Border.all(
                  color: color.withValues(alpha: 0.4),
                  width: 1,
                ),
                boxShadow: [
                  BoxShadow(
                    color: color.withValues(alpha: 0.3),
                    blurRadius: 12,
                    spreadRadius: 2,
                  ),
                ],
              ),
              child: Icon(
                icon,
                color: color,
                size: 24,
              ),
            ),
            const Spacer(),
            // Value
            Text(
              value,
              style: TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
                color: color,
              ),
            ),
            const SizedBox(height: 4),
            // Title
            Text(
              title,
              style: TextStyle(
                fontSize: 12,
                color: Colors.grey.shade600,
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
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Learning Profile',
          style: TextStyle(
            fontSize: 24,
            fontWeight: FontWeight.bold,
            color: Color(0xFF2D3748),
          ),
        ),
        const SizedBox(height: 20),
        Row(
          children: [
            Expanded(
              child: Container(
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                    colors: [
                      Colors.white,
                      Colors.purple.withValues(alpha: 0.05),
                    ],
                  ),
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(
                    color: Colors.purple.withValues(alpha: 0.2),
                    width: 1,
                  ),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.purple.withValues(alpha: 0.1),
                      blurRadius: 15,
                      offset: const Offset(0, 5),
                    ),
                    BoxShadow(
                      color: Colors.black.withValues(alpha: 0.05),
                      blurRadius: 10,
                      offset: const Offset(0, 2),
                    ),
                  ],
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Icon(Icons.psychology, color: Colors.purple, size: 20),
                        const SizedBox(width: 8),
                        const Text(
                          'Learning Style',
                          style: TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.w600,
                            color: Colors.black87,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 8),
                    Text(
                      _learningStyle ?? 'Not Set',
                      style: TextStyle(
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
                  gradient: LinearGradient(
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                    colors: [
                      Colors.white,
                      Colors.teal.withValues(alpha: 0.05),
                    ],
                  ),
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(
                    color: Colors.teal.withValues(alpha: 0.2),
                    width: 1,
                  ),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.teal.withValues(alpha: 0.1),
                      blurRadius: 15,
                      offset: const Offset(0, 5),
                    ),
                    BoxShadow(
                      color: Colors.black.withValues(alpha: 0.05),
                      blurRadius: 10,
                      offset: const Offset(0, 2),
                    ),
                  ],
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Icon(Icons.school, color: Colors.teal, size: 20),
                        const SizedBox(width: 8),
                        const Text(
                          'Skill Level',
                          style: TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.w600,
                            color: Colors.black87,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 8),
                    Text(
                      _skillLevel ?? 'Not Set',
                      style: TextStyle(
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
      // Handle different timestamp formats
      if (activity['timeAgo'] != null) {
        return activity['timeAgo'].toString();
      }

      if (activity['timestamp'] != null) {
        final timestamp = activity['timestamp'];
        if (timestamp is int) {
          return ActivityService.formatTimestamp(timestamp);
        } else if (timestamp is String) {
          // Try to parse as DateTime string
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
      print('Error formatting timestamp: $e');
      return 'Recently';
    }
  }

  Widget _buildRecentActivitySection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Recent Activity',
          style: TextStyle(
            fontSize: 24,
            fontWeight: FontWeight.bold,
            color: Color(0xFF2D3748),
          ),
        ),
        const SizedBox(height: 20),
        Container(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [
                Colors.white,
                Colors.grey.withValues(alpha: 0.05),
              ],
            ),
            borderRadius: BorderRadius.circular(20),
            border: Border.all(
              color: Colors.grey.withValues(alpha: 0.2),
              width: 1,
            ),
            boxShadow: [
              BoxShadow(
                color: Colors.grey.withValues(alpha: 0.1),
                blurRadius: 15,
                offset: const Offset(0, 5),
              ),
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.05),
                blurRadius: 10,
                offset: const Offset(0, 2),
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
                        color: Colors.grey[400],
                      ),
                      const SizedBox(height: 16),
                      Text(
                        'No recent activity',
                        style: TextStyle(
                          fontSize: 18,
                          color: Colors.grey[600],
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        'Start taking quizzes or courses to see your activity here!',
                        style: TextStyle(
                          fontSize: 14,
                          color: Colors.grey[500],
                        ),
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
                    color: Colors.grey[100],
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
                              .withValues(alpha: 0.1),
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
                        style: const TextStyle(
                          fontWeight: FontWeight.w600,
                          fontSize: 14,
                        ),
                      ),
                      subtitle: Text(
                        '${activity['description']?.toString() ?? 'No description'} • ${_formatActivityTimestamp(activity)}',
                        style: TextStyle(
                          fontSize: 12,
                          color: Colors.grey[600],
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
                                color: Colors.green.withValues(alpha: 0.1),
                                borderRadius: BorderRadius.circular(12),
                              ),
                              child: Text(
                                '${activity['metadata']['score']}%',
                                style: TextStyle(
                                  color: Colors.green.shade700,
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
