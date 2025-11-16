import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:http/http.dart' as http;
import 'auth_backend_service.dart';

class ActivityService {
  static const String _activitiesKey = 'user_activities';
  static const String _statsKey = 'user_stats';
  static const String _learningStyleKey = 'learning_style';
  static const String _skillLevelKey = 'skill_level';

  // Activity types
  static const String activityQuiz = 'quiz';
  static const String activityCourse = 'course';
  static const String activityModule = 'module';
  static const String activityAssessment = 'assessment';
  static const String activityLogin = 'login';

  // Add a new activity (sync with backend)
  static Future<void> addActivity({
    required String type,
    required String title,
    required String description,
    Map<String, dynamic>? metadata,
    int? score,
    bool? completed,
  }) async {
    try {
      // Check if user is logged in
      final isLoggedIn = await AuthBackendService.isLoggedIn();
      if (!isLoggedIn) {
        // Store locally only if not logged in
        await _addActivityLocally(type, title, description, metadata);
        return;
      }

      // Try to add to backend first
      final baseUrl = await AuthBackendService.getBaseUrl();
      final headers = await AuthBackendService.getHeaders();

      final response = await http.post(
        Uri.parse('$baseUrl/activities'),
        headers: headers,
        body: json.encode({
          'type': type,
          'title': title,
          'description': description,
          'metadata': metadata ?? {},
          'score': score,
          'completed': completed ?? false,
        }),
      );

      if (response.statusCode == 201) {
        final data = json.decode(response.body);
        if (data['success']) {
          // Successfully added to backend, also store locally as backup
          await _addActivityLocally(type, title, description, metadata);
          return;
        }
      }

      // If backend fails, store locally
      await _addActivityLocally(type, title, description, metadata);
    } catch (e) {
      print('Error adding activity to backend: $e');
      // Fallback to local storage
      await _addActivityLocally(type, title, description, metadata);
    }
  }

  // Add activity locally (fallback method)
  static Future<void> _addActivityLocally(
    String type,
    String title,
    String description,
    Map<String, dynamic>? metadata,
  ) async {
    final prefs = await SharedPreferences.getInstance();

    final activity = {
      'type': type,
      'title': title,
      'description': description,
      'timestamp': DateTime.now().millisecondsSinceEpoch,
      'metadata': metadata ?? {},
    };

    // Get existing activities
    final activitiesJson = prefs.getStringList(_activitiesKey) ?? [];
    final activities = activitiesJson.map((json) => jsonDecode(json)).toList();

    // Add new activity at the beginning
    activities.insert(0, activity);

    // Keep only the last 50 activities
    if (activities.length > 50) {
      activities.removeRange(50, activities.length);
    }

    // Save back to preferences
    final updatedJson =
        activities.map((activity) => jsonEncode(activity)).toList();
    await prefs.setStringList(_activitiesKey, updatedJson);

    // Update stats based on activity type
    await _updateStats(type, metadata);
  }

  // Get recent activities from backend (user-specific)
  static Future<List<Map<String, dynamic>>> getRecentActivities(
      {int limit = 10}) async {
    try {
      // Check if user is logged in
      final isLoggedIn = await AuthBackendService.isLoggedIn();
      if (!isLoggedIn) {
        return []; // Return empty list for non-logged in users
      }

      // Get current user to verify they exist
      final currentUser = await AuthBackendService.getCurrentUser();
      if (currentUser == null) {
        return []; // Return empty list if user doesn't exist
      }

      // Fetch activities from backend
      final baseUrl = await AuthBackendService.getBaseUrl();
      final headers = await AuthBackendService.getHeaders();

      final response = await http.get(
        Uri.parse('$baseUrl/activities?limit=$limit'),
        headers: headers,
      );

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        if (data['success'] && data['data']['hasActivities']) {
          final activities =
              List<Map<String, dynamic>>.from(data['data']['activities']);

          // Store activities locally as backup
          await _storeActivitiesLocally(activities);

          return activities.map((activity) {
            try {
              return {
                'type': activity['type'] ?? 'unknown',
                'title': activity['title'] ?? 'Unknown Activity',
                'description': activity['description'] ?? 'No description',
                'timestamp': activity['createdAt'] != null
                    ? DateTime.parse(activity['createdAt'])
                        .millisecondsSinceEpoch
                    : DateTime.now().millisecondsSinceEpoch,
                'metadata': activity['metadata'] ?? {},
                'score': activity['score'],
                'completed': activity['completed'],
                'timeAgo': activity['timeAgo'] ?? 'Recently',
              };
            } catch (e) {
              print('Error parsing activity: $e');
              return {
                'type': 'unknown',
                'title': 'Unknown Activity',
                'description': 'No description',
                'timestamp': DateTime.now().millisecondsSinceEpoch,
                'metadata': {},
                'score': null,
                'completed': false,
                'timeAgo': 'Recently',
              };
            }
          }).toList();
        }
      }

      // If backend fails, try to get from local storage as fallback
      return await _getLocalActivities(limit);
    } catch (e) {
      print('Error fetching activities from backend: $e');
      // Fallback to local storage
      return await _getLocalActivities(limit);
    }
  }

  // Get activities from local storage (fallback)
  static Future<List<Map<String, dynamic>>> _getLocalActivities(
      int limit) async {
    final prefs = await SharedPreferences.getInstance();
    final activitiesJson = prefs.getStringList(_activitiesKey) ?? [];

    final activities = activitiesJson
        .map((json) => jsonDecode(json) as Map<String, dynamic>)
        .take(limit)
        .toList();

    return activities;
  }

  // Store activities locally as backup
  static Future<void> _storeActivitiesLocally(
      List<Map<String, dynamic>> activities) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final activitiesJson =
          activities.map((activity) => jsonEncode(activity)).toList();
      await prefs.setStringList(_activitiesKey, activitiesJson);
    } catch (e) {
      print('Error storing activities locally: $e');
    }
  }

  // Update user statistics
  static Future<void> _updateStats(
      String activityType, Map<String, dynamic>? metadata) async {
    final prefs = await SharedPreferences.getInstance();
    final statsJson = prefs.getString(_statsKey);

    Map<String, dynamic> stats = {};
    if (statsJson != null) {
      stats = jsonDecode(statsJson);
    }

    // Initialize stats if they don't exist
    stats['coursesCompleted'] ??= 0;
    stats['quizzesTaken'] ??= 0;
    stats['modulesCompleted'] ??= 0;
    stats['totalScore'] ??= 0;
    stats['totalQuizzes'] ??= 0;
    stats['assessmentsTaken'] ??= 0;

    // Update stats based on activity type
    switch (activityType) {
      case activityQuiz:
        stats['quizzesTaken'] = (stats['quizzesTaken'] as int) + 1;
        if (metadata != null && metadata['score'] != null) {
          stats['totalScore'] =
              (stats['totalScore'] as int) + (metadata['score'] as int);
          stats['totalQuizzes'] = (stats['totalQuizzes'] as int) + 1;
        }
        break;
      case activityCourse:
        if (metadata != null && metadata['completed'] == true) {
          stats['coursesCompleted'] = (stats['coursesCompleted'] as int) + 1;
        }
        break;
      case activityModule:
        if (metadata != null && metadata['completed'] == true) {
          stats['modulesCompleted'] = (stats['modulesCompleted'] as int) + 1;
        }
        break;
      case activityAssessment:
        stats['assessmentsTaken'] = (stats['assessmentsTaken'] as int) + 1;
        if (metadata != null && metadata['score'] != null) {
          stats['totalScore'] =
              (stats['totalScore'] as int) + (metadata['score'] as int);
          stats['totalQuizzes'] = (stats['totalQuizzes'] as int) + 1;
        }
        break;
    }

    await prefs.setString(_statsKey, jsonEncode(stats));
  }

  // Get user statistics
  static Future<Map<String, dynamic>> getStats() async {
    final prefs = await SharedPreferences.getInstance();
    final statsJson = prefs.getString(_statsKey);

    if (statsJson != null) {
      return jsonDecode(statsJson);
    }

    // Return default stats
    return {
      'coursesCompleted': 0,
      'quizzesTaken': 0,
      'modulesCompleted': 0,
      'totalScore': 0,
      'totalQuizzes': 0,
      'assessmentsTaken': 0,
    };
  }

  // Calculate average score
  static Future<double> getAverageScore() async {
    final stats = await getStats();
    final totalScore = stats['totalScore'] as int;
    final totalQuizzes = stats['totalQuizzes'] as int;

    if (totalQuizzes == 0) return 0.0;
    return (totalScore / totalQuizzes).roundToDouble();
  }

  // Set learning style
  static Future<void> setLearningStyle(String style) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_learningStyleKey, style);

    // Add activity for learning style assessment
    await addActivity(
      type: activityAssessment,
      title: 'Completed VARK Learning Style Assessment',
      description: 'Result: $style Learner',
      metadata: {'learningStyle': style},
    );
  }

  // Get learning style
  static Future<String?> getLearningStyle() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString(_learningStyleKey);
  }

  // Set skill level
  static Future<void> setSkillLevel(String level) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_skillLevelKey, level);
  }

  // Get skill level
  static Future<String?> getSkillLevel() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString(_skillLevelKey);
  }

  // Format timestamp for display
  static String formatTimestamp(int timestamp) {
    final now = DateTime.now();
    final activityTime = DateTime.fromMillisecondsSinceEpoch(timestamp);
    final difference = now.difference(activityTime);

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

  // Add login activity
  static Future<void> addLoginActivity() async {
    await addActivity(
      type: activityLogin,
      title: 'Logged in to ByteBrain',
      description: 'Welcome back! Started a new learning session',
    );
  }

  // Get activity icon based on type
  static IconData getActivityIcon(String type) {
    switch (type) {
      case activityQuiz:
        return Icons.quiz;
      case activityCourse:
        return Icons.school;
      case activityModule:
        return Icons.book;
      case activityAssessment:
        return Icons.psychology;
      case activityLogin:
        return Icons.login;
      default:
        return Icons.timeline;
    }
  }

  // Get activity color based on type
  static Color getActivityColor(String type) {
    switch (type) {
      case activityQuiz:
        return Colors.blue;
      case activityCourse:
        return Colors.green;
      case activityModule:
        return Colors.orange;
      case activityAssessment:
        return Colors.purple;
      case activityLogin:
        return Colors.teal;
      default:
        return Colors.grey;
    }
  }

  // Clear user-specific data when user changes
  static Future<void> clearUserData() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_activitiesKey);
    await prefs.remove(_statsKey);
    await prefs.remove(_learningStyleKey);
    await prefs.remove(_skillLevelKey);
  }

  // Check if activities need to be refreshed for current user
  static Future<bool> needsRefresh() async {
    try {
      final currentUser = await AuthBackendService.getCurrentUser();
      if (currentUser == null) return true;

      final prefs = await SharedPreferences.getInstance();
      final lastUserId = prefs.getString('last_user_id');

      if (lastUserId != currentUser['id']) {
        // User has changed, clear old data and mark for refresh
        await clearUserData();
        await prefs.setString('last_user_id', currentUser['id']);
        return true;
      }

      return false;
    } catch (e) {
      return true; // Refresh on error
    }
  }

  // Force refresh activities for current user
  static Future<void> refreshActivities() async {
    try {
      final currentUser = await AuthBackendService.getCurrentUser();
      if (currentUser != null) {
        final prefs = await SharedPreferences.getInstance();
        await clearUserData();
        await prefs.setString('last_user_id', currentUser['id']);
      }
    } catch (e) {
      print('Error refreshing activities: $e');
    }
  }

  // Clear all data (for testing or reset)
  static Future<void> clearAllData() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_activitiesKey);
    await prefs.remove(_statsKey);
    await prefs.remove(_learningStyleKey);
    await prefs.remove(_skillLevelKey);
    await prefs.remove('last_user_id');
  }
}
