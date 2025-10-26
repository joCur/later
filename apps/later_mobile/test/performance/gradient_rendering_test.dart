import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:later_mobile/design_system/tokens/tokens.dart';

/// Performance tests for gradient rendering in the Temporal Flow design system
///
/// Tests gradient rendering performance with various configurations:
/// - Multiple gradients on screen (10, 25, 50, 100+)
/// - Gradient shader caching
/// - Gradient animation performance
/// - Memory usage with gradients
/// - Different screen sizes
///
/// Target: 60fps minimum (16.67ms per frame)
void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  group('Gradient Rendering Performance Tests', () {
    late Stopwatch stopwatch;

    setUp(() {
      stopwatch = Stopwatch();
    });

    testWidgets('Benchmark: 10 gradients rendering time', (tester) async {
      stopwatch.start();

      await tester.pumpWidget(_buildGradientGrid(10));
      await tester.pumpAndSettle();

      stopwatch.stop();
      final elapsed = stopwatch.elapsedMilliseconds;

      // Expect rendering to complete in reasonable time (relaxed for test environment)
      expect(elapsed, lessThan(500), reason: '10 gradients should render quickly');

      debugPrint('10 gradients rendered in ${elapsed}ms');
    });

    testWidgets('Benchmark: 25 gradients rendering time', (tester) async {
      stopwatch.start();

      await tester.pumpWidget(_buildGradientGrid(25));
      await tester.pumpAndSettle();

      stopwatch.stop();
      final elapsed = stopwatch.elapsedMilliseconds;

      expect(elapsed, lessThan(600), reason: '25 gradients should render efficiently');

      debugPrint('25 gradients rendered in ${elapsed}ms');
    });

    testWidgets('Benchmark: 50 gradients rendering time', (tester) async {
      stopwatch.start();

      await tester.pumpWidget(_buildGradientGrid(50));
      await tester.pumpAndSettle();

      stopwatch.stop();
      final elapsed = stopwatch.elapsedMilliseconds;

      expect(elapsed, lessThan(800), reason: '50 gradients should maintain performance');

      debugPrint('50 gradients rendered in ${elapsed}ms');
    });

    testWidgets('Benchmark: 100 gradients rendering time', (tester) async {
      stopwatch.start();

      await tester.pumpWidget(_buildGradientGrid(100));
      await tester.pumpAndSettle();

      stopwatch.stop();
      final elapsed = stopwatch.elapsedMilliseconds;

      // More lenient threshold for large number of gradients
      expect(elapsed, lessThan(1200), reason: '100 gradients should remain functional');

      debugPrint('100 gradients rendered in ${elapsed}ms');
    });

    testWidgets('Frame rate test: Multiple gradients during scroll', (tester) async {
      await tester.pumpWidget(_buildScrollableGradientList(50));
      await tester.pumpAndSettle();

      // Enable frame timing tracking
      final frames = <Duration>[];
      tester.binding.addTimingsCallback((timings) {
        for (final timing in timings) {
          frames.add(timing.totalSpan);
        }
      });

      // Simulate scrolling
      await tester.fling(
        find.byType(ListView),
        const Offset(0, -500),
        1000,
      );

      // Pump frames during scroll
      for (int i = 0; i < 60; i++) {
        await tester.pump(const Duration(milliseconds: 16));
      }

      await tester.pumpAndSettle();

      // Analyze frame times
      if (frames.isNotEmpty) {
        final averageFrameTime = frames.fold<Duration>(
          Duration.zero,
          (prev, duration) => prev + duration,
        ) ~/ frames.length;

        debugPrint('Average frame time: ${averageFrameTime.inMicroseconds / 1000}ms');
        debugPrint('Total frames: ${frames.length}');

        // Count janky frames (>16.67ms = 60fps threshold)
        final jankyFrames = frames.where((d) => d.inMilliseconds > 16).length;
        final jankyPercentage = (jankyFrames / frames.length) * 100;

        debugPrint('Janky frames: $jankyFrames (${jankyPercentage.toStringAsFixed(1)}%)');

        // Allow up to 10% janky frames during complex scroll animations
        expect(jankyPercentage, lessThan(10),
          reason: 'Should maintain 60fps with <10% janky frames');
      }
    });

    testWidgets('Gradient shader caching effectiveness', (tester) async {
      // Build same gradient multiple times
      await tester.pumpWidget(_buildRepeatedGradientWidget());
      await tester.pumpAndSettle();

      stopwatch.start();

      // Rebuild the widget
      await tester.pumpWidget(_buildRepeatedGradientWidget());
      await tester.pumpAndSettle();

      stopwatch.stop();
      final rebuildTime = stopwatch.elapsedMilliseconds;

      debugPrint('Gradient rebuild time: ${rebuildTime}ms');

      // Rebuild should be fast due to shader caching
      expect(rebuildTime, lessThan(50),
        reason: 'Shader caching should make rebuilds fast');
    });

    testWidgets('Animated gradient performance', (tester) async {
      await tester.pumpWidget(_buildAnimatedGradientWidget());
      await tester.pump();

      final frames = <Duration>[];
      tester.binding.addTimingsCallback((timings) {
        for (final timing in timings) {
          frames.add(timing.totalSpan);
        }
      });

      // Animate for 1 second (60 frames at 60fps)
      for (int i = 0; i < 60; i++) {
        await tester.pump(const Duration(milliseconds: 16));
      }

      if (frames.isNotEmpty) {
        final averageFrameTime = frames.fold<Duration>(
          Duration.zero,
          (prev, duration) => prev + duration,
        ) ~/ frames.length;

        debugPrint('Animated gradient avg frame time: ${averageFrameTime.inMicroseconds / 1000}ms');

        // Should maintain 60fps during animation
        expect(averageFrameTime.inMilliseconds, lessThanOrEqualTo(16),
          reason: 'Animated gradients should maintain 60fps');
      }
    });

    testWidgets('Gradient rendering on mobile screen size', (tester) async {
      tester.view.physicalSize = const Size(375, 667); // iPhone SE size
      tester.view.devicePixelRatio = 2.0;

      addTearDown(() {
        tester.view.resetPhysicalSize();
        tester.view.resetDevicePixelRatio();
      });

      await tester.pumpWidget(_buildGradientGrid(25));
      await tester.pumpAndSettle();

      // Verify no overflow
      expect(tester.takeException(), isNull);
    });

    testWidgets('Gradient rendering on tablet screen size', (tester) async {
      tester.view.physicalSize = const Size(768, 1024); // iPad size
      tester.view.devicePixelRatio = 2.0;

      addTearDown(() {
        tester.view.resetPhysicalSize();
        tester.view.resetDevicePixelRatio();
      });

      await tester.pumpWidget(_buildGradientGrid(50));
      await tester.pumpAndSettle();

      expect(tester.takeException(), isNull);
    });

    testWidgets('Gradient rendering on desktop screen size', (tester) async {
      tester.view.physicalSize = const Size(1920, 1080); // Full HD
      tester.view.devicePixelRatio = 1.0;

      addTearDown(() {
        tester.view.resetPhysicalSize();
        tester.view.resetDevicePixelRatio();
      });

      await tester.pumpWidget(_buildGradientGrid(100));
      await tester.pumpAndSettle();

      expect(tester.takeException(), isNull);
    });

    testWidgets('Mixed gradient types performance', (tester) async {
      await tester.pumpWidget(_buildMixedGradientsWidget());
      await tester.pumpAndSettle();

      final frames = <Duration>[];
      tester.binding.addTimingsCallback((timings) {
        for (final timing in timings) {
          frames.add(timing.totalSpan);
        }
      });

      // Scroll through mixed gradients
      await tester.fling(
        find.byType(ListView),
        const Offset(0, -300),
        500,
      );

      for (int i = 0; i < 30; i++) {
        await tester.pump(const Duration(milliseconds: 16));
      }

      await tester.pumpAndSettle();

      if (frames.isNotEmpty) {
        final jankyFrames = frames.where((d) => d.inMilliseconds > 16).length;
        final jankyPercentage = (jankyFrames / frames.length) * 100;

        debugPrint('Mixed gradients janky frames: ${jankyPercentage.toStringAsFixed(1)}%');

        expect(jankyPercentage, lessThan(15));
      }
    });

    testWidgets('Gradient memory usage estimation', (tester) async {
      // Create a large number of gradient widgets
      await tester.pumpWidget(_buildGradientGrid(200));
      await tester.pump();

      // Note: Actual memory profiling requires running on device
      // This test verifies no crashes with many gradients
      expect(tester.takeException(), isNull);

      debugPrint('200 gradients rendered without errors');
    });
  });
}

// Helper functions

Widget _buildGradientGrid(int count) {
  return MaterialApp(
    home: Scaffold(
      body: GridView.builder(
        gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: 5,
        ),
        itemCount: count,
        itemBuilder: (context, index) {
          return Container(
            margin: const EdgeInsets.all(2),
            decoration: BoxDecoration(
              gradient: _getGradientForIndex(index),
            ),
          );
        },
      ),
    ),
  );
}

Widget _buildScrollableGradientList(int count) {
  return MaterialApp(
    home: Scaffold(
      body: ListView.builder(
        itemCount: count,
        itemBuilder: (context, index) {
          return Container(
            height: 100,
            margin: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              gradient: _getGradientForIndex(index),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Center(
              child: Text('Item $index'),
            ),
          );
        },
      ),
    ),
  );
}

Widget _buildRepeatedGradientWidget() {
  return MaterialApp(
    home: Scaffold(
      body: GridView.builder(
        gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: 3,
        ),
        itemCount: 30,
        itemBuilder: (context, index) {
          // Use the same gradient multiple times to test caching
          return Container(
            margin: const EdgeInsets.all(4),
            decoration: const BoxDecoration(
              gradient: AppColors.primaryGradient,
            ),
          );
        },
      ),
    ),
  );
}

Widget _buildAnimatedGradientWidget() {
  return MaterialApp(
    home: Scaffold(
      body: Center(
        child: _AnimatedGradientBox(),
      ),
    ),
  );
}

Widget _buildMixedGradientsWidget() {
  return MaterialApp(
    home: Scaffold(
      body: ListView.builder(
        itemCount: 50,
        itemBuilder: (context, index) {
          return Container(
            height: 80,
            margin: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              gradient: _getGradientForIndex(index),
              borderRadius: BorderRadius.circular(12),
            ),
          );
        },
      ),
    ),
  );
}

LinearGradient _getGradientForIndex(int index) {
  final gradients = [
    AppColors.primaryGradient,
    AppColors.secondaryGradient,
    AppColors.taskGradient,
    AppColors.noteGradient,
    AppColors.listGradient,
  ];

  return gradients[index % gradients.length];
}

class _AnimatedGradientBox extends StatefulWidget {
  @override
  State<_AnimatedGradientBox> createState() => _AnimatedGradientBoxState();
}

class _AnimatedGradientBoxState extends State<_AnimatedGradientBox>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: const Duration(seconds: 2),
      vsync: this,
    )..repeat(reverse: true);
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _controller,
      builder: (context, child) {
        return Container(
          width: 200,
          height: 200,
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [
                AppColors.primaryStart,
                Color.lerp(
                  AppColors.primaryEnd,
                  AppColors.secondaryEnd,
                  _controller.value,
                )!,
              ],
            ),
            borderRadius: BorderRadius.circular(16),
          ),
        );
      },
    );
  }
}
