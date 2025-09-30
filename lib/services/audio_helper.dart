// services/audio_helper.dart

import 'dart:async';
import 'package:audioplayers/audioplayers.dart';
import 'package:flutter_tts/flutter_tts.dart';
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
  tts,
}

class AudioHelper {
  static final AudioHelper _instance = AudioHelper._internal();
  factory AudioHelper() => _instance;
  AudioHelper._internal();

  // Audio player for podcast URLs
  final AudioPlayer _audioPlayer = AudioPlayer();

  // Text-to-speech for fallback
  final FlutterTts _flutterTts = FlutterTts();

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
      // Initialize TTS
      await _initializeTts();

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

  Future<void> _initializeTts() async {
    try {
      // Configure TTS settings
      await _flutterTts.setLanguage("en-US");
      await _flutterTts
          .setSpeechRate(0.8); // Slightly slower for better comprehension
      await _flutterTts.setVolume(1.0);
      await _flutterTts.setPitch(1.0);

      // Set up TTS callbacks
      _flutterTts.setStartHandler(() {
        if (_currentSource == AudioSource.tts) {
          _updateState(AudioPlayerState.playing);
        }
      });

      _flutterTts.setCompletionHandler(() {
        if (_currentSource == AudioSource.tts) {
          _updateState(AudioPlayerState.stopped);
          _currentModuleId = null;
          _currentSource = null;
        }
      });

      _flutterTts.setErrorHandler((dynamic message) {
        if (kDebugMode) {
          print('🔴 TTS Error: $message');
        }
        if (_currentSource == AudioSource.tts) {
          _updateState(AudioPlayerState.error);
        }
      });

      _flutterTts.setCancelHandler(() {
        if (_currentSource == AudioSource.tts) {
          _updateState(AudioPlayerState.stopped);
          _currentModuleId = null;
          _currentSource = null;
        }
      });
    } catch (e) {
      if (kDebugMode) {
        print('🔴 TTS initialization error: $e');
      }
      throw e;
    }
  }

  /// Play audio for a module - podcast URL if available, otherwise TTS
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
        // Fallback to TTS
        await _playTts(description);
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
        print('� Playing podcast: $podcastUrl');
      }
    } catch (e) {
      if (kDebugMode) {
        print('🔴 Podcast playback failed, falling back to TTS: $e');
      }
      // Fallback to TTS if podcast fails
      _currentSource = AudioSource.tts;
      throw e; // Re-throw to trigger TTS fallback in calling method
    }
  }

  Future<void> _playTts(String text) async {
    try {
      _currentSource = AudioSource.tts;

      // Clean the text for better TTS
      String cleanText = _cleanTextForTts(text);

      await _flutterTts.speak(cleanText);
      if (kDebugMode) {
        print('🔊 Playing TTS for text: ${cleanText.substring(0, 50)}...');
      }
    } catch (e) {
      if (kDebugMode) {
        print('🔴 TTS playback failed: $e');
      }
      throw e;
    }
  }

  /// Clean text for better TTS pronunciation
  String _cleanTextForTts(String text) {
    return text
        .replaceAll(RegExp(r'\*\*([^*]+)\*\*'), r'\1') // Remove markdown bold
        .replaceAll(RegExp(r'\*([^*]+)\*'), r'\1') // Remove markdown italic
        .replaceAll(RegExp(r'#{1,6}\s*'), '') // Remove markdown headers
        .replaceAll(
            RegExp(r'\[([^\]]+)\]\([^)]+\)'), r'\1') // Remove markdown links
        .replaceAll(RegExp(r'`([^`]+)`'), r'\1') // Remove code blocks
        .replaceAll(RegExp(r'\s+'), ' ') // Normalize whitespace
        .trim();
  }

  /// Pause current playback
  Future<void> pause() async {
    try {
      if (_currentSource == AudioSource.podcast) {
        await _audioPlayer.pause();
      } else if (_currentSource == AudioSource.tts) {
        await _flutterTts.pause();
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
      } else if (_currentSource == AudioSource.tts) {
        // TTS doesn't have resume, need to restart from beginning
        await _flutterTts.speak(_cleanTextForTts('Resuming text-to-speech...'));
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
      if (_currentSource == AudioSource.podcast) {
        await _audioPlayer.stop();
      } else if (_currentSource == AudioSource.tts) {
        await _flutterTts.stop();
      }

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
      await _flutterTts.setVolume(volume);
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
      await _flutterTts.stop();
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
