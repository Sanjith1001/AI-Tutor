// Course Service
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:flutter_dotenv/flutter_dotenv.dart';

class AIService {
  static String get apiKey => dotenv.env['GROQ_API_KEY'] ?? '';
  static const String endpoint = "https://api.openai.com/v1/chat/completions";

  static Future<Map<String, dynamic>> generateCourseContent(
      String topic) async {
    final response = await http.post(
      Uri.parse(endpoint),
      headers: {
        "Authorization": "Bearer $apiKey",
        "Content-Type": "application/json",
      },
      body: jsonEncode({
        "model": "gpt-4o-mini", // or Groq model if you use Groq
        "messages": [
          {
            "role": "system",
            "content":
                "You are an expert course creator. Generate structured JSON."
          },
          {
            "role": "user",
            "content":
                "Generate 10 course modules for the topic '$topic'. Each module should have 2 lessons. "
                    "Return JSON strictly in this format:\n"
                    "{ \"modules\": [ {\"title\": \"...\", \"lessons\": [ {\"title\": \"...\", \"content\": \"...\"} ] } ] }"
          }
        ],
        "temperature": 0.7
      }),
    );

    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      final text = data["choices"][0]["message"]["content"];
      return jsonDecode(text); // this gives you modules + lessons
    } else {
      throw Exception("AI API failed: ${response.body}");
    }
  }
}
