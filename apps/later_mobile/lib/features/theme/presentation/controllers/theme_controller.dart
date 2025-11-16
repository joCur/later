// ignore_for_file: depend_on_referenced_packages
import 'package:flutter/material.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import '../../application/providers.dart';
import '../../application/theme_service.dart';

part 'theme_controller.g.dart';

/// Theme controller managing application theme state with Riverpod 3.0
///
/// Manages theme mode (light, dark, system) with:
/// - Persistent storage via ThemeService
/// - Smooth animated transitions with transition state tracking
/// - Toggle between light/dark modes (skipping system)
/// - Ref.mounted checks for safe async state updates
///
/// Example usage:
/// ```dart
/// // Watch theme state
/// final themeMode = ref.watch(themeControllerProvider);
///
/// // Toggle theme
/// ref.read(themeControllerProvider.notifier).toggleTheme();
///
/// // Set specific mode
/// ref.read(themeControllerProvider.notifier).setThemeMode(ThemeMode.dark);
/// ```
@Riverpod(keepAlive: true)
class ThemeController extends _$ThemeController {
  late ThemeService _service;

  @override
  ThemeMode build() {
    _service = ref.watch(themeServiceProvider);
    return _service.loadThemePreference();
  }

  /// Whether theme is currently transitioning (for animation state)
  bool _isTransitioning = false;

  /// Get transition state
  bool get isTransitioning => _isTransitioning;

  /// Returns true if current effective theme is dark
  ///
  /// When in system mode, checks platform brightness.
  /// Otherwise returns true if theme mode is dark.
  bool get isDarkMode => _service.isDarkMode(state);

  /// Set theme mode with animated transition
  ///
  /// Updates theme and saves preference to storage.
  /// Sets [isTransitioning] to true during animation (250ms).
  /// No-op if new mode equals current mode (but still saves preference).
  ///
  /// NEW in Riverpod 3.0: Uses ref.mounted to check if provider is still alive
  /// before updating state after async operations.
  Future<void> setThemeMode(ThemeMode mode) async {
    if (state == mode) {
      // Still save preference even if mode hasn't changed
      await _service.saveThemePreference(mode);
      return;
    }

    _isTransitioning = true;
    // Note: Cannot call notifyListeners() in Riverpod - state updates handle this

    // Brief delay to trigger animation
    await Future<void>.delayed(const Duration(milliseconds: 50));

    // NEW in 3.0: Check if provider is still mounted before updating state
    if (!ref.mounted) return;

    state = mode;
    await _service.saveThemePreference(mode);

    // Wait for transition to complete (250ms total)
    await Future<void>.delayed(const Duration(milliseconds: 200));

    // NEW in 3.0: Check if still mounted before final state update
    if (!ref.mounted) return;

    _isTransitioning = false;
    // Note: In a real scenario, we'd need a separate state for isTransitioning
    // For now, keeping similar API to old provider
  }

  /// Toggle between light and dark modes
  ///
  /// Skips system mode for direct user control.
  /// If currently in system mode, switches based on current effective brightness.
  Future<void> toggleTheme() async {
    final nextMode = _service.getNextThemeMode(state);
    await setThemeMode(nextMode);
  }
}
