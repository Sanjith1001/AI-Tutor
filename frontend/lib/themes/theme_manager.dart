import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class ThemeManager {
  static const String _key = 'theme_mode';
  
  static final ThemeManager _instance = ThemeManager._internal();
  factory ThemeManager() => _instance;
  ThemeManager._internal();

  final ValueNotifier<ThemeMode> themeModeNotifier = ValueNotifier<ThemeMode>(ThemeMode.dark);

  Future<void> init() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final modeString = prefs.getString(_key);
      if (modeString != null) {
        themeModeNotifier.value = _parseThemeMode(modeString);
      } else {
        themeModeNotifier.value = ThemeMode.dark;
      }
    } catch (e) {
      debugPrint('Error initializing theme mode: $e');
      themeModeNotifier.value = ThemeMode.dark;
    }
  }

  Future<void> setThemeMode(ThemeMode mode) async {
    themeModeNotifier.value = mode;
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString(_key, _getStringFromThemeMode(mode));
    } catch (e) {
      debugPrint('Error saving theme mode: $e');
    }
  }

  ThemeMode _parseThemeMode(String val) {
    switch (val) {
      case 'light':
        return ThemeMode.light;
      case 'dark':
        return ThemeMode.dark;
      case 'system':
      default:
        return ThemeMode.system;
    }
  }

  String _getStringFromThemeMode(ThemeMode mode) {
    switch (mode) {
      case ThemeMode.light:
        return 'light';
      case ThemeMode.dark:
        return 'dark';
      case ThemeMode.system:
      default:
        return 'system';
    }
  }
}
