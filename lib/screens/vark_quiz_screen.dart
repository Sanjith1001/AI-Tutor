import 'package:flutter/material.dart';
import '../models/vark_model.dart';
import 'course_selection_screen.dart';
import '../services/activity_service.dart';

class VARKQuizScreen extends StatefulWidget {
  const VARKQuizScreen({super.key});

  @override
  State<VARKQuizScreen> createState() => _VARKQuizScreenState();
}

class _VARKQuizScreenState extends State<VARKQuizScreen> {
  int currentQuestionIndex = 0;
  Map<String, int> scores = {'V': 0, 'A': 0, 'R': 0, 'K': 0};
  List<VARKQuestion> questions = VARKQuizData.getQuestions();
  String? selectedAnswer;
  bool isQuizCompleted = false;
  VARKResult? result;

  void _selectAnswer(String answer, String learningStyle) {
    setState(() {
      selectedAnswer = answer;
    });
  }

  void _nextQuestion() {
    if (selectedAnswer == null) return;

    // Find the learning style for the selected answer
    String learningStyle = '';
    questions[currentQuestionIndex].options.forEach((option, style) {
      if (option == selectedAnswer) {
        learningStyle = style;
      }
    });

    // Update scores
    scores[learningStyle] = scores[learningStyle]! + 1;

    if (currentQuestionIndex < questions.length - 1) {
      setState(() {
        currentQuestionIndex++;
        selectedAnswer = null;
      });
    } else {
      _completeQuiz();
    }
  }

  void _completeQuiz() async {
    // Determine dominant learning style
    String dominantStyle = scores.entries
        .reduce((a, b) => a.value > b.value ? a : b)
        .key;

    String dominantStyleName = _getStyleName(dominantStyle);

    result = VARKResult(
      visual: scores['V']!,
      auditory: scores['A']!,
      readingWriting: scores['R']!,
      kinesthetic: scores['K']!,
      dominantStyle: dominantStyleName,
      completedAt: DateTime.now(),
    );

    // Save learning style and add activity
    await ActivityService.setLearningStyle(dominantStyleName);

    setState(() {
      isQuizCompleted = true;
    });
  }

  String _getStyleName(String code) {
    switch (code) {
      case 'V':
        return 'Visual';
      case 'A':
        return 'Auditory';
      case 'R':
        return 'Reading/Writing';
      case 'K':
        return 'Kinesthetic';
      default:
        return 'Mixed';
    }
  }

  String _getStyleDescription(String style) {
    switch (style) {
      case 'Visual':
        return 'You learn best through visual aids like charts, diagrams, videos, and images. You prefer to see information presented visually.';
      case 'Auditory':
        return 'You learn best through listening. Podcasts, discussions, lectures, and audio content work well for you.';
      case 'Reading/Writing':
        return 'You learn best through reading and writing. Text-based materials, note-taking, and written exercises are your preference.';
      case 'Kinesthetic':
        return 'You learn best through hands-on experience and movement. Interactive activities and practical applications work best for you.';
      default:
        return 'You have a balanced learning style that benefits from multiple approaches.';
    }
  }

  void _proceedToCourseSelection() {
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(
        builder: (context) => CourseSelectionScreen(varkResult: result!),
      ),
    );
  }

  Future<bool> _hasAlreadyCompletedVARK() async {
    final learningStyle = await ActivityService.getLearningStyle();
    return learningStyle != null;
  }

  void _skipQuiz() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Row(
          children: [
            Icon(Icons.warning, color: Colors.orange),
            SizedBox(width: 8),
            Text('Skip Quiz (Testing)'),
          ],
        ),
        content: const Text(
          'This will skip the VARK assessment and use default "Visual" learning style for testing purposes.\n\nFor best results, complete the full assessment.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(context); // Close dialog
              
              // Create a default VARK result for testing purposes
              final defaultResult = VARKResult(
                visual: 3,
                auditory: 2,
                readingWriting: 2,
                kinesthetic: 3,
                dominantStyle: 'Visual', // Default to Visual for testing
                completedAt: DateTime.now(),
              );

              Navigator.pushReplacement(
                context,
                MaterialPageRoute(
                  builder: (context) => CourseSelectionScreen(varkResult: defaultResult),
                ),
              );
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.orange,
              foregroundColor: Colors.white,
            ),
            child: const Text('Skip Quiz'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<bool>(
      future: _hasAlreadyCompletedVARK(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Scaffold(
            body: Center(child: CircularProgressIndicator()),
          );
        }

        if (snapshot.data == true) {
          return _buildAlreadyCompletedScreen();
        }

        if (isQuizCompleted && result != null) {
          return _buildResultScreen();
        }

        return _buildQuizScreen();
      },
    );
  }

  Widget _buildAlreadyCompletedScreen() {
    return Scaffold(
      backgroundColor: Colors.grey.shade50,
      appBar: AppBar(
        title: const Text('Assessment Already Completed'),
        backgroundColor: Colors.green.shade600,
        foregroundColor: Colors.white,
        elevation: 0,
      ),
      body: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(24),
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [Colors.green.shade600, Colors.green.shade400],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
                borderRadius: BorderRadius.circular(16),
                boxShadow: [
                  BoxShadow(
                    color: Colors.green.withOpacity(0.3),
                    blurRadius: 10,
                    offset: const Offset(0, 4),
                  ),
                ],
              ),
              child: Column(
                children: [
                  const Icon(
                    Icons.check_circle,
                    color: Colors.white,
                    size: 64,
                  ),
                  const SizedBox(height: 16),
                  const Text(
                    'Assessment Already Completed!',
                    style: TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  ),
                  const SizedBox(height: 8),
                  FutureBuilder<String?>(
                    future: ActivityService.getLearningStyle(),
                    builder: (context, snapshot) {
                      return Text(
                        'Your learning style: ${snapshot.data ?? 'Loading...'}',
                        style: const TextStyle(
                          fontSize: 18,
                          color: Colors.white,
                          fontWeight: FontWeight.w600,
                        ),
                        textAlign: TextAlign.center,
                      );
                    },
                  ),
                  const SizedBox(height: 16),
                  Text(
                    'You have already completed the VARK Learning Style Assessment. Your learning preferences have been saved and are being used to personalize your content.',
                    style: TextStyle(
                      fontSize: 16,
                      color: Colors.white.withOpacity(0.9),
                    ),
                    textAlign: TextAlign.center,
                  ),
                ],
              ),
            ),
            const SizedBox(height: 32),
            SizedBox(
              width: double.infinity,
              height: 56,
              child: ElevatedButton(
                onPressed: () => Navigator.pop(context),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.green.shade600,
                  foregroundColor: Colors.white,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  elevation: 4,
                ),
                child: const Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(Icons.arrow_back),
                    SizedBox(width: 8),
                    Text(
                      'Back to Courses',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildQuizScreen() {
    return Scaffold(
      backgroundColor: Colors.grey.shade50,
      appBar: AppBar(
        title: const Text('Learning Style Assessment'),
        backgroundColor: Colors.blue.shade600,
        foregroundColor: Colors.white,
        elevation: 0,
        actions: [
          // Skip button for testing
          TextButton(
            onPressed: _skipQuiz,
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
              decoration: BoxDecoration(
                color: Colors.white.withOpacity(0.2),
                borderRadius: BorderRadius.circular(8),
              ),
              child: const Text(
                'Skip (Test)',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 14,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ),
          const SizedBox(width: 8),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Progress indicator
            Container(
              width: double.infinity,
              height: 8,
              decoration: BoxDecoration(
                color: Colors.grey.shade300,
                borderRadius: BorderRadius.circular(4),
              ),
              child: FractionallySizedBox(
                alignment: Alignment.centerLeft,
                widthFactor: (currentQuestionIndex + 1) / questions.length,
                child: Container(
                  decoration: BoxDecoration(
                    color: Colors.blue.shade600,
                    borderRadius: BorderRadius.circular(4),
                  ),
                ),
              ),
            ),
            
            const SizedBox(height: 16),
            
            Text(
              'Question ${currentQuestionIndex + 1} of ${questions.length}',
              style: TextStyle(
                fontSize: 16,
                color: Colors.grey.shade600,
                fontWeight: FontWeight.w500,
              ),
            ),
            
            const SizedBox(height: 24),
            
            // Question
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(24),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(16),
                boxShadow: [
                  BoxShadow(
                    color: Colors.grey.withOpacity(0.1),
                    blurRadius: 10,
                    offset: const Offset(0, 2),
                  ),
                ],
              ),
              child: Text(
                questions[currentQuestionIndex].question,
                style: const TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  color: Colors.black87,
                ),
              ),
            ),
            
            const SizedBox(height: 24),
            
            // Options
            Expanded(
              child: ListView.builder(
                itemCount: questions[currentQuestionIndex].options.length,
                itemBuilder: (context, index) {
                  final option = questions[currentQuestionIndex].options.keys.elementAt(index);
                  final isSelected = selectedAnswer == option;
                  
                  return Container(
                    margin: const EdgeInsets.only(bottom: 12),
                    child: InkWell(
                      onTap: () => _selectAnswer(option, questions[currentQuestionIndex].options[option]!),
                      borderRadius: BorderRadius.circular(12),
                      child: Container(
                        padding: const EdgeInsets.all(20),
                        decoration: BoxDecoration(
                          color: isSelected ? Colors.blue.shade50 : Colors.white,
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(
                            color: isSelected ? Colors.blue.shade600 : Colors.grey.shade300,
                            width: isSelected ? 2 : 1,
                          ),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.grey.withOpacity(0.1),
                              blurRadius: 4,
                              offset: const Offset(0, 2),
                            ),
                          ],
                        ),
                        child: Row(
                          children: [
                            Container(
                              width: 20,
                              height: 20,
                              decoration: BoxDecoration(
                                shape: BoxShape.circle,
                                border: Border.all(
                                  color: isSelected ? Colors.blue.shade600 : Colors.grey.shade400,
                                  width: 2,
                                ),
                                color: isSelected ? Colors.blue.shade600 : Colors.transparent,
                              ),
                              child: isSelected
                                  ? const Icon(
                                      Icons.check,
                                      size: 14,
                                      color: Colors.white,
                                    )
                                  : null,
                            ),
                            const SizedBox(width: 16),
                            Expanded(
                              child: Text(
                                option,
                                style: TextStyle(
                                  fontSize: 16,
                                  color: isSelected ? Colors.blue.shade800 : Colors.black87,
                                  fontWeight: isSelected ? FontWeight.w600 : FontWeight.normal,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  );
                },
              ),
            ),
            
            // Next button
            SizedBox(
              width: double.infinity,
              height: 56,
              child: ElevatedButton(
                onPressed: selectedAnswer != null ? _nextQuestion : null,
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.blue.shade600,
                  foregroundColor: Colors.white,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  elevation: 4,
                ),
                child: Text(
                  currentQuestionIndex < questions.length - 1 ? 'Next Question' : 'Complete Quiz',
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildResultScreen() {
    return Scaffold(
      backgroundColor: Colors.grey.shade50,
      appBar: AppBar(
        title: const Text('Your Learning Style'),
        backgroundColor: Colors.green.shade600,
        foregroundColor: Colors.white,
        elevation: 0,
        automaticallyImplyLeading: false,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Congratulations header
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(24),
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [Colors.green.shade600, Colors.green.shade400],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
                borderRadius: BorderRadius.circular(16),
                boxShadow: [
                  BoxShadow(
                    color: Colors.green.withOpacity(0.3),
                    blurRadius: 10,
                    offset: const Offset(0, 4),
                  ),
                ],
              ),
              child: Column(
                children: [
                  const Icon(
                    Icons.psychology,
                    color: Colors.white,
                    size: 48,
                  ),
                  const SizedBox(height: 16),
                  const Text(
                    'Assessment Complete!',
                    style: TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Your dominant learning style is',
                    style: TextStyle(
                      fontSize: 16,
                      color: Colors.white.withOpacity(0.9),
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    result!.dominantStyle,
                    style: const TextStyle(
                      fontSize: 28,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  ),
                ],
              ),
            ),
            
            const SizedBox(height: 24),
            
            // Description
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(20),
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
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'What this means:',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: Colors.black87,
                    ),
                  ),
                  const SizedBox(height: 12),
                  Text(
                    _getStyleDescription(result!.dominantStyle),
                    style: const TextStyle(
                      fontSize: 16,
                      color: Colors.black87,
                      height: 1.5,
                    ),
                  ),
                ],
              ),
            ),
            
            const SizedBox(height: 24),
            
            // Detailed scores
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(20),
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
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Your Learning Style Breakdown:',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: Colors.black87,
                    ),
                  ),
                  const SizedBox(height: 16),
                  _buildScoreBar('Visual', result!.visual, Colors.blue),
                  _buildScoreBar('Auditory', result!.auditory, Colors.green),
                  _buildScoreBar('Reading/Writing', result!.readingWriting, Colors.orange),
                  _buildScoreBar('Kinesthetic', result!.kinesthetic, Colors.purple),
                ],
              ),
            ),
            
            const SizedBox(height: 32),
            
            // Continue button
            SizedBox(
              width: double.infinity,
              height: 56,
              child: ElevatedButton(
                onPressed: _proceedToCourseSelection,
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.green.shade600,
                  foregroundColor: Colors.white,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  elevation: 4,
                ),
                child: const Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(Icons.arrow_forward),
                    SizedBox(width: 8),
                    Text(
                      'Continue to Course Selection',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildScoreBar(String label, int score, Color color) {
    double percentage = score / questions.length;
    
    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                label,
                style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                  color: Colors.black87,
                ),
              ),
              Text(
                '$score/${questions.length}',
                style: TextStyle(
                  fontSize: 14,
                  color: Colors.grey.shade600,
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Container(
            width: double.infinity,
            height: 8,
            decoration: BoxDecoration(
              color: Colors.grey.shade300,
              borderRadius: BorderRadius.circular(4),
            ),
            child: FractionallySizedBox(
              alignment: Alignment.centerLeft,
              widthFactor: percentage,
              child: Container(
                decoration: BoxDecoration(
                  color: color,
                  borderRadius: BorderRadius.circular(4),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}