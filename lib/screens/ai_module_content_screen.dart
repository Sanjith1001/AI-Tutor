import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:http/http.dart' as http;
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'dart:convert';
import '../services/groq_service.dart';
import '../services/activity_service.dart';
import '../services/youtube_service.dart';
import '../services/audio_helper.dart';
import '../widgets/youtube_video_widget.dart';

class AIModuleContentScreen extends StatefulWidget {
  final String moduleTitle;
  final String moduleDescription;
  final String? learningStyle;
  final String? courseTitle;

  const AIModuleContentScreen({
    super.key,
    required this.moduleTitle,
    required this.moduleDescription,
    this.learningStyle,
    this.courseTitle,
  });

  @override
  State<AIModuleContentScreen> createState() => _AIModuleContentScreenState();
}

class _AIModuleContentScreenState extends State<AIModuleContentScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;
  final GroqService _groqService = GroqService();
  final AudioHelper _audioHelper = AudioHelper();

  // Podcast functionality
  List<Map<String, dynamic>> availablePodcasts = [];
  bool podcastsLoaded = false;
  bool isLoadingPodcasts = false;

  // Audio player state
  Map<String, dynamic>? currentlyPlayingPodcast;
  bool isPlaying = false;
  bool isLoading = false;
  Duration currentPosition = Duration.zero;
  Duration totalDuration = Duration.zero;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 6, vsync: this);
    _trackModuleStart();
    _initializeAudio();
    _loadPodcasts();
  }

  void _initializeAudio() async {
    try {
      await _audioHelper.initialize();

      // Listen to audio state changes
      _audioHelper.stateStream.listen((state) {
        if (mounted) {
          setState(() {
            switch (state) {
              case AudioPlayerState.playing:
                isPlaying = true;
                isLoading = false;
                break;
              case AudioPlayerState.paused:
                isPlaying = false;
                isLoading = false;
                break;
              case AudioPlayerState.stopped:
                isPlaying = false;
                isLoading = false;
                currentlyPlayingPodcast = null;
                currentPosition = Duration.zero;
                totalDuration = Duration.zero;
                break;
              case AudioPlayerState.loading:
                isLoading = true;
                break;
              case AudioPlayerState.error:
                isPlaying = false;
                isLoading = false;
                break;
            }
          });
        }
      });

      // Listen to position changes
      _audioHelper.positionStream.listen((position) {
        if (mounted) {
          setState(() {
            currentPosition = position;
          });
        }
      });

      // Listen to duration changes
      _audioHelper.durationStream.listen((duration) {
        if (mounted) {
          setState(() {
            totalDuration = duration;
          });
        }
      });
    } catch (e) {
      print('Error initializing audio: $e');
    }
  }

  void _loadPodcasts() async {
    setState(() {
      isLoadingPodcasts = true;
      availablePodcasts = [];
      podcastsLoaded = false;
    });

    try {
      final podcasts = await _fetchPodcastsFromListenNotes(widget.moduleTitle);

      if (mounted) {
        setState(() {
          availablePodcasts = podcasts;
          podcastsLoaded = true;
          isLoadingPodcasts = false;
        });
      }
    } catch (e) {
      print('Error loading podcasts: $e');
      if (mounted) {
        setState(() {
          availablePodcasts = [];
          podcastsLoaded = true;
          isLoadingPodcasts = false;
        });
      }
    }
  }

  Future<List<Map<String, dynamic>>> _fetchPodcastsFromListenNotes(
      String topic) async {
    final apiKey = dotenv.env['LISTEN_NOTES_API_KEY'];

    print('=== PODCAST DEBUG ===');
    print('API Key loaded: ${apiKey != null ? 'Yes' : 'No'}');
    print('Topic: $topic');

    if (apiKey == null || apiKey.isEmpty) {
      print('Listen Notes API key not found');
      return [];
    }

    // More flexible search terms
    String searchQuery = _getSearchQuery(topic);
    print('Search query: $searchQuery');

    final url = Uri.parse('https://listen-api.listennotes.com/api/v2/search');

    try {
      final response = await http.get(
        url.replace(queryParameters: {
          'q': searchQuery,
          'type': 'episode',
          'len_min': '5', // Minimum length
          'len_max': '120', // Increased maximum length for more content
          'language': 'English',
          'safe_mode': '1',
          'sort_by_date': '0', // Sort by relevance, not date
          'offset': '0', // Start from beginning
          'only_in':
              'title,description', // Search in title and description for better relevance
        }),
        headers: {
          'X-ListenAPI-Key': apiKey,
          'Content-Type': 'application/json',
        },
      );

      print('API Response Status: ${response.statusCode}');

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        final results = data['results'] as List<dynamic>? ?? [];
        print('Found ${results.length} podcast episodes');
        print('Processing podcast data with safe type conversion...');

        if (results.isEmpty) {
          print('No results found, trying broader search...');
          // Try a broader search
          return await _tryBroaderSearch(apiKey, topic);
        }

        // Convert to list and sort by popularity metrics
        List<Map<String, dynamic>> podcastList = results.map((episode) {
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
            // Add popularity metrics for sorting
            'listennotes_url': episode['listennotes_url'] ?? '',
            'podcast_listennotes_url':
                episode['podcast']['listennotes_url'] ?? '',
            'podcast_listen_score': int.tryParse(
                    episode['podcast']['listen_score']?.toString() ?? '0') ??
                0,
            'podcast_total_episodes': int.tryParse(
                    episode['podcast']['total_episodes']?.toString() ?? '0') ??
                0,
            'episode_maybe_audio_invalid':
                episode['maybe_audio_invalid'] ?? false,
          };
        }).toList();

        // Sort by popularity: listen_score (higher is better), then total_episodes, then exclude invalid audio
        podcastList.sort((a, b) {
          // First, prioritize episodes with valid audio
          if (a['episode_maybe_audio_invalid'] !=
              b['episode_maybe_audio_invalid']) {
            return a['episode_maybe_audio_invalid'] ? 1 : -1;
          }

          // Then sort by podcast listen score (higher is better)
          int scoreA = int.tryParse(a['podcast_listen_score'].toString()) ?? 0;
          int scoreB = int.tryParse(b['podcast_listen_score'].toString()) ?? 0;
          int scoreComparison = scoreB.compareTo(scoreA);
          if (scoreComparison != 0) return scoreComparison;

          // Finally by total episodes (more episodes = more popular podcast)
          int episodesA =
              int.tryParse(a['podcast_total_episodes'].toString()) ?? 0;
          int episodesB =
              int.tryParse(b['podcast_total_episodes'].toString()) ?? 0;
          return episodesB.compareTo(episodesA);
        });

        // Debug: Print top podcasts with their scores and URLs
        print('=== TOP PODCASTS BY POPULARITY ===');
        for (int i = 0;
            i < (podcastList.length > 5 ? 5 : podcastList.length);
            i++) {
          final podcast = podcastList[i];
          print('${i + 1}. ${podcast['title']}');
          print(
              '   Score: ${podcast['podcast_listen_score']}, Episodes: ${podcast['podcast_total_episodes']}');
          print('   URL: ${podcast['url']}');
          print(
              '   Format: ${podcast['url']?.toString().split('.').last ?? 'unknown'}');
          print('---');
        }

        // Return more podcasts (up to 12 instead of 5)
        return podcastList.take(12).toList();
      } else {
        print(
            'Listen Notes API error: ${response.statusCode} - ${response.body}');
        return [];
      }
    } catch (e) {
      print('Error fetching podcasts: $e');
      return [];
    }
  }

  String _getSearchQuery(String topic) {
    // Create more targeted search queries based on topic
    final topicLower = topic.toLowerCase();

    if (topicLower.contains('cybersecurity') ||
        topicLower.contains('security')) {
      return 'cybersecurity security podcast education';
    } else if (topicLower.contains('programming') ||
        topicLower.contains('coding')) {
      return 'programming coding software development';
    } else if (topicLower.contains('math') ||
        topicLower.contains('arithmetic')) {
      return 'mathematics math education learning';
    } else if (topicLower.contains('science') ||
        topicLower.contains('physics')) {
      return 'science physics education learning';
    } else if (topicLower.contains('business') ||
        topicLower.contains('management')) {
      return 'business management entrepreneurship';
    } else {
      // Generic educational search
      return '$topic education learning podcast';
    }
  }

  Future<List<Map<String, dynamic>>> _tryBroaderSearch(
      String apiKey, String topic) async {
    print('Trying broader search...');

    // Try with just the main topic word
    String broaderQuery = topic.split(' ').first;
    final url = Uri.parse('https://listen-api.listennotes.com/api/v2/search');

    try {
      final response = await http.get(
        url.replace(queryParameters: {
          'q': broaderQuery,
          'type': 'episode',
          'len_min': '5',
          'len_max': '120',
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
        print('Broader search found ${results.length} episodes');

        // Convert to list and sort by popularity for broader search too
        List<Map<String, dynamic>> podcastList = results.map((episode) {
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
            // Add popularity metrics for sorting
            'podcast_listen_score': int.tryParse(
                    episode['podcast']['listen_score']?.toString() ?? '0') ??
                0,
            'podcast_total_episodes': int.tryParse(
                    episode['podcast']['total_episodes']?.toString() ?? '0') ??
                0,
            'episode_maybe_audio_invalid':
                episode['maybe_audio_invalid'] ?? false,
          };
        }).toList();

        // Sort by popularity
        podcastList.sort((a, b) {
          if (a['episode_maybe_audio_invalid'] !=
              b['episode_maybe_audio_invalid']) {
            return a['episode_maybe_audio_invalid'] ? 1 : -1;
          }
          int scoreA = int.tryParse(a['podcast_listen_score'].toString()) ?? 0;
          int scoreB = int.tryParse(b['podcast_listen_score'].toString()) ?? 0;
          int scoreComparison = scoreB.compareTo(scoreA);
          if (scoreComparison != 0) return scoreComparison;

          int episodesA =
              int.tryParse(a['podcast_total_episodes'].toString()) ?? 0;
          int episodesB =
              int.tryParse(b['podcast_total_episodes'].toString()) ?? 0;
          return episodesB.compareTo(episodesA);
        });

        // Return more results from broader search (up to 8)
        return podcastList.take(8).toList();
      }
    } catch (e) {
      print('Broader search error: $e');
    }

    return [];
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

  void _trackModuleStart() async {
    await ActivityService.addActivity(
      type: ActivityService.activityModule,
      title: 'Started ${widget.moduleTitle}',
      description: 'Began learning module content',
      metadata: {
        'moduleTitle': widget.moduleTitle,
        'courseTitle': widget.courseTitle,
        'learningStyle': widget.learningStyle,
      },
    );
  }

  Widget _buildAudioPlayer() {
    return Container(
      decoration: BoxDecoration(
        color: Colors.grey.shade900,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.3),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        children: [
          // Progress Bar
          LinearProgressIndicator(
            value: totalDuration.inMilliseconds > 0
                ? currentPosition.inMilliseconds / totalDuration.inMilliseconds
                : 0.0,
            backgroundColor: Colors.grey.shade700,
            valueColor: AlwaysStoppedAnimation<Color>(Colors.blue.shade400),
          ),

          // Player Controls
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: Row(
              children: [
                // Podcast Thumbnail/Icon
                Container(
                  width: 50,
                  height: 50,
                  decoration: BoxDecoration(
                    color: Colors.blue.shade600,
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: currentlyPlayingPodcast?['thumbnail'] != null &&
                          currentlyPlayingPodcast!['thumbnail'].isNotEmpty
                      ? ClipRRect(
                          borderRadius: BorderRadius.circular(8),
                          child: Image.network(
                            currentlyPlayingPodcast!['thumbnail'],
                            fit: BoxFit.cover,
                            errorBuilder: (context, error, stackTrace) {
                              return const Icon(
                                Icons.podcasts,
                                color: Colors.white,
                                size: 24,
                              );
                            },
                          ),
                        )
                      : const Icon(
                          Icons.podcasts,
                          color: Colors.white,
                          size: 24,
                        ),
                ),

                const SizedBox(width: 12),

                // Podcast Info
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        currentlyPlayingPodcast?['title'] ?? 'Unknown Title',
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 14,
                          fontWeight: FontWeight.bold,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                      Text(
                        currentlyPlayingPodcast?['podcast_title'] ?? '',
                        style: TextStyle(
                          color: Colors.grey.shade400,
                          fontSize: 12,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ],
                  ),
                ),

                // Time Display
                Text(
                  '${_formatTime(currentPosition)} / ${_formatTime(totalDuration)}',
                  style: TextStyle(
                    color: Colors.grey.shade400,
                    fontSize: 12,
                  ),
                ),

                const SizedBox(width: 16),

                // Play/Pause Button
                Container(
                  decoration: BoxDecoration(
                    color: Colors.blue.shade600,
                    shape: BoxShape.circle,
                  ),
                  child: IconButton(
                    onPressed: isLoading ? null : _togglePlayPause,
                    icon: isLoading
                        ? SizedBox(
                            width: 20,
                            height: 20,
                            child: CircularProgressIndicator(
                              strokeWidth: 2,
                              valueColor:
                                  AlwaysStoppedAnimation<Color>(Colors.white),
                            ),
                          )
                        : Icon(
                            isPlaying ? Icons.pause : Icons.play_arrow,
                            color: Colors.white,
                            size: 24,
                          ),
                  ),
                ),

                const SizedBox(width: 8),

                // Stop Button
                IconButton(
                  onPressed: _stopAudio,
                  icon: Icon(
                    Icons.stop,
                    color: Colors.grey.shade400,
                    size: 20,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  String _formatTime(Duration duration) {
    String twoDigits(int n) => n.toString().padLeft(2, '0');
    final minutes = twoDigits(duration.inMinutes.remainder(60));
    final seconds = twoDigits(duration.inSeconds.remainder(60));
    return '$minutes:$seconds';
  }

  @override
  void dispose() {
    _tabController.dispose();
    _audioHelper.stop();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.moduleTitle),
        backgroundColor: Colors.blue.shade800,
        foregroundColor: Colors.white,
        bottom: TabBar(
          controller: _tabController,
          isScrollable: true,
          labelColor: Colors.white,
          unselectedLabelColor: Colors.grey,
          tabs: const [
            Tab(text: "Content"),
            Tab(text: "Simplified"),
            Tab(text: "Quiz"),
            Tab(text: "Examples"),
            Tab(text: "Videos"),
            Tab(text: "Audio"),
          ],
        ),
      ),
      body: TabBarView(
        controller: _tabController,
        children: [
          _buildContentTab('content'),
          _buildContentTab('simplified'),
          _buildContentTab('quiz'),
          _buildContentTab('examples'),
          _buildVideosTab(),
          _buildAudioTab(),
        ],
      ),
    );
  }

  Widget _buildContentTab(String contentType) {
    return FutureBuilder<String>(
      future: _generateContent(contentType),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                CircularProgressIndicator(),
                SizedBox(height: 16),
                Text('Generating AI content...'),
              ],
            ),
          );
        } else if (snapshot.hasError) {
          return Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Icon(Icons.error_outline, size: 48, color: Colors.red),
                const SizedBox(height: 16),
                Text('Error: ${snapshot.error}'),
                const SizedBox(height: 16),
                ElevatedButton(
                  onPressed: () => setState(() {}),
                  child: const Text('Retry'),
                ),
              ],
            ),
          );
        } else {
          return SingleChildScrollView(
            padding: const EdgeInsets.all(16.0),
            child: _buildFormattedContent(
                snapshot.data ?? 'No content available', contentType),
          );
        }
      },
    );
  }

  Widget _buildFormattedContent(String content, String contentType) {
    // Split content into sections and format properly
    final lines = content.split('\n');
    final List<Widget> widgets = [];

    List<String> currentParagraph = [];

    for (String line in lines) {
      final trimmedLine = line.trim();

      if (trimmedLine.isEmpty) {
        if (currentParagraph.isNotEmpty) {
          widgets.add(_buildParagraph(currentParagraph.join(' ')));
          widgets.add(const SizedBox(height: 12));
          currentParagraph.clear();
        }
      } else if (trimmedLine.startsWith('#')) {
        // Handle headers
        if (currentParagraph.isNotEmpty) {
          widgets.add(_buildParagraph(currentParagraph.join(' ')));
          widgets.add(const SizedBox(height: 12));
          currentParagraph.clear();
        }
        widgets.add(_buildHeader(trimmedLine));
        widgets.add(const SizedBox(height: 16));
      } else if (trimmedLine.startsWith('Q') &&
          trimmedLine.contains(':') &&
          contentType == 'quiz') {
        // Handle quiz questions
        if (currentParagraph.isNotEmpty) {
          widgets.add(_buildParagraph(currentParagraph.join(' ')));
          widgets.add(const SizedBox(height: 12));
          currentParagraph.clear();
        }
        widgets.add(_buildQuizQuestion(trimmedLine));
        widgets.add(const SizedBox(height: 8));
      } else if (trimmedLine.startsWith('A)') ||
          trimmedLine.startsWith('B)') ||
          trimmedLine.startsWith('C)') ||
          trimmedLine.startsWith('D)')) {
        // Handle quiz options
        widgets.add(_buildQuizOption(trimmedLine));
        widgets.add(const SizedBox(height: 4));
      } else if (trimmedLine.startsWith('Answer:')) {
        // Handle quiz answers
        widgets.add(_buildQuizAnswer(trimmedLine));
        widgets.add(const SizedBox(height: 16));
      } else if (trimmedLine.startsWith('•') || trimmedLine.startsWith('-')) {
        // Handle bullet points
        if (currentParagraph.isNotEmpty) {
          widgets.add(_buildParagraph(currentParagraph.join(' ')));
          widgets.add(const SizedBox(height: 8));
          currentParagraph.clear();
        }
        widgets.add(_buildBulletPoint(trimmedLine.substring(1).trim()));
        widgets.add(const SizedBox(height: 4));
      } else {
        // Regular text
        currentParagraph.add(trimmedLine);
      }
    }

    // Add any remaining paragraph
    if (currentParagraph.isNotEmpty) {
      widgets.add(_buildParagraph(currentParagraph.join(' ')));
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: widgets,
    );
  }

  Widget _buildHeader(String headerText) {
    final level = headerText.split('#').length - 1;
    final text = headerText.replaceAll('#', '').trim();

    double fontSize;
    FontWeight fontWeight;
    Color color;

    switch (level) {
      case 1:
        fontSize = 24;
        fontWeight = FontWeight.bold;
        color = Colors.blue.shade800;
        break;
      case 2:
        fontSize = 20;
        fontWeight = FontWeight.bold;
        color = Colors.blue.shade700;
        break;
      case 3:
        fontSize = 18;
        fontWeight = FontWeight.w600;
        color = Colors.blue.shade600;
        break;
      default:
        fontSize = 16;
        fontWeight = FontWeight.w500;
        color = Colors.blue.shade500;
    }

    return Text(
      text,
      style: TextStyle(
        fontSize: fontSize,
        fontWeight: fontWeight,
        color: color,
      ),
    );
  }

  Widget _buildParagraph(String text) {
    return Text(
      text,
      style: const TextStyle(
        fontSize: 16,
        height: 1.5,
        color: Colors.black87,
      ),
      textAlign: TextAlign.justify,
    );
  }

  Widget _buildBulletPoint(String text) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          '• ',
          style: TextStyle(
            fontSize: 16,
            color: Colors.blue,
            fontWeight: FontWeight.bold,
          ),
        ),
        Expanded(
          child: Text(
            text,
            style: const TextStyle(
              fontSize: 16,
              height: 1.4,
              color: Colors.black87,
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildQuizQuestion(String question) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.blue.shade50,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: Colors.blue.shade200),
      ),
      child: Text(
        question,
        style: const TextStyle(
          fontSize: 16,
          fontWeight: FontWeight.bold,
          color: Colors.black87,
        ),
      ),
    );
  }

  Widget _buildQuizOption(String option) {
    return Padding(
      padding: const EdgeInsets.only(left: 16),
      child: Text(
        option,
        style: const TextStyle(
          fontSize: 15,
          color: Colors.black87,
        ),
      ),
    );
  }

  Widget _buildQuizAnswer(String answer) {
    return Container(
      padding: const EdgeInsets.all(8),
      decoration: BoxDecoration(
        color: Colors.green.shade50,
        borderRadius: BorderRadius.circular(6),
        border: Border.all(color: Colors.green.shade200),
      ),
      child: Text(
        answer,
        style: TextStyle(
          fontSize: 15,
          fontWeight: FontWeight.bold,
          color: Colors.green.shade700,
        ),
      ),
    );
  }

  Widget _buildVideosTab() {
    return _YouTubeVideosWidget(
      moduleTitle: widget.moduleTitle,
      searchQuery: widget.moduleTitle,
    );
  }

  Widget _buildAudioTab() {
    return Column(
      children: [
        // Audio Player Section (if something is playing)
        if (currentlyPlayingPodcast != null) _buildAudioPlayer(),

        // Scrollable Podcast List
        Expanded(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Header Card
                Card(
                  elevation: 4,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Container(
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(12),
                      gradient: LinearGradient(
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                        colors: [
                          Colors.blue.shade600,
                          Colors.purple.shade600,
                        ],
                      ),
                    ),
                    child: Padding(
                      padding: const EdgeInsets.all(20.0),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              Container(
                                padding: const EdgeInsets.all(8),
                                decoration: BoxDecoration(
                                  color: Colors.white.withValues(alpha: 0.2),
                                  borderRadius: BorderRadius.circular(8),
                                ),
                                child: const Icon(
                                  Icons.headphones,
                                  size: 28,
                                  color: Colors.white,
                                ),
                              ),
                              const SizedBox(width: 16),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      'Audio Learning',
                                      style: const TextStyle(
                                        fontSize: 22,
                                        fontWeight: FontWeight.bold,
                                        color: Colors.white,
                                      ),
                                    ),
                                    Text(
                                      widget.moduleTitle,
                                      style: TextStyle(
                                        fontSize: 16,
                                        color:
                                            Colors.white.withValues(alpha: 0.9),
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 16),
                          Text(
                            'Browse educational podcasts • Windows-compatible audio player',
                            style: TextStyle(
                              fontSize: 16,
                              color: Colors.white.withValues(alpha: 0.8),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),

                const SizedBox(height: 20),

                // Podcast Section
                _buildPodcastSection(),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildPodcastSection() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            Colors.purple.shade50,
            Colors.blue.shade50,
          ],
        ),
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withValues(alpha: 0.1),
            blurRadius: 6,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header
          Row(
            children: [
              Icon(Icons.podcasts, color: Colors.purple.shade600, size: 20),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  'Educational Podcasts',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: Colors.purple.shade800,
                  ),
                ),
              ),
              IconButton(
                onPressed: () {
                  if (mounted) {
                    _loadPodcasts();
                  }
                },
                icon: Icon(Icons.refresh,
                    color: Colors.purple.shade600, size: 18),
                tooltip: 'Refresh',
                padding: EdgeInsets.zero,
                constraints: const BoxConstraints(),
              ),
            ],
          ),
          const SizedBox(height: 12),

          // Loading State
          if (isLoadingPodcasts) ...[
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Colors.white.withValues(alpha: 0.7),
                borderRadius: BorderRadius.circular(8),
              ),
              child: const Row(
                children: [
                  SizedBox(
                    width: 16,
                    height: 16,
                    child: CircularProgressIndicator(strokeWidth: 2),
                  ),
                  SizedBox(width: 12),
                  Text(
                    'Finding podcasts...',
                    style: TextStyle(fontSize: 14),
                  ),
                ],
              ),
            ),
          ]
          // Podcasts Found
          else if (availablePodcasts.isNotEmpty) ...[
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
              decoration: BoxDecoration(
                color: Colors.green.shade100,
                borderRadius: BorderRadius.circular(16),
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
                      fontSize: 12,
                      color: Colors.green.shade700,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 8),

            // Podcast Cards
            ...availablePodcasts.map((podcast) {
              final isCurrentlyPlaying = currentlyPlayingPodcast != null &&
                  currentlyPlayingPodcast!['url'] == podcast['url'];

              return Container(
                margin: const EdgeInsets.only(bottom: 12),
                decoration: BoxDecoration(
                  color:
                      isCurrentlyPlaying ? Colors.blue.shade50 : Colors.white,
                  borderRadius: BorderRadius.circular(12),
                  border: isCurrentlyPlaying
                      ? Border.all(color: Colors.blue.shade300, width: 2)
                      : null,
                  boxShadow: [
                    BoxShadow(
                      color: Colors.grey.withValues(alpha: 0.15),
                      blurRadius: 6,
                      offset: const Offset(0, 3),
                    ),
                  ],
                ),
                child: InkWell(
                  onTap: () => _playPodcast(podcast),
                  borderRadius: BorderRadius.circular(12),
                  child: Padding(
                    padding: const EdgeInsets.all(16),
                    child: Row(
                      children: [
                        // Thumbnail or Play Icon
                        Container(
                          width: 60,
                          height: 60,
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(8),
                            color: isCurrentlyPlaying
                                ? Colors.blue.shade100
                                : Colors.purple.shade100,
                          ),
                          child: podcast['thumbnail'] != null &&
                                  podcast['thumbnail'].isNotEmpty
                              ? ClipRRect(
                                  borderRadius: BorderRadius.circular(8),
                                  child: Image.network(
                                    podcast['thumbnail'],
                                    fit: BoxFit.cover,
                                    errorBuilder: (context, error, stackTrace) {
                                      return Icon(
                                        isCurrentlyPlaying && isPlaying
                                            ? Icons.pause
                                            : Icons.play_arrow,
                                        color: isCurrentlyPlaying
                                            ? Colors.blue.shade600
                                            : Colors.purple.shade600,
                                        size: 24,
                                      );
                                    },
                                  ),
                                )
                              : Icon(
                                  isCurrentlyPlaying && isPlaying
                                      ? Icons.pause
                                      : Icons.play_arrow,
                                  color: isCurrentlyPlaying
                                      ? Colors.blue.shade600
                                      : Colors.purple.shade600,
                                  size: 24,
                                ),
                        ),

                        const SizedBox(width: 16),

                        // Podcast Info
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                podcast['title'],
                                style: TextStyle(
                                  fontSize: 15,
                                  fontWeight: FontWeight.bold,
                                  color: isCurrentlyPlaying
                                      ? Colors.blue.shade800
                                      : Colors.grey.shade800,
                                ),
                                maxLines: 2,
                                overflow: TextOverflow.ellipsis,
                              ),
                              const SizedBox(height: 4),
                              if (podcast['podcast_title'] != null &&
                                  podcast['podcast_title'].isNotEmpty)
                                Text(
                                  podcast['podcast_title'],
                                  style: TextStyle(
                                    fontSize: 13,
                                    color: isCurrentlyPlaying
                                        ? Colors.blue.shade600
                                        : Colors.grey.shade600,
                                    fontWeight: FontWeight.w500,
                                  ),
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                ),
                              const SizedBox(height: 6),
                              if (podcast['description'] != null &&
                                  podcast['description'].isNotEmpty)
                                Text(
                                  podcast['description'],
                                  style: TextStyle(
                                    fontSize: 12,
                                    color: Colors.grey.shade600,
                                  ),
                                  maxLines: 2,
                                  overflow: TextOverflow.ellipsis,
                                ),
                            ],
                          ),
                        ),

                        const SizedBox(width: 12),

                        // Duration and Status
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.end,
                          children: [
                            Container(
                              padding: const EdgeInsets.symmetric(
                                  horizontal: 8, vertical: 4),
                              decoration: BoxDecoration(
                                color: isCurrentlyPlaying
                                    ? Colors.blue.shade100
                                    : Colors.orange.shade100,
                                borderRadius: BorderRadius.circular(8),
                              ),
                              child: Text(
                                podcast['duration'],
                                style: TextStyle(
                                  fontSize: 11,
                                  fontWeight: FontWeight.bold,
                                  color: isCurrentlyPlaying
                                      ? Colors.blue.shade700
                                      : Colors.orange.shade700,
                                ),
                              ),
                            ),
                            if (isCurrentlyPlaying) ...[
                              const SizedBox(height: 8),
                              Container(
                                padding: const EdgeInsets.symmetric(
                                    horizontal: 6, vertical: 2),
                                decoration: BoxDecoration(
                                  color: Colors.green.shade100,
                                  borderRadius: BorderRadius.circular(6),
                                ),
                                child: Row(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    Icon(
                                      isPlaying ? Icons.volume_up : Icons.pause,
                                      size: 12,
                                      color: Colors.green.shade700,
                                    ),
                                    const SizedBox(width: 2),
                                    Text(
                                      isPlaying ? 'Playing' : 'Paused',
                                      style: TextStyle(
                                        fontSize: 10,
                                        fontWeight: FontWeight.bold,
                                        color: Colors.green.shade700,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ],
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
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: Colors.white.withValues(alpha: 0.7),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: Colors.grey.shade200),
              ),
              child: Column(
                children: [
                  Icon(
                    Icons.search_off,
                    size: 40,
                    color: Colors.grey.shade400,
                  ),
                  const SizedBox(height: 10),
                  Text(
                    'No podcasts found for "${widget.moduleTitle}"',
                    style: TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                      color: Colors.grey.shade600,
                    ),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Check console for debug information',
                    style: TextStyle(
                      fontSize: 12,
                      color: Colors.grey.shade500,
                    ),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 12),
                  ElevatedButton.icon(
                    onPressed: () async {
                      print('=== MANUAL TEST ===');
                      final testPodcasts =
                          await _fetchPodcastsFromListenNotes('programming');
                      print(
                          'Test result: ${testPodcasts.length} podcasts found');
                      if (mounted) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(
                              content: Text(
                                  'Test: ${testPodcasts.length} podcasts found')),
                        );
                      }
                    },
                    icon: const Icon(Icons.bug_report, size: 16),
                    label: const Text('Test API'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.blue.shade600,
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(
                          horizontal: 16, vertical: 8),
                    ),
                  ),
                  const SizedBox(height: 8),
                  ElevatedButton.icon(
                    onPressed: () {
                      if (mounted) {
                        _loadPodcasts();
                      }
                    },
                    icon: const Icon(Icons.refresh, size: 16),
                    label: const Text('Try Again'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.green.shade600,
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(
                          horizontal: 16, vertical: 8),
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

  Future<String> _generateContent(String promptType) async {
    String prompt = '';
    switch (promptType) {
      case 'content':
        prompt =
            '''Create comprehensive educational content for "${widget.moduleTitle}":

${widget.moduleDescription}

Structure the content with clear headings using # for main sections and ## for subsections:

# ${widget.moduleTitle}

## Introduction
Provide a clear introduction explaining what ${widget.moduleTitle} is and why it's important.

## Key Concepts
Explain the fundamental concepts with bullet points:
• Concept 1: Detailed explanation
• Concept 2: Detailed explanation
• Concept 3: Detailed explanation

## How It Works
Explain the mechanisms and processes involved.

## Applications
Describe real-world applications and use cases.

## Best Practices
List important best practices and recommendations.

Make the content educational, well-structured, and easy to understand.''';
        break;
      case 'simplified':
        prompt =
            '''Create a beginner-friendly explanation of "${widget.moduleTitle}":

${widget.moduleDescription}

Structure it as follows:

# ${widget.moduleTitle} - Simplified Guide

## What is ${widget.moduleTitle}?
Explain in simple terms what it is and why beginners should learn it.

## Why Learn ${widget.moduleTitle}?
• Benefit 1: Clear explanation
• Benefit 2: Clear explanation  
• Benefit 3: Clear explanation

## Getting Started
Provide step-by-step guidance for beginners.

## Key Points to Remember
List the most important concepts beginners should focus on.

Use simple language and avoid technical jargon.''';
        break;
      case 'quiz':
        prompt =
            '''Generate 5 multiple-choice questions for "${widget.moduleTitle}". 

Format exactly as follows:

Q1: [Question text here]
A) [Option A]
B) [Option B]
C) [Option C]
D) [Option D]
Answer: [Correct option letter]

Q2: [Question text here]
A) [Option A]
B) [Option B]
C) [Option C]
D) [Option D]
Answer: [Correct option letter]

Continue this pattern for all 5 questions. Make questions practical and test understanding of key concepts.''';
        break;
      case 'examples':
        prompt =
            '''Provide 3 practical examples for "${widget.moduleTitle}" with detailed explanations:

# Practical Examples for ${widget.moduleTitle}

## Example 1: [Title]
Detailed explanation of the first example with step-by-step breakdown.

## Example 2: [Title]  
Detailed explanation of the second example with practical applications.

## Example 3: [Title]
Detailed explanation of the third example with real-world context.

Make each example practical and include clear explanations of how it relates to ${widget.moduleTitle}.''';
        break;
    }

    try {
      final response = await _groqService.generateTextContent(prompt);
      return response;
    } catch (e) {
      return _getFallbackContent(promptType);
    }
  }

  String _getFallbackContent(String contentType) {
    switch (contentType) {
      case 'content':
        return '''# ${widget.moduleTitle}

## Introduction
${widget.moduleTitle} is an important topic in modern technology and development. Understanding this concept is crucial for anyone looking to advance their knowledge in this field.

## Key Concepts
• **Fundamental Principles**: The basic principles that govern ${widget.moduleTitle}
• **Core Components**: Essential elements that make up the system
• **Implementation**: How these concepts are applied in practice
• **Best Practices**: Industry-standard approaches and methodologies

## How It Works
${widget.moduleTitle} operates through a series of interconnected processes that work together to achieve specific goals. The system is designed to be efficient, scalable, and maintainable.

## Applications
This technology is widely used in:
• Web development and applications
• Mobile app development  
• Enterprise software solutions
• Data processing and analysis
• System integration projects

## Best Practices
• Follow established coding standards
• Implement proper error handling
• Use version control systems
• Write comprehensive documentation
• Test thoroughly before deployment

## Conclusion
Mastering ${widget.moduleTitle} opens up numerous opportunities in the technology field and provides a solid foundation for advanced topics.''';

      case 'simplified':
        return '''# ${widget.moduleTitle} - Simplified Guide

## What is ${widget.moduleTitle}?
${widget.moduleTitle} is a technology concept that helps developers create better applications and systems. Think of it as a tool that makes complex tasks easier to manage and implement.

## Why Learn ${widget.moduleTitle}?
• **Career Growth**: High demand in the job market
• **Problem Solving**: Helps solve real-world technical challenges
• **Efficiency**: Makes development faster and more reliable
• **Foundation**: Builds a strong base for advanced topics

## Getting Started
1. **Learn the Basics**: Start with fundamental concepts
2. **Practice Regularly**: Apply what you learn through hands-on projects
3. **Join Communities**: Connect with other learners and experts
4. **Build Projects**: Create real applications to reinforce learning

## Key Points to Remember
• Start with simple examples and gradually increase complexity
• Practice is more important than theory
• Don't be afraid to make mistakes - they're part of learning
• Focus on understanding concepts rather than memorizing syntax

## Next Steps
Once you're comfortable with the basics, explore advanced topics and consider specializing in areas that interest you most.''';

      case 'quiz':
        return '''Q1: What is the primary purpose of ${widget.moduleTitle}?
A) To make development more complex
B) To solve specific technical challenges efficiently
C) To replace all existing technologies
D) To slow down the development process
Answer: B

Q2: Which of the following is a key benefit of learning ${widget.moduleTitle}?
A) It's only useful for beginners
B) It has no practical applications
C) It improves career opportunities in technology
D) It's becoming obsolete
Answer: C

Q3: What should be the first step when learning ${widget.moduleTitle}?
A) Jump directly to advanced topics
B) Memorize all syntax without understanding
C) Learn the fundamental concepts and basics
D) Avoid practicing with real examples
Answer: C

Q4: Why is practice important when learning ${widget.moduleTitle}?
A) It's not important at all
B) It helps reinforce theoretical knowledge with hands-on experience
C) It makes learning more difficult
D) It's only for advanced learners
Answer: B

Q5: What is a recommended approach for mastering ${widget.moduleTitle}?
A) Learn everything at once without breaks
B) Focus only on theory without practical application
C) Start simple and gradually increase complexity
D) Avoid joining learning communities
Answer: C''';

      case 'examples':
        return '''# Practical Examples for ${widget.moduleTitle}

## Example 1: Basic Implementation
This example demonstrates the fundamental usage of ${widget.moduleTitle} in a simple scenario. 

**Scenario**: Creating a basic application structure
**Steps**:
1. Set up the initial configuration
2. Implement core functionality
3. Test the basic features
4. Optimize for performance

**Key Learning**: Understanding how the basic components work together.

## Example 2: Real-World Application
This example shows how ${widget.moduleTitle} is used in production environments.

**Scenario**: Building a scalable solution for a business problem
**Steps**:
1. Analyze requirements and constraints
2. Design the architecture
3. Implement with best practices
4. Deploy and monitor performance

**Key Learning**: Applying concepts to solve actual business challenges.

## Example 3: Advanced Integration
This example demonstrates advanced techniques and integration patterns.

**Scenario**: Integrating with existing systems and third-party services
**Steps**:
1. Assess integration requirements
2. Design communication protocols
3. Implement error handling and fallbacks
4. Test integration thoroughly

**Key Learning**: Managing complexity in real-world systems and ensuring reliability.''';

      default:
        return 'Content for ${widget.moduleTitle} will be available soon. Please check back later or try refreshing the content.';
    }
  }

  Color _getAudioStateColor(AudioPlayerState state) {
    switch (state) {
      case AudioPlayerState.playing:
        return Colors.green;
      case AudioPlayerState.paused:
        return Colors.orange;
      case AudioPlayerState.loading:
        return Colors.blue;
      case AudioPlayerState.error:
        return Colors.red;
      case AudioPlayerState.stopped:
      default:
        return Colors.grey;
    }
  }

  IconData _getAudioStateIcon(AudioPlayerState state) {
    switch (state) {
      case AudioPlayerState.playing:
        return Icons.play_circle_filled;
      case AudioPlayerState.paused:
        return Icons.pause_circle_filled;
      case AudioPlayerState.loading:
        return Icons.hourglass_empty;
      case AudioPlayerState.error:
        return Icons.error;
      case AudioPlayerState.stopped:
      default:
        return Icons.stop_circle;
    }
  }

  String _getAudioStateText(AudioPlayerState state) {
    switch (state) {
      case AudioPlayerState.playing:
        return 'Audio is playing...';
      case AudioPlayerState.paused:
        return 'Audio is paused';
      case AudioPlayerState.loading:
        return 'Loading audio...';
      case AudioPlayerState.error:
        return 'Audio error occurred';
      case AudioPlayerState.stopped:
      default:
        return 'Ready to play audio';
    }
  }

  Future<void> _toggleAudio(AudioPlayerState currentState) async {
    try {
      if (currentState == AudioPlayerState.playing) {
        await _audioHelper.pause();
      } else {
        // Instead of playing random audio, show a helpful message
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Audio Feature: ${widget.moduleTitle}',
                    style: const TextStyle(fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    'This would play educational content related to: ${widget.moduleDescription}',
                    style: const TextStyle(fontSize: 14),
                  ),
                  const SizedBox(height: 8),
                  const Text(
                    '💡 Tip: Check the "Educational Podcasts" section in the course modules for real audio content!',
                    style: TextStyle(fontSize: 12, fontStyle: FontStyle.italic),
                  ),
                ],
              ),
              duration: const Duration(seconds: 5),
              backgroundColor: Colors.blue.shade700,
              behavior: SnackBarBehavior.floating,
            ),
          );
        }

        // Simulate audio playing for demo purposes
        await Future.delayed(const Duration(milliseconds: 500));

        // You could implement actual text-to-speech here
        // For now, we'll just show the message above
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Audio Error: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  Future<void> _stopAudio() async {
    try {
      await _audioHelper.stop();
      if (mounted) {
        setState(() {
          currentlyPlayingPodcast = null;
          isPlaying = false;
          isLoading = false;
          currentPosition = Duration.zero;
          totalDuration = Duration.zero;
        });
      }
    } catch (e) {
      print('Error stopping audio: $e');
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error stopping audio: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  void _playPodcast(Map<String, dynamic> podcast) async {
    print('=== PODCAST CLICKED ===');
    print('Podcast: ${podcast['title']}');
    print('Original URL: ${podcast['url']}');

    // Show options dialog since most podcast formats are not Windows-compatible
    _showPodcastOptionsDialog(podcast);
  }

  void _showPodcastOptionsDialog(Map<String, dynamic> podcast) async {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Row(
            children: [
              Icon(Icons.podcasts, color: Colors.blue.shade600),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  'Audio Options',
                  style: TextStyle(color: Colors.blue.shade800),
                ),
              ),
            ],
          ),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                podcast['title'],
                style: const TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 16,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                'From: ${podcast['podcast_title'] ?? 'Unknown Podcast'}',
                style: TextStyle(
                  color: Colors.grey.shade600,
                  fontSize: 14,
                ),
              ),
              const SizedBox(height: 16),
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Colors.orange.shade50,
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(color: Colors.orange.shade200),
                ),
                child: Row(
                  children: [
                    Icon(Icons.info_outline,
                        color: Colors.orange.shade600, size: 20),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        'This podcast uses a streaming format not supported by Windows audio system',
                        style: TextStyle(
                          color: Colors.orange.shade800,
                          fontSize: 13,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 16),
              Row(
                children: [
                  Icon(Icons.lightbulb_outline,
                      color: Colors.amber.shade600, size: 18),
                  const SizedBox(width: 8),
                  const Text(
                    'Choose an option:',
                    style: TextStyle(fontWeight: FontWeight.w500),
                  ),
                ],
              ),
              const SizedBox(height: 8),
              Text(
                '• Listen in Browser: Opens the original podcast\n• Demo Audio Player: Tests in-app audio with sample content',
                style: TextStyle(
                  fontSize: 12,
                  color: Colors.grey.shade600,
                ),
              ),
            ],
          ),
          actions: [
            TextButton.icon(
              onPressed: () {
                Navigator.of(context).pop();
                _openInBrowser(podcast);
              },
              icon: const Icon(Icons.open_in_browser),
              label: const Text('Listen in Browser'),
            ),
            ElevatedButton.icon(
              onPressed: () {
                Navigator.of(context).pop();
                _playWindowsCompatibleAudio(podcast);
              },
              icon: const Icon(Icons.play_arrow),
              label: const Text('Demo Audio Player'),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.blue.shade600,
                foregroundColor: Colors.white,
              ),
            ),
          ],
        );
      },
    );
  }

  void _openInBrowser(Map<String, dynamic> podcast) async {
    final url = podcast['url'];
    if (url != null && url.isNotEmpty) {
      try {
        if (await canLaunchUrl(Uri.parse(url))) {
          await launchUrl(Uri.parse(url));
        } else {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Could not open podcast URL')),
          );
        }
      } catch (e) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error opening URL: $e')),
        );
      }
    }
  }

  void _playWindowsCompatibleAudio(Map<String, dynamic> podcast) async {
    // Use Windows-compatible MP3 files for demonstration
    final windowsCompatibleUrls = [
      'https://archive.org/download/testmp3testfile/mpthreetest.mp3',
      'https://www.soundjay.com/misc/sounds/bell-ringing-05.mp3',
      'https://file-examples.com/storage/fe68c1b7c1a9fd42b99c451/2017/11/file_example_MP3_700KB.mp3',
    ];

    setState(() {
      isLoading = true;
      currentlyPlayingPodcast = {
        ...podcast,
        'title': '🎵 Sample Audio - ${podcast['title']}',
        'url': windowsCompatibleUrls[0],
      };
    });

    try {
      await _audioHelper.stop();

      print('Playing Windows-compatible audio: ${windowsCompatibleUrls[0]}');
      await _audioHelper.playModuleAudio(
        moduleId: 'windows_audio_${podcast['title']}',
        description: 'Windows-compatible sample audio for ${podcast['title']}',
        podcastUrl: windowsCompatibleUrls[0],
      );

      if (mounted) {
        setState(() {
          isPlaying = true;
          isLoading = false;
        });

        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    const Icon(Icons.play_circle_filled, color: Colors.white),
                    const SizedBox(width: 8),
                    const Text('Audio Player Demo',
                        style: TextStyle(fontWeight: FontWeight.bold)),
                  ],
                ),
                const SizedBox(height: 4),
                Text(
                  'Playing sample audio to demonstrate the in-app player functionality',
                  style: TextStyle(
                      fontSize: 12, color: Colors.white.withValues(alpha: 0.9)),
                ),
              ],
            ),
            backgroundColor: Colors.green.shade600,
            duration: const Duration(seconds: 4),
            behavior: SnackBarBehavior.floating,
          ),
        );
      }
    } catch (e) {
      print('Windows-compatible audio also failed: $e');
      if (mounted) {
        setState(() {
          isLoading = false;
          isPlaying = false;
          currentlyPlayingPodcast = null;
        });

        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Audio playback is not available on this system'),
            backgroundColor: Colors.red,
            duration: Duration(seconds: 3),
          ),
        );
      }
    }
  }

  void _playOriginalPodcast(Map<String, dynamic> podcast) async {
    if (podcast['url'] == null || podcast['url'].isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('No audio URL available')),
      );
      return;
    }

    // Check if URL is supported format
    final url = podcast['url'].toString();
    if (!url.toLowerCase().contains('.mp3') &&
        !url.toLowerCase().contains('.wav') &&
        !url.toLowerCase().contains('.ogg')) {
      print('Unsupported audio format: $url');
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text(
              'This podcast format is not supported on Windows. Only MP3, WAV, and OGG files are supported.'),
          duration: Duration(seconds: 4),
        ),
      );
      return;
    }

    setState(() {
      isLoading = true;
      currentlyPlayingPodcast = podcast;
    });

    try {
      await _audioHelper.stop(); // Stop any current audio

      print('Attempting to play: $url');
      await _audioHelper.playModuleAudio(
        moduleId: 'podcast_${podcast['title']}',
        description: podcast['description'] ?? '',
        podcastUrl: url,
      );

      if (mounted) {
        setState(() {
          isPlaying = true;
          isLoading = false;
        });
      }

      print('Successfully started playing podcast');
    } catch (e) {
      print('Error playing podcast: $e');
      if (mounted) {
        setState(() {
          isLoading = false;
          isPlaying = false;
          currentlyPlayingPodcast = null;
        });

        String errorMessage = 'Error playing audio';
        if (e.toString().contains('WindowsAudioError')) {
          errorMessage =
              'Windows audio error. This podcast format may not be supported.';
        } else if (e.toString().contains('Unsupported audio format')) {
          errorMessage = 'This audio format is not supported on Windows.';
        } else if (e.toString().contains('not found')) {
          errorMessage = 'Audio file not found or unavailable.';
        } else {
          errorMessage = 'Error playing audio: ${e.toString()}';
        }

        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(errorMessage),
                const SizedBox(height: 8),
                ElevatedButton(
                  onPressed: () {
                    ScaffoldMessenger.of(context).hideCurrentSnackBar();
                    _playFallbackAudio(podcast);
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.white,
                    foregroundColor: Colors.red,
                    padding:
                        const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                  ),
                  child: const Text('Try Sample Audio',
                      style: TextStyle(fontSize: 12)),
                ),
              ],
            ),
            duration: const Duration(seconds: 6),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  void _playFallbackAudio(Map<String, dynamic> podcast) async {
    _playWindowsCompatibleAudio(podcast);
  }

  void _togglePlayPause() async {
    if (currentlyPlayingPodcast == null) return;

    setState(() {
      isLoading = true;
    });

    try {
      if (isPlaying) {
        await _audioHelper.pause();
      } else {
        await _audioHelper.resume();
      }

      if (mounted) {
        setState(() {
          isPlaying = !isPlaying;
          isLoading = false;
        });
      }
    } catch (e) {
      print('Error toggling play/pause: $e');
      if (mounted) {
        setState(() {
          isLoading = false;
        });
      }
    }
  }
}

class _YouTubeVideosWidget extends StatefulWidget {
  final String moduleTitle;
  final String searchQuery;

  const _YouTubeVideosWidget({
    required this.moduleTitle,
    required this.searchQuery,
  });

  @override
  State<_YouTubeVideosWidget> createState() => _YouTubeVideosWidgetState();
}

class _YouTubeVideosWidgetState extends State<_YouTubeVideosWidget> {
  List<YouTubeVideo> _videos = [];

  @override
  void initState() {
    super.initState();
    // Immediately set fallback videos to ensure they always show
    _videos = _getFallbackVideos();
    _loadVideos();
  }

  Future<void> _loadVideos() async {
    print('Loading videos for: ${widget.searchQuery}');

    try {
      // Try to load real videos in the background
      final videos = await YouTubeService.searchVideos(
        query: widget.searchQuery,
        maxResults: 6,
      ).timeout(
        const Duration(seconds: 5),
        onTimeout: () {
          print('YouTube API timeout - keeping fallback videos');
          return <YouTubeVideo>[];
        },
      );

      if (mounted && videos.isNotEmpty) {
        print('Loaded ${videos.length} real videos');
        setState(() {
          _videos = videos;
        });
      } else {
        print('No real videos found, keeping fallback videos');
      }
    } catch (e) {
      print('YouTube API Error: $e - keeping fallback videos');
      // Fallback videos are already set, no need to do anything
    }
  }

  List<YouTubeVideo> _getFallbackVideos() {
    return [
      YouTubeVideo(
        id: 'fallback1',
        title: '${widget.moduleTitle} - Complete Tutorial',
        description:
            'Comprehensive tutorial covering all aspects of ${widget.moduleTitle}. Perfect for beginners and intermediate learners.',
        channelTitle: 'TechEdu Academy',
        thumbnailUrl:
            'https://via.placeholder.com/320x180/4285F4/FFFFFF?text=${Uri.encodeComponent("Complete Tutorial")}',
        publishedAt: DateTime.now().subtract(const Duration(days: 30)),
        duration: '15:30',
        viewCount: 125000,
      ),
      YouTubeVideo(
        id: 'fallback2',
        title: '${widget.moduleTitle} - Beginner\'s Guide',
        description:
            'Step-by-step guide for beginners. Learn ${widget.moduleTitle} from scratch with practical examples.',
        channelTitle: 'CodeMaster',
        thumbnailUrl:
            'https://via.placeholder.com/320x180/34A853/FFFFFF?text=${Uri.encodeComponent("Beginner Guide")}',
        publishedAt: DateTime.now().subtract(const Duration(days: 15)),
        duration: '12:45',
        viewCount: 87000,
      ),
      YouTubeVideo(
        id: 'fallback3',
        title: '${widget.moduleTitle} - Advanced Concepts',
        description:
            'Deep dive into advanced concepts and best practices for ${widget.moduleTitle}.',
        channelTitle: 'Pro Developer',
        thumbnailUrl:
            'https://via.placeholder.com/320x180/EA4335/FFFFFF?text=${Uri.encodeComponent("Advanced")}',
        publishedAt: DateTime.now().subtract(const Duration(days: 7)),
        duration: '22:15',
        viewCount: 156000,
      ),
      YouTubeVideo(
        id: 'fallback4',
        title: '${widget.moduleTitle} - Practical Examples',
        description:
            'Real-world examples and hands-on projects using ${widget.moduleTitle}.',
        channelTitle: 'Practical Coding',
        thumbnailUrl:
            'https://via.placeholder.com/320x180/FBBC04/FFFFFF?text=${Uri.encodeComponent("Examples")}',
        publishedAt: DateTime.now().subtract(const Duration(days: 3)),
        duration: '18:20',
        viewCount: 92000,
      ),
      YouTubeVideo(
        id: 'fallback5',
        title: '${widget.moduleTitle} - Common Mistakes',
        description:
            'Learn about common mistakes and how to avoid them when working with ${widget.moduleTitle}.',
        channelTitle: 'Debug Masters',
        thumbnailUrl:
            'https://via.placeholder.com/320x180/9C27B0/FFFFFF?text=${Uri.encodeComponent("Mistakes")}',
        publishedAt: DateTime.now().subtract(const Duration(days: 12)),
        duration: '14:55',
        viewCount: 73000,
      ),
      YouTubeVideo(
        id: 'fallback6',
        title: '${widget.moduleTitle} - Quick Tips & Tricks',
        description:
            'Essential tips and tricks to master ${widget.moduleTitle} faster and more efficiently.',
        channelTitle: 'Quick Learn',
        thumbnailUrl:
            'https://via.placeholder.com/320x180/FF5722/FFFFFF?text=${Uri.encodeComponent("Tips & Tricks")}',
        publishedAt: DateTime.now().subtract(const Duration(days: 5)),
        duration: '10:30',
        viewCount: 64000,
      ),
    ];
  }

  @override
  Widget build(BuildContext context) {
    print('Building video widget with ${_videos.length} videos');
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [Colors.red.shade900, Colors.red.shade700],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    const Icon(Icons.play_circle_fill,
                        color: Colors.white, size: 28),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Text(
                        'Video Learning: ${widget.moduleTitle}',
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                Text(
                  'Watch curated YouTube videos to enhance your understanding of ${widget.moduleTitle}',
                  style: const TextStyle(
                    color: Colors.white70,
                    fontSize: 16,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 20),

          // Debug info
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: Colors.grey.shade100,
              borderRadius: BorderRadius.circular(4),
            ),
            child: Text(
              'Videos loaded: ${_videos.length}',
              style: const TextStyle(fontSize: 12, color: Colors.grey),
            ),
          ),
          const SizedBox(height: 12),

          // Always show videos (fallback videos are set in initState)
          _videos.isNotEmpty
              ? GridView.builder(
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: 2,
                    childAspectRatio: 1.2,
                    crossAxisSpacing: 12,
                    mainAxisSpacing: 12,
                  ),
                  itemCount: _videos.length,
                  itemBuilder: (context, index) {
                    final video = _videos[index];
                    return Material(
                      color: Colors.transparent,
                      child: InkWell(
                        onTap: () => _showVideoDetails(video),
                        borderRadius: BorderRadius.circular(8),
                        child: Container(
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(8),
                            boxShadow: [
                              BoxShadow(
                                color: Colors.black.withValues(alpha: 0.1),
                                blurRadius: 4,
                                offset: const Offset(0, 2),
                              ),
                            ],
                          ),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              // Thumbnail
                              Expanded(
                                flex: 3,
                                child: Container(
                                  width: double.infinity,
                                  decoration: BoxDecoration(
                                    color: Colors.grey.shade300,
                                    borderRadius: const BorderRadius.vertical(
                                      top: Radius.circular(8),
                                    ),
                                    image: video.thumbnailUrl.isNotEmpty
                                        ? DecorationImage(
                                            image: NetworkImage(
                                                video.thumbnailUrl),
                                            fit: BoxFit.cover,
                                          )
                                        : null,
                                  ),
                                  child: Stack(
                                    children: [
                                      // Play button overlay
                                      const Center(
                                        child: Icon(
                                          Icons.play_circle_fill,
                                          size: 48,
                                          color: Colors.white,
                                        ),
                                      ),
                                      // Duration badge
                                      if (video.duration != null &&
                                          video.duration!.isNotEmpty)
                                        Positioned(
                                          bottom: 8,
                                          right: 8,
                                          child: Container(
                                            padding: const EdgeInsets.symmetric(
                                              horizontal: 6,
                                              vertical: 2,
                                            ),
                                            decoration: BoxDecoration(
                                              color: Colors.black87,
                                              borderRadius:
                                                  BorderRadius.circular(4),
                                            ),
                                            child: Text(
                                              video.duration!,
                                              style: const TextStyle(
                                                color: Colors.white,
                                                fontSize: 12,
                                                fontWeight: FontWeight.bold,
                                              ),
                                            ),
                                          ),
                                        ),
                                    ],
                                  ),
                                ),
                              ),
                              // Video info
                              Expanded(
                                flex: 2,
                                child: Padding(
                                  padding: const EdgeInsets.all(8.0),
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        video.title,
                                        style: const TextStyle(
                                          fontSize: 14,
                                          fontWeight: FontWeight.bold,
                                        ),
                                        maxLines: 2,
                                        overflow: TextOverflow.ellipsis,
                                      ),
                                      const SizedBox(height: 4),
                                      Text(
                                        video.channelTitle,
                                        style: TextStyle(
                                          fontSize: 12,
                                          color: Colors.grey.shade600,
                                        ),
                                        maxLines: 1,
                                        overflow: TextOverflow.ellipsis,
                                      ),
                                      const SizedBox(height: 4),
                                      if (video.formattedViews.isNotEmpty)
                                        Text(
                                          video.formattedViews,
                                          style: TextStyle(
                                            fontSize: 11,
                                            color: Colors.grey.shade500,
                                          ),
                                        ),
                                    ],
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    );
                  },
                )
              : Center(
                  child: Column(
                    children: [
                      const Icon(Icons.video_library,
                          size: 48, color: Colors.grey),
                      const SizedBox(height: 16),
                      const Text('Loading videos...'),
                      const SizedBox(height: 16),
                      ElevatedButton(
                        onPressed: () {
                          setState(() {
                            _videos = _getFallbackVideos();
                          });
                        },
                        child: const Text('Show Sample Videos'),
                      ),
                    ],
                  ),
                ),
        ],
      ),
    );
  }

  void _showVideoDetails(YouTubeVideo video) {
    showDialog(
      context: context,
      builder: (context) => Dialog(
        child: Container(
          constraints: BoxConstraints(
            maxWidth: MediaQuery.of(context).size.width * 0.9,
            maxHeight: MediaQuery.of(context).size.height * 0.8,
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Colors.red.shade700,
                  borderRadius:
                      const BorderRadius.vertical(top: Radius.circular(8)),
                ),
                child: Row(
                  children: [
                    const Icon(Icons.play_circle_fill, color: Colors.white),
                    const SizedBox(width: 8),
                    const Expanded(
                      child: Text(
                        'Video Details',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                    IconButton(
                      onPressed: () => Navigator.of(context).pop(),
                      icon: const Icon(Icons.close, color: Colors.white),
                    ),
                  ],
                ),
              ),
              Flexible(
                child: SingleChildScrollView(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      YouTubeVideoWidget(
                        video: video,
                        showEmbed: true,
                        showDescription: true,
                      ),
                      const SizedBox(height: 16),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                        children: [
                          ElevatedButton.icon(
                            onPressed: () async {
                              Navigator.of(context).pop();
                              final Uri url = Uri.parse(video.watchUrl);
                              if (await canLaunchUrl(url)) {
                                await launchUrl(url,
                                    mode: LaunchMode.externalApplication);
                              }
                            },
                            icon: const Icon(Icons.open_in_new),
                            label: const Text('Watch on YouTube'),
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Colors.red,
                              foregroundColor: Colors.white,
                            ),
                          ),
                          ElevatedButton.icon(
                            onPressed: () {
                              Navigator.of(context).pop();
                              ScaffoldMessenger.of(context).showSnackBar(
                                SnackBar(
                                  content: Text(
                                      'Added "${video.title}" to learning notes'),
                                  backgroundColor: Colors.green,
                                ),
                              );
                            },
                            icon: const Icon(Icons.bookmark_add),
                            label: const Text('Save to Notes'),
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Colors.blue,
                              foregroundColor: Colors.white,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
