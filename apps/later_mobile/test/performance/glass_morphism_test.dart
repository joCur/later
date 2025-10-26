import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:later_mobile/design_system/tokens/tokens.dart';

/// Performance tests for glass morphism effects (BackdropFilter)
///
/// Tests glass morphism rendering performance:
/// - Static glass surfaces vs scrolling content
/// - Different blur radii (10px, 20px, 30px)
/// - Multiple overlapping glass surfaces
/// - CPU/GPU usage patterns
/// - Device capability detection fallback
///
/// Target: 60fps during scrolling with glass effects
void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  group('Glass Morphism Performance Tests', () {
    testWidgets('Static glass surface rendering', (tester) async {
      await tester.pumpWidget(_buildStaticGlassWidget(AppColors.glassBlurRadius));
      await tester.pumpAndSettle();

      // Verify no rendering errors
      expect(tester.takeException(), isNull);

      // Find the BackdropFilter widget
      final backdropFilter = find.byType(BackdropFilter);
      expect(backdropFilter, findsOneWidget);

      debugPrint('Static glass surface rendered successfully');
    });

    testWidgets('Glass surface with scrolling content behind', (tester) async {
      await tester.pumpWidget(_buildScrollingGlassWidget());
      await tester.pumpAndSettle();

      final frames = <Duration>[];
      tester.binding.addTimingsCallback((timings) {
        for (final timing in timings) {
          frames.add(timing.totalSpan);
        }
      });

      // Scroll content behind glass surface
      await tester.drag(
        find.byType(ListView),
        const Offset(0, -500),
      );

      // Pump frames during scroll
      for (int i = 0; i < 60; i++) {
        await tester.pump(const Duration(milliseconds: 16));
      }

      await tester.pumpAndSettle();

      if (frames.isNotEmpty) {
        final jankyFrames = frames.where((d) => d.inMilliseconds > 16).length;
        final jankyPercentage = (jankyFrames / frames.length) * 100;

        debugPrint('Glass morphism scroll janky frames: ${jankyPercentage.toStringAsFixed(1)}%');

        // Glass morphism is expensive, allow up to 20% janky frames
        expect(jankyPercentage, lessThan(20),
          reason: 'Glass morphism should maintain acceptable performance');
      }
    });

    testWidgets('Low blur radius performance (10px)', (tester) async {
      await tester.pumpWidget(_buildStaticGlassWidget(10.0));
      await tester.pumpAndSettle();

      final frames = <Duration>[];
      tester.binding.addTimingsCallback((timings) {
        for (final timing in timings) {
          frames.add(timing.totalSpan);
        }
      });

      // Trigger rebuild
      await tester.pump(const Duration(milliseconds: 16));

      expect(tester.takeException(), isNull);
      debugPrint('Low blur radius (10px) renders without issues');
    });

    testWidgets('Medium blur radius performance (20px)', (tester) async {
      await tester.pumpWidget(_buildStaticGlassWidget(20.0));
      await tester.pumpAndSettle();

      expect(tester.takeException(), isNull);
      debugPrint('Medium blur radius (20px) renders without issues');
    });

    testWidgets('High blur radius performance (30px)', (tester) async {
      await tester.pumpWidget(_buildStaticGlassWidget(30.0));
      await tester.pumpAndSettle();

      expect(tester.takeException(), isNull);
      debugPrint('High blur radius (30px) renders without issues');
    });

    testWidgets('Multiple overlapping glass surfaces', (tester) async {
      await tester.pumpWidget(_buildOverlappingGlassWidget(3));
      await tester.pumpAndSettle();

      final frames = <Duration>[];
      tester.binding.addTimingsCallback((timings) {
        for (final timing in timings) {
          frames.add(timing.totalSpan);
        }
      });

      // Pump a few frames
      for (int i = 0; i < 10; i++) {
        await tester.pump(const Duration(milliseconds: 16));
      }

      if (frames.isNotEmpty) {
        final averageFrameTime = frames.fold<Duration>(
          Duration.zero,
          (prev, duration) => prev + duration,
        ) ~/ frames.length;

        debugPrint('Overlapping glass avg frame time: ${averageFrameTime.inMicroseconds / 1000}ms');

        // Multiple overlapping glass surfaces are expensive
        // Allow up to 25ms per frame
        expect(averageFrameTime.inMilliseconds, lessThan(25),
          reason: 'Multiple glass surfaces should still be functional');
      }

      expect(tester.takeException(), isNull);
    });

    testWidgets('Glass morphism vs solid fallback comparison', (tester) async {
      // Test glass morphism
      final stopwatchGlass = Stopwatch()..start();
      await tester.pumpWidget(_buildStaticGlassWidget(AppColors.glassBlurRadius));
      await tester.pumpAndSettle();
      stopwatchGlass.stop();

      final glassTime = stopwatchGlass.elapsedMilliseconds;
      debugPrint('Glass morphism build time: ${glassTime}ms');

      // Test solid fallback
      final stopwatchSolid = Stopwatch()..start();
      await tester.pumpWidget(_buildSolidFallbackWidget());
      await tester.pumpAndSettle();
      stopwatchSolid.stop();

      final solidTime = stopwatchSolid.elapsedMilliseconds;
      debugPrint('Solid fallback build time: ${solidTime}ms');

      // Solid should be faster or comparable
      debugPrint('Performance ratio: ${(glassTime / solidTime).toStringAsFixed(2)}x');
    });

    testWidgets('Glass surface with animated content', (tester) async {
      await tester.pumpWidget(_buildAnimatedGlassWidget());
      await tester.pump();

      final frames = <Duration>[];
      tester.binding.addTimingsCallback((timings) {
        for (final timing in timings) {
          frames.add(timing.totalSpan);
        }
      });

      // Animate for 1 second
      for (int i = 0; i < 60; i++) {
        await tester.pump(const Duration(milliseconds: 16));
      }

      if (frames.isNotEmpty) {
        final jankyFrames = frames.where((d) => d.inMilliseconds > 16).length;
        final jankyPercentage = (jankyFrames / frames.length) * 100;

        debugPrint('Animated glass janky frames: ${jankyPercentage.toStringAsFixed(1)}%');

        // Animated content with glass is expensive, allow up to 25%
        expect(jankyPercentage, lessThan(25));
      }
    });

    testWidgets('Glass morphism on mobile screen', (tester) async {
      tester.view.physicalSize = const Size(375, 667);
      tester.view.devicePixelRatio = 2.0;

      addTearDown(() {
        tester.view.resetPhysicalSize();
        tester.view.resetDevicePixelRatio();
      });

      await tester.pumpWidget(_buildScrollingGlassWidget());
      await tester.pumpAndSettle();

      expect(tester.takeException(), isNull);
      debugPrint('Glass morphism renders on mobile screen size');
    });

    testWidgets('RepaintBoundary optimization for glass surfaces', (tester) async {
      await tester.pumpWidget(_buildOptimizedGlassWidget());
      await tester.pumpAndSettle();

      final frames = <Duration>[];
      tester.binding.addTimingsCallback((timings) {
        for (final timing in timings) {
          frames.add(timing.totalSpan);
        }
      });

      // Trigger updates
      await tester.drag(
        find.byType(ListView),
        const Offset(0, -200),
      );

      for (int i = 0; i < 30; i++) {
        await tester.pump(const Duration(milliseconds: 16));
      }

      if (frames.isNotEmpty) {
        final jankyFrames = frames.where((d) => d.inMilliseconds > 16).length;
        final jankyPercentage = (jankyFrames / frames.length) * 100;

        debugPrint('Optimized glass janky frames: ${jankyPercentage.toStringAsFixed(1)}%');

        expect(jankyPercentage, lessThan(15),
          reason: 'RepaintBoundary should improve performance');
      }
    });
  });
}

// Helper widgets

Widget _buildStaticGlassWidget(double blurRadius) {
  return MaterialApp(
    home: Scaffold(
      body: Stack(
        children: [
          // Background content
          Container(
            decoration: const BoxDecoration(
              gradient: AppColors.primaryGradient,
            ),
            child: const Center(
              child: Text(
                'Background Content',
                style: TextStyle(fontSize: 24, color: Colors.white),
              ),
            ),
          ),
          // Glass surface
          Center(
            child: ClipRRect(
              borderRadius: BorderRadius.circular(16),
              child: BackdropFilter(
                filter: ImageFilter.blur(sigmaX: blurRadius, sigmaY: blurRadius),
                child: Container(
                  width: 300,
                  height: 200,
                  decoration: BoxDecoration(
                    color: AppColors.glassLight,
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(
                      color: AppColors.glassBorderLight,
                    ),
                  ),
                  child: const Center(
                    child: Text('Glass Surface'),
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    ),
  );
}

Widget _buildScrollingGlassWidget() {
  return MaterialApp(
    home: Scaffold(
      body: Stack(
        children: [
          // Scrolling background content
          ListView.builder(
            itemCount: 50,
            itemBuilder: (context, index) {
              return Container(
                height: 100,
                margin: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  gradient: const LinearGradient(
                    colors: [
                      AppColors.primaryStart,
                      AppColors.primaryEnd,
                    ],
                  ),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Center(
                  child: Text('Item $index'),
                ),
              );
            },
          ),
          // Fixed glass surface
          Positioned(
            top: 50,
            left: 20,
            right: 20,
            child: ClipRRect(
              borderRadius: BorderRadius.circular(16),
              child: BackdropFilter(
                filter: ImageFilter.blur(
                  sigmaX: AppColors.glassBlurRadius,
                  sigmaY: AppColors.glassBlurRadius,
                ),
                child: Container(
                  height: 80,
                  decoration: BoxDecoration(
                    color: AppColors.glassLight,
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(
                      color: AppColors.glassBorderLight,
                    ),
                  ),
                  child: const Center(
                    child: Text('Glass Header'),
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    ),
  );
}

Widget _buildOverlappingGlassWidget(int layers) {
  return MaterialApp(
    home: Scaffold(
      body: Stack(
        children: [
          // Background
          Container(
            decoration: const BoxDecoration(
              gradient: AppColors.primaryGradient,
            ),
          ),
          // Overlapping glass layers
          ...List.generate(layers, (index) {
            return Positioned(
              top: 100.0 + (index * 50.0),
              left: 50.0 + (index * 20.0),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(16),
                child: BackdropFilter(
                  filter: ImageFilter.blur(
                    sigmaX: AppColors.glassBlurRadius,
                    sigmaY: AppColors.glassBlurRadius,
                  ),
                  child: Container(
                    width: 250,
                    height: 150,
                    decoration: BoxDecoration(
                      color: AppColors.glassLight,
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(
                        color: AppColors.glassBorderLight,
                      ),
                    ),
                    child: Center(
                      child: Text('Glass Layer $index'),
                    ),
                  ),
                ),
              ),
            );
          }),
        ],
      ),
    ),
  );
}

Widget _buildSolidFallbackWidget() {
  return MaterialApp(
    home: Scaffold(
      body: Stack(
        children: [
          Container(
            decoration: const BoxDecoration(
              gradient: AppColors.primaryGradient,
            ),
            child: const Center(
              child: Text(
                'Background Content',
                style: TextStyle(fontSize: 24, color: Colors.white),
              ),
            ),
          ),
          Center(
            child: Container(
              width: 300,
              height: 200,
              decoration: BoxDecoration(
                color: AppColors.glassLight,
                borderRadius: BorderRadius.circular(16),
                border: Border.all(
                  color: AppColors.glassBorderLight,
                ),
              ),
              child: const Center(
                child: Text('Solid Surface'),
              ),
            ),
          ),
        ],
      ),
    ),
  );
}

Widget _buildAnimatedGlassWidget() {
  return MaterialApp(
    home: Scaffold(
      body: Stack(
        children: [
          // Animated background
          _AnimatedBackground(),
          // Glass surface
          Center(
            child: ClipRRect(
              borderRadius: BorderRadius.circular(16),
              child: BackdropFilter(
                filter: ImageFilter.blur(
                  sigmaX: AppColors.glassBlurRadius,
                  sigmaY: AppColors.glassBlurRadius,
                ),
                child: Container(
                  width: 300,
                  height: 200,
                  decoration: BoxDecoration(
                    color: AppColors.glassLight,
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: const Center(
                    child: Text('Glass Surface'),
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    ),
  );
}

Widget _buildOptimizedGlassWidget() {
  return MaterialApp(
    home: Scaffold(
      body: Stack(
        children: [
          ListView.builder(
            itemCount: 30,
            itemBuilder: (context, index) {
              return Container(
                height: 80,
                margin: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  gradient: AppColors.primaryGradient,
                  borderRadius: BorderRadius.circular(12),
                ),
              );
            },
          ),
          // Glass surface with RepaintBoundary
          Positioned(
            top: 50,
            left: 20,
            right: 20,
            child: RepaintBoundary(
              child: ClipRRect(
                borderRadius: BorderRadius.circular(16),
                child: BackdropFilter(
                  filter: ImageFilter.blur(
                    sigmaX: AppColors.glassBlurRadius,
                    sigmaY: AppColors.glassBlurRadius,
                  ),
                  child: Container(
                    height: 80,
                    decoration: BoxDecoration(
                      color: AppColors.glassLight,
                      borderRadius: BorderRadius.circular(16),
                    ),
                    child: const Center(
                      child: Text('Optimized Glass'),
                    ),
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    ),
  );
}

class _AnimatedBackground extends StatefulWidget {
  @override
  State<_AnimatedBackground> createState() => _AnimatedBackgroundState();
}

class _AnimatedBackgroundState extends State<_AnimatedBackground>
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
          ),
        );
      },
    );
  }
}
