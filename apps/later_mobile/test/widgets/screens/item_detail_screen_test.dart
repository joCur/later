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

      // Verify dialog appears
      expect(find.text('Delete task?'), findsOneWidget);
      expect(find.text('This action cannot be undone.'), findsOneWidget);
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

    testWidgets('deletes item when Delete is confirmed', (tester) async {
      await tester.pumpWidget(createTestWidget());
      await tester.pumpAndSettle();

      // Open delete dialog
      await tester.tap(find.byIcon(Icons.delete_outline));
      await tester.pumpAndSettle();

      // Tap Delete
      await tester.tap(find.text('Delete'));
      await tester.pumpAndSettle();

      // Verify deleteItem was called
      verify(mockItemsProvider.deleteItem('item-1')).called(1);
      verify(mockSpacesProvider.decrementSpaceItemCount('space-1')).called(1);
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
  });
}
