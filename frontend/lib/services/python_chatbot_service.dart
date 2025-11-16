import 'dart:convert';
import 'package:http/http.dart' as http;

class PythonChatbotService {
  static const String _baseUrl = 'http://localhost:5002'; // Simple chatbot port
  static const String _advancedUrl =
      'http://localhost:5001'; // Advanced chatbot port

  // Try advanced chatbot first, fallback to simple
  static bool _useAdvanced = true;

  /// Send a message to the Python chatbot
  static Future<ChatbotResponse> sendMessage(
      String message, String userId) async {
    try {
      // Try advanced chatbot first
      if (_useAdvanced) {
        try {
          final response = await _sendToAdvanced(message, userId);
          return response;
        } catch (e) {
          print('Advanced chatbot unavailable, falling back to simple chatbot');
          _useAdvanced = false;
        }
      }

      // Use simple chatbot
      return await _sendToSimple(message, userId);
    } catch (e) {
      print('Chatbot service error: $e');
      return ChatbotResponse(
        success: false,
        response:
            'Sorry, I\'m having trouble connecting right now. Please make sure the Python chatbot server is running.',
        suggestions: ['Try again later', 'Check server connection'],
        error: e.toString(),
      );
    }
  }

  /// Send message to advanced chatbot (Flask + OpenAI)
  static Future<ChatbotResponse> _sendToAdvanced(
      String message, String userId) async {
    final response = await http
        .post(
          Uri.parse('$_advancedUrl/chat'),
          headers: {
            'Content-Type': 'application/json',
            'Accept': 'application/json',
          },
          body: json.encode({
            'message': message,
            'user_id': userId,
          }),
        )
        .timeout(const Duration(seconds: 15));

    if (response.statusCode == 200) {
      final data = json.decode(response.body);
      if (data['success'] == true) {
        return ChatbotResponse(
          success: true,
          response: data['data']['response'] ?? 'No response received',
          suggestions: List<String>.from(data['data']['suggestions'] ?? []),
          sentiment: data['data']['sentiment'],
          intent: data['data']['intent'],
          timestamp: data['data']['timestamp'],
          isAdvanced: true,
        );
      } else {
        throw Exception(data['error'] ?? 'Unknown error from advanced chatbot');
      }
    } else {
      throw Exception('Advanced chatbot server error: ${response.statusCode}');
    }
  }

  /// Send message to simple chatbot (Pure Python)
  static Future<ChatbotResponse> _sendToSimple(
      String message, String userId) async {
    final response = await http
        .post(
          Uri.parse('$_baseUrl/chat'),
          headers: {
            'Content-Type': 'application/json',
            'Accept': 'application/json',
          },
          body: json.encode({
            'message': message,
            'user_id': userId,
          }),
        )
        .timeout(const Duration(seconds: 10));

    if (response.statusCode == 200) {
      final data = json.decode(response.body);
      if (data['success'] == true) {
        return ChatbotResponse(
          success: true,
          response: data['data']['response'] ?? 'No response received',
          suggestions: List<String>.from(data['data']['suggestions'] ?? []),
          pattern: data['data']['pattern'],
          timestamp: data['data']['timestamp'],
          isAdvanced: false,
        );
      } else {
        throw Exception(data['error'] ?? 'Unknown error from simple chatbot');
      }
    } else {
      throw Exception('Simple chatbot server error: ${response.statusCode}');
    }
  }

  /// Get chat history for a user
  static Future<List<Map<String, dynamic>>> getChatHistory(
      String userId) async {
    try {
      final url = _useAdvanced
          ? '$_advancedUrl/chat/history/$userId'
          : '$_baseUrl/history/$userId';

      final response = await http.get(
        Uri.parse(url),
        headers: {'Accept': 'application/json'},
      ).timeout(const Duration(seconds: 5));

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        if (data['success'] == true) {
          return List<Map<String, dynamic>>.from(data['data']['history'] ?? []);
        }
      }
    } catch (e) {
      print('Error getting chat history: $e');
    }

    return [];
  }

  /// Clear chat history for a user (advanced chatbot only)
  static Future<bool> clearChatHistory(String userId) async {
    if (!_useAdvanced) return false;

    try {
      final response = await http.delete(
        Uri.parse('$_advancedUrl/chat/clear/$userId'),
        headers: {'Accept': 'application/json'},
      ).timeout(const Duration(seconds: 5));

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        return data['success'] == true;
      }
    } catch (e) {
      print('Error clearing chat history: $e');
    }

    return false;
  }

  /// Check if chatbot servers are available
  static Future<ServerStatus> checkServerStatus() async {
    bool simpleAvailable = false;
    bool advancedAvailable = false;

    // Check simple chatbot
    try {
      final response = await http.get(
        Uri.parse('$_baseUrl/health'),
        headers: {'Accept': 'application/json'},
      ).timeout(const Duration(seconds: 3));

      simpleAvailable = response.statusCode == 200;
    } catch (e) {
      print('Simple chatbot not available: $e');
    }

    // Check advanced chatbot
    try {
      final response = await http.get(
        Uri.parse('$_advancedUrl/health'),
        headers: {'Accept': 'application/json'},
      ).timeout(const Duration(seconds: 3));

      advancedAvailable = response.statusCode == 200;
    } catch (e) {
      print('Advanced chatbot not available: $e');
    }

    _useAdvanced = advancedAvailable;

    return ServerStatus(
      simpleAvailable: simpleAvailable,
      advancedAvailable: advancedAvailable,
      currentMode: _useAdvanced ? 'Advanced' : 'Simple',
    );
  }

  /// Get available learning topics (advanced chatbot only)
  static Future<List<String>> getLearningTopics() async {
    if (!_useAdvanced) {
      return [
        'Mathematics',
        'Science',
        'Programming',
        'History',
        'Literature',
        'Art',
        'Music',
        'Languages'
      ];
    }

    try {
      final response = await http.get(
        Uri.parse('$_advancedUrl/chat/topics'),
        headers: {'Accept': 'application/json'},
      ).timeout(const Duration(seconds: 5));

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        if (data['success'] == true) {
          return List<String>.from(data['data']['topics'] ?? []);
        }
      }
    } catch (e) {
      print('Error getting learning topics: $e');
    }

    return ['Mathematics', 'Science', 'Programming', 'History'];
  }
}

/// Response model for chatbot interactions
class ChatbotResponse {
  final bool success;
  final String response;
  final List<String> suggestions;
  final String? error;
  final Map<String, dynamic>? sentiment;
  final String? intent;
  final String? pattern;
  final String? timestamp;
  final bool isAdvanced;

  ChatbotResponse({
    required this.success,
    required this.response,
    this.suggestions = const [],
    this.error,
    this.sentiment,
    this.intent,
    this.pattern,
    this.timestamp,
    this.isAdvanced = false,
  });

  @override
  String toString() {
    return 'ChatbotResponse(success: $success, response: $response, isAdvanced: $isAdvanced)';
  }
}

/// Server status model
class ServerStatus {
  final bool simpleAvailable;
  final bool advancedAvailable;
  final String currentMode;

  ServerStatus({
    required this.simpleAvailable,
    required this.advancedAvailable,
    required this.currentMode,
  });

  bool get anyAvailable => simpleAvailable || advancedAvailable;

  String get statusMessage {
    if (advancedAvailable) {
      return 'AI Assistant (Advanced Mode) - Ready to help!';
    } else if (simpleAvailable) {
      return 'AI Assistant (Simple Mode) - Ready to help!';
    } else {
      return 'AI Assistant - Offline';
    }
  }
}
