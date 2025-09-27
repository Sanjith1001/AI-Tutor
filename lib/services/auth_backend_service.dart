import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:crypto/crypto.dart';

class AuthBackendService {
  static const String _usersKey = 'registered_users';
  static const String _currentUserKey = 'current_user';
  static const String _isLoggedInKey = 'is_logged_in';
  static const String _activeSessionsKey = 'active_sessions';
  
  // Admin credentials
  static const String _adminEmail = 'admin@bytebrain.com';
  static const String _adminPassword = 'admin123';
  static const String _adminName = 'ByteBrain Administrator';

  // Register a new user
  static Future<Map<String, dynamic>> registerUser({
    required String email,
    required String password,
    required String name,
  }) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      
      // Validate email format
      if (!_isValidEmail(email)) {
        return {
          'success': false,
          'message': 'Please enter a valid email address'
        };
      }

      // Validate password strength
      if (password.length < 6) {
        return {
          'success': false,
          'message': 'Password must be at least 6 characters long'
        };
      }

      // Get existing users
      final existingUsers = await _getUsers();
      
      // Check if user already exists
      if (existingUsers.any((user) => user['email'] == email.toLowerCase())) {
        return {
          'success': false,
          'message': 'An account with this email already exists'
        };
      }

      // Hash the password
      final hashedPassword = _hashPassword(password);
      
      // Create new user
      final newUser = {
        'id': DateTime.now().millisecondsSinceEpoch.toString(),
        'email': email.toLowerCase(),
        'password': hashedPassword,
        'name': name,
        'createdAt': DateTime.now().toIso8601String(),
      };

      // Add to users list
      existingUsers.add(newUser);
      
      // Save users
      await _saveUsers(existingUsers);

      return {
        'success': true,
        'message': 'Account created successfully!',
        'user': {
          'id': newUser['id'],
          'email': newUser['email'],
          'name': newUser['name'],
        }
      };
    } catch (e) {
      return {
        'success': false,
        'message': 'Registration failed. Please try again.'
      };
    }
  }

  // Login user
  static Future<Map<String, dynamic>> loginUser({
    required String email,
    required String password,
  }) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      
      // Check if it's admin login
      if (email.toLowerCase() == _adminEmail && password == _adminPassword) {
        final adminUser = {
          'id': 'admin_001',
          'email': _adminEmail,
          'name': _adminName,
          'isAdmin': true,
        };
        
        // Save admin session
        await prefs.setString(_currentUserKey, jsonEncode(adminUser));
        await prefs.setBool(_isLoggedInKey, true);
        
        return {
          'success': true,
          'message': 'Admin login successful!',
          'user': adminUser,
          'isAdmin': true,
        };
      }
      
      // Get existing users
      final users = await _getUsers();
      
      // Find user by email
      final user = users.firstWhere(
        (user) => user['email'] == email.toLowerCase(),
        orElse: () => {},
      );

      if (user.isEmpty) {
        return {
          'success': false,
          'message': 'No account found with this email address'
        };
      }

      // Verify password
      final hashedPassword = _hashPassword(password);
      if (user['password'] != hashedPassword) {
        return {
          'success': false,
          'message': 'Incorrect password'
        };
      }

      // Create user session data
      final userSession = {
        'id': user['id'],
        'email': user['email'],
        'name': user['name'],
        'isAdmin': false,
      };

      // Save current user session
      await prefs.setString(_currentUserKey, jsonEncode(userSession));
      await prefs.setBool(_isLoggedInKey, true);
      
      // Add to active sessions
      await _addActiveSession(userSession);

      return {
        'success': true,
        'message': 'Login successful!',
        'user': userSession,
        'isAdmin': false,
      };
    } catch (e) {
      return {
        'success': false,
        'message': 'Login failed. Please try again.'
      };
    }
  }

  // Logout user
  static Future<void> logoutUser() async {
    final prefs = await SharedPreferences.getInstance();
    
    // Get current user before logout
    final currentUser = await getCurrentUser();
    
    // Remove from active sessions if not admin
    if (currentUser != null && currentUser['isAdmin'] != true) {
      await _removeActiveSession(currentUser['id']);
    }
    
    await prefs.remove(_currentUserKey);
    await prefs.setBool(_isLoggedInKey, false);
  }

  // Check if user is logged in
  static Future<bool> isLoggedIn() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getBool(_isLoggedInKey) ?? false;
  }

  // Get current user
  static Future<Map<String, dynamic>?> getCurrentUser() async {
    final prefs = await SharedPreferences.getInstance();
    final userJson = prefs.getString(_currentUserKey);
    if (userJson != null) {
      return jsonDecode(userJson);
    }
    return null;
  }

  // Change password
  static Future<Map<String, dynamic>> changePassword({
    required String currentPassword,
    required String newPassword,
  }) async {
    try {
      final currentUser = await getCurrentUser();
      if (currentUser == null) {
        return {
          'success': false,
          'message': 'Please login first'
        };
      }

      final users = await _getUsers();
      final userIndex = users.indexWhere((user) => user['id'] == currentUser['id']);
      
      if (userIndex == -1) {
        return {
          'success': false,
          'message': 'User not found'
        };
      }

      // Verify current password
      final hashedCurrentPassword = _hashPassword(currentPassword);
      if (users[userIndex]['password'] != hashedCurrentPassword) {
        return {
          'success': false,
          'message': 'Current password is incorrect'
        };
      }

      // Validate new password
      if (newPassword.length < 6) {
        return {
          'success': false,
          'message': 'New password must be at least 6 characters long'
        };
      }

      // Update password
      users[userIndex]['password'] = _hashPassword(newPassword);
      await _saveUsers(users);

      return {
        'success': true,
        'message': 'Password changed successfully!'
      };
    } catch (e) {
      return {
        'success': false,
        'message': 'Failed to change password. Please try again.'
      };
    }
  }

  // Delete account
  static Future<Map<String, dynamic>> deleteAccount() async {
    try {
      final currentUser = await getCurrentUser();
      if (currentUser == null) {
        return {
          'success': false,
          'message': 'Please login first'
        };
      }

      final users = await _getUsers();
      users.removeWhere((user) => user['id'] == currentUser['id']);
      await _saveUsers(users);
      await logoutUser();

      return {
        'success': true,
        'message': 'Account deleted successfully'
      };
    } catch (e) {
      return {
        'success': false,
        'message': 'Failed to delete account. Please try again.'
      };
    }
  }

  // Private helper methods
  static Future<List<Map<String, dynamic>>> _getUsers() async {
    final prefs = await SharedPreferences.getInstance();
    final usersJson = prefs.getStringList(_usersKey) ?? [];
    return usersJson.map((json) => jsonDecode(json) as Map<String, dynamic>).toList();
  }

  static Future<void> _saveUsers(List<Map<String, dynamic>> users) async {
    final prefs = await SharedPreferences.getInstance();
    final usersJson = users.map((user) => jsonEncode(user)).toList();
    await prefs.setStringList(_usersKey, usersJson);
  }

  static String _hashPassword(String password) {
    final bytes = utf8.encode(password + 'bytebrain_salt'); // Add salt for security
    final digest = sha256.convert(bytes);
    return digest.toString();
  }

  static bool _isValidEmail(String email) {
    return RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$').hasMatch(email);
  }

  // Get all users (for admin purposes - remove in production)
  static Future<List<Map<String, dynamic>>> getAllUsers() async {
    return await _getUsers();
  }

  // Get total user count
  static Future<int> getTotalUserCount() async {
    final users = await _getUsers();
    return users.length;
  }

  // Get user registration statistics
  static Future<Map<String, dynamic>> getUserStats() async {
    final users = await _getUsers();
    
    if (users.isEmpty) {
      return {
        'totalUsers': 0,
        'todayRegistrations': 0,
        'thisWeekRegistrations': 0,
        'thisMonthRegistrations': 0,
      };
    }

    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final weekAgo = today.subtract(const Duration(days: 7));
    final monthAgo = DateTime(now.year, now.month - 1, now.day);

    int todayCount = 0;
    int weekCount = 0;
    int monthCount = 0;

    for (final user in users) {
      final createdAt = DateTime.parse(user['createdAt']);
      final createdDate = DateTime(createdAt.year, createdAt.month, createdAt.day);
      
      if (createdDate.isAtSameMomentAs(today)) {
        todayCount++;
      }
      if (createdDate.isAfter(weekAgo) || createdDate.isAtSameMomentAs(weekAgo)) {
        weekCount++;
      }
      if (createdDate.isAfter(monthAgo) || createdDate.isAtSameMomentAs(monthAgo)) {
        monthCount++;
      }
    }

    return {
      'totalUsers': users.length,
      'todayRegistrations': todayCount,
      'thisWeekRegistrations': weekCount,
      'thisMonthRegistrations': monthCount,
      'users': users.map((user) => {
        'name': user['name'],
        'email': user['email'],
        'createdAt': user['createdAt'],
      }).toList(),
    };
  }

  // Clear all data (for testing)
  static Future<void> clearAllData() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_usersKey);
    await prefs.remove(_currentUserKey);
    await prefs.remove(_activeSessionsKey);
    await prefs.setBool(_isLoggedInKey, false);
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
      'email': _adminEmail,
      'password': _adminPassword,
      'name': _adminName,
    };
  }

  // Add user to active sessions
  static Future<void> _addActiveSession(Map<String, dynamic> user) async {
    final prefs = await SharedPreferences.getInstance();
    final activeSessionsJson = prefs.getStringList(_activeSessionsKey) ?? [];
    
    final activeSessions = activeSessionsJson
        .map((json) => jsonDecode(json) as Map<String, dynamic>)
        .toList();
    
    // Remove existing session for this user (if any)
    activeSessions.removeWhere((session) => session['id'] == user['id']);
    
    // Add new session with timestamp
    final sessionData = {
      ...user,
      'loginTime': DateTime.now().toIso8601String(),
      'lastActivity': DateTime.now().toIso8601String(),
    };
    
    activeSessions.add(sessionData);
    
    // Save back to preferences
    final updatedJson = activeSessions.map((session) => jsonEncode(session)).toList();
    await prefs.setStringList(_activeSessionsKey, updatedJson);
  }

  // Remove user from active sessions
  static Future<void> _removeActiveSession(String userId) async {
    final prefs = await SharedPreferences.getInstance();
    final activeSessionsJson = prefs.getStringList(_activeSessionsKey) ?? [];
    
    final activeSessions = activeSessionsJson
        .map((json) => jsonDecode(json) as Map<String, dynamic>)
        .toList();
    
    // Remove session for this user
    activeSessions.removeWhere((session) => session['id'] == userId);
    
    // Save back to preferences
    final updatedJson = activeSessions.map((session) => jsonEncode(session)).toList();
    await prefs.setStringList(_activeSessionsKey, updatedJson);
  }

  // Get all active sessions (Admin only)
  static Future<List<Map<String, dynamic>>> getActiveSessions() async {
    if (!await isAdmin()) {
      throw Exception('Access denied. Admin privileges required.');
    }
    
    final prefs = await SharedPreferences.getInstance();
    final activeSessionsJson = prefs.getStringList(_activeSessionsKey) ?? [];
    
    final activeSessions = activeSessionsJson
        .map((json) => jsonDecode(json) as Map<String, dynamic>)
        .toList();
    
    // Clean up old sessions (older than 24 hours)
    final now = DateTime.now();
    final validSessions = activeSessions.where((session) {
      final lastActivity = DateTime.parse(session['lastActivity']);
      final hoursSinceActivity = now.difference(lastActivity).inHours;
      return hoursSinceActivity < 24; // Consider session active if activity within 24 hours
    }).toList();
    
    // Save cleaned sessions back
    final updatedJson = validSessions.map((session) => jsonEncode(session)).toList();
    await prefs.setStringList(_activeSessionsKey, updatedJson);
    
    return validSessions;
  }

  // Get user statistics (Admin only)
  static Future<Map<String, dynamic>> getUserStatistics() async {
    if (!await isAdmin()) {
      throw Exception('Access denied. Admin privileges required.');
    }
    
    final allUsers = await _getUsers();
    final activeSessions = await getActiveSessions();
    
    // Calculate registration trends (last 30 days)
    final now = DateTime.now();
    final thirtyDaysAgo = now.subtract(const Duration(days: 30));
    
    final recentRegistrations = allUsers.where((user) {
      final createdAt = DateTime.parse(user['createdAt']);
      return createdAt.isAfter(thirtyDaysAgo);
    }).length;
    
    return {
      'totalUsers': allUsers.length,
      'activeUsers': activeSessions.length,
      'recentRegistrations': recentRegistrations,
      'registrationRate': recentRegistrations / 30, // per day
      'activeSessions': activeSessions,
    };
  }

  // Get detailed user list (Admin only)
  static Future<List<Map<String, dynamic>>> getDetailedUserList() async {
    if (!await isAdmin()) {
      throw Exception('Access denied. Admin privileges required.');
    }
    
    final allUsers = await _getUsers();
    final activeSessions = await getActiveSessions();
    
    // Enhance user data with session info
    return allUsers.map((user) {
      final activeSession = activeSessions.firstWhere(
        (session) => session['id'] == user['id'],
        orElse: () => {},
      );
      
      return {
        'id': user['id'],
        'name': user['name'],
        'email': user['email'],
        'createdAt': user['createdAt'],
        'isActive': activeSession.isNotEmpty,
        'lastActivity': activeSession['lastActivity'] ?? 'Never',
        'loginTime': activeSession['loginTime'] ?? 'Not logged in',
      };
    }).toList();
  }

  // Force logout user (Admin only)
  static Future<Map<String, dynamic>> forceLogoutUser(String userId) async {
    if (!await isAdmin()) {
      return {
        'success': false,
        'message': 'Access denied. Admin privileges required.'
      };
    }
    
    try {
      await _removeActiveSession(userId);
      return {
        'success': true,
        'message': 'User logged out successfully'
      };
    } catch (e) {
      return {
        'success': false,
        'message': 'Failed to logout user'
      };
    }
  }

  // Update user activity timestamp
  static Future<void> updateUserActivity() async {
    final currentUser = await getCurrentUser();
    if (currentUser != null && currentUser['isAdmin'] != true) {
      final prefs = await SharedPreferences.getInstance();
      final activeSessionsJson = prefs.getStringList(_activeSessionsKey) ?? [];
      
      final activeSessions = activeSessionsJson
          .map((json) => jsonDecode(json) as Map<String, dynamic>)
          .toList();
      
      // Find and update user's session
      for (int i = 0; i < activeSessions.length; i++) {
        if (activeSessions[i]['id'] == currentUser['id']) {
          activeSessions[i]['lastActivity'] = DateTime.now().toIso8601String();
          break;
        }
      }
      
      // Save back to preferences
      final updatedJson = activeSessions.map((session) => jsonEncode(session)).toList();
      await prefs.setStringList(_activeSessionsKey, updatedJson);
    }
  }
}