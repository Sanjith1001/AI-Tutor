import 'package:flutter/material.dart';
import '../services/activity_service.dart';
import '../services/auth_backend_service.dart';
import '../services/course_storage_service.dart';
import '../services/groq_service.dart';
import '../themes/index.dart';
import 'enhanced_profile_screen.dart';
import 'enhanced_dashboard_screen.dart';
import 'ai_content_generator_screen.dart';
import 'ai_chatbot_screen.dart';
import 'dynamic_assessment_screen.dart';
import 'course_screen.dart';

class EnhancedHomeScreen extends StatefulWidget {
  const EnhancedHomeScreen({super.key});

  @override
  State<EnhancedHomeScreen> createState() => _EnhancedHomeScreenState();
}

class _EnhancedHomeScreenState extends State<EnhancedHomeScreen> {
  int _selectedIndex = 0;

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }

  @override
  Widget build(BuildContext context) {
    final List<Widget> pages = [
      const EnhancedCoursesPage(),
      const EnhancedDashboardScreen(),
      const EnhancedProfileScreen(),
    ];

    return Scaffold(
      body: IndexedStack(
        index: _selectedIndex,
        children: pages,
      ),
      bottomNavigationBar: Container(
        decoration: BoxDecoration(
          color: Colors.white,
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.1),
              blurRadius: 10,
              offset: const Offset(0, -2),
            ),
          ],
        ),
        child: BottomNavigationBar(
          currentIndex: _selectedIndex,
          onTap: _onItemTapped,
          backgroundColor: Colors.transparent,
          elevation: 0,
          selectedItemColor: Colors.red,
          unselectedItemColor: Colors.grey,
          type: BottomNavigationBarType.fixed,
          items: const [
            BottomNavigationBarItem(
              icon: Icon(Icons.home_rounded),
              label: 'Home',
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.dashboard_rounded),
              label: 'Dashboard',
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.person_rounded),
              label: 'Profile',
            ),
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => _navigateToAIGenerator(),
        backgroundColor: const Color(0xFF6366F1),
        foregroundColor: Colors.white,
        elevation: 8,
        icon: const Icon(Icons.auto_awesome),
        label: const Text(
          'Nova AI',
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.endFloat,
    );
  }

  void _navigateToAIGenerator() async {
    // Navigate directly to AI Chatbot screen
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => const AIChatbotScreen(),
      ),
    );
  }
}

class EnhancedCoursesPage extends StatefulWidget {
  const EnhancedCoursesPage({super.key});

  @override
  State<EnhancedCoursesPage> createState() => _EnhancedCoursesPageState();
}

class _EnhancedCoursesPageState extends State<EnhancedCoursesPage>
    with TickerProviderStateMixin {
  late AnimationController _animationController;
  String _userName = 'Student User';

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      duration: const Duration(milliseconds: 1000),
      vsync: this,
    );
    _animationController.forward();
    _loadUserName();
    _checkAssessments();
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  Future<void> _checkAssessments() async {
    final needsRefresh = await ActivityService.needsRefresh();
    if (needsRefresh) {
      print('User changed, refreshing user data...');
    }

    await ActivityService.getLearningStyle();
    await ActivityService.getSkillLevel();
  }

  Future<void> _loadUserName() async {
    final user = await AuthBackendService.getCurrentUser();
    setState(() {
      _userName = user?['name'] ?? 'Student User';
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8F9FA),
      body: SafeArea(
        child: SingleChildScrollView(
          child: Column(
            children: [
              // Top Bar
              _buildTopBar(),

              // Hero Section
              _buildHeroSection(),

              // Continue Learning Section
              _buildContinueLearningSection(),

              // Quick Actions Section
              _buildQuickActionsSection(),

              // Recommended Section
              _buildRecommendedSection(),

              const SizedBox(height: 100), // Space for floating button
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildTopBar() {
    return Container(
      padding: CommonStyles.extraLargePadding.copyWith(bottom: 10),
      decoration: HomeScreenStyles.topBarDecoration,
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            decoration: HomeScreenStyles.brandBadgeDecoration,
            child: Text(
              'ByteBrain',
              style: HomeScreenStyles.brandBadgeText,
            ),
          ),
          IconButton(
            onPressed: () {
              // Show user menu
            },
            icon: const Icon(Icons.account_circle, size: 32),
          ),
        ],
      ),
    );
  }

  Widget _buildHeroSection() {
    return Container(
      width: double.infinity,
      margin: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
      padding: HomeScreenStyles.cardPadding,
      decoration: HomeScreenStyles.heroDecoration,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: Colors.white.withValues(alpha: 0.2),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: const Icon(
                  Icons.psychology,
                  color: Colors.white,
                  size: 24,
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          const Text(
            'Welcome to ByteBrain',
            style: TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.bold,
              color: Colors.white,
            ),
          ),
          const SizedBox(height: 4),
          const Text(
            'Personalized AI-powered learning experiences',
            style: TextStyle(
              fontSize: 14,
              color: Colors.white70,
            ),
          ),
          const SizedBox(height: 16),
          Row(
            children: [
              Text(
                'Welcome back, $_userName',
                style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                  color: Colors.white,
                ),
              ),
              const SizedBox(width: 8),
              const Text(
                '👋',
                style: TextStyle(fontSize: 16),
              ),
            ],
          ),
          const SizedBox(height: 4),
          const Text(
            "Here's what's new for you",
            style: TextStyle(
              fontSize: 14,
              color: Colors.white70,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildContinueLearningSection() {
    return Padding(
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Continue Learning',
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
              color: Colors.black87,
            ),
          ),
          const SizedBox(height: 16),
          FutureBuilder<Map<String, dynamic>?>(
            future: CourseStorageService.getLastCourse(),
            builder: (context, snapshot) {
              if (snapshot.connectionState == ConnectionState.waiting) {
                return Container(
                  padding: const EdgeInsets.all(20),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(16),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withValues(alpha: 0.05),
                        blurRadius: 10,
                        offset: const Offset(0, 4),
                      ),
                    ],
                  ),
                  child: const Center(
                    child: CircularProgressIndicator(),
                  ),
                );
              }

              final courseData = snapshot.data;

              if (courseData == null) {
                return Container(
                  padding: const EdgeInsets.all(20),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(16),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withValues(alpha: 0.05),
                        blurRadius: 10,
                        offset: const Offset(0, 4),
                      ),
                    ],
                  ),
                  child: Column(
                    children: [
                      Icon(
                        Icons.auto_awesome,
                        size: 48,
                        color: Colors.grey.shade400,
                      ),
                      const SizedBox(height: 12),
                      Text(
                        'No Course in Progress',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                          color: Colors.grey.shade600,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        'Generate a course with AI to start learning',
                        style: TextStyle(
                          fontSize: 14,
                          color: Colors.grey.shade500,
                        ),
                        textAlign: TextAlign.center,
                      ),
                    ],
                  ),
                );
              }

              // Show course card like in your screenshot
              final title = courseData['title'] as String;
              final progress =
                  (courseData['progress'] as num?)?.toDouble() ?? 60.0;

              return Container(
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(16),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withValues(alpha: 0.05),
                      blurRadius: 10,
                      offset: const Offset(0, 4),
                    ),
                  ],
                ),
                child: Row(
                  children: [
                    Container(
                      width: 50,
                      height: 50,
                      decoration: BoxDecoration(
                        color: const Color(0xFF8B5CF6),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: const Icon(
                        Icons.school,
                        color: Colors.white,
                        size: 24,
                      ),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            title.isNotEmpty
                                ? title
                                : 'Introduction to Flutter',
                            style: const TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                              color: Colors.black87,
                            ),
                          ),
                          const SizedBox(height: 4),
                          const Text(
                            'Mobile Development',
                            style: TextStyle(
                              fontSize: 14,
                              color: Colors.grey,
                            ),
                          ),
                          const SizedBox(height: 8),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              const Text(
                                'Progress',
                                style: TextStyle(
                                  fontSize: 12,
                                  color: Colors.grey,
                                ),
                              ),
                              Text(
                                '${progress.round()}%',
                                style: const TextStyle(
                                  fontSize: 12,
                                  fontWeight: FontWeight.bold,
                                  color: Color(0xFF6366F1),
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 4),
                          LinearProgressIndicator(
                            value: progress / 100,
                            backgroundColor: Colors.grey.shade200,
                            valueColor: const AlwaysStoppedAnimation<Color>(
                                Color(0xFF6366F1)),
                            borderRadius: BorderRadius.circular(10),
                          ),
                          const SizedBox(height: 12),
                          SizedBox(
                            width: double.infinity,
                            child: ElevatedButton(
                              onPressed: () => _resumeLearning(courseData),
                              style: ElevatedButton.styleFrom(
                                backgroundColor: Colors.red,
                                foregroundColor: Colors.white,
                                padding:
                                    const EdgeInsets.symmetric(vertical: 12),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(8),
                                ),
                              ),
                              child: const Text(
                                'Resume Learning',
                                style: TextStyle(
                                  fontSize: 14,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              );
            },
          ),
        ],
      ),
    );
  }

  Widget _buildQuickActionsSection() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Quick Actions',
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
              color: Colors.black87,
            ),
          ),
          const SizedBox(height: 16),
          Row(
            children: [
              Expanded(
                child: _buildQuickActionCard(
                  icon: Icons.school_rounded,
                  title: 'Browse Courses',
                  subtitle: 'Discover learning paths',
                  color: const Color(0xFF6366F1),
                  onTap: () => _navigateToCourses(),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: _buildQuickActionCard(
                  icon: Icons.assessment_rounded,
                  title: 'Assessment',
                  subtitle: 'Test your skills',
                  color: Colors.red,
                  onTap: () => _navigateToSkillAssessment(),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildQuickActionCard({
    required IconData icon,
    required String title,
    required String subtitle,
    required Color color,
    required VoidCallback onTap,
  }) {
    return Container(
      height: 120,
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: color.withValues(alpha: 0.2),
          width: 1,
        ),
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(16),
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  width: 40,
                  height: 40,
                  decoration: BoxDecoration(
                    color: color,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Icon(
                    icon,
                    color: Colors.white,
                    size: 20,
                  ),
                ),
                const Spacer(),
                Text(
                  title,
                  style: const TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.bold,
                    color: Colors.black87,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  subtitle,
                  style: TextStyle(
                    fontSize: 12,
                    color: Colors.grey.shade600,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildRecommendedSection() {
    return Padding(
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Recommended for You',
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
              color: Colors.black87,
            ),
          ),
          const SizedBox(height: 16),
          SizedBox(
            height: 240,
            child: ListView(
              scrollDirection: Axis.horizontal,
              children: [
                _buildRecommendedCard(
                  title: 'Machine Learning\nBasics',
                  subtitle:
                      'AI curated content tailored to\nyour learning preferences',
                  color: const Color(0xFF8B5CF6),
                  icon: Icons.psychology_rounded,
                ),
                _buildRecommendedCard(
                  title: 'Web Development',
                  subtitle:
                      'AI curated content tailored to\nyour learning preferences',
                  color: const Color(0xFF3B82F6),
                  icon: Icons.web_rounded,
                ),
                _buildRecommendedCard(
                  title: 'Data Science',
                  subtitle:
                      'AI curated content tailored to\nyour learning preferences',
                  color: const Color(0xFF10B981),
                  icon: Icons.analytics_rounded,
                ),
                _buildRecommendedCard(
                  title: 'Mobile Development',
                  subtitle:
                      'AI curated content tailored to\nyour learning preferences',
                  color: const Color(0xFFF59E0B),
                  icon: Icons.phone_android_rounded,
                ),
                _buildRecommendedCard(
                  title: 'Cloud Computing',
                  subtitle:
                      'AI curated content tailored to\nyour learning preferences',
                  color: const Color(0xFF06B6D4),
                  icon: Icons.cloud_rounded,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildRecommendedCard({
    required String title,
    required String subtitle,
    required Color color,
    required IconData icon,
  }) {
    return Container(
      width: 160,
      height: 200, // Fixed height to prevent overflow
      margin: const EdgeInsets.only(right: 16),
      decoration: BoxDecoration(
        color: color,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: color.withValues(alpha: 0.3),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              width: 32,
              height: 32,
              decoration: BoxDecoration(
                color: Colors.white.withValues(alpha: 0.2),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Icon(
                icon,
                color: Colors.white,
                size: 18,
              ),
            ),
            const SizedBox(height: 12),
            Text(
              title,
              style: const TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.bold,
                color: Colors.white,
              ),
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
            ),
            const SizedBox(height: 8),
            Text(
              subtitle,
              style: const TextStyle(
                fontSize: 11,
                color: Colors.white70,
              ),
              maxLines: 3,
              overflow: TextOverflow.ellipsis,
            ),
            const SizedBox(height: 16),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: () {
                  _generateCourseFromTopic(title, color);
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.white,
                  foregroundColor: color,
                  padding: const EdgeInsets.symmetric(vertical: 8),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                  elevation: 0,
                ),
                child: const Text(
                  'Explore',
                  style: TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  // Navigation Methods
  void _navigateToSkillAssessment() {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => const DynamicAssessmentScreen(),
      ),
    );
  }

  Future<void> _generateCourseFromTopic(String topic, Color topicColor) async {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(20),
        ),
        content: Container(
          padding: const EdgeInsets.all(20),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                width: 60,
                height: 60,
                decoration: BoxDecoration(
                  color: topicColor.withValues(alpha: 0.1),
                  shape: BoxShape.circle,
                ),
                child: CircularProgressIndicator(
                  color: topicColor,
                  strokeWidth: 3,
                ),
              ),
              const SizedBox(height: 20),
              Text(
                'Generating $topic Course',
                style: const TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 8),
              Text(
                'AI is creating personalized modules tailored to your learning style',
                style: TextStyle(
                  fontSize: 14,
                  color: Colors.grey.shade600,
                ),
                textAlign: TextAlign.center,
              ),
            ],
          ),
        ),
      ),
    );

    try {
      final prompt =
          'Create a comprehensive $topic course for beginners to intermediate learners';
      final result = await GroqService().generateDetailedContent(
        prompt,
        difficulty: 'beginner to intermediate',
        audience: 'general learners',
      );

      if (mounted) Navigator.pop(context);

      if (result['modules'] != null && result['modules'].isNotEmpty) {
        final courseTitle = result['courseTitle'] ?? '$topic Course';
        final modules = List<Map<String, dynamic>>.from(result['modules']);

        await CourseStorageService.storeLastCourse(
          title: courseTitle,
          modules: modules,
        );

        if (mounted) {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => CourseScreen(
                title: courseTitle,
                modules: modules,
              ),
            ),
          );
        }
      } else {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content:
                  Text('Failed to generate $topic course. Please try again.'),
              backgroundColor: Colors.red,
            ),
          );
        }
      }
    } catch (e) {
      if (mounted && Navigator.canPop(context)) {
        Navigator.pop(context);
      }

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error generating course: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  void _navigateToCourses() {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => const AIContentGeneratorScreen()),
    );
  }

  void _resumeLearning(Map<String, dynamic> courseData) {
    final title = courseData['title'] as String;
    final modules = List<Map<String, dynamic>>.from(courseData['modules']);
    final learningStyle = courseData['learningStyle'] as String?;
    final skillLevel = courseData['skillLevel'] as String?;

    CourseStorageService.storeLastCourse(
      title: title,
      modules: modules,
      learningStyle: learningStyle,
      skillLevel: skillLevel,
    );

    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => CourseScreen(
          title: title,
          modules: modules,
          learningStyle: learningStyle,
          skillLevel: skillLevel,
        ),
      ),
    );
  }
}
