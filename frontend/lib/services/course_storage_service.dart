import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';

class CourseStorageService {
  static const String _lastCourseKey = 'last_generated_course';
  static const String _courseProgressKey = 'course_progress';

  // Store the last generated course
  static Future<void> storeLastCourse({
    required String title,
    required List<Map<String, dynamic>> modules,
    String? learningStyle,
    String? skillLevel,
  }) async {
    try {
      final prefs = await SharedPreferences.getInstance();

      final courseData = {
        'title': title,
        'modules': modules,
        'learningStyle': learningStyle,
        'skillLevel': skillLevel,
        'createdAt': DateTime.now().millisecondsSinceEpoch,
        'lastAccessedAt': DateTime.now().millisecondsSinceEpoch,
        'progress': 0.0, // Start with 0% progress
        'currentModuleIndex': 0,
      };

      await prefs.setString(_lastCourseKey, json.encode(courseData));
      print('✅ Course stored: $title');
    } catch (e) {
      print('❌ Error storing course: $e');
    }
  }

  // Get the last generated course
  static Future<Map<String, dynamic>?> getLastCourse() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final courseJson = prefs.getString(_lastCourseKey);

      if (courseJson != null) {
        final courseData = json.decode(courseJson) as Map<String, dynamic>;
        return courseData;
      }

      return null;
    } catch (e) {
      print('❌ Error retrieving course: $e');
      return null;
    }
  }

  // Update course progress
  static Future<void> updateCourseProgress({
    required int moduleIndex,
    required double progress,
  }) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final courseJson = prefs.getString(_lastCourseKey);

      if (courseJson != null) {
        final courseData = json.decode(courseJson) as Map<String, dynamic>;
        courseData['currentModuleIndex'] = moduleIndex;
        courseData['progress'] = progress;
        courseData['lastAccessedAt'] = DateTime.now().millisecondsSinceEpoch;

        await prefs.setString(_lastCourseKey, json.encode(courseData));
        print('✅ Course progress updated: ${progress.round()}%');
      }
    } catch (e) {
      print('❌ Error updating course progress: $e');
    }
  }

  // Check if user has an unfinished course
  static Future<bool> hasUnfinishedCourse() async {
    final course = await getLastCourse();
    if (course == null) return false;

    final progress = (course['progress'] as num?)?.toDouble() ?? 0.0;
    return progress < 100.0; // Course is unfinished if progress < 100%
  }

  // Get course progress percentage
  static Future<double> getCourseProgress() async {
    final course = await getLastCourse();
    if (course == null) return 0.0;

    return (course['progress'] as num?)?.toDouble() ?? 0.0;
  }

  // Get current module index
  static Future<int> getCurrentModuleIndex() async {
    final course = await getLastCourse();
    if (course == null) return 0;

    return course['currentModuleIndex'] as int? ?? 0;
  }

  // Clear course data (for testing or reset)
  static Future<void> clearCourseData() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.remove(_lastCourseKey);
      await prefs.remove(_courseProgressKey);
      print('✅ Course data cleared');
    } catch (e) {
      print('❌ Error clearing course data: $e');
    }
  }

  // Format time ago for display
  static String formatTimeAgo(int timestamp) {
    final now = DateTime.now();
    final courseTime = DateTime.fromMillisecondsSinceEpoch(timestamp);
    final difference = now.difference(courseTime);

    if (difference.inMinutes < 1) {
      return 'Just now';
    } else if (difference.inMinutes < 60) {
      return '${difference.inMinutes} minutes ago';
    } else if (difference.inHours < 24) {
      return '${difference.inHours} hours ago';
    } else if (difference.inDays < 7) {
      return '${difference.inDays} days ago';
    } else {
      return '${(difference.inDays / 7).floor()} weeks ago';
    }
  }
}
