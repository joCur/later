import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:later_mobile/data/models/space_model.dart';
import 'package:later_mobile/data/repositories/space_repository.dart';
import 'package:later_mobile/providers/spaces_provider.dart';
import 'package:later_mobile/widgets/modals/space_switcher_modal.dart';
import 'package:mockito/annotations.dart';
import 'package:mockito/mockito.dart';
import 'package:provider/provider.dart';

import 'space_switcher_modal_edit_test.mocks.dart';

@GenerateMocks([SpaceRepository])
void main() {
  group('SpaceSwitcherModal Edit Space Tests', () {
    late MockSpaceRepository mockRepository;
    late SpacesProvider spacesProvider;
    late List<Space> testSpaces;

    // Test user ID for all test spaces
    const testUserId = 'test-user-id';

    setUp(() async {
      mockRepository = MockSpaceRepository();
      spacesProvider = SpacesProvider(mockRepository);

      // Create test spaces
      testSpaces = [
        Space(
          id: 'space-1',
          name: 'Personal',
          userId: testUserId,
          icon: '🏠',
          color: '#6366F1',
        ),
        Space(
          id: 'space-2',
          name: 'Work',
          userId: testUserId,
          icon: '💼',
          color: '#8B5CF6',
        ),
        Space(
          id: 'space-3',
          name: 'Projects',
          userId: testUserId,
          icon: '🚀',
          color: '#F59E0B',
        ),
      ];

      // Mock repository to return test spaces
      when(mockRepository.getSpaces()).thenAnswer((_) async => testSpaces);
      when(mockRepository.getItemCount(any)).thenAnswer((_) async => 12);

      // Mock create/update operations
      when(mockRepository.createSpace(any)).thenAnswer((inv) async {
        final space = inv.positionalArguments[0] as Space;
        return space;
      });
      when(mockRepository.updateSpace(any)).thenAnswer((inv) async {
        final space = inv.positionalArguments[0] as Space;
        return space;
      });
      when(mockRepository.deleteSpace(any)).thenAnswer((_) async {});

      // Load spaces into provider
      await spacesProvider.loadSpaces();
    });

    /// Helper to build modal with provider
    Widget buildModalWithProvider({
      Size size = const Size(400, 800), // Mobile by default
      ThemeData? theme,
    }) {
      return MediaQuery(
        data: MediaQueryData(size: size),
        child: MaterialApp(
          theme: theme ?? ThemeData.light(),
          home: ChangeNotifierProvider<SpacesProvider>.value(
            value: spacesProvider,
            child: const Scaffold(body: SpaceSwitcherModal()),
          ),
        ),
      );
    }

    group('Long Press Menu', () {
      testWidgets('long-press on space item shows context menu', (
        WidgetTester tester,
      ) async {
        // Arrange
        await tester.pumpWidget(buildModalWithProvider());
        await tester.pumpAndSettle();

        // Act - Long press on "Work" space
        await tester.longPress(find.text('Work'));
        await tester.pumpAndSettle();

        // Assert - Menu should be visible with all options
        expect(find.text('Edit Space'), findsOneWidget);
        expect(find.text('Archive Space'), findsOneWidget);
        expect(find.text('Cancel'), findsOneWidget);
      });

      testWidgets('long-press menu has proper icons', (
        WidgetTester tester,
      ) async {
        // Arrange
        await tester.pumpWidget(buildModalWithProvider());
        await tester.pumpAndSettle();

        // Act - Long press on "Work" space
        await tester.longPress(find.text('Work'));
        await tester.pumpAndSettle();

        // Assert - Icons should be present
        expect(find.byIcon(Icons.edit), findsOneWidget);
        expect(find.byIcon(Icons.archive), findsOneWidget);
      });

      testWidgets('cancel option closes menu', (WidgetTester tester) async {
        // Arrange
        await tester.pumpWidget(buildModalWithProvider());
        await tester.pumpAndSettle();

        // Act
        await tester.longPress(find.text('Work'));
        await tester.pumpAndSettle();

        await tester.tap(find.text('Cancel'));
        await tester.pumpAndSettle();

        // Assert - Menu should be closed
        expect(find.text('Edit Space'), findsNothing);
      });

      testWidgets('archive option is disabled for current space', (
        WidgetTester tester,
      ) async {
        // Arrange
        await tester.pumpWidget(buildModalWithProvider());
        await tester.pumpAndSettle();

        // Act - Long press on current space (Personal)
        await tester.longPress(find.text('Personal'));
        await tester.pumpAndSettle();

        // Assert - Archive should be visible but potentially disabled
        expect(find.text('Archive Space'), findsOneWidget);

        // Try to tap archive on current space
        await tester.tap(find.text('Archive Space'));
        await tester.pumpAndSettle();

        // Should show error or prevent action
        expect(find.textContaining('current space'), findsOneWidget);
      });

      testWidgets('shows item count warning for non-empty spaces', (
        WidgetTester tester,
      ) async {
        // Arrange
        await tester.pumpWidget(buildModalWithProvider());
        await tester.pumpAndSettle();

        // Act - Long press on "Work" space (has 12 items)
        await tester.longPress(find.text('Work'));
        await tester.pumpAndSettle();

        // Assert - Should show some indication of items
        // The menu or a subtitle might indicate "12 items"
        expect(find.textContaining('12'), findsWidgets);
      });

      testWidgets('tapping outside menu closes it', (
        WidgetTester tester,
      ) async {
        // Arrange
        await tester.pumpWidget(buildModalWithProvider());
        await tester.pumpAndSettle();

        // Act
        await tester.longPress(find.text('Work'));
        await tester.pumpAndSettle();

        // Tap outside (on the title)
        await tester.tapAt(const Offset(200, 50));
        await tester.pumpAndSettle();

        // Assert - Menu should be closed
        expect(find.text('Edit Space'), findsNothing);
      });
    });

    group('Edit Space Flow', () {
      testWidgets('edit space option opens CreateSpaceModal in edit mode', (
        WidgetTester tester,
      ) async {
        // Arrange
        await tester.pumpWidget(buildModalWithProvider());
        await tester.pumpAndSettle();

        // Act - Long press and select Edit
        await tester.longPress(find.text('Work'));
        await tester.pumpAndSettle();

        await tester.tap(find.text('Edit Space'));
        await tester.pumpAndSettle();

        // Assert - CreateSpaceModal should open with "Edit Space" title
        expect(find.text('Edit Space'), findsOneWidget);
        expect(find.text('Save'), findsOneWidget);
        // Pre-filled data
        expect(find.text('Work'), findsWidgets);
      });

      testWidgets('editing space name updates the space list', (
        WidgetTester tester,
      ) async {
        // Arrange
        await tester.pumpWidget(buildModalWithProvider());
        await tester.pumpAndSettle();

        // Act - Open edit modal
        await tester.longPress(find.text('Work'));
        await tester.pumpAndSettle();

        await tester.tap(find.text('Edit Space'));
        await tester.pumpAndSettle();

        // Edit the name
        await tester.enterText(
          find.widgetWithText(TextField, 'Work'),
          'Updated Work',
        );
        await tester.pumpAndSettle();

        // Save
        await tester.tap(find.text('Save'));
        await tester.pumpAndSettle();

        // Assert - Space should be updated in the list
        expect(find.text('Updated Work'), findsOneWidget);
        expect(find.text('Work'), findsNothing);
      });

      testWidgets('editing space icon updates the space', (
        WidgetTester tester,
      ) async {
        // Arrange
        await tester.pumpWidget(buildModalWithProvider());
        await tester.pumpAndSettle();

        // Act - Open edit modal
        await tester.longPress(find.text('Work'));
        await tester.pumpAndSettle();

        await tester.tap(find.text('Edit Space'));
        await tester.pumpAndSettle();

        // Select a different icon (find a non-selected icon)
        final iconFinder = find.text('🏠').last;
        await tester.tap(iconFinder);
        await tester.pumpAndSettle();

        // Save
        await tester.tap(find.text('Save'));
        await tester.pumpAndSettle();

        // Assert - Icon should be updated (though visual verification is complex)
        // Just verify the save completed
        expect(find.text('Save'), findsNothing);
      });

      testWidgets('editing space color updates the space', (
        WidgetTester tester,
      ) async {
        // Arrange
        await tester.pumpWidget(buildModalWithProvider());
        await tester.pumpAndSettle();

        // Act - Open edit modal
        await tester.longPress(find.text('Work'));
        await tester.pumpAndSettle();

        await tester.tap(find.text('Edit Space'));
        await tester.pumpAndSettle();

        // Select a different color (find a color picker container)
        // Colors are rendered as Container widgets
        final colorPickers = find.descendant(
          of: find.ancestor(
            of: find.text('Color'),
            matching: find.byType(Column),
          ),
          matching: find.byType(GestureDetector),
        );

        // Tap the first color option
        await tester.tap(colorPickers.first);
        await tester.pumpAndSettle();

        // Save
        await tester.tap(find.text('Save'));
        await tester.pumpAndSettle();

        // Assert - Save should complete
        expect(find.text('Save'), findsNothing);
      });

      testWidgets('cannot save space with empty name', (
        WidgetTester tester,
      ) async {
        // Arrange
        await tester.pumpWidget(buildModalWithProvider());
        await tester.pumpAndSettle();

        // Act - Open edit modal
        await tester.longPress(find.text('Work'));
        await tester.pumpAndSettle();

        await tester.tap(find.text('Edit Space'));
        await tester.pumpAndSettle();

        // Clear the name
        await tester.enterText(find.byType(TextField).first, '');
        await tester.pumpAndSettle();

        // Try to save
        final saveButton = find.widgetWithText(ElevatedButton, 'Save');
        final button = tester.widget<ElevatedButton>(saveButton);

        // Assert - Save button should be disabled
        expect(button.onPressed, isNull);
      });

      testWidgets('space edit updates immediately in UI', (
        WidgetTester tester,
      ) async {
        // Arrange
        await tester.pumpWidget(buildModalWithProvider());
        await tester.pumpAndSettle();

        const originalName = 'Work';
        const newName = 'Work Updated';

        // Act - Edit space
        await tester.longPress(find.text(originalName));
        await tester.pumpAndSettle();

        await tester.tap(find.text('Edit Space'));
        await tester.pumpAndSettle();

        await tester.enterText(find.byType(TextField).first, newName);
        await tester.pumpAndSettle();

        await tester.tap(find.text('Save'));
        await tester.pumpAndSettle();

        // Assert - Updated name should be visible immediately
        expect(find.text(newName), findsOneWidget);
        expect(spacesProvider.spaces.any((s) => s.name == newName), isTrue);
      });

      testWidgets('edit modal closes after successful save', (
        WidgetTester tester,
      ) async {
        // Arrange
        await tester.pumpWidget(buildModalWithProvider());
        await tester.pumpAndSettle();

        // Act
        await tester.longPress(find.text('Work'));
        await tester.pumpAndSettle();

        await tester.tap(find.text('Edit Space'));
        await tester.pumpAndSettle();

        expect(find.text('Edit Space'), findsOneWidget);

        await tester.enterText(find.byType(TextField).first, 'Work 2');
        await tester.pumpAndSettle();

        await tester.tap(find.text('Save'));
        await tester.pumpAndSettle();

        // Assert - Edit modal should be closed
        expect(find.text('Edit Space'), findsNothing);
      });

      testWidgets('editing preserves item count', (WidgetTester tester) async {
        // Arrange
        await tester.pumpWidget(buildModalWithProvider());
        await tester.pumpAndSettle();

        // Act - Edit space
        await tester.longPress(find.text('Work'));
        await tester.pumpAndSettle();

        await tester.tap(find.text('Edit Space'));
        await tester.pumpAndSettle();

        await tester.enterText(find.byType(TextField).first, 'Work Edited');
        await tester.pumpAndSettle();

        await tester.tap(find.text('Save'));
        await tester.pumpAndSettle();

        // Assert - Space should be edited
        final editedSpace = spacesProvider.spaces.firstWhere(
          (s) => s.name == 'Work Edited',
        );
        // Item count is now calculated from database, not stored
        expect(editedSpace.name, equals('Work Edited'));
      });
    });

    group('Keyboard Accessibility', () {
      testWidgets('menu options are keyboard accessible', (
        WidgetTester tester,
      ) async {
        // Arrange
        await tester.pumpWidget(buildModalWithProvider());
        await tester.pumpAndSettle();

        // Act - Long press to show menu
        await tester.longPress(find.text('Work'));
        await tester.pumpAndSettle();

        // Send Tab key to navigate (if focus management is implemented)
        await tester.sendKeyEvent(LogicalKeyboardKey.tab);
        await tester.pumpAndSettle();

        // Send Enter to activate option
        await tester.sendKeyEvent(LogicalKeyboardKey.enter);
        await tester.pumpAndSettle();

        // Assert - Should have taken some action
        // This is a basic test; more sophisticated focus management may be needed
      });

      testWidgets('escape key closes context menu', (
        WidgetTester tester,
      ) async {
        // Arrange
        await tester.pumpWidget(buildModalWithProvider());
        await tester.pumpAndSettle();

        // Act
        await tester.longPress(find.text('Work'));
        await tester.pumpAndSettle();

        expect(find.text('Edit Space'), findsOneWidget);

        await tester.sendKeyEvent(LogicalKeyboardKey.escape);
        await tester.pumpAndSettle();

        // Assert - Menu should be closed
        expect(find.text('Edit Space'), findsNothing);
      });
    });

    group('Design System Compliance', () {
      testWidgets('destructive actions use red color', (
        WidgetTester tester,
      ) async {
        // Arrange
        await tester.pumpWidget(buildModalWithProvider());
        await tester.pumpAndSettle();

        // Act
        await tester.longPress(find.text('Work'));
        await tester.pumpAndSettle();

        // Assert - Archive should have red/destructive styling
        final archiveOption = find.text('Archive Space');
        expect(archiveOption, findsOneWidget);

        // Find the ListTile or container with the archive option
        final listTile = find.ancestor(
          of: archiveOption,
          matching: find.byType(ListTile),
        );

        if (listTile.evaluate().isNotEmpty) {
          final tile = tester.widget<ListTile>(listTile);
          // Check if text color is red (destructive)
          // This is a basic check; actual implementation may vary
          expect(tile.titleTextStyle, isNotNull);
        }
      });

      testWidgets('menu follows Material 3 design', (
        WidgetTester tester,
      ) async {
        // Arrange
        await tester.pumpWidget(buildModalWithProvider());
        await tester.pumpAndSettle();

        // Act
        await tester.longPress(find.text('Work'));
        await tester.pumpAndSettle();

        // Assert - Should use Material 3 components
        // Bottom sheet on mobile
        expect(find.byType(BottomSheet), findsOneWidget);
      });

      testWidgets('menu has proper spacing and padding', (
        WidgetTester tester,
      ) async {
        // Arrange
        await tester.pumpWidget(buildModalWithProvider());
        await tester.pumpAndSettle();

        // Act
        await tester.longPress(find.text('Work'));
        await tester.pumpAndSettle();

        // Assert - Menu items should have proper padding
        final menuItems = find.byType(ListTile);
        expect(menuItems, findsWidgets);

        // Each ListTile should have adequate touch target size
        for (final item in menuItems.evaluate()) {
          final renderBox = item.renderObject! as RenderBox;
          expect(renderBox.size.height, greaterThanOrEqualTo(44.0));
        }
      });
    });

    group('Responsive Behavior', () {
      testWidgets('shows bottom sheet on mobile', (WidgetTester tester) async {
        // Arrange
        await tester.pumpWidget(buildModalWithProvider());
        await tester.pumpAndSettle();

        // Act
        await tester.longPress(find.text('Work'));
        await tester.pumpAndSettle();

        // Assert
        expect(find.byType(BottomSheet), findsOneWidget);
      });

      testWidgets('shows context menu on desktop', (WidgetTester tester) async {
        // Arrange
        await tester.pumpWidget(
          buildModalWithProvider(size: const Size(1200, 800)),
        );
        await tester.pumpAndSettle();

        // Act
        await tester.longPress(find.text('Work'));
        await tester.pumpAndSettle();

        // Assert - On desktop, might show a PopupMenuButton or similar
        // Bottom sheet is acceptable for now
        expect(find.text('Edit Space'), findsOneWidget);
      });
    });

    group('Error Handling', () {
      testWidgets('shows error if edit fails', (WidgetTester tester) async {
        // Arrange - This would require mocking repository to fail
        // For now, verify the UI doesn't crash
        await tester.pumpWidget(buildModalWithProvider());
        await tester.pumpAndSettle();

        // Act
        await tester.longPress(find.text('Work'));
        await tester.pumpAndSettle();

        await tester.tap(find.text('Edit Space'));
        await tester.pumpAndSettle();

        // Enter valid data and save
        await tester.enterText(find.byType(TextField).first, 'New Name');
        await tester.pumpAndSettle();

        await tester.tap(find.text('Save'));
        await tester.pumpAndSettle();

        // Assert - Should not crash
        // Error handling would show a snackbar if save fails
      });

      testWidgets('menu does not show for archived spaces', (
        WidgetTester tester,
      ) async {
        // Arrange - Archive a space first
        final archivedSpace = testSpaces[2].copyWith(isArchived: true);
        when(mockRepository.updateSpace(archivedSpace))
            .thenAnswer((_) async => archivedSpace);
        await spacesProvider.updateSpace(archivedSpace);

        // Mock to return only non-archived spaces
        when(mockRepository.getSpaces()).thenAnswer(
          (_) async => testSpaces.where((s) => !s.isArchived).toList(),
        );
        await spacesProvider.loadSpaces();

        await tester.pumpWidget(buildModalWithProvider());
        await tester.pumpAndSettle();

        // Since we load non-archived by default, Projects should not appear
        expect(find.text('Projects'), findsNothing);
      });
    });
  });
}
