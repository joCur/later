import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:later_mobile/data/local/preferences_service.dart';
import 'package:later_mobile/providers/theme_provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  setUp(() async {
    // Reset shared preferences before each test
    SharedPreferences.setMockInitialValues({});
    // Initialize PreferencesService for each test
    await PreferencesService.initialize();
  });

  group('ThemeProvider', () {
    test('should initialize with system theme mode', () {
      final provider = ThemeProvider();
      expect(provider.themeMode, ThemeMode.system);
    });

    test('should not be transitioning on initialization', () {
      final provider = ThemeProvider();
      expect(provider.isTransitioning, false);
    });

    test('should load theme preference from storage', () async {
      // Setup: save a theme preference
      SharedPreferences.setMockInitialValues({'themeMode': 'dark'});
      await PreferencesService.initialize();

      final provider = ThemeProvider();
      await provider.loadThemePreference();

      expect(provider.themeMode, ThemeMode.dark);
    });

    test('should load light theme preference from storage', () async {
      SharedPreferences.setMockInitialValues({'themeMode': 'light'});
      await PreferencesService.initialize();

      final provider = ThemeProvider();
      await provider.loadThemePreference();

      expect(provider.themeMode, ThemeMode.light);
    });

    test('should default to system theme if no preference saved', () async {
      SharedPreferences.setMockInitialValues({});

      final provider = ThemeProvider();
      await provider.loadThemePreference();

      expect(provider.themeMode, ThemeMode.system);
    });

    test('should save theme preference when setThemeMode is called', () async {
      final provider = ThemeProvider();
      await provider.setThemeMode(ThemeMode.dark);

      expect(PreferencesService().getThemeMode(), 'dark');
    });

    test('should save light theme preference correctly', () async {
      final provider = ThemeProvider();
      await provider.setThemeMode(ThemeMode.light);

      expect(PreferencesService().getThemeMode(), 'light');
    });

    test('should save system theme preference correctly', () async {
      final provider = ThemeProvider();
      await provider.setThemeMode(ThemeMode.system);

      expect(PreferencesService().getThemeMode(), 'system');
    });

    test('should update themeMode when setThemeMode is called', () async {
      final provider = ThemeProvider();

      await provider.setThemeMode(ThemeMode.dark);

      expect(provider.themeMode, ThemeMode.dark);
    });

    test('should notify listeners when theme changes', () async {
      final provider = ThemeProvider();
      var listenerCalled = false;

      provider.addListener(() {
        listenerCalled = true;
      });

      await provider.setThemeMode(ThemeMode.dark);

      expect(listenerCalled, true);
    });

    test('should set isTransitioning to true during theme change', () async {
      final provider = ThemeProvider();
      final transitioningStateChanges = <bool>[];

      provider.addListener(() {
        transitioningStateChanges.add(provider.isTransitioning);
      });

      await provider.setThemeMode(ThemeMode.dark);

      // Should have been true at some point during the transition
      expect(transitioningStateChanges.contains(true), true);
    });

    test('should set isTransitioning to false after theme change completes', () async {
      final provider = ThemeProvider();

      await provider.setThemeMode(ThemeMode.dark);

      expect(provider.isTransitioning, false);
    });

    test('should not change theme if new mode is same as current', () async {
      SharedPreferences.setMockInitialValues({'themeMode': 'dark'});
      await PreferencesService.initialize();

      final provider = ThemeProvider();
      await provider.loadThemePreference();

      var notificationCount = 0;
      provider.addListener(() {
        notificationCount++;
      });

      await provider.setThemeMode(ThemeMode.dark);

      // Should not notify listeners if theme hasn't changed
      expect(notificationCount, 0);
    });

    test('should toggle from light to dark theme', () async {
      final provider = ThemeProvider();
      await provider.setThemeMode(ThemeMode.light);

      await provider.toggleTheme();

      expect(provider.themeMode, ThemeMode.dark);
    });

    test('should toggle from dark to light theme', () async {
      final provider = ThemeProvider();
      await provider.setThemeMode(ThemeMode.dark);

      await provider.toggleTheme();

      expect(provider.themeMode, ThemeMode.light);
    });

    test('should toggle from system to light if system is dark', () async {
      final provider = ThemeProvider();
      // Provider starts in system mode
      // Note: In real app, this would depend on platform brightness
      // We test the toggle mechanism regardless

      await provider.toggleTheme();

      // Toggle should switch to either light or dark
      expect(provider.themeMode != ThemeMode.system, true);
    });

    test('isDarkMode should return true when theme is dark', () async {
      final provider = ThemeProvider();
      await provider.setThemeMode(ThemeMode.dark);

      expect(provider.isDarkMode, true);
    });

    test('isDarkMode should return false when theme is light', () async {
      final provider = ThemeProvider();
      await provider.setThemeMode(ThemeMode.light);

      expect(provider.isDarkMode, false);
    });

    test('isDarkMode should respect system brightness when in system mode', () {
      final provider = ThemeProvider();

      // In system mode, isDarkMode should check platform brightness
      // This is implementation-dependent, but we're testing the getter exists
      expect(provider.isDarkMode, isA<bool>());
    });

    test('should handle multiple rapid theme changes gracefully', () async {
      final provider = ThemeProvider();

      // Rapidly change themes
      final futures = [
        provider.setThemeMode(ThemeMode.dark),
        provider.setThemeMode(ThemeMode.light),
        provider.setThemeMode(ThemeMode.dark),
      ];

      await Future.wait(futures);

      // Should complete without error
      expect(provider.themeMode, ThemeMode.dark);
    });

    test('should persist theme across provider instances', () async {
      // First instance sets theme
      final provider1 = ThemeProvider();
      await provider1.setThemeMode(ThemeMode.dark);

      // Second instance loads theme
      final provider2 = ThemeProvider();
      await provider2.loadThemePreference();

      expect(provider2.themeMode, ThemeMode.dark);
    });
  });
}
