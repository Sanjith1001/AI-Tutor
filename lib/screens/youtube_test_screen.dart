// Test screen for YouTube widgets
import 'package:flutter/material.dart';
import '../services/youtube_service.dart';
import '../widgets/youtube_video_widget.dart';

class YouTubeTestScreen extends StatefulWidget {
  const YouTubeTestScreen({Key? key}) : super(key: key);

  @override
  State<YouTubeTestScreen> createState() => _YouTubeTestScreenState();
}

class _YouTubeTestScreenState extends State<YouTubeTestScreen> {
  List<YouTubeVideo> _videos = [];
  bool _isLoading = false;
  String? _error;

  @override
  void initState() {
    super.initState();
    _loadTestVideos();
  }

  Future<void> _loadTestVideos() async {
    setState(() {
      _isLoading = true;
      _error = null;
    });

    try {
      final videos = await YouTubeService.searchVideos(
        query: 'Flutter tutorial',
        maxResults: 6,
      );

      setState(() {
        _videos = videos;
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
        title: const Text('YouTube Widget Test'),
        backgroundColor: Colors.red,
        foregroundColor: Colors.white,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Compact YouTube Video Cards Test',
              style: TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 16),
            if (_isLoading)
              const Center(
                child: CircularProgressIndicator(),
              )
            else if (_error != null)
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Colors.red[100],
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Error:',
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        color: Colors.red,
                      ),
                    ),
                    Text(_error!),
                    const SizedBox(height: 8),
                    ElevatedButton(
                      onPressed: _loadTestVideos,
                      child: const Text('Retry'),
                    ),
                  ],
                ),
              )
            else if (_videos.isNotEmpty)
              Expanded(
                child: GridView.builder(
                  gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: 2,
                    childAspectRatio: 1.6,
                    crossAxisSpacing: 12,
                    mainAxisSpacing: 12,
                  ),
                  itemCount: _videos.length,
                  itemBuilder: (context, index) {
                    final video = _videos[index];
                    return YouTubeVideoWidget(
                      video: video,
                      compact: true,
                      onTap: () {
                        showDialog(
                          context: context,
                          builder: (context) => AlertDialog(
                            title: Text(video.title),
                            content: Column(
                              mainAxisSize: MainAxisSize.min,
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text('Channel: ${video.channelTitle}'),
                                Text(
                                    'Duration: ${video.duration ?? 'Unknown'}'),
                                Text('Views: ${video.formattedViews}'),
                                Text('Published: ${video.timeAgo}'),
                              ],
                            ),
                            actions: [
                              TextButton(
                                onPressed: () => Navigator.of(context).pop(),
                                child: const Text('Close'),
                              ),
                            ],
                          ),
                        );
                      },
                    );
                  },
                ),
              )
            else
              const Center(
                child: Text('No videos found'),
              ),
          ],
        ),
      ),
    );
  }
}
