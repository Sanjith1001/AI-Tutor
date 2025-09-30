// Debug screen for YouTube API testing
// Add this to your app for easy debugging

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../services/youtube_service.dart';

class YouTubeDebugScreen extends StatefulWidget {
  const YouTubeDebugScreen({Key? key}) : super(key: key);

  @override
  State<YouTubeDebugScreen> createState() => _YouTubeDebugScreenState();
}

class _YouTubeDebugScreenState extends State<YouTubeDebugScreen> {
  final _queryController = TextEditingController(text: 'Flutter tutorial');
  bool _isLoading = false;
  String? _result;
  List<YouTubeVideo> _videos = [];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('YouTube API Debug'),
        backgroundColor: Colors.red,
        foregroundColor: Colors.white,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // API Key Info
            Card(
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'API Key Status',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      YouTubeService.apiKey.isEmpty
                          ? '❌ No API key found'
                          : '✅ API key: ${YouTubeService.apiKey.substring(0, 8)}...${YouTubeService.apiKey.substring(YouTubeService.apiKey.length - 4)}',
                    ),
                  ],
                ),
              ),
            ),

            const SizedBox(height: 16),

            // Test Controls
            Card(
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Test YouTube API',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 8),
                    TextField(
                      controller: _queryController,
                      decoration: const InputDecoration(
                        labelText: 'Search Query',
                        border: OutlineInputBorder(),
                      ),
                    ),
                    const SizedBox(height: 16),
                    Row(
                      children: [
                        Expanded(
                          child: ElevatedButton(
                            onPressed: _isLoading ? null : _validateApiKey,
                            child: const Text('Validate API Key'),
                          ),
                        ),
                        const SizedBox(width: 8),
                        Expanded(
                          child: ElevatedButton(
                            onPressed: _isLoading ? null : _searchVideos,
                            child: const Text('Search Videos'),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 8),
                    Row(
                      children: [
                        Expanded(
                          child: ElevatedButton(
                            onPressed: _copyTestUrl,
                            child: const Text('Copy Test URL'),
                          ),
                        ),
                        const SizedBox(width: 8),
                        Expanded(
                          child: ElevatedButton(
                            onPressed: _showDebugInfo,
                            child: const Text('Show Debug Info'),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),

            const SizedBox(height: 16),

            // Results
            if (_isLoading)
              const Card(
                child: Padding(
                  padding: EdgeInsets.all(16.0),
                  child: Row(
                    children: [
                      CircularProgressIndicator(),
                      SizedBox(width: 16),
                      Text('Testing...'),
                    ],
                  ),
                ),
              ),

            if (_result != null && !_isLoading)
              Card(
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'Result',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 8),
                      SelectableText(_result!),
                    ],
                  ),
                ),
              ),

            // Videos List
            if (_videos.isNotEmpty)
              Expanded(
                child: Card(
                  child: Column(
                    children: [
                      const Padding(
                        padding: EdgeInsets.all(16.0),
                        child: Text(
                          'Found Videos',
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                      Expanded(
                        child: ListView.builder(
                          itemCount: _videos.length,
                          itemBuilder: (context, index) {
                            final video = _videos[index];
                            return ListTile(
                              leading: video.thumbnailUrl.isNotEmpty
                                  ? Image.network(
                                      video.thumbnailUrl,
                                      width: 60,
                                      height: 45,
                                      fit: BoxFit.cover,
                                    )
                                  : const Icon(Icons.video_library),
                              title: Text(
                                video.title,
                                maxLines: 2,
                                overflow: TextOverflow.ellipsis,
                              ),
                              subtitle: Text(
                                '${video.channelTitle} • ${video.timeAgo}',
                                style: TextStyle(
                                  color: Colors.grey[600],
                                  fontSize: 12,
                                ),
                              ),
                              onTap: () {
                                showDialog(
                                  context: context,
                                  builder: (context) => AlertDialog(
                                    title: Text(video.title),
                                    content: Column(
                                      mainAxisSize: MainAxisSize.min,
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        Text('Channel: ${video.channelTitle}'),
                                        Text('Published: ${video.timeAgo}'),
                                        Text('Video ID: ${video.id}'),
                                        Text('URL: ${video.watchUrl}'),
                                      ],
                                    ),
                                    actions: [
                                      TextButton(
                                        onPressed: () =>
                                            Navigator.of(context).pop(),
                                        child: const Text('Close'),
                                      ),
                                    ],
                                  ),
                                );
                              },
                            );
                          },
                        ),
                      ),
                    ],
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }

  Future<void> _validateApiKey() async {
    setState(() {
      _isLoading = true;
      _result = null;
    });

    try {
      final isValid = await YouTubeService.validateApiKey();
      setState(() {
        _result = isValid
            ? '✅ API Key is valid and working!'
            : '❌ API Key validation failed. Check console for details.';
      });
    } catch (e) {
      setState(() {
        _result = '❌ Error validating API key: $e';
      });
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  Future<void> _searchVideos() async {
    if (_queryController.text.trim().isEmpty) {
      setState(() {
        _result = '❌ Please enter a search query';
      });
      return;
    }

    setState(() {
      _isLoading = true;
      _result = null;
      _videos = [];
    });

    try {
      final videos = await YouTubeService.searchVideos(
        query: _queryController.text,
        maxResults: 5,
      );

      setState(() {
        _videos = videos;
        _result = videos.isEmpty
            ? '⚠️ No videos found for "${_queryController.text}"'
            : '✅ Found ${videos.length} videos for "${_queryController.text}"';
      });
    } catch (e) {
      setState(() {
        _result = '❌ Error searching videos: $e';
      });
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  void _copyTestUrl() {
    final url = YouTubeService.getTestUrl(query: _queryController.text);
    Clipboard.setData(ClipboardData(text: url));

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content:
            Text('Test URL copied to clipboard! Paste it in your browser.'),
      ),
    );

    setState(() {
      _result = 'Test URL copied to clipboard:\n$url';
    });
  }

  void _showDebugInfo() {
    YouTubeService.printDebugInfo(query: _queryController.text);

    setState(() {
      _result = '''Debug information printed to console.

API Key: ${YouTubeService.apiKey.isEmpty ? "NOT SET" : "${YouTubeService.apiKey.substring(0, 8)}...${YouTubeService.apiKey.substring(YouTubeService.apiKey.length - 4)}"}
Query: "${_queryController.text}"
Base URL: ${YouTubeService.baseUrl}

Check the console/debug output for more details.''';
    });
  }

  @override
  void dispose() {
    _queryController.dispose();
    super.dispose();
  }
}
