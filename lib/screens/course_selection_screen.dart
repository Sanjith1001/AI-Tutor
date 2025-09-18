import 'package:flutter/material.dart';
import '../models/vark_model.dart';
import 'subject_selection_screen.dart';

class CourseSelectionScreen extends StatefulWidget {
  final VARKResult varkResult;
  
  const CourseSelectionScreen({super.key, required this.varkResult});

  @override
  State<CourseSelectionScreen> createState() => _CourseSelectionScreenState();
}

class _CourseSelectionScreenState extends State<CourseSelectionScreen> {
  String? selectedCourse;

  final List<Map<String, dynamic>> availableCourses = [
    {
      'title': 'Mathematics',
      'description': 'Algebra, Calculus, Geometry, Statistics',
      'icon': Icons.calculate,
      'color': Colors.blue,
      'subjects': ['Algebra', 'Calculus', 'Geometry', 'Statistics', 'Trigonometry', 'Linear Algebra', 'Discrete Math'],
    },
    {
      'title': 'Computer Science',
      'description': 'Programming, Data Structures, Algorithms',
      'icon': Icons.computer,
      'color': Colors.green,
      'subjects': ['Java Programming', 'Python Programming', 'Data Structures', 'Algorithms', 'Object-Oriented Programming', 'Web Development', 'Database Systems', 'Software Engineering'],
    },
    {
      'title': 'Physics',
      'description': 'Mechanics, Thermodynamics, Electromagnetism',
      'icon': Icons.science,
      'color': Colors.orange,
      'subjects': ['Classical Mechanics', 'Thermodynamics', 'Electromagnetism', 'Quantum Physics', 'Optics', 'Modern Physics'],
    },
    {
      'title': 'Chemistry',
      'description': 'Organic, Inorganic, Physical Chemistry',
      'icon': Icons.biotech,
      'color': Colors.purple,
      'subjects': ['Organic Chemistry', 'Inorganic Chemistry', 'Physical Chemistry', 'Analytical Chemistry', 'Biochemistry'],
    },
    {
      'title': 'Biology',
      'description': 'Cell Biology, Genetics, Ecology',
      'icon': Icons.local_florist,
      'color': Colors.teal,
      'subjects': ['Cell Biology', 'Genetics', 'Ecology', 'Human Anatomy', 'Microbiology', 'Molecular Biology'],
    },
    {
      'title': 'English Literature',
      'description': 'Poetry, Prose, Drama, Writing Skills',
      'icon': Icons.menu_book,
      'color': Colors.red,
      'subjects': ['Poetry Analysis', 'Prose Writing', 'Drama Studies', 'Creative Writing', 'Literary Criticism'],
    },
    {
      'title': 'History',
      'description': 'World History, Ancient Civilizations',
      'icon': Icons.history_edu,
      'color': Colors.brown,
      'subjects': ['World History', 'Ancient Civilizations', 'Modern History', 'Political History', 'Cultural History'],
    },
    {
      'title': 'Economics',
      'description': 'Microeconomics, Macroeconomics, Finance',
      'icon': Icons.trending_up,
      'color': Colors.indigo,
      'subjects': ['Microeconomics', 'Macroeconomics', 'International Economics', 'Finance', 'Business Economics'],
    },
  ];

  void _selectCourse(String courseTitle) {
    setState(() {
      selectedCourse = courseTitle;
    });
  }

  void _proceedToSubjectSelection() {
    if (selectedCourse == null) return;
    
    final selectedCourseData = availableCourses.firstWhere(
      (course) => course['title'] == selectedCourse,
    );
    
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => SubjectSelectionScreen(
          varkResult: widget.varkResult,
          selectedCourse: selectedCourseData,
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey.shade50,
      appBar: AppBar(
        title: const Text('Choose Your Course'),
        backgroundColor: Colors.blue.shade600,
        foregroundColor: Colors.white,
        elevation: 0,
      ),
      body: Column(
        children: [
          // Header with learning style info
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: Colors.blue.shade600,
              boxShadow: [
                BoxShadow(
                  color: Colors.blue.withOpacity(0.3),
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
                    const Icon(
                      Icons.psychology,
                      color: Colors.white,
                      size: 24,
                    ),
                    const SizedBox(width: 8),
                    Text(
                      'Your Learning Style: ${widget.varkResult.dominantStyle}',
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                Text(
                  'We\'ll personalize your learning experience based on your ${widget.varkResult.dominantStyle.toLowerCase()} learning preference.',
                  style: TextStyle(
                    fontSize: 14,
                    color: Colors.white.withOpacity(0.9),
                  ),
                ),
              ],
            ),
          ),
          
          // Course selection
          Expanded(
            child: Padding(
              padding: const EdgeInsets.all(20.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Select a Course to Begin',
                    style: TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                      color: Colors.black87,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Choose the subject you\'d like to learn. We\'ll assess your current level next.',
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
                        childAspectRatio: 0.85,
                        crossAxisSpacing: 16,
                        mainAxisSpacing: 16,
                      ),
                      itemCount: availableCourses.length,
                      itemBuilder: (context, index) {
                        final course = availableCourses[index];
                        final isSelected = selectedCourse == course['title'];
                        
                        return InkWell(
                          onTap: () => _selectCourse(course['title']),
                          borderRadius: BorderRadius.circular(16),
                          child: Container(
                            padding: const EdgeInsets.all(16),
                            decoration: BoxDecoration(
                              color: isSelected ? course['color'].withOpacity(0.1) : Colors.white,
                              borderRadius: BorderRadius.circular(16),
                              border: Border.all(
                                color: isSelected ? course['color'] : Colors.grey.shade300,
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
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Row(
                                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                  children: [
                                    Container(
                                      padding: const EdgeInsets.all(12),
                                      decoration: BoxDecoration(
                                        color: course['color'].withOpacity(0.1),
                                        borderRadius: BorderRadius.circular(12),
                                      ),
                                      child: Icon(
                                        course['icon'],
                                        color: course['color'],
                                        size: 24,
                                      ),
                                    ),
                                    if (isSelected)
                                      Container(
                                        padding: const EdgeInsets.all(4),
                                        decoration: BoxDecoration(
                                          color: course['color'],
                                          shape: BoxShape.circle,
                                        ),
                                        child: const Icon(
                                          Icons.check,
                                          color: Colors.white,
                                          size: 16,
                                        ),
                                      ),
                                  ],
                                ),
                                const SizedBox(height: 16),
                                Text(
                                  course['title'],
                                  style: TextStyle(
                                    fontSize: 18,
                                    fontWeight: FontWeight.bold,
                                    color: isSelected ? course['color'] : Colors.black87,
                                  ),
                                ),
                                const SizedBox(height: 8),
                                Expanded(
                                  child: Text(
                                    course['description'],
                                    style: TextStyle(
                                      fontSize: 14,
                                      color: Colors.grey.shade600,
                                    ),
                                    maxLines: 3,
                                    overflow: TextOverflow.ellipsis,
                                  ),
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
                onPressed: selectedCourse != null ? _proceedToSubjectSelection : null,
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.blue.shade600,
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
                      'Choose Specific Topic',
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
}