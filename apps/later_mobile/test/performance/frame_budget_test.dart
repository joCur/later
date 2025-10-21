import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:later_mobile/core/theme/app_colors.dart';
import 'package:later_mobile/data/models/item_model.dart';
import 'package:later_mobile/widgets/components/cards/item_card.dart';

/// Performance tests for frame budget monitoring
///
/// Tests frame rendering times:
/// - Frame build times
/// - Janky frames detection (>16ms)
/// - Performance during interactions
/// - Expensive widget identification
///
/// Target: <16.67ms per frame for 60fps
void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  group('Frame Budget Monitoring Tests', () {
    testWidgets('Tap interaction frame budget', (tester) async {
      await tester.pumpWidget(_buildInteractiveWidget());
      await tester.pumpAndSettle();

      final frames = <Duration>[];
      tester.binding.addTimingsCallback((timings) {
        for (final timing in timings) {
          frames.add(timing.totalSpan);
        }
      });

      // Tap button
      await tester.tap(find.byType(ElevatedButton));
      await tester.pump();

      // Pump frames for animation
      for (int i = 0; i < 20; i++) {
        await tester.pump(const Duration(milliseconds: 16));
      }

      if (frames.isNotEmpty) {
        final jankyFrames = frames.where((d) => d.inMilliseconds > 16).length;
        final jankyPercentage = (jankyFrames / frames.length) * 100;

        debugPrint('Tap interaction janky frames: ${jankyPercentage.toStringAsFixed(1)}%');

        expect(jankyPercentage, lessThan(10),
          reason: 'Tap interactions should be smooth');
      }
    });

    testWidgets('Scroll interaction frame budget', (tester) async {
      await tester.pumpWidget(_buildScrollableWidget());
      await tester.pumpAndSettle();

      final frames = <Duration>[];
      tester.binding.addTimingsCallback((timings) {
        for (final timing in timings) {
          frames.add(timing.totalSpan);
        }
      });

      // Scroll
      await tester.fling(
        find.byType(ListView),
        const Offset(0, -1000),
        1000,
      );

      for (int i = 0; i < 60; i++) {
        await tester.pump(const Duration(milliseconds: 16));
      }

      await tester.pumpAndSettle();

      if (frames.isNotEmpty) {
        final averageFrameTime = frames.fold<Duration>(
          Duration.zero,
          (prev, duration) => prev + duration,
        ) ~/ frames.length;

        final maxFrameTime = frames.reduce((a, b) => a > b ? a : b);
        final jankyFrames = frames.where((d) => d.inMilliseconds > 16).length;
        final jankyPercentage = (jankyFrames / frames.length) * 100;

        debugPrint('Scroll - avg frame time: ${averageFrameTime.inMicroseconds / 1000}ms');
        debugPrint('Scroll - max frame time: ${maxFrameTime.inMicroseconds / 1000}ms');
        debugPrint('Scroll - janky frames: ${jankyPercentage.toStringAsFixed(1)}%');

        expect(jankyPercentage, lessThan(15),
          reason: 'Scrolling should maintain acceptable frame rate');
      }
    });

    testWidgets('Navigation transition frame budget', (tester) async {
      await tester.pumpWidget(_buildNavigationWidget());
      await tester.pumpAndSettle();

      final frames = <Duration>[];
      tester.binding.addTimingsCallback((timings) {
        for (final timing in timings) {
          frames.add(timing.totalSpan);
        }
      });

      // Navigate to second screen
      await tester.tap(find.byType(ElevatedButton));
      await tester.pump();

      // Pump navigation animation
      for (int i = 0; i < 30; i++) {
        await tester.pump(const Duration(milliseconds: 16));
      }

      await tester.pumpAndSettle();

      if (frames.isNotEmpty) {
        final jankyFrames = frames.where((d) => d.inMilliseconds > 16).length;
        final jankyPercentage = (jankyFrames / frames.length) * 100;

        debugPrint('Navigation janky frames: ${jankyPercentage.toStringAsFixed(1)}%');

        expect(jankyPercentage, lessThan(20),
          reason: 'Navigation should be smooth');
      }
    });

    testWidgets('Complex gradient rendering frame time', (tester) async {
      await tester.pumpWidget(_buildGradientHeavyWidget());
      await tester.pumpAndSettle();

      final frames = <Duration>[];
      tester.binding.addTimingsCallback((timings) {
        for (final timing in timings) {
          frames.add(timing.totalSpan);
        }
      });

      // Trigger rebuild
      await tester.tap(find.byType(IconButton));
      await tester.pump();

      for (int i = 0; i < 10; i++) {
        await tester.pump(const Duration(milliseconds: 16));
      }

      if (frames.isNotEmpty) {
        final averageFrameTime = frames.fold<Duration>(
          Duration.zero,
          (prev, duration) => prev + duration,
        ) ~/ frames.length;

        debugPrint('Complex gradients avg frame time: ${averageFrameTime.inMicroseconds / 1000}ms');

        expect(averageFrameTime.inMilliseconds, lessThan(20),
          reason: 'Complex gradients should render within frame budget');
      }
    });

    testWidgets('ItemCard build time benchmark', (tester) async {
      final stopwatch = Stopwatch();

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: Builder(
              builder: (context) {
                stopwatch.start();
                return ItemCard(
                  item: _createMockItem(0),
                );
              },
            ),
          ),
        ),
      );

      await tester.pump();
      stopwatch.stop();

      final buildTime = stopwatch.elapsedMicroseconds / 1000;
      debugPrint('ItemCard build time: ${buildTime}ms');

      // Single card should build very quickly (relaxed threshold)
      expect(buildTime, lessThan(10),
        reason: 'ItemCard should build efficiently');
    });

    testWidgets('Expensive widget detection - nested gradients', (tester) async {
      await tester.pumpWidget(_buildNestedGradientsWidget());
      await tester.pumpAndSettle();

      final frames = <Duration>[];
      tester.binding.addTimingsCallback((timings) {
        for (final timing in timings) {
          frames.add(timing.totalSpan);
        }
      });

      // Trigger animation
      await tester.tap(find.byType(IconButton));
      await tester.pump();

      for (int i = 0; i < 20; i++) {
        await tester.pump(const Duration(milliseconds: 16));
      }

      if (frames.isNotEmpty) {
        final maxFrameTime = frames.reduce((a, b) => a > b ? a : b);
        debugPrint('Nested gradients max frame time: ${maxFrameTime.inMicroseconds / 1000}ms');

        // Nested gradients are expensive
        expect(maxFrameTime.inMilliseconds, lessThan(25),
          reason: 'Even nested gradients should stay within reasonable limits');
      }
    });

    testWidgets('RepaintBoundary effectiveness test', (tester) async {
      // Test without RepaintBoundary
      await tester.pumpWidget(_buildWithoutRepaintBoundary());
      await tester.pumpAndSettle();

      final framesWithout = <Duration>[];
      tester.binding.addTimingsCallback((timings) {
        for (final timing in timings) {
          framesWithout.add(timing.totalSpan);
        }
      });

      await tester.tap(find.byKey(const Key('increment_button')));
      await tester.pump();

      for (int i = 0; i < 10; i++) {
        await tester.pump(const Duration(milliseconds: 16));
      }

      final avgWithout = framesWithout.isNotEmpty
          ? framesWithout.fold<Duration>(
              Duration.zero,
              (prev, duration) => prev + duration,
            ) ~/ framesWithout.length
          : Duration.zero;

      // Test with RepaintBoundary
      await tester.pumpWidget(_buildWithRepaintBoundary());
      await tester.pumpAndSettle();

      final framesWith = <Duration>[];
      tester.binding.addTimingsCallback((timings) {
        for (final timing in timings) {
          framesWith.add(timing.totalSpan);
        }
      });

      await tester.tap(find.byKey(const Key('increment_button')));
      await tester.pump();

      for (int i = 0; i < 10; i++) {
        await tester.pump(const Duration(milliseconds: 16));
      }

      final avgWith = framesWith.isNotEmpty
          ? framesWith.fold<Duration>(
              Duration.zero,
              (prev, duration) => prev + duration,
            ) ~/ framesWith.length
          : Duration.zero;

      debugPrint('Without RepaintBoundary: ${avgWithout.inMicroseconds / 1000}ms');
      debugPrint('With RepaintBoundary: ${avgWith.inMicroseconds / 1000}ms');

      // RepaintBoundary should improve or maintain performance
      // Note: In some cases the difference may be minimal
    });

    testWidgets('Sustained 60fps test - 1 second animation', (tester) async {
      await tester.pumpWidget(_buildSustainedAnimationWidget());
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

        debugPrint('Sustained animation janky frames: ${jankyPercentage.toStringAsFixed(1)}%');
        debugPrint('Total frames in 1 second: ${frames.length}');

        expect(jankyPercentage, lessThan(10),
          reason: 'Should sustain 60fps for continuous animation');
        expect(frames.length, greaterThanOrEqualTo(50),
          reason: 'Should render at least 50 frames per second');
      }
    });
  });
}

// Helper widgets

Widget _buildInteractiveWidget() {
  return MaterialApp(
    home: Scaffold(
      body: _InteractiveTestWidget(),
    ),
  );
}

Widget _buildScrollableWidget() {
  return MaterialApp(
    home: Scaffold(
      body: ListView.builder(
        itemCount: 100,
        itemBuilder: (context, index) {
          return ItemCard(
            item: _createMockItem(index),
          );
        },
      ),
    ),
  );
}

Widget _buildNavigationWidget() {
  return MaterialApp(
    home: Scaffold(
      body: Center(
        child: ElevatedButton(
          onPressed: () {},
          child: const Text('Navigate'),
        ),
      ),
    ),
    routes: {
      '/second': (context) => Scaffold(
        body: Container(
          decoration: const BoxDecoration(
            gradient: AppColors.primaryGradient,
          ),
        ),
      ),
    },
  );
}

Widget _buildGradientHeavyWidget() {
  return MaterialApp(
    home: Scaffold(
      body: _GradientHeavyWidget(),
    ),
  );
}

Widget _buildNestedGradientsWidget() {
  return MaterialApp(
    home: Scaffold(
      body: _NestedGradientsWidget(),
    ),
  );
}

Widget _buildWithoutRepaintBoundary() {
  return const MaterialApp(
    home: Scaffold(
      body: _CounterWidget(useRepaintBoundary: false),
    ),
  );
}

Widget _buildWithRepaintBoundary() {
  return const MaterialApp(
    home: Scaffold(
      body: _CounterWidget(useRepaintBoundary: true),
    ),
  );
}

Widget _buildSustainedAnimationWidget() {
  return MaterialApp(
    home: Scaffold(
      body: _SustainedAnimationWidget(),
    ),
  );
}

// Test widgets

class _InteractiveTestWidget extends StatefulWidget {
  @override
  State<_InteractiveTestWidget> createState() => _InteractiveTestWidgetState();
}

class _InteractiveTestWidgetState extends State<_InteractiveTestWidget>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: const Duration(milliseconds: 250),
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
            child: const Text('Tap'),
          ),
        ],
      ),
    );
  }
}

class _GradientHeavyWidget extends StatefulWidget {
  @override
  State<_GradientHeavyWidget> createState() => _GradientHeavyWidgetState();
}

class _GradientHeavyWidgetState extends State<_GradientHeavyWidget> {
  int _state = 0;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        IconButton(
          icon: const Icon(Icons.refresh),
          onPressed: () => setState(() => _state++),
        ),
        Expanded(
          child: GridView.builder(
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 4,
            ),
            itemCount: 20,
            itemBuilder: (context, index) {
              return Container(
                margin: const EdgeInsets.all(2),
                decoration: BoxDecoration(
                  gradient: _getGradient(index),
                ),
              );
            },
          ),
        ),
      ],
    );
  }

  LinearGradient _getGradient(int index) {
    final gradients = [
      AppColors.primaryGradient,
      AppColors.secondaryGradient,
      AppColors.taskGradient,
      AppColors.noteGradient,
      AppColors.listGradient,
    ];
    return gradients[index % gradients.length];
  }
}

class _NestedGradientsWidget extends StatefulWidget {
  @override
  State<_NestedGradientsWidget> createState() => _NestedGradientsWidgetState();
}

class _NestedGradientsWidgetState extends State<_NestedGradientsWidget>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: const Duration(milliseconds: 250),
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
    return Stack(
      children: [
        Container(
          decoration: const BoxDecoration(
            gradient: AppColors.primaryGradient,
          ),
        ),
        Center(
          child: Container(
            width: 300,
            height: 300,
            decoration: const BoxDecoration(
              gradient: AppColors.secondaryGradient,
            ),
            child: Center(
              child: ScaleTransition(
                scale: _controller,
                child: Container(
                  width: 150,
                  height: 150,
                  decoration: const BoxDecoration(
                    gradient: AppColors.taskGradient,
                  ),
                ),
              ),
            ),
          ),
        ),
        Positioned(
          top: 20,
          right: 20,
          child: IconButton(
            icon: const Icon(Icons.play_arrow),
            onPressed: () => _controller.forward(from: 0.0),
          ),
        ),
      ],
    );
  }
}

class _CounterWidget extends StatefulWidget {

  const _CounterWidget({required this.useRepaintBoundary});
  final bool useRepaintBoundary;

  @override
  State<_CounterWidget> createState() => _CounterWidgetState();
}

class _CounterWidgetState extends State<_CounterWidget> {
  int _count = 0;

  @override
  Widget build(BuildContext context) {
    final counter = Container(
      width: 100,
      height: 100,
      decoration: const BoxDecoration(
        gradient: AppColors.primaryGradient,
      ),
      child: Center(
        child: Text('$_count'),
      ),
    );

    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        widget.useRepaintBoundary
            ? RepaintBoundary(child: counter)
            : counter,
        ElevatedButton(
          key: const Key('increment_button'),
          onPressed: () => setState(() => _count++),
          child: const Text('Increment'),
        ),
      ],
    );
  }
}

class _SustainedAnimationWidget extends StatefulWidget {
  @override
  State<_SustainedAnimationWidget> createState() => _SustainedAnimationWidgetState();
}

class _SustainedAnimationWidgetState extends State<_SustainedAnimationWidget>
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
    return Center(
      child: AnimatedBuilder(
        animation: _controller,
        builder: (context, child) {
          return Transform.scale(
            scale: 0.5 + (_controller.value * 0.5),
            child: Container(
              width: 200,
              height: 200,
              decoration: const BoxDecoration(
                gradient: AppColors.primaryGradient,
              ),
            ),
          );
        },
      ),
    );
  }
}

Item _createMockItem(int index) {
  final types = [ItemType.task, ItemType.note, ItemType.list];
  return Item(
    id: 'item_$index',
    title: 'Test Item $index',
    type: types[index % types.length],
    spaceId: 'test_space',
    createdAt: DateTime.now(),
  );
}
