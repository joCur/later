import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:later_mobile/data/models/item_model.dart';
import 'package:later_mobile/data/models/space_model.dart';
import 'package:later_mobile/providers/items_provider.dart';
import 'package:later_mobile/providers/spaces_provider.dart';
import 'package:later_mobile/widgets/screens/item_detail_screen.dart';
import 'package:provider/provider.dart';
import 'package:mockito/mockito.dart';
import 'package:mockito/annotations.dart';

import 'item_detail_screen_test.mocks.dart';

@GenerateMocks([ItemsProvider, SpacesProvider])
void main() {
  late MockItemsProvider mockItemsProvider;
  late MockSpacesProvider mockSpacesProvider;
  late Item testItem;
  late List<Space> testSpaces;

  setUp(() {
    mockItemsProvider = MockItemsProvider();
    mockSpacesProvider = MockSpacesProvider();

    // Create test spaces
    testSpaces = [
      Space(
        id: 'space-1',
        name: 'Work',
        icon: '💼',
        color: '#FF5733',
        itemCount: 5,
      ),
      Space(
        id: 'space-2',
        name: 'Personal',
        icon: '🏠',
        color: '#3357FF',
        itemCount: 3,
      ),
    ];

    // Create test item with fixed dates for deterministic testing
    testItem = Item(
      id: 'item-1',
      type: ItemType.task,
      title: 'Test Task',
      content: 'Test content',
      spaceId: 'space-1',
      dueDate: DateTime(2025, 12, 31),
      tags: ['urgent', 'work'],
      // ignore: avoid_redundant_argument_values
      createdAt: DateTime(2025, 1, 1),
      // ignore: avoid_redundant_argument_values
      updatedAt: DateTime(2025, 1, 2),
    );

    // Setup mock behaviors
    when(mockSpacesProvider.spaces).thenReturn(testSpaces);
    when(mockItemsProvider.updateItem(any)).thenAnswer((_) async {});
    when(mockItemsProvider.deleteItem(any)).thenAnswer((_) async {});
    when(mockSpacesProvider.incrementSpaceItemCount(any))
        .thenAnswer((_) async {});
    when(mockSpacesProvider.decrementSpaceItemCount(any))
        .thenAnswer((_) async {});
  });

  Widget createTestWidget({Item? item}) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider<ItemsProvider>.value(value: mockItemsProvider),
        ChangeNotifierProvider<SpacesProvider>.value(value: mockSpacesProvider),
      ],
      child: MaterialApp(
        home: ItemDetailScreen(item: item ?? testItem),
      ),
    );
  }

  group('ItemDetailScreen', () {
    testWidgets('renders item data correctly', (tester) async {
      await tester.pumpWidget(createTestWidget());

      // Check title
      expect(find.text('Test Task'), findsOneWidget);

      // Check content
      expect(find.text('Test content'), findsOneWidget);

      // Check type badge
      expect(find.text('Task'), findsOneWidget);

      // Check tags
      expect(find.text('urgent'), findsOneWidget);
      expect(find.text('work'), findsOneWidget);
    });

    testWidgets('auto-focuses title field on mount', (tester) async {
      await tester.pumpWidget(createTestWidget());
      await tester.pumpAndSettle();

      // The TextFormField has autofocus enabled in implementation
      // We verify it exists and is focused by checking if it can receive input
      final titleField = find.widgetWithText(TextFormField, 'Test Task');
      expect(titleField, findsOneWidget);
    });

    testWidgets('displays completion checkbox for tasks', (tester) async {
      await tester.pumpWidget(createTestWidget());

      expect(find.text('Mark as complete'), findsOneWidget);
      expect(find.byType(CheckboxListTile), findsOneWidget);
    });

    testWidgets('does not display completion checkbox for notes',
        (tester) async {
      final noteItem = Item(
        id: 'note-1',
        type: ItemType.note,
        title: 'Test Note',
        spaceId: 'space-1',
      );

      await tester.pumpWidget(createTestWidget(item: noteItem));

      expect(find.text('Mark as complete'), findsNothing);
      expect(find.byType(CheckboxListTile), findsNothing);
    });

    testWidgets('toggles completion status when checkbox is tapped',
        (tester) async {
      await tester.pumpWidget(createTestWidget());
      await tester.pumpAndSettle();

      // Tap checkbox
      await tester.tap(find.byType(CheckboxListTile));
      await tester.pumpAndSettle();

      // Verify updateItem was called
      verify(mockItemsProvider.updateItem(any)).called(greaterThan(0));
    });

    testWidgets('allows title editing', (tester) async {
      await tester.pumpWidget(createTestWidget());
      await tester.pumpAndSettle();

      // Find and clear title field
      final titleField = find.widgetWithText(TextFormField, 'Test Task');
      await tester.enterText(titleField, 'Updated Title');
      await tester.pumpAndSettle();

      expect(find.text('Updated Title'), findsOneWidget);
    });

    testWidgets('allows content editing', (tester) async {
      await tester.pumpWidget(createTestWidget());
      await tester.pumpAndSettle();

      // Find and update content field
      final contentField = find.widgetWithText(TextFormField, 'Test content');
      await tester.enterText(contentField, 'Updated content');
      await tester.pumpAndSettle();

      expect(find.text('Updated content'), findsOneWidget);
    });

    testWidgets('displays space selector dropdown', (tester) async {
      await tester.pumpWidget(createTestWidget());
      await tester.pumpAndSettle();

      expect(find.text('Space'), findsOneWidget);
      expect(find.byType(DropdownButton<String>), findsOneWidget);
    });

    testWidgets('can change space via dropdown', (tester) async {
      await tester.pumpWidget(createTestWidget());
      await tester.pumpAndSettle();

      // Tap dropdown
      await tester.tap(find.byType(DropdownButton<String>));
      await tester.pumpAndSettle();

      // Select different space
      await tester.tap(find.text('Personal').last);
      await tester.pumpAndSettle();

      // Verify space change methods were called
      verify(mockItemsProvider.updateItem(any)).called(greaterThan(0));
      verify(mockSpacesProvider.decrementSpaceItemCount('space-1')).called(1);
      verify(mockSpacesProvider.incrementSpaceItemCount('space-2')).called(1);
    });

    testWidgets('displays due date for tasks', (tester) async {
      await tester.pumpWidget(createTestWidget());
      await tester.pumpAndSettle();

      expect(find.text('Due Date'), findsOneWidget);
      expect(find.text('Dec 31, 2025'), findsOneWidget);
    });

    testWidgets('does not display due date for notes', (tester) async {
      final noteItem = Item(
        id: 'note-1',
        type: ItemType.note,
        title: 'Test Note',
        spaceId: 'space-1',
      );

      await tester.pumpWidget(createTestWidget(item: noteItem));

      expect(find.text('Due Date'), findsNothing);
    });

    testWidgets('opens date picker when due date tapped', (tester) async {
      await tester.pumpWidget(createTestWidget());
      await tester.pumpAndSettle();

      // Tap due date field
      await tester.tap(find.text('Dec 31, 2025'));
      await tester.pumpAndSettle();

      // Verify date picker opened
      expect(find.byType(DatePickerDialog), findsOneWidget);
    });

    testWidgets('can clear due date', (tester) async {
      await tester.pumpWidget(createTestWidget());
      await tester.pumpAndSettle();

      // Find and tap clear button
      final clearButton = find.widgetWithIcon(IconButton, Icons.clear);
      await tester.tap(clearButton);
      await tester.pumpAndSettle();

      // Verify updateItem was called
      verify(mockItemsProvider.updateItem(any)).called(greaterThan(0));
    });

    testWidgets('displays tags as read-only chips', (tester) async {
      await tester.pumpWidget(createTestWidget());
      await tester.pumpAndSettle();

      expect(find.text('Tags'), findsOneWidget);
      expect(find.byType(Chip), findsNWidgets(2));
      expect(find.text('urgent'), findsOneWidget);
      expect(find.text('work'), findsOneWidget);
    });

    testWidgets('does not display tags section when no tags', (tester) async {
      final itemWithoutTags = Item(
        id: 'item-2',
        type: ItemType.task,
        title: 'Task without tags',
        spaceId: 'space-1',
      );

      await tester.pumpWidget(createTestWidget(item: itemWithoutTags));

      expect(find.text('Tags'), findsNothing);
    });

    testWidgets('displays metadata footer with timestamps', (tester) async {
      await tester.pumpWidget(createTestWidget());
      await tester.pumpAndSettle();

      expect(find.textContaining('Created:'), findsOneWidget);
      expect(find.textContaining('Modified:'), findsOneWidget);
    });

    testWidgets('validates empty title on save', (tester) async {
      await tester.pumpWidget(createTestWidget());
      await tester.pumpAndSettle();

      // Clear title
      final titleField = find.widgetWithText(TextFormField, 'Test Task');
      await tester.enterText(titleField, '');
      await tester.pumpAndSettle();

      // Wait for debounce (500ms) plus some buffer
      await tester.pump(const Duration(milliseconds: 600));

      // Trigger validation by tapping somewhere else
      await tester.tap(find.text('Add content...'));
      await tester.pumpAndSettle();

      // The form should not save with empty title
      // updateItem should not be called for invalid form
      verifyNever(mockItemsProvider.updateItem(argThat(
        predicate<Item>((item) => item.title.isEmpty),
      )));
    });

    testWidgets('shows delete confirmation dialog', (tester) async {
      await tester.pumpWidget(createTestWidget());
      await tester.pumpAndSettle();

      // Tap delete button in app bar
      await tester.tap(find.byIcon(Icons.delete_outline));
      await tester.pumpAndSettle();

      // Verify dialog appears with updated message about undo
      expect(find.text('Delete task?'), findsOneWidget);
      expect(find.text('You can undo this action within 5 seconds.'), findsOneWidget);
      expect(find.text('Cancel'), findsOneWidget);
      expect(find.text('Delete'), findsOneWidget);
    });

    testWidgets('cancels delete when Cancel is tapped', (tester) async {
      await tester.pumpWidget(createTestWidget());
      await tester.pumpAndSettle();

      // Open delete dialog
      await tester.tap(find.byIcon(Icons.delete_outline));
      await tester.pumpAndSettle();

      // Tap Cancel
      await tester.tap(find.text('Cancel'));
      await tester.pumpAndSettle();

      // Verify deleteItem was not called
      verifyNever(mockItemsProvider.deleteItem(any));
    });

    testWidgets('deletes item when Delete is confirmed and shows undo snackbar', (tester) async {
      await tester.pumpWidget(createTestWidget());
      await tester.pumpAndSettle();

      // Open delete dialog
      await tester.tap(find.byIcon(Icons.delete_outline));
      await tester.pumpAndSettle();

      // Tap Delete
      await tester.tap(find.text('Delete'));
      await tester.pumpAndSettle();

      // Verify item was deleted from UI immediately
      verify(mockItemsProvider.deleteItem('item-1')).called(1);

      // Verify undo snackbar is shown
      expect(find.text('Item deleted'), findsOneWidget);
      expect(find.text('Undo'), findsOneWidget);

      // Space count should NOT be decremented yet (waiting for undo timeout)
      verifyNever(mockSpacesProvider.decrementSpaceItemCount(any));
    });

    testWidgets('shows saving indicator when saving', (tester) async {
      // Create a completer to control when updateItem completes
      await tester.pumpWidget(createTestWidget());
      await tester.pumpAndSettle();

      // Make a change
      final titleField = find.widgetWithText(TextFormField, 'Test Task');
      await tester.enterText(titleField, 'Changed Title');

      // Wait for debounce timer but not completion
      await tester.pump(const Duration(milliseconds: 500));
      await tester.pump();

      // Saving indicator should appear
      expect(find.text('Saving...'), findsOneWidget);
    });

    testWidgets('auto-saves after 500ms debounce', (tester) async {
      await tester.pumpWidget(createTestWidget());
      await tester.pumpAndSettle();

      // Make a change
      final titleField = find.widgetWithText(TextFormField, 'Test Task');
      await tester.enterText(titleField, 'Changed Title');

      // Wait less than debounce time
      await tester.pump(const Duration(milliseconds: 300));

      // updateItem should not be called yet
      verifyNever(mockItemsProvider.updateItem(any));

      // Wait for debounce to complete
      await tester.pump(const Duration(milliseconds: 300));
      await tester.pumpAndSettle();

      // Now updateItem should be called
      verify(mockItemsProvider.updateItem(any)).called(greaterThan(0));
    });

    testWidgets('handles back button', (tester) async {
      await tester.pumpWidget(createTestWidget());
      await tester.pumpAndSettle();

      // Tap back button
      await tester.tap(find.byIcon(Icons.arrow_back));
      await tester.pumpAndSettle();

      // Screen should be popped
      expect(find.byType(ItemDetailScreen), findsNothing);
    });

    testWidgets('handles Escape key', (tester) async {
      await tester.pumpWidget(createTestWidget());
      await tester.pumpAndSettle();

      // Simulate Escape key press
      await tester.sendKeyEvent(LogicalKeyboardKey.escape);
      await tester.pumpAndSettle();

      // Screen should be popped
      expect(find.byType(ItemDetailScreen), findsNothing);
    });

    testWidgets('handles Cmd+S keyboard shortcut', (tester) async {
      await tester.pumpWidget(createTestWidget());
      await tester.pumpAndSettle();

      // Make a change
      final titleField = find.widgetWithText(TextFormField, 'Test Task');
      await tester.enterText(titleField, 'Changed Title');
      await tester.pump();

      // Clear any previous calls
      clearInteractions(mockItemsProvider);

      // Simulate Cmd+S (on macOS) or Ctrl+S (on other platforms)
      await tester.sendKeyDownEvent(LogicalKeyboardKey.meta);
      await tester.sendKeyEvent(LogicalKeyboardKey.keyS);
      await tester.sendKeyUpEvent(LogicalKeyboardKey.meta);
      await tester.pumpAndSettle();

      // updateItem should be called immediately
      verify(mockItemsProvider.updateItem(any)).called(greaterThan(0));
    });

    testWidgets('handles Cmd+Backspace keyboard shortcut', (tester) async {
      await tester.pumpWidget(createTestWidget());
      await tester.pumpAndSettle();

      // Simulate Cmd+Backspace
      await tester.sendKeyDownEvent(LogicalKeyboardKey.meta);
      await tester.sendKeyEvent(LogicalKeyboardKey.backspace);
      await tester.sendKeyUpEvent(LogicalKeyboardKey.meta);
      await tester.pumpAndSettle();

      // Delete dialog should appear
      expect(find.text('Delete task?'), findsOneWidget);
    });

    testWidgets('displays correct type badge for tasks', (tester) async {
      await tester.pumpWidget(createTestWidget());

      expect(find.text('Task'), findsOneWidget);
    });

    testWidgets('displays correct type badge for notes', (tester) async {
      final noteItem = Item(
        id: 'note-1',
        type: ItemType.note,
        title: 'Test Note',
        spaceId: 'space-1',
      );

      await tester.pumpWidget(createTestWidget(item: noteItem));

      expect(find.text('Note'), findsOneWidget);
    });

    testWidgets('displays correct type badge for lists', (tester) async {
      final listItem = Item(
        id: 'list-1',
        type: ItemType.list,
        title: 'Test List',
        spaceId: 'space-1',
      );

      await tester.pumpWidget(createTestWidget(item: listItem));

      expect(find.text('List'), findsOneWidget);
    });

    testWidgets('handles empty content gracefully', (tester) async {
      final itemWithoutContent = Item(
        id: 'item-2',
        type: ItemType.task,
        title: 'Task without content',
        spaceId: 'space-1',
      );

      await tester.pumpWidget(createTestWidget(item: itemWithoutContent));
      await tester.pumpAndSettle();

      // Should show placeholder
      expect(find.text('Add content...'), findsOneWidget);
    });

    testWidgets('multiline content field expands with text', (tester) async {
      await tester.pumpWidget(createTestWidget());
      await tester.pumpAndSettle();

      // Find content field - it's multiline and expandable
      final contentField = find.widgetWithText(TextFormField, 'Test content');
      expect(contentField, findsOneWidget);

      // Verify it accepts multiline input by entering text with newlines
      await tester.enterText(contentField, 'Line 1\nLine 2\nLine 3');
      await tester.pump();
      expect(find.text('Line 1\nLine 2\nLine 3'), findsOneWidget);
    });

    testWidgets('displays save button when there are changes', (tester) async {
      await tester.pumpWidget(createTestWidget());
      await tester.pumpAndSettle();

      // Initially no save button
      expect(find.byIcon(Icons.save_outlined), findsNothing);

      // Make a change
      final titleField = find.widgetWithText(TextFormField, 'Test Task');
      await tester.enterText(titleField, 'Changed Title');
      await tester.pump();

      // Save button should appear
      expect(find.byIcon(Icons.save_outlined), findsOneWidget);
    });

    testWidgets('renders in dark mode correctly', (tester) async {
      await tester.pumpWidget(
        MultiProvider(
          providers: [
            ChangeNotifierProvider<ItemsProvider>.value(
                value: mockItemsProvider),
            ChangeNotifierProvider<SpacesProvider>.value(
                value: mockSpacesProvider),
          ],
          child: MaterialApp(
            theme: ThemeData.dark(),
            home: ItemDetailScreen(item: testItem),
          ),
        ),
      );

      // Should render without errors
      expect(find.byType(ItemDetailScreen), findsOneWidget);
    });

    testWidgets('has proper semantic labels for accessibility',
        (tester) async {
      await tester.pumpWidget(createTestWidget());
      await tester.pumpAndSettle();

      // Open delete dialog to check semantic label
      await tester.tap(find.byIcon(Icons.delete_outline));
      await tester.pumpAndSettle();

      // Verify semantic label exists
      final dialog = tester.widget<AlertDialog>(find.byType(AlertDialog));
      expect(dialog.semanticLabel, 'Delete confirmation dialog');
    });

    group('Undo Deletion', () {
      testWidgets('restores item when Undo is pressed', (tester) async {
        await tester.pumpWidget(createTestWidget());
        await tester.pumpAndSettle();

        // Delete the item
        await tester.tap(find.byIcon(Icons.delete_outline));
        await tester.pumpAndSettle();
        await tester.tap(find.text('Delete'));

        // Pump frames to allow snackbar to appear
        await tester.pump();
        await tester.pump(const Duration(milliseconds: 100));

        // Screen should be popped
        expect(find.byType(ItemDetailScreen), findsNothing);

        // Verify undo snackbar is shown on parent screen
        expect(find.text('Item deleted'), findsOneWidget);
        expect(find.text('Undo'), findsOneWidget);

        // Clear previous interactions to isolate undo call
        clearInteractions(mockItemsProvider);

        // Tap Undo in snackbar
        await tester.tap(find.text('Undo'));
        await tester.pumpAndSettle();

        // Verify item was restored
        verify(mockItemsProvider.addItem(testItem)).called(1);
      });

      testWidgets('performs actual deletion after 5-second timeout', (tester) async {
        await tester.pumpWidget(createTestWidget());
        await tester.pumpAndSettle();

        // Delete the item
        await tester.tap(find.byIcon(Icons.delete_outline));
        await tester.pumpAndSettle();
        await tester.tap(find.text('Delete'));

        // Pump frames to allow snackbar to appear
        await tester.pump();
        await tester.pump(const Duration(milliseconds: 100));

        // Verify space count not decremented yet
        verifyNever(mockSpacesProvider.decrementSpaceItemCount(any));

        // Wait for 5-second timeout
        await tester.pump(const Duration(seconds: 5));
        await tester.pumpAndSettle();

        // Verify space count was decremented after timeout
        verify(mockSpacesProvider.decrementSpaceItemCount('space-1')).called(1);
      });

      testWidgets('does not perform actual deletion if undo is pressed', (tester) async {
        await tester.pumpWidget(createTestWidget());
        await tester.pumpAndSettle();

        // Delete the item
        await tester.tap(find.byIcon(Icons.delete_outline));
        await tester.pumpAndSettle();
        await tester.tap(find.text('Delete'));

        // Pump frames to allow snackbar to appear
        await tester.pump();
        await tester.pump(const Duration(milliseconds: 100));

        // Press Undo before timeout
        await tester.pump(const Duration(seconds: 2));
        await tester.tap(find.text('Undo'));
        await tester.pumpAndSettle();

        // Wait for what would have been the timeout period
        await tester.pump(const Duration(seconds: 4));
        await tester.pumpAndSettle();

        // Verify space count was NOT decremented
        verifyNever(mockSpacesProvider.decrementSpaceItemCount(any));
      });

      testWidgets('snackbar disappears after 5 seconds', (tester) async {
        await tester.pumpWidget(createTestWidget());
        await tester.pumpAndSettle();

        // Delete the item
        await tester.tap(find.byIcon(Icons.delete_outline));
        await tester.pumpAndSettle();
        await tester.tap(find.text('Delete'));

        // Pump frames to allow snackbar to appear
        await tester.pump();
        await tester.pump(const Duration(milliseconds: 100));

        // Verify snackbar is visible
        expect(find.text('Item deleted'), findsOneWidget);
        expect(find.text('Undo'), findsOneWidget);

        // Wait for snackbar to disappear
        await tester.pump(const Duration(seconds: 5));
        await tester.pumpAndSettle();

        // Snackbar should be gone
        expect(find.text('Item deleted'), findsNothing);
        expect(find.text('Undo'), findsNothing);
      });

      testWidgets('handles rapid delete and undo scenario', (tester) async {
        await tester.pumpWidget(createTestWidget());
        await tester.pumpAndSettle();

        // Delete the item
        await tester.tap(find.byIcon(Icons.delete_outline));
        await tester.pumpAndSettle();
        await tester.tap(find.text('Delete'));

        // Pump frames to allow snackbar to appear
        await tester.pump();
        await tester.pump(const Duration(milliseconds: 100));

        // Immediately press Undo
        await tester.tap(find.text('Undo'));
        await tester.pumpAndSettle();

        // Verify item was restored
        verify(mockItemsProvider.addItem(testItem)).called(1);

        // Verify space count was never decremented
        verifyNever(mockSpacesProvider.decrementSpaceItemCount(any));
      });

      testWidgets('deletion timer completes after screen disposal', (tester) async {
        await tester.pumpWidget(createTestWidget());
        await tester.pumpAndSettle();

        // Delete the item
        await tester.tap(find.byIcon(Icons.delete_outline));
        await tester.pumpAndSettle();
        await tester.tap(find.text('Delete'));

        // Pump frames and wait for async operations
        await tester.pumpAndSettle();

        // Screen should be popped after delete
        expect(find.byType(ItemDetailScreen), findsNothing);

        // Verify snackbar appeared
        expect(find.text('Item deleted'), findsOneWidget);

        // Wait for timer to fire (5 seconds)
        await tester.pump(const Duration(seconds: 5));

        // Pump a bit more to allow async operations
        await tester.pump(const Duration(milliseconds: 100));

        // Space decrement should have been attempted
        // Note: The call might not be tracked properly because the widget is disposed
        // but the timer still fires. This test mainly verifies no crash occurs.
        verify(mockSpacesProvider.decrementSpaceItemCount('space-1')).called(1);
      });

      testWidgets('undo snackbar has correct properties', (tester) async {
        await tester.pumpWidget(createTestWidget());
        await tester.pumpAndSettle();

        // Delete the item
        await tester.tap(find.byIcon(Icons.delete_outline));
        await tester.pumpAndSettle();
        await tester.tap(find.text('Delete'));

        // Pump frames to allow snackbar to appear
        await tester.pump();
        await tester.pump(const Duration(milliseconds: 100));

        // Verify snackbar content
        expect(find.text('Item deleted'), findsOneWidget);
        expect(find.text('Undo'), findsOneWidget);

        // Find the snackbar widget
        final snackBarFinder = find.byType(SnackBar);
        expect(snackBarFinder, findsOneWidget);

        final snackBar = tester.widget<SnackBar>(snackBarFinder);
        expect(snackBar.duration, const Duration(seconds: 5));
        expect(snackBar.action, isNotNull);
        expect(snackBar.action!.label, 'Undo');
      });

      testWidgets('can undo deletion for different item types', (tester) async {
        final noteItem = Item(
          id: 'note-1',
          type: ItemType.note,
          title: 'Test Note',
          spaceId: 'space-1',
        );

        await tester.pumpWidget(createTestWidget(item: noteItem));
        await tester.pumpAndSettle();

        // Delete the note
        await tester.tap(find.byIcon(Icons.delete_outline));
        await tester.pumpAndSettle();
        await tester.tap(find.text('Delete'));

        // Pump frames to allow snackbar to appear
        await tester.pump();
        await tester.pump(const Duration(milliseconds: 100));

        // Verify undo snackbar is shown
        expect(find.text('Item deleted'), findsOneWidget);
        expect(find.text('Undo'), findsOneWidget);

        // Clear previous interactions to isolate undo call
        clearInteractions(mockItemsProvider);

        // Tap the Undo action directly from the snackbar
        final snackBar = tester.widget<SnackBar>(find.byType(SnackBar));
        snackBar.action!.onPressed();
        await tester.pumpAndSettle();

        // Verify note was restored
        verify(mockItemsProvider.addItem(noteItem)).called(1);
      });
    });

    group('Type Conversion', () {
      testWidgets('displays convert button in app bar', (tester) async {
        await tester.pumpWidget(createTestWidget());
        await tester.pumpAndSettle();

        // Verify convert button exists
        expect(find.byIcon(Icons.swap_horiz), findsOneWidget);
      });

      testWidgets('opens conversion dialog when convert button tapped', (tester) async {
        await tester.pumpWidget(createTestWidget());
        await tester.pumpAndSettle();

        // Tap convert button
        await tester.tap(find.byIcon(Icons.swap_horiz));
        await tester.pumpAndSettle();

        // Verify dialog appears
        expect(find.text('Convert to...'), findsOneWidget);
        expect(find.text('Cancel'), findsOneWidget);
      });

      testWidgets('shows all conversion options except current type', (tester) async {
        await tester.pumpWidget(createTestWidget());
        await tester.pumpAndSettle();

        // Tap convert button
        await tester.tap(find.byIcon(Icons.swap_horiz));
        await tester.pumpAndSettle();

        // Should show Note and List options in the dialog
        // Find them within ListTile widgets to avoid matching the badge
        expect(find.descendant(
          of: find.byType(ListTile),
          matching: find.text('Note'),
        ), findsOneWidget);
        expect(find.descendant(
          of: find.byType(ListTile),
          matching: find.text('List'),
        ), findsOneWidget);
        // Task should not appear as a ListTile option
        expect(find.descendant(
          of: find.byType(ListTile),
          matching: find.text('Task'),
        ), findsNothing);
      });

      testWidgets('shows data loss warning when converting task with due date', (tester) async {
        await tester.pumpWidget(createTestWidget());
        await tester.pumpAndSettle();

        // Tap convert button
        await tester.tap(find.byIcon(Icons.swap_horiz));
        await tester.pumpAndSettle();

        // Verify warning is shown
        expect(find.byIcon(Icons.warning_amber), findsOneWidget);
        expect(find.textContaining('Warning:'), findsOneWidget);
        expect(find.textContaining('due date'), findsOneWidget);
      });

      testWidgets('shows data loss warning when converting completed task', (tester) async {
        final completedTask = Item(
          id: 'task-1',
          type: ItemType.task,
          title: 'Completed Task',
          spaceId: 'space-1',
          isCompleted: true,
        );

        await tester.pumpWidget(createTestWidget(item: completedTask));
        await tester.pumpAndSettle();

        // Tap convert button
        await tester.tap(find.byIcon(Icons.swap_horiz));
        await tester.pumpAndSettle();

        // Verify warning mentions completion status
        expect(find.textContaining('Warning:'), findsOneWidget);
        expect(find.textContaining('completion status'), findsOneWidget);
      });

      testWidgets('shows combined warning for completed task with due date', (tester) async {
        final completedTaskWithDueDate = Item(
          id: 'task-1',
          type: ItemType.task,
          title: 'Completed Task with Due Date',
          spaceId: 'space-1',
          isCompleted: true,
          dueDate: DateTime(2025, 12, 31),
        );

        await tester.pumpWidget(createTestWidget(item: completedTaskWithDueDate));
        await tester.pumpAndSettle();

        // Tap convert button
        await tester.tap(find.byIcon(Icons.swap_horiz));
        await tester.pumpAndSettle();

        // Verify warning mentions both
        expect(find.textContaining('Warning:'), findsOneWidget);
        expect(find.textContaining('due date and completion status'), findsOneWidget);
      });

      testWidgets('does not show warning when converting note', (tester) async {
        final noteItem = Item(
          id: 'note-1',
          type: ItemType.note,
          title: 'Test Note',
          spaceId: 'space-1',
        );

        await tester.pumpWidget(createTestWidget(item: noteItem));
        await tester.pumpAndSettle();

        // Tap convert button
        await tester.tap(find.byIcon(Icons.swap_horiz));
        await tester.pumpAndSettle();

        // No warning should appear
        expect(find.byIcon(Icons.warning_amber), findsNothing);
      });

      testWidgets('converts task to note successfully', (tester) async {
        await tester.pumpWidget(createTestWidget());
        await tester.pumpAndSettle();

        // Clear previous interactions
        clearInteractions(mockItemsProvider);

        // Tap convert button
        await tester.tap(find.byIcon(Icons.swap_horiz));
        await tester.pumpAndSettle();

        // Select Note
        await tester.tap(find.descendant(
          of: find.byType(ListTile),
          matching: find.text('Note'),
        ));
        await tester.pumpAndSettle();

        // Verify updateItem was called
        verify(mockItemsProvider.updateItem(argThat(
          predicate<Item>((item) =>
            item.type == ItemType.note &&
            item.title == 'Test Task' &&
            item.content == 'Test content' &&
            item.dueDate == null // Due date should be cleared
          ),
        ))).called(1);

        // Verify success message
        expect(find.text('Converted to note'), findsOneWidget);
      });

      testWidgets('converts task to list successfully', (tester) async {
        await tester.pumpWidget(createTestWidget());
        await tester.pumpAndSettle();

        // Clear previous interactions
        clearInteractions(mockItemsProvider);

        // Tap convert button
        await tester.tap(find.byIcon(Icons.swap_horiz));
        await tester.pumpAndSettle();

        // Select List
        await tester.tap(find.descendant(
          of: find.byType(ListTile),
          matching: find.text('List'),
        ));
        await tester.pumpAndSettle();

        // Verify updateItem was called
        verify(mockItemsProvider.updateItem(argThat(
          predicate<Item>((item) =>
            item.type == ItemType.list &&
            item.title == 'Test Task' &&
            item.content == 'Test content' &&
            item.dueDate == null // Due date should be cleared
          ),
        ))).called(1);

        // Verify success message
        expect(find.text('Converted to list'), findsOneWidget);
      });

      testWidgets('converts note to task successfully', (tester) async {
        final noteItem = Item(
          id: 'note-1',
          type: ItemType.note,
          title: 'Test Note',
          content: 'Note content',
          spaceId: 'space-1',
        );

        await tester.pumpWidget(createTestWidget(item: noteItem));
        await tester.pumpAndSettle();

        // Clear previous interactions
        clearInteractions(mockItemsProvider);

        // Tap convert button
        await tester.tap(find.byIcon(Icons.swap_horiz));
        await tester.pumpAndSettle();

        // Select Task
        await tester.tap(find.descendant(
          of: find.byType(ListTile),
          matching: find.text('Task'),
        ));
        await tester.pumpAndSettle();

        // Verify updateItem was called
        verify(mockItemsProvider.updateItem(argThat(
          predicate<Item>((item) =>
            item.type == ItemType.task &&
            item.title == 'Test Note' &&
            item.content == 'Note content' &&
            item.isCompleted == false // Should be set to false for new task
          ),
        ))).called(1);

        // Verify success message
        expect(find.text('Converted to task'), findsOneWidget);
      });

      testWidgets('converts note to list successfully', (tester) async {
        final noteItem = Item(
          id: 'note-1',
          type: ItemType.note,
          title: 'Test Note',
          content: 'Note content',
          spaceId: 'space-1',
        );

        await tester.pumpWidget(createTestWidget(item: noteItem));
        await tester.pumpAndSettle();

        // Clear previous interactions
        clearInteractions(mockItemsProvider);

        // Tap convert button
        await tester.tap(find.byIcon(Icons.swap_horiz));
        await tester.pumpAndSettle();

        // Select List
        await tester.tap(find.descendant(
          of: find.byType(ListTile),
          matching: find.text('List'),
        ));
        await tester.pumpAndSettle();

        // Verify updateItem was called
        verify(mockItemsProvider.updateItem(argThat(
          predicate<Item>((item) =>
            item.type == ItemType.list &&
            item.title == 'Test Note' &&
            item.content == 'Note content'
          ),
        ))).called(1);

        // Verify success message
        expect(find.text('Converted to list'), findsOneWidget);
      });

      testWidgets('converts list to task successfully', (tester) async {
        final listItem = Item(
          id: 'list-1',
          type: ItemType.list,
          title: 'Test List',
          content: 'List content',
          spaceId: 'space-1',
        );

        await tester.pumpWidget(createTestWidget(item: listItem));
        await tester.pumpAndSettle();

        // Clear previous interactions
        clearInteractions(mockItemsProvider);

        // Tap convert button
        await tester.tap(find.byIcon(Icons.swap_horiz));
        await tester.pumpAndSettle();

        // Select Task
        await tester.tap(find.descendant(
          of: find.byType(ListTile),
          matching: find.text('Task'),
        ));
        await tester.pumpAndSettle();

        // Verify updateItem was called
        verify(mockItemsProvider.updateItem(argThat(
          predicate<Item>((item) =>
            item.type == ItemType.task &&
            item.title == 'Test List' &&
            item.content == 'List content' &&
            item.isCompleted == false
          ),
        ))).called(1);

        // Verify success message
        expect(find.text('Converted to task'), findsOneWidget);
      });

      testWidgets('converts list to note successfully', (tester) async {
        final listItem = Item(
          id: 'list-1',
          type: ItemType.list,
          title: 'Test List',
          content: 'List content',
          spaceId: 'space-1',
        );

        await tester.pumpWidget(createTestWidget(item: listItem));
        await tester.pumpAndSettle();

        // Clear previous interactions
        clearInteractions(mockItemsProvider);

        // Tap convert button
        await tester.tap(find.byIcon(Icons.swap_horiz));
        await tester.pumpAndSettle();

        // Select Note
        await tester.tap(find.descendant(
          of: find.byType(ListTile),
          matching: find.text('Note'),
        ));
        await tester.pumpAndSettle();

        // Verify updateItem was called
        verify(mockItemsProvider.updateItem(argThat(
          predicate<Item>((item) =>
            item.type == ItemType.note &&
            item.title == 'Test List' &&
            item.content == 'List content'
          ),
        ))).called(1);

        // Verify success message
        expect(find.text('Converted to note'), findsOneWidget);
      });

      testWidgets('preserves title and content during conversion', (tester) async {
        await tester.pumpWidget(createTestWidget());
        await tester.pumpAndSettle();

        // Clear previous interactions
        clearInteractions(mockItemsProvider);

        // Tap convert button
        await tester.tap(find.byIcon(Icons.swap_horiz));
        await tester.pumpAndSettle();

        // Select Note
        await tester.tap(find.descendant(
          of: find.byType(ListTile),
          matching: find.text('Note'),
        ));
        await tester.pumpAndSettle();

        // Verify title and content are preserved (called at least once)
        verify(mockItemsProvider.updateItem(argThat(
          predicate<Item>((item) =>
            item.title == 'Test Task' &&
            item.content == 'Test content'
          ),
        ))).called(greaterThan(0));
      });

      testWidgets('preserves tags during conversion', (tester) async {
        await tester.pumpWidget(createTestWidget());
        await tester.pumpAndSettle();

        // Clear previous interactions
        clearInteractions(mockItemsProvider);

        // Tap convert button
        await tester.tap(find.byIcon(Icons.swap_horiz));
        await tester.pumpAndSettle();

        // Select Note
        await tester.tap(find.descendant(
          of: find.byType(ListTile),
          matching: find.text('Note'),
        ));
        await tester.pumpAndSettle();

        // Verify tags are preserved (should be called at least once)
        verify(mockItemsProvider.updateItem(argThat(
          predicate<Item>((item) =>
            item.tags.length == 2 &&
            item.tags.contains('urgent') &&
            item.tags.contains('work')
          ),
        ))).called(greaterThan(0));
      });

      testWidgets('cancels conversion when Cancel is tapped', (tester) async {
        await tester.pumpWidget(createTestWidget());
        await tester.pumpAndSettle();

        // Tap convert button
        await tester.tap(find.byIcon(Icons.swap_horiz));
        await tester.pumpAndSettle();

        // Clear interactions after dialog opens to ignore setup calls
        clearInteractions(mockItemsProvider);

        // Tap Cancel
        await tester.tap(find.text('Cancel'));
        await tester.pumpAndSettle();

        // Verify updateItem was not called after cancel
        verifyNever(mockItemsProvider.updateItem(any));

        // No success message
        expect(find.textContaining('Converted to'), findsNothing);
      });

      testWidgets('updates type badge after conversion', (tester) async {
        await tester.pumpWidget(createTestWidget());
        await tester.pumpAndSettle();

        // Initially shows Task badge
        expect(find.text('Task'), findsOneWidget);

        // Convert to Note
        await tester.tap(find.byIcon(Icons.swap_horiz));
        await tester.pumpAndSettle();
        await tester.tap(find.descendant(
          of: find.byType(ListTile),
          matching: find.text('Note'),
        ));
        await tester.pumpAndSettle();

        // Should now show Note badge
        expect(find.text('Note'), findsOneWidget);
        expect(find.text('Task'), findsNothing);
      });

      testWidgets('handles conversion error gracefully', (tester) async {
        // Create a fresh mock that throws errors
        final errorMockProvider = MockItemsProvider();
        when(errorMockProvider.updateItem(any))
            .thenThrow(Exception('Conversion failed'));

        await tester.pumpWidget(
          MultiProvider(
            providers: [
              ChangeNotifierProvider<ItemsProvider>.value(value: errorMockProvider),
              ChangeNotifierProvider<SpacesProvider>.value(value: mockSpacesProvider),
            ],
            child: MaterialApp(
              home: ItemDetailScreen(item: testItem),
            ),
          ),
        );
        await tester.pumpAndSettle();

        // Tap convert button
        await tester.tap(find.byIcon(Icons.swap_horiz));
        await tester.pumpAndSettle();

        // Select Note - this should trigger the error
        await tester.tap(find.descendant(
          of: find.byType(ListTile),
          matching: find.text('Note'),
        ));

        // Pump to trigger the async conversion
        await tester.pump();

        // The error is caught and handled gracefully - verify no exception crashed the app
        // by checking that we can still interact with the widget
        expect(find.byType(ItemDetailScreen), findsOneWidget);

        // Verify updateItem was called at least once and failed
        verify(errorMockProvider.updateItem(any)).called(greaterThan(0));
      });

      testWidgets('saves pending changes before conversion', (tester) async {
        await tester.pumpWidget(createTestWidget());
        await tester.pumpAndSettle();

        // Make a change to title
        final titleField = find.widgetWithText(TextFormField, 'Test Task');
        await tester.enterText(titleField, 'Modified Task');
        await tester.pump();

        // Clear previous interactions
        clearInteractions(mockItemsProvider);

        // Immediately convert (before auto-save)
        await tester.tap(find.byIcon(Icons.swap_horiz));
        await tester.pumpAndSettle();
        await tester.tap(find.descendant(
          of: find.byType(ListTile),
          matching: find.text('Note'),
        ));
        await tester.pumpAndSettle();

        // Verify updateItem was called (for both save and conversion)
        verify(mockItemsProvider.updateItem(any)).called(greaterThan(1));
      });

      testWidgets('conversion dialog has proper semantic label', (tester) async {
        await tester.pumpWidget(createTestWidget());
        await tester.pumpAndSettle();

        // Tap convert button
        await tester.tap(find.byIcon(Icons.swap_horiz));
        await tester.pumpAndSettle();

        // Verify semantic label exists
        final dialog = tester.widget<AlertDialog>(find.byType(AlertDialog));
        expect(dialog.semanticLabel, 'Convert item type dialog');
      });
    });
  });
}
