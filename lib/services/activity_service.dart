import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

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

  // Add a new activity
  static Future<void> addActivity({
    required String type,
    required String title,
    required String description,
    Map<String, dynamic>? metadata,
  }) async {
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
    final updatedJson = activities.map((activity) => jsonEncode(activity)).toList();
    await prefs.setStringList(_activitiesKey, updatedJson);
    
    // Update stats based on activity type
    await _updateStats(type, metadata);
  }

  // Get recent activities
  static Future<List<Map<String, dynamic>>> getRecentActivities({int limit = 10}) async {
    final prefs = await SharedPreferences.getInstance();
    final activitiesJson = prefs.getStringList(_activitiesKey) ?? [];
    
    final activities = activitiesJson
        .map((json) => jsonDecode(json) as Map<String, dynamic>)
        .take(limit)
        .toList();
    
    return activities;
  }

  // Update user statistics
  static Future<void> _updateStats(String activityType, Map<String, dynamic>? metadata) async {
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
          stats['totalScore'] = (stats['totalScore'] as int) + (metadata['score'] as int);
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
          stats['totalScore'] = (stats['totalScore'] as int) + (metadata['score'] as int);
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
      default:
        return Colors.grey;
    }
  }

  // Clear all data (for testing or reset)
  static Future<void> clearAllData() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_activitiesKey);
    await prefs.remove(_statsKey);
    await prefs.remove(_learningStyleKey);
    await prefs.remove(_skillLevelKey);
  }
}