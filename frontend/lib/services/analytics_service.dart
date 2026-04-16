import 'dart:convert';
import 'package:http/http.dart' as http;
import 'auth_backend_service.dart';

class AnalyticsService {
  static Future<String> _baseUrl() async {
    final base = await AuthBackendService.getBaseUrl();
    return '$base/analytics';
  }

  // Get online users count
  static Future<Map<String, dynamic>> getOnlineUsersCount() async {
    try {
      final token = await AuthBackendService.getToken();
      if (token == null) {
        return {
          'success': false,
          'message': 'Authentication required',
        };
      }

      final baseUrl = await _baseUrl();
      final response = await http.get(
        Uri.parse('$baseUrl/online-users'),
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

  // Get list of online users
  static Future<Map<String, dynamic>> getOnlineUsersList() async {
    try {
      final token = await AuthBackendService.getToken();
      if (token == null) {
        return {
          'success': false,
          'message': 'Authentication required',
        };
      }

      final baseUrl = await _baseUrl();
      final response = await http.get(
        Uri.parse('$baseUrl/online-users/list'),
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

  // Get comprehensive user statistics
  static Future<Map<String, dynamic>> getUserStats() async {
    try {
      final token = await AuthBackendService.getToken();
      if (token == null) {
        return {
          'success': false,
          'message': 'Authentication required',
        };
      }

      final baseUrl = await _baseUrl();
      final response = await http.get(
        Uri.parse('$baseUrl/user-stats'),
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

  // Update user activity (heartbeat)
  static Future<Map<String, dynamic>> updateActivity() async {
    try {
      final token = await AuthBackendService.getToken();
      if (token == null) {
        return {
          'success': false,
          'message': 'Authentication required',
        };
      }

      final baseUrl = await _baseUrl();
      final response = await http.put(
        Uri.parse('$baseUrl/activity'),
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

  // Cleanup offline users (admin only)
  static Future<Map<String, dynamic>> cleanupOfflineUsers() async {
    try {
      final token = await AuthBackendService.getToken();
      if (token == null) {
        return {
          'success': false,
          'message': 'Authentication required',
        };
      }

      final baseUrl = await _baseUrl();
      final response = await http.post(
        Uri.parse('$baseUrl/cleanup-offline'),
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
