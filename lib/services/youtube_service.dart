// services/youtube_service.dart

import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:flutter_dotenv/flutter_dotenv.dart';

class YouTubeService {
  static String get apiKey => dotenv.env['YOUTUBE_API_KEY'] ?? '';
  static const String baseUrl = 'https://www.googleapis.com/youtube/v3';

  /// Search for videos based on a query
  static Future<List<YouTubeVideo>> searchVideos({
    required String query,
    int maxResults = 10,
  }) async {
    if (apiKey.isEmpty) {
      throw Exception(
          'YouTube API key not found. Please add YOUTUBE_API_KEY to your .env file');
    }

    final url = Uri.parse(
        '$baseUrl/search?part=snippet&q=$query&type=video&maxResults=$maxResults&key=$apiKey');

    try {
      final response = await http.get(url);

      if (response.statusCode == 200) {
        final Map<String, dynamic> data = json.decode(response.body);
        final List items = data['items'] ?? [];

        return items.map((item) => YouTubeVideo.fromJson(item)).toList();
      } else {
        throw Exception(
            'Failed to search YouTube videos: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('Error searching YouTube videos: $e');
    }
  }

  /// Get video details by video ID
  static Future<YouTubeVideo?> getVideoDetails(String videoId) async {
    if (apiKey.isEmpty) {
      throw Exception('YouTube API key not found');
    }

    final url = Uri.parse(
        '$baseUrl/videos?part=snippet,statistics&id=$videoId&key=$apiKey');

    try {
      final response = await http.get(url);

      if (response.statusCode == 200) {
        final Map<String, dynamic> data = json.decode(response.body);
        final List items = data['items'] ?? [];

        if (items.isNotEmpty) {
          return YouTubeVideo.fromJson(items[0]);
        }
      }
      return null;
    } catch (e) {
      print('Error getting video details: $e');
      return null;
    }
  }

  /// Generate YouTube embed URL
  static String getEmbedUrl(String videoId) {
    return 'https://www.youtube.com/embed/$videoId';
  }

  /// Generate YouTube watch URL
  static String getWatchUrl(String videoId) {
    return 'https://www.youtube.com/watch?v=$videoId';
  }
}

/// YouTube Video Model
class YouTubeVideo {
  final String id;
  final String title;
  final String description;
  final String channelTitle;
  final String thumbnailUrl;
  final DateTime publishedAt;
  final String? duration;
  final int? viewCount;
  final int? likeCount;

  YouTubeVideo({
    required this.id,
    required this.title,
    required this.description,
    required this.channelTitle,
    required this.thumbnailUrl,
    required this.publishedAt,
    this.duration,
    this.viewCount,
    this.likeCount,
  });

  factory YouTubeVideo.fromJson(Map<String, dynamic> json) {
    // Handle different response formats (search vs videos endpoint)
    final snippet = json['snippet'] ?? {};
    final statistics = json['statistics'];

    String videoId;
    if (json['id'] is String) {
      videoId = json['id'];
    } else if (json['id'] is Map) {
      videoId = json['id']['videoId'] ?? '';
    } else {
      videoId = '';
    }

    return YouTubeVideo(
      id: videoId,
      title: snippet['title'] ?? '',
      description: snippet['description'] ?? '',
      channelTitle: snippet['channelTitle'] ?? '',
      thumbnailUrl: snippet['thumbnails']?['medium']?['url'] ??
          snippet['thumbnails']?['default']?['url'] ??
          '',
      publishedAt:
          DateTime.tryParse(snippet['publishedAt'] ?? '') ?? DateTime.now(),
      viewCount: statistics != null
          ? int.tryParse(statistics['viewCount'] ?? '0')
          : null,
      likeCount: statistics != null
          ? int.tryParse(statistics['likeCount'] ?? '0')
          : null,
    );
  }

  String get embedUrl => YouTubeService.getEmbedUrl(id);
  String get watchUrl => YouTubeService.getWatchUrl(id);

  String get formattedViews {
    if (viewCount == null) return '';
    if (viewCount! > 1000000) {
      return '${(viewCount! / 1000000).toStringAsFixed(1)}M views';
    } else if (viewCount! > 1000) {
      return '${(viewCount! / 1000).toStringAsFixed(1)}K views';
    }
    return '$viewCount views';
  }

  String get timeAgo {
    final now = DateTime.now();
    final difference = now.difference(publishedAt);

    if (difference.inDays > 365) {
      return '${(difference.inDays / 365).floor()} years ago';
    } else if (difference.inDays > 30) {
      return '${(difference.inDays / 30).floor()} months ago';
    } else if (difference.inDays > 0) {
      return '${difference.inDays} days ago';
    } else if (difference.inHours > 0) {
      return '${difference.inHours} hours ago';
    } else {
      return '${difference.inMinutes} minutes ago';
    }
  }
}
