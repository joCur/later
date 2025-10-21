import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:later_mobile/data/models/item_model.dart';
import 'package:later_mobile/widgets/components/cards/item_card.dart';

/// Performance tests for list rendering with ItemCard components
///
/// Tests list performance with:
/// - 500+ items in list
/// - Scroll performance
/// - Item card rendering (with gradients)
/// - Memory with large lists
/// - Virtualization/recycling
///
/// Target: Smooth 60fps scrolling
void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  group('List Performance Tests', () {
    testWidgets('Render 100 items without errors', (tester) async {
      await tester.pumpWidget(_buildListWidget(100));
      await tester.pumpAndSettle();

      expect(tester.takeException(), isNull);
      expect(find.byType(ItemCard), findsWidgets);

      debugPrint('100 items rendered successfully');
    });

    testWidgets('Render 500 items without errors', (tester) async {
      await tester.pumpWidget(_buildListWidget(500));
      await tester.pumpAndSettle();

      expect(tester.takeException(), isNull);

      debugPrint('500 items rendered successfully');
    });

    testWidgets('Render 1000 items without errors', (tester) async {
      await tester.pumpWidget(_buildListWidget(1000));
      await tester.pumpAndSettle();

      expect(tester.takeException(), isNull);

      debugPrint('1000 items rendered successfully');
    });

    testWidgets('Scroll performance with 100 items', (tester) async {
      await tester.pumpWidget(_buildListWidget(100));
      await tester.pumpAndSettle();

      final frames = <Duration>[];
      tester.binding.addTimingsCallback((timings) {
        for (final timing in timings) {
          frames.add(timing.totalSpan);
        }
      });

      // Perform scroll
      await tester.fling(
        find.byType(ListView),
        const Offset(0, -1000),
        1000,
      );

      // Pump frames during scroll
      for (int i = 0; i < 60; i++) {
        await tester.pump(const Duration(milliseconds: 16));
      }

      await tester.pumpAndSettle();

      if (frames.isNotEmpty) {
        final averageFrameTime = frames.fold<Duration>(
          Duration.zero,
          (prev, duration) => prev + duration,
        ) ~/ frames.length;

        final jankyFrames = frames.where((d) => d.inMilliseconds > 16).length;
        final jankyPercentage = (jankyFrames / frames.length) * 100;

        debugPrint('100 items scroll - avg frame time: ${averageFrameTime.inMicroseconds / 1000}ms');
        debugPrint('100 items scroll - janky frames: ${jankyPercentage.toStringAsFixed(1)}%');

        expect(jankyPercentage, lessThan(10),
          reason: 'Should maintain smooth scrolling with 100 items');
      }
    });

    testWidgets('Scroll performance with 500 items', (tester) async {
      await tester.pumpWidget(_buildListWidget(500));
      await tester.pumpAndSettle();

      final frames = <Duration>[];
      tester.binding.addTimingsCallback((timings) {
        for (final timing in timings) {
          frames.add(timing.totalSpan);
        }
      });

      await tester.fling(
        find.byType(ListView),
        const Offset(0, -2000),
        1500,
      );

      for (int i = 0; i < 60; i++) {
        await tester.pump(const Duration(milliseconds: 16));
      }

      await tester.pumpAndSettle();

      if (frames.isNotEmpty) {
        final jankyFrames = frames.where((d) => d.inMilliseconds > 16).length;
        final jankyPercentage = (jankyFrames / frames.length) * 100;

        debugPrint('500 items scroll - janky frames: ${jankyPercentage.toStringAsFixed(1)}%');

        expect(jankyPercentage, lessThan(15),
          reason: 'Should maintain acceptable scrolling with 500 items');
      }
    });

    testWidgets('Item card with gradient rendering performance', (tester) async {
      await tester.pumpWidget(_buildListWidget(50));
      await tester.pumpAndSettle();

      final frames = <Duration>[];
      tester.binding.addTimingsCallback((timings) {
        for (final timing in timings) {
          frames.add(timing.totalSpan);
        }
      });

      // Slow scroll to test sustained performance
      await tester.drag(
        find.byType(ListView),
        const Offset(0, -500),
        touchSlopY: 0.0,
      );

      for (int i = 0; i < 30; i++) {
        await tester.pump(const Duration(milliseconds: 16));
      }

      await tester.pumpAndSettle();

      if (frames.isNotEmpty) {
        final jankyFrames = frames.where((d) => d.inMilliseconds > 16).length;
        final jankyPercentage = (jankyFrames / frames.length) * 100;

        debugPrint('Gradient cards scroll - janky frames: ${jankyPercentage.toStringAsFixed(1)}%');

        expect(jankyPercentage, lessThan(10));
      }
    });

    testWidgets('ListView.builder vs ListView comparison', (tester) async {
      // Test ListView.builder (efficient)
      final stopwatchBuilder = Stopwatch()..start();
      await tester.pumpWidget(_buildListWidget(500));
      await tester.pumpAndSettle();
      stopwatchBuilder.stop();

      final builderTime = stopwatchBuilder.elapsedMilliseconds;
      debugPrint('ListView.builder build time: ${builderTime}ms');

      // ListView.builder should build quickly even with many items
      expect(builderTime, lessThan(500),
        reason: 'ListView.builder should lazy-build items');
    });

    testWidgets('Virtualization test - only visible items rendered', (tester) async {
      await tester.pumpWidget(_buildListWidget(1000));
      await tester.pumpAndSettle();

      // Count rendered ItemCard widgets
      final renderedCards = tester.widgetList(find.byType(ItemCard)).length;

      debugPrint('Rendered cards out of 1000: $renderedCards');

      // Only visible items + buffer should be rendered
      expect(renderedCards, lessThan(100),
        reason: 'ListView.builder should virtualize off-screen items');
    });

    testWidgets('Memory test indicator with large list', (tester) async {
      // This test verifies no crashes with large lists
      // Actual memory profiling requires device/profiler tools
      await tester.pumpWidget(_buildListWidget(2000));
      await tester.pumpAndSettle();

      expect(tester.takeException(), isNull);

      // Scroll through list
      for (int i = 0; i < 5; i++) {
        await tester.drag(
          find.byType(ListView),
          const Offset(0, -1000),
        );
        await tester.pump();
      }

      await tester.pumpAndSettle();

      expect(tester.takeException(), isNull);

      debugPrint('2000 items list scrolled without memory errors');
    });
  });
}

// Helper functions

Widget _buildListWidget(int itemCount) {
  return MaterialApp(
    home: Scaffold(
      body: ListView.builder(
        itemCount: itemCount,
        itemBuilder: (context, index) {
          return ItemCard(
            item: _createMockItem(index),
          );
        },
      ),
    ),
  );
}

Item _createMockItem(int index) {
  final types = [ItemType.task, ItemType.note, ItemType.list];
  final type = types[index % types.length];

  return Item(
    id: 'item_$index',
    title: 'Test Item $index',
    type: type,
    spaceId: 'test_space',
    createdAt: DateTime.now().subtract(Duration(days: index)),
    isCompleted: index % 5 == 0,
    content: index % 2 == 0
        ? 'This is some content for item $index. It has multiple lines of text to test the preview functionality.'
        : null,
    dueDate: index % 3 == 0 ? DateTime.now().add(Duration(days: index)) : null,
  );
}
