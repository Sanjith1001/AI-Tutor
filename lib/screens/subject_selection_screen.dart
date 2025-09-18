import 'package:flutter/material.dart';
import '../models/vark_model.dart';
import 'skill_assessment_screen.dart';

class SubjectSelectionScreen extends StatefulWidget {
  final VARKResult varkResult;
  final Map<String, dynamic> selectedCourse;
  
  const SubjectSelectionScreen({
    super.key, 
    required this.varkResult, 
    required this.selectedCourse,
  });

  @override
  State<SubjectSelectionScreen> createState() => _SubjectSelectionScreenState();
}

class _SubjectSelectionScreenState extends State<SubjectSelectionScreen> {
  String? selectedSubject;

  void _selectSubject(String subject) {
    setState(() {
      selectedSubject = subject;
    });
  }

  void _proceedToSkillAssessment() {
    if (selectedSubject == null) return;
    
    // Create updated course data with selected subject
    final updatedCourseData = Map<String, dynamic>.from(widget.selectedCourse);
    updatedCourseData['selectedSubject'] = selectedSubject;
    
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => SkillAssessmentScreen(
          varkResult: widget.varkResult,
          selectedCourse: updatedCourseData,
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final subjects = widget.selectedCourse['subjects'] as List<String>;
    
    return Scaffold(
      backgroundColor: Colors.grey.shade50,
      appBar: AppBar(
        title: Text('Choose ${widget.selectedCourse['title']} Topic'),
        backgroundColor: widget.selectedCourse['color'],
        foregroundColor: Colors.white,
        elevation: 0,
      ),
      body: Column(
        children: [
          // Header with course info
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: widget.selectedCourse['color'],
              boxShadow: [
                BoxShadow(
                  color: widget.selectedCourse['color'].withOpacity(0.3),
                  blurRadius: 10,
                  offset: const Offset(0, 4),
                ),
              ],
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Icon(
                      widget.selectedCourse['icon'],
                      color: Colors.white,
                      size: 24,
                    ),
                    const SizedBox(width: 8),
                    Text(
                      widget.selectedCourse['title'],
                      style: const TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                Row(
                  children: [
                    const Icon(
                      Icons.psychology,
                      color: Colors.white,
                      size: 16,
                    ),
                    const SizedBox(width: 4),
                    Text(
                      'Learning Style: ${widget.varkResult.dominantStyle}',
                      style: TextStyle(
                        fontSize: 14,
                        color: Colors.white.withOpacity(0.9),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
          
          // Subject selection
          Expanded(
            child: Padding(
              padding: const EdgeInsets.all(20.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Select Specific Topic',
                    style: TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                      color: Colors.black87,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Choose the specific topic you want to focus on for your skill assessment.',
                    style: TextStyle(
                      fontSize: 16,
                      color: Colors.grey.shade600,
                    ),
                  ),
                  const SizedBox(height: 24),
                  
                  Expanded(
                    child: GridView.builder(
                      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                        crossAxisCount: 2,
                        childAspectRatio: 1.2,
                        crossAxisSpacing: 16,
                        mainAxisSpacing: 16,
                      ),
                      itemCount: subjects.length,
                      itemBuilder: (context, index) {
                        final subject = subjects[index];
                        final isSelected = selectedSubject == subject;
                        
                        return InkWell(
                          onTap: () => _selectSubject(subject),
                          borderRadius: BorderRadius.circular(16),
                          child: Container(
                            padding: const EdgeInsets.all(16),
                            decoration: BoxDecoration(
                              color: isSelected 
                                  ? widget.selectedCourse['color'].withOpacity(0.1) 
                                  : Colors.white,
                              borderRadius: BorderRadius.circular(16),
                              border: Border.all(
                                color: isSelected 
                                    ? widget.selectedCourse['color'] 
                                    : Colors.grey.shade300,
                                width: isSelected ? 2 : 1,
                              ),
                              boxShadow: [
                                BoxShadow(
                                  color: Colors.grey.withOpacity(0.1),
                                  blurRadius: 8,
                                  offset: const Offset(0, 2),
                                ),
                              ],
                            ),
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                if (isSelected)
                                  Container(
                                    padding: const EdgeInsets.all(8),
                                    decoration: BoxDecoration(
                                      color: widget.selectedCourse['color'],
                                      shape: BoxShape.circle,
                                    ),
                                    child: const Icon(
                                      Icons.check,
                                      color: Colors.white,
                                      size: 20,
                                    ),
                                  )
                                else
                                  Container(
                                    padding: const EdgeInsets.all(8),
                                    decoration: BoxDecoration(
                                      color: widget.selectedCourse['color'].withOpacity(0.1),
                                      shape: BoxShape.circle,
                                    ),
                                    child: Icon(
                                      _getSubjectIcon(subject),
                                      color: widget.selectedCourse['color'],
                                      size: 20,
                                    ),
                                  ),
                                const SizedBox(height: 12),
                                Text(
                                  subject,
                                  style: TextStyle(
                                    fontSize: 14,
                                    fontWeight: FontWeight.bold,
                                    color: isSelected 
                                        ? widget.selectedCourse['color'] 
                                        : Colors.black87,
                                  ),
                                  textAlign: TextAlign.center,
                                  maxLines: 2,
                                  overflow: TextOverflow.ellipsis,
                                ),
                              ],
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
          
          // Continue button
          Padding(
            padding: const EdgeInsets.all(20.0),
            child: SizedBox(
              width: double.infinity,
              height: 56,
              child: ElevatedButton(
                onPressed: selectedSubject != null ? _proceedToSkillAssessment : null,
                style: ElevatedButton.styleFrom(
                  backgroundColor: widget.selectedCourse['color'],
                  foregroundColor: Colors.white,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  elevation: 4,
                ),
                child: const Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(Icons.assessment),
                    SizedBox(width: 8),
                    Text(
                      'Start Skill Assessment',
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

  IconData _getSubjectIcon(String subject) {
    switch (subject.toLowerCase()) {
      case 'java programming':
      case 'python programming':
        return Icons.code;
      case 'data structures':
        return Icons.account_tree;
      case 'algorithms':
        return Icons.psychology;
      case 'object-oriented programming':
        return Icons.layers;
      case 'web development':
        return Icons.web;
      case 'database systems':
        return Icons.storage;
      case 'software engineering':
        return Icons.engineering;
      case 'algebra':
      case 'calculus':
        return Icons.functions;
      case 'geometry':
        return Icons.crop_square;
      case 'statistics':
        return Icons.bar_chart;
      case 'trigonometry':
        return Icons.timeline;
      case 'linear algebra':
        return Icons.grid_on;
      case 'discrete math':
        return Icons.scatter_plot;
      default:
        return Icons.book;
    }
  }
}