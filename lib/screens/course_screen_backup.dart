import 'package:flutter/material.dart';
import 'ai_module_content_screen.dart';
import '../models/course_model.dart';
import '../services/activity_service.dart';

class CourseScreen extends StatelessWidget {
  final String title;
  final List<Map<String, dynamic>> modules; // dynamic for Groq
  final String? learningStyle;
  final String? skillLevel;

  const CourseScreen({
    super.key,
    required this.title,
    required this.modules,
    this.learningStyle,
    this.skillLevel,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.blue.shade100,
      appBar: AppBar(
        title: Text(title),
        backgroundColor: Colors.white,
        elevation: 0,
        actions: [
          if (learningStyle != null)
            Padding(
              padding: const EdgeInsets.only(right: 16.0),
              child: Center(
                child: Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  decoration: BoxDecoration(
                    color: Colors.blue.shade600,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Text(
                    learningStyle!,
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 12,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ),
            ),
        ],
      ),
      body: Column(
        children: [
          // Personalization header if available
          if (learningStyle != null || skillLevel != null)
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(16),
              margin: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [Colors.blue.shade600, Colors.blue.shade400],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Row(
                    children: [
                      Icon(Icons.auto_awesome, color: Colors.white, size: 20),
                      SizedBox(width: 8),
                      Text(
                        'Personalized for You',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  if (learningStyle != null && skillLevel != null)
                    Text(
                      'This course is tailored for $learningStyle learners at $skillLevel level',
                      style: TextStyle(
                        color: Colors.white.withOpacity(0.9),
                        fontSize: 14,
                      ),
                    ),
                ],
              ),
            ),

          // Modules grid
          Expanded(
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: modules.isEmpty
                  ? const Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(Icons.school, size: 64, color: Colors.grey),
                          SizedBox(height: 16),
                          Text(
                            'No modules available',
                            style: TextStyle(fontSize: 18, color: Colors.grey),
                          ),
                        ],
                      ),
                    )
                  : GridView.count(
                      crossAxisCount: 3,
                      childAspectRatio: 0.9,
                      crossAxisSpacing: 16,
                      mainAxisSpacing: 16,
                      children: List.generate(modules.length, (index) {
                        final module = modules[index];
                        return ModuleCard(
                          title: module['title']?.toString() ?? "Untitled",
                          description: module['description']?.toString() ?? "",
                          index: index + 1,
                          course: courses.isNotEmpty
                              ? courses[0]
                              : null, // Example: pass the first course
                          learningStyle: learningStyle,
                          podcastUrl: module['podcastUrl']
                              ?.toString(), // Pass podcast URL if available
                        );
                      }),
                    ),
            ),
          ),
        ],
      ),
    );
  }
}

class ModuleCard extends StatefulWidget {
  final String title;
  final String description;
  final int index;
  final Course? course;
  final String? learningStyle;
  final String? podcastUrl; // Optional podcast URL

  const ModuleCard({
    super.key,
    required this.title,
    required this.description,
    required this.index,
    this.course,
    this.learningStyle,
    this.podcastUrl,
  });

  @override
  State<ModuleCard> createState() => _ModuleCardState();
}

class _ModuleCardState extends State<ModuleCard> {
  bool _isHovered = false;
  final AudioHelper _audioHelper = AudioHelper();
  String get _moduleId =>
      'module_${widget.index}_${widget.title.replaceAll(' ', '_').toLowerCase()}';

  @override
  void initState() {
    super.initState();
    _initializeAudio();
  }

  Future<void> _initializeAudio() async {
    await _audioHelper.initialize();
  }

  Future<void> _playAudio() async {
    try {
      await _audioHelper.playModuleAudio(
        moduleId: _moduleId,
        description: widget.description,
        podcastUrl: widget.podcastUrl,
      );
    } catch (e) {
      if (mounted) {
        String errorMessage = e.toString();
        if (errorMessage.contains('TTS not available')) {
          errorMessage =
              'Audio requires a podcast URL. Text-to-speech is not available on Windows.';
        }

        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(errorMessage),
            backgroundColor:
                widget.podcastUrl != null ? Colors.red : Colors.orange,
            duration: const Duration(seconds: 4),
          ),
        );
      }
    }
  }

  Future<void> _stopAudio() async {
    await _audioHelper.stop();
  }

  @override
  void dispose() {
    // Note: Don't dispose the AudioHelper here as it's a singleton
    // and might be used by other modules
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return MouseRegion(
      onEnter: (_) => setState(() => _isHovered = true),
      onExit: (_) => setState(() => _isHovered = false),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 300),
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: _isHovered ? Colors.blue.shade800 : Colors.blue.shade100,
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(
              color: Colors.black26,
              blurRadius: 6,
              offset: const Offset(2, 2),
            )
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              "${widget.index}. ${widget.title}",
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: _isHovered ? Colors.white : Colors.black87,
              ),
            ),
            const SizedBox(height: 12),
            Expanded(
              child: Text(
                widget.description,
                style: TextStyle(
                  fontSize: 14,
                  color: _isHovered ? Colors.white70 : Colors.black54,
                ),
              ),
            ),
            const SizedBox(height: 16),

            // Audio Controls Row
            Row(
              children: [
                // Listen Button
                Expanded(
                  child: StreamBuilder<AudioPlayerState>(
                    stream: _audioHelper.stateStream,
                    builder: (context, snapshot) {
                      final isPlayingThisModule =
                          _audioHelper.isPlayingModule(_moduleId);
                      final isLoadingThisModule =
                          _audioHelper.isLoadingModule(_moduleId);

                      return ElevatedButton.icon(
                        onPressed: (isPlayingThisModule || isLoadingThisModule)
                            ? null
                            : _playAudio,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.green,
                          padding: const EdgeInsets.symmetric(
                              horizontal: 16, vertical: 10),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(8),
                          ),
                        ),
                        icon: isLoadingThisModule
                            ? SizedBox(
                                width: 16,
                                height: 16,
                                child: CircularProgressIndicator(
                                  strokeWidth: 2,
                                  color: Colors.white,
                                ),
                              )
                            : Icon(
                                isPlayingThisModule
                                    ? Icons.volume_up
                                    : Icons.volume_up_outlined,
                                size: 18,
                              ),
                        label: Text(
                          isLoadingThisModule
                              ? "Loading..."
                              : isPlayingThisModule
                                  ? "Playing"
                                  : "🔊 Listen",
                          style: const TextStyle(fontSize: 12),
                        ),
                      );
                    },
                  ),
                ),

                const SizedBox(width: 8),

                // Stop Button
                StreamBuilder<AudioPlayerState>(
                  stream: _audioHelper.stateStream,
                  builder: (context, snapshot) {
                    final state = snapshot.data ?? AudioPlayerState.stopped;
                    final isActiveForThisModule =
                        _audioHelper.currentModuleId == _moduleId;
                    final canStop = isActiveForThisModule &&
                        (state == AudioPlayerState.playing ||
                            state == AudioPlayerState.loading);

                    return ElevatedButton.icon(
                      onPressed: canStop ? _stopAudio : null,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.red,
                        padding: const EdgeInsets.symmetric(
                            horizontal: 16, vertical: 10),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8),
                        ),
                      ),
                      icon: const Icon(Icons.stop, size: 18),
                      label:
                          const Text("⏹ Stop", style: TextStyle(fontSize: 12)),
                    );
                  },
                ),
              ],
            ),

            const SizedBox(height: 12),

            // Start Module Button
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: () async {
                  // Get learning style if available, otherwise use default
                  final learningStyle =
                      await ActivityService.getLearningStyle();

                  // Always use AIModuleContentScreen for comprehensive structured content
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => AIModuleContentScreen(
                        moduleTitle: widget.title,
                        moduleDescription: widget.description,
                        learningStyle: learningStyle ??
                            'Visual', // Default to Visual if no VARK completed
                        courseTitle: 'AI Generated Course',
                      ),
                    ),
                  );
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.blue,
                  padding:
                      const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                child:
                    const Text("Start Module", style: TextStyle(fontSize: 14)),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

/// ✅ Sample course modules (still works because dynamic is allowed)
final List<Map<String, dynamic>> modules = [
  {
    "title": "Foundations Of Data Structures",
    "description":
        "Understand the basic concepts and definitions of data structures. Learn about their importance in computer science and how they form the building blocks of efficient algorithms and software systems.",
    "podcastUrl":
        "https://www.soundjay.com/misc/bell-ringing-05.wav", // Example audio file
  },
  {
    "title": "Arrays And Linked Lists",
    "description":
        "Dive into the details of arrays and linked lists. Learn about their structures, operations, and use cases in real-world programming scenarios.",
    // No podcastUrl - will fallback to TTS
  },
  {
    "title": "Stacks And Queues",
    "description":
        "Explore the concepts of stacks and queues, including their structures and operations. Understand LIFO and FIFO principles and their practical applications.",
    "podcastUrl":
        "https://www.soundjay.com/misc/bell-ringing-05.wav", // Example audio file
  },
  {
    "title": "Trees And Binary Trees",
    "description":
        "Examine the structures and properties of trees, with a focus on binary trees..."
  },
  {
    "title": "Heaps And Priority Queues",
    "description":
        "Understand the concepts of heaps and priority queues, including their properties and operations..."
  },
  {
    "title": "Hash Tables",
    "description":
        "Delve into the workings of hash tables and their importance in ensuring fast data retrieval..."
  },
  {
    "title": "Graphs And Graph Algorithms",
    "description":
        "Learn about graph data structures and their representations. Understand various graph algorithms..."
  },
  {
    "title": "Advanced Data Structures",
    "description":
        "Explore advanced data structures such as AVL trees, B-trees, and red-black trees..."
  },
  {
    "title": "Practical Applications And Case Studies",
    "description":
        "Apply the knowledge gained throughout the course to real-world scenarios and case studies..."
  },
];

final List<Course> courses = [
  Course(
    title: "Data Structures",
    modules: [
      Module(
        title: "Introduction to DS",
        lessons: [
          Lesson(
            title: "1.1.1 Introduction",
            content: '''
Data structures are the backbone of computer science. They provide systematic ways of organizing, processing, retrieving, and storing data. 
A good understanding of data structures ensures that programs are efficient and scalable.

The importance of data structures lies in their ability to optimize algorithms. For example, searching for an element in an unsorted list can take O(n) time, 
while searching in a balanced binary search tree can be reduced to O(log n).

From operating systems to artificial intelligence, almost every domain in computing relies on the clever use of data structures.
''',
          ),
          Lesson(
            title: "1.1.2 Types of DS",
            content: '''
There are two broad categories of data structures: Primitive and Non-Primitive.

- **Primitive Data Structures**: These are the basic structures directly available in most programming languages. Examples include integers, floats, characters, and booleans.

- **Non-Primitive Data Structures**: These are more advanced and can be classified as:
  - **Linear Data Structures**: Arrays, Linked Lists, Stacks, Queues
  - **Non-Linear Data Structures**: Trees, Graphs
  - **Hash-based Data Structures**: Hash Tables

Each has unique strengths and limitations. Choosing the right one depends on the problem at hand.
''',
          ),
        ],
      ),
    ],
  ),
  Course(
    title: "Machine Learning",
    modules: [
      Module(
        title: "Introduction to ML",
        lessons: [
          Lesson(
            title: "1.1.1 What is ML?",
            content:
                "Machine Learning is a subset of AI that enables systems to learn patterns...",
          ),
          Lesson(
            title: "1.1.2 Types of ML",
            content:
                "Supervised, Unsupervised, Reinforcement Learning with examples...",
          ),
        ],
      ),
    ],
  ),
];
