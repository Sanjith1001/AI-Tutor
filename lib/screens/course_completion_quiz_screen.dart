import 'package:flutter/material.dart';
import '../services/activity_service.dart';
import '../services/groq_service.dart';

class CourseCompletionQuizScreen extends StatefulWidget {
  final String courseTitle;
  final String moduleTitle;
  final String learningStyle;
  final String skillLevel;

  const CourseCompletionQuizScreen({
    super.key,
    required this.courseTitle,
    required this.moduleTitle,
    required this.learningStyle,
    required this.skillLevel,
  });

  @override
  State<CourseCompletionQuizScreen> createState() => _CourseCompletionQuizScreenState();
}

class _CourseCompletionQuizScreenState extends State<CourseCompletionQuizScreen> {
  List<Map<String, dynamic>> questions = [];
  int currentQuestionIndex = 0;
  int score = 0;
  String? selectedAnswer;
  bool isQuizCompleted = false;
  bool isLoading = true;
  final GroqService _groqService = GroqService();

  @override
  void initState() {
    super.initState();
    _generateQuizQuestions();
  }

  Future<void> _generateQuizQuestions() async {
    try {
      final prompt = '''
Generate 5 multiple choice questions to test understanding of ${widget.moduleTitle} for ${widget.skillLevel} level learners.

Format each question as:
Q: [Question text]
A) [Option A]
B) [Option B] 
C) [Option C]
D) [Option D]
Correct: [A/B/C/D]

Make questions practical and test real understanding, not just memorization.
''';

      final response = await _groqService.generateTextContent(prompt);
      _parseQuestions(response);
    } catch (e) {
      _generateFallbackQuestions();
    }
  }

  void _parseQuestions(String response) {
    final lines = response.split('\n');
    List<Map<String, dynamic>> parsedQuestions = [];
    
    String? currentQuestion;
    List<String> options = [];
    String? correctAnswer;
    
    for (String line in lines) {
      line = line.trim();
      if (line.startsWith('Q:')) {
        currentQuestion = line.substring(2).trim();
      } else if (line.startsWith('A)') || line.startsWith('B)') || line.startsWith('C)') || line.startsWith('D)')) {
        options.add(line.substring(2).trim());
      } else if (line.startsWith('Correct:')) {
        correctAnswer = line.substring(8).trim();
        
        if (currentQuestion != null && currentQuestion.isNotEmpty && options.length == 4 && correctAnswer != null && correctAnswer.isNotEmpty) {
          int correctIndex = ['A', 'B', 'C', 'D'].indexOf(correctAnswer);
          if (correctIndex != -1) {
            parsedQuestions.add({
              'question': currentQuestion,
              'options': List<String>.from(options),
              'correctIndex': correctIndex,
            });
          }
        }
        
        // Reset for next question
        currentQuestion = null;
        options.clear();
        correctAnswer = null;
      }
    }
    
    setState(() {
      questions = parsedQuestions.isNotEmpty ? parsedQuestions : _getFallbackQuestions();
      isLoading = false;
    });
  }

  void _generateFallbackQuestions() {
    setState(() {
      questions = _getFallbackQuestions();
      isLoading = false;
    });
  }

  List<Map<String, dynamic>> _getFallbackQuestions() {
    return [
      {
        'question': 'What is the main purpose of ${widget.moduleTitle}?',
        'options': [
          'To organize and manipulate data efficiently',
          'To create user interfaces',
          'To manage network connections',
          'To handle file operations'
        ],
        'correctIndex': 0,
      },
      {
        'question': 'Which characteristic is most important for ${widget.moduleTitle}?',
        'options': [
          'Visual appearance',
          'Performance and efficiency',
          'Color scheme',
          'Font size'
        ],
        'correctIndex': 1,
      },
      {
        'question': 'When should you consider using ${widget.moduleTitle}?',
        'options': [
          'Only for large applications',
          'When you need to organize data systematically',
          'Only for web development',
          'Never, it\'s outdated'
        ],
        'correctIndex': 1,
      },
      {
        'question': 'What is a key benefit of understanding ${widget.moduleTitle}?',
        'options': [
          'Better user interface design',
          'Improved algorithm efficiency',
          'Faster internet connection',
          'Better graphics rendering'
        ],
        'correctIndex': 1,
      },
      {
        'question': 'How does ${widget.moduleTitle} relate to problem-solving?',
        'options': [
          'It has no relation to problem-solving',
          'It only helps with mathematical problems',
          'It provides systematic approaches to organize and process information',
          'It only works for simple problems'
        ],
        'correctIndex': 2,
      },
    ];
  }

  void _selectAnswer(String answer) {
    setState(() {
      selectedAnswer = answer;
    });
  }

  void _nextQuestion() {
    if (selectedAnswer == null) return;

    final currentQuestion = questions[currentQuestionIndex];
    final selectedIndex = currentQuestion['options'].indexOf(selectedAnswer!);
    final isCorrect = selectedIndex == currentQuestion['correctIndex'];
    
    if (isCorrect) {
      score++;
    }

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
    final percentage = (score / questions.length * 100).round();
    
    // Add activity for course completion
    await ActivityService.addActivity(
      type: ActivityService.activityCourse,
      title: 'Completed ${widget.courseTitle} - ${widget.moduleTitle}',
      description: 'Final Quiz Score: $percentage% ($score/${questions.length})',
      metadata: {
        'score': percentage,
        'courseTitle': widget.courseTitle,
        'moduleTitle': widget.moduleTitle,
        'completed': true,
        'learningStyle': widget.learningStyle,
        'skillLevel': widget.skillLevel,
      },
    );

    setState(() {
      isQuizCompleted = true;
    });
  }

  @override
  Widget build(BuildContext context) {
    if (isLoading) {
      return Scaffold(
        backgroundColor: Colors.blue.shade900,
        appBar: AppBar(
          title: const Text('Course Completion Quiz'),
          backgroundColor: Colors.blue.shade800,
          foregroundColor: Colors.white,
        ),
        body: const Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              CircularProgressIndicator(color: Colors.white),
              SizedBox(height: 16),
              Text(
                'Generating quiz questions...',
                style: TextStyle(color: Colors.white, fontSize: 16),
              ),
            ],
          ),
        ),
      );
    }

    if (isQuizCompleted) {
      return _buildResultScreen();
    }

    return _buildQuizScreen();
  }

  Widget _buildQuizScreen() {
    final currentQuestion = questions[currentQuestionIndex];
    
    return Scaffold(
      backgroundColor: Colors.blue.shade900,
      appBar: AppBar(
        title: const Text('Course Completion Quiz'),
        backgroundColor: Colors.blue.shade800,
        foregroundColor: Colors.white,
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
                color: Colors.white.withOpacity(0.3),
                borderRadius: BorderRadius.circular(4),
              ),
              child: FractionallySizedBox(
                alignment: Alignment.centerLeft,
                widthFactor: (currentQuestionIndex + 1) / questions.length,
                child: Container(
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(4),
                  ),
                ),
              ),
            ),
            
            const SizedBox(height: 16),
            
            Text(
              'Question ${currentQuestionIndex + 1} of ${questions.length}',
              style: const TextStyle(
                fontSize: 16,
                color: Colors.white70,
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
                    color: Colors.black.withOpacity(0.1),
                    blurRadius: 10,
                    offset: const Offset(0, 2),
                  ),
                ],
              ),
              child: Text(
                currentQuestion['question'],
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
                itemCount: currentQuestion['options'].length,
                itemBuilder: (context, index) {
                  final option = currentQuestion['options'][index];
                  final isSelected = selectedAnswer == option;
                  
                  return Container(
                    margin: const EdgeInsets.only(bottom: 12),
                    child: InkWell(
                      onTap: () => _selectAnswer(option),
                      borderRadius: BorderRadius.circular(12),
                      child: Container(
                        padding: const EdgeInsets.all(20),
                        decoration: BoxDecoration(
                          color: isSelected ? Colors.white : Colors.white.withOpacity(0.1),
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(
                            color: isSelected ? Colors.white : Colors.white.withOpacity(0.3),
                            width: 2,
                          ),
                        ),
                        child: Row(
                          children: [
                            Container(
                              width: 20,
                              height: 20,
                              decoration: BoxDecoration(
                                shape: BoxShape.circle,
                                border: Border.all(
                                  color: isSelected ? Colors.blue.shade600 : Colors.white,
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
                                  color: isSelected ? Colors.black87 : Colors.white,
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
                  backgroundColor: Colors.white,
                  foregroundColor: Colors.blue.shade900,
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
    final percentage = (score / questions.length * 100).round();
    final isPassed = percentage >= 70;
    
    return Scaffold(
      backgroundColor: isPassed ? Colors.green.shade900 : Colors.red.shade900,
      appBar: AppBar(
        title: const Text('Quiz Results'),
        backgroundColor: isPassed ? Colors.green.shade800 : Colors.red.shade800,
        foregroundColor: Colors.white,
        automaticallyImplyLeading: false,
      ),
      body: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(32),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(20),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.2),
                    blurRadius: 15,
                    offset: const Offset(0, 5),
                  ),
                ],
              ),
              child: Column(
                children: [
                  Icon(
                    isPassed ? Icons.celebration : Icons.refresh,
                    size: 64,
                    color: isPassed ? Colors.green.shade600 : Colors.red.shade600,
                  ),
                  const SizedBox(height: 20),
                  Text(
                    isPassed ? 'Congratulations!' : 'Keep Learning!',
                    style: const TextStyle(
                      fontSize: 28,
                      fontWeight: FontWeight.bold,
                      color: Colors.black87,
                    ),
                  ),
                  const SizedBox(height: 12),
                  Text(
                    'You scored $score out of ${questions.length}',
                    style: const TextStyle(
                      fontSize: 18,
                      color: Colors.black54,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    '$percentage%',
                    style: TextStyle(
                      fontSize: 48,
                      fontWeight: FontWeight.bold,
                      color: isPassed ? Colors.green.shade600 : Colors.red.shade600,
                    ),
                  ),
                  const SizedBox(height: 16),
                  Text(
                    isPassed 
                        ? 'Excellent work! You have successfully completed the ${widget.moduleTitle} course.'
                        : 'You need 70% to pass. Review the material and try again.',
                    style: const TextStyle(
                      fontSize: 16,
                      color: Colors.black87,
                    ),
                    textAlign: TextAlign.center,
                  ),
                ],
              ),
            ),
            
            const SizedBox(height: 32),
            
            Row(
              children: [
                if (!isPassed) ...[
                  Expanded(
                    child: ElevatedButton(
                      onPressed: () {
                        setState(() {
                          currentQuestionIndex = 0;
                          score = 0;
                          selectedAnswer = null;
                          isQuizCompleted = false;
                        });
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.white,
                        foregroundColor: Colors.red.shade900,
                        padding: const EdgeInsets.symmetric(vertical: 16),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                      child: const Text(
                        'Retry Quiz',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 16),
                ],
                Expanded(
                  child: ElevatedButton(
                    onPressed: () {
                      Navigator.popUntil(context, (route) => route.isFirst);
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.white,
                      foregroundColor: isPassed ? Colors.green.shade900 : Colors.red.shade900,
                      padding: const EdgeInsets.symmetric(vertical: 16),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                    child: const Text(
                      'Back to Home',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}