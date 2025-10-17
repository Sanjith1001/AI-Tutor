import 'dart:convert';
import 'package:http/http.dart' as http;
import 'auth_backend_service.dart';

class CourseService {
  static const String baseUrl = 'http://localhost:3000/api/courses';

  // Get all courses with filtering
  static Future<Map<String, dynamic>> getCourses({
    int page = 1,
    int limit = 12,
    String? category,
    String? difficulty,
    String? search,
    String sort = 'newest',
    bool? isFree,
  }) async {
    try {
      final queryParams = <String, String>{
        'page': page.toString(),
        'limit': limit.toString(),
        'sort': sort,
      };

      if (category != null) queryParams['category'] = category;
      if (difficulty != null) queryParams['difficulty'] = difficulty;
      if (search != null && search.isNotEmpty) queryParams['search'] = search;
      if (isFree != null) queryParams['isFree'] = isFree.toString();

      final uri = Uri.parse(baseUrl).replace(queryParameters: queryParams);
      final response = await http.get(uri);

      return json.decode(response.body);
    } catch (e) {
      return {
        'success': false,
        'message': 'Network error: $e',
      };
    }
  }

  // Get course categories
  static Future<Map<String, dynamic>> getCategories() async {
    try {
      final response = await http.get(Uri.parse('$baseUrl/categories'));
      return json.decode(response.body);
    } catch (e) {
      return {
        'success': false,
        'message': 'Network error: $e',
      };
    }
  }

  // Get popular courses
  static Future<Map<String, dynamic>> getPopularCourses({int limit = 6}) async {
    try {
      final uri = Uri.parse('$baseUrl/popular').replace(
        queryParameters: {'limit': limit.toString()},
      );
      final response = await http.get(uri);
      return json.decode(response.body);
    } catch (e) {
      return {
        'success': false,
        'message': 'Network error: $e',
      };
    }
  }

  // Get recommended courses (requires auth)
  static Future<Map<String, dynamic>> getRecommendedCourses() async {
    try {
      final token = await AuthBackendService.getToken();
      if (token == null) {
        return {
          'success': false,
          'message': 'Authentication required',
        };
      }

      final response = await http.get(
        Uri.parse('$baseUrl/recommended'),
        headers: {
          'Authorization': 'Bearer $token',
          'Content-Type': 'application/json',
        },
      );

      return json.decode(response.body);
    } catch (e) {
      return {
        'success': false,
        'message': 'Network error: $e',
      };
    }
  }

  // Get single course by ID
  static Future<Map<String, dynamic>> getCourse(String courseId) async {
    try {
      final token = await AuthBackendService.getToken();
      final headers = <String, String>{
        'Content-Type': 'application/json',
      };

      if (token != null) {
        headers['Authorization'] = 'Bearer $token';
      }

      final response = await http.get(
        Uri.parse('$baseUrl/$courseId'),
        headers: headers,
      );

      return json.decode(response.body);
    } catch (e) {
      return {
        'success': false,
        'message': 'Network error: $e',
      };
    }
  }

  // Enroll in a course
  static Future<Map<String, dynamic>> enrollCourse(String courseId) async {
    try {
      final token = await AuthBackendService.getToken();
      if (token == null) {
        return {
          'success': false,
          'message': 'Authentication required',
        };
      }

      final response = await http.post(
        Uri.parse('$baseUrl/$courseId/enroll'),
        headers: {
          'Authorization': 'Bearer $token',
          'Content-Type': 'application/json',
        },
      );

      return json.decode(response.body);
    } catch (e) {
      return {
        'success': false,
        'message': 'Network error: $e',
      };
    }
  }

  // Unenroll from a course
  static Future<Map<String, dynamic>> unenrollCourse(String courseId) async {
    try {
      final token = await AuthBackendService.getToken();
      if (token == null) {
        return {
          'success': false,
          'message': 'Authentication required',
        };
      }

      final response = await http.post(
        Uri.parse('$baseUrl/$courseId/unenroll'),
        headers: {
          'Authorization': 'Bearer $token',
          'Content-Type': 'application/json',
        },
      );

      return json.decode(response.body);
    } catch (e) {
      return {
        'success': false,
        'message': 'Network error: $e',
      };
    }
  }

  // Complete a module
  static Future<Map<String, dynamic>> completeModule(
      String courseId, String moduleId,
      {double? score}) async {
    try {
      final token = await AuthBackendService.getToken();
      if (token == null) {
        return {
          'success': false,
          'message': 'Authentication required',
        };
      }

      final body = <String, dynamic>{};
      if (score != null) body['score'] = score;

      final response = await http.post(
        Uri.parse('$baseUrl/$courseId/modules/$moduleId/complete'),
        headers: {
          'Authorization': 'Bearer $token',
          'Content-Type': 'application/json',
        },
        body: json.encode(body),
      );

      return json.decode(response.body);
    } catch (e) {
      return {
        'success': false,
        'message': 'Network error: $e',
      };
    }
  }

  // Rate a course
  static Future<Map<String, dynamic>> rateCourse(String courseId, int rating,
      {String? review}) async {
    try {
      final token = await AuthBackendService.getToken();
      if (token == null) {
        return {
          'success': false,
          'message': 'Authentication required',
        };
      }

      final body = {
        'rating': rating,
        if (review != null && review.isNotEmpty) 'review': review,
      };

      final response = await http.post(
        Uri.parse('$baseUrl/$courseId/rate'),
        headers: {
          'Authorization': 'Bearer $token',
          'Content-Type': 'application/json',
        },
        body: json.encode(body),
      );

      return json.decode(response.body);
    } catch (e) {
      return {
        'success': false,
        'message': 'Network error: $e',
      };
    }
  }

  // Create a new course (Admin/Teacher only)
  static Future<Map<String, dynamic>> createCourse(
      Map<String, dynamic> courseData) async {
    try {
      final token = await AuthBackendService.getToken();
      if (token == null) {
        return {
          'success': false,
          'message': 'Authentication required',
        };
      }

      final response = await http.post(
        Uri.parse(baseUrl),
        headers: {
          'Authorization': 'Bearer $token',
          'Content-Type': 'application/json',
        },
        body: json.encode(courseData),
      );

      return json.decode(response.body);
    } catch (e) {
      return {
        'success': false,
        'message': 'Network error: $e',
      };
    }
  }

  // Update a course (Admin/Course Creator only)
  static Future<Map<String, dynamic>> updateCourse(
      String courseId, Map<String, dynamic> courseData) async {
    try {
      final token = await AuthBackendService.getToken();
      if (token == null) {
        return {
          'success': false,
          'message': 'Authentication required',
        };
      }

      final response = await http.put(
        Uri.parse('$baseUrl/$courseId'),
        headers: {
          'Authorization': 'Bearer $token',
          'Content-Type': 'application/json',
        },
        body: json.encode(courseData),
      );

      return json.decode(response.body);
    } catch (e) {
      return {
        'success': false,
        'message': 'Network error: $e',
      };
    }
  }

  // Delete a course (Admin/Course Creator only)
  static Future<Map<String, dynamic>> deleteCourse(String courseId) async {
    try {
      final token = await AuthBackendService.getToken();
      if (token == null) {
        return {
          'success': false,
          'message': 'Authentication required',
        };
      }

      final response = await http.delete(
        Uri.parse('$baseUrl/$courseId'),
        headers: {
          'Authorization': 'Bearer $token',
          'Content-Type': 'application/json',
        },
      );

      return json.decode(response.body);
    } catch (e) {
      return {
        'success': false,
        'message': 'Network error: $e',
      };
    }
  }
}
