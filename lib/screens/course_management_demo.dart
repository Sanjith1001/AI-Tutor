import 'package:flutter/material.dart';
import '../services/course_service.dart';
import '../models/course.dart';
import '../widgets/course_card.dart';

class CourseManagementDemo extends StatefulWidget {
  const CourseManagementDemo({Key? key}) : super(key: key);

  @override
  State<CourseManagementDemo> createState() => _CourseManagementDemoState();
}

class _CourseManagementDemoState extends State<CourseManagementDemo> {
  List<Course> _courses = [];
  bool _isLoading = false;
  String _statusMessage = '';

  @override
  void initState() {
    super.initState();
    _loadCourses();
  }

  Future<void> _loadCourses() async {
    setState(() {
      _isLoading = true;
      _statusMessage = 'Loading courses...';
    });

    try {
      final response = await CourseService.getCourses();

      if (response['success'] == true) {
        final coursesData = response['data']['courses'] as List;
        setState(() {
          _courses = coursesData
              .map((courseJson) => Course.fromJson(courseJson))
              .toList();
          _statusMessage = 'Loaded ${_courses.length} courses successfully!';
        });
      } else {
        setState(() {
          _statusMessage =
              'Error: ${response['message'] ?? 'Failed to load courses'}';
        });
      }
    } catch (e) {
      setState(() {
        _statusMessage = 'Network error: $e';
      });
    } finally {
      setState(() => _isLoading = false);
    }
  }

  Future<void> _testCourseCreation() async {
    setState(() {
      _isLoading = true;
      _statusMessage = 'Creating test course...';
    });

    final testCourse = {
      'title': 'Flutter Course Management Test',
      'description':
          'This is a test course created to demonstrate the course management system functionality.',
      'shortDescription': 'Test course for course management system',
      'category': 'programming',
      'difficulty': 'beginner',
      'prerequisites': ['Basic programming knowledge'],
      'learningOutcomes': [
        'Understand course management',
        'Test API functionality',
        'Verify Flutter integration'
      ],
      'tags': ['flutter', 'test', 'course-management'],
      'isFree': true,
    };

    try {
      final response = await CourseService.createCourse(testCourse);

      if (response['success'] == true) {
        setState(() {
          _statusMessage = 'Test course created successfully!';
        });
        _loadCourses(); // Reload courses
      } else {
        setState(() {
          _statusMessage = 'Error creating course: ${response['message']}';
        });
      }
    } catch (e) {
      setState(() {
        _statusMessage = 'Network error creating course: $e';
      });
    } finally {
      setState(() => _isLoading = false);
    }
  }

  Future<void> _testEnrollment(Course course) async {
    setState(() {
      _isLoading = true;
      _statusMessage = 'Enrolling in ${course.title}...';
    });

    try {
      final response = await CourseService.enrollCourse(course.id);

      if (response['success'] == true) {
        setState(() {
          _statusMessage = 'Successfully enrolled in ${course.title}!';
        });
      } else {
        setState(() {
          _statusMessage = 'Error enrolling: ${response['message']}';
        });
      }
    } catch (e) {
      setState(() {
        _statusMessage = 'Network error enrolling: $e';
      });
    } finally {
      setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Course Management Demo',
          style: TextStyle(
            fontWeight: FontWeight.bold,
            color: Colors.white,
          ),
        ),
        backgroundColor: Colors.blue[600],
        elevation: 0,
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh, color: Colors.white),
            onPressed: _loadCourses,
          ),
        ],
      ),
      body: Column(
        children: [
          // Status and controls
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.white,
              boxShadow: [
                BoxShadow(
                  color: Colors.grey.withValues(alpha: 0.1),
                  spreadRadius: 1,
                  blurRadius: 3,
                  offset: const Offset(0, 1),
                ),
              ],
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Status message
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: _statusMessage.contains('Error') ||
                            _statusMessage.contains('error')
                        ? Colors.red[50]
                        : _statusMessage.contains('Successfully') ||
                                _statusMessage.contains('success')
                            ? Colors.green[50]
                            : Colors.blue[50],
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(
                      color: _statusMessage.contains('Error') ||
                              _statusMessage.contains('error')
                          ? Colors.red[200]!
                          : _statusMessage.contains('Successfully') ||
                                  _statusMessage.contains('success')
                              ? Colors.green[200]!
                              : Colors.blue[200]!,
                    ),
                  ),
                  child: Row(
                    children: [
                      if (_isLoading)
                        const SizedBox(
                          width: 16,
                          height: 16,
                          child: CircularProgressIndicator(strokeWidth: 2),
                        )
                      else
                        Icon(
                          _statusMessage.contains('Error') ||
                                  _statusMessage.contains('error')
                              ? Icons.error
                              : _statusMessage.contains('Successfully') ||
                                      _statusMessage.contains('success')
                                  ? Icons.check_circle
                                  : Icons.info,
                          size: 16,
                          color: _statusMessage.contains('Error') ||
                                  _statusMessage.contains('error')
                              ? Colors.red
                              : _statusMessage.contains('Successfully') ||
                                      _statusMessage.contains('success')
                                  ? Colors.green
                                  : Colors.blue,
                        ),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Text(
                          _statusMessage.isEmpty
                              ? 'Ready to test course management'
                              : _statusMessage,
                          style: TextStyle(
                            color: _statusMessage.contains('Error') ||
                                    _statusMessage.contains('error')
                                ? Colors.red[700]
                                : _statusMessage.contains('Successfully') ||
                                        _statusMessage.contains('success')
                                    ? Colors.green[700]
                                    : Colors.blue[700],
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),

                const SizedBox(height: 16),

                // Action buttons
                Row(
                  children: [
                    Expanded(
                      child: ElevatedButton.icon(
                        onPressed: _isLoading ? null : _loadCourses,
                        icon: const Icon(Icons.refresh),
                        label: const Text('Load Courses'),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.blue,
                          foregroundColor: Colors.white,
                        ),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: ElevatedButton.icon(
                        onPressed: _isLoading ? null : _testCourseCreation,
                        icon: const Icon(Icons.add),
                        label: const Text('Create Test Course'),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.green,
                          foregroundColor: Colors.white,
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),

          // Course count
          if (_courses.isNotEmpty)
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              child: Row(
                children: [
                  Text(
                    '${_courses.length} course${_courses.length != 1 ? 's' : ''} available',
                    style: TextStyle(
                      color: Colors.grey[600],
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ],
              ),
            ),

          // Course list
          Expanded(
            child: _courses.isEmpty && !_isLoading
                ? _buildEmptyState()
                : ListView.builder(
                    padding: const EdgeInsets.only(bottom: 16),
                    itemCount: _courses.length,
                    itemBuilder: (context, index) {
                      final course = _courses[index];
                      return CourseCard(
                        course: course,
                        onTap: () {
                          // Show course details in a dialog
                          _showCourseDetails(course);
                        },
                        onEnroll: () => _testEnrollment(course),
                      );
                    },
                  ),
          ),
        ],
      ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.school_outlined,
            size: 64,
            color: Colors.grey[400],
          ),
          const SizedBox(height: 16),
          Text(
            'No courses available',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: Colors.grey[600],
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Try creating a test course or check your connection',
            style: TextStyle(
              color: Colors.grey[500],
            ),
          ),
          const SizedBox(height: 24),
          ElevatedButton.icon(
            onPressed: _testCourseCreation,
            icon: const Icon(Icons.add),
            label: const Text('Create Test Course'),
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.blue,
              foregroundColor: Colors.white,
            ),
          ),
        ],
      ),
    );
  }

  void _showCourseDetails(Course course) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(course.title),
        content: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              Text('Category: ${course.category}'),
              Text('Difficulty: ${course.difficulty}'),
              Text('Duration: ${course.formattedDuration}'),
              Text('Modules: ${course.totalModules}'),
              Text('Students: ${course.enrollmentCount}'),
              Text(
                  'Rating: ${course.averageRating.toStringAsFixed(1)} (${course.totalRatings} reviews)'),
              Text('Free: ${course.isFree ? 'Yes' : 'No'}'),
              if (!course.isFree)
                Text('Price: \$${course.price.toStringAsFixed(2)}'),
              const SizedBox(height: 12),
              const Text('Description:',
                  style: TextStyle(fontWeight: FontWeight.bold)),
              Text(course.description),
              if (course.learningOutcomes.isNotEmpty) ...[
                const SizedBox(height: 12),
                const Text('Learning Outcomes:',
                    style: TextStyle(fontWeight: FontWeight.bold)),
                ...course.learningOutcomes.map((outcome) => Text('• $outcome')),
              ],
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Close'),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(context);
              _testEnrollment(course);
            },
            child: const Text('Enroll'),
          ),
        ],
      ),
    );
  }
}
