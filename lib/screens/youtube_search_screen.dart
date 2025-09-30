// screens/youtube_search_screen.dart

import 'package:flutter/material.dart';
import '../services/youtube_service.dart';
import '../widgets/youtube_video_widget.dart';

class YouTubeSearchScreen extends StatefulWidget {
  final String initialQuery;
  final String moduleTitle;

  const YouTubeSearchScreen({
    Key? key,
    required this.initialQuery,
    required this.moduleTitle,
  }) : super(key: key);

  @override
  State<YouTubeSearchScreen> createState() => _YouTubeSearchScreenState();
}

class _YouTubeSearchScreenState extends State<YouTubeSearchScreen> {
  final TextEditingController _searchController = TextEditingController();
  List<YouTubeVideo> _videos = [];
  bool _isLoading = false;
  String? _error;
  String _currentQuery = '';

  @override
  void initState() {
    super.initState();
    _searchController.text = widget.initialQuery;
    _currentQuery = widget.initialQuery;
    _searchVideos(widget.initialQuery);
  }

  Future<void> _searchVideos(String query) async {
    if (query.trim().isEmpty) {
      print('🔴 YouTubeSearchScreen: Empty query provided');
      return;
    }

    setState(() {
      _isLoading = true;
      _error = null;
    });

    // Print debug information
    YouTubeService.printDebugInfo(query: query);

    try {
      // Only validate API key on first search to avoid too many validation calls
      if (_videos.isEmpty) {
        final isValidKey = await YouTubeService.validateApiKey();
        if (!isValidKey) {
          throw Exception(
              'YouTube API key is invalid or not working. Please check your .env file and ensure YouTube Data API v3 is enabled.');
        }
      }

      final videos = await YouTubeService.searchVideos(
        query: query,
        maxResults: 12,
      );
      setState(() {
        _videos = videos;
        _currentQuery = query;
      });
    } catch (e) {
      setState(() {
        _error = e.toString();
      });
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('${widget.moduleTitle} - Videos'),
        backgroundColor: Colors.blue[700],
        foregroundColor: Colors.white,
      ),
      body: Column(
        children: [
          // Search bar
          Container(
            padding: const EdgeInsets.all(16.0),
            color: Colors.grey[50],
            child: Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: _searchController,
                    decoration: InputDecoration(
                      hintText: 'Search YouTube videos...',
                      prefixIcon: const Icon(Icons.search),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                      filled: true,
                      fillColor: Colors.white,
                    ),
                    onSubmitted: _searchVideos,
                  ),
                ),
                const SizedBox(width: 8),
                ElevatedButton(
                  onPressed: () => _searchVideos(_searchController.text),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.blue[700],
                    foregroundColor: Colors.white,
                  ),
                  child: const Text('Search'),
                ),
              ],
            ),
          ),

          // Search suggestions
          if (_currentQuery == widget.initialQuery) _buildSuggestions(),

          // Results
          Expanded(
            child: _buildContent(),
          ),
        ],
      ),
    );
  }

  Widget _buildSuggestions() {
    final suggestions = _getSearchSuggestions();
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Suggested Searches:',
            style: TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.bold,
              color: Colors.grey[700],
            ),
          ),
          const SizedBox(height: 8),
          Wrap(
            spacing: 8,
            children: suggestions.map((suggestion) {
              return ActionChip(
                label: Text(suggestion),
                onPressed: () {
                  _searchController.text = suggestion;
                  _searchVideos(suggestion);
                },
                backgroundColor: Colors.blue[50],
              );
            }).toList(),
          ),
        ],
      ),
    );
  }

  Widget _buildContent() {
    if (_isLoading) {
      return const Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            CircularProgressIndicator(),
            SizedBox(height: 16),
            Text('Searching YouTube videos...'),
          ],
        ),
      );
    }

    if (_error != null) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.error_outline, size: 64, color: Colors.red[400]),
            const SizedBox(height: 16),
            Text(
              'Error loading videos',
              style: TextStyle(fontSize: 18, color: Colors.red[700]),
            ),
            const SizedBox(height: 8),
            Text(
              _error!,
              textAlign: TextAlign.center,
              style: TextStyle(color: Colors.grey[600]),
            ),
            const SizedBox(height: 16),
            ElevatedButton(
              onPressed: () => _searchVideos(_currentQuery),
              child: const Text('Retry'),
            ),
          ],
        ),
      );
    }

    if (_videos.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.video_library_outlined,
                size: 64, color: Colors.grey[400]),
            const SizedBox(height: 16),
            Text(
              'No videos found',
              style: TextStyle(fontSize: 18, color: Colors.grey[600]),
            ),
            const SizedBox(height: 8),
            Text(
              'Try searching with different keywords',
              style: TextStyle(color: Colors.grey[500]),
            ),
          ],
        ),
      );
    }

    return GridView.builder(
      padding: const EdgeInsets.all(16),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        childAspectRatio: 0.75,
        crossAxisSpacing: 16,
        mainAxisSpacing: 16,
      ),
      itemCount: _videos.length,
      itemBuilder: (context, index) {
        final video = _videos[index];
        return YouTubeVideoWidget(
          video: video,
          showDescription: false,
          onTap: () => _showVideoDetails(video),
        );
      },
    );
  }

  void _showVideoDetails(YouTubeVideo video) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(video.title),
        content: SizedBox(
          width: MediaQuery.of(context).size.width * 0.8,
          height: MediaQuery.of(context).size.height * 0.6,
          child: YouTubeVideoWidget(
            video: video,
            showEmbed: true,
            showDescription: true,
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Close'),
          ),
        ],
      ),
    );
  }

  List<String> _getSearchSuggestions() {
    // Generate module-specific search suggestions
    final baseQuery = widget.initialQuery.toLowerCase();

    if (baseQuery.contains('html') || baseQuery.contains('css')) {
      return [
        'HTML CSS tutorial',
        'responsive web design',
        'CSS flexbox grid',
        'HTML semantic elements',
        'CSS animations',
        'frontend web development',
      ];
    } else if (baseQuery.contains('data') &&
        baseQuery.contains('preprocessing')) {
      return [
        'data preprocessing tutorial',
        'machine learning data cleaning',
        'pandas data manipulation',
        'feature engineering',
        'data analysis python',
        'ML data preparation',
      ];
    } else if (baseQuery.contains('state management')) {
      return [
        'Flutter state management',
        'Provider Riverpod tutorial',
        'BLoC pattern Flutter',
        'setState vs Provider',
        'Flutter app architecture',
        'reactive programming',
      ];
    } else if (baseQuery.contains('machine learning')) {
      return [
        'machine learning basics',
        'ML algorithms explained',
        'deep learning tutorial',
        'neural networks',
        'AI fundamentals',
        'ML model training',
      ];
    }

    return [
      '${widget.initialQuery} tutorial',
      '${widget.initialQuery} explained',
      '${widget.initialQuery} for beginners',
      '${widget.initialQuery} advanced',
      '${widget.initialQuery} examples',
    ];
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }
}
