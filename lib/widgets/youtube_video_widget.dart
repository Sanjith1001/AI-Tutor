// widgets/youtube_video_widget.dart

import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart';
import '../services/youtube_service.dart';
import 'package:url_launcher/url_launcher.dart';

class YouTubeVideoWidget extends StatelessWidget {
  final YouTubeVideo video;
  final VoidCallback? onTap;
  final bool showDescription;
  final bool showEmbed;
  final bool compact;

  const YouTubeVideoWidget({
    Key? key,
    required this.video,
    this.onTap,
    this.showDescription = true,
    this.showEmbed = false,
    this.compact = false,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: compact ? const EdgeInsets.all(2.0) : const EdgeInsets.all(8.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Video Thumbnail or Embed
          if (showEmbed) _buildEmbeddedVideo() else _buildThumbnail(context),

          // Video Information
          Padding(
            padding: compact
                ? const EdgeInsets.all(6.0)
                : const EdgeInsets.all(12.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Title
                Text(
                  video.title,
                  style: TextStyle(
                    fontSize: compact ? 14 : 16,
                    fontWeight: FontWeight.bold,
                  ),
                  maxLines: compact ? 2 : 2,
                  overflow: TextOverflow.ellipsis,
                ),
                SizedBox(height: compact ? 2 : 4),

                // Channel and stats
                if (!compact) ...[
                  Row(
                    children: [
                      Icon(Icons.account_circle,
                          size: 14, color: Colors.grey[600]),
                      const SizedBox(width: 4),
                      Expanded(
                        child: Text(
                          video.channelTitle,
                          style: TextStyle(
                            fontSize: 12,
                            color: Colors.grey[600],
                          ),
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                      if (video.formattedViews.isNotEmpty) ...[
                        Text(
                          video.formattedViews,
                          style: TextStyle(
                            fontSize: 10,
                            color: Colors.grey[500],
                          ),
                        ),
                      ],
                    ],
                  ),
                  SizedBox(height: compact ? 2 : 4),
                ],

                // Duration, published date, and channel (compact row)
                Row(
                  children: [
                    // Duration (if available)
                    if (video.duration != null &&
                        video.duration!.isNotEmpty) ...[
                      Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 4, vertical: 2),
                        decoration: BoxDecoration(
                          color: Colors.black87,
                          borderRadius: BorderRadius.circular(4),
                        ),
                        child: Text(
                          video.duration!,
                          style: const TextStyle(
                            fontSize: 10,
                            color: Colors.white,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                      const SizedBox(width: 8),
                    ],

                    // Channel (compact mode) or published date
                    Expanded(
                      child: Text(
                        compact ? video.channelTitle : video.timeAgo,
                        style: TextStyle(
                          fontSize: compact ? 10 : 12,
                          color: Colors.grey[500],
                        ),
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),

                    // Published date in compact mode
                    if (compact) ...[
                      Text(
                        video.timeAgo,
                        style: TextStyle(
                          fontSize: 10,
                          color: Colors.grey[500],
                        ),
                      ),
                    ],
                  ],
                ),

                // Description
                if (showDescription &&
                    video.description.isNotEmpty &&
                    !compact) ...[
                  const SizedBox(height: 8),
                  Text(
                    video.description,
                    style: TextStyle(
                      fontSize: 14,
                      color: Colors.grey[700],
                    ),
                    maxLines: 3,
                    overflow: TextOverflow.ellipsis,
                  ),
                ],

                // Action buttons
                if (!compact) ...[
                  const SizedBox(height: 8),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children: [
                      TextButton.icon(
                        onPressed: () => _openYouTube(),
                        icon: const Icon(Icons.play_arrow),
                        label: const Text('Watch'),
                      ),
                      if (!showEmbed)
                        TextButton.icon(
                          onPressed: onTap,
                          icon: const Icon(Icons.fullscreen),
                          label: const Text('Embed'),
                        ),
                      TextButton.icon(
                        onPressed: () => _shareVideo(),
                        icon: const Icon(Icons.share),
                        label: const Text('Share'),
                      ),
                    ],
                  ),
                ],
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildThumbnail(BuildContext context) {
    return GestureDetector(
      onTap: onTap ?? _openYouTube,
      child: Stack(
        children: [
          // Thumbnail image
          AspectRatio(
            aspectRatio: 16 / 9,
            child: Container(
              decoration: BoxDecoration(
                borderRadius:
                    const BorderRadius.vertical(top: Radius.circular(4)),
                image: video.thumbnailUrl.isNotEmpty
                    ? DecorationImage(
                        image: NetworkImage(video.thumbnailUrl),
                        fit: BoxFit.cover,
                      )
                    : null,
                color: Colors.grey[300],
              ),
              child: video.thumbnailUrl.isEmpty
                  ? const Center(
                      child: Icon(Icons.video_library,
                          size: 48, color: Colors.grey),
                    )
                  : null,
            ),
          ),

          // Play button overlay
          Positioned.fill(
            child: Container(
              decoration: BoxDecoration(
                color: Colors.black.withOpacity(0.3),
                borderRadius:
                    const BorderRadius.vertical(top: Radius.circular(4)),
              ),
              child: Center(
                child: Icon(
                  Icons.play_circle_fill,
                  size: compact ? 48 : 64,
                  color: Colors.white,
                ),
              ),
            ),
          ),

          // Duration overlay (bottom-right corner)
          if (video.duration != null && video.duration!.isNotEmpty)
            Positioned(
              bottom: 8,
              right: 8,
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                decoration: BoxDecoration(
                  color: Colors.black87,
                  borderRadius: BorderRadius.circular(4),
                ),
                child: Text(
                  video.duration!,
                  style: const TextStyle(
                    fontSize: 12,
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildEmbeddedVideo() {
    return AspectRatio(
      aspectRatio: 16 / 9,
      child: Container(
        decoration: const BoxDecoration(
          borderRadius: BorderRadius.vertical(top: Radius.circular(4)),
        ),
        child: ClipRRect(
          borderRadius: const BorderRadius.vertical(top: Radius.circular(4)),
          child: _YouTubeEmbed(videoId: video.id),
        ),
      ),
    );
  }

  Future<void> _openYouTube() async {
    final Uri url = Uri.parse(video.watchUrl);
    if (await canLaunchUrl(url)) {
      await launchUrl(url, mode: LaunchMode.externalApplication);
    }
  }

  void _shareVideo() {
    // Simple implementation - could be enhanced with share_plus package
    // For now, just open the video
    _openYouTube();
  }
}

class _YouTubeEmbed extends StatelessWidget {
  final String videoId;

  const _YouTubeEmbed({required this.videoId});

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.black,
        borderRadius: BorderRadius.circular(4),
      ),
      child: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.play_circle_fill, size: 48, color: Colors.white),
            const SizedBox(height: 8),
            Text(
              'Click to watch on YouTube',
              style: TextStyle(color: Colors.white),
            ),
            const SizedBox(height: 4),
            TextButton(
              onPressed: () async {
                final Uri url =
                    Uri.parse('https://www.youtube.com/watch?v=$videoId');
                if (await canLaunchUrl(url)) {
                  await launchUrl(url, mode: LaunchMode.externalApplication);
                }
              },
              child: const Text('Open Video',
                  style: TextStyle(color: Colors.blue)),
            ),
          ],
        ),
      ),
    );
  }
}
