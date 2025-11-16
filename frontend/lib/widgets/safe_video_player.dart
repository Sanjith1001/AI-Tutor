import 'package:flutter/material.dart';
import 'package:video_player/video_player.dart';
import 'package:url_launcher/url_launcher.dart';

class SafeVideoPlayer extends StatefulWidget {
  final String videoUrl;
  final String? thumbnailUrl;
  final String title;
  final bool autoPlay;
  final bool showControls;

  const SafeVideoPlayer({
    Key? key,
    required this.videoUrl,
    this.thumbnailUrl,
    required this.title,
    this.autoPlay = false,
    this.showControls = true,
  }) : super(key: key);

  @override
  State<SafeVideoPlayer> createState() => _SafeVideoPlayerState();
}

class _SafeVideoPlayerState extends State<SafeVideoPlayer> {
  VideoPlayerController? _controller;
  bool _isInitialized = false;
  bool _isLoading = false;
  bool _hasError = false;
  String? _errorMessage;
  bool _showThumbnail = true;

  @override
  void initState() {
    super.initState();
    // Don't auto-initialize to prevent blocking
    // User must tap to play
  }

  Future<void> _initializeVideo() async {
    if (_controller != null) return;

    setState(() {
      _isLoading = true;
      _hasError = false;
      _errorMessage = null;
    });

    try {
      // Check if it's a YouTube URL and handle differently
      if (widget.videoUrl.contains('youtube.com') ||
          widget.videoUrl.contains('youtu.be')) {
        // For YouTube videos, open in external app instead of trying to play inline
        await _openInExternalApp();
        return;
      }

      _controller =
          VideoPlayerController.networkUrl(Uri.parse(widget.videoUrl));

      // Set up error handling
      _controller!.addListener(() {
        if (_controller!.value.hasError) {
          setState(() {
            _hasError = true;
            _errorMessage =
                _controller!.value.errorDescription ?? 'Video playback error';
            _isLoading = false;
          });
        }
      });

      await _controller!.initialize();

      if (mounted) {
        setState(() {
          _isInitialized = true;
          _isLoading = false;
          _showThumbnail = false;
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
        });
      }
    }
  }

  Future<void> _openInExternalApp() async {
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
          _errorMessage = 'Could not open video: ${e.toString()}';
          _isLoading = false;
        });
      }
    }
  }

  @override
  void dispose() {
    _controller?.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      height: 200,
      decoration: BoxDecoration(
        color: Colors.black,
        borderRadius: BorderRadius.circular(8),
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(8),
        child: Stack(
          children: [
            // Background/Thumbnail
            if (_showThumbnail && widget.thumbnailUrl != null)
              Positioned.fill(
                child: Image.network(
                  widget.thumbnailUrl!,
                  fit: BoxFit.cover,
                  errorBuilder: (context, error, stackTrace) {
                    return Container(
                      color: Colors.grey[800],
                      child: const Icon(
                        Icons.video_library,
                        color: Colors.white,
                        size: 48,
                      ),
                    );
                  },
                ),
              ),

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
                  child: CircularProgressIndicator(
                    color: Colors.white,
                  ),
                ),
              ),

            // Error Display
            if (_hasError)
              Positioned.fill(
                child: Container(
                  color: Colors.black54,
                  child: Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const Icon(
                          Icons.error_outline,
                          color: Colors.white,
                          size: 48,
                        ),
                        const SizedBox(height: 8),
                        Text(
                          'Video Error',
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 16),
                          child: Text(
                            _errorMessage ?? 'Unknown error',
                            style: const TextStyle(
                              color: Colors.white70,
                              fontSize: 12,
                            ),
                            textAlign: TextAlign.center,
                            maxLines: 2,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                        const SizedBox(height: 8),
                        ElevatedButton(
                          onPressed: _openInExternalApp,
                          child: const Text('Open Externally'),
                        ),
                      ],
                    ),
                  ),
                ),
              ),

            // Play Button Overlay
            if (!_isInitialized && !_isLoading && !_hasError)
              Positioned.fill(
                child: Container(
                  color: Colors.black54,
                  child: Center(
                    child: GestureDetector(
                      onTap: _initializeVideo,
                      child: Container(
                        padding: const EdgeInsets.all(16),
                        decoration: BoxDecoration(
                          color: Colors.black54,
                          shape: BoxShape.circle,
                        ),
                        child: const Icon(
                          Icons.play_arrow,
                          color: Colors.white,
                          size: 48,
                        ),
                      ),
                    ),
                  ),
                ),
              ),

            // Video Controls
            if (_isInitialized && widget.showControls)
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
                        Colors.black54,
                      ],
                    ),
                  ),
                  child: Row(
                    children: [
                      IconButton(
                        onPressed: () {
                          if (_controller!.value.isPlaying) {
                            _controller!.pause();
                          } else {
                            _controller!.play();
                          }
                          setState(() {});
                        },
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
                            backgroundColor: Colors.white24,
                          ),
                        ),
                      ),
                      IconButton(
                        onPressed: _openInExternalApp,
                        icon: const Icon(
                          Icons.open_in_new,
                          color: Colors.white,
                        ),
                      ),
                    ],
                  ),
                ),
              ),

            // Title Overlay
            Positioned(
              top: 8,
              left: 8,
              right: 8,
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: Colors.black54,
                  borderRadius: BorderRadius.circular(4),
                ),
                child: Text(
                  widget.title,
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 12,
                    fontWeight: FontWeight.bold,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
