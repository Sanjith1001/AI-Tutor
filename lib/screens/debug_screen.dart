import 'package:flutter/material.dart';
import '../services/youtube_service.dart';
import '../services/audio_helper.dart';

class DebugScreen extends StatefulWidget {
  const DebugScreen({super.key});

  @override
  State<DebugScreen> createState() => _DebugScreenState();
}

class _DebugScreenState extends State<DebugScreen> {
  final AudioHelper _audioHelper = AudioHelper();
  String _youtubeStatus = 'Not tested';
  String _audioStatus = 'Not tested';
  bool _isTestingYoutube = false;
  bool _isTestingAudio = false;

  @override
  void initState() {
    super.initState();
    _audioHelper.initialize();
  }

  @override
  void dispose() {
    _audioHelper.stop();
    super.dispose();
  }

  Future<void> _testYouTubeAPI() async {
    setState(() {
      _isTestingYoutube = true;
      _youtubeStatus = 'Testing...';
    });

    try {
      // Test API key validation
      final isValid = await YouTubeService.validateApiKey();
      if (!isValid) {
        setState(() {
          _youtubeStatus = '❌ API key validation failed';
        });
        return;
      }

      // Test video search
      final videos = await YouTubeService.searchVideos(
        query: 'flutter tutorial',
        maxResults: 1,
      );

      setState(() {
        _youtubeStatus = videos.isNotEmpty 
          ? '✅ SUCCESS: Found ${videos.length} videos'
          : '⚠️ No videos found';
      });
    } catch (e) {
      setState(() {
        _youtubeStatus = '❌ ERROR: ${e.toString()}';
      });
    } finally {
      setState(() {
        _isTestingYoutube = false;
      });
    }
  }

  Future<void> _testAudio() async {
    setState(() {
      _isTestingAudio = true;
      _audioStatus = 'Testing...';
    });

    try {
      // Test with a simple audio file
      await _audioHelper.playModuleAudio(
        moduleId: 'test_module',
        description: 'Test audio playback',
        podcastUrl: 'https://www.soundjay.com/misc/sounds/bell-ringing-05.mp3',
      );

      setState(() {
        _audioStatus = '✅ Audio playback started successfully';
      });

      // Stop after 3 seconds
      await Future.delayed(const Duration(seconds: 3));
      await _audioHelper.stop();
    } catch (e) {
      setState(() {
        _audioStatus = '❌ ERROR: ${e.toString()}';
      });
    } finally {
      setState(() {
        _isTestingAudio = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Debug Screen'),
        backgroundColor: Colors.blue,
        foregroundColor: Colors.white,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'API & Feature Testing',
              style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 20),

            // YouTube API Test
            Card(
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'YouTube API Test',
                      style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                    ),
                    const SizedBox(height: 8),
                    Text('Status: $_youtubeStatus'),
                    const SizedBox(height: 12),
                    ElevatedButton(
                      onPressed: _isTestingYoutube ? null : _testYouTubeAPI,
                      child: _isTestingYoutube
                          ? const SizedBox(
                              width: 20,
                              height: 20,
                              child: CircularProgressIndicator(strokeWidth: 2),
                            )
                          : const Text('Test YouTube API'),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 16),

            // Audio Test
            Card(
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Audio Playback Test',
                      style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                    ),
                    const SizedBox(height: 8),
                    Text('Status: $_audioStatus'),
                    const SizedBox(height: 12),
                    Row(
                      children: [
                        ElevatedButton(
                          onPressed: _isTestingAudio ? null : _testAudio,
                          child: _isTestingAudio
                              ? const SizedBox(
                                  width: 20,
                                  height: 20,
                                  child: CircularProgressIndicator(strokeWidth: 2),
                                )
                              : const Text('Test Audio'),
                        ),
                        const SizedBox(width: 12),
                        ElevatedButton(
                          onPressed: () => _audioHelper.stop(),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.red,
                            foregroundColor: Colors.white,
                          ),
                          child: const Text('Stop Audio'),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 20),

            // Instructions
            const Card(
              child: Padding(
                padding: EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Troubleshooting Tips:',
                      style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                    ),
                    SizedBox(height: 8),
                    Text(
                      '• YouTube API issues: Check your API key and quota limits\n'
                      '• Audio issues: Ensure internet connection and audio drivers\n'
                      '• Windows compatibility: Use MP3, WAV, or OGG formats\n'
                      '• Network timeouts: Check firewall and proxy settings',
                      style: TextStyle(fontSize: 14),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}