import 'package:shared_preferences/shared_preferences.dart';

/// Service for managing app-wide preferences using SharedPreferences
/// Provides a clean interface for storing simple key-value settings
/// Follows singleton pattern similar to HiveDatabase
class PreferencesService {
  // Singleton instance
  factory PreferencesService() => _instance;
  PreferencesService._internal();

  static final PreferencesService _instance = PreferencesService._internal();

  // Preference keys
  static const String _lastSelectedSpaceIdKey = 'last_selected_space_id';
  static const String _themeModeKey = 'themeMode';

  // SharedPreferences instance
  SharedPreferences? _prefs;

  /// Initialize SharedPreferences
  /// Must be called before using any preference operations
  static Future<void> initialize() async {
    _instance._prefs = await SharedPreferences.getInstance();
  }

  /// Get the last selected space ID
  /// Returns null if no space ID has been persisted
  /// Throws StateError if not initialized
  String? getLastSelectedSpaceId() {
    if (_prefs == null) {
      throw StateError(
        'PreferencesService not initialized. Call PreferencesService.initialize() first.',
      );
    }
    return _prefs!.getString(_lastSelectedSpaceIdKey);
  }

  /// Save the last selected space ID
  /// Throws StateError if not initialized
  Future<void> setLastSelectedSpaceId(String spaceId) async {
    if (_prefs == null) {
      throw StateError(
        'PreferencesService not initialized. Call PreferencesService.initialize() first.',
      );
    }
    await _prefs!.setString(_lastSelectedSpaceIdKey, spaceId);
  }

  /// Clear the last selected space ID
  /// Used when the persisted space is deleted or for cleanup/reset scenarios
  /// Throws StateError if not initialized
  Future<void> clearLastSelectedSpaceId() async {
    if (_prefs == null) {
      throw StateError(
        'PreferencesService not initialized. Call PreferencesService.initialize() first.',
      );
    }
    await _prefs!.remove(_lastSelectedSpaceIdKey);
  }

  /// Get the saved theme mode
  /// Returns null if no theme mode has been persisted
  /// Throws StateError if not initialized
  String? getThemeMode() {
    if (_prefs == null) {
      throw StateError(
        'PreferencesService not initialized. Call PreferencesService.initialize() first.',
      );
    }
    return _prefs!.getString(_themeModeKey);
  }

  /// Save the theme mode
  /// Throws StateError if not initialized
  Future<void> setThemeMode(String themeMode) async {
    if (_prefs == null) {
      throw StateError(
        'PreferencesService not initialized. Call PreferencesService.initialize() first.',
      );
    }
    await _prefs!.setString(_themeModeKey, themeMode);
  }

  /// Check if the service has been initialized
  bool get isInitialized => _prefs != null;

  /// Get all stored preferences (useful for debugging)
  Map<String, dynamic> getAllPreferences() {
    if (_prefs == null) {
      throw StateError(
        'PreferencesService not initialized. Call PreferencesService.initialize() first.',
      );
    }
    return {
      'lastSelectedSpaceId': _prefs!.getString(_lastSelectedSpaceIdKey),
      'themeMode': _prefs!.getString(_themeModeKey),
    };
  }

  /// Clear all preferences (useful for testing or reset)
  Future<void> clearAll() async {
    if (_prefs == null) {
      throw StateError(
        'PreferencesService not initialized. Call PreferencesService.initialize() first.',
      );
    }
    await _prefs!.clear();
  }

  /// Reset the service (useful for testing)
  /// This clears the internal SharedPreferences instance
  void reset() {
    _prefs = null;
  }
}
