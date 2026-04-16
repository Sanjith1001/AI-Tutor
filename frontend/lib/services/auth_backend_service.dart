import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:http/http.dart' as http;
import 'package:flutter_dotenv/flutter_dotenv.dart';

class AuthBackendService {
  // Multiple URLs to try based on platform
  static const List<String> baseUrls = [
    'http://10.0.2.2:3000/api', // Android Emulator
    'http://localhost:3000/api', // iOS Simulator / Desktop
    'http://127.0.0.1:3000/api', // Alternative localhost
    'http://192.168.1.100:3000/api', // Replace with your computer's IP
  ];

  // If frontend .env defines API_URL, use that as highest priority.
  static String? get envBaseUrl {
    final raw = dotenv.env['API_URL'];
    if (raw == null || raw.isEmpty) return null;
    // Ensure it ends with /api
    if (raw.endsWith('/api')) return raw;
    if (raw.endsWith('/')) return raw + 'api';
    return raw + '/api';
  }

  static String? _workingBaseUrl;
  static const String _currentUserKey = 'current_user';
  static const String _authTokenKey = 'auth_token';
  static const String _refreshTokenKey = 'refresh_token';
  static const String _localUsersKey = 'local_users';

  // Find working base URL
  static Future<String?> findWorkingBaseUrl() async {
    if (_workingBaseUrl != null) return _workingBaseUrl;
    // If env provides a base URL, use it directly (no probing).
    final fromEnv = envBaseUrl;
    if (fromEnv != null) {
      // quick health check
      try {
        final resp = await http.get(Uri.parse(fromEnv.replaceAll('/api', '/health'))).timeout(const Duration(seconds: 3));
        if (resp.statusCode == 200) {
          _workingBaseUrl = fromEnv;
          return _workingBaseUrl;
        }
      } catch (_) {
        // fallthrough to probing other URLs
      }
    }
    for (String url in baseUrls) {
      try {
        print('🔍 Testing connection to: $url');
        final response = await http
            .get(
              Uri.parse(url.replaceAll('/api', '/health')),
            )
            .timeout(const Duration(seconds: 3));

        if (response.statusCode == 200) {
          _workingBaseUrl = url;
          print('✅ Found working URL: $url');
          return url;
        }
      } catch (e) {
        print('❌ Failed to connect to: $url - $e');
        continue;
      }
    }

    print('❌ No working URL found');
    return null;
  }

  // Get base URL (with fallback)
  static Future<String> getBaseUrl() async {
    final workingUrl = await findWorkingBaseUrl();
    return workingUrl ?? baseUrls.first; // Fallback to first URL
  }

  // Get stored token
  static Future<String?> getToken() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString(_authTokenKey);
  }

  // Store token
  static Future<void> storeToken(String token) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_authTokenKey, token);
  }

  // Store refresh token
  static Future<void> storeRefreshToken(String refreshToken) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_refreshTokenKey, refreshToken);
  }

  // Clear tokens
  static Future<void> clearTokens() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_authTokenKey);
    await prefs.remove(_refreshTokenKey);
    await prefs.remove(_currentUserKey);
  }

  // Get headers with auth token
  static Future<Map<String, String>> getHeaders() async {
    final token = await getToken();
    return {
      'Content-Type': 'application/json',
      if (token != null) 'Authorization': 'Bearer $token',
    };
  }

  // Register a new user
  static Future<Map<String, dynamic>> registerUser({
    required String email,
    required String password,
    required String name,
  }) async {
    try {
      // Split name into first and last name
      final nameParts = name.trim().split(' ');
      final firstName = nameParts.first;
      final lastName = nameParts.length > 1
          ? nameParts.sublist(1).join(' ')
          : 'User'; // Default last name if not provided

      final baseUrl = await getBaseUrl();
      if (baseUrl != null) {
        print('➡️ Register request -> ${baseUrl}/auth/register');
        final response = await http.post(
            Uri.parse('$baseUrl/auth/register'),
          headers: {'Content-Type': 'application/json'},
          body: json.encode({
            'email': email,
            'password': password,
            'firstName': firstName,
            'lastName': lastName,
          }),
        );

        final data = json.decode(response.body);

        if (response.statusCode == 201 && data['success']) {
          // Store tokens
          if (data['data']['token'] != null) {
            await storeToken(data['data']['token']);
          }
          if (data['data']['refreshToken'] != null) {
            await storeRefreshToken(data['data']['refreshToken']);
          }

          // Store user data
          final prefs = await SharedPreferences.getInstance();
          await prefs.setString(
              _currentUserKey, json.encode(data['data']['user']));

          return {
            'success': true,
            'message': data['message'] ?? 'Account created successfully!',
            'user': {
              'id': data['data']['user']['_id'],
              'email': data['data']['user']['email'],
              'name':
                  '${data['data']['user']['firstName']} ${data['data']['user']['lastName']}',
              'isAdmin': data['data']['user']['role'] == 'admin',
            }
          };
        } else {
          return {
            'success': false,
            'message': data['message'] ?? 'Registration failed'
          };
        }
      }

      // If no backend is reachable, store user locally for testing
      await _ensureDefaultTestUser();
      final localUser = {
        '_id': 'local-${DateTime.now().millisecondsSinceEpoch}',
        'email': email,
        'firstName': firstName,
        'lastName': lastName,
        'role': 'student',
        'password': password,
        'isEmailVerified': true,
      };
      await _saveLocalUser(localUser);

      // Store as current user
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString(_currentUserKey, json.encode(localUser));
      await storeToken('local-token-${localUser['_id']}');

      return {
        'success': true,
        'message': 'Registered locally (offline mode)',
        'user': {
          'id': localUser['_id'],
          'email': localUser['email'],
          'name': '${localUser['firstName']} ${localUser['lastName']}',
          'isAdmin': false,
        }
      };
    } catch (e) {
      return {'success': false, 'message': 'Network error: $e'};
    }
  }

  // Login user
  static Future<Map<String, dynamic>> loginUser({
    required String email,
    required String password,
  }) async {
    try {
      final baseUrl = await getBaseUrl();
      if (baseUrl != null) {
        print('🔐 Attempting login to: $baseUrl/auth/login');

        final response = await http
            .post(
              Uri.parse('$baseUrl/auth/login'),
              headers: {'Content-Type': 'application/json'},
              body: json.encode({
                'email': email,
                'password': password,
              }),
            )
            .timeout(const Duration(seconds: 10));

        final data = json.decode(response.body);

        if (response.statusCode == 200 && data['success']) {
          // Store tokens
          if (data['data']['token'] != null) {
            await storeToken(data['data']['token']);
          }
          if (data['data']['refreshToken'] != null) {
            await storeRefreshToken(data['data']['refreshToken']);
          }

          // Store user data
          final prefs = await SharedPreferences.getInstance();
          await prefs.setString(
              _currentUserKey, json.encode(data['data']['user']));

          return {
            'success': true,
            'message': data['message'] ?? 'Login successful!',
            'user': {
              'id': data['data']['user']['_id'],
              'email': data['data']['user']['email'],
              'name':
                  '${data['data']['user']['firstName']} ${data['data']['user']['lastName']}',
              'isAdmin': data['data']['user']['role'] == 'admin',
            },
            'isAdmin': data['data']['user']['role'] == 'admin',
          };
        } else {
          return {'success': false, 'message': data['message'] ?? 'Login failed'};
        }
      }

      // No backend reachable — try local users
      await _ensureDefaultTestUser();
      final local = await _getLocalUser(email);
      if (local == null) {
        return {'success': false, 'message': 'User not found (offline)'};
      }

      if (local['password'] != password) {
        return {'success': false, 'message': 'Invalid credentials (offline)'};
      }

      // Store tokens and current user locally
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString(_currentUserKey, json.encode(local));
      await storeToken('local-token-${local['_id']}');

      return {
        'success': true,
        'message': 'Logged in (offline mode)',
        'user': {
          'id': local['_id'],
          'email': local['email'],
          'name': '${local['firstName']} ${local['lastName']}',
          'isAdmin': local['role'] == 'admin',
        },
        'isAdmin': local['role'] == 'admin',
      };
    } catch (e) {
      // On unexpected network errors, attempt local fallback
      try {
        await _ensureDefaultTestUser();
        final local = await _getLocalUser(email);
        if (local != null && local['password'] == password) {
          final prefs = await SharedPreferences.getInstance();
          await prefs.setString(_currentUserKey, json.encode(local));
          await storeToken('local-token-${local['_id']}');
          return {
            'success': true,
            'message': 'Logged in (offline mode)',
            'user': {
              'id': local['_id'],
              'email': local['email'],
              'name': '${local['firstName']} ${local['lastName']}',
              'isAdmin': local['role'] == 'admin',
            },
            'isAdmin': local['role'] == 'admin',
          };
        }
      } catch (_) {}

      return {'success': false, 'message': 'Network error: $e'};
    }
  }

  // Logout user
  static Future<void> logoutUser() async {
    try {
      final baseUrl = await getBaseUrl();
      final headers = await getHeaders();
      await http.post(
        Uri.parse('$baseUrl/auth/logout'),
        headers: headers,
      );
    } catch (e) {
      // Continue with logout even if API call fails
      print('Logout API error: $e');
    }

    // Clear local storage
    await clearTokens();
  }

  // Check if user is logged in
  static Future<bool> isLoggedIn() async {
    final token = await getToken();
    return token != null;
  }

  // Get current user
  static Future<Map<String, dynamic>?> getCurrentUser() async {
    try {
      final baseUrl = await getBaseUrl();
      final headers = await getHeaders();
      final response = await http.get(
        Uri.parse('$baseUrl/auth/me'),
        headers: headers,
      );

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        if (data['success']) {
          final user = data['data']['user'];
          return {
            'id': user['_id'],
            'email': user['email'],
            'name': '${user['firstName']} ${user['lastName']}',
            'isAdmin': user['role'] == 'admin',
            'role': user['role'],
            'firstName': user['firstName'],
            'lastName': user['lastName'],
            'learningStyle': user['learningStyle'],
            'preferences': user['preferences'],
            'createdAt': user['createdAt'],
            'lastLogin': user['lastLogin'],
            'isEmailVerified': user['isEmailVerified'],
          };
        }
      }

      // If API call fails, try to get from local storage
      final prefs = await SharedPreferences.getInstance();
      final userJson = prefs.getString(_currentUserKey);
      if (userJson != null) {
        final userData = json.decode(userJson);
        return {
          'id': userData['_id'],
          'email': userData['email'],
          'name': '${userData['firstName']} ${userData['lastName']}',
          'isAdmin': userData['role'] == 'admin',
          'role': userData['role'],
          'firstName': userData['firstName'],
          'lastName': userData['lastName'],
          'learningStyle': userData['learningStyle'],
          'preferences': userData['preferences'],
          'createdAt': userData['createdAt'],
          'lastLogin': userData['lastLogin'],
          'isEmailVerified': userData['isEmailVerified'],
        };
      }
    } catch (e) {
      print('Get current user error: $e');
    }

    return null;
  }

  // ------------------ Local users (offline/testing) ------------------
  static Future<Map<String, dynamic>?> _getLocalUser(String email) async {
    final prefs = await SharedPreferences.getInstance();
    final jsonStr = prefs.getString(_localUsersKey);
    if (jsonStr == null) return null;
    try {
      final Map users = json.decode(jsonStr);
      final user = users[email.toLowerCase()];
      if (user == null) return null;
      return Map<String, dynamic>.from(user);
    } catch (e) {
      return null;
    }
  }

  static Future<void> _saveLocalUser(Map<String, dynamic> user) async {
    final prefs = await SharedPreferences.getInstance();
    final jsonStr = prefs.getString(_localUsersKey);
    Map users = {};
    if (jsonStr != null) {
      try {
        users = json.decode(jsonStr);
      } catch (e) {
        users = {};
      }
    }
    users[user['email'].toLowerCase()] = user;
    await prefs.setString(_localUsersKey, json.encode(users));
  }

  static Future<void> _ensureDefaultTestUser() async {
    final existing = await _getLocalUser('student@aitutor.com');
    if (existing == null) {
      await _saveLocalUser({
        '_id': 'local-student-1',
        'email': 'student@aitutor.com',
        'firstName': 'Student',
        'lastName': 'User',
        'role': 'student',
        'password': 'student123',
        'learningStyle': {'visual': 25, 'auditory': 25, 'reading': 25, 'kinesthetic': 25},
        'preferences': {},
        'isEmailVerified': true,
      });
    }
  }

  // Change password
  static Future<Map<String, dynamic>> changePassword({
    required String currentPassword,
    required String newPassword,
  }) async {
    try {
      final baseUrl = await getBaseUrl();
      final headers = await getHeaders();
      final response = await http.put(
        Uri.parse('$baseUrl/users/change-password'),
        headers: headers,
        body: json.encode({
          'currentPassword': currentPassword,
          'newPassword': newPassword,
        }),
      );

      final data = json.decode(response.body);
      return {
        'success': data['success'] ?? false,
        'message': data['message'] ?? 'Password change failed'
      };
    } catch (e) {
      return {'success': false, 'message': 'Network error: $e'};
    }
  }

  // Update user profile
  static Future<Map<String, dynamic>> updateProfile({
    String? firstName,
    String? lastName,
    String? bio,
    String? country,
    String? timezone,
  }) async {
    try {
      final baseUrl = await getBaseUrl();
      final headers = await getHeaders();
      final body = <String, dynamic>{};

      if (firstName != null) body['firstName'] = firstName;
      if (lastName != null) body['lastName'] = lastName;
      if (bio != null) body['bio'] = bio;
      if (country != null) body['country'] = country;
      if (timezone != null) body['timezone'] = timezone;

      final response = await http.put(
        Uri.parse('$baseUrl/users/profile'),
        headers: headers,
        body: json.encode(body),
      );

      final data = json.decode(response.body);

      if (data['success']) {
        // Update local storage
        final prefs = await SharedPreferences.getInstance();
        await prefs.setString(
            _currentUserKey, json.encode(data['data']['user']));
      }

      return {
        'success': data['success'] ?? false,
        'message': data['message'] ?? 'Profile update failed'
      };
    } catch (e) {
      return {'success': false, 'message': 'Network error: $e'};
    }
  }

  // Update learning style
  static Future<Map<String, dynamic>> updateLearningStyle({
    required Map<String, dynamic> learningStyle,
  }) async {
    try {
      final baseUrl = await getBaseUrl();
      final headers = await getHeaders();
      final response = await http.put(
        Uri.parse('$baseUrl/users/learning-style'),
        headers: headers,
        body: json.encode({
          'learningStyle': learningStyle,
        }),
      );

      final data = json.decode(response.body);

      if (data['success']) {
        // Update local storage
        final prefs = await SharedPreferences.getInstance();
        await prefs.setString(
            _currentUserKey, json.encode(data['data']['user']));
      }

      return {
        'success': data['success'] ?? false,
        'message': data['message'] ?? 'Learning style update failed'
      };
    } catch (e) {
      return {'success': false, 'message': 'Network error: $e'};
    }
  }

  // Delete account
  static Future<Map<String, dynamic>> deleteAccount() async {
    try {
      final baseUrl = await getBaseUrl();
      final headers = await getHeaders();
      final response = await http.delete(
        Uri.parse('$baseUrl/users/account'),
        headers: headers,
      );

      final data = json.decode(response.body);

      if (data['success']) {
        await clearTokens();
      }

      return {
        'success': data['success'] ?? false,
        'message': data['message'] ?? 'Account deletion failed'
      };
    } catch (e) {
      return {'success': false, 'message': 'Network error: $e'};
    }
  }

  // Health check
  static Future<Map<String, dynamic>> healthCheck() async {
    try {
      final baseUrl = await getBaseUrl();
      final response = await http
          .get(
            Uri.parse(baseUrl.replaceAll('/api', '/health')),
          )
          .timeout(const Duration(seconds: 5));

      final result = json.decode(response.body);
      result['connectedUrl'] = baseUrl;
      return result;
    } catch (e) {
      return {
        'status': 'ERROR',
        'message': 'Cannot connect to server: $e',
        'testedUrls': baseUrls,
      };
    }
  }

  // ============ ADMIN FUNCTIONS ============

  // Check if current user is admin
  static Future<bool> isAdmin() async {
    final currentUser = await getCurrentUser();
    return currentUser?['isAdmin'] == true;
  }

  // Get admin credentials (for display purposes)
  static Map<String, String> getAdminCredentials() {
    return {
      'email': 'admin@aitutor.com',
      'password': 'admin123',
      'name': 'AI-Tutor Administrator',
    };
  }

  // Get all users (Admin only)
  static Future<List<Map<String, dynamic>>> getAllUsers() async {
    try {
      final baseUrl = await getBaseUrl();
      final headers = await getHeaders();
      final response = await http.get(
        Uri.parse('$baseUrl/users'),
        headers: headers,
      );

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        if (data['success']) {
          return List<Map<String, dynamic>>.from(data['data']['users']);
        }
      }
      return [];
    } catch (e) {
      print('Get all users error: $e');
      return [];
    }
  }

  // Get user statistics (Admin only)
  static Future<Map<String, dynamic>> getUserStats() async {
    try {
      final baseUrl = await getBaseUrl();
      final headers = await getHeaders();
      final response = await http.get(
        Uri.parse('$baseUrl/users/stats'),
        headers: headers,
      );

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        if (data['success']) {
          return data['data']['stats'];
        }
      }

      return {
        'totalUsers': 0,
        'activeUsers': 0,
        'verifiedUsers': 0,
        'studentCount': 0,
        'teacherCount': 0,
        'adminCount': 0,
      };
    } catch (e) {
      print('Get user stats error: $e');
      return {
        'totalUsers': 0,
        'activeUsers': 0,
        'verifiedUsers': 0,
        'studentCount': 0,
        'teacherCount': 0,
        'adminCount': 0,
      };
    }
  }

  // Get total user count
  static Future<int> getTotalUserCount() async {
    final stats = await getUserStats();
    return stats['totalUsers'] ?? 0;
  }

  // Get user statistics (backward compatibility)
  static Future<Map<String, dynamic>> getUserStatistics() async {
    return await getUserStats();
  }

  // Get detailed user list (Admin only)
  static Future<List<Map<String, dynamic>>> getDetailedUserList() async {
    return await getAllUsers();
  }

  // Get active sessions (Admin only)
  static Future<List<Map<String, dynamic>>> getActiveSessions() async {
    try {
      final baseUrl = await getBaseUrl();
      final headers = await getHeaders();
      final response = await http.get(
        Uri.parse('$baseUrl/users/sessions'),
        headers: headers,
      );

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        if (data['success']) {
          return List<Map<String, dynamic>>.from(data['data']['sessions']);
        }
      }
      return [];
    } catch (e) {
      print('Get active sessions error: $e');
      return [];
    }
  }

  // Force logout user (Admin only)
  static Future<Map<String, dynamic>> forceLogoutUser(String userId) async {
    try {
      final baseUrl = await getBaseUrl();
      final headers = await getHeaders();
      final response = await http.post(
        Uri.parse('$baseUrl/users/$userId/force-logout'),
        headers: headers,
      );

      final data = json.decode(response.body);
      return {
        'success': data['success'] ?? false,
        'message': data['message'] ?? 'Force logout failed'
      };
    } catch (e) {
      return {'success': false, 'message': 'Network error: $e'};
    }
  }

  // Update user activity timestamp
  static Future<void> updateUserActivity() async {
    try {
      final baseUrl = await getBaseUrl();
      final headers = await getHeaders();
      await http.post(
        Uri.parse('$baseUrl/users/activity'),
        headers: headers,
      );
    } catch (e) {
      // Silently fail - this is not critical
      print('Update activity error: $e');
    }
  }

  // Clear all data (for testing)
  static Future<void> clearAllData() async {
    await clearTokens();
  }
}
