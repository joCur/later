import 'package:flutter/material.dart';
import '../../../data/local/preferences_service.dart';

/// Theme service handling business logic for theme management
///
/// Extracts theme-related business logic from ThemeProvider:
/// - Loading theme preference from storage
/// - Saving theme preference to storage
/// - Parsing theme mode from string
/// - Determining effective dark mode state
///
/// This service is used by the theme controller for state management.
class ThemeService {
  ThemeService({PreferencesService? preferencesService})
      : _preferencesService = preferencesService ?? PreferencesService();

  final PreferencesService _preferencesService;

  /// Load saved theme preference from storage
  ///
  /// Returns the saved ThemeMode, or ThemeMode.system if no preference exists.
  /// Called on app startup to restore user's theme choice.
  ThemeMode loadThemePreference() {
    final themeModeString = _preferencesService.getThemeMode() ?? 'system';
    return parseThemeMode(themeModeString);
  }

  /// Save theme preference to storage
  ///
  /// Persists the user's theme choice for future app sessions.
  /// Converts ThemeMode enum to string format for storage.
  Future<void> saveThemePreference(ThemeMode mode) async {
    await _preferencesService.setThemeMode(mode.toString().split('.').last);
  }

  /// Parse theme mode from string
  ///
  /// Converts saved preference string back to ThemeMode enum.
  /// Returns ThemeMode.system for invalid or missing values.
  ThemeMode parseThemeMode(String value) {
    switch (value) {
      case 'light':
        return ThemeMode.light;
      case 'dark':
        return ThemeMode.dark;
      default:
        return ThemeMode.system;
    }
  }

  /// Determine if effective theme is dark mode
  ///
  /// When in system mode, checks platform brightness.
  /// Otherwise returns true if theme mode is dark.
  bool isDarkMode(ThemeMode mode) {
    if (mode == ThemeMode.system) {
      return WidgetsBinding.instance.platformDispatcher.platformBrightness ==
          Brightness.dark;
    }
    return mode == ThemeMode.dark;
  }

  /// Get next theme mode for toggle operation
  ///
  /// Toggles between light and dark modes (skips system mode).
  /// If currently in system mode, switches based on current effective brightness.
  ThemeMode getNextThemeMode(ThemeMode currentMode) {
    return isDarkMode(currentMode) ? ThemeMode.light : ThemeMode.dark;
  }
}
