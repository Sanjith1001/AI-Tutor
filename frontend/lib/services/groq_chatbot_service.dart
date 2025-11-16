import 'dart:convert';
import 'package:http/http.dart' as http;

class GroqChatbotService {
  static const String _baseUrl = 'http://localhost:5000'; // Groq server port

  /// Send a message to your Groq-powered chatbot
  static Future<GroqChatbotResponse> sendMessage(String message,
      [String? userId]) async {
    try {
      final response = await http
          .post(
            Uri.parse('$_baseUrl/chat'),
            headers: {
              'Content-Type': 'application/json',
              'Accept': 'application/json',
            },
            body: json.encode({
              'message': message,
              'user_id': userId ??
                  'flutter_user_${DateTime.now().millisecondsSinceEpoch}',
            }),
          )
          .timeout(const Duration(seconds: 30)); // Groq can take longer

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        if (data['success'] == true) {
          return GroqChatbotResponse(
            success: true,
            reply: data['reply'] ?? 'No response received',
            suggestions: List<String>.from(data['suggestions'] ?? []),
            timestamp: data['timestamp'],
            model: data['model'],
            userId: data['user_id'],
          );
        } else {
          return GroqChatbotResponse(
            success: false,
            reply: data['reply'] ?? 'Error occurred',
            error: data['error'],
            details: data['details'],
          );
        }
      } else {
        final errorData = json.decode(response.body);
        return GroqChatbotResponse(
          success: false,
          reply: 'Error: ${errorData['error'] ?? 'Unknown error'}',
          error: errorData['error'],
          details: errorData['details'],
        );
      }
    } catch (e) {
      print('Groq chatbot service error: $e');
      return GroqChatbotResponse(
        success: false,
        reply:
            'Sorry, I\'m having trouble connecting to the AI service. Please make sure the Groq server is running on port 5000.',
        error: e.toString(),
      );
    }
  }

  /// Check if the Groq server is available
  static Future<bool> checkServerStatus() async {
    try {
      final response = await http.get(
        Uri.parse('$_baseUrl/'),
        headers: {'Accept': 'application/json'},
      ).timeout(const Duration(seconds: 5));

      // Flask returns 404 for root path, but that means server is running
      return response.statusCode == 404 || response.statusCode == 200;
    } catch (e) {
      print('Groq server not available: $e');
      return false;
    }
  }

  /// Get server information
  static Future<Map<String, dynamic>> getServerInfo() async {
    final isAvailable = await checkServerStatus();
    return {
      'available': isAvailable,
      'url': _baseUrl,
      'model': 'llama-3.1-8b-instant',
      'provider': 'Groq',
      'status': isAvailable ? 'Online' : 'Offline',
    };
  }
}

/// Response model for Groq chatbot interactions
class GroqChatbotResponse {
  final bool success;
  final String reply;
  final List<String> suggestions;
  final String? error;
  final String? details;
  final String? timestamp;
  final String? model;
  final String? userId;

  GroqChatbotResponse({
    required this.success,
    required this.reply,
    this.suggestions = const [],
    this.error,
    this.details,
    this.timestamp,
    this.model,
    this.userId,
  });

  @override
  String toString() {
    return 'GroqChatbotResponse(success: $success, reply: $reply, suggestions: ${suggestions.length})';
  }
}
