import 'package:flutter/material.dart';
import '../services/activity_service.dart';

class EnhancedVARKQuizScreen extends StatefulWidget {
  const EnhancedVARKQuizScreen({Key? key}) : super(key: key);

  @override
  State<EnhancedVARKQuizScreen> createState() => _EnhancedVARKQuizScreenState();
}

class _EnhancedVARKQuizScreenState extends State<EnhancedVARKQuizScreen>
    with TickerProviderStateMixin {
  int _currentQuestionIndex = 0;
  Map<int, String> _answers = {};
  bool _isLoading = false;
  late AnimationController _progressController;
  late AnimationController _questionController;
  late Animation<double> _progressAnimation;
  late Animation<Offset> _slideAnimation;

  final List<VARKQuestion> _questions = [
    VARKQuestion(
      question: "When you need to learn something new, you prefer to:",
      options: {
        'V': "Look at diagrams, charts, or visual aids",
        'A': "Listen to explanations or discussions",
        'R': "Read detailed instructions or articles",
        'K': "Try it out hands-on or practice doing it",
      },
    ),
    VARKQuestion(
      question: "When giving directions to someone, you would:",
      options: {
        'V': "Draw a map or show them visually",
        'A': "Tell them the directions verbally",
        'R': "Write down the directions step by step",
        'K': "Walk with them or show them the way",
      },
    ),
    VARKQuestion(
      question: "When you're trying to remember something, you:",
      options: {
        'V': "Picture it in your mind or create mental images",
        'A': "Repeat it out loud or hear it in your head",
        'R': "Write it down or make notes",
        'K': "Associate it with physical movements or actions",
      },
    ),
    VARKQuestion(
      question: "In a classroom, you learn best when the teacher:",
      options: {
        'V': "Uses visual aids like slides, diagrams, or videos",
        'A': "Explains concepts through lectures and discussions",
        'R': "Provides reading materials and written exercises",
        'K': "Includes hands-on activities and experiments",
      },
    ),
    VARKQuestion(
      question: "When you have free time, you prefer to:",
      options: {
        'V': "Watch videos, look at art, or browse visual content",
        'A': "Listen to music, podcasts, or have conversations",
        'R': "Read books, articles, or written content",
        'K': "Do physical activities or work with your hands",
      },
    ),
  ];

  @override
  void initState() {
    super.initState();
    _progressController = AnimationController(
      duration: const Duration(milliseconds: 800),
      vsync: this,
    );
    _questionController = AnimationController(
      duration: const Duration(milliseconds: 500),
      vsync: this,
    );

    _progressAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _progressController, curve: Curves.easeInOut),
    );

    _slideAnimation = Tween<Offset>(
      begin: const Offset(1.0, 0.0),
      end: Offset.zero,
    ).animate(
        CurvedAnimation(parent: _questionController, curve: Curves.easeOut));

    _updateProgress();
    _questionController.forward();
  }

  @override
  void dispose() {
    _progressController.dispose();
    _questionController.dispose();
    super.dispose();
  }

  void _updateProgress() {
    final progress = (_currentQuestionIndex + 1) / _questions.length;
    _progressController.animateTo(progress);
  }

  void _selectAnswer(String learningType) {
    setState(() {
      _answers[_currentQuestionIndex] = learningType;
    });
  }

  void _nextQuestion() async {
    if (_currentQuestionIndex < _questions.length - 1) {
      await _questionController.reverse();
      setState(() {
        _currentQuestionIndex++;
      });
      _updateProgress();
      _questionController.forward();
    } else {
      _completeQuiz();
    }
  }

  void _previousQuestion() async {
    if (_currentQuestionIndex > 0) {
      await _questionController.reverse();
      setState(() {
        _currentQuestionIndex--;
      });
      _updateProgress();
      _questionController.forward();
    }
  }

  void _completeQuiz() async {
    setState(() {
      _isLoading = true;
    });

    // Calculate VARK scores
    Map<String, int> scores = {'V': 0, 'A': 0, 'R': 0, 'K': 0};

    _answers.forEach((index, learningType) {
      scores[learningType] = scores[learningType]! + 1;
    });

    // Determine dominant learning style
    String dominantStyle = 'Visual';
    int maxScore = scores['V']!;

    if (scores['A']! > maxScore) {
      dominantStyle = 'Auditory';
      maxScore = scores['A']!;
    }
    if (scores['R']! > maxScore) {
      dominantStyle = 'Reading/Writing';
      maxScore = scores['R']!;
    }
    if (scores['K']! > maxScore) {
      dominantStyle = 'Kinesthetic';
    }

    // Save learning style
    await ActivityService.setLearningStyle(dominantStyle);

    // Navigate to results
    if (mounted) {
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(
          builder: (context) => VARKResultScreen(
            learningStyle: dominantStyle,
            scores: scores,
          ),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final currentQuestion = _questions[_currentQuestionIndex];
    final selectedAnswer = _answers[_currentQuestionIndex];

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.black87),
          onPressed: () => Navigator.pop(context),
        ),
        title: const Text(
          'VARK Learning Style Quiz',
          style: TextStyle(
            color: Colors.black87,
            fontWeight: FontWeight.bold,
          ),
        ),
        centerTitle: true,
      ),
      body: Column(
        children: [
          // Progress Bar
          Container(
            padding: const EdgeInsets.all(20),
            child: Column(
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      'Question ${_currentQuestionIndex + 1} of ${_questions.length}',
                      style: TextStyle(
                        fontSize: 14,
                        color: Colors.grey[600],
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                    Text(
                      '${(((_currentQuestionIndex + 1) / _questions.length) * 100).toInt()}%',
                      style: const TextStyle(
                        fontSize: 14,
                        color: Colors.purple,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                AnimatedBuilder(
                  animation: _progressAnimation,
                  builder: (context, child) {
                    return LinearProgressIndicator(
                      value: _progressAnimation.value,
                      backgroundColor: Colors.grey[200],
                      valueColor:
                          const AlwaysStoppedAnimation<Color>(Colors.purple),
                      minHeight: 6,
                    );
                  },
                ),
              ],
            ),
          ),

          // Question Content
          Expanded(
            child: SlideTransition(
              position: _slideAnimation,
              child: Padding(
                padding: const EdgeInsets.all(20),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // VARK Badge
                    Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 12, vertical: 6),
                      decoration: BoxDecoration(
                        color: Colors.purple.withValues(alpha: 0.1),
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: const Text(
                        'Learning Style Assessment',
                        style: TextStyle(
                          color: Colors.purple,
                          fontSize: 12,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),

                    const SizedBox(height: 24),

                    // Question
                    Text(
                      currentQuestion.question,
                      style: const TextStyle(
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                        color: Colors.black87,
                        height: 1.3,
                      ),
                    ),

                    const SizedBox(height: 32),

                    // Options
                    Expanded(
                      child: ListView.builder(
                        itemCount: currentQuestion.options.length,
                        itemBuilder: (context, index) {
                          final entry =
                              currentQuestion.options.entries.elementAt(index);
                          final learningType = entry.key;
                          final option = entry.value;
                          final isSelected = selectedAnswer == learningType;

                          return Container(
                            margin: const EdgeInsets.only(bottom: 12),
                            child: Material(
                              color: Colors.transparent,
                              child: InkWell(
                                onTap: () => _selectAnswer(learningType),
                                borderRadius: BorderRadius.circular(12),
                                child: AnimatedContainer(
                                  duration: const Duration(milliseconds: 200),
                                  padding: const EdgeInsets.all(20),
                                  decoration: BoxDecoration(
                                    color: isSelected
                                        ? Colors.purple.withValues(alpha: 0.1)
                                        : Colors.grey[50],
                                    border: Border.all(
                                      color: isSelected
                                          ? Colors.purple
                                          : Colors.grey[300]!,
                                      width: isSelected ? 2 : 1,
                                    ),
                                    borderRadius: BorderRadius.circular(12),
                                  ),
                                  child: Row(
                                    children: [
                                      Container(
                                        width: 32,
                                        height: 32,
                                        decoration: BoxDecoration(
                                          color: _getLearningTypeColor(
                                                  learningType)
                                              .withValues(alpha: 0.1),
                                          borderRadius:
                                              BorderRadius.circular(8),
                                        ),
                                        child: Center(
                                          child: Text(
                                            learningType,
                                            style: TextStyle(
                                              color: _getLearningTypeColor(
                                                  learningType),
                                              fontWeight: FontWeight.bold,
                                              fontSize: 16,
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
                                                ? Colors.purple
                                                : Colors.black87,
                                            fontWeight: isSelected
                                                ? FontWeight.w600
                                                : FontWeight.normal,
                                          ),
                                        ),
                                      ),
                                      if (isSelected)
                                        const Icon(
                                          Icons.check_circle,
                                          color: Colors.purple,
                                          size: 24,
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
                  ],
                ),
              ),
            ),
          ),

          // Navigation Buttons
          Container(
            padding: const EdgeInsets.all(20),
            child: Row(
              children: [
                if (_currentQuestionIndex > 0)
                  Expanded(
                    child: OutlinedButton(
                      onPressed: _previousQuestion,
                      style: OutlinedButton.styleFrom(
                        padding: const EdgeInsets.symmetric(vertical: 16),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                        side: const BorderSide(color: Colors.purple),
                      ),
                      child: const Text(
                        'Previous',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                          color: Colors.purple,
                        ),
                      ),
                    ),
                  ),
                if (_currentQuestionIndex > 0) const SizedBox(width: 16),
                Expanded(
                  flex: _currentQuestionIndex > 0 ? 1 : 2,
                  child: ElevatedButton(
                    onPressed: selectedAnswer != null
                        ? (_isLoading ? null : _nextQuestion)
                        : null,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.purple,
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(vertical: 16),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                      elevation: 0,
                    ),
                    child: _isLoading
                        ? const SizedBox(
                            height: 20,
                            width: 20,
                            child: CircularProgressIndicator(
                              color: Colors.white,
                              strokeWidth: 2,
                            ),
                          )
                        : Text(
                            _currentQuestionIndex == _questions.length - 1
                                ? 'Complete Quiz'
                                : 'Next',
                            style: const TextStyle(
                              fontSize: 16,
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
  }

  Color _getLearningTypeColor(String type) {
    switch (type) {
      case 'V':
        return Colors.blue;
      case 'A':
        return Colors.green;
      case 'R':
        return Colors.orange;
      case 'K':
        return Colors.red;
      default:
        return Colors.grey;
    }
  }
}

class VARKQuestion {
  final String question;
  final Map<String, String> options;

  VARKQuestion({
    required this.question,
    required this.options,
  });
}

class VARKResultScreen extends StatefulWidget {
  final String learningStyle;
  final Map<String, int> scores;

  const VARKResultScreen({
    Key? key,
    required this.learningStyle,
    required this.scores,
  }) : super(key: key);

  @override
  State<VARKResultScreen> createState() => _VARKResultScreenState();
}

class _VARKResultScreenState extends State<VARKResultScreen>
    with TickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _scaleAnimation;
  late Animation<double> _fadeAnimation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: const Duration(milliseconds: 1200),
      vsync: this,
    );

    _scaleAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _controller, curve: Curves.elasticOut),
    );

    _fadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeIn),
    );

    _controller.forward();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  Color _getLearningStyleColor() {
    switch (widget.learningStyle.toLowerCase()) {
      case 'visual':
        return Colors.blue;
      case 'auditory':
        return Colors.green;
      case 'reading/writing':
        return Colors.orange;
      case 'kinesthetic':
        return Colors.red;
      default:
        return Colors.purple;
    }
  }

  IconData _getLearningStyleIcon() {
    switch (widget.learningStyle.toLowerCase()) {
      case 'visual':
        return Icons.visibility;
      case 'auditory':
        return Icons.hearing;
      case 'reading/writing':
        return Icons.menu_book;
      case 'kinesthetic':
        return Icons.touch_app;
      default:
        return Icons.psychology;
    }
  }

  String _getLearningStyleDescription() {
    switch (widget.learningStyle.toLowerCase()) {
      case 'visual':
        return 'You learn best through visual aids like diagrams, charts, videos, and images. You prefer to see information presented graphically.';
      case 'auditory':
        return 'You learn best through listening to explanations, discussions, and verbal instructions. You prefer to hear information.';
      case 'reading/writing':
        return 'You learn best through reading texts and writing notes. You prefer information presented in words and text format.';
      case 'kinesthetic':
        return 'You learn best through hands-on experiences, physical activities, and practical applications. You prefer to learn by doing.';
      default:
        return 'Your learning style has been identified based on your preferences.';
    }
  }

  @override
  Widget build(BuildContext context) {
    final styleColor = _getLearningStyleColor();

    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(20),
          child: Column(
            children: [
              Expanded(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    // Success Animation
                    ScaleTransition(
                      scale: _scaleAnimation,
                      child: Container(
                        width: 120,
                        height: 120,
                        decoration: BoxDecoration(
                          color: styleColor.withValues(alpha: 0.1),
                          shape: BoxShape.circle,
                        ),
                        child: Icon(
                          _getLearningStyleIcon(),
                          size: 60,
                          color: styleColor,
                        ),
                      ),
                    ),

                    const SizedBox(height: 32),

                    // Results
                    FadeTransition(
                      opacity: _fadeAnimation,
                      child: Column(
                        children: [
                          const Text(
                            'Your Learning Style',
                            style: TextStyle(
                              fontSize: 28,
                              fontWeight: FontWeight.bold,
                              color: Colors.black87,
                            ),
                            textAlign: TextAlign.center,
                          ),

                          const SizedBox(height: 16),

                          Container(
                            padding: const EdgeInsets.symmetric(
                                horizontal: 20, vertical: 10),
                            decoration: BoxDecoration(
                              color: styleColor.withValues(alpha: 0.1),
                              borderRadius: BorderRadius.circular(25),
                            ),
                            child: Text(
                              widget.learningStyle,
                              style: TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.bold,
                                color: styleColor,
                              ),
                            ),
                          ),

                          const SizedBox(height: 24),

                          Text(
                            _getLearningStyleDescription(),
                            style: TextStyle(
                              fontSize: 16,
                              color: Colors.grey[600],
                              height: 1.5,
                            ),
                            textAlign: TextAlign.center,
                          ),

                          const SizedBox(height: 32),

                          // Score Breakdown
                          Container(
                            padding: const EdgeInsets.all(20),
                            decoration: BoxDecoration(
                              color: Colors.grey[50],
                              borderRadius: BorderRadius.circular(16),
                              border: Border.all(color: Colors.grey[200]!),
                            ),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                const Text(
                                  'Your VARK Scores',
                                  style: TextStyle(
                                    fontSize: 16,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                                const SizedBox(height: 16),
                                _buildScoreBar(
                                    'Visual', widget.scores['V']!, Colors.blue),
                                _buildScoreBar('Auditory', widget.scores['A']!,
                                    Colors.green),
                                _buildScoreBar('Reading/Writing',
                                    widget.scores['R']!, Colors.orange),
                                _buildScoreBar('Kinesthetic',
                                    widget.scores['K']!, Colors.red),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),

              // Continue Button
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: () {
                    Navigator.pop(context);
                    Navigator.pop(context);
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.purple,
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    elevation: 0,
                  ),
                  child: const Text(
                    'Continue',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildScoreBar(String label, int score, Color color) {
    final maxScore = 5; // Total number of VARK questions
    final percentage = score / maxScore;

    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                label,
                style: const TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w500,
                ),
              ),
              Text(
                '$score/$maxScore',
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.bold,
                  color: color,
                ),
              ),
            ],
          ),
          const SizedBox(height: 6),
          ClipRRect(
            borderRadius: BorderRadius.circular(4),
            child: LinearProgressIndicator(
              value: percentage,
              backgroundColor: Colors.grey[300],
              valueColor: AlwaysStoppedAnimation<Color>(color),
              minHeight: 8,
            ),
          ),
        ],
      ),
    );
  }
}
