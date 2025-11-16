// services/audio_helper.dart

import 'dart:async';
import 'dart:io';
import 'package:audioplayers/audioplayers.dart';
import 'package:flutter/foundation.dart';

enum AudioPlayerState {
  stopped,
  playing,
  paused,
  loading,
  error,
}

enum AudioSource {
  podcast,
  tts, // Placeholder for future TTS implementation
}

class AudioHelper {
  static final AudioHelper _instance = AudioHelper._internal();
  factory AudioHelper() => _instance;
  AudioHelper._internal();

  // Audio player for podcast URLs
  final AudioPlayer _audioPlayer = AudioPlayer();

  // Current state tracking
  AudioPlayerState _currentState = AudioPlayerState.stopped;
  AudioSource? _currentSource;
  String? _currentModuleId;

  // Stream controllers for state updates
  final StreamController<AudioPlayerState> _stateController =
      StreamController<AudioPlayerState>.broadcast();
  final StreamController<Duration> _positionController =
      StreamController<Duration>.broadcast();
  final StreamController<Duration> _durationController =
      StreamController<Duration>.broadcast();

  // Getters for streams
  Stream<AudioPlayerState> get stateStream => _stateController.stream;
  Stream<Duration> get positionStream => _positionController.stream;
  Stream<Duration> get durationStream => _durationController.stream;

  AudioPlayerState get currentState => _currentState;
  AudioSource? get currentSource => _currentSource;
  String? get currentModuleId => _currentModuleId;

  Future<void> initialize() async {
    try {
      // Set up audio player listeners
      _audioPlayer.onPlayerStateChanged.listen((PlayerState state) {
        if (kDebugMode) {
          print('🔊 Audio player state changed: $state');
        }
        switch (state) {
          case PlayerState.stopped:
            _updateState(AudioPlayerState.stopped);
            break;
          case PlayerState.playing:
            _updateState(AudioPlayerState.playing);
            break;
          case PlayerState.paused:
            _updateState(AudioPlayerState.paused);
            break;
          case PlayerState.completed:
            _updateState(AudioPlayerState.stopped);
            _currentModuleId = null;
            _currentSource = null;
            break;
          case PlayerState.disposed:
            _updateState(AudioPlayerState.stopped);
            break;
        }
      });

      _audioPlayer.onPositionChanged.listen((Duration position) {
        _positionController.add(position);
      });

      _audioPlayer.onDurationChanged.listen((Duration duration) {
        _durationController.add(duration);
      });

      // Add error listener
      _audioPlayer.onPlayerComplete.listen((_) {
        if (kDebugMode) {
          print('🔊 Audio playback completed');
        }
        _updateState(AudioPlayerState.stopped);
        _currentModuleId = null;
        _currentSource = null;
      });

      if (kDebugMode) {
        print('🔊 AudioHelper initialized successfully');
      }
    } catch (e) {
      if (kDebugMode) {
        print('🔴 AudioHelper initialization error: $e');
      }
      _updateState(AudioPlayerState.error);
      rethrow;
    }
  }

  /// Play audio for a module - podcast URL if available, otherwise show TTS message
  Future<void> playModuleAudio({
    required String moduleId,
    required String description,
    String? podcastUrl,
  }) async {
    try {
      // Stop any current playback first
      await stop();

      _currentModuleId = moduleId;
      _updateState(AudioPlayerState.loading);

      if (podcastUrl != null && podcastUrl.isNotEmpty) {
        // Try to play podcast URL
        await _playPodcast(podcastUrl);
      } else {
        // Show message about TTS not being available
        if (kDebugMode) {
          print(
              '🔵 TTS not available on Windows - would read:  ${description.substring(0, 50)}...');
        }
        throw Exception(
            'TTS not available on Windows. Please provide a podcast URL for audio playback.');
      }

      if (kDebugMode) {
        print(
            '🔊 Playing audio for module: $moduleId, source: $_currentSource');
      }
    } catch (e) {
      if (kDebugMode) {
        print('🔴 Error playing module audio: $e');
      }
      _updateState(AudioPlayerState.error);
      _currentModuleId = null;
      _currentSource = null;
      rethrow;
    }
  }

  Future<void> _playPodcast(String podcastUrl) async {
    try {
      _currentSource = AudioSource.podcast;

      if (kDebugMode) {
        print('🔊 Attempting to play podcast: $podcastUrl');
      }

      // Handle different URL types with Windows-specific logic
      if (podcastUrl.startsWith('http://') ||
          podcastUrl.startsWith('https://')) {
        // Web URL - check if it's a supported format
        if (!_isSupportedAudioFormat(podcastUrl)) {
          throw Exception(
              'Unsupported audio format. Windows supports MP3, WAV, and OGG files only.');
        }
        await _audioPlayer.play(UrlSource(podcastUrl));
      } else if (podcastUrl.startsWith('file://')) {
        // File URI - use DeviceFileSource
        final filePath = podcastUrl.replaceFirst('file://', '');
        if (!_isSupportedAudioFormat(filePath)) {
          throw Exception(
              'Unsupported audio format. Windows supports MP3, WAV, and OGG files only.');
        }
        await _audioPlayer.play(DeviceFileSource(filePath));
      } else if (podcastUrl.contains('\\') || podcastUrl.contains('/')) {
        // Local file path - use DeviceFileSource
        if (!File(podcastUrl).existsSync()) {
          throw Exception('Audio file not found: $podcastUrl');
        }
        if (!_isSupportedAudioFormat(podcastUrl)) {
          throw Exception(
              'Unsupported audio format. Windows supports MP3, WAV, and OGG files only.');
        }
        await _audioPlayer.play(DeviceFileSource(podcastUrl));
      } else {
        // Asset path - use AssetSource
        if (!_isSupportedAudioFormat(podcastUrl)) {
          throw Exception(
              'Unsupported audio format. Windows supports MP3, WAV, and OGG files only.');
        }
        await _audioPlayer.play(AssetSource(podcastUrl));
      }

      if (kDebugMode) {
        print('🔊 Successfully started playing podcast: $podcastUrl');
      }
    } catch (e) {
      if (kDebugMode) {
        print('🔴 Podcast playback failed: $e');
      }
      // Re-throw with more specific error message
      if (e.toString().contains('WindowsAudioError')) {
        throw Exception(
            'Windows audio error: ${e.toString()}. Try using MP3, WAV, or OGG format.');
      }
      throw e;
    }
  }

  /// Check if the audio format is supported on Windows
  bool _isSupportedAudioFormat(String url) {
    final supportedExtensions = ['.mp3', '.wav', '.ogg'];
    final lowerUrl = url.toLowerCase();
    return supportedExtensions.any((ext) => lowerUrl.endsWith(ext));
  }

  /// Get Windows-compatible sample audio URLs for testing
  static List<Map<String, String>> getWindowsCompatibleSampleUrls() {
    return [
      {
        'title': 'Educational Podcast Sample',
        'url': 'https://archive.org/download/testmp3testfile/mpthreetest.mp3',
        'description': 'A sample educational audio file for testing'
      },
      {
        'title': 'Programming Tutorial Audio',
        'url': 'https://traffic.libsyn.com/secure/talkpython/python-bytes-1.mp3',
        'description': 'Python programming podcast episode'
      },
      {
        'title': 'Tech Learning Content',
        'url': 'https://traffic.libsyn.com/secure/talkpython/python-bytes-2.mp3',
        'description': 'Technology learning audio content'
      },
    ];
  }

  /// Pause current playback
  Future<void> pause() async {
    try {
      if (_currentSource == AudioSource.podcast) {
        await _audioPlayer.pause();
      }

      if (kDebugMode) {
        print('🔊 Audio paused');
      }
    } catch (e) {
      if (kDebugMode) {
        print('🔴 Error pausing audio: $e');
      }
    }
  }

  /// Resume current playback
  Future<void> resume() async {
    try {
      if (_currentSource == AudioSource.podcast) {
        await _audioPlayer.resume();
      }

      if (kDebugMode) {
        print('🔊 Audio resumed');
      }
    } catch (e) {
      if (kDebugMode) {
        print('🔴 Error resuming audio: $e');
      }
    }
  }

  /// Stop current playback
  Future<void> stop() async {
    try {
      await _audioPlayer.stop();
      _updateState(AudioPlayerState.stopped);
      _currentModuleId = null;
      _currentSource = null;

      if (kDebugMode) {
        print('🔊 Audio stopped');
      }
    } catch (e) {
      if (kDebugMode) {
        print('🔴 Error stopping audio: $e');
      }
    }
  }

  /// Seek to position (only for podcast playback)
  Future<void> seek(Duration position) async {
    try {
      if (_currentSource == AudioSource.podcast) {
        await _audioPlayer.seek(position);
      }
    } catch (e) {
      if (kDebugMode) {
        print('🔴 Error seeking audio: $e');
      }
    }
  }

  /// Set volume (0.0 to 1.0)
  Future<void> setVolume(double volume) async {
    try {
      await _audioPlayer.setVolume(volume);
    } catch (e) {
      if (kDebugMode) {
        print('🔴 Error setting volume: $e');
      }
    }
  }

  /// Check if currently playing audio for a specific module
  bool isPlayingModule(String moduleId) {
    return _currentModuleId == moduleId &&
        _currentState == AudioPlayerState.playing;
  }

  /// Check if currently loading audio for a specific module
  bool isLoadingModule(String moduleId) {
    return _currentModuleId == moduleId &&
        _currentState == AudioPlayerState.loading;
  }

  void _updateState(AudioPlayerState newState) {
    _currentState = newState;
    _stateController.add(newState);
  }

  /// Dispose resources
  Future<void> dispose() async {
    try {
      await stop();
      await _audioPlayer.dispose();
      await _stateController.close();
      await _positionController.close();
      await _durationController.close();

      if (kDebugMode) {
        print('🔊 AudioHelper disposed');
      }
    } catch (e) {
      if (kDebugMode) {
        print('🔴 Error disposing AudioHelper: $e');
      }
    }
  }
}
