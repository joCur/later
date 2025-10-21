import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// Theme provider with animated transitions and persistent storage
///
/// Manages application theme mode (light, dark, system) with:
/// - Smooth 250ms transitions with animation state tracking
/// - Persistent storage using SharedPreferences
/// - Toggle between light/dark modes (skipping system)
/// - System brightness detection for auto-theme
///
/// Usage:
/// ```dart
/// // In main app
/// ChangeNotifierProvider(create: (_) => ThemeProvider()),
///
/// // Load preference on startup
/// context.read<ThemeProvider>().loadThemePreference();
///
/// // Toggle theme
/// await context.read<ThemeProvider>().toggleTheme();
///
/// // Set specific mode
/// await context.read<ThemeProvider>().setThemeMode(ThemeMode.dark);
/// ```
class ThemeProvider extends ChangeNotifier {
  ThemeMode _themeMode = ThemeMode.system;
  bool _isTransitioning = false;

  /// Current theme mode (light, dark, or system)
  ThemeMode get themeMode => _themeMode;

  /// Whether theme is currently transitioning
  bool get isTransitioning => _isTransitioning;

  /// Returns true if current effective theme is dark
  ///
  /// When in system mode, checks platform brightness.
  /// Otherwise returns true if theme mode is dark.
  bool get isDarkMode {
    if (_themeMode == ThemeMode.system) {
      return WidgetsBinding.instance.platformDispatcher.platformBrightness ==
          Brightness.dark;
    }
    return _themeMode == ThemeMode.dark;
  }

  /// Load saved theme preference from SharedPreferences
  ///
  /// Called on app startup to restore user's theme choice.
  /// Defaults to system theme if no preference is saved.
  Future<void> loadThemePreference() async {
    final prefs = await SharedPreferences.getInstance();
    final themeModeString = prefs.getString('themeMode') ?? 'system';
    _themeMode = _parseThemeMode(themeModeString);
    notifyListeners();
  }

  /// Set theme mode with animated transition
  ///
  /// Updates theme and saves preference to storage.
  /// Sets [isTransitioning] to true during animation (250ms).
  /// No-op if new mode equals current mode (skips animation).
  ///
  /// Example:
  /// ```dart
  /// await provider.setThemeMode(ThemeMode.dark);
  /// ```
  Future<void> setThemeMode(ThemeMode mode) async {
    if (_themeMode == mode) {
      // Still save preference even if mode hasn't changed
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString('themeMode', mode.toString().split('.').last);
      return;
    }

    _isTransitioning = true;
    notifyListeners();

    // Brief delay to trigger animation
    await Future<void>.delayed(const Duration(milliseconds: 50));

    _themeMode = mode;
    notifyListeners();

    // Save preference
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('themeMode', mode.toString().split('.').last);

    // Wait for transition to complete (250ms total)
    await Future<void>.delayed(const Duration(milliseconds: 200));

    _isTransitioning = false;
    notifyListeners();
  }

  /// Toggle between light and dark modes
  ///
  /// Skips system mode for direct user control.
  /// If currently in system mode, switches based on current effective brightness.
  ///
  /// Example:
  /// ```dart
  /// await provider.toggleTheme();
  /// ```
  Future<void> toggleTheme() async {
    final nextMode = isDarkMode ? ThemeMode.light : ThemeMode.dark;
    await setThemeMode(nextMode);
  }

  /// Parse theme mode from string
  ///
  /// Converts saved preference string back to ThemeMode enum.
  /// Returns system mode for invalid or missing values.
  ThemeMode _parseThemeMode(String value) {
    switch (value) {
      case 'light':
        return ThemeMode.light;
      case 'dark':
        return ThemeMode.dark;
      default:
        return ThemeMode.system;
    }
  }
}
