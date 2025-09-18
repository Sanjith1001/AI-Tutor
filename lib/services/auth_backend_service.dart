import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:crypto/crypto.dart';

class AuthBackendService {
  static const String _usersKey = 'registered_users';
  static const String _currentUserKey = 'current_user';
  static const String _isLoggedInKey = 'is_logged_in';

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

      // Save current user session
      await prefs.setString(_currentUserKey, jsonEncode({
        'id': user['id'],
        'email': user['email'],
        'name': user['name'],
      }));
      await prefs.setBool(_isLoggedInKey, true);

      return {
        'success': true,
        'message': 'Login successful!',
        'user': {
          'id': user['id'],
          'email': user['email'],
          'name': user['name'],
        }
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

  // Clear all data (for testing)
  static Future<void> clearAllData() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_usersKey);
    await prefs.remove(_currentUserKey);
    await prefs.setBool(_isLoggedInKey, false);
  }
}