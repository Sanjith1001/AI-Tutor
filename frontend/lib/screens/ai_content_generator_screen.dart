import 'package:flutter/material.dart';
import '../services/groq_service.dart';
import '../services/course_storage_service.dart';
import '../themes/index.dart';
import 'course_screen.dart';

class AIContentGeneratorScreen extends StatefulWidget {
  const AIContentGeneratorScreen({super.key});

  @override
  State<AIContentGeneratorScreen> createState() =>
      _AIContentGeneratorScreenState();
}

class _AIContentGeneratorScreenState extends State<AIContentGeneratorScreen> {
  final TextEditingController _promptController = TextEditingController();
  final GroqService _groqService = GroqService();
  bool _isLoading = false;
  String? _errorMessage;

  // Predefined prompt templates
  final List<Map<String, String>> _promptTemplates = [
    {
      'title': 'Programming Course',
      'prompt':
          'Create a comprehensive programming course for beginners learning Python'
    },
    {
      'title': 'Data Science',
      'prompt':
          'Generate a data science course covering statistics, machine learning, and data visualization'
    },
    {
      'title': 'Web Development',
      'prompt':
          'Create a full-stack web development course with HTML, CSS, JavaScript, and React'
    },
    {
      'title': 'Mobile App Development',
      'prompt':
          'Design a mobile app development course focusing on Flutter and Dart'
    },
    {
      'title': 'AI & Machine Learning',
      'prompt':
          'Create an artificial intelligence and machine learning course for intermediate learners'
    },
    {
      'title': 'Cybersecurity',
      'prompt':
          'Generate a cybersecurity fundamentals course covering network security and ethical hacking'
    },
  ];

  Future<void> _generateContent() async {
    if (_promptController.text.trim().isEmpty) {
      setState(() {
        _errorMessage = 'Please enter a prompt to generate content';
      });
      return;
    }

    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    try {
      final result = await _groqService.generateDetailedContent(
        _promptController.text.trim(),
        difficulty: 'intermediate',
        audience: 'general learners',
      );

      if (result['modules'] != null && result['modules'].isNotEmpty) {
        final courseTitle = result['courseTitle'] ?? 'AI Generated Course';
        final modules = List<Map<String, dynamic>>.from(result['modules']);

        await CourseStorageService.storeLastCourse(
          title: courseTitle,
          modules: modules,
        );

        if (!mounted) return;

        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => CourseScreen(
              title: courseTitle,
              modules: modules,
            ),
          ),
        );
      } else {
        setState(() {
          _errorMessage =
              'Failed to generate course modules. Please try again with a different prompt.';
        });
      }
    } catch (e) {
      setState(() {
        _errorMessage =
            'Error generating content: ${e.toString().replaceAll('Exception: ', '')}';
      });
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  void _useTemplate(String prompt) {
    _promptController.text = prompt;
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return Scaffold(
      backgroundColor: theme.scaffoldBackgroundColor,
      appBar: AppBar(
        title: const Text('AI Content Generator'),
        backgroundColor: theme.appBarTheme.backgroundColor ?? theme.colorScheme.primary,
        foregroundColor: Colors.white,
        elevation: 0,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header Section with centralized brand colors
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(24),
              decoration: BoxDecoration(
                gradient: const LinearGradient(
                  colors: AppColors.primaryGradient,
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
                borderRadius: BorderRadius.circular(16),
                boxShadow: [
                  BoxShadow(
                    color: AppColors.primary.withOpacity(isDark ? 0.2 : 0.3),
                    blurRadius: 10,
                    offset: const Offset(0, 4),
                  ),
                ],
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Icon(
                    Icons.auto_awesome,
                    color: Colors.white,
                    size: 32,
                  ),
                  const SizedBox(height: 12),
                  const Text(
                    'Generate Learning Content',
                    style: TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Use AI to create personalized courses and modules based on your learning needs',
                    style: TextStyle(
                      fontSize: 16,
                      color: Colors.white.withOpacity(0.9),
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 32),

            // Prompt Templates Section
            Text(
              'Quick Start Templates',
              style: theme.textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 16),

            SizedBox(
              height: 120,
              child: ListView.builder(
                scrollDirection: Axis.horizontal,
                itemCount: _promptTemplates.length,
                itemBuilder: (context, index) {
                  final template = _promptTemplates[index];
                  return Container(
                    width: 200,
                    margin: const EdgeInsets.only(right: 12),
                    child: Card(
                      elevation: 2,
                      child: InkWell(
                        onTap: () => _useTemplate(template['prompt']!),
                        borderRadius: BorderRadius.circular(16),
                        child: Padding(
                          padding: const EdgeInsets.all(16),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                template['title']!,
                                style: theme.textTheme.titleSmall?.copyWith(
                                  fontWeight: FontWeight.bold,
                                ),
                                maxLines: 2,
                                overflow: TextOverflow.ellipsis,
                              ),
                              const Spacer(),
                              Text(
                                'Tap to use template',
                                style: theme.textTheme.bodySmall?.copyWith(
                                  color: isDark ? AppColors.darkTextSecondary : Colors.grey.shade600,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                  );
                },
              ),
            ),

            const SizedBox(height: 32),

            // Custom Prompt Section
            Text(
              'Custom Prompt',
              style: theme.textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 16),

            Container(
              decoration: BoxDecoration(
                color: theme.cardColor,
                borderRadius: BorderRadius.circular(12),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(isDark ? 0.2 : 0.05),
                    blurRadius: 10,
                    offset: const Offset(0, 2),
                  ),
                ],
              ),
              child: TextField(
                controller: _promptController,
                maxLines: 4,
                style: theme.textTheme.bodyMedium,
                decoration: InputDecoration(
                  hintText:
                      'Enter your prompt here...\n\nExample: "Create a beginner-friendly course about artificial intelligence with practical examples and hands-on projects"',
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: BorderSide.none,
                  ),
                  filled: true,
                  fillColor: theme.cardColor,
                  contentPadding: const EdgeInsets.all(16),
                  hintStyle: TextStyle(
                    color: isDark ? AppColors.darkTextTertiary : Colors.grey.shade500,
                    fontSize: 14,
                  ),
                ),
              ),
            ),

            const SizedBox(height: 24),

            // Error Message
            if (_errorMessage != null)
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(16),
                margin: const EdgeInsets.only(bottom: 16),
                decoration: BoxDecoration(
                  color: Colors.red.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(color: Colors.red.withOpacity(0.3)),
                ),
                child: Row(
                  children: [
                    const Icon(Icons.error_outline, color: Colors.red),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Text(
                        _errorMessage!,
                        style: const TextStyle(color: Colors.red),
                      ),
                    ),
                  ],
                ),
              ),

            // Generate Button
            SizedBox(
              width: double.infinity,
              height: 56,
              child: ElevatedButton(
                onPressed: _isLoading ? null : _generateContent,
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.primary,
                  foregroundColor: Colors.white,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  elevation: 2,
                ),
                child: _isLoading
                    ? const Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          SizedBox(
                            width: 20,
                            height: 20,
                            child: CircularProgressIndicator(
                              strokeWidth: 2,
                              valueColor:
                                  AlwaysStoppedAnimation<Color>(Colors.white),
                            ),
                          ),
                          SizedBox(width: 12),
                          Text('Generating Content...'),
                        ],
                      )
                    : const Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(Icons.auto_awesome),
                          SizedBox(width: 8),
                          Text(
                            'Generate Course',
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ],
                      ),
              ),
            ),

            const SizedBox(height: 24),

            // Tips Section
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: AppColors.primary.withOpacity(isDark ? 0.12 : 0.08),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: AppColors.primary.withOpacity(isDark ? 0.25 : 0.15)),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      const Icon(Icons.lightbulb_outline,
                          color: AppColors.primary),
                      const SizedBox(width: 8),
                      Text(
                        'Tips for Better Results',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                          color: isDark ? AppColors.darkTextPrimary : AppColors.primaryDark,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  Text(
                    '• Be specific about the topic and target audience\n'
                    '• Mention the difficulty level (beginner, intermediate, advanced)\n'
                    '• Include any specific technologies or tools you want covered\n'
                    '• Specify if you want practical examples or theoretical content',
                    style: TextStyle(
                      color: isDark ? AppColors.darkTextSecondary : AppColors.primary,
                      fontSize: 14,
                      height: 1.5,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  @override
  void dispose() {
    _promptController.dispose();
    super.dispose();
  }
}
