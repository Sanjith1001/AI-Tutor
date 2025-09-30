// Test script to verify YouTube API functionality
// Run this with: dart test_youtube_api.dart

import 'dart:io';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'lib/services/youtube_service.dart';

Future<void> main() async {
  print('🚀 YouTube API Test Script');
  print('=' * 50);

  try {
    // Load environment variables
    await dotenv.load(fileName: '.env');

    print('\n🔧 Environment Setup:');
    final apiKey = dotenv.env['YOUTUBE_API_KEY'] ?? '';
    if (apiKey.isEmpty) {
      print('❌ YOUTUBE_API_KEY not found in .env file');
      print('💡 Please add your YouTube Data API v3 key to .env file');
      exit(1);
    }

    print(
        '✅ API Key found: ${apiKey.substring(0, 8)}...${apiKey.substring(apiKey.length - 4)}');

    // Test 1: Validate API Key
    print('\n🧪 Test 1: Validating API Key...');
    final isValid = await YouTubeService.validateApiKey();
    if (!isValid) {
      print('❌ API Key validation failed');
      print('💡 Troubleshooting steps:');
      print('   1. Verify your API key is correct');
      print('   2. Enable YouTube Data API v3 in Google Cloud Console');
      print('   3. Check if you have exceeded the daily quota');
      print('   4. Ensure no referrer restrictions are blocking the request');
      exit(1);
    }
    print('✅ API Key is valid');

    // Test 2: Search for videos
    print('\n🧪 Test 2: Searching for Flutter videos...');
    YouTubeService.printDebugInfo(query: 'Flutter tutorial');

    final videos = await YouTubeService.searchVideos(
      query: 'Flutter tutorial',
      maxResults: 3,
    );

    if (videos.isEmpty) {
      print('⚠️ No videos found (this might be normal)');
    } else {
      print('✅ Found ${videos.length} videos:');
      for (int i = 0; i < videos.length; i++) {
        final video = videos[i];
        print('   ${i + 1}. ${video.title}');
        print('      Channel: ${video.channelTitle}');
        print('      Published: ${video.timeAgo}');
        print('      URL: ${video.watchUrl}');
        print('');
      }
    }

    // Test 3: Manual URL test
    print('\n🧪 Test 3: Manual URL Test');
    print('Copy and paste this URL into your browser to test manually:');
    print(YouTubeService.getTestUrl(query: 'Flutter tutorial'));
    print(
        '\nIf this URL works in your browser, the problem is in the app code.');
    print('If it doesn\'t work, check your API key and quotas.');

    print('\n✅ All tests completed successfully!');
  } catch (e) {
    print('\n❌ Test failed with error: $e');
    print('\n💡 Common solutions:');
    print('   - Check your internet connection');
    print('   - Verify your API key is correct and active');
    print('   - Ensure YouTube Data API v3 is enabled');
    print('   - Check if you\'ve exceeded the daily quota');
    exit(1);
  }
}
