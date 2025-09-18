import 'package:flutter/material.dart';
import '../models/vark_model.dart';
import '../models/skill_assessment_model.dart';

class PersonalizedCourseScreen extends StatefulWidget {
  final VARKResult varkResult;
  final SkillAssessmentResult skillAssessmentResult;
  final Map<String, dynamic> selectedCourse;

  const PersonalizedCourseScreen({
    super.key,
    required this.varkResult,
    required this.skillAssessmentResult,
    required this.selectedCourse,
  });

  @override
  State<PersonalizedCourseScreen> createState() => _PersonalizedCourseScreenState();
}

class _PersonalizedCourseScreenState extends State<PersonalizedCourseScreen> {
  int selectedModuleIndex = 0;
  bool showSimplified = false;

  // Sample course modules based on skill level
  List<Map<String, dynamic>> get courseModules {
    final level = widget.skillAssessmentResult.skillLevel;
    final course = widget.selectedCourse['title'];
    
    switch (course) {
      case 'Mathematics':
        return _getMathModules(level);
      case 'Computer Science':
        return _getComputerScienceModules(level);
      case 'Physics':
        return _getPhysicsModules(level);
      default:
        return _getGeneralModules(level);
    }
  }

  List<Map<String, dynamic>> _getMathModules(String level) {
    if (level == 'Beginner') {
      return [
        {
          'title': 'Basic Arithmetic',
          'content': 'Arithmetic is the foundation of mathematics. It involves basic operations like addition, subtraction, multiplication, and division.\n\nAddition combines numbers to get a sum. For example: 5 + 3 = 8\nSubtraction finds the difference between numbers. For example: 8 - 3 = 5\nMultiplication is repeated addition. For example: 4 × 3 = 12 (adding 4 three times)\nDivision splits numbers into equal parts. For example: 12 ÷ 3 = 4',
          'simplified': 'Basic math operations: +, -, ×, ÷\n• Addition: combining numbers\n• Subtraction: taking away\n• Multiplication: repeated addition\n• Division: splitting into equal parts',
          'examples': [
            '5 + 7 = 12',
            '15 - 6 = 9',
            '8 × 4 = 32',
            '20 ÷ 5 = 4'
          ],
          'videoKeywords': 'basic arithmetic operations elementary math',
        },
        {
          'title': 'Fractions and Decimals',
          'content': 'Fractions represent parts of a whole. A fraction has a numerator (top number) and denominator (bottom number).\n\nFor example, 1/2 means one part out of two equal parts.\nDecimals are another way to represent fractions. 0.5 is the same as 1/2.\n\nTo add fractions with the same denominator, add the numerators: 1/4 + 2/4 = 3/4\nTo convert fractions to decimals, divide the numerator by the denominator.',
          'simplified': 'Fractions = parts of a whole\n• 1/2 = 0.5 (half)\n• 1/4 = 0.25 (quarter)\n• Add fractions: same bottom number, add top numbers\n• Convert: divide top by bottom',
          'examples': [
            '1/2 + 1/4 = 2/4 + 1/4 = 3/4',
            '3/4 = 0.75',
            '0.25 = 1/4'
          ],
          'videoKeywords': 'fractions decimals elementary math',
        }
      ];
    } else if (level == 'Intermediate') {
      return [
        {
          'title': 'Algebra Basics',
          'content': 'Algebra uses letters (variables) to represent unknown numbers. The most common variable is x.\n\nSolving equations means finding the value of the variable that makes the equation true.\n\nFor example: x + 5 = 12\nTo solve this, subtract 5 from both sides: x = 12 - 5 = 7\n\nBasic rules:\n• What you do to one side, do to the other\n• Opposite operations cancel out (+ and -, × and ÷)',
          'simplified': 'Algebra uses letters for unknown numbers\n• x + 5 = 12, so x = 7\n• Same operation on both sides\n• Opposite operations cancel',
          'examples': [
            '2x = 10, so x = 5',
            'x - 3 = 7, so x = 10',
            '3x + 2 = 14, so x = 4'
          ],
          'videoKeywords': 'basic algebra solving equations',
        }
      ];
    } else {
      return [
        {
          'title': 'Calculus Introduction',
          'content': 'Calculus is the study of change and motion. It has two main branches: differential calculus (derivatives) and integral calculus (integrals).\n\nDerivatives measure the rate of change. If you have a function f(x), its derivative f\'(x) tells you how fast f(x) is changing at any point.\n\nFor example, the derivative of x² is 2x. This means at x = 3, the function x² is changing at a rate of 2(3) = 6.',
          'simplified': 'Calculus studies change\n• Derivatives = rate of change\n• d/dx(x²) = 2x\n• At x = 3, rate = 6',
          'examples': [
            'd/dx(x³) = 3x²',
            'd/dx(5x) = 5',
            'd/dx(x² + 3x) = 2x + 3'
          ],
          'videoKeywords': 'calculus derivatives introduction',
        }
      ];
    }
  }

  List<Map<String, dynamic>> _getComputerScienceModules(String level) {
    if (level == 'Beginner') {
      return [
        {
          'title': 'Introduction to Programming',
          'content': 'Programming is giving instructions to a computer. We write code in programming languages like Python, Java, or JavaScript.\n\nA program is a set of instructions that tells the computer what to do. These instructions are executed step by step.\n\nBasic concepts:\n• Variables: store data (like x = 5)\n• Functions: reusable blocks of code\n• Loops: repeat actions\n• Conditions: make decisions (if/else)',
          'simplified': 'Programming = giving instructions to computers\n• Variables store data\n• Functions are reusable code\n• Loops repeat actions\n• If/else makes decisions',
          'examples': [
            'x = 10 (variable)',
            'print("Hello") (function)',
            'for i in range(5): (loop)',
            'if x > 5: (condition)'
          ],
          'videoKeywords': 'programming basics introduction variables',
        }
      ];
    }
    return [];
  }

  List<Map<String, dynamic>> _getPhysicsModules(String level) {
    if (level == 'Beginner') {
      return [
        {
          'title': 'Motion and Forces',
          'content': 'Motion is when objects change position over time. Force is a push or pull that can change an object\'s motion.\n\nNewton\'s First Law: An object at rest stays at rest, and an object in motion stays in motion, unless acted upon by a force.\n\nSpeed = Distance ÷ Time\nFor example, if you travel 100 meters in 10 seconds, your speed is 10 m/s.',
          'simplified': 'Motion = changing position\nForce = push or pull\nSpeed = Distance ÷ Time\nObjects keep doing what they\'re doing unless forced to change',
          'examples': [
            'Car traveling 60 km in 1 hour = 60 km/h',
            'Ball rolling until friction stops it',
            'Pushing a box to make it move'
          ],
          'videoKeywords': 'physics motion forces Newton laws',
        }
      ];
    }
    return [];
  }

  List<Map<String, dynamic>> _getGeneralModules(String level) {
    return [
      {
        'title': 'Getting Started',
        'content': 'Welcome to your personalized learning journey! This course is tailored to your learning style and skill level.',
        'simplified': 'Welcome! This course is made just for you.',
        'examples': ['Personalized content', 'Your pace', 'Your style'],
        'videoKeywords': 'introduction getting started',
      }
    ];
  }

  String _getPersonalizedContent(Map<String, dynamic> module) {
    final learningStyle = widget.varkResult.dominantStyle;
    String content = showSimplified ? module['simplified'] : module['content'];
    
    // Add learning style specific suggestions
    switch (learningStyle) {
      case 'Visual':
        content += '\n\n📊 Visual Learning Tips:\n• Draw diagrams and charts\n• Use colors to highlight key points\n• Create mind maps\n• Watch the recommended videos below';
        break;
      case 'Auditory':
        content += '\n\n🎧 Auditory Learning Tips:\n• Read the content aloud\n• Discuss with others\n• Listen to related podcasts\n• Use text-to-speech features';
        break;
      case 'Reading/Writing':
        content += '\n\n📝 Reading/Writing Tips:\n• Take detailed notes\n• Rewrite key concepts\n• Create summaries\n• Practice with written exercises';
        break;
      case 'Kinesthetic':
        content += '\n\n🤲 Kinesthetic Learning Tips:\n• Practice with hands-on activities\n• Use physical objects when possible\n• Take breaks to move around\n• Apply concepts in real situations';
        break;
    }
    
    return content;
  }

  @override
  Widget build(BuildContext context) {
    final currentModule = courseModules.isNotEmpty ? courseModules[selectedModuleIndex] : null;
    
    return Scaffold(
      backgroundColor: Colors.grey.shade50,
      appBar: AppBar(
        title: Text(widget.selectedCourse['title']),
        backgroundColor: widget.selectedCourse['color'],
        foregroundColor: Colors.white,
        elevation: 0,
        actions: [
          IconButton(
            icon: const Icon(Icons.dashboard),
            onPressed: () {
              // Navigate to dashboard
            },
          ),
        ],
      ),
      body: courseModules.isEmpty 
        ? _buildEmptyState()
        : Row(
            children: [
              // Module list sidebar
              Container(
                width: 300,
                color: Colors.white,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // User info header
                    Container(
                      width: double.infinity,
                      padding: const EdgeInsets.all(20),
                      decoration: BoxDecoration(
                        color: widget.selectedCourse['color'].withOpacity(0.1),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Learning Style: ${widget.varkResult.dominantStyle}',
                            style: TextStyle(
                              fontSize: 14,
                              fontWeight: FontWeight.bold,
                              color: widget.selectedCourse['color'],
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            'Level: ${widget.skillAssessmentResult.skillLevel}',
                            style: TextStyle(
                              fontSize: 14,
                              color: Colors.grey.shade600,
                            ),
                          ),
                        ],
                      ),
                    ),
                    
                    // Modules list
                    Expanded(
                      child: ListView.builder(
                        itemCount: courseModules.length,
                        itemBuilder: (context, index) {
                          final module = courseModules[index];
                          final isSelected = index == selectedModuleIndex;
                          
                          return Container(
                            margin: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                            child: InkWell(
                              onTap: () {
                                setState(() {
                                  selectedModuleIndex = index;
                                });
                              },
                              borderRadius: BorderRadius.circular(8),
                              child: Container(
                                padding: const EdgeInsets.all(16),
                                decoration: BoxDecoration(
                                  color: isSelected ? widget.selectedCourse['color'].withOpacity(0.1) : null,
                                  borderRadius: BorderRadius.circular(8),
                                  border: isSelected ? Border.all(color: widget.selectedCourse['color']) : null,
                                ),
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      '${index + 1}. ${module['title']}',
                                      style: TextStyle(
                                        fontSize: 16,
                                        fontWeight: FontWeight.bold,
                                        color: isSelected ? widget.selectedCourse['color'] : Colors.black87,
                                      ),
                                    ),
                                    if (isSelected) ...[
                                      const SizedBox(height: 8),
                                      LinearProgressIndicator(
                                        value: 0.3, // This would come from user progress
                                        backgroundColor: Colors.grey.shade300,
                                        valueColor: AlwaysStoppedAnimation<Color>(widget.selectedCourse['color']),
                                      ),
                                      const SizedBox(height: 4),
                                      Text(
                                        '30% Complete',
                                        style: TextStyle(
                                          fontSize: 12,
                                          color: Colors.grey.shade600,
                                        ),
                                      ),
                                    ],
                                  ],
                                ),
                              ),
                            ),
                          );
                        },
                      ),
                    ),
                  ],
                ),
              ),
              
              // Main content area
              Expanded(
                child: currentModule != null ? _buildContentArea(currentModule) : _buildEmptyState(),
              ),
            ],
          ),
    );
  }

  Widget _buildContentArea(Map<String, dynamic> module) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Module header
          Row(
            children: [
              Expanded(
                child: Text(
                  module['title'],
                  style: const TextStyle(
                    fontSize: 28,
                    fontWeight: FontWeight.bold,
                    color: Colors.black87,
                  ),
                ),
              ),
              // Toggle simplified view
              Row(
                children: [
                  Text(
                    'Simplified',
                    style: TextStyle(
                      fontSize: 14,
                      color: Colors.grey.shade600,
                    ),
                  ),
                  const SizedBox(width: 8),
                  Switch(
                    value: showSimplified,
                    onChanged: (value) {
                      setState(() {
                        showSimplified = value;
                      });
                    },
                    activeColor: widget.selectedCourse['color'],
                  ),
                ],
              ),
            ],
          ),
          
          const SizedBox(height: 24),
          
          // Main content
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(24),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(12),
              boxShadow: [
                BoxShadow(
                  color: Colors.grey.withOpacity(0.1),
                  blurRadius: 10,
                  offset: const Offset(0, 2),
                ),
              ],
            ),
            child: Text(
              _getPersonalizedContent(module),
              style: const TextStyle(
                fontSize: 16,
                height: 1.6,
                color: Colors.black87,
              ),
            ),
          ),
          
          const SizedBox(height: 24),
          
          // Examples section
          if (module['examples'] != null && module['examples'].isNotEmpty)
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: Colors.blue.shade50,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: Colors.blue.shade200),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Icon(Icons.lightbulb_outline, color: Colors.blue.shade600),
                      const SizedBox(width: 8),
                      Text(
                        'Examples',
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          color: Colors.blue.shade800,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  ...module['examples'].map<Widget>((example) => Padding(
                    padding: const EdgeInsets.only(bottom: 8),
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text('• ', style: TextStyle(color: Colors.blue.shade600, fontSize: 16)),
                        Expanded(
                          child: Text(
                            example,
                            style: TextStyle(
                              fontSize: 16,
                              color: Colors.blue.shade700,
                            ),
                          ),
                        ),
                      ],
                    ),
                  )).toList(),
                ],
              ),
            ),
          
          const SizedBox(height: 24),
          
          // Videos section
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: Colors.red.shade50,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: Colors.red.shade200),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Icon(Icons.play_circle_outline, color: Colors.red.shade600),
                    const SizedBox(width: 8),
                    Text(
                      'Recommended Videos',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: Colors.red.shade800,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                Text(
                  'Search YouTube for: "${module['videoKeywords']}"',
                  style: TextStyle(
                    fontSize: 16,
                    color: Colors.red.shade700,
                  ),
                ),
                const SizedBox(height: 12),
                ElevatedButton.icon(
                  onPressed: () {
                    // This would open YouTube search or embedded videos
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text('Opening YouTube search...')),
                    );
                  },
                  icon: const Icon(Icons.video_library),
                  label: const Text('Find Videos'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.red.shade600,
                    foregroundColor: Colors.white,
                  ),
                ),
              ],
            ),
          ),
          
          const SizedBox(height: 24),
          
          // Quiz button
          Center(
            child: ElevatedButton.icon(
              onPressed: () {
                // Navigate to quiz for this module
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Quiz feature coming soon!')),
                );
              },
              icon: const Icon(Icons.quiz),
              label: const Text('Take Quiz'),
              style: ElevatedButton.styleFrom(
                backgroundColor: widget.selectedCourse['color'],
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 16),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildEmptyState() {
    return const Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.school, size: 64, color: Colors.grey),
          SizedBox(height: 16),
          Text(
            'Course content is being prepared...',
            style: TextStyle(fontSize: 18, color: Colors.grey),
          ),
        ],
      ),
    );
  }
}