import 'dart:io' show Platform;
import 'package:flutter/foundation.dart';

/// Configuration class to determine audio service capabilities
/// based on the current platform
class AudioConfig {
  static const bool kTtsEnabled = kDebugMode && !kIsWeb;

  /// Check if Text-to-Speech is supported on current platform
  static bool get isTtsSupported {
    if (kIsWeb) return false;

    try {
      // TTS is problematic on Windows due to NUGET.exe dependencies
      if (Platform.isWindows) return false;

      // TTS should work on other platforms
      return Platform.isAndroid ||
          Platform.isIOS ||
          Platform.isMacOS ||
          Platform.isLinux;
    } catch (e) {
      // If Platform check fails, assume no TTS support
      return false;
    }
  }

  /// Check if audio playback is supported (should work on all platforms)
  static bool get isAudioPlaybackSupported => true;

  /// Get recommended audio service based on platform capabilities
  static AudioServiceType get recommendedService {
    if (isTtsSupported) {
      return AudioServiceType.full;
    } else {
      return AudioServiceType.simplified;
    }
  }
}

enum AudioServiceType {
  full, // Full audio service with TTS support
  simplified // Simplified audio service without TTS
}
