// services/groq_service.dart

import 'dart:convert';
import 'package:http/http.dart' as http;

class GroqService {
  final String apiKey = "YOUR_API_KEY_HERE";  // replace this with your actual key
  final String endpoint = "https://api.groq.com/openai/v1/chat/completions";

  Future<Map<String, dynamic>> generateCourse(String topic) async {
    final response = await http.post(
      Uri.parse(endpoint),
      headers: {
        "Content-Type": "application/json",
        "Authorization": "Bearer $apiKey",
      },
      body: jsonEncode({
        "model": "llama-3.3-70b-versatile",  // changed model to a supported one
        "messages": [
          {
            "role": "system",
            "content": "You are an expert educational content creator and AI tutor that generates comprehensive, structured course outlines. You create engaging, practical, and well-organized learning materials."
          },
          {
            "role": "user",
            "content": """
Generate a comprehensive course outline on the topic: "$topic"

Requirements:
- Create 6-10 modules that progressively build knowledge
- Each module should have a clear, descriptive title
- Each module description should be detailed (2-3 sentences) explaining what students will learn
- Make the content practical and engaging
- Include real-world applications where relevant
- Ensure logical progression from basic to advanced concepts

The response must ONLY be valid JSON in this exact format:

{
  "courseTitle": "Complete Course Title Here",
  "modules": [
    {
      "title": "Module Title",
      "description": "Detailed description of what students will learn in this module, including key concepts and practical applications. This should be informative and engaging."
    }
  ]
}

Generate the course now:
"""
          }
        ],
        "temperature": 0.7,
        "max_tokens": 2000,
      }),
    );

    if (response.statusCode == 200) {
      final decoded = jsonDecode(response.body);
      final content = decoded["choices"][0]["message"]["content"];

      try {
        // Clean the content to extract JSON
        String cleanContent = content.trim();
        
        // Find JSON start and end
        int jsonStart = cleanContent.indexOf('{');
        int jsonEnd = cleanContent.lastIndexOf('}') + 1;
        
        if (jsonStart != -1 && jsonEnd > jsonStart) {
          cleanContent = cleanContent.substring(jsonStart, jsonEnd);
        }
        
        return jsonDecode(cleanContent);
      } catch (e) {
        throw Exception("Invalid JSON format from Groq. Raw content: $content");
      }
    } else {
      throw Exception("Failed to fetch from Groq: ${response.statusCode} - ${response.body}");
    }
  }

  Future<Map<String, dynamic>> generateDetailedContent(String prompt, {String? difficulty, String? audience}) async {
    String enhancedPrompt = prompt;
    
    if (difficulty != null) {
      enhancedPrompt += "\n\nDifficulty Level: $difficulty";
    }
    
    if (audience != null) {
      enhancedPrompt += "\nTarget Audience: $audience";
    }

    final response = await http.post(
      Uri.parse(endpoint),
      headers: {
        "Content-Type": "application/json",
        "Authorization": "Bearer $apiKey",
      },
      body: jsonEncode({
        "model": "llama-3.3-70b-versatile",
        "messages": [
          {
            "role": "system",
            "content": "You are an expert educational content creator specializing in creating comprehensive, engaging learning materials. You understand different learning styles and can adapt content for various audiences and skill levels."
          },
          {
            "role": "user",
            "content": """
Based on this detailed prompt: "$enhancedPrompt"

Create a comprehensive course with the following specifications:
- Generate 8-12 modules that cover the topic thoroughly
- Each module should have a compelling title and detailed description
- Include practical examples, real-world applications, and hands-on elements
- Ensure content is appropriate for the specified difficulty level and audience
- Make the learning progression logical and engaging

Return ONLY valid JSON in this format:

{
  "courseTitle": "Comprehensive Course Title",
  "modules": [
    {
      "title": "Module Title",
      "description": "Comprehensive description including learning objectives, key concepts, practical applications, and what students will be able to do after completing this module."
    }
  ]
}
"""
          }
        ],
        "temperature": 0.8,
        "max_tokens": 3000,
      }),
    );

    if (response.statusCode == 200) {
      final decoded = jsonDecode(response.body);
      final content = decoded["choices"][0]["message"]["content"];

      try {
        // Clean the content to extract JSON
        String cleanContent = content.trim();
        
        // Find JSON start and end
        int jsonStart = cleanContent.indexOf('{');
        int jsonEnd = cleanContent.lastIndexOf('}') + 1;
        
        if (jsonStart != -1 && jsonEnd > jsonStart) {
          cleanContent = cleanContent.substring(jsonStart, jsonEnd);
        }
        
        return jsonDecode(cleanContent);
      } catch (e) {
        throw Exception("Invalid JSON format from Groq. Raw content: $content");
      }
    } else {
      throw Exception("Failed to fetch from Groq: ${response.statusCode} - ${response.body}");
    }
  }

  Future<String> generateTextContent(String prompt) async {
    print('🔵 GroqService: Making API call...');
    print('🔵 Prompt: ${prompt.substring(0, prompt.length > 100 ? 100 : prompt.length)}...');
    
    final response = await http.post(
      Uri.parse(endpoint),
      headers: {
        "Content-Type": "application/json",
        "Authorization": "Bearer $apiKey",
      },
      body: jsonEncode({
        "model": "llama-3.3-70b-versatile",
        "messages": [
          {
            "role": "system",
            "content": "You are an expert educational content creator. Provide clear, comprehensive, and engaging educational content."
          },
          {
            "role": "user",
            "content": prompt
          }
        ],
        "temperature": 0.7,
        "max_tokens": 2000,
      }),
    );

    print('🔵 Response status: ${response.statusCode}');
    
    if (response.statusCode == 200) {
      final decoded = jsonDecode(response.body);
      final content = decoded["choices"][0]["message"]["content"];
      print('🔵 Content generated successfully: ${content?.substring(0, content.length > 100 ? 100 : content.length)}...');
      return content?.trim() ?? "No content generated.";
    } else {
      print('🔴 API Error: ${response.statusCode} - ${response.body}');
      throw Exception("Failed to fetch from Groq: ${response.statusCode} - ${response.body}");
    }
  }
}
