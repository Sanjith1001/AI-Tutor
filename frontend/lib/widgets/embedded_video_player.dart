import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:video_player/video_player.dart';
import 'package:url_launcher/url_launcher.dart';
import '../services/youtube_service.dart';

class EmbeddedVideoPlayerScreen extends StatefulWidget {
  final YouTubeVideo video;

  const EmbeddedVideoPlayerScreen({
    Key? key,
    required this.video,
  }) : super(key: key);

  @override
  State<EmbeddedVideoPlayerScreen> createState() =>
      _EmbeddedVideoPlayerScreenState();
}

class _EmbeddedVideoPlayerScreenState extends State<EmbeddedVideoPlayerScreen>
    with TickerProviderStateMixin {
  VideoPlayerController? _controller;
  bool _isInitialized = false;
  bool _isLoading = true;
  bool _hasError = false;
  bool _isPlaying = false;
  String? _errorMessage;

  late AnimationController _controlsAnimationController;
  late Animation<double> _controlsAnimation;

  @override
  void initState() {
    super.initState();
    _controlsAnimationController = AnimationController(
      duration: const Duration(milliseconds: 300),
      vsync: this,
    );
    _controlsAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(
          parent: _controlsAnimationController, curve: Curves.easeInOut),
    );

    _initializePlayer();
    _startControlsTimer();
  }

  @override
  void dispose() {
    _controller?.dispose();
    _controlsAnimationController.dispose();
    super.dispose();
  }

  Future<void> _initializePlayer() async {
    setState(() {
      _isLoading = true;
      _hasError = false;
    });

    try {
      // For demo purposes, we'll use a sample video URL
      // In a real app, you'd extract the actual video URL from YouTube
      final sampleVideoUrl =
          'https://sample-videos.com/zip/10/mp4/SampleVideo_1280x720_1mb.mp4';

      _controller = VideoPlayerController.networkUrl(Uri.parse(sampleVideoUrl));

      _controller!.addListener(() {
        if (_controller!.value.hasError) {
          setState(() {
            _hasError = true;
            _errorMessage = 'Video playback failed';
            _isLoading = false;
          });
        } else if (_controller!.value.isInitialized && !_isInitialized) {
          setState(() {
            _isInitialized = true;
            _isLoading = false;
          });
        }

        if (_controller!.value.isPlaying != _isPlaying) {
          setState(() {
            _isPlaying = _controller!.value.isPlaying;
          });
        }
      });

      await _controller!.initialize();

      if (mounted) {
        setState(() {
          _isInitialized = true;
          _isLoading = false;
        });
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

  void _startControlsTimer() {
    _controlsAnimationController.forward();
    Future.delayed(const Duration(seconds: 3), () {
      if (mounted && _isPlaying) {
        _controlsAnimationController.reverse();
      }
    });
  }

  void _toggleControls() {
    if (_controlsAnimationController.isCompleted) {
      _controlsAnimationController.reverse();
    } else {
      _controlsAnimationController.forward();
      if (_isPlaying) {
        Future.delayed(const Duration(seconds: 3), () {
          if (mounted && _isPlaying) {
            _controlsAnimationController.reverse();
          }
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
        _startControlsTimer();
      }
    });
  }

  Future<void> _openInYouTube() async {
    try {
      final Uri url = Uri.parse(widget.video.watchUrl);
      if (await canLaunchUrl(url)) {
        await launchUrl(url, mode: LaunchMode.externalApplication);
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Could not open YouTube: $e')),
      );
    }
  }

  String _formatDuration(Duration duration) {
    String twoDigits(int n) => n.toString().padLeft(2, '0');
    final hours = duration.inHours;
    final minutes = duration.inMinutes.remainder(60);
    final seconds = duration.inSeconds.remainder(60);

    if (hours > 0) {
      return '$hours:${twoDigits(minutes)}:${twoDigits(seconds)}';
    } else {
      return '${twoDigits(minutes)}:${twoDigits(seconds)}';
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      body: SafeArea(
        child: Column(
          children: [
            // Video Player Area
            Expanded(
              child: Container(
                width: double.infinity,
                color: Colors.black,
                child: _buildVideoPlayer(),
              ),
            ),

            // Video Info Section
            Container(
              color: Colors.white,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Video Title and Actions
                  Padding(
                    padding: const EdgeInsets.all(16),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          widget.video.title,
                          style: const TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                            color: Colors.black87,
                          ),
                        ),
                        const SizedBox(height: 8),
                        Row(
                          children: [
                            Text(
                              '${widget.video.formattedViews} • ${widget.video.timeAgo}',
                              style: TextStyle(
                                fontSize: 14,
                                color: Colors.grey[600],
                              ),
                            ),
                            const Spacer(),
                            _buildActionButton(Icons.thumb_up, 'Like'),
                            _buildActionButton(Icons.thumb_down, 'Dislike'),
                            _buildActionButton(Icons.share, 'Share'),
                            _buildActionButton(Icons.download, 'Download'),
                          ],
                        ),
                      ],
                    ),
                  ),

                  const Divider(height: 1),

                  // Channel Info
                  Padding(
                    padding: const EdgeInsets.all(16),
                    child: Row(
                      children: [
                        Container(
                          width: 40,
                          height: 40,
                          decoration: BoxDecoration(
                            color: Colors.grey[400],
                            shape: BoxShape.circle,
                          ),
                          child: Icon(
                            Icons.account_circle,
                            color: Colors.grey[600],
                            size: 40,
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                widget.video.channelTitle,
                                style: const TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.w600,
                                  color: Colors.black87,
                                ),
                              ),
                              Text(
                                'Educational Channel',
                                style: TextStyle(
                                  fontSize: 13,
                                  color: Colors.grey[600],
                                ),
                              ),
                            ],
                          ),
                        ),
                        ElevatedButton(
                          onPressed: () {
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(content: Text('Subscribed!')),
                            );
                          },
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.red,
                            foregroundColor: Colors.white,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(20),
                            ),
                          ),
                          child: const Text('Subscribe'),
                        ),
                      ],
                    ),
                  ),

                  const Divider(height: 1),

                  // Description
                  if (widget.video.description.isNotEmpty)
                    Padding(
                      padding: const EdgeInsets.all(16),
                      child: Text(
                        widget.video.description,
                        style: TextStyle(
                          fontSize: 14,
                          color: Colors.grey[700],
                          height: 1.4,
                        ),
                        maxLines: 3,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildVideoPlayer() {
    if (_isLoading) {
      return const Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            CircularProgressIndicator(color: Colors.red),
            SizedBox(height: 16),
            Text(
              'Loading video...',
              style: TextStyle(color: Colors.white),
            ),
          ],
        ),
      );
    }

    if (_hasError) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(
              Icons.error_outline,
              color: Colors.red,
              size: 64,
            ),
            const SizedBox(height: 16),
            const Text(
              'Video Unavailable',
              style: TextStyle(
                color: Colors.white,
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              _errorMessage ?? 'Unknown error',
              style: const TextStyle(
                color: Colors.white70,
                fontSize: 14,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 24),
            ElevatedButton.icon(
              onPressed: _openInYouTube,
              icon: const Icon(Icons.open_in_new),
              label: const Text('Watch on YouTube'),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.red,
                foregroundColor: Colors.white,
              ),
            ),
          ],
        ),
      );
    }

    if (!_isInitialized || _controller == null) {
      return const Center(
        child: CircularProgressIndicator(color: Colors.red),
      );
    }

    return GestureDetector(
      onTap: _toggleControls,
      child: Stack(
        children: [
          // Video
          Center(
            child: AspectRatio(
              aspectRatio: _controller!.value.aspectRatio,
              child: VideoPlayer(_controller!),
            ),
          ),

          // Controls Overlay
          AnimatedBuilder(
            animation: _controlsAnimation,
            builder: (context, child) {
              return Opacity(
                opacity: _controlsAnimation.value,
                child: Container(
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      begin: Alignment.topCenter,
                      end: Alignment.bottomCenter,
                      colors: [
                        Colors.black.withValues(alpha: 0.7),
                        Colors.transparent,
                        Colors.transparent,
                        Colors.black.withValues(alpha: 0.7),
                      ],
                    ),
                  ),
                  child: Column(
                    children: [
                      // Top Controls
                      Padding(
                        padding: const EdgeInsets.all(16),
                        child: Row(
                          children: [
                            IconButton(
                              onPressed: () => Navigator.pop(context),
                              icon: const Icon(
                                Icons.arrow_back,
                                color: Colors.white,
                              ),
                            ),
                            const Spacer(),
                            IconButton(
                              onPressed: _openInYouTube,
                              icon: const Icon(
                                Icons.open_in_new,
                                color: Colors.white,
                              ),
                            ),
                          ],
                        ),
                      ),

                      const Spacer(),

                      // Center Play Button
                      Center(
                        child: GestureDetector(
                          onTap: _togglePlayPause,
                          child: Container(
                            padding: const EdgeInsets.all(16),
                            decoration: BoxDecoration(
                              color: Colors.black.withValues(alpha: 0.5),
                              shape: BoxShape.circle,
                            ),
                            child: Icon(
                              _isPlaying ? Icons.pause : Icons.play_arrow,
                              color: Colors.white,
                              size: 32,
                            ),
                          ),
                        ),
                      ),

                      const Spacer(),

                      // Bottom Controls
                      Padding(
                        padding: const EdgeInsets.all(16),
                        child: Column(
                          children: [
                            // Progress Bar
                            VideoProgressIndicator(
                              _controller!,
                              allowScrubbing: true,
                              colors: VideoProgressColors(
                                playedColor: Colors.red,
                                bufferedColor: Colors.grey,
                                backgroundColor:
                                    Colors.white.withValues(alpha: 0.3),
                              ),
                            ),
                            const SizedBox(height: 8),
                            // Time and Fullscreen
                            Row(
                              children: [
                                Text(
                                  '${_formatDuration(_controller!.value.position)} / ${_formatDuration(_controller!.value.duration)}',
                                  style: const TextStyle(
                                    color: Colors.white,
                                    fontSize: 12,
                                  ),
                                ),
                                const Spacer(),
                                IconButton(
                                  onPressed: () {
                                    // Toggle fullscreen
                                    SystemChrome.setEnabledSystemUIMode(
                                      SystemUiMode.immersiveSticky,
                                    );
                                  },
                                  icon: const Icon(
                                    Icons.fullscreen,
                                    color: Colors.white,
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              );
            },
          ),
        ],
      ),
    );
  }

  Widget _buildActionButton(IconData icon, String label) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 8),
      child: Column(
        children: [
          IconButton(
            onPressed: () {
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(content: Text('$label pressed')),
              );
            },
            icon: Icon(icon, size: 20),
            padding: EdgeInsets.zero,
            constraints: const BoxConstraints(minWidth: 32, minHeight: 32),
          ),
          Text(
            label,
            style: const TextStyle(fontSize: 10),
          ),
        ],
      ),
    );
  }
}
