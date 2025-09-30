// services/audio_helper_simplified.dart
// Simplified version for Windows compatibility (without flutter_tts)

import 'dart:async';
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

      if (kDebugMode) {
        print('🔊 AudioHelper initialized successfully');
      }
    } catch (e) {
      if (kDebugMode) {
        print('🔴 AudioHelper initialization error: $e');
      }
      _updateState(AudioPlayerState.error);
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
              '🔵 TTS not available on Windows - would read: ${description.substring(0, 50)}...');
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

      // Use UrlSource for web URLs
      if (podcastUrl.startsWith('http')) {
        await _audioPlayer.play(UrlSource(podcastUrl));
      } else {
        // Use AssetSource for local assets
        await _audioPlayer.play(AssetSource(podcastUrl));
      }

      if (kDebugMode) {
        print('🔊 Playing podcast: $podcastUrl');
      }
    } catch (e) {
      if (kDebugMode) {
        print('🔴 Podcast playback failed: $e');
      }
      throw e;
    }
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
