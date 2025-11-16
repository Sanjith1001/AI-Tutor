import 'package:flutter/material.dart';
import '../models/course.dart';

class CourseCard extends StatelessWidget {
  final Course course;
  final VoidCallback? onTap;
  final bool showEnrollButton;
  final VoidCallback? onEnroll;

  const CourseCard({
    Key? key,
    required this.course,
    this.onTap,
    this.showEnrollButton = true,
    this.onEnroll,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 4,
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
      ),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Course thumbnail
            ClipRRect(
              borderRadius:
                  const BorderRadius.vertical(top: Radius.circular(16)),
              child: Container(
                height: 200,
                width: double.infinity,
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                    colors: _getCategoryColors(course.category),
                  ),
                ),
                child: course.thumbnail != null
                    ? Image.network(
                        course.thumbnail!,
                        fit: BoxFit.cover,
                        errorBuilder: (context, error, stackTrace) =>
                            _buildPlaceholderImage(),
                      )
                    : _buildPlaceholderImage(),
              ),
            ),

            // Course content
            Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Category and difficulty badges
                  Row(
                    children: [
                      _buildBadge(
                        course.category.toUpperCase(),
                        _getCategoryColor(course.category),
                      ),
                      const SizedBox(width: 8),
                      _buildBadge(
                        course.difficulty.toUpperCase(),
                        _getDifficultyColor(course.difficulty),
                      ),
                      const Spacer(),
                      if (!course.isFree)
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 8,
                            vertical: 4,
                          ),
                          decoration: BoxDecoration(
                            color: Colors.green,
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Text(
                            '\$${course.price.toStringAsFixed(2)}',
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 12,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                    ],
                  ),

                  const SizedBox(height: 12),

                  // Course title
                  Text(
                    course.title,
                    style: const TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: Colors.black87,
                    ),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),

                  const SizedBox(height: 8),

                  // Course description
                  Text(
                    course.shortDescription ?? course.description,
                    style: TextStyle(
                      fontSize: 14,
                      color: Colors.grey[600],
                      height: 1.4,
                    ),
                    maxLines: 3,
                    overflow: TextOverflow.ellipsis,
                  ),

                  const SizedBox(height: 16),

                  // Course stats
                  Row(
                    children: [
                      _buildStatItem(
                        Icons.schedule,
                        course.formattedDuration,
                        Colors.blue,
                      ),
                      const SizedBox(width: 16),
                      _buildStatItem(
                        Icons.play_lesson,
                        '${course.totalModules} modules',
                        Colors.purple,
                      ),
                      const SizedBox(width: 16),
                      _buildStatItem(
                        Icons.people,
                        '${course.enrollmentCount}',
                        Colors.orange,
                      ),
                    ],
                  ),

                  const SizedBox(height: 16),

                  // Rating and instructor
                  Row(
                    children: [
                      // Rating
                      Row(
                        children: [
                          const Icon(
                            Icons.star,
                            color: Colors.amber,
                            size: 16,
                          ),
                          const SizedBox(width: 4),
                          Text(
                            course.averageRating.toStringAsFixed(1),
                            style: const TextStyle(
                              fontWeight: FontWeight.bold,
                              fontSize: 14,
                            ),
                          ),
                          const SizedBox(width: 4),
                          Text(
                            '(${course.totalRatings})',
                            style: TextStyle(
                              color: Colors.grey[600],
                              fontSize: 12,
                            ),
                          ),
                        ],
                      ),

                      const Spacer(),

                      // Instructor
                      if (course.createdBy != null)
                        Text(
                          'by ${course.createdBy!.fullName}',
                          style: TextStyle(
                            color: Colors.grey[600],
                            fontSize: 12,
                          ),
                        ),
                    ],
                  ),

                  if (showEnrollButton) ...[
                    const SizedBox(height: 16),

                    // Enroll button
                    SizedBox(
                      width: double.infinity,
                      child: ElevatedButton(
                        onPressed: onEnroll,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Theme.of(context).primaryColor,
                          foregroundColor: Colors.white,
                          padding: const EdgeInsets.symmetric(vertical: 12),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(8),
                          ),
                        ),
                        child: Text(
                          course.isFree ? 'Enroll Free' : 'Enroll Now',
                          style: const TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ),
                  ],
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildPlaceholderImage() {
    return Container(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: _getCategoryColors(course.category),
        ),
      ),
      child: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              _getCategoryIcon(course.category),
              size: 48,
              color: Colors.white.withOpacity(0.8),
            ),
            const SizedBox(height: 8),
            Text(
              course.category.toUpperCase(),
              style: TextStyle(
                color: Colors.white.withOpacity(0.8),
                fontSize: 16,
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildBadge(String text, Color color) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: color.withOpacity(0.3)),
      ),
      child: Text(
        text,
        style: TextStyle(
          color: color,
          fontSize: 10,
          fontWeight: FontWeight.bold,
        ),
      ),
    );
  }

  Widget _buildStatItem(IconData icon, String text, Color color) {
    return Row(
      children: [
        Icon(icon, size: 16, color: color),
        const SizedBox(width: 4),
        Text(
          text,
          style: TextStyle(
            fontSize: 12,
            color: Colors.grey[700],
            fontWeight: FontWeight.w500,
          ),
        ),
      ],
    );
  }

  List<Color> _getCategoryColors(String category) {
    switch (category.toLowerCase()) {
      case 'programming':
        return [Colors.blue.shade400, Colors.blue.shade600];
      case 'mathematics':
        return [Colors.purple.shade400, Colors.purple.shade600];
      case 'science':
        return [Colors.green.shade400, Colors.green.shade600];
      case 'language':
        return [Colors.orange.shade400, Colors.orange.shade600];
      case 'business':
        return [Colors.teal.shade400, Colors.teal.shade600];
      case 'design':
        return [Colors.pink.shade400, Colors.pink.shade600];
      case 'music':
        return [Colors.indigo.shade400, Colors.indigo.shade600];
      case 'health':
        return [Colors.red.shade400, Colors.red.shade600];
      default:
        return [Colors.grey.shade400, Colors.grey.shade600];
    }
  }

  Color _getCategoryColor(String category) {
    switch (category.toLowerCase()) {
      case 'programming':
        return Colors.blue;
      case 'mathematics':
        return Colors.purple;
      case 'science':
        return Colors.green;
      case 'language':
        return Colors.orange;
      case 'business':
        return Colors.teal;
      case 'design':
        return Colors.pink;
      case 'music':
        return Colors.indigo;
      case 'health':
        return Colors.red;
      default:
        return Colors.grey;
    }
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

  IconData _getCategoryIcon(String category) {
    switch (category.toLowerCase()) {
      case 'programming':
        return Icons.code;
      case 'mathematics':
        return Icons.calculate;
      case 'science':
        return Icons.science;
      case 'language':
        return Icons.language;
      case 'business':
        return Icons.business;
      case 'design':
        return Icons.design_services;
      case 'music':
        return Icons.music_note;
      case 'health':
        return Icons.health_and_safety;
      default:
        return Icons.school;
    }
  }
}
