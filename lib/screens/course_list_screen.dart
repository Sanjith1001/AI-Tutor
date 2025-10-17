import 'package:flutter/material.dart';
import '../services/course_service.dart';
import '../models/course.dart';
import '../widgets/course_card.dart';
import 'course_detail_screen.dart';

class CourseListScreen extends StatefulWidget {
  const CourseListScreen({Key? key}) : super(key: key);

  @override
  State<CourseListScreen> createState() => _CourseListScreenState();
}

class _CourseListScreenState extends State<CourseListScreen> {
  List<Course> _courses = [];
  List<Course> _filteredCourses = [];
  bool _isLoading = true;
  String _selectedCategory = 'All';
  String _selectedDifficulty = 'All';
  String _searchQuery = '';
  String _sortBy = 'newest';

  final TextEditingController _searchController = TextEditingController();

  final List<String> _categories = [
    'All',
    'programming',
    'mathematics',
    'science',
    'language',
    'business',
    'design',
    'music',
    'health',
    'personal-development',
    'technology'
  ];

  final List<String> _difficulties = [
    'All',
    'beginner',
    'intermediate',
    'advanced'
  ];
  final List<String> _sortOptions = ['newest', 'oldest', 'popular', 'rating'];

  @override
  void initState() {
    super.initState();
    _loadCourses();
  }

  Future<void> _loadCourses() async {
    setState(() => _isLoading = true);

    try {
      final response = await CourseService.getCourses(
        category: _selectedCategory == 'All' ? null : _selectedCategory,
        difficulty: _selectedDifficulty == 'All' ? null : _selectedDifficulty,
        search: _searchQuery.isEmpty ? null : _searchQuery,
        sort: _sortBy,
      );

      if (response['success'] == true) {
        final coursesData = response['data']['courses'] as List;
        setState(() {
          _courses = coursesData
              .map((courseJson) => Course.fromJson(courseJson))
              .toList();
          _filteredCourses = _courses;
        });
      } else {
        _showErrorSnackBar(response['message'] ?? 'Failed to load courses');
      }
    } catch (e) {
      _showErrorSnackBar('Network error: $e');
    } finally {
      setState(() => _isLoading = false);
    }
  }

  void _filterCourses() {
    setState(() {
      _filteredCourses = _courses.where((course) {
        final matchesCategory =
            _selectedCategory == 'All' || course.category == _selectedCategory;
        final matchesDifficulty = _selectedDifficulty == 'All' ||
            course.difficulty == _selectedDifficulty;
        final matchesSearch = _searchQuery.isEmpty ||
            course.title.toLowerCase().contains(_searchQuery.toLowerCase()) ||
            course.description
                .toLowerCase()
                .contains(_searchQuery.toLowerCase());

        return matchesCategory && matchesDifficulty && matchesSearch;
      }).toList();

      // Apply sorting
      _filteredCourses.sort((a, b) {
        switch (_sortBy) {
          case 'oldest':
            return a.createdAt.compareTo(b.createdAt);
          case 'popular':
            return b.enrollmentCount.compareTo(a.enrollmentCount);
          case 'rating':
            return b.averageRating.compareTo(a.averageRating);
          case 'newest':
          default:
            return b.createdAt.compareTo(a.createdAt);
        }
      });
    });
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

  Future<void> _enrollInCourse(Course course) async {
    try {
      final response = await CourseService.enrollCourse(course.id);

      if (response['success'] == true) {
        _showSuccessSnackBar('Successfully enrolled in ${course.title}!');
        // Navigate to course detail screen
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => CourseDetailScreen(courseId: course.id),
          ),
        );
      } else {
        _showErrorSnackBar(response['message'] ?? 'Failed to enroll in course');
      }
    } catch (e) {
      _showErrorSnackBar('Network error: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[50],
      appBar: AppBar(
        title: const Text(
          'Courses',
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
          // Search and filters
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
              children: [
                // Search bar
                TextField(
                  controller: _searchController,
                  decoration: InputDecoration(
                    hintText: 'Search courses...',
                    prefixIcon: const Icon(Icons.search),
                    suffixIcon: _searchQuery.isNotEmpty
                        ? IconButton(
                            icon: const Icon(Icons.clear),
                            onPressed: () {
                              _searchController.clear();
                              setState(() => _searchQuery = '');
                              _filterCourses();
                            },
                          )
                        : null,
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: BorderSide.none,
                    ),
                    filled: true,
                    fillColor: Colors.grey[100],
                  ),
                  onChanged: (value) {
                    setState(() => _searchQuery = value);
                    _filterCourses();
                  },
                ),

                const SizedBox(height: 16),

                // Filter chips
                SingleChildScrollView(
                  scrollDirection: Axis.horizontal,
                  child: Row(
                    children: [
                      // Category filter
                      _buildFilterDropdown(
                        'Category',
                        _selectedCategory,
                        _categories,
                        (value) {
                          setState(() => _selectedCategory = value!);
                          _filterCourses();
                        },
                      ),

                      const SizedBox(width: 12),

                      // Difficulty filter
                      _buildFilterDropdown(
                        'Difficulty',
                        _selectedDifficulty,
                        _difficulties,
                        (value) {
                          setState(() => _selectedDifficulty = value!);
                          _filterCourses();
                        },
                      ),

                      const SizedBox(width: 12),

                      // Sort filter
                      _buildFilterDropdown(
                        'Sort by',
                        _sortBy,
                        _sortOptions,
                        (value) {
                          setState(() => _sortBy = value!);
                          _filterCourses();
                        },
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),

          // Course count
          if (!_isLoading)
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              child: Row(
                children: [
                  Text(
                    '${_filteredCourses.length} course${_filteredCourses.length != 1 ? 's' : ''} found',
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
            child: _isLoading
                ? const Center(
                    child: CircularProgressIndicator(),
                  )
                : _filteredCourses.isEmpty
                    ? _buildEmptyState()
                    : RefreshIndicator(
                        onRefresh: _loadCourses,
                        child: ListView.builder(
                          padding: const EdgeInsets.only(bottom: 16),
                          itemCount: _filteredCourses.length,
                          itemBuilder: (context, index) {
                            final course = _filteredCourses[index];
                            return CourseCard(
                              course: course,
                              onTap: () {
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder: (context) => CourseDetailScreen(
                                      courseId: course.id,
                                    ),
                                  ),
                                );
                              },
                              onEnroll: () => _enrollInCourse(course),
                            );
                          },
                        ),
                      ),
          ),
        ],
      ),
    );
  }

  Widget _buildFilterDropdown(
    String label,
    String value,
    List<String> options,
    ValueChanged<String?> onChanged,
  ) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
      decoration: BoxDecoration(
        border: Border.all(color: Colors.grey[300]!),
        borderRadius: BorderRadius.circular(20),
      ),
      child: DropdownButtonHideUnderline(
        child: DropdownButton<String>(
          value: value,
          items: options.map((option) {
            return DropdownMenuItem<String>(
              value: option,
              child: Text(
                option == 'All' ? label : option,
                style: const TextStyle(fontSize: 14),
              ),
            );
          }).toList(),
          onChanged: onChanged,
          style: TextStyle(
            color: Colors.grey[700],
            fontSize: 14,
          ),
        ),
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
            'No courses found',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: Colors.grey[600],
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Try adjusting your search or filters',
            style: TextStyle(
              color: Colors.grey[500],
            ),
          ),
          const SizedBox(height: 24),
          ElevatedButton(
            onPressed: () {
              setState(() {
                _selectedCategory = 'All';
                _selectedDifficulty = 'All';
                _searchQuery = '';
                _searchController.clear();
              });
              _filterCourses();
            },
            child: const Text('Clear Filters'),
          ),
        ],
      ),
    );
  }
}
