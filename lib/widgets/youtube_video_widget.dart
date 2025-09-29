// widgets/youtube_video_widget.dart

import 'package:flutter/material.dart';
import '../services/youtube_service.dart';
import 'dart:html' as html;

class YouTubeVideoWidget extends StatelessWidget {
  final YouTubeVideo video;
  final VoidCallback? onTap;
  final bool showDescription;
  final bool showEmbed;

  const YouTubeVideoWidget({
    Key? key,
    required this.video,
    this.onTap,
    this.showDescription = true,
    this.showEmbed = false,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.all(8.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Video Thumbnail or Embed
          if (showEmbed) _buildEmbeddedVideo() else _buildThumbnail(context),

          // Video Information
          Padding(
            padding: const EdgeInsets.all(12.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Title
                Text(
                  video.title,
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  ),
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 4),

                // Channel and stats
                Row(
                  children: [
                    Icon(Icons.account_circle,
                        size: 16, color: Colors.grey[600]),
                    const SizedBox(width: 4),
                    Expanded(
                      child: Text(
                        video.channelTitle,
                        style: TextStyle(
                          fontSize: 14,
                          color: Colors.grey[600],
                        ),
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                    if (video.formattedViews.isNotEmpty) ...[
                      Text(
                        video.formattedViews,
                        style: TextStyle(
                          fontSize: 12,
                          color: Colors.grey[500],
                        ),
                      ),
                    ],
                  ],
                ),
                const SizedBox(height: 4),

                // Published date
                Text(
                  video.timeAgo,
                  style: TextStyle(
                    fontSize: 12,
                    color: Colors.grey[500],
                  ),
                ),

                // Description
                if (showDescription && video.description.isNotEmpty) ...[
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
              child: const Center(
                child: Icon(
                  Icons.play_circle_fill,
                  size: 64,
                  color: Colors.white,
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

  void _openYouTube() {
    html.window.open(video.watchUrl, '_blank');
  }

  void _shareVideo() {
    // For web, copy to clipboard
    html.window.navigator.clipboard?.writeText(video.watchUrl);
    // You could also show a snackbar here
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
              onPressed: () => html.window
                  .open('https://www.youtube.com/embed/$videoId', '_blank'),
              child: const Text('Open Video',
                  style: TextStyle(color: Colors.blue)),
            ),
          ],
        ),
      ),
    );
  }
}
