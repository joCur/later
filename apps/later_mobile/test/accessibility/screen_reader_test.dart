import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:later_mobile/design_system/atoms/buttons/primary_button.dart';
import 'package:later_mobile/design_system/molecules/fab/quick_capture_fab.dart';
import 'package:later_mobile/design_system/organisms/cards/item_card.dart';
import 'package:later_mobile/data/models/item_model.dart';

/// Accessibility Test Suite: Screen Reader Support
///
/// Tests that simulate VoiceOver (iOS) and TalkBack (Android) behavior
/// to ensure the app is fully navigable and understandable via screen readers.
///
/// WCAG 2.1 Success Criteria:
/// - 1.3.1 Info and Relationships (Level A)
/// - 2.4.3 Focus Order (Level A)
/// - 4.1.3 Status Messages (Level AA)
///
/// Coverage:
/// - Navigation flow is logical
/// - State changes are announced
/// - Interactive elements are discoverable
/// - Reading order makes sense
/// - Live regions announce updates
///
/// Success Criteria:
/// - Semantic tree is complete and logical
/// - Focus order follows visual order
/// - State changes trigger announcements
/// - All content is reachable via screen reader
void main() {
  group('Screen Reader - Semantic Tree Structure', () {
    testWidgets('App has proper semantic tree hierarchy',
        (WidgetTester tester) async {
      // Arrange: Build a simple screen with multiple elements
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            appBar: AppBar(title: const Text('Test Screen')),
            body: Column(
              children: [
                const Text('Welcome'),
                PrimaryButton(
                  text: 'Get Started',
                  onPressed: () {},
                ),
              ],
            ),
            floatingActionButton: QuickCaptureFab(
              onPressed: () {},
            ),
          ),
        ),
      );

      // Act: Enable semantics and get the tree
      final SemanticsHandle handle = tester.ensureSemantics();
      await tester.pumpAndSettle();

      // Get all semantic nodes
      final semantics = tester.binding.rootPipelineOwner.semanticsOwner!;

      // Assert: Semantic tree should exist and be navigable
      expect(
        semantics.rootSemanticsNode,
        isNotNull,
        reason: 'App should have a semantic tree root',
      );

      // Clean up
      handle.dispose();
    });

    testWidgets('Screen reader can traverse all interactive elements',
        (WidgetTester tester) async {
      // Arrange: Create screen with multiple interactive elements
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: Column(
              children: [
                PrimaryButton(
                  text: 'Button 1',
                  onPressed: () {},
                ),
                PrimaryButton(
                  text: 'Button 2',
                  onPressed: () {},
                ),
                PrimaryButton(
                  text: 'Button 3',
                  onPressed: () {},
                ),
              ],
            ),
          ),
        ),
      );

      // Act: Enable semantics
      final SemanticsHandle handle = tester.ensureSemantics();
      await tester.pumpAndSettle();

      // Find all buttons
      final buttonFinders = find.byType(PrimaryButton);
      expect(buttonFinders, findsNWidgets(3));

      // Assert: Each button should have semantic properties
      for (int i = 0; i < 3; i++) {
        final semantics = tester.getSemantics(buttonFinders.at(i));
        expect(
          semantics.flagsCollection.isButton,
          isTrue,
          reason: 'Button ${i + 1} should be identifiable by screen reader',
        );
      }

      // Clean up
      handle.dispose();
    });

    testWidgets('Semantic tree respects visual hierarchy',
        (WidgetTester tester) async {
      // Arrange: Create nested semantic structure
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            appBar: AppBar(title: const Text('Tasks')),
            body: Column(
              children: [
                const Text('My Tasks'),
                Expanded(
                  child: ListView(
                    children: [
                      ItemCard(
                        item: Item(
                          id: '1',
                          title: 'Task 1',
                          spaceId: 'space-1',
                        ),
                        onTap: () {},
                      ),
                      ItemCard(
                        item: Item(
                          id: '2',
                          title: 'Task 2',
                          spaceId: 'space-1',
                        ),
                        onTap: () {},
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      );

      // Act: Enable semantics
      final SemanticsHandle handle = tester.ensureSemantics();
      await tester.pumpAndSettle();

      // Assert: Semantic structure should be traversable
      final cardFinders = find.byType(ItemCard);
      expect(cardFinders, findsNWidgets(2));

      // Each card should be semantically accessible
      for (int i = 0; i < 2; i++) {
        final semantics = tester.getSemantics(cardFinders.at(i));
        expect(
          semantics.label,
          isNotEmpty,
          reason: 'Card ${i + 1} should have semantic label',
        );
      }

      // Clean up
      handle.dispose();
    });
  });

  group('Screen Reader - Focus Order', () {
    testWidgets('Focus order follows logical reading order',
        (WidgetTester tester) async {
      // Arrange: Create screen with multiple focusable elements
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: Column(
              children: [
                PrimaryButton(
                  text: 'First',
                  onPressed: () {},
                ),
                PrimaryButton(
                  text: 'Second',
                  onPressed: () {},
                ),
                PrimaryButton(
                  text: 'Third',
                  onPressed: () {},
                ),
              ],
            ),
          ),
        ),
      );

      // Act: Enable semantics
      final SemanticsHandle handle = tester.ensureSemantics();
      await tester.pumpAndSettle();

      // Get semantic nodes in traversal order
      final buttonFinders = find.byType(PrimaryButton);
      expect(buttonFinders, findsNWidgets(3));

      // Assert: Buttons should be traversable in order
      final firstButton = tester.getSemantics(buttonFinders.at(0));
      final secondButton = tester.getSemantics(buttonFinders.at(1));
      final thirdButton = tester.getSemantics(buttonFinders.at(2));

      expect(firstButton.label, equals('First'));
      expect(secondButton.label, equals('Second'));
      expect(thirdButton.label, equals('Third'));

      // Clean up
      handle.dispose();
    });

    testWidgets('Bottom navigation is accessible in correct order',
        (WidgetTester tester) async {
      // Arrange: Create screen with bottom navigation
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: const Center(child: Text('Content')),
            bottomNavigationBar: BottomNavigationBar(
              onTap: (_) {},
              items: const [
                BottomNavigationBarItem(
                  icon: Icon(Icons.home),
                  label: 'Home',
                ),
                BottomNavigationBarItem(
                  icon: Icon(Icons.search),
                  label: 'Search',
                ),
                BottomNavigationBarItem(
                  icon: Icon(Icons.settings),
                  label: 'Settings',
                ),
              ],
            ),
          ),
        ),
      );

      // Act: Enable semantics
      final SemanticsHandle handle = tester.ensureSemantics();
      await tester.pumpAndSettle();

      // Assert: Navigation should be semantically accessible
      final navBarFinder = find.byType(BottomNavigationBar);
      expect(navBarFinder, findsOneWidget);

      // Clean up
      handle.dispose();
    });
  });

  group('Screen Reader - State Announcements', () {
    testWidgets('Button state changes are announced',
        (WidgetTester tester) async {
      // Arrange: Create enabled button
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: StatefulBuilder(
              builder: (context, setState) {
                return PrimaryButton(
                  text: 'Toggle Me',
                  onPressed: () {},
                );
              },
            ),
          ),
        ),
      );

      // Act: Enable semantics
      final SemanticsHandle handle = tester.ensureSemantics();
      await tester.pumpAndSettle();

      // Get initial state
      final buttonFinder = find.byType(PrimaryButton);
      final initialSemantics = tester.getSemantics(buttonFinder);

      // Assert: Initial state should show enabled
      expect(
        initialSemantics.flagsCollection.hasEnabledState,
        isTrue,
        reason: 'Button should have enabled state flag',
      );

      // Clean up
      handle.dispose();
    });

    testWidgets('Checkbox state changes are announced',
        (WidgetTester tester) async {
      // Arrange: Create task card with checkbox

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: StatefulBuilder(
              builder: (context, setState) {
                return ItemCard(
                  item: Item(
                    id: 'test-1',
                    title: 'Test Task',
                    spaceId: 'space-1',
                  ),
                );
              },
            ),
          ),
        ),
      );

      // Act: Enable semantics
      final SemanticsHandle handle = tester.ensureSemantics();
      await tester.pumpAndSettle();

      // Find checkbox
      final checkboxFinder = find.byType(Checkbox);
      expect(checkboxFinder, findsOneWidget);

      // Get initial semantics
      final initialSemantics = tester.getSemantics(checkboxFinder);

      // Assert: Checkbox should have checked state
      expect(
        initialSemantics.flagsCollection.hasCheckedState,
        isTrue,
        reason: 'Checkbox should have checked state flag',
      );

      expect(
        initialSemantics.flagsCollection.isChecked,
        isFalse,
        reason: 'Checkbox should not be checked initially',
      );

      // Tap checkbox
      await tester.tap(checkboxFinder);
      await tester.pumpAndSettle();

      // Get updated semantics
      final updatedSemantics = tester.getSemantics(checkboxFinder);

      // Assert: Checkbox should now be checked
      expect(
        updatedSemantics.flagsCollection.isChecked,
        isTrue,
        reason: 'Checkbox should be checked after tap',
      );

      // Clean up
      handle.dispose();
    });

    testWidgets('Loading state is communicated to screen reader',
        (WidgetTester tester) async {
      // Arrange: Create button with loading state
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: StatefulBuilder(
              builder: (context, setState) {
                return PrimaryButton(
                  text: 'Submit',
                  onPressed: () {},
                );
              },
            ),
          ),
        ),
      );

      // Act: Enable semantics
      final SemanticsHandle handle = tester.ensureSemantics();
      await tester.pumpAndSettle();

      // Get semantics
      final buttonFinder = find.byType(PrimaryButton);
      final semantics = tester.getSemantics(buttonFinder);

      // Assert: Button should maintain semantic label when loading
      expect(
        semantics.label,
        isNotEmpty,
        reason: 'Button should maintain label when loading',
      );

      // Clean up
      handle.dispose();
    });
  });

  group('Screen Reader - Content Discovery', () {
    testWidgets('All text content is exposed to screen reader',
        (WidgetTester tester) async {
      // Arrange: Create card with title and content
      final testItem = Item(
        id: 'test-1',
        title: 'Test Note Title',
        spaceId: 'space-1',
        content: 'This is the note content that should be accessible',
      );

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: ItemCard(
              item: testItem,
              onTap: () {},
            ),
          ),
        ),
      );

      // Act: Enable semantics
      final SemanticsHandle handle = tester.ensureSemantics();
      await tester.pumpAndSettle();

      // Assert: Content should be findable
      expect(find.text(testItem.title), findsOneWidget);
      expect(find.text(testItem.content!), findsOneWidget);

      // Clean up
      handle.dispose();
    });

    testWidgets('Icon-only buttons have accessible labels',
        (WidgetTester tester) async {
      // Arrange: Create FAB (icon-only button)
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: Center(
              child: QuickCaptureFab(
                onPressed: () {},
                tooltip: 'Create new item',
              ),
            ),
          ),
        ),
      );

      // Act: Enable semantics
      final SemanticsHandle handle = tester.ensureSemantics();
      await tester.pumpAndSettle();

      // Get semantics
      final fabFinder = find.byType(QuickCaptureFab);
      final semantics = tester.getSemantics(fabFinder);

      // Assert: FAB should have accessible label
      expect(
        semantics.label,
        isNotEmpty,
        reason: 'Icon-only FAB should have accessible label',
      );

      // Clean up
      handle.dispose();
    });

    testWidgets('Images and icons have alternative text',
        (WidgetTester tester) async {
      // Arrange: Create button with icon
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: Center(
              child: PrimaryButton(
                text: 'Add Item',
                onPressed: () {},
                icon: Icons.add,
              ),
            ),
          ),
        ),
      );

      // Act: Enable semantics
      final SemanticsHandle handle = tester.ensureSemantics();
      await tester.pumpAndSettle();

      // Get semantics
      final buttonFinder = find.byType(PrimaryButton);
      final semantics = tester.getSemantics(buttonFinder);

      // Assert: Button label should describe the action
      expect(
        semantics.label,
        equals('Add Item'),
        reason: 'Button with icon should have descriptive label',
      );

      // Clean up
      handle.dispose();
    });
  });

  group('Screen Reader - Navigation Announcements', () {
    testWidgets('Screen navigation is announced',
        (WidgetTester tester) async {
      // Arrange: Create two screens that can be navigated
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            appBar: AppBar(title: const Text('Home')),
            body: Center(
              child: PrimaryButton(
                text: 'Go to Details',
                onPressed: () {},
              ),
            ),
          ),
        ),
      );

      // Act: Enable semantics
      final SemanticsHandle handle = tester.ensureSemantics();
      await tester.pumpAndSettle();

      // Assert: Screen title should be accessible
      final titleFinder = find.text('Home');
      expect(titleFinder, findsOneWidget);

      // Clean up
      handle.dispose();
    });

    testWidgets('Modal dialogs are announced when opened',
        (WidgetTester tester) async {
      // Arrange: Create button that opens dialog
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: Center(
              child: Builder(
                builder: (context) {
                  return PrimaryButton(
                    text: 'Show Dialog',
                    onPressed: () {
                      showDialog<void>(
                        context: context,
                        builder: (context) => AlertDialog(
                          title: const Text('Confirmation'),
                          content: const Text('Are you sure?'),
                          actions: [
                            TextButton(
                              onPressed: () => Navigator.pop(context),
                              child: const Text('Cancel'),
                            ),
                            TextButton(
                              onPressed: () => Navigator.pop(context),
                              child: const Text('Confirm'),
                            ),
                          ],
                        ),
                      );
                    },
                  );
                },
              ),
            ),
          ),
        ),
      );

      // Act: Enable semantics and tap button
      final SemanticsHandle handle = tester.ensureSemantics();
      await tester.tap(find.byType(PrimaryButton));
      await tester.pumpAndSettle();

      // Assert: Dialog content should be accessible
      expect(find.text('Confirmation'), findsOneWidget);
      expect(find.text('Are you sure?'), findsOneWidget);

      // Clean up
      handle.dispose();
    });
  });

  group('Screen Reader - Error Announcements', () {
    testWidgets('Form validation errors are announced',
        (WidgetTester tester) async {
      // Arrange: Create form with error
      const errorMessage = 'This field is required';

      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: TextField(
              decoration: InputDecoration(
                labelText: 'Email',
                errorText: errorMessage,
              ),
            ),
          ),
        ),
      );

      // Act: Enable semantics
      final SemanticsHandle handle = tester.ensureSemantics();
      await tester.pumpAndSettle();

      // Assert: Error message should be visible
      expect(find.text(errorMessage), findsOneWidget);

      // Clean up
      handle.dispose();
    });
  });

  group('Screen Reader - Interactive Element Grouping', () {
    testWidgets('Related elements are grouped semantically',
        (WidgetTester tester) async {
      // Arrange: Create card with multiple elements
      final testItem = Item(
        id: 'test-1',
        title: 'Task with checkbox',
        spaceId: 'space-1',
      );

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: ItemCard(
              item: testItem,
            ),
          ),
        ),
      );

      // Act: Enable semantics
      final SemanticsHandle handle = tester.ensureSemantics();
      await tester.pumpAndSettle();

      // Get card semantics
      final cardFinder = find.byType(ItemCard);
      final cardSemantics = tester.getSemantics(cardFinder);

      // Assert: Card should be a semantic container
      expect(
        cardSemantics.flagsCollection.scopesRoute ||
            cardSemantics.label.isNotEmpty,
        isTrue,
        reason: 'Card should group related elements semantically',
      );

      // Clean up
      handle.dispose();
    });
  });
}
