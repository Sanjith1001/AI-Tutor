import 'package:flutter/material.dart';
import 'package:audioplayers/audioplayers.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:video_player/video_player.dart';
import 'package:http/http.dart' as http;
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'dart:convert';
import '../models/vark_model.dart';
import '../models/skill_assessment_model.dart';

class PersonalizedCourseScreen extends StatefulWidget {
  final VARKResult varkResult;
  final SkillAssessmentResult skillAssessmentResult;
  final Map<String, dynamic> selectedCourse;

  const PersonalizedCourseScreen({
    super.key,
    required this.varkResult,
    required this.skillAssessmentResult,
    required this.selectedCourse,
  });

  @override
  State<PersonalizedCourseScreen> createState() =>
      _PersonalizedCourseScreenState();
}

class _PersonalizedCourseScreenState extends State<PersonalizedCourseScreen> {
  int selectedModuleIndex = 0;
  bool showSimplified = false;
  final AudioPlayer audioPlayer = AudioPlayer();
  bool isPlayingAudio = false;
  VideoPlayerController? currentVideoController;
  bool videoLoaded = false;
  bool isVideoPlaying = false;

  // Podcast functionality
  bool isSpeaking = false;
  List<Map<String, dynamic>> availablePodcasts = [];
  bool podcastsLoaded = false;

  @override
  void initState() {
    super.initState();
    _initializeCurrentVideo();
    _loadPodcasts();
  }

  @override
  void dispose() {
    audioPlayer.dispose();
    currentVideoController?.dispose();
    super.dispose();
  }

  void _initializeCurrentVideo() {
    // Use a single reliable video for all modules
    const videoUrl =
        'https://commondatastorage.googleapis.com/gtv-videos-bucket/sample/BigBuckBunny.mp4';

    currentVideoController =
        VideoPlayerController.networkUrl(Uri.parse(videoUrl));

    currentVideoController!.initialize().then((_) {
      if (mounted) {
        setState(() {
          videoLoaded = true;
        });
      }
    }).catchError((error) {
      print('Video initialization error: $error');
    });
  }

  void _toggleVideoPlayback() {
    if (currentVideoController == null || !videoLoaded) return;

    if (mounted) {
      if (isVideoPlaying) {
        currentVideoController!.pause();
        setState(() {
          isVideoPlaying = false;
        });
      } else {
        currentVideoController!.play();
        setState(() {
          isVideoPlaying = true;
        });
      }
    }
  }

  void _replayVideo() {
    if (currentVideoController == null || !videoLoaded) return;

    if (mounted) {
      currentVideoController!.seekTo(Duration.zero);
      if (!isVideoPlaying) {
        currentVideoController!.play();
        setState(() {
          isVideoPlaying = true;
        });
      }
    }
  }

  void _loadPodcasts() async {
    setState(() {
      podcastsLoaded = false;
      availablePodcasts = [];
    });

    final currentModule =
        courseModules.isNotEmpty ? courseModules[selectedModuleIndex] : null;
    if (currentModule == null) return;

    try {
      final podcasts =
          await _fetchPodcastsFromListenNotes(currentModule['title']);

      if (mounted) {
        setState(() {
          availablePodcasts = podcasts;
          podcastsLoaded = true;
        });
      }
    } catch (e) {
      print('Error loading podcasts: $e');
      if (mounted) {
        setState(() {
          availablePodcasts = [];
          podcastsLoaded = true;
        });
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error loading podcasts: ${e.toString()}')),
        );
      }
    }
  }

  Future<List<Map<String, dynamic>>> _fetchPodcastsFromListenNotes(
      String topic) async {
    final apiKey = dotenv.env['LISTEN_NOTES_API_KEY'];

    if (apiKey == null || apiKey.isEmpty) {
      print('Listen Notes API key not found');
      return [];
    }

    // Simple search query for educational content
    String searchQuery = '$topic education tutorial lesson';

    final url = Uri.parse('https://listen-api.listennotes.com/api/v2/search');

    try {
      final response = await http.get(
        url.replace(queryParameters: {
          'q': searchQuery,
          'type': 'episode',
          'len_min': '10',
          'len_max': '60',
          'language': 'English',
          'safe_mode': '1',
          'sort_by_date': '0',
        }),
        headers: {
          'X-ListenAPI-Key': apiKey,
          'Content-Type': 'application/json',
        },
      );

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        final results = data['results'] as List<dynamic>? ?? [];

        return results.take(5).map((episode) {
          return {
            'title': episode['title_original'] ?? 'Unknown Title',
            'duration': _formatDuration(episode['audio_length_sec'] ?? 0),
            'description': (episode['description_original'] ??
                    'No description available')
                .toString()
                .replaceAll(RegExp(r'<[^>]*>'), '')
                .substring(
                    0,
                    (episode['description_original']?.toString().length ?? 0) >
                            150
                        ? 150
                        : (episode['description_original']?.toString().length ??
                            0)),
            'url': episode['audio'] ?? '',
            'podcast_title': episode['podcast']['title_original'] ?? '',
            'thumbnail':
                episode['thumbnail'] ?? episode['podcast']['thumbnail'] ?? '',
            'pub_date': episode['pub_date_ms'] != null
                ? DateTime.fromMillisecondsSinceEpoch(episode['pub_date_ms'])
                    .toString()
                    .split(' ')[0]
                : '',
          };
        }).toList();
      } else {
        print('Listen Notes API error: ${response.statusCode}');
        return [];
      }
    } catch (e) {
      print('Error fetching podcasts: $e');
      return [];
    }
  }

  String _getSearchQueryForTopic(String topic) {
    // Map course topics to better educational search queries
    switch (topic.toLowerCase()) {
      case 'basic arithmetic':
        return 'math education elementary arithmetic tutorial lesson teaching';
      case 'fractions and decimals':
        return 'fractions decimals math education tutorial elementary teaching';
      case 'algebra basics':
        return 'algebra education tutorial math lesson teaching basics';
      case 'calculus introduction':
        return 'calculus education tutorial math lesson derivatives teaching';
      case 'introduction to programming':
        return 'programming education tutorial coding lesson computer science teaching';
      case 'motion and forces':
        return 'physics education tutorial science lesson teaching motion forces';
      default:
        return '$topic education tutorial lesson teaching learning';
    }
  }

  String _formatDuration(int seconds) {
    if (seconds <= 0) return 'Unknown';

    final minutes = seconds ~/ 60;
    if (minutes < 60) {
      return '${minutes} min';
    } else {
      final hours = minutes ~/ 60;
      final remainingMinutes = minutes % 60;
      return '${hours}h ${remainingMinutes}m';
    }
  }

  void _speakContent(String content) async {
    if (isSpeaking) {
      setState(() {
        isSpeaking = false;
      });
      // Show message that TTS stopped
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Stopped reading')),
      );
    } else {
      setState(() {
        isSpeaking = true;
      });

      // Simulate reading for demo purposes
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
            content:
                Text('Text-to-speech feature would read the content aloud')),
      );

      // Auto-stop after 3 seconds for demo
      Future.delayed(const Duration(seconds: 3), () {
        if (mounted) {
          setState(() {
            isSpeaking = false;
          });
        }
      });
    }
  }

  // Sample course modules based on skill level
  List<Map<String, dynamic>> get courseModules {
    final level = widget.skillAssessmentResult.skillLevel;
    final course = widget.selectedCourse['title'];

    switch (course) {
      case 'Mathematics':
        return _getMathModules(level);
      case 'Computer Science':
        return _getComputerScienceModules(level);
      case 'Physics':
        return _getPhysicsModules(level);
      default:
        return _getGeneralModules(level);
    }
  }

  List<Map<String, dynamic>> _getMathModules(String level) {
    if (level == 'Beginner') {
      return [
        {
          'title': 'Basic Arithmetic',
          'content':
              'Arithmetic is the foundation of mathematics. It involves basic operations like addition, subtraction, multiplication, and division.\n\nAddition combines numbers to get a sum. For example: 5 + 3 = 8\nSubtraction finds the difference between numbers. For example: 8 - 3 = 5\nMultiplication is repeated addition. For example: 4 × 3 = 12 (adding 4 three times)\nDivision splits numbers into equal parts. For example: 12 ÷ 3 = 4',
          'simplified':
              'Basic math operations: +, -, ×, ÷\n• Addition: combining numbers\n• Subtraction: taking away\n• Multiplication: repeated addition\n• Division: splitting into equal parts',
          'examples': ['5 + 7 = 12', '15 - 6 = 9', '8 × 4 = 32', '20 ÷ 5 = 4'],
          'videoKeywords': 'basic arithmetic operations elementary math',
          'videoIndex': 0,
        },
        {
          'title': 'Fractions and Decimals',
          'content':
              'Fractions represent parts of a whole. A fraction has a numerator (top number) and denominator (bottom number).\n\nFor example, 1/2 means one part out of two equal parts.\nDecimals are another way to represent fractions. 0.5 is the same as 1/2.\n\nTo add fractions with the same denominator, add the numerators: 1/4 + 2/4 = 3/4\nTo convert fractions to decimals, divide the numerator by the denominator.',
          'simplified':
              'Fractions = parts of a whole\n• 1/2 = 0.5 (half)\n• 1/4 = 0.25 (quarter)\n• Add fractions: same bottom number, add top numbers\n• Convert: divide top by bottom',
          'examples': [
            '1/2 + 1/4 = 2/4 + 1/4 = 3/4',
            '3/4 = 0.75',
            '0.25 = 1/4'
          ],
          'videoKeywords': 'fractions decimals elementary math',
          'videoIndex': 1,
        }
      ];
    } else if (level == 'Intermediate') {
      return [
        {
          'title': 'Algebra Basics',
          'content':
              'Algebra uses letters (variables) to represent unknown numbers. The most common variable is x.\n\nSolving equations means finding the value of the variable that makes the equation true.\n\nFor example: x + 5 = 12\nTo solve this, subtract 5 from both sides: x = 12 - 5 = 7\n\nBasic rules:\n• What you do to one side, do to the other\n• Opposite operations cancel out (+ and -, × and ÷)',
          'simplified':
              'Algebra uses letters for unknown numbers\n• x + 5 = 12, so x = 7\n• Same operation on both sides\n• Opposite operations cancel',
          'examples': [
            '2x = 10, so x = 5',
            'x - 3 = 7, so x = 10',
            '3x + 2 = 14, so x = 4'
          ],
          'videoKeywords': 'basic algebra solving equations',
          'videoIndex': 2,
        }
      ];
    } else {
      return [
        {
          'title': 'Calculus Introduction',
          'content':
              'Calculus is the study of change and motion. It has two main branches: differential calculus (derivatives) and integral calculus (integrals).\n\nDerivatives measure the rate of change. If you have a function f(x), its derivative f\'(x) tells you how fast f(x) is changing at any point.\n\nFor example, the derivative of x² is 2x. This means at x = 3, the function x² is changing at a rate of 2(3) = 6.',
          'simplified':
              'Calculus studies change\n• Derivatives = rate of change\n• d/dx(x²) = 2x\n• At x = 3, rate = 6',
          'examples': [
            'd/dx(x³) = 3x²',
            'd/dx(5x) = 5',
            'd/dx(x² + 3x) = 2x + 3'
          ],
          'videoKeywords': 'calculus derivatives introduction',
          'videoIndex': 3,
        }
      ];
    }
  }

  List<Map<String, dynamic>> _getComputerScienceModules(String level) {
    if (level == 'Beginner') {
      return [
        {
          'title': 'Introduction to Programming',
          'content':
              'Programming is giving instructions to a computer. We write code in programming languages like Python, Java, or JavaScript.\n\nA program is a set of instructions that tells the computer what to do. These instructions are executed step by step.\n\nBasic concepts:\n• Variables: store data (like x = 5)\n• Functions: reusable blocks of code\n• Loops: repeat actions\n• Conditions: make decisions (if/else)',
          'simplified':
              'Programming = giving instructions to computers\n• Variables store data\n• Functions are reusable code\n• Loops repeat actions\n• If/else makes decisions',
          'examples': [
            'x = 10 (variable)',
            'print("Hello") (function)',
            'for i in range(5): (loop)',
            'if x > 5: (condition)'
          ],
          'videoKeywords': 'programming basics introduction variables',
          'videoIndex': 4,
        }
      ];
    }
    return [];
  }

  List<Map<String, dynamic>> _getPhysicsModules(String level) {
    if (level == 'Beginner') {
      return [
        {
          'title': 'Motion and Forces',
          'content':
              'Motion is when objects change position over time. Force is a push or pull that can change an object\'s motion.\n\nNewton\'s First Law: An object at rest stays at rest, and an object in motion stays in motion, unless acted upon by a force.\n\nSpeed = Distance ÷ Time\nFor example, if you travel 100 meters in 10 seconds, your speed is 10 m/s.',
          'simplified':
              'Motion = changing position\nForce = push or pull\nSpeed = Distance ÷ Time\nObjects keep doing what they\'re doing unless forced to change',
          'examples': [
            'Car traveling 60 km in 1 hour = 60 km/h',
            'Ball rolling until friction stops it',
            'Pushing a box to make it move'
          ],
          'videoKeywords': 'physics motion forces Newton laws',
          'videoIndex': 5,
        }
      ];
    }
    return [];
  }

  List<Map<String, dynamic>> _getGeneralModules(String level) {
    return [
      {
        'title': 'Getting Started',
        'content':
            'Welcome to your personalized learning journey! This course is tailored to your learning style and skill level.',
        'simplified': 'Welcome! This course is made just for you.',
        'examples': ['Personalized content', 'Your pace', 'Your style'],
        'videoKeywords': 'introduction getting started',
        'videoIndex': 0,
      }
    ];
  }

  String _getPersonalizedContent(Map<String, dynamic> module) {
    final learningStyle = widget.varkResult.dominantStyle;
    String content = showSimplified ? module['simplified'] : module['content'];

    // Add learning style specific suggestions
    switch (learningStyle) {
      case 'Visual':
        content +=
            '\n\n📊 Visual Learning Tips:\n• Draw diagrams and charts\n• Use colors to highlight key points\n• Create mind maps\n• Watch the recommended videos below';
        break;
      case 'Auditory':
        content +=
            '\n\n🎧 Auditory Learning Tips:\n• Read the content aloud\n• Discuss with others\n• Listen to related podcasts\n• Use text-to-speech features';
        break;
      case 'Reading/Writing':
        content +=
            '\n\n📝 Reading/Writing Tips:\n• Take detailed notes\n• Rewrite key concepts\n• Create summaries\n• Practice with written exercises';
        break;
      case 'Kinesthetic':
        content +=
            '\n\n🤲 Kinesthetic Learning Tips:\n• Practice with hands-on activities\n• Use physical objects when possible\n• Take breaks to move around\n• Apply concepts in real situations';
        break;
    }

    return content;
  }

  @override
  Widget build(BuildContext context) {
    final currentModule =
        courseModules.isNotEmpty ? courseModules[selectedModuleIndex] : null;

    return Scaffold(
      backgroundColor: Colors.grey.shade50,
      appBar: AppBar(
        title: Text(widget.selectedCourse['title']),
        backgroundColor: widget.selectedCourse['color'],
        foregroundColor: Colors.white,
        elevation: 0,
        actions: [
          IconButton(
            icon: const Icon(Icons.dashboard),
            onPressed: () {
              if (mounted) {
                // Navigate to dashboard
              }
            },
          ),
        ],
      ),
      body: courseModules.isEmpty
          ? _buildEmptyState()
          : Row(
              children: [
                // Module list sidebar
                Container(
                  width: 300,
                  color: Colors.white,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // User info header
                      Container(
                        width: double.infinity,
                        padding: const EdgeInsets.all(20),
                        decoration: BoxDecoration(
                          color: widget.selectedCourse['color']
                              .withValues(alpha: 0.1),
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Learning Style: ${widget.varkResult.dominantStyle}',
                              style: TextStyle(
                                fontSize: 14,
                                fontWeight: FontWeight.bold,
                                color: widget.selectedCourse['color'],
                              ),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              'Level: ${widget.skillAssessmentResult.skillLevel}',
                              style: TextStyle(
                                fontSize: 14,
                                color: Colors.grey.shade600,
                              ),
                            ),
                          ],
                        ),
                      ),

                      // Modules list
                      Expanded(
                        child: ListView.builder(
                          itemCount: courseModules.length,
                          itemBuilder: (context, index) {
                            final module = courseModules[index];
                            final isSelected = index == selectedModuleIndex;

                            return Container(
                              margin: const EdgeInsets.symmetric(
                                  horizontal: 12, vertical: 4),
                              child: InkWell(
                                onTap: () {
                                  if (mounted) {
                                    setState(() {
                                      selectedModuleIndex = index;
                                    });
                                    _loadPodcasts(); // Reload podcasts for new module
                                  }
                                },
                                borderRadius: BorderRadius.circular(8),
                                child: Container(
                                  padding: const EdgeInsets.all(16),
                                  decoration: BoxDecoration(
                                    color: isSelected
                                        ? widget.selectedCourse['color']
                                            .withValues(alpha: 0.1)
                                        : null,
                                    borderRadius: BorderRadius.circular(8),
                                    border: isSelected
                                        ? Border.all(
                                            color:
                                                widget.selectedCourse['color'])
                                        : null,
                                  ),
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        '${index + 1}. ${module['title']}',
                                        style: TextStyle(
                                          fontSize: 16,
                                          fontWeight: FontWeight.bold,
                                          color: isSelected
                                              ? widget.selectedCourse['color']
                                              : Colors.black87,
                                        ),
                                      ),
                                      if (isSelected) ...[
                                        const SizedBox(height: 8),
                                        LinearProgressIndicator(
                                          value:
                                              0.3, // This would come from user progress
                                          backgroundColor: Colors.grey.shade300,
                                          valueColor: AlwaysStoppedAnimation<
                                                  Color>(
                                              widget.selectedCourse['color']),
                                        ),
                                        const SizedBox(height: 4),
                                        Text(
                                          '30% Complete',
                                          style: TextStyle(
                                            fontSize: 12,
                                            color: Colors.grey.shade600,
                                          ),
                                        ),
                                      ],
                                    ],
                                  ),
                                ),
                              ),
                            );
                          },
                        ),
                      ),
                    ],
                  ),
                ),

                // Main content area
                Expanded(
                  child: currentModule != null
                      ? _buildContentArea(currentModule)
                      : _buildEmptyState(),
                ),
              ],
            ),
    );
  }

  Widget _buildContentArea(Map<String, dynamic> module) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Module header
          Row(
            children: [
              Expanded(
                child: Text(
                  module['title'],
                  style: const TextStyle(
                    fontSize: 28,
                    fontWeight: FontWeight.bold,
                    color: Colors.black87,
                  ),
                ),
              ),
              // Toggle simplified view
              Row(
                children: [
                  Text(
                    'Simplified',
                    style: TextStyle(
                      fontSize: 14,
                      color: Colors.grey.shade600,
                    ),
                  ),
                  const SizedBox(width: 8),
                  Switch(
                    value: showSimplified,
                    onChanged: (value) {
                      if (mounted) {
                        setState(() {
                          showSimplified = value;
                        });
                      }
                    },
                    activeThumbColor: widget.selectedCourse['color'],
                  ),
                ],
              ),
            ],
          ),

          const SizedBox(height: 24),

          // Main content
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(24),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(12),
              boxShadow: [
                BoxShadow(
                  color: Colors.grey.withValues(alpha: 0.1),
                  blurRadius: 10,
                  offset: const Offset(0, 2),
                ),
              ],
            ),
            child: Text(
              _getPersonalizedContent(module),
              style: const TextStyle(
                fontSize: 16,
                height: 1.6,
                color: Colors.black87,
              ),
            ),
          ),

          const SizedBox(height: 24),

          // Examples section
          if (module['examples'] != null && module['examples'].isNotEmpty)
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: Colors.blue.shade50,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: Colors.blue.shade200),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Icon(Icons.lightbulb_outline,
                          color: Colors.blue.shade600),
                      const SizedBox(width: 8),
                      Text(
                        'Examples',
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          color: Colors.blue.shade800,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  ...module['examples']
                      .map<Widget>((example) => Padding(
                            padding: const EdgeInsets.only(bottom: 8),
                            child: Row(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text('• ',
                                    style: TextStyle(
                                        color: Colors.blue.shade600,
                                        fontSize: 16)),
                                Expanded(
                                  child: Text(
                                    example,
                                    style: TextStyle(
                                      fontSize: 16,
                                      color: Colors.blue.shade700,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ))
                      .toList(),
                ],
              ),
            ),

          const SizedBox(height: 24),

          // Videos section
          _buildVideoSection(module),

          const SizedBox(height: 24),

          // Quiz button
          Center(
            child: ElevatedButton.icon(
              onPressed: () {
                if (mounted) {
                  // Navigate to quiz for this module
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('Quiz feature coming soon!')),
                  );
                }
              },
              icon: const Icon(Icons.quiz),
              label: const Text('Take Quiz'),
              style: ElevatedButton.styleFrom(
                backgroundColor: widget.selectedCourse['color'],
                foregroundColor: Colors.white,
                padding:
                    const EdgeInsets.symmetric(horizontal: 32, vertical: 16),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildVideoSection(Map<String, dynamic> module) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.red.shade50,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.red.shade200),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(Icons.play_circle_outline, color: Colors.red.shade600),
              const SizedBox(width: 8),
              Text(
                'Educational Video',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: Colors.red.shade800,
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),

          // Simple video player
          Container(
            height: 200,
            width: double.infinity,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(8),
              color: Colors.black,
            ),
            child: ClipRRect(
              borderRadius: BorderRadius.circular(8),
              child: currentVideoController != null && videoLoaded
                  ? AspectRatio(
                      aspectRatio: currentVideoController!.value.aspectRatio,
                      child: VideoPlayer(currentVideoController!),
                    )
                  : Container(
                      color: Colors.grey.shade800,
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          if (!videoLoaded) ...[
                            const CircularProgressIndicator(
                                color: Colors.white),
                            const SizedBox(height: 16),
                            const Text(
                              'Loading video...',
                              style: TextStyle(color: Colors.white),
                            ),
                          ] else ...[
                            Icon(
                              Icons.video_library,
                              size: 48,
                              color: Colors.grey.shade400,
                            ),
                            const SizedBox(height: 8),
                            Text(
                              module['title'],
                              style: const TextStyle(
                                color: Colors.white,
                                fontSize: 16,
                              ),
                              textAlign: TextAlign.center,
                            ),
                          ],
                        ],
                      ),
                    ),
            ),
          ),

          const SizedBox(height: 16),

          // Simple video controls
          if (currentVideoController != null && videoLoaded) ...[
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                IconButton(
                  onPressed: _toggleVideoPlayback,
                  icon: Icon(
                    isVideoPlaying
                        ? Icons.pause_circle_filled
                        : Icons.play_circle_filled,
                    size: 48,
                    color: Colors.red.shade600,
                  ),
                ),
                const SizedBox(width: 16),
                IconButton(
                  onPressed: _replayVideo,
                  icon: Icon(
                    Icons.replay,
                    size: 32,
                    color: Colors.red.shade600,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
          ],

          // Podcast and Audio Section
          _buildPodcastSection(module),

          const SizedBox(height: 12),

          // Debug section for API testing
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: Colors.grey.shade100,
              borderRadius: BorderRadius.circular(8),
              border: Border.all(color: Colors.grey.shade300),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Debug Info:',
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.bold,
                    color: Colors.grey.shade700,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  'API Key: ${dotenv.env['LISTEN_NOTES_API_KEY'] != null ? 'Loaded ✓' : 'Missing ✗'}',
                  style: TextStyle(fontSize: 12, color: Colors.grey.shade600),
                ),
                Text(
                  'Module: ${module['title']}',
                  style: TextStyle(fontSize: 12, color: Colors.grey.shade600),
                ),
                Text(
                  'Podcasts Loaded: ${podcastsLoaded ? 'Yes' : 'Loading...'}',
                  style: TextStyle(fontSize: 12, color: Colors.grey.shade600),
                ),
                Text(
                  'Podcasts Found: ${availablePodcasts.length}',
                  style: TextStyle(fontSize: 12, color: Colors.grey.shade600),
                ),
                const SizedBox(height: 8),
                ElevatedButton(
                  onPressed: () async {
                    print('=== MANUAL API TEST ===');
                    final testPodcasts =
                        await _fetchPodcastsFromListenNotes('math education');
                    print('Test result: ${testPodcasts.length} podcasts found');
                    if (mounted) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                            content: Text(
                                'Test: ${testPodcasts.length} podcasts found')),
                      );
                    }
                  },
                  child: const Text('Test API'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.blue.shade600,
                    foregroundColor: Colors.white,
                  ),
                ),
              ],
            ),
          ),

          const SizedBox(height: 12),
          Text(
            'Topic: ${module['videoKeywords']}',
            style: TextStyle(
              fontSize: 14,
              color: Colors.red.shade700,
              fontStyle: FontStyle.italic,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPodcastSection(Map<String, dynamic> module) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            Colors.purple.shade50,
            Colors.blue.shade50,
          ],
        ),
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withValues(alpha: 0.1),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: Colors.purple.shade100,
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Icon(Icons.podcasts, color: Colors.purple.shade600, size: 24),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Educational Podcasts',
                      style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                        color: Colors.purple.shade800,
                      ),
                    ),
                    Text(
                      'Listen and learn on the go',
                      style: TextStyle(
                        fontSize: 14,
                        color: Colors.grey.shade600,
                      ),
                    ),
                  ],
                ),
              ),
              IconButton(
                onPressed: () {
                  if (mounted) {
                    _loadPodcasts();
                  }
                },
                icon: Icon(Icons.refresh, color: Colors.purple.shade600),
                tooltip: 'Refresh podcasts',
              ),
            ],
          ),
          const SizedBox(height: 20),

          // Loading State
          if (!podcastsLoaded) ...[
            Container(
              height: 120,
              decoration: BoxDecoration(
                color: Colors.white.withValues(alpha: 0.7),
                borderRadius: BorderRadius.circular(12),
              ),
              child: const Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    CircularProgressIndicator(),
                    SizedBox(height: 12),
                    Text(
                      'Finding educational podcasts...',
                      style: TextStyle(fontSize: 16, fontWeight: FontWeight.w500),
                    ),
                  ],
                ),
              ),
            ),
          ] 
          // Podcasts Found
          else if (availablePodcasts.isNotEmpty) ...[
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
              decoration: BoxDecoration(
                color: Colors.green.shade100,
                borderRadius: BorderRadius.circular(20),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(Icons.check_circle, color: Colors.green.shade600, size: 16),
                  const SizedBox(width: 6),
                  Text(
                    '${availablePodcasts.length} podcasts found',
                    style: TextStyle(
                      fontSize: 14,
                      color: Colors.green.shade700,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 16),

            // Podcast Cards
            ...availablePodcasts.map((podcast) {
              return Container(
                margin: const EdgeInsets.only(bottom: 16),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(16),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.grey.withValues(alpha: 0.15),
                      blurRadius: 8,
                      offset: const Offset(0, 4),
                    ),
                  ],
                ),
                child: InkWell(
                  onTap: () async {
                    if (mounted && podcast['url'] != null && podcast['url'].isNotEmpty) {
                      if (await canLaunchUrl(Uri.parse(podcast['url']))) {
                        await launchUrl(Uri.parse(podcast['url']));
                      } else {
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(content: Text('Could not open podcast')),
                        );
                      }
                    }
                  },
                  borderRadius: BorderRadius.circular(16),
                  child: Padding(
                    padding: const EdgeInsets.all(20),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // Header Row
                        Row(
                          children: [
                            Container(
                              padding: const EdgeInsets.all(8),
                              decoration: BoxDecoration(
                                color: Colors.purple.shade100,
                                borderRadius: BorderRadius.circular(8),
                              ),
                              child: Icon(
                                Icons.play_arrow,
                                color: Colors.purple.shade600,
                                size: 20,
                              ),
                            ),
                            const SizedBox(width: 12),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    podcast['title'],
                                    style: TextStyle(
                                      fontSize: 16,
                                      fontWeight: FontWeight.bold,
                                      color: Colors.grey.shade800,
                                    ),
                                    maxLines: 2,
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                  if (podcast['podcast_title'] != null && podcast['podcast_title'].isNotEmpty)
                                    Text(
                                      podcast['podcast_title'],
                                      style: TextStyle(
                                        fontSize: 14,
                                        color: Colors.blue.shade600,
                                        fontWeight: FontWeight.w500,
                                      ),
                                    ),
                                ],
                              ),
                            ),
                            Container(
                              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                              decoration: BoxDecoration(
                                color: Colors.orange.shade100,
                                borderRadius: BorderRadius.circular(12),
                              ),
                              child: Text(
                                podcast['duration'],
                                style: TextStyle(
                                  fontSize: 12,
                                  fontWeight: FontWeight.bold,
                                  color: Colors.orange.shade700,
                                ),
                              ),
                            ),
                          ],
                        ),
                        
                        const SizedBox(height: 12),
                        
                        // Description
                        Text(
                          podcast['description'],
                          style: TextStyle(
                            fontSize: 14,
                            color: Colors.grey.shade600,
                            height: 1.4,
                          ),
                          maxLines: 3,
                          overflow: TextOverflow.ellipsis,
                        ),
                        
                        const SizedBox(height: 16),
                        
                        // Action Row
                        Row(
                          children: [
                            Icon(
                              Icons.touch_app,
                              size: 16,
                              color: Colors.purple.shade400,
                            ),
                            const SizedBox(width: 6),
                            Text(
                              'Tap to listen',
                              style: TextStyle(
                                fontSize: 13,
                                color: Colors.purple.shade600,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                            const Spacer(),
                            if (podcast['pub_date'] != null && podcast['pub_date'].isNotEmpty)
                              Text(
                                podcast['pub_date'],
                                style: TextStyle(
                                  fontSize: 12,
                                  color: Colors.grey.shade500,
                                ),
                              ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ),
              );
            }).toList(),
          ] 
          // No Podcasts Found
          else ...[
            Container(
              padding: const EdgeInsets.all(24),
              decoration: BoxDecoration(
                color: Colors.white.withValues(alpha: 0.7),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: Colors.grey.shade200),
              ),
              child: Column(
                children: [
                  Icon(
                    Icons.search_off,
                    size: 48,
                    color: Colors.grey.shade400,
                  ),
                  const SizedBox(height: 12),
                  Text(
                    'No podcasts found for this topic',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                      color: Colors.grey.shade600,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Try refreshing or explore other learning materials',
                    style: TextStyle(
                      fontSize: 14,
                      color: Colors.grey.shade500,
                    ),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 16),
                  ElevatedButton.icon(
                    onPressed: () {
                      final content = showSimplified ? module['simplified'] : module['content'];
                      _speakContent(content);
                    },
                    icon: Icon(isSpeaking ? Icons.stop : Icons.record_voice_over),
                    label: Text(isSpeaking ? 'Stop Reading' : 'Read Content Aloud'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.blue.shade600,
                      foregroundColor: Colors.white,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ],
      ),
    );
  }
      child: Column(
        crossAxisAlignment = CrossAxisAlignment.start,
        children = [
          // Header
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: Colors.purple.shade100,
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Icon(Icons.podcasts,
                    color: Colors.purple.shade600, size: 24),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Educational Podcasts',
                      style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                        color: Colors.purple.shade800,
                      ),
                    ),
                    Text(
                      'Listen and learn on the go',
                      style: TextStyle(
                        fontSize: 14,
                        color: Colors.grey.shade600,
                      ),
                    ),
                  ],
                ),
              ),
              IconButton(
                onPressed: () {
                  if (mounted) {
                    _loadPodcasts();
                  }
                },
                icon: Icon(Icons.refresh, color: Colors.purple.shade600),
                tooltip: 'Refresh podcasts',
              ),
            ],
          ),
          const SizedBox(height: 20),

          // Loading State
          if (!podcastsLoaded) ...[
            Container(
              height: 120,
              decoration: BoxDecoration(
                color: Colors.white.withValues(alpha: 0.7),
                borderRadius: BorderRadius.circular(12),
              ),
              child: const Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    CircularProgressIndicator(),
                    SizedBox(height: 12),
                    Text(
                      'Finding educational podcasts...',
                      style:
                          TextStyle(fontSize: 16, fontWeight: FontWeight.w500),
                    ),
                  ],
                ),
              ),
            ),
          ]
          // Podcasts Found
          else if (availablePodcasts.isNotEmpty) ...[
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
              decoration: BoxDecoration(
                color: Colors.green.shade100,
                borderRadius: BorderRadius.circular(20),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(Icons.check_circle,
                      color: Colors.green.shade600, size: 16),
                  const SizedBox(width: 6),
                  Text(
                    '${availablePodcasts.length} podcasts found',
                    style: TextStyle(
                      fontSize: 14,
                      color: Colors.green.shade700,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 16),
            // Show available podcasts
            Row(
              children: [
                Text(
                  'Available Podcasts:',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: Colors.orange.shade800,
                  ),
                ),
                const SizedBox(width: 8),
                Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                  decoration: BoxDecoration(
                    color: Colors.green.shade100,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Text(
                    '${availablePodcasts.length} found',
                    style: TextStyle(
                      fontSize: 12,
                      color: Colors.green.shade700,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            // Podcast Cards
            ...availablePodcasts.asMap().entries.map((entry) {
              final index = entry.key;
              final podcast = entry.value;
              
              return Container(
                margin: const EdgeInsets.only(bottom: 16),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(16),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.grey.withValues(alpha: 0.15),
                      blurRadius: 8,
                      offset: const Offset(0, 4),
                    ),
                  ],
                ),
                child: InkWell(
                  onTap: () async {
                    if (mounted && podcast['url'] != null && podcast['url'].isNotEmpty) {
                      if (await canLaunchUrl(Uri.parse(podcast['url']))) {
                        await launchUrl(Uri.parse(podcast['url']));
                      } else {
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(content: Text('Could not open podcast')),
                        );
                      }
                    }
                  },
                  borderRadius: BorderRadius.circular(16),
                  child: Padding(
                    padding: const EdgeInsets.all(20),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // Header Row
                        Row(
                          children: [
                            Container(
                              padding: const EdgeInsets.all(8),
                              decoration: BoxDecoration(
                                color: Colors.purple.shade100,
                                borderRadius: BorderRadius.circular(8),
                              ),
                              child: Icon(
                                Icons.play_arrow,
                                color: Colors.purple.shade600,
                                size: 20,
                              ),
                            ),
                            const SizedBox(width: 12),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    podcast['title'],
                                    style: TextStyle(
                                      fontSize: 16,
                                      fontWeight: FontWeight.bold,
                                      color: Colors.grey.shade800,
                                    ),
                                    maxLines: 2,
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                  if (podcast['podcast_title'] != null && podcast['podcast_title'].isNotEmpty)
                                    Text(
                                      podcast['podcast_title'],
                                      style: TextStyle(
                                        fontSize: 14,
                                        color: Colors.blue.shade600,
                                        fontWeight: FontWeight.w500,
                                      ),
                                    ),
                                ],
                              ),
                            ),
                            Container(
                              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                              decoration: BoxDecoration(
                                color: Colors.orange.shade100,
                                borderRadius: BorderRadius.circular(12),
                              ),
                              child: Text(
                                podcast['duration'],
                                style: TextStyle(
                                  fontSize: 12,
                                  fontWeight: FontWeight.bold,
                                  color: Colors.orange.shade700,
                                ),
                              ),
                            ),
                          ],
                        ),
                        
                        const SizedBox(height: 12),
                        
                        // Description
                        Text(
                          podcast['description'],
                          style: TextStyle(
                            fontSize: 14,
                            color: Colors.grey.shade600,
                            height: 1.4,
                          ),
                          maxLines: 3,
                          overflow: TextOverflow.ellipsis,
                        ),
                        
                        const SizedBox(height: 16),
                        
                        // Action Row
                        Row(
                          children: [
                            Icon(
                              Icons.touch_app,
                              size: 16,
                              color: Colors.purple.shade400,
                            ),
                            const SizedBox(width: 6),
                            Text(
                              'Tap to listen',
                              style: TextStyle(
                                fontSize: 13,
                                color: Colors.purple.shade600,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                            const Spacer(),
                            if (podcast['pub_date'] != null && podcast['pub_date'].isNotEmpty)
                              Text(
                                podcast['pub_date'],
                                style: TextStyle(
                                  fontSize: 12,
                                  color: Colors.grey.shade500,
                                ),
                              ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ),
              );
            }).toList(),
          ] 
          // No Podcasts Found
          else ...[
            Container(
              padding: const EdgeInsets.all(24),
              decoration: BoxDecoration(
                color: Colors.white.withValues(alpha: 0.7),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: Colors.grey.shade200),
              ),
              child: Column(
                children: [
                  Icon(
                    Icons.search_off,
                    size: 48,
                    color: Colors.grey.shade400,
                  ),
                  const SizedBox(height: 12),
                  Text(
                    'No podcasts found for this topic',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                      color: Colors.grey.shade600,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Try refreshing or explore other learning materials',
                    style: TextStyle(
                      fontSize: 14,
                      color: Colors.grey.shade500,
                    ),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 16),
                  ElevatedButton.icon(
                    onPressed: () {
                      final content = showSimplified ? module['simplified'] : module['content'];
                      _speakContent(content);
                    },
                    icon: Icon(isSpeaking ? Icons.stop : Icons.record_voice_over),
                    label: Text(isSpeaking ? 'Stop Reading' : 'Read Content Aloud'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.blue.shade600,
                      foregroundColor: Colors.white,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                  ),
                ],
              ),
            ),
                            ),
                            if (podcast['podcast_title'] != null &&
                                podcast['podcast_title'].isNotEmpty) ...[
                              const SizedBox(height = 4),
                              Text(
                                'From: ${podcast['podcast_title']}',
                                style: TextStyle(
                                  fontSize: 11,
                                  fontWeight: FontWeight.w500,
                                  color: Colors.blue.shade600,
                                ),
                              ),
                            ],
                            const SizedBox(height = 6),
                            Text(
                              podcast['description'],
                              style: TextStyle(
                                fontSize: 12,
                                color: Colors.grey.shade700,
                              ),
                              maxLines: 3,
                              overflow: TextOverflow.ellipsis,
                            ),
                            const SizedBox(height = 8),
                            Row(
                              children = [
                                Icon(Icons.tap_and_play,
                                    size: 14, color: Colors.grey.shade500),
                                const SizedBox(width: 4),
                                Text(
                                  'Tap to listen',
                                  style: TextStyle(
                                    fontSize: 11,
                                    color: Colors.grey.shade500,
                                    fontStyle: FontStyle.italic,
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                    ))
                .toList(),
          ] else ...[
            // No podcasts available - offer text-to-speech
            Container(
              padding = const EdgeInsets.all(16),
              decoration = BoxDecoration(
                color: Colors.grey.shade100,
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: Colors.grey.shade300),
              ),
              child = Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Icon(Icons.info_outline, color: Colors.grey.shade600),
                      const SizedBox(width: 8),
                      Text(
                        'No podcasts available for this topic',
                        style: TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.bold,
                          color: Colors.grey.shade700,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Would you like me to read the content aloud?',
                    style: TextStyle(
                      fontSize: 14,
                      color: Colors.grey.shade600,
                    ),
                  ),
                ],
              ),
            ),
          ],

          const SizedBox(height = 16),

          // Action buttons
          Row(
            children = [
              if (availablePodcasts.isNotEmpty) ...[
                Expanded(
                  child: ElevatedButton.icon(
                    onPressed: () async {
                      if (mounted) {
                        final query =
                            Uri.encodeComponent('${module['title']} podcast');
                        final url = 'https://www.google.com/search?q=$query';
                        if (await canLaunchUrl(Uri.parse(url))) {
                          await launchUrl(Uri.parse(url));
                        }
                      }
                    },
                    icon: const Icon(Icons.search),
                    label: const Text('Find More Podcasts'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.orange.shade600,
                      foregroundColor: Colors.white,
                    ),
                  ),
                ),
                const SizedBox(width: 12),
              ],
              Expanded(
                child: ElevatedButton.icon(
                  onPressed: () {
                    final content = showSimplified
                        ? module['simplified']
                        : module['content'];
                    _speakContent(content);
                  },
                  icon: Icon(isSpeaking ? Icons.stop : Icons.record_voice_over),
                  label: Text(isSpeaking ? 'Stop Reading' : 'Read Aloud'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.blue.shade600,
                    foregroundColor: Colors.white,
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildEmptyState() {
    return const Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.school, size: 64, color: Colors.grey),
          SizedBox(height: 16),
          Text(
            'Course content is being prepared...',
            style: TextStyle(fontSize: 18, color: Colors.grey),
          ),
        ],
      ),
    );
  }
}
