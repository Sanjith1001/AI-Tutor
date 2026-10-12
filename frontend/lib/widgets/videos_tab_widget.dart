import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';
import '../services/youtube_service.dart';
import 'youtube_shorts_carousel.dart';
import 'youtube_video_card.dart';

class VideosTabWidget extends StatefulWidget {
  final String? searchQuery;

  const VideosTabWidget({
    Key? key,
    this.searchQuery,
  }) : super(key: key);

  @override
  State<VideosTabWidget> createState() => _VideosTabWidgetState();
}

class _VideosTabWidgetState extends State<VideosTabWidget> {
  bool _isLoading = true;
  bool _hasError = false;
  String? _errorMessage;
  List<YouTubeVideo> _allVideos = [];
  List<YouTubeVideo> _shortsVideos = [];
  List<YouTubeVideo> _regularVideos = [];

  @override
  void initState() {
    super.initState();
    _loadVideos();
  }

  @override
  void didUpdateWidget(VideosTabWidget oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.searchQuery != oldWidget.searchQuery) {
      _loadVideos();
    }
  }

  Future<void> _loadVideos() async {
    setState(() {
      _isLoading = true;
      _hasError = false;
      _errorMessage = null;
    });

    try {
      // Use search query or default to educational content
      final query = widget.searchQuery ?? 'educational tutorial';

      print('🔵 VideosTabWidget: Loading videos for query: "$query"');

      // Search for videos
      final videos = await YouTubeService.searchVideos(
        query: query,
        maxResults: 20,
      );

      if (!mounted) return;

      // Separate shorts from regular videos
      // Note: In real implementation, you'd filter by duration or use YouTube Shorts API
      // For demo, we'll use the first 5 videos as "shorts"
      final shorts = videos.take(5).toList();
      final regular = videos.skip(5).toList();

      setState(() {
        _allVideos = videos;
        _shortsVideos = shorts;
        _regularVideos = regular;
        _isLoading = false;
      });

      print(
          '🟢 VideosTabWidget: Loaded ${videos.length} videos (${shorts.length} shorts, ${regular.length} regular)');
    } catch (e) {
      print('🔴 VideosTabWidget Error: $e');
      if (!mounted) return;

      setState(() {
        _hasError = true;
        _errorMessage = e.toString();
        _isLoading = false;
      });
    }
  }

  Future<void> _openVideoPlayer(YouTubeVideo video) async {
    final url = Uri.parse(video.watchUrl);
    if (await canLaunchUrl(url)) {
      await launchUrl(url, mode: LaunchMode.externalApplication);
    } else if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Could not open this YouTube video.')),
      );
    }
  }

  Future<void> _onRefresh() async {
    await _loadVideos();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: RefreshIndicator(
        onRefresh: _onRefresh,
        color: Colors.red,
        child: _buildBody(),
      ),
    );
  }

  Widget _buildBody() {
    if (_isLoading) {
      return _buildLoadingState();
    }

    if (_hasError) {
      return _buildErrorState();
    }

    if (_allVideos.isEmpty) {
      return _buildEmptyState();
    }

    return CustomScrollView(
      slivers: [
        // Shorts Carousel Section
        if (_shortsVideos.isNotEmpty)
          SliverToBoxAdapter(
            child: YouTubeShortsCarousel(
              shorts: _shortsVideos,
              onShortTap: _openVideoPlayer,
            ),
          ),

        // Divider
        SliverToBoxAdapter(
          child: Container(
            height: 8,
            color: Colors.grey[100],
          ),
        ),

        // Regular Videos Section Header
        SliverToBoxAdapter(
          child: Padding(
            padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
            child: Row(
              children: [
                const Text(
                  'Recommended',
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    color: Colors.black87,
                  ),
                ),
                const Spacer(),
                Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                  decoration: BoxDecoration(
                    color: Colors.grey[100],
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(
                        Icons.tune,
                        color: Colors.grey[700],
                        size: 16,
                      ),
                      const SizedBox(width: 4),
                      Text(
                        'Filter',
                        style: TextStyle(
                          color: Colors.grey[700],
                          fontWeight: FontWeight.w500,
                          fontSize: 14,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),

        // Regular Videos List
        SliverList(
          delegate: SliverChildBuilderDelegate(
            (context, index) {
              final video = _regularVideos[index];
              return YouTubeVideoCard(
                video: video,
                onTap: () => _openVideoPlayer(video),
              );
            },
            childCount: _regularVideos.length,
          ),
        ),

        // Bottom padding
        const SliverToBoxAdapter(
          child: SizedBox(height: 16),
        ),
      ],
    );
  }

  Widget _buildLoadingState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const CircularProgressIndicator(
            color: Colors.red,
          ),
          const SizedBox(height: 16),
          Text(
            'Loading videos...',
            style: TextStyle(
              fontSize: 16,
              color: Colors.grey[600],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildErrorState() {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.error_outline,
              size: 64,
              color: Colors.red[400],
            ),
            const SizedBox(height: 16),
            const Text(
              'Oops! Something went wrong',
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: Colors.black87,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 8),
            Text(
              _errorMessage ?? 'Failed to load videos',
              style: TextStyle(
                fontSize: 14,
                color: Colors.grey[600],
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 24),
            ElevatedButton.icon(
              onPressed: _loadVideos,
              icon: const Icon(Icons.refresh),
              label: const Text('Try Again'),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.red,
                foregroundColor: Colors.white,
                padding:
                    const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.video_library_outlined,
              size: 64,
              color: Colors.grey[400],
            ),
            const SizedBox(height: 16),
            const Text(
              'No videos found',
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: Colors.black87,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'Try adjusting your search or check back later',
              style: TextStyle(
                fontSize: 14,
                color: Colors.grey[600],
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 24),
            ElevatedButton.icon(
              onPressed: _loadVideos,
              icon: const Icon(Icons.refresh),
              label: const Text('Refresh'),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.red,
                foregroundColor: Colors.white,
                padding:
                    const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
