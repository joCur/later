import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:later_mobile/widgets/components/buttons/primary_button.dart';
import 'package:later_mobile/widgets/components/buttons/secondary_button.dart';
import 'package:later_mobile/widgets/components/buttons/ghost_button.dart';
import 'package:later_mobile/widgets/components/inputs/text_input_field.dart';
import 'package:later_mobile/widgets/components/inputs/text_area_field.dart';
import 'package:later_mobile/widgets/components/cards/item_card.dart';
import 'package:later_mobile/data/models/item_model.dart';

/// Accessibility Test Suite: Text Scaling Support
///
/// Tests that ensure the app supports text scaling up to 200% (2.0x)
/// without breaking layouts, losing content, or causing overlaps.
///
/// WCAG 2.1 Success Criteria:
/// - 1.4.4 Resize Text (Level AA) - Text can be resized up to 200%
/// - 1.4.10 Reflow (Level AA) - Content reflows without horizontal scrolling
/// - 1.4.12 Text Spacing (Level AA) - No loss of content with increased spacing
///
/// Coverage:
/// - Buttons remain usable with large text
/// - Input fields accommodate large text
/// - Cards and lists don't break with large text
/// - Navigation remains functional
/// - No content is cut off or overlapped
///
/// Success Criteria:
/// - All text scales up to 2.0x
/// - Layouts adapt without breaking
/// - No horizontal scrolling required
/// - All interactive elements remain accessible
void main() {
  group('Text Scaling - Button Components', () {
    testWidgets('PrimaryButton handles 1.5x text scaling',
        (WidgetTester tester) async {
      // Arrange: Create button with 1.5x text scale
      await tester.pumpWidget(
        MaterialApp(
          home: MediaQuery(
            data: const MediaQueryData(textScaler: TextScaler.linear(1.5)),
            child: Scaffold(
              body: Center(
                child: PrimaryButton(
                  text: 'Save Changes',
                  onPressed: () {},
                ),
              ),
            ),
          ),
        ),
      );

      // Act: Get button dimensions
      final buttonFinder = find.byType(PrimaryButton);
      expect(buttonFinder, findsOneWidget);

      final Size buttonSize = tester.getSize(buttonFinder);

      // Assert: Button should still be reasonable size
      expect(
        buttonSize.width < 600, // Shouldn't be unreasonably wide
        isTrue,
        reason: 'Button width should be reasonable with 1.5x scaling',
      );

      // Button should be tall enough for scaled text
      expect(
        buttonSize.height >= 44.0, // Should maintain minimum touch target
        isTrue,
        reason: 'Button should maintain adequate height with scaled text',
      );

      // Text should be visible (not clipped)
      expect(find.text('Save Changes'), findsOneWidget);
    });

    testWidgets('PrimaryButton handles 2.0x text scaling',
        (WidgetTester tester) async {
      // Arrange: Create button with 2.0x text scale (maximum required)
      await tester.pumpWidget(
        MaterialApp(
          home: MediaQuery(
            data: const MediaQueryData(textScaler: TextScaler.linear(2.0)),
            child: Scaffold(
              body: Center(
                child: PrimaryButton(
                  text: 'Save',
                  onPressed: () {},
                ),
              ),
            ),
          ),
        ),
      );

      // Act: Get button dimensions
      final buttonFinder = find.byType(PrimaryButton);
      expect(buttonFinder, findsOneWidget);

      final Size buttonSize = tester.getSize(buttonFinder);

      // Assert: Button should accommodate large text
      expect(
        buttonSize.height >= 48.0,
        isTrue,
        reason: 'Button should grow to accommodate 2.0x scaled text',
      );

      // Text should be visible (not clipped)
      expect(find.text('Save'), findsOneWidget);
    });

    testWidgets('PrimaryButton with icon handles 2.0x text scaling',
        (WidgetTester tester) async {
      // Arrange: Create button with icon and large text
      await tester.pumpWidget(
        MaterialApp(
          home: MediaQuery(
            data: const MediaQueryData(textScaler: TextScaler.linear(2.0)),
            child: Scaffold(
              body: Center(
                child: PrimaryButton(
                  text: 'Add Item',
                  icon: Icons.add,
                  onPressed: () {},
                ),
              ),
            ),
          ),
        ),
      );

      // Act: Find button
      final buttonFinder = find.byType(PrimaryButton);
      expect(buttonFinder, findsOneWidget);

      // Assert: Text and icon should both be visible
      expect(find.text('Add Item'), findsOneWidget);
      expect(find.byIcon(Icons.add), findsOneWidget);
    });

    testWidgets('SecondaryButton handles 2.0x text scaling',
        (WidgetTester tester) async {
      // Arrange: Create secondary button with 2.0x text scale
      await tester.pumpWidget(
        MaterialApp(
          home: MediaQuery(
            data: const MediaQueryData(textScaler: TextScaler.linear(2.0)),
            child: Scaffold(
              body: Center(
                child: SecondaryButton(
                  text: 'Cancel',
                  onPressed: () {},
                ),
              ),
            ),
          ),
        ),
      );

      // Assert: Button should be visible and usable
      expect(find.text('Cancel'), findsOneWidget);
      expect(find.byType(SecondaryButton), findsOneWidget);
    });

    testWidgets('GhostButton handles 2.0x text scaling',
        (WidgetTester tester) async {
      // Arrange: Create ghost button with 2.0x text scale
      await tester.pumpWidget(
        MaterialApp(
          home: MediaQuery(
            data: const MediaQueryData(textScaler: TextScaler.linear(2.0)),
            child: Scaffold(
              body: Center(
                child: GhostButton(
                  text: 'Learn More',
                  onPressed: () {},
                ),
              ),
            ),
          ),
        ),
      );

      // Assert: Button should be visible and usable
      expect(find.text('Learn More'), findsOneWidget);
      expect(find.byType(GhostButton), findsOneWidget);
    });

    testWidgets('Button group handles 2.0x text scaling without overlap',
        (WidgetTester tester) async {
      // Arrange: Create row of buttons with 2.0x text scale
      await tester.pumpWidget(
        MaterialApp(
          home: MediaQuery(
            data: const MediaQueryData(textScaler: TextScaler.linear(2.0)),
            child: Scaffold(
              body: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: [
                    Flexible(
                      child: SecondaryButton(
                        text: 'Cancel',
                        onPressed: () {},
                      ),
                    ),
                    const SizedBox(width: 16),
                    Flexible(
                      child: PrimaryButton(
                        text: 'Save',
                        onPressed: () {},
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      );

      // Assert: Both buttons should be visible
      expect(find.text('Cancel'), findsOneWidget);
      expect(find.text('Save'), findsOneWidget);

      // Buttons should not overlap
      final cancelButton = find.byType(SecondaryButton);
      final saveButton = find.byType(PrimaryButton);

      final cancelRect = tester.getRect(cancelButton);
      final saveRect = tester.getRect(saveButton);

      expect(
        cancelRect.right <= saveRect.left + 16, // Account for spacing
        isTrue,
        reason: 'Buttons should not overlap with large text',
      );
    });
  });

  group('Text Scaling - Input Fields', () {
    testWidgets('TextInputField handles 1.5x text scaling',
        (WidgetTester tester) async {
      // Arrange: Create input with 1.5x text scale
      await tester.pumpWidget(
        const MaterialApp(
          home: MediaQuery(
            data: MediaQueryData(textScaler: TextScaler.linear(1.5)),
            child: Scaffold(
              body: Padding(
                padding: EdgeInsets.all(16.0),
                child: TextInputField(
                  label: 'Email Address',
                  hintText: 'Enter your email',
                ),
              ),
            ),
          ),
        ),
      );

      // Assert: Label and hint should be visible
      expect(find.text('Email Address'), findsOneWidget);

      // Input should be usable
      final textField = find.byType(TextField);
      expect(textField, findsOneWidget);
    });

    testWidgets('TextInputField handles 2.0x text scaling',
        (WidgetTester tester) async {
      // Arrange: Create input with 2.0x text scale
      await tester.pumpWidget(
        const MaterialApp(
          home: MediaQuery(
            data: MediaQueryData(textScaler: TextScaler.linear(2.0)),
            child: Scaffold(
              body: Padding(
                padding: EdgeInsets.all(16.0),
                child: TextInputField(
                  label: 'Full Name',
                  hintText: 'Enter your full name',
                ),
              ),
            ),
          ),
        ),
      );

      // Assert: Label should be visible
      expect(find.text('Full Name'), findsOneWidget);

      // Input should accommodate large text
      final textField = find.byType(TextField);
      expect(textField, findsOneWidget);

      final Size fieldSize = tester.getSize(textField);
      expect(
        fieldSize.height >= 48.0,
        isTrue,
        reason: 'Input field should grow to accommodate large text',
      );
    });

    testWidgets('TextAreaField handles 2.0x text scaling',
        (WidgetTester tester) async {
      // Arrange: Create text area with 2.0x text scale
      await tester.pumpWidget(
        const MaterialApp(
          home: MediaQuery(
            data: MediaQueryData(textScaler: TextScaler.linear(2.0)),
            child: Scaffold(
              body: Padding(
                padding: EdgeInsets.all(16.0),
                child: TextAreaField(
                  label: 'Description',
                  hintText: 'Enter description',
                ),
              ),
            ),
          ),
        ),
      );

      // Assert: Label should be visible
      expect(find.text('Description'), findsOneWidget);

      // Text area should be usable
      final textField = find.byType(TextField);
      expect(textField, findsOneWidget);
    });

    testWidgets('Input field with error message handles 2.0x scaling',
        (WidgetTester tester) async {
      // Arrange: Create input with error and large text
      await tester.pumpWidget(
        const MaterialApp(
          home: MediaQuery(
            data: MediaQueryData(textScaler: TextScaler.linear(2.0)),
            child: Scaffold(
              body: Padding(
                padding: EdgeInsets.all(16.0),
                child: TextInputField(
                  label: 'Email',
                  errorText: 'Invalid email address',
                ),
              ),
            ),
          ),
        ),
      );

      // Assert: Label and error should both be visible
      expect(find.text('Email'), findsOneWidget);
      expect(find.text('Invalid email address'), findsOneWidget);
    });

    testWidgets('Multiple input fields stack properly with 2.0x scaling',
        (WidgetTester tester) async {
      // Arrange: Create form with multiple inputs and large text
      await tester.pumpWidget(
        const MaterialApp(
          home: MediaQuery(
            data: MediaQueryData(textScaler: TextScaler.linear(2.0)),
            child: Scaffold(
              body: SingleChildScrollView(
                padding: EdgeInsets.all(16.0),
                child: Column(
                  children: [
                    TextInputField(
                      label: 'First Name',
                      hintText: 'Enter first name',
                    ),
                    SizedBox(height: 16),
                    TextInputField(
                      label: 'Last Name',
                      hintText: 'Enter last name',
                    ),
                    SizedBox(height: 16),
                    TextInputField(
                      label: 'Email',
                      hintText: 'Enter email',
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      );

      // Assert: All fields should be visible
      expect(find.text('First Name'), findsOneWidget);
      expect(find.text('Last Name'), findsOneWidget);
      expect(find.text('Email'), findsOneWidget);

      // Fields should not overlap
      final textFields = find.byType(TextField);
      expect(textFields, findsNWidgets(3));
    });
  });

  group('Text Scaling - Item Cards', () {
    testWidgets('ItemCard handles 1.5x text scaling',
        (WidgetTester tester) async {
      // Arrange: Create card with 1.5x text scale
      final testItem = Item(
        id: 'test-1',
        title: 'Complete accessibility testing',
        type: ItemType.task,
        spaceId: 'space-1',
        content: 'Write comprehensive tests for all components',
      );

      await tester.pumpWidget(
        MaterialApp(
          home: MediaQuery(
            data: const MediaQueryData(textScaler: TextScaler.linear(1.5)),
            child: Scaffold(
              body: Padding(
                padding: const EdgeInsets.all(16.0),
                child: ItemCard(
                  item: testItem,
                  onTap: () {},
                ),
              ),
            ),
          ),
        ),
      );

      // Assert: Title and content should be visible
      expect(find.text(testItem.title), findsOneWidget);
      expect(find.textContaining('Write comprehensive'), findsOneWidget);
    });

    testWidgets('ItemCard handles 2.0x text scaling',
        (WidgetTester tester) async {
      // Arrange: Create card with 2.0x text scale
      final testItem = Item(
        id: 'test-2',
        title: 'Test with large text',
        type: ItemType.note,
        spaceId: 'space-1',
        content: 'This note should remain readable with large text',
      );

      await tester.pumpWidget(
        MaterialApp(
          home: MediaQuery(
            data: const MediaQueryData(textScaler: TextScaler.linear(2.0)),
            child: Scaffold(
              body: Padding(
                padding: const EdgeInsets.all(16.0),
                child: ItemCard(
                  item: testItem,
                  onTap: () {},
                ),
              ),
            ),
          ),
        ),
      );

      // Assert: Card should be visible and accommodate large text
      expect(find.byType(ItemCard), findsOneWidget);
      expect(find.text(testItem.title), findsOneWidget);

      // Card should grow to accommodate content
      final cardSize = tester.getSize(find.byType(ItemCard));
      expect(
        cardSize.height >= 60.0,
        isTrue,
        reason: 'Card should grow to accommodate large text',
      );
    });

    testWidgets('ItemCard list handles 2.0x scaling without overlap',
        (WidgetTester tester) async {
      // Arrange: Create list of cards with large text
      final items = [
        Item(
          id: '1',
          title: 'Task 1',
          type: ItemType.task,
          spaceId: 'space-1',
        ),
        Item(
          id: '2',
          title: 'Task 2',
          type: ItemType.task,
          spaceId: 'space-1',
        ),
        Item(
          id: '3',
          title: 'Task 3',
          type: ItemType.task,
          spaceId: 'space-1',
        ),
      ];

      await tester.pumpWidget(
        MaterialApp(
          home: MediaQuery(
            data: const MediaQueryData(textScaler: TextScaler.linear(2.0)),
            child: Scaffold(
              body: ListView.builder(
                padding: const EdgeInsets.all(16.0),
                itemCount: items.length,
                itemBuilder: (context, index) => ItemCard(
                  item: items[index],
                  onTap: () {},
                ),
              ),
            ),
          ),
        ),
      );

      // Assert: All cards should be visible
      expect(find.byType(ItemCard), findsNWidgets(3));
      expect(find.text('Task 1'), findsOneWidget);
      expect(find.text('Task 2'), findsOneWidget);
      expect(find.text('Task 3'), findsOneWidget);
    });

    testWidgets('ItemCard with long title handles text wrapping at 2.0x',
        (WidgetTester tester) async {
      // Arrange: Create card with very long title
      final testItem = Item(
        id: 'test-4',
        title: 'This is a very long task title that should wrap to multiple lines when text scaling is applied',
        type: ItemType.task,
        spaceId: 'space-1',
      );

      await tester.pumpWidget(
        MaterialApp(
          home: MediaQuery(
            data: const MediaQueryData(textScaler: TextScaler.linear(2.0)),
            child: Scaffold(
              body: SizedBox(
                width: 400, // Constrain width to force wrapping
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: ItemCard(
                    item: testItem,
                    onTap: () {},
                  ),
                ),
              ),
            ),
          ),
        ),
      );

      // Assert: Card should exist and accommodate wrapped text
      expect(find.byType(ItemCard), findsOneWidget);

      // Title should be visible (may be truncated with ellipsis per design)
      final cardSize = tester.getSize(find.byType(ItemCard));
      expect(
        cardSize.height >= 60.0,
        isTrue,
        reason: 'Card should accommodate wrapped/scaled text',
      );
    });
  });

  group('Text Scaling - Navigation', () {
    testWidgets('Bottom navigation handles 1.5x text scaling',
        (WidgetTester tester) async {
      // Arrange: Create bottom nav with 1.5x text scale
      await tester.pumpWidget(
        MaterialApp(
          home: MediaQuery(
            data: const MediaQueryData(textScaler: TextScaler.linear(1.5)),
            child: Scaffold(
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
        ),
      );

      // Assert: Navigation should be visible
      expect(find.byType(BottomNavigationBar), findsOneWidget);

      // Should maintain adequate height
      final navBarSize = tester.getSize(find.byType(BottomNavigationBar));
      expect(
        navBarSize.height >= 56.0,
        isTrue,
        reason: 'Navigation bar should maintain minimum height',
      );
    });

    testWidgets('Bottom navigation handles 2.0x text scaling',
        (WidgetTester tester) async {
      // Arrange: Create bottom nav with 2.0x text scale
      await tester.pumpWidget(
        MaterialApp(
          home: MediaQuery(
            data: const MediaQueryData(textScaler: TextScaler.linear(2.0)),
            child: Scaffold(
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
        ),
      );

      // Assert: Navigation should be visible and usable
      expect(find.byType(BottomNavigationBar), findsOneWidget);

      // Icons should be visible
      final icons = find.descendant(
        of: find.byType(BottomNavigationBar),
        matching: find.byType(Icon),
      );
      expect(icons, findsWidgets);
    });
  });

  group('Text Scaling - Complex Layouts', () {
    testWidgets('Screen with mixed content handles 2.0x scaling',
        (WidgetTester tester) async {
      // Arrange: Create screen with various elements and 2.0x text
      final testItem = Item(
        id: 'test-1',
        title: 'Sample Task',
        type: ItemType.task,
        spaceId: 'space-1',
      );

      await tester.pumpWidget(
        MaterialApp(
          home: MediaQuery(
            data: const MediaQueryData(textScaler: TextScaler.linear(2.0)),
            child: Scaffold(
              appBar: AppBar(title: const Text('Tasks')),
              body: SingleChildScrollView(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    const Text('My Tasks'),
                    const SizedBox(height: 16),
                    ItemCard(
                      item: testItem,
                      onTap: () {},
                    ),
                    const SizedBox(height: 16),
                    PrimaryButton(
                      text: 'Add Task',
                      onPressed: () {},
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      );

      // Assert: All elements should be visible
      expect(find.text('Tasks'), findsOneWidget);
      expect(find.text('My Tasks'), findsOneWidget);
      expect(find.text('Sample Task'), findsOneWidget);
      expect(find.text('Add Task'), findsOneWidget);
    });

    testWidgets('Horizontal scrolling is not required with 2.0x scaling',
        (WidgetTester tester) async {
      // Arrange: Create content that should reflow
      await tester.pumpWidget(
        MaterialApp(
          home: MediaQuery(
            data: const MediaQueryData(textScaler: TextScaler.linear(2.0)),
            child: Scaffold(
              body: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    const Text(
                      'This is a paragraph of text that should wrap to multiple lines when scaled',
                    ),
                    const SizedBox(height: 16),
                    PrimaryButton(
                      text: 'Action',
                      onPressed: () {},
                      isExpanded: true,
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      );

      // Assert: Content should fit within screen width
      final screenWidth = tester.getSize(find.byType(Scaffold)).width;
      final textWidth = tester.getSize(find.text(
        'This is a paragraph of text that should wrap to multiple lines when scaled',
      )).width;

      expect(
        textWidth <= screenWidth,
        isTrue,
        reason: 'Text should not require horizontal scrolling',
      );
    });
  });

  group('Text Scaling - Edge Cases', () {
    testWidgets('Empty state handles 2.0x text scaling',
        (WidgetTester tester) async {
      // Arrange: Create empty state with large text
      await tester.pumpWidget(
        const MaterialApp(
          home: MediaQuery(
            data: MediaQueryData(textScaler: TextScaler.linear(2.0)),
            child: Scaffold(
              body: Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(Icons.inbox, size: 64),
                    SizedBox(height: 16),
                    Text('No items yet'),
                    SizedBox(height: 8),
                    Text('Get started by creating your first item'),
                  ],
                ),
              ),
            ),
          ),
        ),
      );

      // Assert: All text should be visible
      expect(find.text('No items yet'), findsOneWidget);
      expect(find.text('Get started by creating your first item'), findsOneWidget);
    });

    testWidgets('Very small button text remains readable at 2.0x',
        (WidgetTester tester) async {
      // Arrange: Create small button with 2.0x text
      await tester.pumpWidget(
        MaterialApp(
          home: MediaQuery(
            data: const MediaQueryData(textScaler: TextScaler.linear(2.0)),
            child: Scaffold(
              body: Center(
                child: PrimaryButton(
                  text: 'OK',
                  size: ButtonSize.small,
                  onPressed: () {},
                ),
              ),
            ),
          ),
        ),
      );

      // Assert: Text should be visible
      expect(find.text('OK'), findsOneWidget);

      // Button should grow to accommodate text
      final buttonSize = tester.getSize(find.byType(PrimaryButton));
      expect(
        buttonSize.height >= 36.0, // Small button base size
        isTrue,
        reason: 'Small button should accommodate scaled text',
      );
    });
  });
}
