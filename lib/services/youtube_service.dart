// services/youtube_service.dart

import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:flutter_dotenv/flutter_dotenv.dart';

class YouTubeService {
  static String get apiKey => dotenv.env['YOUTUBE_API_KEY'] ?? '';
  static const String baseUrl = 'https://www.googleapis.com/youtube/v3';

  /// Test if the API key is valid and working
  static Future<bool> validateApiKey() async {
    if (apiKey.isEmpty) {
      print('🔴 YouTube API: No API key found in environment');
      return false;
    }

    print('🔵 YouTube API: Testing API key validity...');
    print(
        '🔵 YouTube API Key: ${apiKey.substring(0, 8)}...${apiKey.substring(apiKey.length - 4)}');

    try {
      // Test with a simple search query
      final url = Uri.parse(
          '$baseUrl/search?part=snippet&q=flutter&type=video&maxResults=1&key=$apiKey');

      final response = await http.get(url);

      if (response.statusCode == 200) {
        print('🟢 YouTube API: API key is valid and working');
        return true;
      } else if (response.statusCode == 400) {
        final errorBody = json.decode(response.body);
        final errorMessage = errorBody['error']?['message'] ?? 'Bad Request';
        print('🔴 YouTube API Key Error (400): $errorMessage');
        return false;
      } else if (response.statusCode == 403) {
        final errorBody = json.decode(response.body);
        final errorMessage = errorBody['error']?['message'] ?? 'Forbidden';
        print('🔴 YouTube API Key Error (403): $errorMessage');
        if (errorMessage.toLowerCase().contains('quota')) {
          print(
              '💡 Hint: Your daily quota may be exceeded. Try again tomorrow.');
        } else {
          print(
              '💡 Hint: Check if YouTube Data API v3 is enabled for your key.');
        }
        return false;
      } else {
        print(
            '🔴 YouTube API Key Error (${response.statusCode}): ${response.body}');
        return false;
      }
    } catch (e) {
      print('🔴 YouTube API Key Validation Exception: $e');
      return false;
    }
  }

  /// Search for videos based on a query
  static Future<List<YouTubeVideo>> searchVideos({
    required String query,
    int maxResults = 10,
  }) async {
    // Validate API key
    if (apiKey.isEmpty) {
      throw Exception(
          'YouTube API key not found. Please add YOUTUBE_API_KEY to your .env file');
    }

    // Validate and clean query
    if (query.trim().isEmpty) {
      print('🔴 YouTube API Error: Empty query provided');
      throw Exception('Search query cannot be empty');
    }

    final cleanQuery = query.trim();
    final encodedQuery = Uri.encodeQueryComponent(cleanQuery);

    print(
        '🔵 YouTube API: Searching for "$cleanQuery" (encoded: "$encodedQuery")');
    print('🔵 YouTube API: Max results: $maxResults');

    final url = Uri.parse(
        '$baseUrl/search?part=snippet&q=$encodedQuery&type=video&maxResults=$maxResults&key=$apiKey');

    print('🔵 YouTube API Request URL: $url');

    try {
      final response = await http.get(url);

      print('🔵 YouTube API Response Status: ${response.statusCode}');
      print('🔵 YouTube API Response Headers: ${response.headers}');

      if (response.statusCode == 200) {
        final Map<String, dynamic> data = json.decode(response.body);
        final List items = data['items'] ?? [];

        print('🔵 YouTube API: Found ${items.length} videos');

        if (items.isEmpty) {
          print(
              '🟡 YouTube API Warning: No videos found for query "$cleanQuery"');
        }

        final videos =
            items.map((item) => YouTubeVideo.fromJson(item)).toList();

        // Get additional details (duration, view count) for each video
        final videosWithDetails = await _enrichVideosWithDetails(videos);

        return videosWithDetails;
      } else {
        // Log detailed error information
        print('🔴 YouTube API Error ${response.statusCode}: ${response.body}');

        // Handle specific error codes
        if (response.statusCode == 400) {
          final errorBody = json.decode(response.body);
          final errorMessage = errorBody['error']?['message'] ?? 'Bad Request';
          throw Exception(
              'YouTube API Bad Request (400): $errorMessage. Check your query format and API key.');
        } else if (response.statusCode == 403) {
          final errorBody = json.decode(response.body);
          final errorMessage = errorBody['error']?['message'] ?? 'Forbidden';
          if (errorMessage.toLowerCase().contains('quota')) {
            throw Exception(
                'YouTube API Quota Exceeded (403): Daily quota limit reached. Try again tomorrow.');
          }
          throw Exception(
              'YouTube API Forbidden (403): $errorMessage. Check your API key permissions.');
        } else if (response.statusCode == 404) {
          throw Exception(
              'YouTube API Not Found (404): The requested resource was not found.');
        } else {
          throw Exception(
              'YouTube API Error (${response.statusCode}): ${response.body}');
        }
      }
    } catch (e) {
      print('🔴 YouTube API Exception: $e');
      if (e.toString().contains('YouTube API')) {
        rethrow; // Re-throw our custom exceptions
      }
      throw Exception('Network error while searching YouTube videos: $e');
    }
  }

  /// Enrich videos with additional details (duration, accurate view counts)
  static Future<List<YouTubeVideo>> _enrichVideosWithDetails(
      List<YouTubeVideo> videos) async {
    if (videos.isEmpty) return videos;

    // Get video IDs
    final videoIds =
        videos.map((v) => v.id).where((id) => id.isNotEmpty).join(',');
    if (videoIds.isEmpty) return videos;

    print(
        '🔵 YouTube API: Enriching ${videos.length} videos with duration and stats...');

    try {
      final url = Uri.parse(
          '$baseUrl/videos?part=snippet,statistics,contentDetails&id=$videoIds&key=$apiKey');

      final response = await http.get(url);

      if (response.statusCode == 200) {
        final Map<String, dynamic> data = json.decode(response.body);
        final List items = data['items'] ?? [];

        // Create a map of enriched video data
        final Map<String, Map<String, dynamic>> enrichedData = {};
        for (final item in items) {
          final videoId = item['id'];
          if (videoId != null) {
            enrichedData[videoId] = item;
          }
        }

        // Update original videos with enriched data
        final enrichedVideos = <YouTubeVideo>[];
        for (final video in videos) {
          if (enrichedData.containsKey(video.id)) {
            // Create new video with enriched data
            final enrichedItem = enrichedData[video.id]!;
            enrichedVideos
                .add(YouTubeVideo.fromEnrichedJson(video, enrichedItem));
          } else {
            // Keep original video if no enriched data found
            enrichedVideos.add(video);
          }
        }

        print(
            '🔵 YouTube API: Successfully enriched ${enrichedVideos.length} videos with details');
        return enrichedVideos;
      } else {
        print(
            '🟡 YouTube API Warning: Could not fetch video details (${response.statusCode}). Using basic data.');
        return videos;
      }
    } catch (e) {
      print(
          '🟡 YouTube API Warning: Error enriching video data: $e. Using basic data.');
      return videos;
    }
  }

  /// Get video details by video ID
  static Future<YouTubeVideo?> getVideoDetails(String videoId) async {
    // Validate API key
    if (apiKey.isEmpty) {
      throw Exception('YouTube API key not found');
    }

    // Validate video ID
    if (videoId.trim().isEmpty) {
      print('🔴 YouTube API Error: Empty video ID provided');
      return null;
    }

    final cleanVideoId = videoId.trim();
    print('🔵 YouTube API: Getting details for video ID "$cleanVideoId"');

    final url = Uri.parse(
        '$baseUrl/videos?part=snippet,statistics&id=$cleanVideoId&key=$apiKey');

    print('🔵 YouTube API Request URL: $url');

    try {
      final response = await http.get(url);

      print('🔵 YouTube API Response Status: ${response.statusCode}');

      if (response.statusCode == 200) {
        final Map<String, dynamic> data = json.decode(response.body);
        final List items = data['items'] ?? [];

        if (items.isNotEmpty) {
          print('🔵 YouTube API: Video details retrieved successfully');
          return YouTubeVideo.fromJson(items[0]);
        } else {
          print(
              '🟡 YouTube API Warning: No video found with ID "$cleanVideoId"');
        }
      } else {
        print('🔴 YouTube API Error ${response.statusCode}: ${response.body}');
      }
      return null;
    } catch (e) {
      print('🔴 YouTube API Exception in getVideoDetails: $e');
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

  /// Generate a test URL that can be used in browser for debugging
  static String getTestUrl({required String query, int maxResults = 5}) {
    final encodedQuery = Uri.encodeQueryComponent(query.trim());
    return '$baseUrl/search?part=snippet&q=$encodedQuery&type=video&maxResults=$maxResults&key=$apiKey';
  }

  /// Print debugging information
  static void printDebugInfo({required String query}) {
    print('\n🔧 YouTube API Debug Information:');
    print('📍 Base URL: $baseUrl');
    print(
        '🔑 API Key: ${apiKey.isEmpty ? "NOT SET" : "${apiKey.substring(0, 8)}...${apiKey.substring(apiKey.length - 4)}"}');
    print('🔍 Query: "$query"');
    print('🔗 Test URL: ${getTestUrl(query: query)}');
    print('💡 Copy this URL to test in your browser\n');
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

  /// Create enriched video from original video and additional API data
  factory YouTubeVideo.fromEnrichedJson(
      YouTubeVideo original, Map<String, dynamic> enrichedJson) {
    final statistics = enrichedJson['statistics'];
    final contentDetails = enrichedJson['contentDetails'];

    // Parse duration from ISO 8601 format (PT4M13S -> 4:13)
    String? formattedDuration;
    final duration = contentDetails?['duration'];
    if (duration != null && duration is String) {
      formattedDuration = _parseDuration(duration);
    }

    return YouTubeVideo(
      id: original.id,
      title: original.title,
      description: original.description,
      channelTitle: original.channelTitle,
      thumbnailUrl: original.thumbnailUrl,
      publishedAt: original.publishedAt,
      duration: formattedDuration,
      viewCount: statistics != null
          ? int.tryParse(statistics['viewCount'] ?? '0')
          : null,
      likeCount: statistics != null
          ? int.tryParse(statistics['likeCount'] ?? '0')
          : null,
    );
  }

  /// Parse ISO 8601 duration (PT4M13S) to readable format (4:13)
  static String _parseDuration(String isoDuration) {
    final regex = RegExp(r'PT(?:(\d+)H)?(?:(\d+)M)?(?:(\d+)S)?');
    final match = regex.firstMatch(isoDuration);

    if (match != null) {
      final hours = int.tryParse(match.group(1) ?? '0') ?? 0;
      final minutes = int.tryParse(match.group(2) ?? '0') ?? 0;
      final seconds = int.tryParse(match.group(3) ?? '0') ?? 0;

      if (hours > 0) {
        return '${hours}:${minutes.toString().padLeft(2, '0')}:${seconds.toString().padLeft(2, '0')}';
      } else {
        return '${minutes}:${seconds.toString().padLeft(2, '0')}';
      }
    }

    return isoDuration; // Return original if parsing fails
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
