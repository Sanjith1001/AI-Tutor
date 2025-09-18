class Course {
  final String title;
  final List<Module> modules;

  Course({required this.title, required this.modules});
}

class Module {
  final String title;
  final List<Lesson> lessons;

  Module({required this.title, required this.lessons});
}

class Lesson {
  final String title;
  final String content;

  Lesson({required this.title, required this.content});
}
