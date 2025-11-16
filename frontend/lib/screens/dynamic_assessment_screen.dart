import 'package:flutter/material.dart';
import '../services/groq_service.dart';
import '../services/activity_service.dart';
import '../services/auth_backend_service.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;

class DynamicAssessmentScreen extends StatefulWidget {
  const DynamicAssessmentScreen({super.key});

  @override
  State<DynamicAssessmentScreen> createState() =>
      _DynamicAssessmentScreenState();
}

class _DynamicAssessmentScreenState extends State<DynamicAssessmentScreen> {
  final _topicController = TextEditingController();
  int _selectedQuestionCount = 5;
  bool _isGenerating = false;
  List<Map<String, dynamic>> _generatedQuestions = [];
  bool _isQuizStarted = false;
  int _currentQuestionIndex = 0;
  int _score = 0;
  String? _selectedAnswer;
  List<String> _userAnswers = [];
  List<int> _selectedIndices = [];
  bool _isQuizCompleted = false;
  String _skillLevel = '';

  // Quiz tracking variables
  String? _quizId;
  DateTime? _quizStartTime;
  DateTime? _questionStartTime;
  List<int> _questionTimes = [];
  bool _isSubmitting = false;

  final List<String> _popularTopics = [
    'JavaScript Programming',
    'Python Basics',
    'Data Structures',
    'Machine Learning',
    'Web Development',
    'Mobile App Development',
    'Database Management',
    'Cybersecurity',
    'Cloud Computing',
    'Artificial Intelligence',
  ];

  @override
  void dispose() {
    _topicController.dispose();
    super.dispose();
  }

  Future<void> _generateQuestions() async {
    if (_topicController.text.trim().isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please enter a topic')),
      );
      return;
    }

    setState(() {
      _isGenerating = true;
    });

    try {
      final prompt = '''
You are an expert quiz generator. Generate exactly $_selectedQuestionCount multiple choice questions about "${_topicController.text.trim()}".

IMPORTANT: Return ONLY valid JSON, no other text before or after.

{
  "questions": [
    {
      "question": "What is the main purpose of ${_topicController.text.trim()}?",
      "options": ["Option A", "Option B", "Option C", "Option D"],
      "correctAnswer": 0,
      "difficulty": "Easy",
      "explanation": "Brief explanation"
    }
  ]
}

Generate $_selectedQuestionCount questions with:
- Clear, educational questions
- 4 options each (exactly 4)
- correctAnswer as number (0-3)
- difficulty: "Easy", "Medium", or "Hard"
- Mix of difficulty levels
- Real understanding testing

Return ONLY the JSON object, nothing else.
''';

      final response = await GroqService().generateTextContent(prompt);

      // Parse the JSON response with error handling
      Map<String, dynamic> jsonResponse;
      try {
        // Clean the response to extract JSON
        String cleanResponse = response.trim();

        // Find JSON start and end
        int jsonStart = cleanResponse.indexOf('{');
        int jsonEnd = cleanResponse.lastIndexOf('}') + 1;

        if (jsonStart != -1 && jsonEnd > jsonStart) {
          cleanResponse = cleanResponse.substring(jsonStart, jsonEnd);
        }

        jsonResponse = json.decode(cleanResponse);
      } catch (e) {
        throw Exception(
            'Failed to parse AI response as JSON: $e\nResponse: $response');
      }

      final questions =
          List<Map<String, dynamic>>.from(jsonResponse['questions'] ?? []);

      // Validate questions
      if (questions.isEmpty) {
        throw Exception('No questions were generated. Please try again.');
      }

      // Validate each question has required fields
      for (int i = 0; i < questions.length; i++) {
        final question = questions[i];
        if (question['question'] == null ||
            question['options'] == null ||
            question['correctAnswer'] == null) {
          throw Exception('Question ${i + 1} is missing required fields.');
        }

        final options = question['options'] as List;
        if (options.length < 2) {
          throw Exception('Question ${i + 1} needs at least 2 options.');
        }

        final correctAnswer = question['correctAnswer'] as int;
        if (correctAnswer < 0 || correctAnswer >= options.length) {
          throw Exception(
              'Question ${i + 1} has invalid correct answer index.');
        }
      }

      setState(() {
        _generatedQuestions = questions;
        _isGenerating = false;
      });

      // Automatically start the quiz after generating questions
      _startQuiz();
    } catch (e) {
      setState(() {
        _isGenerating = false;
      });

      String errorMessage = 'Error generating questions';
      if (e.toString().contains('JSON')) {
        errorMessage = 'AI response format error. Please try again.';
      } else if (e.toString().contains('questions')) {
        errorMessage = 'Invalid questions generated. Please try again.';
      } else if (e.toString().contains('network') ||
          e.toString().contains('connection')) {
        errorMessage = 'Network error. Please check your connection.';
      }

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(errorMessage),
          backgroundColor: Colors.red,
          action: SnackBarAction(
            label: 'Use Sample',
            textColor: Colors.white,
            onPressed: _generateSampleQuestions,
          ),
        ),
      );
    }
  }

  void _generateSampleQuestions() {
    final topic = _topicController.text.trim();
    final sampleQuestions = [
      {
        "question": "What is the main concept of $topic?",
        "options": [
          "A fundamental principle",
          "An advanced technique",
          "A programming language",
          "A software tool"
        ],
        "correctAnswer": 0,
        "difficulty": "Easy",
        "explanation": "This is a basic conceptual question about $topic"
      },
      {
        "question":
            "Which of the following is most important when learning $topic?",
        "options": [
          "Memorizing syntax",
          "Understanding core concepts",
          "Using advanced tools",
          "Reading documentation"
        ],
        "correctAnswer": 1,
        "difficulty": "Medium",
        "explanation":
            "Understanding core concepts is crucial for mastering any topic"
      },
      {
        "question":
            "What would be considered an advanced application of $topic?",
        "options": [
          "Basic implementation",
          "Complex problem solving",
          "Simple examples",
          "Tutorial following"
        ],
        "correctAnswer": 1,
        "difficulty": "Hard",
        "explanation": "Advanced applications involve complex problem solving"
      }
    ];

    setState(() {
      _generatedQuestions =
          sampleQuestions.take(_selectedQuestionCount).toList();
      _isGenerating = false;
    });

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content:
            Text('Using sample questions. Try generating AI questions later.'),
        backgroundColor: Colors.orange,
      ),
    );

    // Automatically start the quiz with sample questions
    _startQuiz();
  }

  Future<void> _createQuizInDatabase() async {
    try {
      final baseUrl = await AuthBackendService.getBaseUrl();
      final headers = await AuthBackendService.getHeaders();

      final response = await http.post(
        Uri.parse('$baseUrl/quizzes'),
        headers: headers,
        body: json.encode({
          'topic': _topicController.text.trim(),
          'title': '${_topicController.text.trim()} Assessment',
          'questions': _generatedQuestions,
        }),
      );

      if (response.statusCode == 201) {
        final data = json.decode(response.body);
        _quizId = data['data']['quiz']['_id'];
        print('✅ Quiz created in database with ID: $_quizId');
      } else {
        print('❌ Failed to create quiz in database: ${response.body}');
      }
    } catch (e) {
      print('❌ Error creating quiz in database: $e');
    }
  }

  void _startQuiz() async {
    // Create quiz in database first
    await _createQuizInDatabase();

    setState(() {
      _isQuizStarted = true;
      _currentQuestionIndex = 0;
      _score = 0;
      _userAnswers = [];
      _selectedIndices = [];
      _selectedAnswer = null;
      _quizStartTime = DateTime.now();
      _questionStartTime = DateTime.now();
      _questionTimes = [];
    });
  }

  void _selectAnswer(String answer) {
    setState(() {
      _selectedAnswer = answer;
    });
  }

  void _nextQuestion() {
    if (_selectedAnswer == null) return;

    final currentQuestion = _generatedQuestions[_currentQuestionIndex];
    final correctAnswerIndex = currentQuestion['correctAnswer'];
    final correctAnswer = currentQuestion['options'][correctAnswerIndex];
    final selectedIndex = currentQuestion['options'].indexOf(_selectedAnswer!);

    // Track timing for this question
    final questionTime =
        DateTime.now().difference(_questionStartTime!).inSeconds;
    _questionTimes.add(questionTime);

    _userAnswers.add(_selectedAnswer!);
    _selectedIndices.add(selectedIndex);

    if (_selectedAnswer == correctAnswer) {
      _score++;
    }

    if (_currentQuestionIndex < _generatedQuestions.length - 1) {
      setState(() {
        _currentQuestionIndex++;
        _selectedAnswer = null;
        _questionStartTime = DateTime.now(); // Reset timer for next question
      });
    } else {
      _completeQuiz();
    }
  }

  void _completeQuiz() async {
    setState(() {
      _isSubmitting = true;
    });

    final percentage = (_score / _generatedQuestions.length * 100).round();
    final totalTimeSpent = DateTime.now().difference(_quizStartTime!).inSeconds;

    // Determine skill level based on score
    if (percentage >= 80) {
      _skillLevel = 'Advanced';
    } else if (percentage >= 60) {
      _skillLevel = 'Intermediate';
    } else {
      _skillLevel = 'Beginner';
    }

    // Submit quiz responses to database
    await _submitQuizToDatabase(percentage, totalTimeSpent);

    // Add activity
    await ActivityService.addActivity(
      type: ActivityService.activityAssessment,
      title: 'Completed ${_topicController.text} Assessment',
      description: 'Score: $percentage% • Skill Level: $_skillLevel',
      metadata: {
        'score': percentage,
        'skillLevel': _skillLevel,
        'topic': _topicController.text.trim(),
        'questionsCount': _generatedQuestions.length,
        'timeSpent': totalTimeSpent,
      },
      score: percentage,
      completed: true,
    );

    setState(() {
      _isQuizCompleted = true;
      _isSubmitting = false;
    });
  }

  Future<void> _submitQuizToDatabase(int percentage, int totalTimeSpent) async {
    if (_quizId == null) {
      print('❌ No quiz ID available for submission');
      return;
    }

    try {
      final baseUrl = await AuthBackendService.getBaseUrl();
      final headers = await AuthBackendService.getHeaders();

      // Prepare responses data
      final responses = <Map<String, dynamic>>[];
      for (int i = 0; i < _generatedQuestions.length; i++) {
        responses.add({
          'questionIndex': i,
          'selectedAnswer': _userAnswers[i],
          'selectedIndex': _selectedIndices[i],
          'timeSpent': i < _questionTimes.length ? _questionTimes[i] : 0,
        });
      }

      final response = await http.post(
        Uri.parse('$baseUrl/quizzes/$_quizId/submit'),
        headers: headers,
        body: json.encode({
          'responses': responses,
          'totalTimeSpent': totalTimeSpent,
          'startedAt': _quizStartTime!.toIso8601String(),
        }),
      );

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        print('✅ Quiz submitted successfully: ${data['message']}');
      } else {
        print('❌ Failed to submit quiz: ${response.body}');
      }
    } catch (e) {
      print('❌ Error submitting quiz to database: $e');
    }
  }

  void _resetAssessment() {
    setState(() {
      _topicController.clear();
      _selectedQuestionCount = 5;
      _generatedQuestions = [];
      _isQuizStarted = false;
      _currentQuestionIndex = 0;
      _score = 0;
      _userAnswers = [];
      _selectedIndices = [];
      _selectedAnswer = null;
      _isQuizCompleted = false;
      _skillLevel = '';
      _quizId = null;
      _quizStartTime = null;
      _questionStartTime = null;
      _questionTimes = [];
      _isSubmitting = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    if (_isQuizCompleted) {
      return _buildResultScreen();
    }

    if (_isQuizStarted) {
      return _buildQuizScreen();
    }

    return _buildSetupScreen();
  }

  Widget _buildSetupScreen() {
    return Scaffold(
      backgroundColor: const Color(0xFFF8F9FA),
      appBar: AppBar(
        title: const Text('AI Assessment'),
        backgroundColor: const Color(0xFF667eea),
        foregroundColor: Colors.white,
        elevation: 0,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(24),
              decoration: BoxDecoration(
                gradient: const LinearGradient(
                  colors: [Color(0xFF667eea), Color(0xFF764ba2)],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
                borderRadius: BorderRadius.circular(20),
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
                    'AI-Powered Assessment',
                    style: TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  ),
                  const SizedBox(height: 8),
                  const Text(
                    'Get personalized questions on any topic',
                    style: TextStyle(
                      fontSize: 16,
                      color: Colors.white70,
                    ),
                    textAlign: TextAlign.center,
                  ),
                ],
              ),
            ),

            const SizedBox(height: 30),

            // Topic Input
            const Text(
              'What topic would you like to be assessed on?',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: Color(0xFF2D3748),
              ),
            ),
            const SizedBox(height: 16),

            Container(
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
              child: TextField(
                controller: _topicController,
                decoration: const InputDecoration(
                  hintText:
                      'e.g., JavaScript, Machine Learning, Data Structures',
                  prefixIcon: Icon(Icons.search, color: Color(0xFF667eea)),
                  border: InputBorder.none,
                  contentPadding: EdgeInsets.all(20),
                ),
                style: const TextStyle(fontSize: 16),
              ),
            ),

            const SizedBox(height: 20),

            // Popular Topics
            const Text(
              'Popular Topics',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w600,
                color: Color(0xFF2D3748),
              ),
            ),
            const SizedBox(height: 12),

            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: _popularTopics
                  .map((topic) => GestureDetector(
                        onTap: () {
                          _topicController.text = topic;
                        },
                        child: Container(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 16, vertical: 8),
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(20),
                            border: Border.all(
                                color: const Color(0xFF667eea)
                                    .withValues(alpha: 0.3)),
                          ),
                          child: Text(
                            topic,
                            style: const TextStyle(
                              color: Color(0xFF667eea),
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ),
                      ))
                  .toList(),
            ),

            const SizedBox(height: 30),

            // Question Count
            const Text(
              'Number of Questions',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: Color(0xFF2D3748),
              ),
            ),
            const SizedBox(height: 16),

            Container(
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
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text(
                        'Questions:',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      Text(
                        '$_selectedQuestionCount',
                        style: const TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          color: Color(0xFF667eea),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),
                  Slider(
                    value: _selectedQuestionCount.toDouble(),
                    min: 3,
                    max: 15,
                    divisions: 12,
                    activeColor: const Color(0xFF667eea),
                    onChanged: (value) {
                      setState(() {
                        _selectedQuestionCount = value.round();
                      });
                    },
                  ),
                  const Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text('3', style: TextStyle(color: Colors.grey)),
                      Text('15', style: TextStyle(color: Colors.grey)),
                    ],
                  ),
                ],
              ),
            ),

            const SizedBox(height: 40),

            // Generate Button
            SizedBox(
              width: double.infinity,
              height: 56,
              child: ElevatedButton(
                onPressed: _isGenerating ? null : _generateQuestions,
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF667eea),
                  foregroundColor: Colors.white,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(16),
                  ),
                  elevation: 4,
                ),
                child: _isGenerating
                    ? const Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          SizedBox(
                            width: 20,
                            height: 20,
                            child: CircularProgressIndicator(
                              color: Colors.white,
                              strokeWidth: 2,
                            ),
                          ),
                          SizedBox(width: 12),
                          Text('Starting Assessment...'),
                        ],
                      )
                    : const Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(Icons.auto_awesome),
                          SizedBox(width: 8),
                          Text(
                            'Start Assessment',
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

  Widget _buildPreviewScreen() {
    return Scaffold(
      backgroundColor: const Color(0xFFF8F9FA),
      appBar: AppBar(
        title: const Text('Preview Questions'),
        backgroundColor: const Color(0xFF667eea),
        foregroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () {
            _resetAssessment();
          },
        ),
      ),
      body: Column(
        children: [
          // Header
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(20),
            color: const Color(0xFF667eea),
            child: Column(
              children: [
                Text(
                  _topicController.text,
                  style: const TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  '${_generatedQuestions.length} Questions Generated',
                  style: const TextStyle(
                    fontSize: 16,
                    color: Colors.white70,
                  ),
                ),
              ],
            ),
          ),

          // Questions List
          Expanded(
            child: ListView.builder(
              padding: const EdgeInsets.all(20),
              itemCount: _generatedQuestions.length,
              itemBuilder: (context, index) {
                final question = _generatedQuestions[index];
                return Container(
                  margin: const EdgeInsets.only(bottom: 16),
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
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            'Question ${index + 1}',
                            style: const TextStyle(
                              fontSize: 14,
                              fontWeight: FontWeight.w600,
                              color: Color(0xFF667eea),
                            ),
                          ),
                          Container(
                            padding: const EdgeInsets.symmetric(
                                horizontal: 8, vertical: 4),
                            decoration: BoxDecoration(
                              color: _getDifficultyColor(question['difficulty'])
                                  .withValues(alpha: 0.1),
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: Text(
                              question['difficulty'],
                              style: TextStyle(
                                fontSize: 12,
                                fontWeight: FontWeight.w600,
                                color:
                                    _getDifficultyColor(question['difficulty']),
                              ),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 12),
                      Text(
                        question['question'],
                        style: const TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                          color: Color(0xFF2D3748),
                        ),
                      ),
                      const SizedBox(height: 12),
                      ...List.generate(
                        question['options'].length,
                        (optionIndex) => Padding(
                          padding: const EdgeInsets.only(bottom: 8),
                          child: Row(
                            children: [
                              Container(
                                width: 20,
                                height: 20,
                                decoration: BoxDecoration(
                                  shape: BoxShape.circle,
                                  color:
                                      optionIndex == question['correctAnswer']
                                          ? Colors.green
                                          : Colors.grey.shade300,
                                ),
                                child: optionIndex == question['correctAnswer']
                                    ? const Icon(Icons.check,
                                        size: 14, color: Colors.white)
                                    : Text(
                                        String.fromCharCode(65 + optionIndex),
                                        style: const TextStyle(
                                          fontSize: 12,
                                          fontWeight: FontWeight.bold,
                                          color: Colors.white,
                                        ),
                                        textAlign: TextAlign.center,
                                      ),
                              ),
                              const SizedBox(width: 12),
                              Expanded(
                                child: Text(
                                  question['options'][optionIndex],
                                  style: TextStyle(
                                    fontSize: 14,
                                    color:
                                        optionIndex == question['correctAnswer']
                                            ? Colors.green.shade700
                                            : const Color(0xFF4A5568),
                                    fontWeight:
                                        optionIndex == question['correctAnswer']
                                            ? FontWeight.w600
                                            : FontWeight.normal,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ],
                  ),
                );
              },
            ),
          ),

          // Start Quiz Button
          Container(
            padding: const EdgeInsets.all(20),
            child: SizedBox(
              width: double.infinity,
              height: 56,
              child: ElevatedButton(
                onPressed: _startQuiz,
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.green.shade600,
                  foregroundColor: Colors.white,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(16),
                  ),
                  elevation: 4,
                ),
                child: const Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(Icons.play_arrow),
                    SizedBox(width: 8),
                    Text(
                      'Start Assessment',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildQuizScreen() {
    final question = _generatedQuestions[_currentQuestionIndex];
    final progress = (_currentQuestionIndex + 1) / _generatedQuestions.length;

    return Scaffold(
      backgroundColor: const Color(0xFFF8F9FA),
      appBar: AppBar(
        title: Text(
            'Question ${_currentQuestionIndex + 1} of ${_generatedQuestions.length}'),
        backgroundColor: const Color(0xFF667eea),
        foregroundColor: Colors.white,
        elevation: 0,
        automaticallyImplyLeading: false,
      ),
      body: Column(
        children: [
          // Progress Bar
          Container(
            width: double.infinity,
            height: 8,
            color: Colors.grey.shade200,
            child: FractionallySizedBox(
              alignment: Alignment.centerLeft,
              widthFactor: progress,
              child: Container(
                decoration: const BoxDecoration(
                  color: Color(0xFF667eea),
                ),
              ),
            ),
          ),

          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Difficulty Badge
                  Container(
                    padding:
                        const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                    decoration: BoxDecoration(
                      color: _getDifficultyColor(question['difficulty'])
                          .withValues(alpha: 0.1),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Text(
                      question['difficulty'],
                      style: TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.bold,
                        color: _getDifficultyColor(question['difficulty']),
                      ),
                    ),
                  ),

                  const SizedBox(height: 20),

                  // Question
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(24),
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
                    child: Text(
                      question['question'],
                      style: const TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                        color: Color(0xFF2D3748),
                      ),
                    ),
                  ),

                  const SizedBox(height: 24),

                  // Options
                  ...List.generate(
                    question['options'].length,
                    (index) {
                      final option = question['options'][index];
                      final isSelected = _selectedAnswer == option;

                      return Container(
                        margin: const EdgeInsets.only(bottom: 12),
                        child: InkWell(
                          onTap: () => _selectAnswer(option),
                          borderRadius: BorderRadius.circular(12),
                          child: Container(
                            padding: const EdgeInsets.all(20),
                            decoration: BoxDecoration(
                              color: isSelected
                                  ? const Color(0xFF667eea)
                                      .withValues(alpha: 0.1)
                                  : Colors.white,
                              borderRadius: BorderRadius.circular(12),
                              border: Border.all(
                                color: isSelected
                                    ? const Color(0xFF667eea)
                                    : Colors.grey.shade300,
                                width: isSelected ? 2 : 1,
                              ),
                              boxShadow: [
                                BoxShadow(
                                  color: Colors.black.withValues(alpha: 0.05),
                                  blurRadius: 4,
                                  offset: const Offset(0, 2),
                                ),
                              ],
                            ),
                            child: Row(
                              children: [
                                Container(
                                  width: 24,
                                  height: 24,
                                  decoration: BoxDecoration(
                                    shape: BoxShape.circle,
                                    color: isSelected
                                        ? const Color(0xFF667eea)
                                        : Colors.transparent,
                                    border: Border.all(
                                      color: isSelected
                                          ? const Color(0xFF667eea)
                                          : Colors.grey.shade400,
                                      width: 2,
                                    ),
                                  ),
                                  child: isSelected
                                      ? const Icon(
                                          Icons.check,
                                          size: 16,
                                          color: Colors.white,
                                        )
                                      : Center(
                                          child: Text(
                                            String.fromCharCode(65 + index),
                                            style: TextStyle(
                                              fontSize: 12,
                                              fontWeight: FontWeight.bold,
                                              color: Colors.grey.shade600,
                                            ),
                                          ),
                                        ),
                                ),
                                const SizedBox(width: 16),
                                Expanded(
                                  child: Text(
                                    option,
                                    style: TextStyle(
                                      fontSize: 16,
                                      color: isSelected
                                          ? const Color(0xFF667eea)
                                          : const Color(0xFF2D3748),
                                      fontWeight: isSelected
                                          ? FontWeight.w600
                                          : FontWeight.normal,
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
                ],
              ),
            ),
          ),

          // Next Button
          Container(
            padding: const EdgeInsets.all(20),
            child: SizedBox(
              width: double.infinity,
              height: 56,
              child: ElevatedButton(
                onPressed: _selectedAnswer != null ? _nextQuestion : null,
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF667eea),
                  foregroundColor: Colors.white,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(16),
                  ),
                  elevation: 4,
                ),
                child: Text(
                  _currentQuestionIndex < _generatedQuestions.length - 1
                      ? 'Next Question'
                      : 'Complete Assessment',
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildResultScreen() {
    final percentage = (_score / _generatedQuestions.length * 100).round();

    if (_isSubmitting) {
      return Scaffold(
        backgroundColor: const Color(0xFFF8F9FA),
        appBar: AppBar(
          title: const Text('Submitting Assessment'),
          backgroundColor: Colors.blue.shade600,
          foregroundColor: Colors.white,
          elevation: 0,
          automaticallyImplyLeading: false,
        ),
        body: const Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              CircularProgressIndicator(),
              SizedBox(height: 20),
              Text(
                'Saving your results...',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
        ),
      );
    }

    return Scaffold(
      backgroundColor: const Color(0xFFF8F9FA),
      appBar: AppBar(
        title: const Text('Assessment Complete'),
        backgroundColor: Colors.green.shade600,
        foregroundColor: Colors.white,
        elevation: 0,
        automaticallyImplyLeading: false,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          children: [
            // Score Card
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(24),
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [Colors.green.shade600, Colors.green.shade400],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
                borderRadius: BorderRadius.circular(20),
                boxShadow: [
                  BoxShadow(
                    color: Colors.green.withValues(alpha: 0.3),
                    blurRadius: 15,
                    offset: const Offset(0, 8),
                  ),
                ],
              ),
              child: Column(
                children: [
                  const Icon(
                    Icons.emoji_events,
                    color: Colors.white,
                    size: 48,
                  ),
                  const SizedBox(height: 16),
                  Text(
                    'You scored $_score out of ${_generatedQuestions.length}',
                    style: const TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 8),
                  Text(
                    '$percentage%',
                    style: const TextStyle(
                      fontSize: 48,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Container(
                    padding:
                        const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                    decoration: BoxDecoration(
                      color: Colors.white.withValues(alpha: 0.2),
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Text(
                      'Skill Level: $_skillLevel',
                      style: const TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 24),

            // Skill Level Description
            Container(
              width: double.infinity,
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
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Your $_skillLevel Level in ${_topicController.text}',
                    style: const TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: Color(0xFF2D3748),
                    ),
                  ),
                  const SizedBox(height: 12),
                  Text(
                    _getSkillLevelDescription(_skillLevel),
                    style: const TextStyle(
                      fontSize: 16,
                      color: Color(0xFF4A5568),
                      height: 1.5,
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 24),

            // Action Buttons
            Row(
              children: [
                Expanded(
                  child: ElevatedButton(
                    onPressed: _resetAssessment,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.grey.shade600,
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(vertical: 16),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                    child: const Text(
                      'New Assessment',
                      style: TextStyle(fontWeight: FontWeight.bold),
                    ),
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: ElevatedButton(
                    onPressed: () => Navigator.pop(context),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF667eea),
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(vertical: 16),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                    child: const Text(
                      'Back to Home',
                      style: TextStyle(fontWeight: FontWeight.bold),
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

  Color _getDifficultyColor(String difficulty) {
    switch (difficulty.toLowerCase()) {
      case 'easy':
        return Colors.green;
      case 'medium':
        return Colors.orange;
      case 'hard':
        return Colors.red;
      default:
        return Colors.grey;
    }
  }

  String _getSkillLevelDescription(String level) {
    switch (level) {
      case 'Beginner':
        return 'You\'re just starting out! Focus on building fundamental concepts and practicing basic problems. Don\'t worry, everyone starts here.';
      case 'Intermediate':
        return 'Great progress! You have a solid understanding of the basics. Now it\'s time to tackle more complex problems and deepen your knowledge.';
      case 'Advanced':
        return 'Excellent work! You have strong knowledge in this area. Consider exploring advanced topics or helping others learn.';
      default:
        return 'Keep learning and practicing to improve your skills!';
    }
  }
}
