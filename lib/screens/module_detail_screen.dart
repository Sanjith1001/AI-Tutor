import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:flutter_dotenv/flutter_dotenv.dart';
import '../models/course_model.dart';

class ModuleDetailScreen extends StatefulWidget {
  final String courseTitle;
  final Module module;
  final String? learningStyle;

  const ModuleDetailScreen({
    super.key,
    required this.courseTitle,
    required this.module,
    this.learningStyle,
  });

  @override
  State<ModuleDetailScreen> createState() => _ModuleDetailScreenState();
}

class _ModuleDetailScreenState extends State<ModuleDetailScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;

  final Map<String, Future<String>> _cache = {}; // Cache AI results

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 5, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF10141A),
      appBar: AppBar(
        title: Text(widget.module.title,
            style: const TextStyle(color: Colors.white)),
        backgroundColor: const Color(0xFF10141A),
        iconTheme:
            const IconThemeData(color: Colors.white), // Make back button white
        bottom: TabBar(
          controller: _tabController,
          labelColor: Colors.white,
          unselectedLabelColor: Colors.grey,
          tabs: const [
            Tab(text: "Content"),
            Tab(text: "Simplify"),
            Tab(text: "Quiz"),
            Tab(text: "Example"),
            Tab(text: "Videos"),
          ],
        ),
      ),
      body: TabBarView(
        controller: _tabController,
        children: [
          _buildAITab("Explain {title} in detail with examples."),
          _buildAITab("Simplify {title} into 3 bullet points for beginners."),
          _buildAITab(
              "Generate 5 multiple-choice questions with answers for {title}."),
          _buildAITab(
              "Provide 2 Python code examples for {title} with explanation."),
          _buildVideosTab(),
        ],
      ),
    );
  }

  Widget _buildAITab(String promptTemplate) {
    return Column(
      children: [
        // Learning style header if available
        if (widget.learningStyle != null)
          Container(
            width: double.infinity,
            margin: const EdgeInsets.all(16),
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.blue.shade900,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: Colors.blue.shade700),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Icon(Icons.psychology,
                        color: Colors.blue.shade300, size: 20),
                    const SizedBox(width: 8),
                    Text(
                      '${widget.learningStyle} Learning Style',
                      style: TextStyle(
                        color: Colors.blue.shade300,
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                Text(
                  _getLearningStyleTips(widget.learningStyle!),
                  style: const TextStyle(
                    color: Colors.white70,
                    fontSize: 14,
                  ),
                ),
              ],
            ),
          ),

        // Content
        Expanded(
          child: ListView.builder(
            padding: const EdgeInsets.all(16),
            itemCount: widget.module.lessons.length,
            itemBuilder: (context, index) {
              final lesson = widget.module.lessons[index];
              String prompt =
                  promptTemplate.replaceAll("{title}", lesson.title);

              // Enhance prompt with learning style if available
              if (widget.learningStyle != null) {
                prompt +=
                    _getLearningStylePromptAddition(widget.learningStyle!);
              }

              final future =
                  _cache.putIfAbsent(prompt, () => _fetchAIResponse(prompt));

              return FutureBuilder<String>(
                future: future,
                builder: (context, snapshot) {
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return const Padding(
                      padding: EdgeInsets.all(16.0),
                      child: Center(child: CircularProgressIndicator()),
                    );
                  }

                  if (snapshot.hasError) {
                    return Padding(
                      padding: const EdgeInsets.all(16.0),
                      child: Text(
                        "⚠️ Error: ${snapshot.error}",
                        style: const TextStyle(color: Colors.redAccent),
                      ),
                    );
                  }

                  return ExpansionTile(
                    title: Text(
                      lesson.title,
                      style: const TextStyle(color: Colors.white),
                    ),
                    children: [
                      Padding(
                        padding: const EdgeInsets.all(12.0),
                        child: SelectableText(
                          snapshot.data ?? "⚠️ No AI response generated.",
                          style: const TextStyle(
                              color: Colors.white70, height: 1.4),
                        ),
                      ),
                    ],
                  );
                },
              );
            },
          ),
        ),
      ],
    );
  }

  String _getLearningStyleTips(String style) {
    switch (style) {
      case 'Visual':
        return 'Focus on diagrams, charts, and visual representations. Look for patterns and use colors to organize information.';
      case 'Auditory':
        return 'Read content aloud, discuss concepts, and listen to explanations. Use verbal repetition to reinforce learning.';
      case 'Reading/Writing':
        return 'Take detailed notes, create summaries, and rewrite key concepts. Use lists and written exercises.';
      case 'Kinesthetic':
        return 'Apply concepts practically, use hands-on examples, and take breaks to move around while studying.';
      default:
        return 'Use a combination of different learning approaches to maximize understanding.';
    }
  }

  String _getLearningStylePromptAddition(String style) {
    switch (style) {
      case 'Visual':
        return ' Include visual descriptions, suggest diagrams, and use formatting that helps visual learners.';
      case 'Auditory':
        return ' Structure the explanation for reading aloud and include discussion points.';
      case 'Reading/Writing':
        return ' Provide detailed written explanations with clear structure and key points.';
      case 'Kinesthetic':
        return ' Include practical examples and hands-on activities where possible.';
      default:
        return '';
    }
  }

  Widget _buildVideosTab() {
    // Placeholder: Replace with your video widget or logic
    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: widget.module.lessons.length,
      itemBuilder: (context, index) {
        final lesson = widget.module.lessons[index];
        return Card(
          color: Colors.black12,
          child: ListTile(
            leading: const Icon(Icons.play_circle_fill,
                color: Colors.blue, size: 32),
            title: Text(
              'Video for: ' + lesson.title,
              style: const TextStyle(color: Colors.white),
            ),
            subtitle: const Text('Video content coming soon!',
                style: TextStyle(color: Colors.white70)),
          ),
        );
      },
    );
  }

  Future<String> _fetchAIResponse(String prompt) async {
    try {
      final response = await http.post(
        Uri.parse("https://api.groq.com/openai/v1/chat/completions"),
        headers: {
          "Content-Type": "application/json",
          "Authorization":
              "Bearer ${dotenv.env['GROQ_API_KEY']}", // ✅ Use real API key from env
        },
        body: jsonEncode({
          "model": "llama3-70b-8192",
          "messages": [
            {
              "role": "system",
              "content": "You are a helpful tutor that explains topics clearly."
            },
            {"role": "user", "content": prompt}
          ],
          "temperature": 0.7,
        }),
      );

      debugPrint("🔵 STATUS: \\${response.statusCode}");
      debugPrint("🔵 RESPONSE: \\${response.body}");

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        final String? content = data["choices"]?[0]?["message"]?["content"];
        if (content == null || content.trim().isEmpty) {
          throw Exception("AI returned empty content.");
        }
        return content.trim();
      } else {
        throw Exception(
            "Groq API Error: \\${response.statusCode} → \\${response.body}");
      }
    } catch (e) {
      debugPrint("🔥 AI generation failed: $e");
      rethrow;
    }
  }
}
