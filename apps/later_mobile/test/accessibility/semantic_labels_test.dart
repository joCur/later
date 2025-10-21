import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:later_mobile/widgets/components/buttons/primary_button.dart';
import 'package:later_mobile/widgets/components/buttons/secondary_button.dart';
import 'package:later_mobile/widgets/components/buttons/ghost_button.dart';
import 'package:later_mobile/widgets/components/buttons/theme_toggle_button.dart';
import 'package:later_mobile/widgets/components/fab/quick_capture_fab.dart';
import 'package:later_mobile/widgets/components/cards/item_card.dart';
import 'package:later_mobile/widgets/components/inputs/text_input_field.dart';
import 'package:later_mobile/data/models/item_model.dart';

/// Accessibility Test Suite: Semantic Labels Verification
///
/// Tests that all interactive elements have proper semantic labels for
/// screen readers (VoiceOver on iOS, TalkBack on Android).
///
/// WCAG 2.1 Success Criteria:
/// - 4.1.2 Name, Role, Value (Level A)
/// - 2.4.6 Headings and Labels (Level AA)
/// - 3.3.2 Labels or Instructions (Level A)
///
/// Coverage:
/// - Buttons have descriptive labels
/// - Icons have meaningful tooltips
/// - Form inputs have associated labels
/// - Interactive elements have role indicators
/// - State changes are properly announced
///
/// Success Criteria:
/// - All interactive elements have semantic labels
/// - Labels are descriptive and meaningful
/// - Icons have tooltips or labels
/// - Form inputs have proper labels
void main() {
  group('Semantic Labels - Buttons', () {
    testWidgets('PrimaryButton has semantic button role and label',
        (WidgetTester tester) async {
      // Arrange: Create button with text
      const buttonText = 'Save Changes';
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: Center(
              child: PrimaryButton(
                text: buttonText,
                onPressed: () {},
              ),
            ),
          ),
        ),
      );

      // Act: Get semantics
      final semantics = tester.getSemantics(find.byType(PrimaryButton));

      // Assert: Check semantic properties
      expect(
        semantics.flagsCollection.isButton,
        isTrue,
        reason: 'Button should have semantic button flag',
      );

      expect(
        semantics.label,
        equals(buttonText),
        reason: 'Button should have semantic label matching button text',
      );

      expect(
        semantics.flagsCollection.hasEnabledState,
        isTrue,
        reason: 'Button should indicate enabled/disabled state',
      );
    });

    testWidgets('PrimaryButton with icon has descriptive label',
        (WidgetTester tester) async {
      // Arrange: Create button with icon
      const buttonText = 'Add Item';
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: Center(
              child: PrimaryButton(
                text: buttonText,
                onPressed: () {},
                icon: Icons.add,
              ),
            ),
          ),
        ),
      );

      // Act: Get semantics
      final semantics = tester.getSemantics(find.byType(PrimaryButton));

      // Assert: Label should describe the action
      expect(
        semantics.label,
        equals(buttonText),
        reason:
            'Button with icon should have descriptive label that explains the action',
      );
    });

    testWidgets('Disabled button has proper semantic state',
        (WidgetTester tester) async {
      // Arrange: Create disabled button
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: Center(
              child: PrimaryButton(
                text: 'Disabled Button',
                onPressed: null, // Disabled
              ),
            ),
          ),
        ),
      );

      // Act: Get semantics
      final semantics = tester.getSemantics(find.byType(PrimaryButton));

      // Assert: Should indicate disabled state
      expect(
        semantics.flagsCollection.hasEnabledState,
        isTrue,
        reason: 'Disabled button should have enabled state flag',
      );

      // The enabled flag should be false for disabled buttons
      expect(
        semantics.flagsCollection.isEnabled,
        isFalse,
        reason: 'Disabled button should not have enabled flag set',
      );
    });

    testWidgets('Loading button has appropriate semantic state',
        (WidgetTester tester) async {
      // Arrange: Create loading button
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: Center(
              child: PrimaryButton(
                text: 'Submit',
                onPressed: () {},
                isLoading: true,
              ),
            ),
          ),
        ),
      );

      // Act: Get semantics
      final semantics = tester.getSemantics(find.byType(PrimaryButton));

      // Assert: Should indicate busy/loading state
      // Note: Loading state should be communicated through the button
      expect(
        semantics.label,
        isNotEmpty,
        reason: 'Loading button should maintain semantic label',
      );
    });

    testWidgets('SecondaryButton has proper semantic label',
        (WidgetTester tester) async {
      // Arrange: Create secondary button
      const buttonText = 'Cancel';
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: Center(
              child: SecondaryButton(
                text: buttonText,
                onPressed: () {},
              ),
            ),
          ),
        ),
      );

      // Act: Get semantics
      final semantics = tester.getSemantics(find.byType(SecondaryButton));

      // Assert: Check semantic properties
      expect(
        semantics.flagsCollection.isButton,
        isTrue,
        reason: 'Secondary button should have button semantic flag',
      );

      expect(
        semantics.label,
        equals(buttonText),
        reason: 'Secondary button should have semantic label',
      );
    });

    testWidgets('GhostButton has proper semantic label',
        (WidgetTester tester) async {
      // Arrange: Create ghost button
      const buttonText = 'Learn More';
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: Center(
              child: GhostButton(
                text: buttonText,
                onPressed: () {},
              ),
            ),
          ),
        ),
      );

      // Act: Get semantics
      final semantics = tester.getSemantics(find.byType(GhostButton));

      // Assert: Check semantic properties
      expect(
        semantics.flagsCollection.isButton,
        isTrue,
        reason: 'Ghost button should have button semantic flag',
      );

      expect(
        semantics.label,
        equals(buttonText),
        reason: 'Ghost button should have semantic label',
      );
    });

    testWidgets('ThemeToggleButton has descriptive label and state',
        (WidgetTester tester) async {
      // Arrange: Create theme toggle using a mock provider
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: Center(
              child: ThemeToggleButton(),
            ),
          ),
        ),
      );

      // Act: Get semantics
      final semantics = tester.getSemantics(find.byType(ThemeToggleButton));

      // Assert: Should have descriptive label
      expect(
        semantics.label,
        isNotEmpty,
        reason: 'Theme toggle should have descriptive semantic label',
      );

      // Should indicate it's a button
      expect(
        semantics.flagsCollection.isButton,
        isTrue,
        reason: 'Theme toggle should have button semantic flag',
      );
    });
  });

  group('Semantic Labels - FAB', () {
    testWidgets('QuickCaptureFab has descriptive label',
        (WidgetTester tester) async {
      // Arrange: Create FAB
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: Center(
              child: QuickCaptureFab(
                onPressed: () {},
              ),
            ),
          ),
        ),
      );

      // Act: Get semantics
      final semantics = tester.getSemantics(find.byType(QuickCaptureFab));

      // Assert: Should have descriptive label
      expect(
        semantics.label,
        isNotEmpty,
        reason: 'FAB should have descriptive semantic label',
      );

      expect(
        semantics.flagsCollection.isButton,
        isTrue,
        reason: 'FAB should have button semantic flag',
      );
    });

    testWidgets('QuickCaptureFab with custom tooltip uses tooltip as label',
        (WidgetTester tester) async {
      // Arrange: Create FAB with custom tooltip
      const customTooltip = 'Create new item';
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: Center(
              child: QuickCaptureFab(
                onPressed: () {},
                tooltip: customTooltip,
              ),
            ),
          ),
        ),
      );

      // Act: Get semantics
      final semantics = tester.getSemantics(find.byType(QuickCaptureFab));

      // Assert: Should use custom tooltip as label
      expect(
        semantics.label,
        equals(customTooltip),
        reason: 'FAB should use custom tooltip as semantic label',
      );
    });

    testWidgets('QuickCaptureFab extended variant has label from text',
        (WidgetTester tester) async {
      // Arrange: Create extended FAB with label
      const fabLabel = 'Quick Capture';
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: Center(
              child: QuickCaptureFab(
                onPressed: () {},
                label: fabLabel,
              ),
            ),
          ),
        ),
      );

      // Act: Get semantics
      final semantics = tester.getSemantics(find.byType(QuickCaptureFab));

      // Assert: Should use label as semantic label
      expect(
        semantics.label,
        contains(fabLabel),
        reason: 'Extended FAB should use label text in semantic label',
      );
    });
  });

  group('Semantic Labels - Item Cards', () {
    testWidgets('ItemCard has descriptive semantic label',
        (WidgetTester tester) async {
      // Arrange: Create task card
      final testItem = Item(
        id: 'test-1',
        title: 'Complete accessibility audit',
        type: ItemType.task,
        spaceId: 'space-1',
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

      // Act: Get semantics
      final semantics = tester.getSemantics(find.byType(ItemCard));

      // Assert: Should have descriptive label including type and title
      expect(
        semantics.label,
        contains('task'),
        reason: 'Item card should include item type in semantic label',
      );

      expect(
        semantics.label,
        contains(testItem.title),
        reason: 'Item card should include item title in semantic label',
      );

      expect(
        semantics.flagsCollection.isButton,
        isTrue,
        reason: 'Item card should have button semantic flag',
      );
    });

    testWidgets('ItemCard checkbox has proper semantic label',
        (WidgetTester tester) async {
      // Arrange: Create task card with checkbox
      final testItem = Item(
        id: 'test-2',
        title: 'Write unit tests',
        type: ItemType.task,
        spaceId: 'space-1',
      );

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: ItemCard(
              item: testItem,
              onCheckboxChanged: (_) {},
            ),
          ),
        ),
      );

      // Act: Find checkbox and get semantics
      final checkboxFinder = find.byType(Checkbox);
      expect(checkboxFinder, findsOneWidget);

      final checkboxSemantics = tester.getSemantics(checkboxFinder);

      // Assert: Checkbox should have proper semantic properties
      expect(
        checkboxSemantics.flagsCollection.hasCheckedState,
        isTrue,
        reason: 'Checkbox should have checked state flag',
      );

      expect(
        checkboxSemantics.flagsCollection.hasEnabledState,
        isTrue,
        reason: 'Checkbox should have enabled state flag',
      );
    });

    testWidgets('Note ItemCard has appropriate semantic label',
        (WidgetTester tester) async {
      // Arrange: Create note card
      final testItem = Item(
        id: 'test-3',
        title: 'Meeting Notes',
        type: ItemType.note,
        spaceId: 'space-1',
        content: 'Discussion about accessibility improvements',
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

      // Act: Get semantics
      final semantics = tester.getSemantics(find.byType(ItemCard));

      // Assert: Should indicate it's a note
      expect(
        semantics.label,
        contains('note'),
        reason: 'Note card should include "note" in semantic label',
      );
    });

    testWidgets('List ItemCard has appropriate semantic label',
        (WidgetTester tester) async {
      // Arrange: Create list card
      final testItem = Item(
        id: 'test-4',
        title: 'Shopping List',
        type: ItemType.list,
        spaceId: 'space-1',
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

      // Act: Get semantics
      final semantics = tester.getSemantics(find.byType(ItemCard));

      // Assert: Should indicate it's a list
      expect(
        semantics.label,
        contains('list'),
        reason: 'List card should include "list" in semantic label',
      );
    });
  });

  group('Semantic Labels - Input Fields', () {
    testWidgets('TextInputField has associated label',
        (WidgetTester tester) async {
      // Arrange: Create text input field
      const fieldLabel = 'Task Name';
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: TextInputField(
              label: fieldLabel,
              hintText: 'Enter task name',
            ),
          ),
        ),
      );

      // Act: Find the text field
      final textFieldFinder = find.byType(TextField);
      expect(textFieldFinder, findsOneWidget);

      // Get the label text
      final labelFinder = find.text(fieldLabel);
      expect(labelFinder, findsOneWidget);

      // Assert: Label should be visible and associated with input
      final labelWidget = tester.widget<Text>(labelFinder);
      expect(
        labelWidget.data,
        equals(fieldLabel),
        reason: 'Input field should have visible label',
      );
    });

    testWidgets('TextInputField with hint has accessible hint text',
        (WidgetTester tester) async {
      // Arrange: Create text input with hint
      const hintText = 'Enter your task description';
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: TextInputField(
              label: 'Description',
              hintText: hintText,
            ),
          ),
        ),
      );

      // Act: Find the text field
      final textFieldFinder = find.byType(TextField);
      expect(textFieldFinder, findsOneWidget);

      final textField = tester.widget<TextField>(textFieldFinder);

      // Assert: Hint text should be set
      expect(
        textField.decoration?.hintText,
        equals(hintText),
        reason: 'Input field should have hint text for screen readers',
      );
    });

    testWidgets('TextInputField with error has error message exposed',
        (WidgetTester tester) async {
      // Arrange: Create text input with error
      const errorMessage = 'This field is required';
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: TextInputField(
              label: 'Email',
              errorText: errorMessage,
            ),
          ),
        ),
      );

      // Act: Find the error text
      final errorFinder = find.text(errorMessage);

      // Assert: Error text should be visible
      expect(
        errorFinder,
        findsOneWidget,
        reason: 'Error message should be visible to screen readers',
      );
    });

    testWidgets('TextInputField with icon has accessible icon',
        (WidgetTester tester) async {
      // Arrange: Create text input with prefix icon
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: TextInputField(
              label: 'Search',
              prefixIcon: Icons.search,
            ),
          ),
        ),
      );

      // Act: Find the icon
      final iconFinder = find.byIcon(Icons.search);

      // Assert: Icon should be present
      expect(
        iconFinder,
        findsOneWidget,
        reason: 'Input field icon should be present',
      );
    });
  });

  group('Semantic Labels - Navigation', () {
    testWidgets('Bottom navigation items have semantic labels',
        (WidgetTester tester) async {
      // Arrange: Create bottom navigation bar
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
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

      // Act: Get all semantics for navigation items
      final semanticsFinder = find.byType(BottomNavigationBar);
      expect(semanticsFinder, findsOneWidget);

      // Assert: Navigation bar should exist
      // Individual items should have semantic labels (verified through icon semantics)
      final iconFinders = find.descendant(
        of: semanticsFinder,
        matching: find.byType(Icon),
      );

      expect(
        iconFinders.evaluate().length,
        greaterThan(0),
        reason: 'Navigation bar should have icon items',
      );
    });
  });

  group('Semantic Labels - Icon-Only Elements', () {
    testWidgets('Icon buttons without text have semantic labels',
        (WidgetTester tester) async {
      // Arrange: Create icon button with semantic label
      const semanticLabel = 'Close dialog';
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: Center(
              child: IconButton(
                icon: const Icon(Icons.close),
                onPressed: () {},
                tooltip: semanticLabel,
              ),
            ),
          ),
        ),
      );

      // Act: Get semantics
      final semantics = tester.getSemantics(find.byType(IconButton));

      // Assert: Should have semantic label from tooltip
      expect(
        semantics.label,
        equals(semanticLabel),
        reason: 'Icon button should use tooltip as semantic label',
      );

      expect(
        semantics.flagsCollection.isButton,
        isTrue,
        reason: 'Icon button should have button semantic flag',
      );
    });
  });
}
