import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';
import '../utils/image_helper.dart';

// Helper function to format time ago
String _formatTimeAgo(DateTime publishedDate) {
  final now = DateTime.now();
  final difference = now.difference(publishedDate);

  if (difference.inDays >= 365) {
    final years = (difference.inDays / 365).floor();
    return '${years} year${years > 1 ? 's' : ''} ago';
  } else if (difference.inDays >= 30) {
    final months = (difference.inDays / 30).floor();
    return '${months} month${months > 1 ? 's' : ''} ago';
  } else if (difference.inDays >= 7) {
    final weeks = (difference.inDays / 7).floor();
    return '${weeks} week${weeks > 1 ? 's' : ''} ago';
  } else if (difference.inDays >= 1) {
    return '${difference.inDays} day${difference.inDays > 1 ? 's' : ''} ago';
  } else if (difference.inHours >= 1) {
    return '${difference.inHours} hour${difference.inHours > 1 ? 's' : ''} ago';
  } else if (difference.inMinutes >= 1) {
    return '${difference.inMinutes} minute${difference.inMinutes > 1 ? 's' : ''} ago';
  } else {
    return 'Just now';
  }
}

// Helper function to format view count
String _formatViewCount(String viewCount) {
  final count = int.tryParse(viewCount.replaceAll(',', ''));
  if (count == null) return viewCount;

  if (count >= 1000000000) {
    return '${(count / 1000000000).toStringAsFixed(1)}B views';
  } else if (count >= 1000000) {
    return '${(count / 1000000).toStringAsFixed(1)}M views';
  } else if (count >= 1000) {
    return '${(count / 1000).toStringAsFixed(1)}K views';
  } else {
    return '$count views';
  }
}

class SimpleVideoPlayer extends StatelessWidget {
  final String videoUrl;
  final String title;
  final String? thumbnailUrl;
  final String? description;
  final String? duration;
  final String? channelTitle;
  final String? viewCount;
  final DateTime? publishedDate;

  const SimpleVideoPlayer({
    Key? key,
    required this.videoUrl,
    required this.title,
    this.thumbnailUrl,
    this.description,
    this.duration,
    this.channelTitle,
    this.viewCount,
    this.publishedDate,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 4,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Video Thumbnail with Play Button
          GestureDetector(
            onTap: _playVideo,
            child: Container(
              height: 200,
              width: double.infinity,
              decoration: BoxDecoration(
                color: Colors.black,
                borderRadius: const BorderRadius.vertical(
                  top: Radius.circular(12),
                ),
                image: thumbnailUrl != null
                    ? DecorationImage(
                        image: NetworkImage(thumbnailUrl!),
                        fit: BoxFit.cover,
                      )
                    : null,
              ),
              child: Stack(
                children: [
                  // Dark overlay
                  Container(
                    decoration: BoxDecoration(
                      color: Colors.black.withValues(alpha: 0.3),
                      borderRadius: const BorderRadius.vertical(
                        top: Radius.circular(12),
                      ),
                    ),
                  ),

                  // Play button
                  Center(
                    child: Container(
                      padding: const EdgeInsets.all(16),
                      decoration: const BoxDecoration(
                        color: Colors.red,
                        shape: BoxShape.circle,
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black26,
                            blurRadius: 8,
                            offset: Offset(0, 4),
                          ),
                        ],
                      ),
                      child: const Icon(
                        Icons.play_arrow,
                        color: Colors.white,
                        size: 32,
                      ),
                    ),
                  ),

                  // Duration badge
                  if (duration != null)
                    Positioned(
                      bottom: 8,
                      right: 8,
                      child: Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 8,
                          vertical: 4,
                        ),
                        decoration: BoxDecoration(
                          color: Colors.black87,
                          borderRadius: BorderRadius.circular(4),
                        ),
                        child: Text(
                          duration!,
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

          // Video Information
          Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Title
                Text(
                  title,
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  ),
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),

                if (channelTitle != null) ...[
                  const SizedBox(height: 4),
                  Row(
                    children: [
                      Icon(
                        Icons.account_circle,
                        size: 16,
                        color: Colors.grey[600],
                      ),
                      const SizedBox(width: 4),
                      Text(
                        channelTitle!,
                        style: TextStyle(
                          fontSize: 14,
                          color: Colors.grey[600],
                        ),
                      ),
                    ],
                  ),
                ],

                // View count and publication date
                if (viewCount != null || publishedDate != null) ...[
                  const SizedBox(height: 4),
                  Row(
                    children: [
                      if (viewCount != null) ...[
                        Icon(
                          Icons.visibility,
                          size: 14,
                          color: Colors.grey[600],
                        ),
                        const SizedBox(width: 4),
                        Text(
                          _formatViewCount(viewCount!),
                          style: TextStyle(
                            fontSize: 12,
                            color: Colors.grey[600],
                          ),
                        ),
                      ],
                      if (viewCount != null && publishedDate != null) ...[
                        const SizedBox(width: 12),
                        Container(
                          width: 3,
                          height: 3,
                          decoration: BoxDecoration(
                            color: Colors.grey[600],
                            shape: BoxShape.circle,
                          ),
                        ),
                        const SizedBox(width: 12),
                      ],
                      if (publishedDate != null) ...[
                        Icon(
                          Icons.schedule,
                          size: 14,
                          color: Colors.grey[600],
                        ),
                        const SizedBox(width: 4),
                        Text(
                          _formatTimeAgo(publishedDate!),
                          style: TextStyle(
                            fontSize: 12,
                            color: Colors.grey[600],
                          ),
                        ),
                      ],
                    ],
                  ),
                ],

                if (description != null) ...[
                  const SizedBox(height: 8),
                  Text(
                    description!,
                    style: TextStyle(
                      fontSize: 14,
                      color: Colors.grey[700],
                    ),
                    maxLines: 3,
                    overflow: TextOverflow.ellipsis,
                  ),
                ],

                const SizedBox(height: 12),

                // Action Buttons
                Row(
                  children: [
                    Expanded(
                      child: ElevatedButton.icon(
                        onPressed: _playVideo,
                        icon: const Icon(Icons.play_arrow),
                        label: const Text('Watch Video'),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.red,
                          foregroundColor: Colors.white,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(8),
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(width: 8),
                    IconButton(
                      onPressed: _shareVideo,
                      icon: const Icon(Icons.share),
                      tooltip: 'Share Video',
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

  Future<void> _playVideo() async {
    // For YouTube videos, we should use the embedded player
    // This is a fallback for external URLs
    try {
      final Uri url = Uri.parse(videoUrl);
      if (await canLaunchUrl(url)) {
        await launchUrl(url, mode: LaunchMode.externalApplication);
      } else {
        throw 'Could not launch video';
      }
    } catch (e) {
      print('Error launching video: $e');
    }
  }

  Future<void> _shareVideo() async {
    try {
      final Uri url = Uri.parse(videoUrl);
      if (await canLaunchUrl(url)) {
        await launchUrl(url, mode: LaunchMode.externalApplication);
      }
    } catch (e) {
      print('Error sharing video: $e');
    }
  }
}

// Compact version for grid layouts
class CompactVideoPlayer extends StatefulWidget {
  final String videoUrl;
  final String title;
  final String? thumbnailUrl;
  final String? duration;
  final String? channelTitle;
  final String? viewCount;
  final DateTime? publishedDate;

  const CompactVideoPlayer({
    Key? key,
    required this.videoUrl,
    required this.title,
    this.thumbnailUrl,
    this.duration,
    this.channelTitle,
    this.viewCount,
    this.publishedDate,
  }) : super(key: key);

  @override
  State<CompactVideoPlayer> createState() => _CompactVideoPlayerState();
}

class _CompactVideoPlayerState extends State<CompactVideoPlayer>
    with SingleTickerProviderStateMixin {
  bool _isHovered = false;
  late AnimationController _animationController;
  late Animation<double> _scaleAnimation;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      duration: const Duration(milliseconds: 200),
      vsync: this,
    );
    _scaleAnimation = Tween<double>(begin: 1.0, end: 1.05).animate(
      CurvedAnimation(parent: _animationController, curve: Curves.easeInOut),
    );
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return MouseRegion(
      onEnter: (_) {
        setState(() => _isHovered = true);
        _animationController.forward();
      },
      onExit: (_) {
        setState(() => _isHovered = false);
        _animationController.reverse();
      },
      cursor: SystemMouseCursors.click,
      child: AnimatedBuilder(
        animation: _scaleAnimation,
        builder: (context, child) {
          return Transform.scale(
            scale: _scaleAnimation.value,
            child: GestureDetector(
              onTap: _playVideo,
              child: Container(
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(8),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black
                          .withValues(alpha: _isHovered ? 0.15 : 0.08),
                      blurRadius: _isHovered ? 8 : 4,
                      offset: Offset(0, _isHovered ? 4 : 2),
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
                          color: Colors.grey[300],
                          borderRadius: const BorderRadius.vertical(
                            top: Radius.circular(8),
                          ),
                        ),
                        clipBehavior: Clip.hardEdge,
                        child: Stack(
                          children: [
                            Positioned.fill(
                              child: widget.thumbnailUrl != null &&
                                      widget.thumbnailUrl!.isNotEmpty
                                  ? safeNetworkImage(
                                      widget.thumbnailUrl!,
                                      fit: BoxFit.cover,
                                    )
                                  : Container(color: Colors.grey[300]),
                            ),
                            // Hover overlay
                            if (_isHovered)
                              Container(
                                decoration: BoxDecoration(
                                  color: Colors.black.withValues(alpha: 0.1),
                                  borderRadius: const BorderRadius.vertical(
                                    top: Radius.circular(8),
                                  ),
                                ),
                              ),

                            // Play button overlay
                            Center(
                              child: AnimatedContainer(
                                duration: const Duration(milliseconds: 200),
                                padding: EdgeInsets.all(_isHovered ? 8 : 6),
                                decoration: BoxDecoration(
                                  color: _isHovered
                                      ? Colors.red
                                      : Colors.white.withValues(alpha: 0.9),
                                  shape: BoxShape.circle,
                                  boxShadow: [
                                    BoxShadow(
                                      color:
                                          Colors.black.withValues(alpha: 0.3),
                                      blurRadius: 4,
                                      offset: const Offset(0, 2),
                                    ),
                                  ],
                                ),
                                child: Icon(
                                  Icons.play_arrow,
                                  size: _isHovered ? 24 : 20,
                                  color: _isHovered ? Colors.white : Colors.red,
                                ),
                              ),
                            ),

                            // Duration badge
                            if (widget.duration != null)
                              Positioned(
                                bottom: 6,
                                right: 6,
                                child: Container(
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: 6,
                                    vertical: 3,
                                  ),
                                  decoration: BoxDecoration(
                                    color: Colors.black87,
                                    borderRadius: BorderRadius.circular(4),
                                  ),
                                  child: Text(
                                    widget.duration!,
                                    style: const TextStyle(
                                      color: Colors.white,
                                      fontSize: 10,
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
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              widget.title,
                              style: const TextStyle(
                                fontSize: 11,
                                fontWeight: FontWeight.w600,
                                color: Colors.black87,
                                height: 1.2,
                              ),
                              maxLines: 2,
                              overflow: TextOverflow.ellipsis,
                            ),
                            if (widget.channelTitle != null) ...[
                              const SizedBox(height: 3),
                              Text(
                                widget.channelTitle!,
                                style: TextStyle(
                                  fontSize: 9,
                                  color: Colors.grey[600],
                                  fontWeight: FontWeight.w500,
                                ),
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                              ),
                            ],
                            // View count and publication date
                            if (widget.viewCount != null ||
                                widget.publishedDate != null) ...[
                              const SizedBox(height: 2),
                              Row(
                                children: [
                                  if (widget.viewCount != null) ...[
                                    Text(
                                      _formatViewCount(widget.viewCount!),
                                      style: TextStyle(
                                        fontSize: 8,
                                        color: Colors.grey[500],
                                        fontWeight: FontWeight.w400,
                                      ),
                                    ),
                                  ],
                                  if (widget.viewCount != null &&
                                      widget.publishedDate != null) ...[
                                    const SizedBox(width: 4),
                                    Container(
                                      width: 2,
                                      height: 2,
                                      decoration: BoxDecoration(
                                        color: Colors.grey[500],
                                        shape: BoxShape.circle,
                                      ),
                                    ),
                                    const SizedBox(width: 4),
                                  ],
                                  if (widget.publishedDate != null) ...[
                                    Text(
                                      _formatTimeAgo(widget.publishedDate!),
                                      style: TextStyle(
                                        fontSize: 8,
                                        color: Colors.grey[500],
                                        fontWeight: FontWeight.w400,
                                      ),
                                    ),
                                  ],
                                ],
                              ),
                            ],
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
      ),
    );
  }

  Future<void> _playVideo() async {
    try {
      final Uri url = Uri.parse(widget.videoUrl);
      if (await canLaunchUrl(url)) {
        await launchUrl(url, mode: LaunchMode.externalApplication);
      } else {
        throw 'Could not launch video';
      }
    } catch (e) {
      print('Error launching video: $e');
    }
  }
}
