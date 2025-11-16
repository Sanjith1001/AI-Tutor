class Course {
  final String id;
  final String title;
  final String description;
  final String? shortDescription;
  final String category;
  final String? subcategory;
  final String difficulty;
  final List<String> prerequisites;
  final List<CourseModule> modules;
  final bool isPublished;
  final bool isActive;
  final bool isFree;
  final double price;
  final String? thumbnail;
  final List<String> images;
  final int totalDuration;
  final int totalModules;
  final List<String> learningOutcomes;
  final List<String> tags;
  final String? slug;
  final double averageRating;
  final int totalRatings;
  final User? createdBy;
  final List<User> instructors;
  final int views;
  final double completionRate;
  final String status;
  final DateTime createdAt;
  final DateTime updatedAt;
  final DateTime? publishedAt;
  final int enrollmentCount;
  final String formattedDuration;

  Course({
    required this.id,
    required this.title,
    required this.description,
    this.shortDescription,
    required this.category,
    this.subcategory,
    required this.difficulty,
    required this.prerequisites,
    required this.modules,
    required this.isPublished,
    required this.isActive,
    required this.isFree,
    required this.price,
    this.thumbnail,
    required this.images,
    required this.totalDuration,
    required this.totalModules,
    required this.learningOutcomes,
    required this.tags,
    this.slug,
    required this.averageRating,
    required this.totalRatings,
    this.createdBy,
    required this.instructors,
    required this.views,
    required this.completionRate,
    required this.status,
    required this.createdAt,
    required this.updatedAt,
    this.publishedAt,
    required this.enrollmentCount,
    required this.formattedDuration,
  });

  factory Course.fromJson(Map<String, dynamic> json) {
    return Course(
      id: json['_id'] ?? '',
      title: json['title'] ?? '',
      description: json['description'] ?? '',
      shortDescription: json['shortDescription'],
      category: json['category'] ?? '',
      subcategory: json['subcategory'],
      difficulty: json['difficulty'] ?? 'beginner',
      prerequisites: List<String>.from(json['prerequisites'] ?? []),
      modules: (json['modules'] as List<dynamic>?)
              ?.map((m) => CourseModule.fromJson(m))
              .toList() ??
          [],
      isPublished: json['isPublished'] ?? false,
      isActive: json['isActive'] ?? true,
      isFree: json['isFree'] ?? true,
      price: (json['price'] ?? 0).toDouble(),
      thumbnail: json['thumbnail'],
      images: List<String>.from(json['images'] ?? []),
      totalDuration: json['totalDuration'] ?? 0,
      totalModules: json['totalModules'] ?? 0,
      learningOutcomes: List<String>.from(json['learningOutcomes'] ?? []),
      tags: List<String>.from(json['tags'] ?? []),
      slug: json['slug'],
      averageRating: (json['averageRating'] ?? 0).toDouble(),
      totalRatings: json['totalRatings'] ?? 0,
      createdBy:
          json['createdBy'] != null ? User.fromJson(json['createdBy']) : null,
      instructors: (json['instructors'] as List<dynamic>?)
              ?.map((i) => User.fromJson(i))
              .toList() ??
          [],
      views: json['views'] ?? 0,
      completionRate: (json['completionRate'] ?? 0).toDouble(),
      status: json['status'] ?? 'draft',
      createdAt:
          DateTime.parse(json['createdAt'] ?? DateTime.now().toIso8601String()),
      updatedAt:
          DateTime.parse(json['updatedAt'] ?? DateTime.now().toIso8601String()),
      publishedAt: json['publishedAt'] != null
          ? DateTime.parse(json['publishedAt'])
          : null,
      enrollmentCount: json['enrollmentCount'] ?? 0,
      formattedDuration: json['formattedDuration'] ?? '0m',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      '_id': id,
      'title': title,
      'description': description,
      'shortDescription': shortDescription,
      'category': category,
      'subcategory': subcategory,
      'difficulty': difficulty,
      'prerequisites': prerequisites,
      'modules': modules.map((m) => m.toJson()).toList(),
      'isPublished': isPublished,
      'isActive': isActive,
      'isFree': isFree,
      'price': price,
      'thumbnail': thumbnail,
      'images': images,
      'totalDuration': totalDuration,
      'totalModules': totalModules,
      'learningOutcomes': learningOutcomes,
      'tags': tags,
      'slug': slug,
      'averageRating': averageRating,
      'totalRatings': totalRatings,
      'createdBy': createdBy?.toJson(),
      'instructors': instructors.map((i) => i.toJson()).toList(),
      'views': views,
      'completionRate': completionRate,
      'status': status,
      'createdAt': createdAt.toIso8601String(),
      'updatedAt': updatedAt.toIso8601String(),
      'publishedAt': publishedAt?.toIso8601String(),
      'enrollmentCount': enrollmentCount,
      'formattedDuration': formattedDuration,
    };
  }
}

class CourseModule {
  final String id;
  final String title;
  final String description;
  final String content;
  final String contentType;
  final int duration;
  final int order;
  final bool isCompleted;
  final String? videoUrl;
  final String? videoThumbnail;
  final String? audioUrl;
  final Quiz? quiz;
  final List<String> learningObjectives;
  final List<String> prerequisites;
  final List<Resource> resources;
  final DateTime createdAt;
  final DateTime updatedAt;

  CourseModule({
    required this.id,
    required this.title,
    required this.description,
    required this.content,
    required this.contentType,
    required this.duration,
    required this.order,
    required this.isCompleted,
    this.videoUrl,
    this.videoThumbnail,
    this.audioUrl,
    this.quiz,
    required this.learningObjectives,
    required this.prerequisites,
    required this.resources,
    required this.createdAt,
    required this.updatedAt,
  });

  factory CourseModule.fromJson(Map<String, dynamic> json) {
    return CourseModule(
      id: json['_id'] ?? '',
      title: json['title'] ?? '',
      description: json['description'] ?? '',
      content: json['content'] ?? '',
      contentType: json['contentType'] ?? 'text',
      duration: json['duration'] ?? 0,
      order: json['order'] ?? 0,
      isCompleted: json['isCompleted'] ?? false,
      videoUrl: json['videoUrl'],
      videoThumbnail: json['videoThumbnail'],
      audioUrl: json['audioUrl'],
      quiz: json['quiz'] != null ? Quiz.fromJson(json['quiz']) : null,
      learningObjectives: List<String>.from(json['learningObjectives'] ?? []),
      prerequisites: List<String>.from(json['prerequisites'] ?? []),
      resources: (json['resources'] as List<dynamic>?)
              ?.map((r) => Resource.fromJson(r))
              .toList() ??
          [],
      createdAt:
          DateTime.parse(json['createdAt'] ?? DateTime.now().toIso8601String()),
      updatedAt:
          DateTime.parse(json['updatedAt'] ?? DateTime.now().toIso8601String()),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      '_id': id,
      'title': title,
      'description': description,
      'content': content,
      'contentType': contentType,
      'duration': duration,
      'order': order,
      'isCompleted': isCompleted,
      'videoUrl': videoUrl,
      'videoThumbnail': videoThumbnail,
      'audioUrl': audioUrl,
      'quiz': quiz?.toJson(),
      'learningObjectives': learningObjectives,
      'prerequisites': prerequisites,
      'resources': resources.map((r) => r.toJson()).toList(),
      'createdAt': createdAt.toIso8601String(),
      'updatedAt': updatedAt.toIso8601String(),
    };
  }
}

class Quiz {
  final List<QuizQuestion> questions;
  final int passingScore;
  final int? timeLimit;

  Quiz({
    required this.questions,
    required this.passingScore,
    this.timeLimit,
  });

  factory Quiz.fromJson(Map<String, dynamic> json) {
    return Quiz(
      questions: (json['questions'] as List<dynamic>?)
              ?.map((q) => QuizQuestion.fromJson(q))
              .toList() ??
          [],
      passingScore: json['passingScore'] ?? 70,
      timeLimit: json['timeLimit'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'questions': questions.map((q) => q.toJson()).toList(),
      'passingScore': passingScore,
      'timeLimit': timeLimit,
    };
  }
}

class QuizQuestion {
  final String question;
  final List<QuizOption> options;
  final String? explanation;
  final int points;

  QuizQuestion({
    required this.question,
    required this.options,
    this.explanation,
    required this.points,
  });

  factory QuizQuestion.fromJson(Map<String, dynamic> json) {
    return QuizQuestion(
      question: json['question'] ?? '',
      options: (json['options'] as List<dynamic>?)
              ?.map((o) => QuizOption.fromJson(o))
              .toList() ??
          [],
      explanation: json['explanation'],
      points: json['points'] ?? 1,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'question': question,
      'options': options.map((o) => o.toJson()).toList(),
      'explanation': explanation,
      'points': points,
    };
  }
}

class QuizOption {
  final String text;
  final bool isCorrect;

  QuizOption({
    required this.text,
    required this.isCorrect,
  });

  factory QuizOption.fromJson(Map<String, dynamic> json) {
    return QuizOption(
      text: json['text'] ?? '',
      isCorrect: json['isCorrect'] ?? false,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'text': text,
      'isCorrect': isCorrect,
    };
  }
}

class Resource {
  final String title;
  final String url;
  final String type;

  Resource({
    required this.title,
    required this.url,
    required this.type,
  });

  factory Resource.fromJson(Map<String, dynamic> json) {
    return Resource(
      title: json['title'] ?? '',
      url: json['url'] ?? '',
      type: json['type'] ?? 'link',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'title': title,
      'url': url,
      'type': type,
    };
  }
}

class User {
  final String id;
  final String firstName;
  final String lastName;
  final String email;
  final String? bio;

  User({
    required this.id,
    required this.firstName,
    required this.lastName,
    required this.email,
    this.bio,
  });

  factory User.fromJson(Map<String, dynamic> json) {
    return User(
      id: json['_id'] ?? '',
      firstName: json['firstName'] ?? '',
      lastName: json['lastName'] ?? '',
      email: json['email'] ?? '',
      bio: json['bio'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      '_id': id,
      'firstName': firstName,
      'lastName': lastName,
      'email': email,
      'bio': bio,
    };
  }

  String get fullName => '$firstName $lastName';
}
