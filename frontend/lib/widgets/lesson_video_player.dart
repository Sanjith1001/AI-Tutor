import 'package:flutter/material.dart';
import 'package:video_player/video_player.dart';
import 'package:url_launcher/url_launcher.dart';

class LessonVideoPlayer extends StatefulWidget {
  final String videoUrl;
  final String title;
  final String? description;
  final bool autoPlay;

  const LessonVideoPlayer({
    Key? key,
    required this.videoUrl,
    required this.title,
    this.description,
    this.autoPlay = false,
  }) : super(key: key);

  @override
  State<LessonVideoPlayer> createState() => _LessonVideoPlayerState();
}

class _LessonVideoPlayerState extends State<LessonVideoPlayer> {
  VideoPlayerController? _controller;
  bool _isInitialized = false;
  bool _isLoading = false;
  bool _hasError = false;
  String? _errorMessage;
  bool _showPlayButton = true;

  @override
  void dispose() {
    _controller?.dispose();
    super.dispose();
  }

  Future<void> _initializeVideo() async {
    if (_controller != null) return;

    setState(() {
      _isLoading = true;
      _hasError = false;
      _showPlayButton = false;
    });

    try {
      // Check if it's a YouTube URL
      if (_isYouTubeUrl(widget.videoUrl)) {
        await _openInBrowser();
        setState(() {
          _isLoading = false;
          _showPlayButton = true;
        });
        return;
      }

      _controller =
          VideoPlayerController.networkUrl(Uri.parse(widget.videoUrl));

      // Add error listener
      _controller!.addListener(() {
        if (_controller!.value.hasError && mounted) {
          setState(() {
            _hasError = true;
            _errorMessage = 'Video playback failed';
            _isLoading = false;
            _showPlayButton = true;
          });
        }
      });

      await _controller!.initialize();

      if (mounted) {
        setState(() {
          _isInitialized = true;
          _isLoading = false;
        });

        if (widget.autoPlay) {
          await _controller!.play();
        }
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _hasError = true;
          _errorMessage = 'Failed to load video: ${e.toString()}';
          _isLoading = false;
          _showPlayButton = true;
        });
      }
    }
  }

  bool _isYouTubeUrl(String url) {
    return url.contains('youtube.com') ||
        url.contains('youtu.be') ||
        url.contains('youtube-nocookie.com');
  }

  Future<void> _openInBrowser() async {
    try {
      final Uri url = Uri.parse(widget.videoUrl);
      if (await canLaunchUrl(url)) {
        await launchUrl(url, mode: LaunchMode.externalApplication);
      } else {
        throw 'Could not launch video';
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _hasError = true;
          _errorMessage = 'Could not open video';
          _isLoading = false;
        });
      }
    }
  }

  void _togglePlayPause() {
    if (_controller == null) return;

    setState(() {
      if (_controller!.value.isPlaying) {
        _controller!.pause();
      } else {
        _controller!.play();
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.all(8),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Video Player Area
          Container(
            width: double.infinity,
            height: 200,
            decoration: BoxDecoration(
              color: Colors.black,
              borderRadius: const BorderRadius.vertical(
                top: Radius.circular(8),
              ),
            ),
            child: ClipRRect(
              borderRadius: const BorderRadius.vertical(
                top: Radius.circular(8),
              ),
              child: Stack(
                children: [
                  // Video Player
                  if (_isInitialized && _controller != null)
                    Positioned.fill(
                      child: AspectRatio(
                        aspectRatio: _controller!.value.aspectRatio,
                        child: VideoPlayer(_controller!),
                      ),
                    ),

                  // Loading Indicator
                  if (_isLoading)
                    const Positioned.fill(
                      child: Center(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            CircularProgressIndicator(color: Colors.white),
                            SizedBox(height: 8),
                            Text(
                              'Loading video...',
                              style: TextStyle(color: Colors.white),
                            ),
                          ],
                        ),
                      ),
                    ),

                  // Error Display
                  if (_hasError)
                    Positioned.fill(
                      child: Container(
                        color: Colors.black87,
                        child: Center(
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              const Icon(
                                Icons.error_outline,
                                color: Colors.red,
                                size: 48,
                              ),
                              const SizedBox(height: 8),
                              const Text(
                                'Video Unavailable',
                                style: TextStyle(
                                  color: Colors.white,
                                  fontSize: 16,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              const SizedBox(height: 4),
                              Text(
                                _errorMessage ?? 'Unknown error',
                                style: const TextStyle(
                                  color: Colors.white70,
                                  fontSize: 12,
                                ),
                                textAlign: TextAlign.center,
                              ),
                              const SizedBox(height: 16),
                              Row(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  ElevatedButton.icon(
                                    onPressed: () {
                                      setState(() {
                                        _hasError = false;
                                        _controller?.dispose();
                                        _controller = null;
                                        _isInitialized = false;
                                        _showPlayButton = true;
                                      });
                                    },
                                    icon: const Icon(Icons.refresh),
                                    label: const Text('Retry'),
                                  ),
                                  const SizedBox(width: 8),
                                  ElevatedButton.icon(
                                    onPressed: _openInBrowser,
                                    icon: const Icon(Icons.open_in_new),
                                    label: const Text('Open External'),
                                  ),
                                ],
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),

                  // Play Button Overlay
                  if (_showPlayButton && !_isLoading && !_hasError)
                    Positioned.fill(
                      child: Container(
                        color: Colors.black54,
                        child: Center(
                          child: GestureDetector(
                            onTap: _initializeVideo,
                            child: Container(
                              padding: const EdgeInsets.all(20),
                              decoration: BoxDecoration(
                                color: Colors.black54,
                                shape: BoxShape.circle,
                                border:
                                    Border.all(color: Colors.white, width: 2),
                              ),
                              child: const Icon(
                                Icons.play_arrow,
                                color: Colors.white,
                                size: 40,
                              ),
                            ),
                          ),
                        ),
                      ),
                    ),

                  // Video Controls
                  if (_isInitialized && !_hasError)
                    Positioned(
                      bottom: 0,
                      left: 0,
                      right: 0,
                      child: Container(
                        padding: const EdgeInsets.all(8),
                        decoration: BoxDecoration(
                          gradient: LinearGradient(
                            begin: Alignment.topCenter,
                            end: Alignment.bottomCenter,
                            colors: [
                              Colors.transparent,
                              Colors.black.withValues(alpha: 0.7),
                            ],
                          ),
                        ),
                        child: Row(
                          children: [
                            IconButton(
                              onPressed: _togglePlayPause,
                              icon: Icon(
                                _controller!.value.isPlaying
                                    ? Icons.pause
                                    : Icons.play_arrow,
                                color: Colors.white,
                              ),
                            ),
                            Expanded(
                              child: VideoProgressIndicator(
                                _controller!,
                                allowScrubbing: true,
                                colors: VideoProgressColors(
                                  playedColor: Colors.blue,
                                  bufferedColor: Colors.grey,
                                  backgroundColor:
                                      Colors.white.withValues(alpha: 0.3),
                                ),
                              ),
                            ),
                            IconButton(
                              onPressed: _openInBrowser,
                              icon: const Icon(
                                Icons.open_in_new,
                                color: Colors.white,
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

          // Video Info
          Padding(
            padding: const EdgeInsets.all(12),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  widget.title,
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  ),
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
                if (widget.description != null) ...[
                  const SizedBox(height: 8),
                  Text(
                    widget.description!,
                    style: TextStyle(
                      fontSize: 14,
                      color: Colors.grey[600],
                    ),
                    maxLines: 3,
                    overflow: TextOverflow.ellipsis,
                  ),
                ],
                const SizedBox(height: 8),
                Row(
                  children: [
                    Icon(Icons.play_circle_outline,
                        size: 16, color: Colors.grey[600]),
                    const SizedBox(width: 4),
                    Text(
                      'Tap to play video',
                      style: TextStyle(
                        fontSize: 12,
                        color: Colors.grey[600],
                      ),
                    ),
                    const Spacer(),
                    TextButton.icon(
                      onPressed: _openInBrowser,
                      icon: const Icon(Icons.open_in_new, size: 16),
                      label: const Text('External'),
                      style: TextButton.styleFrom(
                        padding: const EdgeInsets.symmetric(horizontal: 8),
                        minimumSize: const Size(0, 32),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
