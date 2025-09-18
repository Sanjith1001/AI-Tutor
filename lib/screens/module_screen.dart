import 'package:flutter/material.dart';
import '../models/course_model.dart';
import 'lesson_screen.dart';

class ModuleScreen extends StatelessWidget {
  final Course course;

  const ModuleScreen({super.key, required this.course});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text(course.title)),
      body: ListView.builder(
        itemCount: course.modules.length,
        itemBuilder: (context, index) {
          final module = course.modules[index];
          return ListTile(
            title: Text(module.title),
            trailing: ElevatedButton(
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (_) => LessonScreen(module: module),
                  ),
                );
              },
              child: const Text("Start Module"),
            ),
          );
        },
      ),
    );
  }
}
