import 'package:flutter/material.dart';
import '../models/vark_model.dart';
import '../models/skill_assessment_model.dart';
import '../services/groq_service.dart';
import '../services/activity_service.dart';
import 'course_screen.dart';

class SkillAssessmentScreen extends StatefulWidget {
  final VARKResult varkResult;
  final Map<String, dynamic> selectedCourse;
  
  const SkillAssessmentScreen({
    super.key, 
    required this.varkResult, 
    required this.selectedCourse,
  });

  @override
  State<SkillAssessmentScreen> createState() => _SkillAssessmentScreenState();
}

class _SkillAssessmentScreenState extends State<SkillAssessmentScreen> {
  int currentQuestionIndex = 0;
  int score = 0;
  List<AssessmentQuestion> questions = [];
  String? selectedAnswer;
  bool isQuizCompleted = false;
  SkillAssessmentResult? result;
  List<bool> correctAnswers = [];

  @override
  void initState() {
    super.initState();
    final specificSubject = widget.selectedCourse['selectedSubject'];
    questions = SkillAssessmentData.getQuestionsForCourse(
      widget.selectedCourse['title'],
      specificSubject: specificSubject,
    );
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
    final selectedIndex = currentQuestion.options.indexOf(selectedAnswer!);
    final isCorrect = selectedIndex == currentQuestion.correctAnswerIndex;
    
    correctAnswers.add(isCorrect);
    if (isCorrect) {
      score++;
    }

    if (currentQuestionIndex < questions.length - 1) {
      setState(() {
        currentQuestionIndex++;
        selectedAnswer = null;
      });
    } else {
      _completeAssessment();
    }
  }

  void _completeAssessment() async {
    final skillLevel = SkillLevel.getLevel(score, questions.length);
    final percentage = (score / questions.length * 100).round();
    
    // Analyze strengths and improvement areas
    Map<String, int> topicScores = {};
    Map<String, int> topicCounts = {};
    
    for (int i = 0; i < questions.length; i++) {
      final topic = questions[i].topic;
      topicCounts[topic] = (topicCounts[topic] ?? 0) + 1;
      if (correctAnswers[i]) {
        topicScores[topic] = (topicScores[topic] ?? 0) + 1;
      }
    }
    
    List<String> strengths = [];
    List<String> improvementAreas = [];
    
    topicScores.forEach((topic, correct) {
      final total = topicCounts[topic]!;
      final percentageScore = correct / total;
      if (percentageScore >= 0.7) {
        strengths.add(topic);
      } else if (percentageScore < 0.5) {
        improvementAreas.add(topic);
      }
    });

    result = SkillAssessmentResult(
      course: widget.selectedCourse['title'],
      score: score,
      totalQuestions: questions.length,
      skillLevel: skillLevel,
      completedAt: DateTime.now(),
      strengths: strengths,
      improvementAreas: improvementAreas,
    );

    // Save skill level and add activity for skill assessment
    await ActivityService.setSkillLevel(skillLevel);
    await ActivityService.addActivity(
      type: ActivityService.activityAssessment,
      title: 'Completed ${widget.selectedCourse['title']} Assessment',
      description: 'Score: $percentage% • Skill Level: $skillLevel',
      metadata: {
        'score': percentage,
        'skillLevel': skillLevel,
        'course': widget.selectedCourse['title'],
      },
    );

    setState(() {
      isQuizCompleted = true;
    });
  }

  void _proceedToCourse() async {
    // Generate course content using AI based on the selected subject
    try {
      final specificSubject = widget.selectedCourse['selectedSubject'];
      // final courseTitle = widget.selectedCourse['title']; // Unused for now
      
      // Create a prompt that includes the user's learning style and skill level
      String prompt = 'Create a comprehensive course on $specificSubject for ${result!.skillLevel} level learners';
      
      // Add learning style specific instructions
      switch (widget.varkResult.dominantStyle) {
        case 'Visual':
          prompt += '. Include visual learning elements, diagrams, and visual examples.';
          break;
        case 'Auditory':
          prompt += '. Include audio-friendly content, discussions, and verbal explanations.';
          break;
        case 'Reading/Writing':
          prompt += '. Include text-based materials, written exercises, and detailed explanations.';
          break;
        case 'Kinesthetic':
          prompt += '. Include hands-on activities, practical examples, and interactive elements.';
          break;
      }
      
      // Show loading
      showDialog(
        context: context,
        barrierDismissible: false,
        builder: (context) => const Center(
          child: CircularProgressIndicator(),
        ),
      );
      
      // Generate course using your existing GroqService
      final data = await GroqService().generateDetailedContent(prompt);
      
      // Close loading dialog
      Navigator.pop(context);
      
      // Navigate to your existing CourseScreen with personalization data
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(
          builder: (context) => CourseScreen(
            title: data["courseTitle"] ?? '$specificSubject Course',
            modules: List<Map<String, dynamic>>.from(data["modules"] ?? []),
            learningStyle: widget.varkResult.dominantStyle,
            skillLevel: result!.skillLevel,
          ),
        ),
      );
    } catch (e) {
      // Close loading dialog if open
      if (Navigator.canPop(context)) {
        Navigator.pop(context);
      }
      
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Error generating course: $e")),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    if (isQuizCompleted && result != null) {
      return _buildResultScreen();
    }

    return Scaffold(
      backgroundColor: Colors.grey.shade50,
      appBar: AppBar(
        title: Text('${widget.selectedCourse['title']} Assessment'),
        backgroundColor: widget.selectedCourse['color'],
        foregroundColor: Colors.white,
        elevation: 0,
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(16.0),
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
                    color: widget.selectedCourse['color'],
                    borderRadius: BorderRadius.circular(4),
                  ),
                ),
              ),
            ),
            
            const SizedBox(height: 16),
            
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'Question ${currentQuestionIndex + 1} of ${questions.length}',
                  style: TextStyle(
                    fontSize: 16,
                    color: Colors.grey.shade600,
                    fontWeight: FontWeight.w500,
                  ),
                ),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                  decoration: BoxDecoration(
                    color: widget.selectedCourse['color'].withOpacity(0.1),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Text(
                    questions[currentQuestionIndex].difficulty,
                    style: TextStyle(
                      fontSize: 12,
                      color: widget.selectedCourse['color'],
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ],
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
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                    decoration: BoxDecoration(
                      color: Colors.grey.shade100,
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Text(
                      questions[currentQuestionIndex].topic,
                      style: TextStyle(
                        fontSize: 12,
                        color: Colors.grey.shade600,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ),
                  const SizedBox(height: 16),
                  Text(
                    questions[currentQuestionIndex].question,
                    style: const TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                      color: Colors.black87,
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
                          color: isSelected ? widget.selectedCourse['color'].withOpacity(0.1) : Colors.white,
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(
                            color: isSelected ? widget.selectedCourse['color'] : Colors.grey.shade300,
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
                                  color: isSelected ? widget.selectedCourse['color'] : Colors.grey.shade400,
                                  width: 2,
                                ),
                                color: isSelected ? widget.selectedCourse['color'] : Colors.transparent,
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
                                  color: isSelected ? widget.selectedCourse['color'] : Colors.black87,
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
                  backgroundColor: widget.selectedCourse['color'],
                  foregroundColor: Colors.white,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  elevation: 4,
                ),
                child: Text(
                  currentQuestionIndex < questions.length - 1 ? 'Next Question' : 'Complete Assessment',
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
    ),
  );
}

  Widget _buildResultScreen() {
    final percentage = (score / questions.length * 100).round();
    
    return Scaffold(
      backgroundColor: Colors.grey.shade50,
      appBar: AppBar(
        title: const Text('Assessment Complete'),
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
            // Score header
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
                    Icons.emoji_events,
                    color: Colors.white,
                    size: 48,
                  ),
                  const SizedBox(height: 16),
                  Text(
                    'You scored $score out of ${questions.length}',
                    style: const TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
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
                    'Skill Level: ${result!.skillLevel}',
                    style: const TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.w600,
                      color: Colors.white,
                    ),
                  ),
                ],
              ),
            ),
            
            const SizedBox(height: 24),
            
            // Level description
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
                    SkillLevel.getLevelDescription(result!.skillLevel),
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
            
            // Strengths and improvement areas
            if (result!.strengths.isNotEmpty || result!.improvementAreas.isNotEmpty)
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
                      'Analysis:',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: Colors.black87,
                      ),
                    ),
                    const SizedBox(height: 16),
                    
                    if (result!.strengths.isNotEmpty) ...[
                      Row(
                        children: [
                          Icon(Icons.star, color: Colors.green.shade600, size: 20),
                          const SizedBox(width: 8),
                          const Text(
                            'Strengths:',
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                              color: Colors.black87,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 8),
                      Wrap(
                        spacing: 8,
                        runSpacing: 8,
                        children: result!.strengths.map((strength) => Container(
                          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                          decoration: BoxDecoration(
                            color: Colors.green.shade50,
                            borderRadius: BorderRadius.circular(16),
                            border: Border.all(color: Colors.green.shade200),
                          ),
                          child: Text(
                            strength,
                            style: TextStyle(
                              fontSize: 14,
                              color: Colors.green.shade700,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        )).toList(),
                      ),
                      const SizedBox(height: 16),
                    ],
                    
                    if (result!.improvementAreas.isNotEmpty) ...[
                      Row(
                        children: [
                          Icon(Icons.trending_up, color: Colors.orange.shade600, size: 20),
                          const SizedBox(width: 8),
                          const Text(
                            'Areas to focus on:',
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                              color: Colors.black87,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 8),
                      Wrap(
                        spacing: 8,
                        runSpacing: 8,
                        children: result!.improvementAreas.map((area) => Container(
                          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                          decoration: BoxDecoration(
                            color: Colors.orange.shade50,
                            borderRadius: BorderRadius.circular(16),
                            border: Border.all(color: Colors.orange.shade200),
                          ),
                          child: Text(
                            area,
                            style: TextStyle(
                              fontSize: 14,
                              color: Colors.orange.shade700,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        )).toList(),
                      ),
                    ],
                  ],
                ),
              ),
            
            const SizedBox(height: 32),
            
            // Continue button
            SizedBox(
              width: double.infinity,
              height: 56,
              child: ElevatedButton(
                onPressed: _proceedToCourse,
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
                    Icon(Icons.school),
                    SizedBox(width: 8),
                    Text(
                      'Start Your Personalized Course',
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
}