// Lesson Screen
import 'package:flutter/material.dart';
import '../models/course_model.dart';

class LessonScreen extends StatelessWidget {
  final Module module;

  const LessonScreen({super.key, required this.module});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text(module.title)),
      body: ListView.builder(
        itemCount: module.lessons.length,
        itemBuilder: (context, index) {
          final lesson = module.lessons[index];
          return ExpansionTile(
            title: Text(lesson.title),
            children: [
              Padding(
                padding: const EdgeInsets.all(12.0),
                child: Text(lesson.content),
              ),
            ],
          );
        },
      ),
    );
  }
}
