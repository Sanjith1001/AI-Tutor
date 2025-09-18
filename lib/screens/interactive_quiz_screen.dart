import 'package:flutter/material.dart';
import 'dart:convert';

class InteractiveQuizScreen extends StatefulWidget {
  final String moduleTitle;
  final String quizContent;
  final String? learningStyle;

  const InteractiveQuizScreen({
    super.key,
    required this.moduleTitle,
    required this.quizContent,
    this.learningStyle,
  });

  @override
  State<InteractiveQuizScreen> createState() => _InteractiveQuizScreenState();
}

class _InteractiveQuizScreenState extends State<InteractiveQuizScreen> {
  List<QuizQuestion> questions = [];
  int currentQuestionIndex = 0;
  int score = 0;
  String? selectedAnswer;
  bool isQuizCompleted = false;
  List<bool> correctAnswers = [];
  List<String> userAnswers = [];

  @override
  void initState() {
    super.initState();
    _parseQuizContent();
  }

  void _parseQuizContent() {
    // Parse the quiz content to extract questions
    final lines = widget.quizContent.split('\n');
    String currentQuestion = '';
    List<String> currentOptions = [];
    String currentAnswer = '';
    
    for (String line in lines) {
      line = line.trim();
      if (line.startsWith('### Question') || line.startsWith('Q')) {
        // Save previous question if exists
        if (currentQuestion.isNotEmpty && currentOptions.isNotEmpty) {
          questions.add(QuizQuestion(
            question: currentQuestion,
            options: List.from(currentOptions),
            correctAnswer: currentAnswer,
          ));
        }
        // Start new question
        currentQuestion = line.replaceAll(RegExp(r'### Question \d+|Q\d+:'), '').trim();
        currentOptions.clear();
        currentAnswer = '';
      } else if (line.startsWith('A)') || line.startsWith('B)') || 
                 line.startsWith('C)') || line.startsWith('D)')) {
        currentOptions.add(line);
      } else if (line.startsWith('**Answer:') || line.startsWith('Answer:')) {
        currentAnswer = line.replaceAll('**Answer:', '').replaceAll('Answer:', '').trim();
      }
    }
    
    // Add the last question
    if (currentQuestion.isNotEmpty && currentOptions.isNotEmpty) {
      questions.add(QuizQuestion(
        question: currentQuestion,
        options: List.from(currentOptions),
        correctAnswer: currentAnswer,
      ));
    }

    // If parsing failed, create fallback questions
    if (questions.isEmpty) {
      _createFallbackQuestions();
    }
  }

  void _createFallbackQuestions() {
    questions = [
      QuizQuestion(
        question: 'What is the main purpose of ${widget.moduleTitle}?',
        options: [
          'A) To make programming harder',
          'B) To organize and store data efficiently',
          'C) To slow down programs',
          'D) To confuse developers'
        ],
        correctAnswer: 'B) To organize and store data efficiently',
      ),
      QuizQuestion(
        question: 'Which is a key characteristic of ${widget.moduleTitle}?',
        options: [
          'A) They are always slow',
          'B) They waste memory',
          'C) They improve algorithm efficiency',
          'D) They are unnecessary'
        ],
        correctAnswer: 'C) They improve algorithm efficiency',
      ),
      QuizQuestion(
        question: 'When should you consider using ${widget.moduleTitle}?',
        options: [
          'A) Never',
          'B) Only for small programs',
          'C) When you need efficient data organization',
          'D) Only for games'
        ],
        correctAnswer: 'C) When you need efficient data organization',
      ),
      QuizQuestion(
        question: 'What is Big O notation used for in ${widget.moduleTitle}?',
        options: [
          'A) Naming variables',
          'B) Measuring algorithm complexity',
          'C) Creating loops',
          'D) Defining functions'
        ],
        correctAnswer: 'B) Measuring algorithm complexity',
      ),
      QuizQuestion(
        question: 'Which factor is important when choosing ${widget.moduleTitle}?',
        options: [
          'A) The color of your IDE',
          'B) Performance requirements',
          'C) Your favorite programming language',
          'D) The day of the week'
        ],
        correctAnswer: 'B) Performance requirements',
      ),
    ];
  }

  void _selectAnswer(String answer) {
    setState(() {
      selectedAnswer = answer;
    });
  }

  void _nextQuestion() {
    if (selectedAnswer == null) return;

    // Check if answer is correct
    final currentQuestion = questions[currentQuestionIndex];
    final isCorrect = selectedAnswer == currentQuestion.correctAnswer;
    
    correctAnswers.add(isCorrect);
    userAnswers.add(selectedAnswer!);
    
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

  void _completeQuiz() {
    setState(() {
      isQuizCompleted = true;
    });
  }

  void _restartQuiz() {
    setState(() {
      currentQuestionIndex = 0;
      score = 0;
      selectedAnswer = null;
      isQuizCompleted = false;
      correctAnswers.clear();
      userAnswers.clear();
    });
  }

  @override
  Widget build(BuildContext context) {
    if (isQuizCompleted) {
      return _buildResultScreen();
    }

    if (questions.isEmpty) {
      return Scaffold(
        backgroundColor: const Color(0xFF10141A),
        appBar: AppBar(
          title: Text('${widget.moduleTitle} Quiz'),
          backgroundColor: const Color(0xFF10141A),
          foregroundColor: Colors.white,
        ),
        body: const Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(Icons.error_outline, color: Colors.red, size: 64),
              SizedBox(height: 16),
              Text(
                'Unable to load quiz questions',
                style: TextStyle(color: Colors.white, fontSize: 18),
              ),
            ],
          ),
        ),
      );
    }

    return Scaffold(
      backgroundColor: const Color(0xFF10141A),
      appBar: AppBar(
        title: Text('${widget.moduleTitle} Quiz'),
        backgroundColor: const Color(0xFF10141A),
        foregroundColor: Colors.white,
        actions: [
          Padding(
            padding: const EdgeInsets.only(right: 16.0),
            child: Center(
              child: Text(
                '${currentQuestionIndex + 1}/${questions.length}',
                style: const TextStyle(
                  color: Colors.white70,
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ),
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
                color: Colors.grey.shade800,
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
            
            const SizedBox(height: 24),
            
            // Score display
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'Question ${currentQuestionIndex + 1} of ${questions.length}',
                  style: const TextStyle(
                    fontSize: 16,
                    color: Colors.white70,
                    fontWeight: FontWeight.w500,
                  ),
                ),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                  decoration: BoxDecoration(
                    color: Colors.green.shade900,
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: Colors.green.shade700),
                  ),
                  child: Text(
                    'Score: $score/${correctAnswers.length}',
                    style: TextStyle(
                      fontSize: 14,
                      color: Colors.green.shade300,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ],
            ),
            
            const SizedBox(height: 32),
            
            // Question
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(24),
              decoration: BoxDecoration(
                color: const Color(0xFF1E2328),
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: Colors.grey.shade700),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Question ${currentQuestionIndex + 1}',
                    style: TextStyle(
                      fontSize: 14,
                      color: Colors.blue.shade400,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 12),
                  Text(
                    _formatMathContent(questions[currentQuestionIndex].question),
                    style: const TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                      height: 1.4,
                    ),
                  ),
                ],
              ),
            ),
            
            const SizedBox(height: 24),
            
            // Options
            Expanded(
              child: ListView.builder(
                itemCount: questions[currentQuestionIndex].options.length,
                itemBuilder: (context, index) {
                  final option = questions[currentQuestionIndex].options[index];
                  final isSelected = selectedAnswer == option;
                  
                  return Container(
                    margin: const EdgeInsets.only(bottom: 12),
                    child: InkWell(
                      onTap: () => _selectAnswer(option),
                      borderRadius: BorderRadius.circular(12),
                      child: Container(
                        padding: const EdgeInsets.all(20),
                        decoration: BoxDecoration(
                          color: isSelected 
                              ? Colors.blue.shade900.withOpacity(0.3)
                              : const Color(0xFF1E2328),
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(
                            color: isSelected 
                                ? Colors.blue.shade400 
                                : Colors.grey.shade700,
                            width: isSelected ? 2 : 1,
                          ),
                        ),
                        child: Row(
                          children: [
                            Container(
                              width: 24,
                              height: 24,
                              decoration: BoxDecoration(
                                shape: BoxShape.circle,
                                border: Border.all(
                                  color: isSelected 
                                      ? Colors.blue.shade400 
                                      : Colors.grey.shade500,
                                  width: 2,
                                ),
                                color: isSelected 
                                    ? Colors.blue.shade400 
                                    : Colors.transparent,
                              ),
                              child: isSelected
                                  ? const Icon(
                                      Icons.check,
                                      size: 16,
                                      color: Colors.white,
                                    )
                                  : null,
                            ),
                            const SizedBox(width: 16),
                            Expanded(
                              child: Text(
                                _formatMathContent(option),
                                style: TextStyle(
                                  fontSize: 16,
                                  color: isSelected 
                                      ? Colors.blue.shade300 
                                      : Colors.white70,
                                  fontWeight: isSelected 
                                      ? FontWeight.w600 
                                      : FontWeight.normal,
                                  height: 1.3,
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
                  currentQuestionIndex < questions.length - 1 
                      ? 'Next Question' 
                      : 'Complete Quiz',
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
    final passed = percentage >= 70;
    
    return Scaffold(
      backgroundColor: const Color(0xFF10141A),
      appBar: AppBar(
        title: const Text('Quiz Results'),
        backgroundColor: const Color(0xFF10141A),
        foregroundColor: Colors.white,
        automaticallyImplyLeading: false,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Score header
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(24),
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: passed 
                      ? [Colors.green.shade600, Colors.green.shade400]
                      : [Colors.orange.shade600, Colors.orange.shade400],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
                borderRadius: BorderRadius.circular(16),
              ),
              child: Column(
                children: [
                  Icon(
                    passed ? Icons.emoji_events : Icons.school,
                    color: Colors.white,
                    size: 48,
                  ),
                  const SizedBox(height: 16),
                  Text(
                    passed ? 'Congratulations!' : 'Good Effort!',
                    style: const TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'You scored $score out of ${questions.length}',
                    style: const TextStyle(
                      fontSize: 18,
                      color: Colors.white,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    '$percentage%',
                    style: const TextStyle(
                      fontSize: 36,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    passed 
                        ? 'Excellent understanding!' 
                        : 'Keep learning and try again!',
                    style: const TextStyle(
                      fontSize: 16,
                      color: Colors.white,
                    ),
                  ),
                ],
              ),
            ),
            
            const SizedBox(height: 24),
            
            // Performance breakdown
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: const Color(0xFF1E2328),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: Colors.grey.shade700),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Performance Breakdown',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  ),
                  const SizedBox(height: 16),
                  
                  Row(
                    children: [
                      Expanded(
                        child: _buildStatCard(
                          'Correct',
                          score.toString(),
                          Colors.green.shade600,
                          Icons.check_circle,
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: _buildStatCard(
                          'Incorrect',
                          (questions.length - score).toString(),
                          Colors.red.shade600,
                          Icons.cancel,
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: _buildStatCard(
                          'Accuracy',
                          '$percentage%',
                          Colors.blue.shade600,
                          Icons.analytics,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            
            const SizedBox(height: 24),
            
            // Question review
            const Text(
              'Question Review',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: Colors.white,
              ),
            ),
            const SizedBox(height: 16),
            
            ListView.builder(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              itemCount: questions.length,
              itemBuilder: (context, index) {
                final question = questions[index];
                final userAnswer = userAnswers[index];
                final isCorrect = correctAnswers[index];
                
                return Container(
                  margin: const EdgeInsets.only(bottom: 12),
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: const Color(0xFF1E2328),
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(
                      color: isCorrect 
                          ? Colors.green.shade700 
                          : Colors.red.shade700,
                    ),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Icon(
                            isCorrect ? Icons.check_circle : Icons.cancel,
                            color: isCorrect 
                                ? Colors.green.shade400 
                                : Colors.red.shade400,
                            size: 20,
                          ),
                          const SizedBox(width: 8),
                          Expanded(
                            child: Text(
                              'Question ${index + 1}',
                              style: TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.bold,
                                color: isCorrect 
                                    ? Colors.green.shade400 
                                    : Colors.red.shade400,
                              ),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 8),
                      Text(
                        _formatMathContent(question.question),
                        style: const TextStyle(
                          fontSize: 14,
                          color: Colors.white70,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        'Your answer: ${_formatMathContent(userAnswer)}',
                        style: TextStyle(
                          fontSize: 14,
                          color: isCorrect 
                              ? Colors.green.shade300 
                              : Colors.red.shade300,
                        ),
                      ),
                      if (!isCorrect) ...[
                        const SizedBox(height: 4),
                        Text(
                          'Correct answer: ${_formatMathContent(question.correctAnswer)}',
                          style: TextStyle(
                            fontSize: 14,
                            color: Colors.green.shade300,
                          ),
                        ),
                      ],
                    ],
                  ),
                );
              },
            ),
            
            const SizedBox(height: 32),
            
            // Action buttons
            Row(
              children: [
                Expanded(
                  child: ElevatedButton(
                    onPressed: _restartQuiz,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.blue.shade600,
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(vertical: 16),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                    child: const Text(
                      'Retake Quiz',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: ElevatedButton(
                    onPressed: () => Navigator.pop(context),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.grey.shade700,
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(vertical: 16),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                    child: const Text(
                      'Back to Content',
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

  Widget _buildStatCard(String label, String value, Color color, IconData icon) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: color.withOpacity(0.3)),
      ),
      child: Column(
        children: [
          Icon(icon, color: color, size: 24),
          const SizedBox(height: 8),
          Text(
            value,
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
              color: color,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            label,
            style: const TextStyle(
              fontSize: 12,
              color: Colors.white70,
            ),
          ),
        ],
      ),
    );
  }

  String _formatMathContent(String content) {
    // Enhanced math formatting for better display
    return content
        // Handle mathematical expressions
        .replaceAll(RegExp(r'\b(\d+)x\b'), r'$1x')  // Format coefficients
        .replaceAll(RegExp(r'\b(\d+)\s*\+\s*(\d+)\b'), r'$1 + $2')  // Format addition
        .replaceAll(RegExp(r'\b(\d+)\s*-\s*(\d+)\b'), r'$1 - $2')  // Format subtraction
        .replaceAll(RegExp(r'\b(\d+)\s*\*\s*(\d+)\b'), r'$1 × $2')  // Format multiplication
        .replaceAll(RegExp(r'\b(\d+)\s*/\s*(\d+)\b'), r'$1 ÷ $2')  // Format division
        .replaceAll(RegExp(r'\^(\d+)'), r'⁽$1⁾')  // Format exponents
        .replaceAll('sqrt', '√')  // Square root symbol
        .replaceAll('<=', '≤')  // Less than or equal
        .replaceAll('>=', '≥')  // Greater than or equal
        .replaceAll('!=', '≠')  // Not equal
        .replaceAll('infinity', '∞')  // Infinity symbol
        // Handle coordinate notation
        .replaceAll(RegExp(r'\((\d+),\s*(\d+)\)'), r'($1, $2)')
        // Clean up extra spaces
        .replaceAll(RegExp(r'\s+'), ' ')
        .trim();
  }
}

class QuizQuestion {
  final String question;
  final List<String> options;
  final String correctAnswer;

  QuizQuestion({
    required this.question,
    required this.options,
    required this.correctAnswer,
  });
}