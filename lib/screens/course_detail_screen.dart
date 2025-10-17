import 'package:flutter/material.dart';
import '../services/course_service.dart';
import '../models/course.dart';

class CourseDetailScreen extends StatefulWidget {
  final String courseId;

  const CourseDetailScreen({
    Key? key,
    required this.courseId,
  }) : super(key: key);

  @override
  State<CourseDetailScreen> createState() => _CourseDetailScreenState();
}

class _CourseDetailScreenState extends State<CourseDetailScreen> {
  Course? _course;
  bool _isLoading = true;
  bool _isEnrolled = false;
  Map<String, dynamic>? _userProgress;

  @override
  void initState() {
    super.initState();
    _loadCourseDetails();
  }

  Future<void> _loadCourseDetails() async {
    setState(() => _isLoading = true);

    try {
      final response = await CourseService.getCourse(widget.courseId);

      if (response['success'] == true) {
        final courseData = response['data']['course'];
        setState(() {
          _course = Course.fromJson(courseData);
          _isEnrolled = response['data']['isEnrolled'] ?? false;
          _userProgress = response['data']['userProgress'];
        });
      } else {
        _showErrorSnackBar(response['message'] ?? 'Failed to load course');
      }
    } catch (e) {
      _showErrorSnackBar('Network error: $e');
    } finally {
      setState(() => _isLoading = false);
    }
  }

  Future<void> _enrollInCourse() async {
    if (_course == null) return;

    try {
      final response = await CourseService.enrollCourse(_course!.id);

      if (response['success'] == true) {
        setState(() => _isEnrolled = true);
        _showSuccessSnackBar('Successfully enrolled in ${_course!.title}!');
      } else {
        _showErrorSnackBar(response['message'] ?? 'Failed to enroll in course');
      }
    } catch (e) {
      _showErrorSnackBar('Network error: $e');
    }
  }

  Future<void> _unenrollFromCourse() async {
    if (_course == null) return;

    final confirmed = await _showConfirmDialog(
      'Unenroll from Course',
      'Are you sure you want to unenroll from ${_course!.title}? Your progress will be lost.',
    );

    if (!confirmed) return;

    try {
      final response = await CourseService.unenrollCourse(_course!.id);

      if (response['success'] == true) {
        setState(() {
          _isEnrolled = false;
          _userProgress = null;
        });
        _showSuccessSnackBar('Successfully unenrolled from ${_course!.title}');
      } else {
        _showErrorSnackBar(
            response['message'] ?? 'Failed to unenroll from course');
      }
    } catch (e) {
      _showErrorSnackBar('Network error: $e');
    }
  }

  Future<bool> _showConfirmDialog(String title, String content) async {
    return await showDialog<bool>(
          context: context,
          builder: (context) => AlertDialog(
            title: Text(title),
            content: Text(content),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context, false),
                child: const Text('Cancel'),
              ),
              ElevatedButton(
                onPressed: () => Navigator.pop(context, true),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.red,
                  foregroundColor: Colors.white,
                ),
                child: const Text('Confirm'),
              ),
            ],
          ),
        ) ??
        false;
  }

  void _showErrorSnackBar(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: Colors.red,
        behavior: SnackBarBehavior.floating,
      ),
    );
  }

  void _showSuccessSnackBar(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: Colors.green,
        behavior: SnackBarBehavior.floating,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : _course == null
              ? _buildErrorState()
              : _buildCourseContent(),
    );
  }

  Widget _buildErrorState() {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Course Not Found'),
      ),
      body: const Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.error_outline, size: 64, color: Colors.grey),
            SizedBox(height: 16),
            Text(
              'Course not found',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            SizedBox(height: 8),
            Text('The course you\'re looking for doesn\'t exist.'),
          ],
        ),
      ),
    );
  }

  Widget _buildCourseContent() {
    return CustomScrollView(
      slivers: [
        // App bar with course image
        SliverAppBar(
          expandedHeight: 250,
          pinned: true,
          flexibleSpace: FlexibleSpaceBar(
            title: Text(
              _course!.title,
              style: const TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.bold,
                shadows: [
                  Shadow(
                    offset: Offset(0, 1),
                    blurRadius: 3,
                    color: Colors.black54,
                  ),
                ],
              ),
            ),
            background: Container(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [
                    Colors.blue[400]!,
                    Colors.blue[600]!,
                  ],
                ),
              ),
              child: _course!.thumbnail != null
                  ? Stack(
                      fit: StackFit.expand,
                      children: [
                        Image.network(
                          _course!.thumbnail!,
                          fit: BoxFit.cover,
                          errorBuilder: (context, error, stackTrace) =>
                              Container(),
                        ),
                        Container(
                          decoration: BoxDecoration(
                            gradient: LinearGradient(
                              begin: Alignment.topCenter,
                              end: Alignment.bottomCenter,
                              colors: [
                                Colors.transparent,
                                Colors.black.withValues(alpha: 0.7),
                              ],
                            ),
                          ),
                        ),
                      ],
                    )
                  : const Center(
                      child: Icon(
                        Icons.school,
                        size: 64,
                        color: Colors.white70,
                      ),
                    ),
            ),
          ),
        ),

        // Course content
        SliverToBoxAdapter(
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Course info cards
                _buildCourseInfoCard(),
                const SizedBox(height: 16),

                // Progress card (if enrolled)
                if (_isEnrolled && _userProgress != null) _buildProgressCard(),

                // Enrollment button
                if (!_isEnrolled)
                  _buildEnrollmentCard()
                else
                  _buildEnrolledActions(),

                const SizedBox(height: 24),

                // Course description
                _buildDescriptionSection(),
                const SizedBox(height: 24),

                // Learning outcomes
                if (_course!.learningOutcomes.isNotEmpty)
                  _buildLearningOutcomesSection(),

                const SizedBox(height: 24),

                // Course modules
                _buildModulesSection(),

                const SizedBox(height: 24),

                // Instructor info
                _buildInstructorSection(),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildCourseInfoCard() {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            Row(
              children: [
                _buildInfoChip(
                  Icons.category,
                  _course!.category.toUpperCase(),
                  Colors.blue,
                ),
                const SizedBox(width: 8),
                _buildInfoChip(
                  Icons.signal_cellular_alt,
                  _course!.difficulty.toUpperCase(),
                  _getDifficultyColor(_course!.difficulty),
                ),
                const Spacer(),
                if (!_course!.isFree)
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 12,
                      vertical: 6,
                    ),
                    decoration: BoxDecoration(
                      color: Colors.green,
                      borderRadius: BorderRadius.circular(16),
                    ),
                    child: Text(
                      '\$${_course!.price.toStringAsFixed(2)}',
                      style: const TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
              ],
            ),
            const SizedBox(height: 16),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                _buildStatColumn(
                  Icons.schedule,
                  _course!.formattedDuration,
                  'Duration',
                ),
                _buildStatColumn(
                  Icons.play_lesson,
                  '${_course!.totalModules}',
                  'Modules',
                ),
                _buildStatColumn(
                  Icons.people,
                  '${_course!.enrollmentCount}',
                  'Students',
                ),
                _buildStatColumn(
                  Icons.star,
                  _course!.averageRating.toStringAsFixed(1),
                  'Rating',
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildProgressCard() {
    final progress = _userProgress!['progress'] ?? 0;
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                const Icon(Icons.trending_up, color: Colors.green),
                const SizedBox(width: 8),
                const Text(
                  'Your Progress',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const Spacer(),
                Text(
                  '$progress%',
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: Colors.green,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            LinearProgressIndicator(
              value: progress / 100,
              backgroundColor: Colors.grey[300],
              valueColor: const AlwaysStoppedAnimation<Color>(Colors.green),
            ),
            const SizedBox(height: 8),
            Text(
              '${_userProgress!['completedModules']?.length ?? 0} of ${_course!.totalModules} modules completed',
              style: TextStyle(color: Colors.grey[600]),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildEnrollmentCard() {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            Row(
              children: [
                Icon(
                  _course!.isFree ? Icons.school : Icons.payment,
                  color: Colors.blue,
                ),
                const SizedBox(width: 8),
                Text(
                  _course!.isFree ? 'Free Course' : 'Premium Course',
                  style: const TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: _enrollInCourse,
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.blue,
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                ),
                child: Text(
                  _course!.isFree
                      ? 'Enroll Free'
                      : 'Enroll Now - \$${_course!.price.toStringAsFixed(2)}',
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

  Widget _buildEnrolledActions() {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            Row(
              children: [
                const Icon(Icons.check_circle, color: Colors.green),
                const SizedBox(width: 8),
                const Text(
                  'Enrolled',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: Colors.green,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            Row(
              children: [
                Expanded(
                  child: ElevatedButton(
                    onPressed: () {
                      // Navigate to course content
                      // TODO: Implement course content navigation
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.blue,
                      foregroundColor: Colors.white,
                    ),
                    child: const Text('Continue Learning'),
                  ),
                ),
                const SizedBox(width: 12),
                OutlinedButton(
                  onPressed: _unenrollFromCourse,
                  style: OutlinedButton.styleFrom(
                    foregroundColor: Colors.red,
                    side: const BorderSide(color: Colors.red),
                  ),
                  child: const Text('Unenroll'),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildDescriptionSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'About This Course',
          style: TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 12),
        Text(
          _course!.description,
          style: const TextStyle(
            fontSize: 16,
            height: 1.5,
          ),
        ),
      ],
    );
  }

  Widget _buildLearningOutcomesSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'What You\'ll Learn',
          style: TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 12),
        ...(_course!.learningOutcomes.map((outcome) => Padding(
              padding: const EdgeInsets.only(bottom: 8),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Icon(
                    Icons.check_circle,
                    color: Colors.green,
                    size: 20,
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      outcome,
                      style: const TextStyle(fontSize: 16),
                    ),
                  ),
                ],
              ),
            ))),
      ],
    );
  }

  Widget _buildModulesSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Course Content (${_course!.modules.length} modules)',
          style: const TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 12),
        ...(_course!.modules.asMap().entries.map((entry) {
          final index = entry.key;
          final module = entry.value;
          return Card(
            margin: const EdgeInsets.only(bottom: 8),
            child: ListTile(
              leading: CircleAvatar(
                backgroundColor: Colors.blue,
                child: Text(
                  '${index + 1}',
                  style: const TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
              title: Text(
                module.title,
                style: const TextStyle(fontWeight: FontWeight.bold),
              ),
              subtitle: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(module.description),
                  const SizedBox(height: 4),
                  Row(
                    children: [
                      Icon(Icons.schedule, size: 16, color: Colors.grey[600]),
                      const SizedBox(width: 4),
                      Text(
                        '${module.duration} min',
                        style: TextStyle(color: Colors.grey[600]),
                      ),
                      const SizedBox(width: 16),
                      Icon(Icons.play_circle,
                          size: 16, color: Colors.grey[600]),
                      const SizedBox(width: 4),
                      Text(
                        module.contentType,
                        style: TextStyle(color: Colors.grey[600]),
                      ),
                    ],
                  ),
                ],
              ),
              trailing: _isEnrolled
                  ? const Icon(Icons.play_arrow, color: Colors.blue)
                  : const Icon(Icons.lock, color: Colors.grey),
              onTap: _isEnrolled
                  ? () {
                      // TODO: Navigate to module content
                    }
                  : null,
            ),
          );
        })),
      ],
    );
  }

  Widget _buildInstructorSection() {
    if (_course!.createdBy == null) return const SizedBox.shrink();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Instructor',
          style: TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 12),
        Card(
          child: ListTile(
            leading: CircleAvatar(
              backgroundColor: Colors.blue,
              child: Text(
                _course!.createdBy!.firstName[0].toUpperCase(),
                style: const TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
            title: Text(
              _course!.createdBy!.fullName,
              style: const TextStyle(fontWeight: FontWeight.bold),
            ),
            subtitle: Text(_course!.createdBy!.email),
          ),
        ),
      ],
    );
  }

  Widget _buildInfoChip(IconData icon, String label, Color color) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: color.withValues(alpha: 0.3)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 14, color: color),
          const SizedBox(width: 4),
          Text(
            label,
            style: TextStyle(
              color: color,
              fontSize: 12,
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStatColumn(IconData icon, String value, String label) {
    return Column(
      children: [
        Icon(icon, color: Colors.blue),
        const SizedBox(height: 4),
        Text(
          value,
          style: const TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.bold,
          ),
        ),
        Text(
          label,
          style: TextStyle(
            fontSize: 12,
            color: Colors.grey[600],
          ),
        ),
      ],
    );
  }

  Color _getDifficultyColor(String difficulty) {
    switch (difficulty.toLowerCase()) {
      case 'beginner':
        return Colors.green;
      case 'intermediate':
        return Colors.orange;
      case 'advanced':
        return Colors.red;
      default:
        return Colors.grey;
    }
  }
}
