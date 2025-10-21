import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

/// Test helper for responsive behavior tests
///
/// Provides utilities for testing widgets at different screen sizes
class ResponsiveTestHelper {
  /// Sets up a widget test with specific screen dimensions
  static Future<void> testAtSize(
    WidgetTester tester, {
    required double width,
    required double height,
    required Widget child,
  }) async {
    tester.view.physicalSize = Size(width, height);
    tester.view.devicePixelRatio = 1.0;

    await tester.pumpWidget(child);
  }

  /// Wraps a widget with MaterialApp for testing
  static Widget wrapWithApp(Widget child) {
    return MaterialApp(
      home: Scaffold(
        body: child,
      ),
    );
  }

  /// Cleans up view size after test
  static void resetView(WidgetTester tester) {
    tester.view.resetPhysicalSize();
    tester.view.resetDevicePixelRatio();
  }
}
