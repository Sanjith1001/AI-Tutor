import 'package:flutter/material.dart';
import 'ai_module_content_screen.dart';
import '../models/course_model.dart';
import '../services/activity_service.dart';
import '../services/course_storage_service.dart';

class CourseScreen extends StatelessWidget {
  final String title;
  final List<Map<String, dynamic>> modules; // dynamic for Groq
  final String? learningStyle;
  final String? skillLevel;

  const CourseScreen({
    super.key,
    required this.title,
    required this.modules,
    this.learningStyle,
    this.skillLevel,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return Scaffold(
      backgroundColor: theme.scaffoldBackgroundColor,
      appBar: AppBar(
        title: Text(title),
        backgroundColor: theme.appBarTheme.backgroundColor ?? theme.colorScheme.primary,
        foregroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => Navigator.of(context).pop(),
        ),
        actions: [
          if (learningStyle != null)
            Padding(
              padding: const EdgeInsets.only(right: 16.0),
              child: Center(
                child: Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  decoration: BoxDecoration(
                    color: Colors.white.withOpacity(0.2),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Text(
                    learningStyle!,
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 12,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ),
            ),
        ],
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Progress indicator
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: theme.cardColor,
                  borderRadius: BorderRadius.circular(12),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(isDark ? 0.2 : 0.05),
                      spreadRadius: 1,
                      blurRadius: 3,
                      offset: const Offset(0, 1),
                    ),
                  ],
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Course Progress',
                      style: theme.textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 8),
                    LinearProgressIndicator(
                      value: 0.3, // Placeholder progress
                      backgroundColor: isDark ? Colors.grey[800] : Colors.grey[300],
                      valueColor:
                          const AlwaysStoppedAnimation<Color>(Colors.blue),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      '${modules.length} modules available',
                      style: theme.textTheme.bodySmall?.copyWith(
                        color: isDark ? Colors.grey[400] : Colors.grey[600],
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 20),

              // Modules list
              Text(
                'Course Modules',
                style: theme.textTheme.headlineSmall?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 16),

              ListView.builder(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                itemCount: modules.length,
                itemBuilder: (context, index) {
                  final module = modules[index];
                  return ModuleCard(
                    title: module['title'] ?? 'Module ${index + 1}',
                    description:
                        module['description'] ?? 'No description available',
                    index: index,
                    learningStyle: learningStyle,
                    course: null, // No course object in this simplified version
                    courseTitle: title,
                    totalModules: modules.length,
                  );
                },
              ),
              const SizedBox(height: 100), // Extra padding at bottom
            ],
          ),
        ),
      ),
    );
  }
}

class ModuleCard extends StatefulWidget {
  final String title;
  final String description;
  final int index;
  final Course? course;
  final String? learningStyle;
  final String? courseTitle;
  final int totalModules;

  const ModuleCard({
    super.key,
    required this.title,
    required this.description,
    required this.index,
    this.course,
    this.learningStyle,
    this.courseTitle,
    required this.totalModules,
  });

  @override
  State<ModuleCard> createState() => _ModuleCardState();
}

class _ModuleCardState extends State<ModuleCard> {
  bool _isHovered = false;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      child: MouseRegion(
        onEnter: (_) {
          if (mounted) {
            setState(() => _isHovered = true);
          }
        },
        onExit: (_) {
          if (mounted) {
            setState(() => _isHovered = false);
          }
        },
        child: GestureDetector(
          onTap: () async {
            // Track module access
            ActivityService.addActivity(
              type: ActivityService.activityModule,
              title: 'Accessed ${widget.title}',
              description: 'Opened module for learning',
              metadata: {
                'moduleTitle': widget.title,
                'learningStyle': widget.learningStyle,
                'courseTitle': widget.courseTitle,
              },
            );

            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => AIModuleContentScreen(
                  moduleTitle: widget.title,
                  moduleDescription: widget.description,
                  moduleIndex: widget.index,
                  learningStyle: widget.learningStyle,
                  courseTitle: widget.courseTitle ?? '',
                  totalModules: widget.totalModules,
                ),
              ),
            );
          },
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 200),
            transform: Matrix4.identity()..scale(_isHovered ? 1.02 : 1.0),
            child: Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: theme.cardColor,
                borderRadius: BorderRadius.circular(16),
                boxShadow: [
                  BoxShadow(
                    color: _isHovered
                        ? Colors.blue.withOpacity(0.2)
                        : Colors.black.withOpacity(isDark ? 0.25 : 0.05),
                    spreadRadius: _isHovered ? 3 : 1,
                    blurRadius: _isHovered ? 10 : 5,
                    offset: const Offset(0, 3),
                  ),
                ],
                border: _isHovered
                    ? Border.all(color: Colors.blue.withOpacity(0.5), width: 2)
                    : null,
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Header row with module number and title
                  Row(
                    children: [
                      Container(
                        width: 40,
                        height: 40,
                        decoration: BoxDecoration(
                          color: Colors.blue,
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Center(
                          child: Text(
                            '${widget.index + 1}',
                            style: const TextStyle(
                              color: Colors.white,
                              fontWeight: FontWeight.bold,
                              fontSize: 18,
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(width: 16),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              widget.title,
                              style: theme.textTheme.titleMedium?.copyWith(
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            if (widget.learningStyle != null)
                              Container(
                                margin: const EdgeInsets.only(top: 4),
                                padding: const EdgeInsets.symmetric(
                                    horizontal: 8, vertical: 2),
                                decoration: BoxDecoration(
                                  color: Colors.blue.withOpacity(0.15),
                                  borderRadius: BorderRadius.circular(8),
                                ),
                                child: Text(
                                  widget.learningStyle!,
                                  style: const TextStyle(
                                    fontSize: 12,
                                    color: Colors.blue,
                                    fontWeight: FontWeight.w500,
                                  ),
                                ),
                              ),
                          ],
                        ),
                      ),
                      Icon(
                        Icons.arrow_forward_ios,
                        color: isDark ? Colors.grey[600] : Colors.grey[400],
                        size: 20,
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),

                  // Module description
                  Text(
                    widget.description,
                    style: theme.textTheme.bodyMedium?.copyWith(
                      color: isDark ? Colors.grey[400] : Colors.grey[600],
                      height: 1.4,
                    ),
                    maxLines: 3,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 16),

                  // Bottom row with features info
                  Row(
                    children: [
                      _buildFeatureChip(context, Icons.book, 'Content'),
                      const SizedBox(width: 8),
                      _buildFeatureChip(context, Icons.quiz, 'Quiz'),
                      const SizedBox(width: 8),
                      _buildFeatureChip(context, Icons.video_library, 'Videos'),
                      const SizedBox(width: 8),
                      _buildFeatureChip(context, Icons.headphones, 'Audio'),
                    ],
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildFeatureChip(BuildContext context, IconData icon, String label) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: isDark ? Colors.grey[800] : Colors.grey[100],
        borderRadius: BorderRadius.circular(6),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 14, color: isDark ? Colors.grey[400] : Colors.grey[600]),
          const SizedBox(width: 4),
          Text(
            label,
            style: TextStyle(
              fontSize: 12,
              color: isDark ? Colors.grey[400] : Colors.grey[600],
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }
}

// Sample data (keeping the existing structure)
List<Course> sampleCourses = [
  Course(
    title: "Flutter Development",
    modules: [
      Module(
        title: "Introduction to Flutter",
        lessons: [
          Lesson(
            title: "1.1.1 What is Flutter?",
            content:
                "Flutter is Google's UI toolkit for building natively compiled applications for mobile, web, and desktop from a single codebase...",
          ),
          Lesson(
            title: "1.1.2 Setting up Flutter",
            content:
                "To get started with Flutter development, you need to install Flutter SDK, set up an IDE like VS Code or Android Studio...",
          ),
        ],
      ),
      Module(
        title: "Widgets and Layout",
        lessons: [
          Lesson(
            title: "2.1.1 Basic Widgets",
            content:
                "Flutter provides a rich set of widgets including Text, Container, Row, Column, Stack, and many more...",
          ),
          Lesson(
            title: "2.1.2 Layout Widgets",
            content:
                "Layout widgets in Flutter help you arrange other widgets in specific ways. The most common ones are Row, Column, and Stack...",
          ),
        ],
      ),
    ],
  ),
  Course(
    title: "Machine Learning",
    modules: [
      Module(
        title: "Introduction to ML",
        lessons: [
          Lesson(
            title: "1.1.1 What is ML?",
            content:
                "Machine Learning is a subset of AI that enables systems to learn patterns...",
          ),
          Lesson(
            title: "1.1.2 Types of ML",
            content:
                "Supervised, Unsupervised, Reinforcement Learning with examples...",
          ),
        ],
      ),
    ],
  ),
];
