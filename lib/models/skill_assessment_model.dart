// Skill Assessment Models
class SkillLevel {
  static const String beginner = 'Beginner';
  static const String intermediate = 'Intermediate';
  static const String advanced = 'Advanced';
  
  static String getLevel(int score, int totalQuestions) {
    double percentage = score / totalQuestions;
    if (percentage <= 0.4) return beginner;
    if (percentage <= 0.7) return intermediate;
    return advanced;
  }
  
  static String getLevelDescription(String level) {
    switch (level) {
      case beginner:
        return 'You\'re just starting out. We\'ll cover the fundamentals and build a strong foundation.';
      case intermediate:
        return 'You have some knowledge. We\'ll build on what you know and fill in any gaps.';
      case advanced:
        return 'You have strong knowledge. We\'ll focus on advanced concepts and applications.';
      default:
        return 'We\'ll customize the content based on your assessment.';
    }
  }
}

class SkillAssessmentResult {
  final String course;
  final int score;
  final int totalQuestions;
  final String skillLevel;
  final DateTime completedAt;
  final List<String> strengths;
  final List<String> improvementAreas;

  SkillAssessmentResult({
    required this.course,
    required this.score,
    required this.totalQuestions,
    required this.skillLevel,
    required this.completedAt,
    required this.strengths,
    required this.improvementAreas,
  });

  Map<String, dynamic> toJson() {
    return {
      'course': course,
      'score': score,
      'totalQuestions': totalQuestions,
      'skillLevel': skillLevel,
      'completedAt': completedAt.toIso8601String(),
      'strengths': strengths,
      'improvementAreas': improvementAreas,
    };
  }

  factory SkillAssessmentResult.fromJson(Map<String, dynamic> json) {
    return SkillAssessmentResult(
      course: json['course'],
      score: json['score'],
      totalQuestions: json['totalQuestions'],
      skillLevel: json['skillLevel'],
      completedAt: DateTime.parse(json['completedAt']),
      strengths: List<String>.from(json['strengths']),
      improvementAreas: List<String>.from(json['improvementAreas']),
    );
  }
}

class AssessmentQuestion {
  final String question;
  final List<String> options;
  final int correctAnswerIndex;
  final String topic;
  final String difficulty;

  AssessmentQuestion({
    required this.question,
    required this.options,
    required this.correctAnswerIndex,
    required this.topic,
    required this.difficulty,
  });
}

// Sample questions for different courses
class SkillAssessmentData {
  static List<AssessmentQuestion> getQuestionsForCourse(String course, {String? specificSubject}) {
    List<AssessmentQuestion> allQuestions = [];
    
    if (specificSubject != null) {
      allQuestions = _getQuestionsForSpecificSubject(specificSubject);
    } else {
      switch (course) {
        case 'Mathematics':
          allQuestions = _getMathQuestions();
          break;
        case 'Computer Science':
          allQuestions = _getComputerScienceQuestions();
          break;
        case 'Physics':
          allQuestions = _getPhysicsQuestions();
          break;
        case 'Chemistry':
          allQuestions = _getChemistryQuestions();
          break;
        case 'Biology':
          allQuestions = _getBiologyQuestions();
          break;
        default:
          allQuestions = _getGeneralQuestions();
      }
    }
    
    // Shuffle questions to make them different each time
    allQuestions.shuffle();
    
    // Return only 8 questions to keep assessment manageable
    return allQuestions.take(8).toList();
  }

  static List<AssessmentQuestion> _getQuestionsForSpecificSubject(String subject) {
    switch (subject.toLowerCase()) {
      case 'java programming':
        return _getJavaQuestions();
      case 'python programming':
        return _getPythonQuestions();
      case 'data structures':
        return _getDataStructuresQuestions();
      case 'algorithms':
        return _getAlgorithmsQuestions();
      case 'object-oriented programming':
        return _getOOPQuestions();
      case 'web development':
        return _getWebDevQuestions();
      case 'database systems':
        return _getDatabaseQuestions();
      case 'algebra':
        return _getAlgebraQuestions();
      case 'calculus':
        return _getCalculusQuestions();
      case 'geometry':
        return _getGeometryQuestions();
      case 'statistics':
        return _getStatisticsQuestions();
      default:
        return _getGeneralQuestions();
    }
  }

  static List<AssessmentQuestion> _getMathQuestions() {
    return [
      AssessmentQuestion(
        question: "What is 15% of 200?",
        options: ["25", "30", "35", "40"],
        correctAnswerIndex: 1,
        topic: "Percentages",
        difficulty: "Basic",
      ),
      AssessmentQuestion(
        question: "Solve for x: 2x + 5 = 15",
        options: ["x = 5", "x = 10", "x = 7.5", "x = 2.5"],
        correctAnswerIndex: 0,
        topic: "Algebra",
        difficulty: "Basic",
      ),
      AssessmentQuestion(
        question: "What is the derivative of x²?",
        options: ["x", "2x", "x²", "2x²"],
        correctAnswerIndex: 1,
        topic: "Calculus",
        difficulty: "Intermediate",
      ),
      AssessmentQuestion(
        question: "In a right triangle, if one angle is 30°, what is the other acute angle?",
        options: ["45°", "60°", "90°", "120°"],
        correctAnswerIndex: 1,
        topic: "Geometry",
        difficulty: "Basic",
      ),
      AssessmentQuestion(
        question: "What is the area of a circle with radius 5?",
        options: ["10π", "25π", "5π", "15π"],
        correctAnswerIndex: 1,
        topic: "Geometry",
        difficulty: "Intermediate",
      ),
      AssessmentQuestion(
        question: "What is the integral of 2x?",
        options: ["x²", "x² + C", "2", "2x + C"],
        correctAnswerIndex: 1,
        topic: "Calculus",
        difficulty: "Intermediate",
      ),
      AssessmentQuestion(
        question: "If log₁₀(x) = 2, what is x?",
        options: ["10", "20", "100", "200"],
        correctAnswerIndex: 2,
        topic: "Logarithms",
        difficulty: "Advanced",
      ),
      AssessmentQuestion(
        question: "What is the sum of interior angles of a pentagon?",
        options: ["360°", "540°", "720°", "900°"],
        correctAnswerIndex: 1,
        topic: "Geometry",
        difficulty: "Intermediate",
      ),
    ];
  }

  static List<AssessmentQuestion> _getComputerScienceQuestions() {
    return [
      AssessmentQuestion(
        question: "What does HTML stand for?",
        options: ["Hyper Text Markup Language", "High Tech Modern Language", "Home Tool Markup Language", "Hyperlink and Text Markup Language"],
        correctAnswerIndex: 0,
        topic: "Web Development",
        difficulty: "Basic",
      ),
      AssessmentQuestion(
        question: "Which data structure uses LIFO (Last In, First Out)?",
        options: ["Queue", "Stack", "Array", "Linked List"],
        correctAnswerIndex: 1,
        topic: "Data Structures",
        difficulty: "Basic",
      ),
      AssessmentQuestion(
        question: "What is the time complexity of binary search?",
        options: ["O(n)", "O(log n)", "O(n²)", "O(1)"],
        correctAnswerIndex: 1,
        topic: "Algorithms",
        difficulty: "Intermediate",
      ),
      AssessmentQuestion(
        question: "In object-oriented programming, what is encapsulation?",
        options: ["Hiding implementation details", "Creating multiple objects", "Inheriting from parent class", "Overriding methods"],
        correctAnswerIndex: 0,
        topic: "OOP",
        difficulty: "Intermediate",
      ),
      AssessmentQuestion(
        question: "What is the output of: print(2 ** 3) in Python?",
        options: ["6", "8", "9", "23"],
        correctAnswerIndex: 1,
        topic: "Programming",
        difficulty: "Basic",
      ),
      AssessmentQuestion(
        question: "Which sorting algorithm has the best average-case time complexity?",
        options: ["Bubble Sort", "Selection Sort", "Quick Sort", "Insertion Sort"],
        correctAnswerIndex: 2,
        topic: "Algorithms",
        difficulty: "Advanced",
      ),
      AssessmentQuestion(
        question: "What does SQL stand for?",
        options: ["Structured Query Language", "Simple Query Language", "Standard Query Language", "System Query Language"],
        correctAnswerIndex: 0,
        topic: "Database",
        difficulty: "Basic",
      ),
      AssessmentQuestion(
        question: "In a binary tree, what is the maximum number of nodes at level 3?",
        options: ["3", "6", "8", "9"],
        correctAnswerIndex: 2,
        topic: "Data Structures",
        difficulty: "Intermediate",
      ),
    ];
  }

  static List<AssessmentQuestion> _getPhysicsQuestions() {
    return [
      AssessmentQuestion(
        question: "What is the unit of force?",
        options: ["Joule", "Newton", "Watt", "Pascal"],
        correctAnswerIndex: 1,
        topic: "Mechanics",
        difficulty: "Basic",
      ),
      AssessmentQuestion(
        question: "What is the acceleration due to gravity on Earth?",
        options: ["9.8 m/s²", "10 m/s²", "8.9 m/s²", "11 m/s²"],
        correctAnswerIndex: 0,
        topic: "Mechanics",
        difficulty: "Basic",
      ),
      AssessmentQuestion(
        question: "According to Newton's first law, an object at rest will:",
        options: ["Start moving", "Stay at rest unless acted upon by force", "Accelerate", "Change direction"],
        correctAnswerIndex: 1,
        topic: "Mechanics",
        difficulty: "Basic",
      ),
      AssessmentQuestion(
        question: "What is the speed of light in vacuum?",
        options: ["3 × 10⁸ m/s", "3 × 10⁶ m/s", "3 × 10¹⁰ m/s", "3 × 10⁴ m/s"],
        correctAnswerIndex: 0,
        topic: "Optics",
        difficulty: "Intermediate",
      ),
      AssessmentQuestion(
        question: "What is the first law of thermodynamics?",
        options: ["Energy cannot be created or destroyed", "Entropy always increases", "Heat flows from hot to cold", "PV = nRT"],
        correctAnswerIndex: 0,
        topic: "Thermodynamics",
        difficulty: "Intermediate",
      ),
      AssessmentQuestion(
        question: "What is the unit of electric current?",
        options: ["Volt", "Ohm", "Ampere", "Coulomb"],
        correctAnswerIndex: 2,
        topic: "Electricity",
        difficulty: "Basic",
      ),
      AssessmentQuestion(
        question: "In quantum mechanics, what does the uncertainty principle state?",
        options: ["Position and momentum cannot both be precisely known", "Energy is quantized", "Wave-particle duality", "Electrons orbit in shells"],
        correctAnswerIndex: 0,
        topic: "Quantum Physics",
        difficulty: "Advanced",
      ),
      AssessmentQuestion(
        question: "What is the formula for kinetic energy?",
        options: ["mgh", "½mv²", "mv", "ma"],
        correctAnswerIndex: 1,
        topic: "Mechanics",
        difficulty: "Intermediate",
      ),
    ];
  }

  static List<AssessmentQuestion> _getChemistryQuestions() {
    return [
      AssessmentQuestion(
        question: "What is the chemical symbol for gold?",
        options: ["Go", "Gd", "Au", "Ag"],
        correctAnswerIndex: 2,
        topic: "Elements",
        difficulty: "Basic",
      ),
      AssessmentQuestion(
        question: "How many electrons can the first shell hold?",
        options: ["2", "8", "18", "32"],
        correctAnswerIndex: 0,
        topic: "Atomic Structure",
        difficulty: "Basic",
      ),
      AssessmentQuestion(
        question: "What is the pH of pure water?",
        options: ["6", "7", "8", "9"],
        correctAnswerIndex: 1,
        topic: "Acids and Bases",
        difficulty: "Basic",
      ),
      AssessmentQuestion(
        question: "What type of bond forms between metals and non-metals?",
        options: ["Covalent", "Ionic", "Metallic", "Hydrogen"],
        correctAnswerIndex: 1,
        topic: "Chemical Bonding",
        difficulty: "Intermediate",
      ),
      AssessmentQuestion(
        question: "What is Avogadro's number?",
        options: ["6.02 × 10²³", "6.02 × 10²²", "6.02 × 10²⁴", "6.02 × 10²¹"],
        correctAnswerIndex: 0,
        topic: "Moles",
        difficulty: "Intermediate",
      ),
      AssessmentQuestion(
        question: "In the periodic table, what increases as you move from left to right?",
        options: ["Atomic radius", "Atomic number", "Metallic character", "Number of shells"],
        correctAnswerIndex: 1,
        topic: "Periodic Table",
        difficulty: "Intermediate",
      ),
      AssessmentQuestion(
        question: "What is the molecular formula for glucose?",
        options: ["C₆H₁₂O₆", "C₆H₆", "CH₄", "H₂O"],
        correctAnswerIndex: 0,
        topic: "Organic Chemistry",
        difficulty: "Advanced",
      ),
      AssessmentQuestion(
        question: "What happens to the rate of reaction when temperature increases?",
        options: ["Decreases", "Stays the same", "Increases", "Becomes zero"],
        correctAnswerIndex: 2,
        topic: "Reaction Kinetics",
        difficulty: "Intermediate",
      ),
    ];
  }

  static List<AssessmentQuestion> _getBiologyQuestions() {
    return [
      AssessmentQuestion(
        question: "What is the powerhouse of the cell?",
        options: ["Nucleus", "Mitochondria", "Ribosome", "Endoplasmic Reticulum"],
        correctAnswerIndex: 1,
        topic: "Cell Biology",
        difficulty: "Basic",
      ),
      AssessmentQuestion(
        question: "What is the process by which plants make food?",
        options: ["Respiration", "Photosynthesis", "Digestion", "Fermentation"],
        correctAnswerIndex: 1,
        topic: "Plant Biology",
        difficulty: "Basic",
      ),
      AssessmentQuestion(
        question: "How many chromosomes do humans have?",
        options: ["44", "46", "48", "50"],
        correctAnswerIndex: 1,
        topic: "Genetics",
        difficulty: "Basic",
      ),
      AssessmentQuestion(
        question: "What is DNA?",
        options: ["Deoxyribonucleic Acid", "Dinitrogen Acid", "Deoxyribose Acid", "Dinucleotide Acid"],
        correctAnswerIndex: 0,
        topic: "Genetics",
        difficulty: "Basic",
      ),
      AssessmentQuestion(
        question: "Which blood type is considered the universal donor?",
        options: ["A", "B", "AB", "O"],
        correctAnswerIndex: 3,
        topic: "Human Biology",
        difficulty: "Intermediate",
      ),
      AssessmentQuestion(
        question: "What is the largest organ in the human body?",
        options: ["Liver", "Brain", "Skin", "Lungs"],
        correctAnswerIndex: 2,
        topic: "Human Anatomy",
        difficulty: "Intermediate",
      ),
      AssessmentQuestion(
        question: "In which organelle does protein synthesis occur?",
        options: ["Nucleus", "Mitochondria", "Ribosome", "Golgi apparatus"],
        correctAnswerIndex: 2,
        topic: "Cell Biology",
        difficulty: "Intermediate",
      ),
      AssessmentQuestion(
        question: "What is the theory of evolution primarily associated with?",
        options: ["Mendel", "Darwin", "Watson", "Crick"],
        correctAnswerIndex: 1,
        topic: "Evolution",
        difficulty: "Advanced",
      ),
    ];
  }

  static List<AssessmentQuestion> _getJavaQuestions() {
    return [
      AssessmentQuestion(
        question: "Which keyword is used to create a class in Java?",
        options: ["class", "Class", "create", "new"],
        correctAnswerIndex: 0,
        topic: "Java Basics",
        difficulty: "Basic",
      ),
      AssessmentQuestion(
        question: "What is the correct way to declare a variable in Java?",
        options: ["int x;", "variable int x;", "declare int x;", "int: x;"],
        correctAnswerIndex: 0,
        topic: "Variables",
        difficulty: "Basic",
      ),
      AssessmentQuestion(
        question: "Which method is the entry point of a Java program?",
        options: ["start()", "main()", "run()", "begin()"],
        correctAnswerIndex: 1,
        topic: "Program Structure",
        difficulty: "Basic",
      ),
      AssessmentQuestion(
        question: "What is inheritance in Java?",
        options: ["Creating multiple objects", "A class acquiring properties of another class", "Method overloading", "Variable declaration"],
        correctAnswerIndex: 1,
        topic: "OOP Concepts",
        difficulty: "Intermediate",
      ),
      AssessmentQuestion(
        question: "Which access modifier makes a member accessible only within the same class?",
        options: ["public", "protected", "private", "default"],
        correctAnswerIndex: 2,
        topic: "Access Modifiers",
        difficulty: "Intermediate",
      ),
      AssessmentQuestion(
        question: "What is polymorphism in Java?",
        options: ["Having multiple constructors", "One interface, multiple implementations", "Creating arrays", "Exception handling"],
        correctAnswerIndex: 1,
        topic: "OOP Concepts",
        difficulty: "Advanced",
      ),
      AssessmentQuestion(
        question: "Which collection class allows duplicate elements?",
        options: ["Set", "HashSet", "ArrayList", "TreeSet"],
        correctAnswerIndex: 2,
        topic: "Collections",
        difficulty: "Intermediate",
      ),
      AssessmentQuestion(
        question: "What is the difference between == and .equals() in Java?",
        options: ["No difference", "== compares references, .equals() compares content", "== compares content, .equals() compares references", "Both compare references"],
        correctAnswerIndex: 1,
        topic: "Object Comparison",
        difficulty: "Advanced",
      ),
      AssessmentQuestion(
        question: "Which keyword is used to handle exceptions in Java?",
        options: ["catch", "handle", "exception", "error"],
        correctAnswerIndex: 0,
        topic: "Exception Handling",
        difficulty: "Intermediate",
      ),
      AssessmentQuestion(
        question: "What is a constructor in Java?",
        options: ["A method that destroys objects", "A special method to initialize objects", "A variable type", "A loop structure"],
        correctAnswerIndex: 1,
        topic: "Constructors",
        difficulty: "Basic",
      ),
    ];
  }

  static List<AssessmentQuestion> _getPythonQuestions() {
    return [
      AssessmentQuestion(
        question: "How do you create a comment in Python?",
        options: ["// comment", "/* comment */", "# comment", "<!-- comment -->"],
        correctAnswerIndex: 2,
        topic: "Python Basics",
        difficulty: "Basic",
      ),
      AssessmentQuestion(
        question: "Which data type is mutable in Python?",
        options: ["tuple", "string", "list", "int"],
        correctAnswerIndex: 2,
        topic: "Data Types",
        difficulty: "Basic",
      ),
      AssessmentQuestion(
        question: "What is the output of: print(type([]))?",
        options: ["<class 'array'>", "<class 'list'>", "<class 'tuple'>", "<class 'dict'>"],
        correctAnswerIndex: 1,
        topic: "Data Types",
        difficulty: "Basic",
      ),
      AssessmentQuestion(
        question: "How do you define a function in Python?",
        options: ["function myFunc():", "def myFunc():", "create myFunc():", "func myFunc():"],
        correctAnswerIndex: 1,
        topic: "Functions",
        difficulty: "Basic",
      ),
      AssessmentQuestion(
        question: "What is a lambda function in Python?",
        options: ["A named function", "An anonymous function", "A class method", "A built-in function"],
        correctAnswerIndex: 1,
        topic: "Functions",
        difficulty: "Intermediate",
      ),
      AssessmentQuestion(
        question: "Which method is used to add an element to a list?",
        options: ["add()", "append()", "insert()", "push()"],
        correctAnswerIndex: 1,
        topic: "Lists",
        difficulty: "Basic",
      ),
      AssessmentQuestion(
        question: "What is list comprehension in Python?",
        options: ["A way to create lists concisely", "A method to sort lists", "A type of loop", "A built-in function"],
        correctAnswerIndex: 0,
        topic: "List Comprehension",
        difficulty: "Intermediate",
      ),
      AssessmentQuestion(
        question: "What is the difference between '==' and 'is' in Python?",
        options: ["No difference", "'==' compares values, 'is' compares identity", "'==' compares identity, 'is' compares values", "Both compare values"],
        correctAnswerIndex: 1,
        topic: "Comparison",
        difficulty: "Advanced",
      ),
      AssessmentQuestion(
        question: "How do you handle exceptions in Python?",
        options: ["try-catch", "try-except", "catch-finally", "handle-error"],
        correctAnswerIndex: 1,
        topic: "Exception Handling",
        difficulty: "Intermediate",
      ),
      AssessmentQuestion(
        question: "What is a decorator in Python?",
        options: ["A design pattern", "A function that modifies another function", "A data structure", "A loop construct"],
        correctAnswerIndex: 1,
        topic: "Decorators",
        difficulty: "Advanced",
      ),
    ];
  }

  static List<AssessmentQuestion> _getDataStructuresQuestions() {
    return [
      AssessmentQuestion(
        question: "Which data structure uses LIFO (Last In, First Out)?",
        options: ["Queue", "Stack", "Array", "Linked List"],
        correctAnswerIndex: 1,
        topic: "Stack",
        difficulty: "Basic",
      ),
      AssessmentQuestion(
        question: "Which data structure uses FIFO (First In, First Out)?",
        options: ["Stack", "Queue", "Tree", "Graph"],
        correctAnswerIndex: 1,
        topic: "Queue",
        difficulty: "Basic",
      ),
      AssessmentQuestion(
        question: "What is the time complexity of accessing an element in an array by index?",
        options: ["O(n)", "O(log n)", "O(1)", "O(n²)"],
        correctAnswerIndex: 2,
        topic: "Arrays",
        difficulty: "Basic",
      ),
      AssessmentQuestion(
        question: "In a binary tree, what is the maximum number of children a node can have?",
        options: ["1", "2", "3", "Unlimited"],
        correctAnswerIndex: 1,
        topic: "Binary Trees",
        difficulty: "Basic",
      ),
      AssessmentQuestion(
        question: "What is the worst-case time complexity of searching in a hash table?",
        options: ["O(1)", "O(log n)", "O(n)", "O(n²)"],
        correctAnswerIndex: 2,
        topic: "Hash Tables",
        difficulty: "Intermediate",
      ),
      AssessmentQuestion(
        question: "Which traversal visits the root node first in a binary tree?",
        options: ["Inorder", "Preorder", "Postorder", "Level order"],
        correctAnswerIndex: 1,
        topic: "Tree Traversal",
        difficulty: "Intermediate",
      ),
      AssessmentQuestion(
        question: "What is a balanced binary search tree?",
        options: ["A tree with equal left and right subtrees", "A tree where height difference between subtrees is at most 1", "A complete binary tree", "A tree with all leaves at the same level"],
        correctAnswerIndex: 1,
        topic: "Balanced Trees",
        difficulty: "Advanced",
      ),
      AssessmentQuestion(
        question: "In a doubly linked list, each node contains:",
        options: ["Only data", "Data and one pointer", "Data and two pointers", "Only pointers"],
        correctAnswerIndex: 2,
        topic: "Linked Lists",
        difficulty: "Intermediate",
      ),
      AssessmentQuestion(
        question: "What is the space complexity of merge sort?",
        options: ["O(1)", "O(log n)", "O(n)", "O(n²)"],
        correctAnswerIndex: 2,
        topic: "Sorting",
        difficulty: "Advanced",
      ),
      AssessmentQuestion(
        question: "Which data structure is best for implementing recursion?",
        options: ["Queue", "Stack", "Array", "Hash Table"],
        correctAnswerIndex: 1,
        topic: "Recursion",
        difficulty: "Intermediate",
      ),
    ];
  }

  static List<AssessmentQuestion> _getAlgorithmsQuestions() {
    return [
      AssessmentQuestion(
        question: "What is the time complexity of binary search?",
        options: ["O(n)", "O(log n)", "O(n²)", "O(1)"],
        correctAnswerIndex: 1,
        topic: "Search Algorithms",
        difficulty: "Basic",
      ),
      AssessmentQuestion(
        question: "Which sorting algorithm has the best average-case time complexity?",
        options: ["Bubble Sort", "Selection Sort", "Quick Sort", "Insertion Sort"],
        correctAnswerIndex: 2,
        topic: "Sorting Algorithms",
        difficulty: "Intermediate",
      ),
      AssessmentQuestion(
        question: "What is the worst-case time complexity of Quick Sort?",
        options: ["O(n log n)", "O(n²)", "O(n)", "O(log n)"],
        correctAnswerIndex: 1,
        topic: "Quick Sort",
        difficulty: "Advanced",
      ),
      AssessmentQuestion(
        question: "Which algorithm is used to find the shortest path in a graph?",
        options: ["DFS", "BFS", "Dijkstra's", "Binary Search"],
        correctAnswerIndex: 2,
        topic: "Graph Algorithms",
        difficulty: "Intermediate",
      ),
      AssessmentQuestion(
        question: "What is dynamic programming?",
        options: ["A programming language", "An optimization technique", "A data structure", "A sorting method"],
        correctAnswerIndex: 1,
        topic: "Dynamic Programming",
        difficulty: "Advanced",
      ),
      AssessmentQuestion(
        question: "Which algorithm uses divide and conquer approach?",
        options: ["Linear Search", "Bubble Sort", "Merge Sort", "Selection Sort"],
        correctAnswerIndex: 2,
        topic: "Divide and Conquer",
        difficulty: "Intermediate",
      ),
      AssessmentQuestion(
        question: "What is the time complexity of DFS (Depth First Search)?",
        options: ["O(V)", "O(E)", "O(V + E)", "O(V * E)"],
        correctAnswerIndex: 2,
        topic: "Graph Traversal",
        difficulty: "Intermediate",
      ),
      AssessmentQuestion(
        question: "Which data structure is used in BFS (Breadth First Search)?",
        options: ["Stack", "Queue", "Array", "Tree"],
        correctAnswerIndex: 1,
        topic: "Graph Traversal",
        difficulty: "Basic",
      ),
      AssessmentQuestion(
        question: "What is the principle behind greedy algorithms?",
        options: ["Optimal substructure", "Making locally optimal choices", "Divide and conquer", "Backtracking"],
        correctAnswerIndex: 1,
        topic: "Greedy Algorithms",
        difficulty: "Advanced",
      ),
      AssessmentQuestion(
        question: "Which algorithm is used for finding minimum spanning tree?",
        options: ["Dijkstra's", "Kruskal's", "Binary Search", "Quick Sort"],
        correctAnswerIndex: 1,
        topic: "Graph Algorithms",
        difficulty: "Advanced",
      ),
    ];
  }

  static List<AssessmentQuestion> _getOOPQuestions() {
    return [
      AssessmentQuestion(
        question: "What is encapsulation in OOP?",
        options: ["Hiding implementation details", "Creating multiple objects", "Inheriting properties", "Method overloading"],
        correctAnswerIndex: 0,
        topic: "Encapsulation",
        difficulty: "Basic",
      ),
      AssessmentQuestion(
        question: "What is inheritance?",
        options: ["Creating new objects", "A class acquiring properties of another class", "Method overriding", "Data hiding"],
        correctAnswerIndex: 1,
        topic: "Inheritance",
        difficulty: "Basic",
      ),
      AssessmentQuestion(
        question: "What is polymorphism?",
        options: ["Having multiple forms", "One interface, multiple implementations", "Creating classes", "Data abstraction"],
        correctAnswerIndex: 1,
        topic: "Polymorphism",
        difficulty: "Intermediate",
      ),
      AssessmentQuestion(
        question: "What is abstraction in OOP?",
        options: ["Hiding complex implementation", "Creating objects", "Method overloading", "Variable declaration"],
        correctAnswerIndex: 0,
        topic: "Abstraction",
        difficulty: "Basic",
      ),
      AssessmentQuestion(
        question: "What is method overriding?",
        options: ["Having multiple methods with same name", "Redefining a method in derived class", "Creating new methods", "Deleting methods"],
        correctAnswerIndex: 1,
        topic: "Method Overriding",
        difficulty: "Intermediate",
      ),
      AssessmentQuestion(
        question: "What is method overloading?",
        options: ["Redefining methods", "Having multiple methods with same name but different parameters", "Deleting methods", "Hiding methods"],
        correctAnswerIndex: 1,
        topic: "Method Overloading",
        difficulty: "Intermediate",
      ),
      AssessmentQuestion(
        question: "What is a constructor?",
        options: ["A method that destroys objects", "A special method to initialize objects", "A variable type", "A data structure"],
        correctAnswerIndex: 1,
        topic: "Constructors",
        difficulty: "Basic",
      ),
      AssessmentQuestion(
        question: "What is a destructor?",
        options: ["A method to create objects", "A method to clean up objects", "A variable type", "A loop structure"],
        correctAnswerIndex: 1,
        topic: "Destructors",
        difficulty: "Intermediate",
      ),
      AssessmentQuestion(
        question: "What is composition in OOP?",
        options: ["Inheriting from multiple classes", "A 'has-a' relationship between classes", "Method overloading", "Data hiding"],
        correctAnswerIndex: 1,
        topic: "Composition",
        difficulty: "Advanced",
      ),
      AssessmentQuestion(
        question: "What is the difference between interface and abstract class?",
        options: ["No difference", "Interface has only abstract methods, abstract class can have both", "Abstract class has only abstract methods", "Interface can be instantiated"],
        correctAnswerIndex: 1,
        topic: "Interface vs Abstract",
        difficulty: "Advanced",
      ),
    ];
  }

  static List<AssessmentQuestion> _getWebDevQuestions() {
    return [
      AssessmentQuestion(
        question: "What does HTML stand for?",
        options: ["Hyper Text Markup Language", "High Tech Modern Language", "Home Tool Markup Language", "Hyperlink Text Markup Language"],
        correctAnswerIndex: 0,
        topic: "HTML",
        difficulty: "Basic",
      ),
      AssessmentQuestion(
        question: "Which CSS property is used to change text color?",
        options: ["text-color", "color", "font-color", "text-style"],
        correctAnswerIndex: 1,
        topic: "CSS",
        difficulty: "Basic",
      ),
      AssessmentQuestion(
        question: "What is the correct way to link a CSS file to HTML?",
        options: ["<style src='style.css'>", "<link rel='stylesheet' href='style.css'>", "<css href='style.css'>", "<stylesheet src='style.css'>"],
        correctAnswerIndex: 1,
        topic: "HTML/CSS",
        difficulty: "Basic",
      ),
      AssessmentQuestion(
        question: "Which JavaScript method is used to select an element by ID?",
        options: ["getElementById()", "selectById()", "getElement()", "findById()"],
        correctAnswerIndex: 0,
        topic: "JavaScript DOM",
        difficulty: "Basic",
      ),
      AssessmentQuestion(
        question: "What is the box model in CSS?",
        options: ["A design pattern", "Content, padding, border, margin", "A layout technique", "A CSS framework"],
        correctAnswerIndex: 1,
        topic: "CSS Box Model",
        difficulty: "Intermediate",
      ),
      AssessmentQuestion(
        question: "What is responsive web design?",
        options: ["Fast loading websites", "Websites that adapt to different screen sizes", "Interactive websites", "Animated websites"],
        correctAnswerIndex: 1,
        topic: "Responsive Design",
        difficulty: "Intermediate",
      ),
      AssessmentQuestion(
        question: "What is AJAX?",
        options: ["A programming language", "Asynchronous JavaScript and XML", "A web server", "A database"],
        correctAnswerIndex: 1,
        topic: "AJAX",
        difficulty: "Advanced",
      ),
      AssessmentQuestion(
        question: "What is the purpose of media queries in CSS?",
        options: ["To play media files", "To apply styles based on device characteristics", "To query databases", "To handle user input"],
        correctAnswerIndex: 1,
        topic: "Media Queries",
        difficulty: "Intermediate",
      ),
      AssessmentQuestion(
        question: "What is the difference between '==' and '===' in JavaScript?",
        options: ["No difference", "'==' compares values, '===' compares values and types", "'==' compares types, '===' compares values", "Both compare types"],
        correctAnswerIndex: 1,
        topic: "JavaScript Comparison",
        difficulty: "Advanced",
      ),
      AssessmentQuestion(
        question: "What is a closure in JavaScript?",
        options: ["A loop structure", "A function with access to outer scope variables", "A data type", "An event handler"],
        correctAnswerIndex: 1,
        topic: "JavaScript Closures",
        difficulty: "Advanced",
      ),
    ];
  }

  static List<AssessmentQuestion> _getDatabaseQuestions() {
    return [
      AssessmentQuestion(
        question: "What does SQL stand for?",
        options: ["Structured Query Language", "Simple Query Language", "Standard Query Language", "System Query Language"],
        correctAnswerIndex: 0,
        topic: "SQL Basics",
        difficulty: "Basic",
      ),
      AssessmentQuestion(
        question: "Which SQL command is used to retrieve data?",
        options: ["GET", "SELECT", "RETRIEVE", "FETCH"],
        correctAnswerIndex: 1,
        topic: "SQL Commands",
        difficulty: "Basic",
      ),
      AssessmentQuestion(
        question: "What is a primary key?",
        options: ["The first column in a table", "A unique identifier for each row", "The most important column", "A foreign key reference"],
        correctAnswerIndex: 1,
        topic: "Database Keys",
        difficulty: "Basic",
      ),
      AssessmentQuestion(
        question: "What is normalization in databases?",
        options: ["Making data normal", "Organizing data to reduce redundancy", "Sorting data", "Backing up data"],
        correctAnswerIndex: 1,
        topic: "Normalization",
        difficulty: "Intermediate",
      ),
      AssessmentQuestion(
        question: "What is a foreign key?",
        options: ["A key from another country", "A reference to primary key in another table", "An encrypted key", "A backup key"],
        correctAnswerIndex: 1,
        topic: "Database Keys",
        difficulty: "Intermediate",
      ),
      AssessmentQuestion(
        question: "What is ACID in database transactions?",
        options: ["A type of database", "Atomicity, Consistency, Isolation, Durability", "A query language", "A storage method"],
        correctAnswerIndex: 1,
        topic: "Transactions",
        difficulty: "Advanced",
      ),
      AssessmentQuestion(
        question: "What is an index in a database?",
        options: ["A table of contents", "A data structure to improve query performance", "A type of key", "A backup mechanism"],
        correctAnswerIndex: 1,
        topic: "Database Indexing",
        difficulty: "Intermediate",
      ),
      AssessmentQuestion(
        question: "What is the difference between INNER JOIN and LEFT JOIN?",
        options: ["No difference", "INNER JOIN returns matching rows, LEFT JOIN returns all left table rows", "LEFT JOIN is faster", "INNER JOIN is newer"],
        correctAnswerIndex: 1,
        topic: "SQL Joins",
        difficulty: "Advanced",
      ),
      AssessmentQuestion(
        question: "What is a stored procedure?",
        options: ["A saved query", "A precompiled collection of SQL statements", "A backup method", "A data type"],
        correctAnswerIndex: 1,
        topic: "Stored Procedures",
        difficulty: "Advanced",
      ),
      AssessmentQuestion(
        question: "What is the purpose of GROUP BY clause?",
        options: ["To sort data", "To group rows with same values", "To join tables", "To filter data"],
        correctAnswerIndex: 1,
        topic: "SQL Aggregation",
        difficulty: "Intermediate",
      ),
    ];
  }

  static List<AssessmentQuestion> _getAlgebraQuestions() {
    return [
      AssessmentQuestion(
        question: "Solve for x: 2x + 5 = 15",
        options: ["x = 5", "x = 10", "x = 7.5", "x = 2.5"],
        correctAnswerIndex: 0,
        topic: "Linear Equations",
        difficulty: "Basic",
      ),
      AssessmentQuestion(
        question: "What is the slope of the line y = 3x + 2?",
        options: ["2", "3", "5", "1"],
        correctAnswerIndex: 1,
        topic: "Linear Functions",
        difficulty: "Basic",
      ),
      AssessmentQuestion(
        question: "Factor: x² - 9",
        options: ["(x - 3)(x - 3)", "(x + 3)(x - 3)", "(x + 9)(x - 1)", "Cannot be factored"],
        correctAnswerIndex: 1,
        topic: "Factoring",
        difficulty: "Intermediate",
      ),
      AssessmentQuestion(
        question: "Solve: x² - 5x + 6 = 0",
        options: ["x = 2, 3", "x = 1, 6", "x = -2, -3", "x = 5, 1"],
        correctAnswerIndex: 0,
        topic: "Quadratic Equations",
        difficulty: "Intermediate",
      ),
      AssessmentQuestion(
        question: "What is the discriminant of ax² + bx + c = 0?",
        options: ["b² - 4ac", "b² + 4ac", "-b ± √(b² - 4ac)", "4ac - b²"],
        correctAnswerIndex: 0,
        topic: "Quadratic Formula",
        difficulty: "Advanced",
      ),
    ];
  }

  static List<AssessmentQuestion> _getCalculusQuestions() {
    return [
      AssessmentQuestion(
        question: "What is the derivative of x²?",
        options: ["x", "2x", "x²", "2x²"],
        correctAnswerIndex: 1,
        topic: "Derivatives",
        difficulty: "Basic",
      ),
      AssessmentQuestion(
        question: "What is the integral of 2x?",
        options: ["x²", "x² + C", "2", "2x + C"],
        correctAnswerIndex: 1,
        topic: "Integration",
        difficulty: "Basic",
      ),
      AssessmentQuestion(
        question: "What is the derivative of sin(x)?",
        options: ["cos(x)", "-cos(x)", "sin(x)", "-sin(x)"],
        correctAnswerIndex: 0,
        topic: "Trigonometric Derivatives",
        difficulty: "Intermediate",
      ),
      AssessmentQuestion(
        question: "What is the limit of (sin x)/x as x approaches 0?",
        options: ["0", "1", "∞", "undefined"],
        correctAnswerIndex: 1,
        topic: "Limits",
        difficulty: "Advanced",
      ),
      AssessmentQuestion(
        question: "What is the chain rule?",
        options: ["d/dx[f(g(x))] = f'(g(x)) · g'(x)", "d/dx[f(x) + g(x)] = f'(x) + g'(x)", "d/dx[f(x) · g(x)] = f'(x) · g(x) + f(x) · g'(x)", "d/dx[f(x)/g(x)] = [f'(x)g(x) - f(x)g'(x)]/[g(x)]²"],
        correctAnswerIndex: 0,
        topic: "Chain Rule",
        difficulty: "Advanced",
      ),
    ];
  }

  static List<AssessmentQuestion> _getGeometryQuestions() {
    return [
      AssessmentQuestion(
        question: "What is the area of a circle with radius 5?",
        options: ["10π", "25π", "5π", "15π"],
        correctAnswerIndex: 1,
        topic: "Circle Area",
        difficulty: "Basic",
      ),
      AssessmentQuestion(
        question: "In a right triangle, if one angle is 30°, what is the other acute angle?",
        options: ["45°", "60°", "90°", "120°"],
        correctAnswerIndex: 1,
        topic: "Triangle Angles",
        difficulty: "Basic",
      ),
      AssessmentQuestion(
        question: "What is the Pythagorean theorem?",
        options: ["a + b = c", "a² + b² = c²", "a × b = c", "a² - b² = c²"],
        correctAnswerIndex: 1,
        topic: "Pythagorean Theorem",
        difficulty: "Basic",
      ),
      AssessmentQuestion(
        question: "What is the sum of interior angles of a pentagon?",
        options: ["360°", "540°", "720°", "900°"],
        correctAnswerIndex: 1,
        topic: "Polygon Angles",
        difficulty: "Intermediate",
      ),
      AssessmentQuestion(
        question: "What is the volume of a sphere with radius r?",
        options: ["4πr²", "(4/3)πr³", "πr²", "2πr³"],
        correctAnswerIndex: 1,
        topic: "Sphere Volume",
        difficulty: "Advanced",
      ),
    ];
  }

  static List<AssessmentQuestion> _getStatisticsQuestions() {
    return [
      AssessmentQuestion(
        question: "What is the mean of: 2, 4, 6, 8, 10?",
        options: ["5", "6", "7", "8"],
        correctAnswerIndex: 1,
        topic: "Mean",
        difficulty: "Basic",
      ),
      AssessmentQuestion(
        question: "What is the median of: 1, 3, 5, 7, 9?",
        options: ["3", "5", "7", "25"],
        correctAnswerIndex: 1,
        topic: "Median",
        difficulty: "Basic",
      ),
      AssessmentQuestion(
        question: "What is the mode of: 1, 2, 2, 3, 4, 4, 4?",
        options: ["2", "3", "4", "No mode"],
        correctAnswerIndex: 2,
        topic: "Mode",
        difficulty: "Basic",
      ),
      AssessmentQuestion(
        question: "What is standard deviation?",
        options: ["Average of data", "Measure of spread", "Middle value", "Most frequent value"],
        correctAnswerIndex: 1,
        topic: "Standard Deviation",
        difficulty: "Intermediate",
      ),
      AssessmentQuestion(
        question: "What is a normal distribution?",
        options: ["A skewed distribution", "A bell-shaped distribution", "A uniform distribution", "A random distribution"],
        correctAnswerIndex: 1,
        topic: "Normal Distribution",
        difficulty: "Advanced",
      ),
    ];
  }

  static List<AssessmentQuestion> _getGeneralQuestions() {
    return [
      AssessmentQuestion(
        question: "What is 2 + 2?",
        options: ["3", "4", "5", "6"],
        correctAnswerIndex: 1,
        topic: "Basic Math",
        difficulty: "Basic",
      ),
      AssessmentQuestion(
        question: "What is the capital of France?",
        options: ["London", "Berlin", "Paris", "Madrid"],
        correctAnswerIndex: 2,
        topic: "Geography",
        difficulty: "Basic",
      ),
    ];
  }
}