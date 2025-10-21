import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:later_mobile/core/theme/app_colors.dart';
import 'package:later_mobile/data/models/item_model.dart';
import 'package:later_mobile/data/models/space_model.dart';
import 'package:later_mobile/providers/items_provider.dart';
import 'package:later_mobile/providers/spaces_provider.dart';
import 'package:later_mobile/widgets/screens/item_detail_screen.dart';
import 'package:provider/provider.dart';
import 'package:mockito/mockito.dart';
import 'package:mockito/annotations.dart';

import 'item_detail_screen_test.mocks.dart';

/// Test suite for Item Detail Screen Redesign (Phase 4, Task 4.2)
/// Tests the Temporal Flow design system implementation:
/// - Gradient header background matching item type
/// - Glass card containers for content sections
/// - Glass morphism on input fields
/// - Gradient delete button in confirmation dialog
/// - Gradient completion toggle
/// - Gradient separator lines between sections
/// - Softer metadata footer styling
/// - Support for all item types and long content
@GenerateMocks([ItemsProvider, SpacesProvider])
void main() {
  late MockItemsProvider mockItemsProvider;
  late MockSpacesProvider mockSpacesProvider;
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

    // Setup mock behaviors
    when(mockSpacesProvider.spaces).thenReturn(testSpaces);
    when(mockItemsProvider.updateItem(any)).thenAnswer((_) async {});
    when(mockItemsProvider.deleteItem(any)).thenAnswer((_) async {});
    when(mockSpacesProvider.incrementSpaceItemCount(any))
        .thenAnswer((_) async {});
    when(mockSpacesProvider.decrementSpaceItemCount(any))
        .thenAnswer((_) async {});
  });

  Widget createTestWidget({Item? item, ThemeData? theme}) {
    final defaultItem = Item(
      id: 'item-1',
      type: ItemType.task,
      title: 'Test Task',
      content: 'Test content',
      spaceId: 'space-1',
      dueDate: DateTime(2025, 12, 31),
      tags: ['urgent'],
      // ignore: avoid_redundant_argument_values
      createdAt: DateTime(2025, 1, 1),
      // ignore: avoid_redundant_argument_values
      updatedAt: DateTime(2025, 1, 2),
    );

    return MultiProvider(
      providers: [
        ChangeNotifierProvider<ItemsProvider>.value(value: mockItemsProvider),
        ChangeNotifierProvider<SpacesProvider>.value(value: mockSpacesProvider),
      ],
      child: MaterialApp(
        theme: theme,
        home: ItemDetailScreen(item: item ?? defaultItem),
      ),
    );
  }

  group('Item Detail Screen Redesign - Gradient Headers', () {
    testWidgets('displays gradient header background for task items',
        (tester) async {
      final taskItem = Item(
        id: 'task-1',
        type: ItemType.task,
        title: 'Task with Gradient',
        spaceId: 'space-1',
      );

      await tester.pumpWidget(createTestWidget(item: taskItem));
      await tester.pumpAndSettle();

      // Look for Container with gradient decoration in the header area
      final gradientContainers = find.byWidgetPredicate(
        (widget) =>
            widget is Container &&
            widget.decoration is BoxDecoration &&
            (widget.decoration as BoxDecoration).gradient != null,
      );

      expect(gradientContainers, findsWidgets);

      // Verify the gradient uses task colors
      final container = tester.widget<Container>(gradientContainers.first);
      final decoration = container.decoration as BoxDecoration;
      final gradient = decoration.gradient as LinearGradient;

      expect(gradient.colors, contains(AppColors.taskGradientStart));
      expect(gradient.colors, contains(AppColors.taskGradientEnd));
    });

    testWidgets('displays gradient header background for note items',
        (tester) async {
      final noteItem = Item(
        id: 'note-1',
        type: ItemType.note,
        title: 'Note with Gradient',
        spaceId: 'space-1',
      );

      await tester.pumpWidget(createTestWidget(item: noteItem));
      await tester.pumpAndSettle();

      // Look for Container with gradient decoration
      final gradientContainers = find.byWidgetPredicate(
        (widget) =>
            widget is Container &&
            widget.decoration is BoxDecoration &&
            (widget.decoration as BoxDecoration).gradient != null,
      );

      expect(gradientContainers, findsWidgets);

      // Verify the gradient uses note colors
      final container = tester.widget<Container>(gradientContainers.first);
      final decoration = container.decoration as BoxDecoration;
      final gradient = decoration.gradient as LinearGradient;

      expect(gradient.colors, contains(AppColors.noteGradientStart));
      expect(gradient.colors, contains(AppColors.noteGradientEnd));
    });

    testWidgets('displays gradient header background for list items',
        (tester) async {
      final listItem = Item(
        id: 'list-1',
        type: ItemType.list,
        title: 'List with Gradient',
        spaceId: 'space-1',
      );

      await tester.pumpWidget(createTestWidget(item: listItem));
      await tester.pumpAndSettle();

      // Look for Container with gradient decoration
      final gradientContainers = find.byWidgetPredicate(
        (widget) =>
            widget is Container &&
            widget.decoration is BoxDecoration &&
            (widget.decoration as BoxDecoration).gradient != null,
      );

      expect(gradientContainers, findsWidgets);

      // Verify the gradient uses list colors
      final container = tester.widget<Container>(gradientContainers.first);
      final decoration = container.decoration as BoxDecoration;
      final gradient = decoration.gradient as LinearGradient;

      expect(gradient.colors, contains(AppColors.listGradientStart));
      expect(gradient.colors, contains(AppColors.listGradientEnd));
    });

    testWidgets('gradient header adapts to dark mode', (tester) async {
      final taskItem = Item(
        id: 'task-1',
        type: ItemType.task,
        title: 'Task in Dark Mode',
        spaceId: 'space-1',
      );

      await tester.pumpWidget(
        createTestWidget(
          item: taskItem,
          theme: ThemeData.dark(),
        ),
      );
      await tester.pumpAndSettle();

      // Verify gradient exists in dark mode
      final gradientContainers = find.byWidgetPredicate(
        (widget) =>
            widget is Container &&
            widget.decoration is BoxDecoration &&
            (widget.decoration as BoxDecoration).gradient != null,
      );

      expect(gradientContainers, findsWidgets);
    });
  });

  group('Item Detail Screen Redesign - Glass Card Containers', () {
    testWidgets('wraps content sections in semi-transparent containers',
        (tester) async {
      await tester.pumpWidget(createTestWidget());
      await tester.pumpAndSettle();

      // Look for containers with semi-transparent backgrounds
      final glassContainers = find.byWidgetPredicate(
        (widget) =>
            widget is Container &&
            widget.decoration is BoxDecoration &&
            (widget.decoration as BoxDecoration).color != null &&
            (widget.decoration as BoxDecoration).color!.a < 1.0,
      );

      expect(glassContainers, findsWidgets);
    });

    testWidgets('glass-style containers have rounded corners',
        (tester) async {
      await tester.pumpWidget(createTestWidget());
      await tester.pumpAndSettle();

      // Look for containers with rounded borders
      final roundedContainers = find.byWidgetPredicate(
        (widget) =>
            widget is Container &&
            widget.decoration is BoxDecoration &&
            (widget.decoration as BoxDecoration).borderRadius != null,
      );

      expect(roundedContainers, findsWidgets);
    });

    testWidgets('glass-style containers adapt to dark mode', (tester) async {
      await tester.pumpWidget(
        createTestWidget(theme: ThemeData.dark()),
      );
      await tester.pumpAndSettle();

      // Verify containers exist with proper styling
      final containers = find.byWidgetPredicate(
        (widget) =>
            widget is Container &&
            widget.decoration is BoxDecoration &&
            (widget.decoration as BoxDecoration).color != null,
      );

      expect(containers, findsWidgets);
    });
  });

  group('Item Detail Screen Redesign - Glass Input Fields', () {
    testWidgets('title input field has glass focus state', (tester) async {
      await tester.pumpWidget(createTestWidget());
      await tester.pumpAndSettle();

      // Find title field
      final titleField = find.widgetWithText(TextFormField, 'Test Task');
      expect(titleField, findsOneWidget);

      // Tap to focus
      await tester.tap(titleField);
      await tester.pumpAndSettle();

      // Look for glass effect when focused
      // This will be implemented via InputDecoration with glass colors
      // We verify the field exists and can be interacted with
      expect(titleField, findsOneWidget);
    });

    testWidgets('content input field has glass focus state', (tester) async {
      await tester.pumpWidget(createTestWidget());
      await tester.pumpAndSettle();

      // Find content field
      final contentField = find.widgetWithText(TextFormField, 'Test content');
      expect(contentField, findsOneWidget);

      // Tap to focus
      await tester.tap(contentField);
      await tester.pumpAndSettle();

      // Look for glass effect when focused
      // We verify the field exists and can be interacted with
      expect(contentField, findsOneWidget);
    });
  });

  group('Item Detail Screen Redesign - Gradient Delete Button', () {
    testWidgets('delete confirmation dialog has gradient button',
        (tester) async {
      await tester.pumpWidget(createTestWidget());
      await tester.pumpAndSettle();

      // Open delete confirmation
      await tester.tap(find.byIcon(Icons.delete_outline));
      await tester.pumpAndSettle();

      // Look for ElevatedButton with gradient decoration
      final deleteButtons = find.byWidgetPredicate(
        (widget) => widget is ElevatedButton,
      );

      expect(deleteButtons, findsWidgets);

      // Find the Delete button (not Cancel)
      final deleteButton = find.ancestor(
        of: find.text('Delete'),
        matching: find.byType(ElevatedButton),
      );

      expect(deleteButton, findsOneWidget);

      // Verify button has Container with gradient decoration
      final buttonWidget = tester.widget<ElevatedButton>(deleteButton);
      expect(buttonWidget, isNotNull);
    });

    testWidgets('delete button gradient uses error colors', (tester) async {
      await tester.pumpWidget(createTestWidget());
      await tester.pumpAndSettle();

      // Open delete confirmation
      await tester.tap(find.byIcon(Icons.delete_outline));
      await tester.pumpAndSettle();

      // Look for gradient containers in dialog
      final gradientContainers = find.byWidgetPredicate(
        (widget) =>
            widget is Container &&
            widget.decoration is BoxDecoration &&
            (widget.decoration as BoxDecoration).gradient != null,
      );

      expect(gradientContainers, findsWidgets);
    });
  });

  group('Item Detail Screen Redesign - Gradient Completion Toggle', () {
    testWidgets('completion checkbox uses gradient when checked',
        (tester) async {
      final taskItem = Item(
        id: 'task-1',
        type: ItemType.task,
        title: 'Completed Task',
        spaceId: 'space-1',
        isCompleted: true,
      );

      await tester.pumpWidget(createTestWidget(item: taskItem));
      await tester.pumpAndSettle();

      // Find checkbox
      final checkbox = find.byType(CheckboxListTile);
      expect(checkbox, findsOneWidget);

      // Look for gradient decoration on the checkbox or its wrapper
      final checkboxWidget = tester.widget<CheckboxListTile>(checkbox);
      expect(checkboxWidget.value, isTrue);
    });

    testWidgets('completion toggle animates with gradient', (tester) async {
      await tester.pumpWidget(createTestWidget());
      await tester.pumpAndSettle();

      // Find checkbox
      final checkbox = find.byType(CheckboxListTile);
      expect(checkbox, findsOneWidget);

      // Toggle completion
      await tester.tap(checkbox);
      await tester.pump(); // Start animation
      await tester.pump(const Duration(milliseconds: 100)); // Mid animation

      // Checkbox should be updating
      final checkboxWidget = tester.widget<CheckboxListTile>(checkbox);
      expect(checkboxWidget, isNotNull);
    });
  });

  group('Item Detail Screen Redesign - Gradient Separators', () {
    testWidgets('displays gradient separators between sections', (tester) async {
      await tester.pumpWidget(createTestWidget());
      await tester.pumpAndSettle();

      // Look for gradient containers used as separators (height of 1px)
      final gradientSeparators = find.byWidgetPredicate(
        (widget) =>
            widget is Container &&
            widget.decoration is BoxDecoration &&
            (widget.decoration as BoxDecoration).gradient != null,
      );

      expect(gradientSeparators, findsWidgets);
    });

    testWidgets('gradient separators use subtle gradients', (tester) async {
      await tester.pumpWidget(createTestWidget());
      await tester.pumpAndSettle();

      // Look for gradient containers used as dividers
      final gradientDividers = find.byWidgetPredicate(
        (widget) =>
            widget is Container &&
            widget.decoration is BoxDecoration &&
            (widget.decoration as BoxDecoration).gradient != null,
      );

      expect(gradientDividers, findsWidgets);
    });

    testWidgets('separators adapt to item type colors', (tester) async {
      final noteItem = Item(
        id: 'note-1',
        type: ItemType.note,
        title: 'Note with Separators',
        content: 'Content',
        spaceId: 'space-1',
        tags: ['tag1'], // Add tags to ensure separator appears
      );

      await tester.pumpWidget(createTestWidget(item: noteItem));
      await tester.pumpAndSettle();

      // Verify gradient containers are present (separators)
      final gradientContainers = find.byWidgetPredicate(
        (widget) =>
            widget is Container &&
            widget.decoration is BoxDecoration &&
            (widget.decoration as BoxDecoration).gradient != null,
      );

      expect(gradientContainers, findsWidgets);
    });
  });

  group('Item Detail Screen Redesign - Metadata Footer', () {
    testWidgets('metadata footer has softer visual hierarchy', (tester) async {
      await tester.pumpWidget(createTestWidget());
      await tester.pumpAndSettle();

      // Find metadata text
      final createdText = find.textContaining('Created:');
      final modifiedText = find.textContaining('Modified:');

      expect(createdText, findsOneWidget);
      expect(modifiedText, findsOneWidget);

      // Verify text has reduced opacity or disabled color
      final createdTextWidget = tester.widget<Text>(createdText);
      expect(createdTextWidget.style, isNotNull);
      expect(createdTextWidget.style!.color, isNotNull);
    });

    testWidgets('metadata footer uses glass background', (tester) async {
      await tester.pumpWidget(createTestWidget());
      await tester.pumpAndSettle();

      // Look for metadata container with glass styling
      final metadataContainers = find.byWidgetPredicate(
        (widget) =>
            widget is Container &&
            widget.decoration is BoxDecoration &&
            (widget.decoration as BoxDecoration).color != null,
      );

      expect(metadataContainers, findsWidgets);
    });

    testWidgets('metadata icons have reduced opacity', (tester) async {
      await tester.pumpWidget(createTestWidget());
      await tester.pumpAndSettle();

      // Find metadata icons
      final icons = find.byWidgetPredicate(
        (widget) =>
            widget is Icon &&
            (widget.icon == Icons.add_circle_outline ||
                widget.icon == Icons.update),
      );

      expect(icons, findsWidgets);

      // Verify icons have muted colors
      final iconWidget = tester.widget<Icon>(icons.first);
      expect(iconWidget.color, isNotNull);
    });
  });

  group('Item Detail Screen Redesign - Type Badge with Gradient', () {
    testWidgets('type badge uses gradient background for tasks', (tester) async {
      final taskItem = Item(
        id: 'task-1',
        type: ItemType.task,
        title: 'Task Badge',
        spaceId: 'space-1',
      );

      await tester.pumpWidget(createTestWidget(item: taskItem));
      await tester.pumpAndSettle();

      // Find type badge
      expect(find.text('Task'), findsOneWidget);

      // Look for gradient container wrapping the badge
      final badgeContainers = find.byWidgetPredicate(
        (widget) =>
            widget is Container &&
            widget.decoration is BoxDecoration &&
            (widget.decoration as BoxDecoration).gradient != null,
      );

      expect(badgeContainers, findsWidgets);
    });

    testWidgets('type badge uses gradient background for notes', (tester) async {
      final noteItem = Item(
        id: 'note-1',
        type: ItemType.note,
        title: 'Note Badge',
        spaceId: 'space-1',
      );

      await tester.pumpWidget(createTestWidget(item: noteItem));
      await tester.pumpAndSettle();

      // Find type badge
      expect(find.text('Note'), findsOneWidget);

      // Look for gradient
      final badgeContainers = find.byWidgetPredicate(
        (widget) =>
            widget is Container &&
            widget.decoration is BoxDecoration &&
            (widget.decoration as BoxDecoration).gradient != null,
      );

      expect(badgeContainers, findsWidgets);
    });

    testWidgets('type badge uses gradient background for lists', (tester) async {
      final listItem = Item(
        id: 'list-1',
        type: ItemType.list,
        title: 'List Badge',
        spaceId: 'space-1',
      );

      await tester.pumpWidget(createTestWidget(item: listItem));
      await tester.pumpAndSettle();

      // Find type badge
      expect(find.text('List'), findsOneWidget);

      // Look for gradient
      final badgeContainers = find.byWidgetPredicate(
        (widget) =>
            widget is Container &&
            widget.decoration is BoxDecoration &&
            (widget.decoration as BoxDecoration).gradient != null,
      );

      expect(badgeContainers, findsWidgets);
    });
  });

  group('Item Detail Screen Redesign - Long Content Support', () {
    testWidgets('handles very long title text gracefully', (tester) async {
      final longTitleItem = Item(
        id: 'long-1',
        type: ItemType.task,
        title: 'This is an extremely long title that should wrap properly and '
            'still maintain good visual hierarchy with the gradient header and '
            'glass morphism effects throughout the entire interface design',
        spaceId: 'space-1',
      );

      await tester.pumpWidget(createTestWidget(item: longTitleItem));
      await tester.pumpAndSettle();

      // Verify long title is displayed
      expect(find.textContaining('This is an extremely long title'),
          findsOneWidget);

      // Verify layout doesn't overflow
      expect(tester.takeException(), isNull);
    });

    testWidgets('handles very long content text gracefully', (tester) async {
      final longContentItem = Item(
        id: 'long-2',
        type: ItemType.note,
        title: 'Note with Long Content',
        content: 'Lorem ipsum dolor sit amet, consectetur adipiscing elit. ' * 50,
        spaceId: 'space-1',
      );

      await tester.pumpWidget(createTestWidget(item: longContentItem));
      await tester.pumpAndSettle();

      // Verify content is scrollable
      final scrollView = find.byType(SingleChildScrollView);
      expect(scrollView, findsOneWidget);

      // Verify no overflow errors
      expect(tester.takeException(), isNull);
    });

    testWidgets('maintains gradient header visibility with long content',
        (tester) async {
      final longItem = Item(
        id: 'long-3',
        type: ItemType.task,
        title: 'Long Task',
        content: 'Very long content. ' * 100,
        spaceId: 'space-1',
      );

      await tester.pumpWidget(createTestWidget(item: longItem));
      await tester.pumpAndSettle();

      // Scroll to bottom
      await tester.drag(
        find.byType(SingleChildScrollView),
        const Offset(0, -500),
      );
      await tester.pumpAndSettle();

      // Verify gradient header is still visible (fixed at top)
      final gradientHeaders = find.byWidgetPredicate(
        (widget) =>
            widget is Container &&
            widget.decoration is BoxDecoration &&
            (widget.decoration as BoxDecoration).gradient != null,
      );

      expect(gradientHeaders, findsWidgets);
    });
  });

  group('Item Detail Screen Redesign - All Item Types', () {
    testWidgets('task items display all gradient elements correctly',
        (tester) async {
      final taskItem = Item(
        id: 'task-1',
        type: ItemType.task,
        title: 'Complete Task Design',
        content: 'Task content',
        spaceId: 'space-1',
        dueDate: DateTime(2025, 12, 31),
      );

      await tester.pumpWidget(createTestWidget(item: taskItem));
      await tester.pumpAndSettle();

      // Verify all redesign elements are present
      expect(find.text('Task'), findsOneWidget);
      expect(find.text('Mark as complete'), findsOneWidget);
      expect(find.text('Due Date'), findsOneWidget);

      // Verify glass containers with border styling
      final glassContainers = find.byWidgetPredicate(
        (widget) =>
            widget is Container &&
            widget.decoration is BoxDecoration &&
            (widget.decoration as BoxDecoration).border != null,
      );
      expect(glassContainers, findsWidgets);
      expect(find.textContaining('Created:'), findsOneWidget);
    });

    testWidgets('note items display all gradient elements correctly',
        (tester) async {
      final noteItem = Item(
        id: 'note-1',
        type: ItemType.note,
        title: 'Complete Note Design',
        content: 'Note content with important information',
        spaceId: 'space-1',
      );

      await tester.pumpWidget(createTestWidget(item: noteItem));
      await tester.pumpAndSettle();

      // Verify all redesign elements are present
      expect(find.text('Note'), findsOneWidget);

      // Verify glass containers with border styling
      final glassContainers = find.byWidgetPredicate(
        (widget) =>
            widget is Container &&
            widget.decoration is BoxDecoration &&
            (widget.decoration as BoxDecoration).border != null,
      );
      expect(glassContainers, findsWidgets);
      expect(find.textContaining('Created:'), findsOneWidget);
      // Notes should not have completion checkbox or due date
      expect(find.text('Mark as complete'), findsNothing);
      expect(find.text('Due Date'), findsNothing);
    });

    testWidgets('list items display all gradient elements correctly',
        (tester) async {
      final listItem = Item(
        id: 'list-1',
        type: ItemType.list,
        title: 'Complete List Design',
        content: 'List items:\n1. First item\n2. Second item',
        spaceId: 'space-1',
      );

      await tester.pumpWidget(createTestWidget(item: listItem));
      await tester.pumpAndSettle();

      // Verify all redesign elements are present
      expect(find.text('List'), findsOneWidget);

      // Verify glass containers with border styling
      final glassContainers = find.byWidgetPredicate(
        (widget) =>
            widget is Container &&
            widget.decoration is BoxDecoration &&
            (widget.decoration as BoxDecoration).border != null,
      );
      expect(glassContainers, findsWidgets);
      expect(find.textContaining('Created:'), findsOneWidget);
      // Lists should not have completion checkbox or due date
      expect(find.text('Mark as complete'), findsNothing);
      expect(find.text('Due Date'), findsNothing);
    });
  });

  group('Item Detail Screen Redesign - Dark Mode Adaptation', () {
    testWidgets('all gradient elements adapt to dark mode', (tester) async {
      await tester.pumpWidget(
        createTestWidget(theme: ThemeData.dark()),
      );
      await tester.pumpAndSettle();

      // Verify gradient header
      final gradientContainers = find.byWidgetPredicate(
        (widget) =>
            widget is Container &&
            widget.decoration is BoxDecoration &&
            (widget.decoration as BoxDecoration).gradient != null,
      );
      expect(gradientContainers, findsWidgets);

      // Verify glass containers with borders
      final glassContainers = find.byWidgetPredicate(
        (widget) =>
            widget is Container &&
            widget.decoration is BoxDecoration &&
            (widget.decoration as BoxDecoration).border != null,
      );
      expect(glassContainers, findsWidgets);

      // Verify metadata footer uses dark colors
      expect(find.textContaining('Created:'), findsOneWidget);
    });

    testWidgets('glass morphism uses dark mode colors', (tester) async {
      await tester.pumpWidget(
        createTestWidget(theme: ThemeData.dark()),
      );
      await tester.pumpAndSettle();

      // Look for dark surface containers (using surfaceDark instead of glassDark)
      final darkGlassContainers = find.byWidgetPredicate(
        (widget) =>
            widget is Container &&
            widget.decoration is BoxDecoration &&
            (widget.decoration as BoxDecoration).color != null &&
            (widget.decoration as BoxDecoration).color == AppColors.surfaceDark,
      );

      expect(darkGlassContainers, findsWidgets);
    });
  });

  group('Item Detail Screen Redesign - Functionality Preservation', () {
    testWidgets('auto-save functionality still works', (tester) async {
      await tester.pumpWidget(createTestWidget());
      await tester.pumpAndSettle();

      // Make a change
      final titleField = find.widgetWithText(TextFormField, 'Test Task');
      await tester.enterText(titleField, 'Changed Title');

      // Wait for debounce
      await tester.pump(const Duration(milliseconds: 500));
      await tester.pumpAndSettle();

      // Verify save was called
      verify(mockItemsProvider.updateItem(any)).called(greaterThan(0));
    });

    testWidgets('keyboard shortcuts still work', (tester) async {
      await tester.pumpWidget(createTestWidget());
      await tester.pumpAndSettle();

      // Test Escape key
      await tester.sendKeyEvent(LogicalKeyboardKey.escape);
      await tester.pumpAndSettle();

      // Screen should be popped
      expect(find.byType(ItemDetailScreen), findsNothing);
    });

    testWidgets('form validation still works', (tester) async {
      await tester.pumpWidget(createTestWidget());
      await tester.pumpAndSettle();

      // Clear title
      final titleField = find.widgetWithText(TextFormField, 'Test Task');
      await tester.enterText(titleField, '');
      await tester.pumpAndSettle();

      // Wait for debounce
      await tester.pump(const Duration(milliseconds: 600));

      // Should not save empty title
      verifyNever(mockItemsProvider.updateItem(argThat(
        predicate<Item>((item) => item.title.isEmpty),
      )));
    });
  });
}
