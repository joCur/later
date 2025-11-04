import 'package:flutter/material.dart';
import 'package:later_mobile/core/theme/temporal_flow_theme.dart';

/// Helper functions for widget testing.
///
/// This file provides common utilities for setting up widget tests
/// with proper theme configuration.

/// Creates a MaterialApp with proper theme configuration for widget tests.
///
/// This helper ensures that all design system components have access to
/// the required [TemporalFlowTheme] extension.
///
/// Example usage:
/// ```dart
/// await tester.pumpWidget(
///   testApp(
///     MyWidget(),
///   ),
/// );
/// ```
Widget testApp(Widget child) {
  return MaterialApp(
    theme: ThemeData.light().copyWith(
      extensions: <ThemeExtension<dynamic>>[TemporalFlowTheme.light()],
    ),
    home: Scaffold(body: child),
  );
}

/// Creates a MaterialApp with dark theme configuration for widget tests.
///
/// This helper ensures that all design system components have access to
/// the required [TemporalFlowTheme] extension in dark mode.
///
/// Example usage:
/// ```dart
/// await tester.pumpWidget(
///   testAppDark(
///     MyWidget(),
///   ),
/// );
/// ```
Widget testAppDark(Widget child) {
  return MaterialApp(
    theme: ThemeData.dark().copyWith(
      extensions: <ThemeExtension<dynamic>>[TemporalFlowTheme.dark()],
    ),
    home: Scaffold(body: child),
  );
}
