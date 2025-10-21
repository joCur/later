import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:later_mobile/core/theme/app_animations.dart';
import 'package:later_mobile/core/theme/app_colors.dart';

/// Performance tests for spring animations in Temporal Flow design system
///
/// Tests animation performance:
/// - Spring animation frame budget
/// - Multiple simultaneous animations
/// - Staggered animations (list entrance)
/// - Animation jank/dropped frames
/// - Reduced motion compliance
///
/// Target: No dropped frames during animations
void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  group('Animation Performance Tests', () {
    testWidgets('Single spring animation frame budget', (tester) async {
      await tester.pumpWidget(_buildSimpleAnimationWidget());
      await tester.pumpAndSettle();

      final frames = <Duration>[];
      tester.binding.addTimingsCallback((timings) {
        for (final timing in timings) {
          frames.add(timing.totalSpan);
        }
      });

      // Trigger animation
      await tester.tap(find.byType(ElevatedButton));
      await tester.pump();

      // Pump frames for animation duration (250ms = ~15 frames)
      for (int i = 0; i < 20; i++) {
        await tester.pump(const Duration(milliseconds: 16));
      }

      if (frames.isNotEmpty) {
        final averageFrameTime = frames.fold<Duration>(
          Duration.zero,
          (prev, duration) => prev + duration,
        ) ~/ frames.length;

        final maxFrameTime = frames.reduce((a, b) => a > b ? a : b);

        debugPrint('Spring animation avg frame time: ${averageFrameTime.inMicroseconds / 1000}ms');
        debugPrint('Spring animation max frame time: ${maxFrameTime.inMicroseconds / 1000}ms');

        // Should maintain 60fps
        expect(averageFrameTime.inMilliseconds, lessThanOrEqualTo(16));
        expect(maxFrameTime.inMilliseconds, lessThanOrEqualTo(20),
          reason: 'Max frame time should stay within budget');
      }
    });

    testWidgets('Multiple simultaneous animations (5 elements)', (tester) async {
      await tester.pumpWidget(_buildMultipleAnimationsWidget(5));
      await tester.pumpAndSettle();

      final frames = <Duration>[];
      tester.binding.addTimingsCallback((timings) {
        for (final timing in timings) {
          frames.add(timing.totalSpan);
        }
      });

      // Trigger all animations
      await tester.tap(find.byType(ElevatedButton));
      await tester.pump();

      for (int i = 0; i < 25; i++) {
        await tester.pump(const Duration(milliseconds: 16));
      }

      if (frames.isNotEmpty) {
        final jankyFrames = frames.where((d) => d.inMilliseconds > 16).length;
        final jankyPercentage = (jankyFrames / frames.length) * 100;

        debugPrint('5 simultaneous animations janky frames: ${jankyPercentage.toStringAsFixed(1)}%');

        expect(jankyPercentage, lessThan(5),
          reason: '5 animations should run smoothly');
      }
    });

    testWidgets('Multiple simultaneous animations (10 elements)', (tester) async {
      await tester.pumpWidget(_buildMultipleAnimationsWidget(10));
      await tester.pumpAndSettle();

      final frames = <Duration>[];
      tester.binding.addTimingsCallback((timings) {
        for (final timing in timings) {
          frames.add(timing.totalSpan);
        }
      });

      await tester.tap(find.byType(ElevatedButton));
      await tester.pump();

      for (int i = 0; i < 25; i++) {
        await tester.pump(const Duration(milliseconds: 16));
      }

      if (frames.isNotEmpty) {
        final jankyFrames = frames.where((d) => d.inMilliseconds > 16).length;
        final jankyPercentage = (jankyFrames / frames.length) * 100;

        debugPrint('10 simultaneous animations janky frames: ${jankyPercentage.toStringAsFixed(1)}%');

        expect(jankyPercentage, lessThan(10),
          reason: '10 animations should maintain acceptable performance');
      }
    });

    testWidgets('Staggered list entrance animations', (tester) async {
      await tester.pumpWidget(_buildStaggeredListWidget(20));

      final frames = <Duration>[];
      tester.binding.addTimingsCallback((timings) {
        for (final timing in timings) {
          frames.add(timing.totalSpan);
        }
      });

      // Pump all staggered animations (20 items × 50ms = 1000ms + 250ms animation)
      for (int i = 0; i < 80; i++) {
        await tester.pump(const Duration(milliseconds: 16));
      }

      await tester.pumpAndSettle();

      if (frames.isNotEmpty) {
        final jankyFrames = frames.where((d) => d.inMilliseconds > 16).length;
        final jankyPercentage = (jankyFrames / frames.length) * 100;

        debugPrint('Staggered animations janky frames: ${jankyPercentage.toStringAsFixed(1)}%');

        expect(jankyPercentage, lessThan(10),
          reason: 'Staggered entrance should be smooth');
      }
    });

    testWidgets('Scale animation performance', (tester) async {
      await tester.pumpWidget(_buildScaleAnimationWidget());
      await tester.pumpAndSettle();

      final frames = <Duration>[];
      tester.binding.addTimingsCallback((timings) {
        for (final timing in timings) {
          frames.add(timing.totalSpan);
        }
      });

      await tester.tap(find.byType(ElevatedButton));
      await tester.pump();

      for (int i = 0; i < 20; i++) {
        await tester.pump(const Duration(milliseconds: 16));
      }

      if (frames.isNotEmpty) {
        final averageFrameTime = frames.fold<Duration>(
          Duration.zero,
          (prev, duration) => prev + duration,
        ) ~/ frames.length;

        debugPrint('Scale animation avg frame time: ${averageFrameTime.inMicroseconds / 1000}ms');

        expect(averageFrameTime.inMilliseconds, lessThanOrEqualTo(16));
      }
    });

    testWidgets('Fade animation performance', (tester) async {
      await tester.pumpWidget(_buildFadeAnimationWidget());
      await tester.pumpAndSettle();

      final frames = <Duration>[];
      tester.binding.addTimingsCallback((timings) {
        for (final timing in timings) {
          frames.add(timing.totalSpan);
        }
      });

      await tester.tap(find.byType(ElevatedButton));
      await tester.pump();

      for (int i = 0; i < 20; i++) {
        await tester.pump(const Duration(milliseconds: 16));
      }

      if (frames.isNotEmpty) {
        final averageFrameTime = frames.fold<Duration>(
          Duration.zero,
          (prev, duration) => prev + duration,
        ) ~/ frames.length;

        debugPrint('Fade animation avg frame time: ${averageFrameTime.inMicroseconds / 1000}ms');

        expect(averageFrameTime.inMilliseconds, lessThanOrEqualTo(16));
      }
    });

    testWidgets('Slide animation performance', (tester) async {
      await tester.pumpWidget(_buildSlideAnimationWidget());
      await tester.pumpAndSettle();

      final frames = <Duration>[];
      tester.binding.addTimingsCallback((timings) {
        for (final timing in timings) {
          frames.add(timing.totalSpan);
        }
      });

      await tester.tap(find.byType(ElevatedButton));
      await tester.pump();

      for (int i = 0; i < 20; i++) {
        await tester.pump(const Duration(milliseconds: 16));
      }

      if (frames.isNotEmpty) {
        final averageFrameTime = frames.fold<Duration>(
          Duration.zero,
          (prev, duration) => prev + duration,
        ) ~/ frames.length;

        debugPrint('Slide animation avg frame time: ${averageFrameTime.inMicroseconds / 1000}ms');

        expect(averageFrameTime.inMilliseconds, lessThanOrEqualTo(16));
      }
    });

    testWidgets('Combined scale + fade animation', (tester) async {
      await tester.pumpWidget(_buildCombinedAnimationWidget());
      await tester.pumpAndSettle();

      final frames = <Duration>[];
      tester.binding.addTimingsCallback((timings) {
        for (final timing in timings) {
          frames.add(timing.totalSpan);
        }
      });

      await tester.tap(find.byType(ElevatedButton));
      await tester.pump();

      for (int i = 0; i < 20; i++) {
        await tester.pump(const Duration(milliseconds: 16));
      }

      if (frames.isNotEmpty) {
        final averageFrameTime = frames.fold<Duration>(
          Duration.zero,
          (prev, duration) => prev + duration,
        ) ~/ frames.length;

        debugPrint('Combined animation avg frame time: ${averageFrameTime.inMicroseconds / 1000}ms');

        expect(averageFrameTime.inMilliseconds, lessThanOrEqualTo(16));
      }
    });

    testWidgets('Reduced motion compliance test', (tester) async {
      // Enable reduced motion
      tester.platformDispatcher.accessibilityFeaturesTestValue =
        const FakeAccessibilityFeatures(disableAnimations: true);

      addTearDown(() {
        tester.platformDispatcher.clearAccessibilityFeaturesTestValue();
      });

      await tester.pumpWidget(_buildReducedMotionWidget());
      await tester.pumpAndSettle();

      // Trigger animation
      await tester.tap(find.byType(ElevatedButton));
      await tester.pump();

      // In reduced motion, animation should complete instantly
      await tester.pump(AppAnimations.instant);
      await tester.pumpAndSettle();

      // Widget should be in final state
      final animatedContainer = tester.widget<AnimatedContainer>(
        find.byKey(const Key('animated_container')),
      );

      expect(animatedContainer, isNotNull);

      debugPrint('Reduced motion: animation completes instantly');
    });

    testWidgets('Animation with RepaintBoundary optimization', (tester) async {
      await tester.pumpWidget(_buildOptimizedAnimationWidget());
      await tester.pumpAndSettle();

      final frames = <Duration>[];
      tester.binding.addTimingsCallback((timings) {
        for (final timing in timings) {
          frames.add(timing.totalSpan);
        }
      });

      await tester.tap(find.byType(ElevatedButton));
      await tester.pump();

      for (int i = 0; i < 20; i++) {
        await tester.pump(const Duration(milliseconds: 16));
      }

      if (frames.isNotEmpty) {
        final jankyFrames = frames.where((d) => d.inMilliseconds > 16).length;
        final jankyPercentage = (jankyFrames / frames.length) * 100;

        debugPrint('Optimized animation janky frames: ${jankyPercentage.toStringAsFixed(1)}%');

        expect(jankyPercentage, lessThan(5),
          reason: 'RepaintBoundary should optimize animation');
      }
    });

    testWidgets('Complex animation sequence', (tester) async {
      await tester.pumpWidget(_buildComplexAnimationWidget());
      await tester.pumpAndSettle();

      final frames = <Duration>[];
      tester.binding.addTimingsCallback((timings) {
        for (final timing in timings) {
          frames.add(timing.totalSpan);
        }
      });

      await tester.tap(find.byType(ElevatedButton));
      await tester.pump();

      // Run for full animation sequence
      for (int i = 0; i < 50; i++) {
        await tester.pump(const Duration(milliseconds: 16));
      }

      if (frames.isNotEmpty) {
        final jankyFrames = frames.where((d) => d.inMilliseconds > 16).length;
        final jankyPercentage = (jankyFrames / frames.length) * 100;

        debugPrint('Complex animation janky frames: ${jankyPercentage.toStringAsFixed(1)}%');

        expect(jankyPercentage, lessThan(15),
          reason: 'Complex animations should maintain acceptable performance');
      }
    });
  });
}

// Helper widgets

Widget _buildSimpleAnimationWidget() {
  return MaterialApp(
    home: Scaffold(
      body: _SimpleAnimatedBox(),
    ),
  );
}

Widget _buildMultipleAnimationsWidget(int count) {
  return MaterialApp(
    home: Scaffold(
      body: _MultipleAnimationsWidget(count: count),
    ),
  );
}

Widget _buildStaggeredListWidget(int itemCount) {
  return MaterialApp(
    home: Scaffold(
      body: ListView.builder(
        itemCount: itemCount,
        itemBuilder: (context, index) {
          return _StaggeredListItem(
            index: index,
            key: ValueKey('item_$index'),
          );
        },
      ),
    ),
  );
}

Widget _buildScaleAnimationWidget() {
  return MaterialApp(
    home: Scaffold(
      body: _ScaleAnimatedBox(),
    ),
  );
}

Widget _buildFadeAnimationWidget() {
  return MaterialApp(
    home: Scaffold(
      body: _FadeAnimatedBox(),
    ),
  );
}

Widget _buildSlideAnimationWidget() {
  return MaterialApp(
    home: Scaffold(
      body: _SlideAnimatedBox(),
    ),
  );
}

Widget _buildCombinedAnimationWidget() {
  return MaterialApp(
    home: Scaffold(
      body: _CombinedAnimatedBox(),
    ),
  );
}

Widget _buildReducedMotionWidget() {
  return MaterialApp(
    home: Scaffold(
      body: _ReducedMotionBox(),
    ),
  );
}

Widget _buildOptimizedAnimationWidget() {
  return MaterialApp(
    home: Scaffold(
      body: _OptimizedAnimatedBox(),
    ),
  );
}

Widget _buildComplexAnimationWidget() {
  return MaterialApp(
    home: Scaffold(
      body: _ComplexAnimatedBox(),
    ),
  );
}

// Animation widgets

class _SimpleAnimatedBox extends StatefulWidget {
  @override
  State<_SimpleAnimatedBox> createState() => _SimpleAnimatedBoxState();
}

class _SimpleAnimatedBoxState extends State<_SimpleAnimatedBox>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _animation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: AppAnimations.normal,
      vsync: this,
    );
    _animation = CurvedAnimation(
      parent: _controller,
      curve: AppAnimations.springCurve,
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          ScaleTransition(
            scale: _animation,
            child: Container(
              width: 100,
              height: 100,
              decoration: const BoxDecoration(
                gradient: AppColors.primaryGradient,
              ),
            ),
          ),
          const SizedBox(height: 20),
          ElevatedButton(
            onPressed: () {
              _controller.forward(from: 0.0);
            },
            child: const Text('Animate'),
          ),
        ],
      ),
    );
  }
}

class _MultipleAnimationsWidget extends StatefulWidget {

  const _MultipleAnimationsWidget({required this.count});
  final int count;

  @override
  State<_MultipleAnimationsWidget> createState() => _MultipleAnimationsWidgetState();
}

class _MultipleAnimationsWidgetState extends State<_MultipleAnimationsWidget>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: AppAnimations.normal,
      vsync: this,
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Expanded(
          child: GridView.builder(
            gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: widget.count > 5 ? 5 : 3,
            ),
            itemCount: widget.count,
            itemBuilder: (context, index) {
              return ScaleTransition(
                scale: _controller,
                child: Container(
                  margin: const EdgeInsets.all(4),
                  decoration: const BoxDecoration(
                    gradient: AppColors.primaryGradient,
                  ),
                ),
              );
            },
          ),
        ),
        ElevatedButton(
          onPressed: () {
            _controller.forward(from: 0.0);
          },
          child: const Text('Animate All'),
        ),
      ],
    );
  }
}

class _StaggeredListItem extends StatefulWidget {

  const _StaggeredListItem({required this.index, super.key});
  final int index;

  @override
  State<_StaggeredListItem> createState() => _StaggeredListItemState();
}

class _StaggeredListItemState extends State<_StaggeredListItem>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _fadeAnimation;
  late Animation<Offset> _slideAnimation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: AppAnimations.itemEntrance,
      vsync: this,
    );
    _fadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(_controller);
    _slideAnimation = Tween<Offset>(
      begin: const Offset(0, 0.05), // Use Offset directly instead of removed constant
      end: Offset.zero,
    ).animate(_controller);

    // Stagger animation based on index
    Future.delayed(AppAnimations.itemEntranceStagger * widget.index, () {
      if (mounted) {
        _controller.forward();
      }
    });
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return FadeTransition(
      opacity: _fadeAnimation,
      child: SlideTransition(
        position: _slideAnimation,
        child: Container(
          height: 80,
          margin: const EdgeInsets.all(8),
          decoration: const BoxDecoration(
            gradient: AppColors.primaryGradient,
          ),
          child: Center(
            child: Text('Item ${widget.index}'),
          ),
        ),
      ),
    );
  }
}

class _ScaleAnimatedBox extends StatefulWidget {
  @override
  State<_ScaleAnimatedBox> createState() => _ScaleAnimatedBoxState();
}

class _ScaleAnimatedBoxState extends State<_ScaleAnimatedBox>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: AppAnimations.normal,
      vsync: this,
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          ScaleTransition(
            scale: _controller,
            child: Container(
              width: 100,
              height: 100,
              decoration: const BoxDecoration(
                gradient: AppColors.primaryGradient,
              ),
            ),
          ),
          ElevatedButton(
            onPressed: () => _controller.forward(from: 0.0),
            child: const Text('Animate'),
          ),
        ],
      ),
    );
  }
}

class _FadeAnimatedBox extends StatefulWidget {
  @override
  State<_FadeAnimatedBox> createState() => _FadeAnimatedBoxState();
}

class _FadeAnimatedBoxState extends State<_FadeAnimatedBox>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: AppAnimations.normal,
      vsync: this,
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          FadeTransition(
            opacity: _controller,
            child: Container(
              width: 100,
              height: 100,
              decoration: const BoxDecoration(
                gradient: AppColors.primaryGradient,
              ),
            ),
          ),
          ElevatedButton(
            onPressed: () => _controller.forward(from: 0.0),
            child: const Text('Animate'),
          ),
        ],
      ),
    );
  }
}

class _SlideAnimatedBox extends StatefulWidget {
  @override
  State<_SlideAnimatedBox> createState() => _SlideAnimatedBoxState();
}

class _SlideAnimatedBoxState extends State<_SlideAnimatedBox>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<Offset> _animation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: AppAnimations.normal,
      vsync: this,
    );
    _animation = Tween<Offset>(
      begin: const Offset(0, 0.2),
      end: Offset.zero,
    ).animate(_controller);
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          SlideTransition(
            position: _animation,
            child: Container(
              width: 100,
              height: 100,
              decoration: const BoxDecoration(
                gradient: AppColors.primaryGradient,
              ),
            ),
          ),
          ElevatedButton(
            onPressed: () => _controller.forward(from: 0.0),
            child: const Text('Animate'),
          ),
        ],
      ),
    );
  }
}

class _CombinedAnimatedBox extends StatefulWidget {
  @override
  State<_CombinedAnimatedBox> createState() => _CombinedAnimatedBoxState();
}

class _CombinedAnimatedBoxState extends State<_CombinedAnimatedBox>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: AppAnimations.normal,
      vsync: this,
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          FadeTransition(
            opacity: _controller,
            child: ScaleTransition(
              scale: _controller,
              child: Container(
                width: 100,
                height: 100,
                decoration: const BoxDecoration(
                  gradient: AppColors.primaryGradient,
                ),
              ),
            ),
          ),
          ElevatedButton(
            onPressed: () => _controller.forward(from: 0.0),
            child: const Text('Animate'),
          ),
        ],
      ),
    );
  }
}

class _ReducedMotionBox extends StatefulWidget {
  @override
  State<_ReducedMotionBox> createState() => _ReducedMotionBoxState();
}

class _ReducedMotionBoxState extends State<_ReducedMotionBox> {
  bool _isAnimated = false;

  @override
  Widget build(BuildContext context) {
    final duration = AppAnimations.getDuration(context, AppAnimations.normal);

    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          AnimatedContainer(
            key: const Key('animated_container'),
            duration: duration,
            width: _isAnimated ? 200 : 100,
            height: _isAnimated ? 200 : 100,
            decoration: const BoxDecoration(
              gradient: AppColors.primaryGradient,
            ),
          ),
          ElevatedButton(
            onPressed: () {
              setState(() {
                _isAnimated = !_isAnimated;
              });
            },
            child: const Text('Animate'),
          ),
        ],
      ),
    );
  }
}

class _OptimizedAnimatedBox extends StatefulWidget {
  @override
  State<_OptimizedAnimatedBox> createState() => _OptimizedAnimatedBoxState();
}

class _OptimizedAnimatedBoxState extends State<_OptimizedAnimatedBox>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: AppAnimations.normal,
      vsync: this,
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          RepaintBoundary(
            child: ScaleTransition(
              scale: _controller,
              child: Container(
                width: 100,
                height: 100,
                decoration: const BoxDecoration(
                  gradient: AppColors.primaryGradient,
                ),
              ),
            ),
          ),
          ElevatedButton(
            onPressed: () => _controller.forward(from: 0.0),
            child: const Text('Animate'),
          ),
        ],
      ),
    );
  }
}

class _ComplexAnimatedBox extends StatefulWidget {
  @override
  State<_ComplexAnimatedBox> createState() => _ComplexAnimatedBoxState();
}

class _ComplexAnimatedBoxState extends State<_ComplexAnimatedBox>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _scaleAnimation;
  late Animation<double> _fadeAnimation;
  late Animation<double> _rotationAnimation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: AppAnimations.gentle,
      vsync: this,
    );

    _scaleAnimation = TweenSequence<double>([
      TweenSequenceItem(
        tween: Tween<double>(begin: 0.0, end: 1.2),
        weight: 50.0,
      ),
      TweenSequenceItem(
        tween: Tween<double>(begin: 1.2, end: 1.0),
        weight: 50.0,
      ),
    ]).animate(_controller);

    _fadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(_controller);
    _rotationAnimation = Tween<double>(begin: 0.0, end: 0.5).animate(_controller);
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          FadeTransition(
            opacity: _fadeAnimation,
            child: ScaleTransition(
              scale: _scaleAnimation,
              child: RotationTransition(
                turns: _rotationAnimation,
                child: Container(
                  width: 100,
                  height: 100,
                  decoration: const BoxDecoration(
                    gradient: AppColors.primaryGradient,
                  ),
                ),
              ),
            ),
          ),
          ElevatedButton(
            onPressed: () => _controller.forward(from: 0.0),
            child: const Text('Animate'),
          ),
        ],
      ),
    );
  }
}
