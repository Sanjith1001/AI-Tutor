// VARK Learning Style Model
class VARKResult {
  final int visual;
  final int auditory;
  final int readingWriting;
  final int kinesthetic;
  final String dominantStyle;
  final DateTime completedAt;

  VARKResult({
    required this.visual,
    required this.auditory,
    required this.readingWriting,
    required this.kinesthetic,
    required this.dominantStyle,
    required this.completedAt,
  });

  Map<String, dynamic> toJson() {
    return {
      'visual': visual,
      'auditory': auditory,
      'readingWriting': readingWriting,
      'kinesthetic': kinesthetic,
      'dominantStyle': dominantStyle,
      'completedAt': completedAt.toIso8601String(),
    };
  }

  factory VARKResult.fromJson(Map<String, dynamic> json) {
    return VARKResult(
      visual: json['visual'],
      auditory: json['auditory'],
      readingWriting: json['readingWriting'],
      kinesthetic: json['kinesthetic'],
      dominantStyle: json['dominantStyle'],
      completedAt: DateTime.parse(json['completedAt']),
    );
  }
}

class VARKQuestion {
  final String question;
  final Map<String, String> options; // option -> learning style
  
  VARKQuestion({
    required this.question,
    required this.options,
  });
}

// VARK Quiz Data
class VARKQuizData {
  static List<VARKQuestion> getQuestions() {
    return [
      VARKQuestion(
        question: "When you need to learn something new, you prefer to:",
        options: {
          "Watch videos or demonstrations": "V",
          "Listen to explanations or podcasts": "A", 
          "Read books or articles": "R",
          "Practice hands-on activities": "K",
        },
      ),
      VARKQuestion(
        question: "When giving directions to someone, you would:",
        options: {
          "Draw a map or show pictures": "V",
          "Give verbal directions": "A",
          "Write down the directions": "R",
          "Walk with them to show the way": "K",
        },
      ),
      VARKQuestion(
        question: "When studying for an exam, you:",
        options: {
          "Use charts, diagrams, and visual aids": "V",
          "Record yourself reading notes and listen back": "A",
          "Read and rewrite your notes multiple times": "R",
          "Use flashcards and practice problems": "K",
        },
      ),
      VARKQuestion(
        question: "You remember information best when:",
        options: {
          "You can see it in pictures or diagrams": "V",
          "You hear it explained out loud": "A",
          "You read it in text form": "R",
          "You can practice or experience it": "K",
        },
      ),
      VARKQuestion(
        question: "When learning a new software, you prefer to:",
        options: {
          "Watch tutorial videos": "V",
          "Have someone explain it verbally": "A",
          "Read the manual or documentation": "R",
          "Try it out and learn by doing": "K",
        },
      ),
      VARKQuestion(
        question: "In a classroom, you learn best when the teacher:",
        options: {
          "Uses visual presentations and diagrams": "V",
          "Explains concepts through discussion": "A",
          "Provides detailed written materials": "R",
          "Includes hands-on activities and experiments": "K",
        },
      ),
      VARKQuestion(
        question: "When you're trying to concentrate, you:",
        options: {
          "Need a clean, organized visual environment": "V",
          "Prefer background music or sounds": "A",
          "Like to have reading materials nearby": "R",
          "Need to move around or fidget": "K",
        },
      ),
      VARKQuestion(
        question: "When explaining a concept to others, you:",
        options: {
          "Draw pictures or use visual examples": "V",
          "Talk through it step by step": "A",
          "Write it down or share articles": "R",
          "Show them how to do it practically": "K",
        },
      ),
      VARKQuestion(
        question: "Your ideal study environment includes:",
        options: {
          "Good lighting and visual organization": "V",
          "Ability to discuss with others or listen to audio": "A",
          "Quiet space with books and written materials": "R",
          "Space to move around and use hands-on materials": "K",
        },
      ),
      VARKQuestion(
        question: "When you need to remember a phone number, you:",
        options: {
          "Visualize the numbers in your mind": "V",
          "Repeat it out loud several times": "A",
          "Write it down immediately": "R",
          "Use your finger to 'dial' the numbers": "K",
        },
      ),
    ];
  }
}