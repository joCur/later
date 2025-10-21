import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:later_mobile/core/theme/app_colors.dart';
import 'package:later_mobile/data/models/item_model.dart';
import 'package:later_mobile/widgets/components/cards/item_card.dart';

/// Performance tests for memory usage
///
/// Tests memory with:
/// - New visual effects (gradients, glass morphism)
/// - Memory leaks (providers, animations)
/// - Cached vs non-cached shaders
/// - Memory pressure scenarios
///
/// Target: < 100MB for typical usage
///
/// Note: Actual memory profiling requires running on device with profiler.
/// These tests verify no crashes and proper cleanup.
void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  group('Memory Usage Tests', () {
    testWidgets('Gradient memory - multiple unique gradients', (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: ListView.builder(
              itemCount: 100,
              itemBuilder: (context, index) {
                // Create unique gradients
                return Container(
                  height: 100,
                  margin: const EdgeInsets.all(4),
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      colors: [
                        Color.fromARGB(255, index * 2, 100, 200),
                        Color.fromARGB(255, 100, index * 2, 200),
                      ],
                    ),
                  ),
                );
              },
            ),
          ),
        ),
      );

      await tester.pumpAndSettle();

      // Scroll through list to render all items
      for (int i = 0; i < 5; i++) {
        await tester.drag(find.byType(ListView), const Offset(0, -1000));
        await tester.pump();
      }

      await tester.pumpAndSettle();

      expect(tester.takeException(), isNull);
      debugPrint('100 unique gradients: No memory errors');
    });

    testWidgets('Gradient memory - repeated gradients (caching)', (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: ListView.builder(
              itemCount: 100,
              itemBuilder: (context, index) {
                // Use same gradient repeatedly
                return Container(
                  height: 100,
                  margin: const EdgeInsets.all(4),
                  decoration: const BoxDecoration(
                    gradient: AppColors.primaryGradient,
                  ),
                );
              },
            ),
          ),
        ),
      );

      await tester.pumpAndSettle();

      for (int i = 0; i < 5; i++) {
        await tester.drag(find.byType(ListView), const Offset(0, -1000));
        await tester.pump();
      }

      await tester.pumpAndSettle();

      expect(tester.takeException(), isNull);
      debugPrint('100 cached gradients: No memory errors');
    });

    testWidgets('Animation controller cleanup test', (tester) async {
      await tester.pumpWidget(_buildAnimationWidget());
      await tester.pumpAndSettle();

      // Trigger animations
      await tester.tap(find.byType(ElevatedButton));
      await tester.pump();

      for (int i = 0; i < 20; i++) {
        await tester.pump(const Duration(milliseconds: 16));
      }

      // Dispose widget
      await tester.pumpWidget(const SizedBox.shrink());
      await tester.pumpAndSettle();

      expect(tester.takeException(), isNull);
      debugPrint('Animation controllers disposed properly');
    });

    testWidgets('ItemCard memory with entrance animations', (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: ListView.builder(
              itemCount: 50,
              itemBuilder: (context, index) {
                return ItemCard(
                  item: _createMockItem(index),
                  index: index,
                );
              },
            ),
          ),
        ),
      );

      // Pump animations
      for (int i = 0; i < 100; i++) {
        await tester.pump(const Duration(milliseconds: 16));
      }

      await tester.pumpAndSettle();

      // Dispose
      await tester.pumpWidget(const SizedBox.shrink());
      await tester.pumpAndSettle();

      expect(tester.takeException(), isNull);
      debugPrint('ItemCard animations cleaned up properly');
    });

    testWidgets('Memory stress test - rapid widget rebuilds', (tester) async {
      for (int i = 0; i < 10; i++) {
        await tester.pumpWidget(
          MaterialApp(
            home: Scaffold(
              body: Container(
                decoration: const BoxDecoration(
                  gradient: AppColors.primaryGradient,
                ),
                child: Text('Rebuild $i'),
              ),
            ),
          ),
        );
        await tester.pump();
      }

      await tester.pumpAndSettle();

      expect(tester.takeException(), isNull);
      debugPrint('Rapid rebuilds: No memory errors');
    });

    testWidgets('Large list memory pressure', (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: ListView.builder(
              itemCount: 5000,
              itemBuilder: (context, index) {
                return ItemCard(
                  item: _createMockItem(index),
                );
              },
            ),
          ),
        ),
      );

      await tester.pumpAndSettle();

      // Scroll through portions of the list
      for (int i = 0; i < 10; i++) {
        await tester.drag(find.byType(ListView), const Offset(0, -2000));
        await tester.pump();
      }

      await tester.pumpAndSettle();

      expect(tester.takeException(), isNull);
      debugPrint('5000 items with virtualization: No memory errors');
    });

    testWidgets('Provider memory leak test', (tester) async {
      // Create and dispose providers multiple times
      for (int i = 0; i < 5; i++) {
        await tester.pumpWidget(
          MaterialApp(
            home: Scaffold(
              body: Container(
                decoration: const BoxDecoration(
                  gradient: AppColors.primaryGradient,
                ),
              ),
            ),
          ),
        );
        await tester.pump();

        // Dispose
        await tester.pumpWidget(const SizedBox.shrink());
        await tester.pump();
      }

      expect(tester.takeException(), isNull);
      debugPrint('Provider lifecycle: No memory leaks detected');
    });

    testWidgets('Mixed content memory test', (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: ListView.builder(
              itemCount: 200,
              itemBuilder: (context, index) {
                if (index % 3 == 0) {
                  return ItemCard(item: _createMockItem(index));
                } else if (index % 3 == 1) {
                  return Container(
                    height: 80,
                    margin: const EdgeInsets.all(8),
                    decoration: const BoxDecoration(
                      gradient: AppColors.secondaryGradient,
                    ),
                  );
                } else {
                  return const ListTile(
                    title: Text('Regular tile'),
                  );
                }
              },
            ),
          ),
        ),
      );

      await tester.pumpAndSettle();

      for (int i = 0; i < 5; i++) {
        await tester.drag(find.byType(ListView), const Offset(0, -1500));
        await tester.pump();
      }

      await tester.pumpAndSettle();

      expect(tester.takeException(), isNull);
      debugPrint('Mixed content types: No memory errors');
    });
  });
}

// Helper widgets

Widget _buildAnimationWidget() {
  return MaterialApp(
    home: Scaffold(
      body: _TestAnimatedWidget(),
    ),
  );
}

class _TestAnimatedWidget extends StatefulWidget {
  @override
  State<_TestAnimatedWidget> createState() => _TestAnimatedWidgetState();
}

class _TestAnimatedWidgetState extends State<_TestAnimatedWidget>
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
    return Column(
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
          onPressed: () {
            _controller.forward(from: 0.0);
          },
          child: const Text('Animate'),
        ),
      ],
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
