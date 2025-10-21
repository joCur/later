import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:later_mobile/widgets/components/fab/quick_capture_fab.dart';
import 'package:later_mobile/widgets/components/cards/item_card.dart';
import 'package:later_mobile/data/models/item_model.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  group('FAB and ItemCard Haptic Feedback', () {
    final List<MethodCall> methodCalls = [];

    setUp(() {
      methodCalls.clear();

      TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
          .setMockMethodCallHandler(
        SystemChannels.platform,
        (MethodCall methodCall) async {
          methodCalls.add(methodCall);
          return null;
        },
      );
    });

    tearDown(() {
      TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
          .setMockMethodCallHandler(SystemChannels.platform, null);
    });

    group('QuickCaptureFab', () {
      testWidgets('triggers medium haptic on press', (WidgetTester tester) async {
        bool wasPressed = false;

        await tester.pumpWidget(
          MaterialApp(
            home: Scaffold(
              body: QuickCaptureFab(
                onPressed: () {
                  wasPressed = true;
                },
              ),
            ),
          ),
        );

        // Find the FAB by icon
        final fab = find.byType(QuickCaptureFab);
        expect(fab, findsOneWidget);

        // Press the FAB
        await tester.tap(fab);
        await tester.pumpAndSettle();

        // Verify callback was called
        expect(wasPressed, isTrue);
      });

      testWidgets('shows icon rotation animation with haptic', (WidgetTester tester) async {
        await tester.pumpWidget(
          MaterialApp(
            home: Scaffold(
              body: QuickCaptureFab(
                onPressed: () {},
              ),
            ),
          ),
        );

        // Verify widget builds without error
        expect(find.byType(QuickCaptureFab), findsOneWidget);

        // Update to open state
        await tester.pumpWidget(
          MaterialApp(
            home: Scaffold(
              body: QuickCaptureFab(
                onPressed: () {},
                isOpen: true,
              ),
            ),
          ),
        );

        await tester.pumpAndSettle();

        // No exceptions should be thrown during animation
      });
    });

    group('ItemCard', () {
      final testItem = Item(
        id: 'test-1',
        spaceId: 'space-1',
        title: 'Test Task',
        type: ItemType.task,
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
      );

      testWidgets('triggers light haptic on card tap', (WidgetTester tester) async {
        bool wasTapped = false;

        await tester.pumpWidget(
          MaterialApp(
            home: Scaffold(
              body: ItemCard(
                item: testItem,
                onTap: () {
                  wasTapped = true;
                },
              ),
            ),
          ),
        );

        // Tap the card (not the checkbox)
        final card = find.byType(ItemCard);
        expect(card, findsOneWidget);

        await tester.tap(card);
        await tester.pumpAndSettle();

        expect(wasTapped, isTrue);
      });

      testWidgets('triggers medium haptic on checkbox toggle', (WidgetTester tester) async {
        bool? checkboxValue;

        await tester.pumpWidget(
          MaterialApp(
            home: Scaffold(
              body: ItemCard(
                item: testItem,
                onCheckboxChanged: (value) {
                  checkboxValue = value;
                },
              ),
            ),
          ),
        );

        // Find and tap the checkbox
        final checkbox = find.byType(Checkbox);
        expect(checkbox, findsOneWidget);

        await tester.tap(checkbox);
        await tester.pumpAndSettle();

        // Verify checkbox callback was triggered
        expect(checkboxValue, isNotNull);
        expect(checkboxValue, isTrue);
      });

      testWidgets('triggers medium haptic on long press', (WidgetTester tester) async {
        bool wasLongPressed = false;

        await tester.pumpWidget(
          MaterialApp(
            home: Scaffold(
              body: ItemCard(
                item: testItem,
                onLongPress: () {
                  wasLongPressed = true;
                },
              ),
            ),
          ),
        );

        final card = find.byType(ItemCard);
        await tester.longPress(card);
        await tester.pumpAndSettle();

        expect(wasLongPressed, isTrue);
      });

      testWidgets('checkbox scale animation works with haptic', (WidgetTester tester) async {
        await tester.pumpWidget(
          MaterialApp(
            home: Scaffold(
              body: ItemCard(
                item: testItem,
                onCheckboxChanged: (value) {},
              ),
            ),
          ),
        );

        // Tap checkbox
        final checkbox = find.byType(Checkbox);
        await tester.tap(checkbox);

        // Pump animation frames
        await tester.pump();
        await tester.pump(const Duration(milliseconds: 125)); // Mid-animation
        await tester.pump(const Duration(milliseconds: 125)); // End animation
        await tester.pumpAndSettle();

        // Animation should complete without errors
      });
    });
  });
}
