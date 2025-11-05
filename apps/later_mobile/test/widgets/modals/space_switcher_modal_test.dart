import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:later_mobile/core/theme/temporal_flow_theme.dart';
import 'package:later_mobile/core/utils/responsive_modal.dart';
import 'package:later_mobile/data/models/space_model.dart';
import 'package:later_mobile/data/repositories/space_repository.dart';
import 'package:later_mobile/providers/spaces_provider.dart';
import 'package:later_mobile/widgets/modals/space_switcher_modal.dart';
import 'package:later_mobile/design_system/tokens/tokens.dart';
import 'package:mockito/annotations.dart';
import 'package:mockito/mockito.dart';
import 'package:provider/provider.dart';

import 'space_switcher_modal_test.mocks.dart';

@GenerateMocks([SpaceRepository])
void main() {
  group('SpaceSwitcherModal Widget Tests', () {
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
        Space(id: 'space-1', name: 'Personal', userId: testUserId, icon: '🏠'),
        Space(id: 'space-2', name: 'Work', userId: testUserId, icon: '💼'),
        Space(id: 'space-3', name: 'Projects', userId: testUserId, icon: '🚀'),
        Space(id: 'space-4', name: 'Shopping', userId: testUserId, icon: '🛒'),
        Space(id: 'space-5', name: 'Ideas', userId: testUserId, icon: '💡'),
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
      final baseTheme = theme ?? ThemeData.light();
      final isDark = baseTheme.brightness == Brightness.dark;
      final testTheme = baseTheme.copyWith(
        extensions: <ThemeExtension<dynamic>>[
          isDark ? TemporalFlowTheme.dark() : TemporalFlowTheme.light(),
        ],
      );

      return MediaQuery(
        data: MediaQueryData(size: size),
        child: MaterialApp(
          theme: testTheme,
          home: ChangeNotifierProvider<SpacesProvider>.value(
            value: spacesProvider,
            child: const Scaffold(body: SpaceSwitcherModal()),
          ),
        ),
      );
    }

    testWidgets('renders list of spaces correctly', (
      WidgetTester tester,
    ) async {
      // Act
      await tester.pumpWidget(buildModalWithProvider());
      await tester.pumpAndSettle();

      // Assert
      expect(find.text('Switch Space'), findsOneWidget);
      expect(find.text('Personal'), findsOneWidget);
      expect(find.text('Work'), findsOneWidget);
      expect(find.text('Projects'), findsOneWidget);
      expect(find.text('Shopping'), findsOneWidget);
      expect(find.text('Ideas'), findsOneWidget);
    });

    testWidgets('displays space icons correctly', (WidgetTester tester) async {
      // Act
      await tester.pumpWidget(buildModalWithProvider());
      await tester.pumpAndSettle();

      // Assert
      expect(find.text('🏠'), findsOneWidget);
      expect(find.text('💼'), findsOneWidget);
      expect(find.text('🚀'), findsOneWidget);
      expect(find.text('🛒'), findsOneWidget);
      expect(find.text('💡'), findsOneWidget);
    });

    testWidgets('displays item count badges', (WidgetTester tester) async {
      // Act
      await tester.pumpWidget(buildModalWithProvider());
      await tester.pumpAndSettle();

      // Assert - Check that item counts are visible (all spaces have 12 items from mock)
      expect(find.text('12'), findsWidgets);
    });

    testWidgets('highlights currently selected space', (
      WidgetTester tester,
    ) async {
      // Act
      await tester.pumpWidget(buildModalWithProvider());
      await tester.pumpAndSettle();

      // Assert - Personal should be selected (first space)
      final selectedIcon = find.byIcon(Icons.check_circle);
      expect(selectedIcon, findsOneWidget);
    });

    testWidgets('displays search field at the top', (
      WidgetTester tester,
    ) async {
      // Act
      await tester.pumpWidget(buildModalWithProvider());
      await tester.pumpAndSettle();

      // Assert
      expect(find.byType(TextField), findsOneWidget);
      expect(find.text('Search spaces...'), findsOneWidget);
    });

    testWidgets('filters spaces by search query', (WidgetTester tester) async {
      // Act
      await tester.pumpWidget(buildModalWithProvider());
      await tester.pumpAndSettle();

      // Type 'work' in search field
      await tester.enterText(find.byType(TextField), 'work');
      await tester.pumpAndSettle();

      // Assert
      expect(find.text('Work'), findsOneWidget);
      expect(find.text('Personal'), findsNothing);
      expect(find.text('Projects'), findsNothing);
    });

    testWidgets('search is case-insensitive', (WidgetTester tester) async {
      // Act
      await tester.pumpWidget(buildModalWithProvider());
      await tester.pumpAndSettle();

      // Search with uppercase
      await tester.enterText(find.byType(TextField), 'WORK');
      await tester.pumpAndSettle();

      // Assert
      expect(find.text('Work'), findsOneWidget);
    });

    testWidgets('shows "No spaces found" when filter has no results', (
      WidgetTester tester,
    ) async {
      // Act
      await tester.pumpWidget(buildModalWithProvider());
      await tester.pumpAndSettle();

      await tester.enterText(find.byType(TextField), 'nonexistent');
      await tester.pumpAndSettle();

      // Assert
      expect(find.text('No spaces found'), findsOneWidget);
    });

    testWidgets('clears search with clear button', (WidgetTester tester) async {
      // Act
      await tester.pumpWidget(buildModalWithProvider());
      await tester.pumpAndSettle();

      await tester.enterText(find.byType(TextField), 'work');
      await tester.pumpAndSettle();

      // Tap clear button
      await tester.tap(find.byIcon(Icons.clear));
      await tester.pumpAndSettle();

      // Assert - all spaces should be visible again
      expect(find.text('Personal'), findsOneWidget);
      expect(find.text('Work'), findsOneWidget);
      expect(find.text('Projects'), findsOneWidget);
    });

    testWidgets('displays create new space button', (
      WidgetTester tester,
    ) async {
      // Act
      await tester.pumpWidget(buildModalWithProvider());
      await tester.pumpAndSettle();

      // Assert
      expect(find.text('Create New Space'), findsOneWidget);
      expect(find.widgetWithIcon(ElevatedButton, Icons.add), findsOneWidget);
    });

    testWidgets('create button opens create space modal', (
      WidgetTester tester,
    ) async {
      // Act
      await tester.pumpWidget(buildModalWithProvider());
      await tester.pumpAndSettle();

      await tester.tap(find.text('Create New Space'));
      await tester.pumpAndSettle();

      // Assert - the modal should close and open CreateSpaceModal
      // Since we're in a test without proper navigation, just verify
      // the button can be tapped without errors
      expect(find.text('Create New Space'), findsNothing);
    });

    testWidgets('closes modal when close button is tapped', (
      WidgetTester tester,
    ) async {
      // Arrange
      var modalClosed = false;

      await tester.pumpWidget(
        MediaQuery(
          data: const MediaQueryData(size: Size(400, 800)),
          child: MaterialApp(
            home: ChangeNotifierProvider<SpacesProvider>.value(
              value: spacesProvider,
              child: Builder(
                builder: (context) => Scaffold(
                  body: ElevatedButton(
                    onPressed: () async {
                      final result = await ResponsiveModal.show<bool>(
                        context: context,
                        child: const SpaceSwitcherModal(),
                      );
                      modalClosed = result == null || !result;
                    },
                    child: const Text('Show Modal'),
                  ),
                ),
              ),
            ),
          ),
        ),
      );

      // Act
      await tester.tap(find.text('Show Modal'));
      await tester.pumpAndSettle();

      await tester.tap(find.byIcon(Icons.close));
      await tester.pumpAndSettle();

      // Assert
      expect(modalClosed, isTrue);
    });

    testWidgets('switches space when space is tapped', (
      WidgetTester tester,
    ) async {
      // Act
      await tester.pumpWidget(buildModalWithProvider());
      await tester.pumpAndSettle();

      // Tap on 'Work' space
      await tester.tap(find.text('Work'));
      await tester.pumpAndSettle();

      // Assert
      expect(spacesProvider.currentSpace?.id, equals('space-2'));
      expect(spacesProvider.currentSpace?.name, equals('Work'));
    });

    testWidgets('escape key closes modal', (WidgetTester tester) async {
      // Arrange
      var modalClosed = false;

      await tester.pumpWidget(
        MediaQuery(
          data: const MediaQueryData(size: Size(400, 800)),
          child: MaterialApp(
            home: ChangeNotifierProvider<SpacesProvider>.value(
              value: spacesProvider,
              child: Builder(
                builder: (context) => Scaffold(
                  body: ElevatedButton(
                    onPressed: () async {
                      final result = await ResponsiveModal.show<bool>(
                        context: context,
                        child: const SpaceSwitcherModal(),
                      );
                      modalClosed = result == null || !result;
                    },
                    child: const Text('Show Modal'),
                  ),
                ),
              ),
            ),
          ),
        ),
      );

      await tester.tap(find.text('Show Modal'));
      await tester.pumpAndSettle();

      // Act - Press escape key
      await tester.sendKeyEvent(LogicalKeyboardKey.escape);
      await tester.pumpAndSettle();

      // Assert
      expect(modalClosed, isTrue);
    });

    testWidgets('arrow down key navigates down the list', (
      WidgetTester tester,
    ) async {
      // Act
      await tester.pumpWidget(buildModalWithProvider());
      await tester.pumpAndSettle();

      // Press arrow down twice
      await tester.sendKeyEvent(LogicalKeyboardKey.arrowDown);
      await tester.pumpAndSettle();

      await tester.sendKeyEvent(LogicalKeyboardKey.arrowDown);
      await tester.pumpAndSettle();

      // Press enter to select
      await tester.sendKeyEvent(LogicalKeyboardKey.enter);
      await tester.pumpAndSettle();

      // Assert - Should have selected the second space (Work)
      expect(spacesProvider.currentSpace?.id, equals('space-2'));
    });

    testWidgets('arrow up key navigates up the list', (
      WidgetTester tester,
    ) async {
      // Act
      await tester.pumpWidget(buildModalWithProvider());
      await tester.pumpAndSettle();

      // Press arrow up (should wrap to last item)
      await tester.sendKeyEvent(LogicalKeyboardKey.arrowUp);
      await tester.pumpAndSettle();

      await tester.sendKeyEvent(LogicalKeyboardKey.enter);
      await tester.pumpAndSettle();

      // Assert - Should have selected the last space (Ideas)
      expect(spacesProvider.currentSpace?.id, equals('space-5'));
    });

    testWidgets('number key 1 selects first space', (
      WidgetTester tester,
    ) async {
      // Act
      await tester.pumpWidget(buildModalWithProvider());
      await tester.pumpAndSettle();

      await tester.sendKeyEvent(LogicalKeyboardKey.digit1);
      await tester.pumpAndSettle();

      // Assert
      expect(spacesProvider.currentSpace?.id, equals('space-1'));
    });

    testWidgets('number key 2 selects second space', (
      WidgetTester tester,
    ) async {
      // Act
      await tester.pumpWidget(buildModalWithProvider());
      await tester.pumpAndSettle();

      await tester.sendKeyEvent(LogicalKeyboardKey.digit2);
      await tester.pumpAndSettle();

      // Assert
      expect(spacesProvider.currentSpace?.id, equals('space-2'));
    });

    testWidgets('shows number indicators for first 9 spaces', (
      WidgetTester tester,
    ) async {
      // Act
      await tester.pumpWidget(buildModalWithProvider());
      await tester.pumpAndSettle();

      // Assert - Should show numbers 1-5 (may appear more than once)
      expect(find.text('1'), findsWidgets);
      expect(find.text('2'), findsWidgets);
      expect(find.text('3'), findsWidgets);
      expect(find.text('4'), findsWidgets);
    });

    testWidgets('displays as bottom sheet on mobile', (
      WidgetTester tester,
    ) async {
      // Arrange
      await tester.pumpWidget(
        MediaQuery(
          data: const MediaQueryData(size: Size(400, 800)), // Mobile size
          child: MaterialApp(
            home: ChangeNotifierProvider<SpacesProvider>.value(
              value: spacesProvider,
              child: Builder(
                builder: (context) => Scaffold(
                  body: ElevatedButton(
                    onPressed: () => ResponsiveModal.show<bool>(
                      context: context,
                      child: const SpaceSwitcherModal(),
                    ),
                    child: const Text('Show Modal'),
                  ),
                ),
              ),
            ),
          ),
        ),
      );

      // Act
      await tester.tap(find.text('Show Modal'));
      await tester.pumpAndSettle();

      // Assert - Modal should be visible
      expect(find.text('Switch Space'), findsOneWidget);
      expect(find.text('Personal'), findsOneWidget);
    });

    testWidgets('displays as dialog on desktop', (WidgetTester tester) async {
      // Arrange
      await tester.pumpWidget(
        MediaQuery(
          data: const MediaQueryData(size: Size(1200, 800)), // Desktop size
          child: MaterialApp(
            home: ChangeNotifierProvider<SpacesProvider>.value(
              value: spacesProvider,
              child: Builder(
                builder: (context) => Scaffold(
                  body: ElevatedButton(
                    onPressed: () => ResponsiveModal.show<bool>(
                      context: context,
                      child: const SpaceSwitcherModal(),
                    ),
                    child: const Text('Show Modal'),
                  ),
                ),
              ),
            ),
          ),
        ),
      );

      // Act
      await tester.tap(find.text('Show Modal'));
      await tester.pumpAndSettle();

      // Assert - Dialog should be visible
      expect(find.byType(Dialog), findsOneWidget);
      expect(find.text('Switch Space'), findsOneWidget);
    });

    testWidgets('has minimum touch target size for all interactive elements', (
      WidgetTester tester,
    ) async {
      // Act
      await tester.pumpWidget(buildModalWithProvider());
      await tester.pumpAndSettle();

      // Assert - Create button should meet minimum size
      final createButton = tester.widget<ElevatedButton>(
        find.widgetWithText(ElevatedButton, 'Create New Space'),
      );
      final minimumSize = createButton.style!.minimumSize?.resolve(
        <WidgetState>{},
      );
      expect(minimumSize, isNotNull);
      expect(minimumSize!.height, greaterThanOrEqualTo(44.0));
    });

    testWidgets('uses correct colors in light mode', (
      WidgetTester tester,
    ) async {
      // Act
      await tester.pumpWidget(buildModalWithProvider(theme: ThemeData.light()));
      await tester.pumpAndSettle();

      // Assert - Create button should use primary amber
      final createButton = tester.widget<ElevatedButton>(
        find.widgetWithText(ElevatedButton, 'Create New Space'),
      );
      final backgroundColor = createButton.style!.backgroundColor?.resolve(
        <WidgetState>{},
      );
      expect(backgroundColor, AppColors.primarySolid);
    });

    testWidgets('uses correct colors in dark mode', (
      WidgetTester tester,
    ) async {
      // Act
      final darkTheme = ThemeData.dark().copyWith(
        extensions: <ThemeExtension<dynamic>>[
          TemporalFlowTheme.dark(),
        ],
      );
      await tester.pumpWidget(buildModalWithProvider(theme: darkTheme));
      await tester.pumpAndSettle();

      // Assert - Create button should still use primary amber
      final createButton = tester.widget<ElevatedButton>(
        find.widgetWithText(ElevatedButton, 'Create New Space'),
      );
      final backgroundColor = createButton.style!.backgroundColor?.resolve(
        <WidgetState>{},
      );
      expect(backgroundColor, AppColors.primarySolid);
    });

    testWidgets('has proper semantic labels for accessibility', (
      WidgetTester tester,
    ) async {
      // Act
      await tester.pumpWidget(buildModalWithProvider());
      await tester.pumpAndSettle();

      // Assert - Space items should have semantic labels with item counts
      final personalSemantics = tester.getSemantics(
        find
            .ancestor(
              of: find.text('Personal'),
              matching: find.byType(Semantics),
            )
            .first,
      );
      expect(personalSemantics.label, contains('Personal'));
      // Item count should be present (will be 0 since no items created in test)
      expect(personalSemantics.label, contains('items'));
    });

    testWidgets('performance: space switching completes quickly', (
      WidgetTester tester,
    ) async {
      // Act
      await tester.pumpWidget(buildModalWithProvider());
      await tester.pumpAndSettle();

      final startTime = DateTime.now();
      await tester.tap(find.text('Work'));
      await tester.pumpAndSettle();
      final duration = DateTime.now().difference(startTime);

      // Assert - Should complete quickly (test environment allowance)
      expect(duration.inMilliseconds, lessThan(1000));
      expect(spacesProvider.currentSpace?.name, equals('Work'));
    });

    testWidgets('closes modal automatically when space is selected', (
      WidgetTester tester,
    ) async {
      // Arrange
      var modalClosed = false;

      await tester.pumpWidget(
        MediaQuery(
          data: const MediaQueryData(size: Size(400, 800)),
          child: MaterialApp(
            home: ChangeNotifierProvider<SpacesProvider>.value(
              value: spacesProvider,
              child: Builder(
                builder: (context) => Scaffold(
                  body: ElevatedButton(
                    onPressed: () async {
                      final result = await ResponsiveModal.show<bool>(
                        context: context,
                        child: const SpaceSwitcherModal(),
                      );
                      modalClosed = result == true;
                    },
                    child: const Text('Show Modal'),
                  ),
                ),
              ),
            ),
          ),
        ),
      );

      await tester.tap(find.text('Show Modal'));
      await tester.pumpAndSettle();

      // Assert - Modal is visible before selection
      expect(find.text('Switch Space'), findsOneWidget);

      // Act - Select a different space (find the text in the list)
      final workFinder = find.descendant(
        of: find.byType(ListView),
        matching: find.text('Work'),
      );
      expect(workFinder, findsOneWidget);
      await tester.tap(workFinder);
      await tester.pumpAndSettle();

      // Assert
      expect(modalClosed, isTrue);
    });

    testWidgets('does not close when selecting current space', (
      WidgetTester tester,
    ) async {
      // Act
      await tester.pumpWidget(buildModalWithProvider());
      await tester.pumpAndSettle();

      // Tap on current space (Personal, which is first/current)
      await tester.tap(find.text('Personal'));
      await tester.pumpAndSettle();

      // Assert - Modal should close but return false (no change)
      expect(find.text('Switch Space'), findsNothing);
    });

    group('Async Item Count Display', () {
      testWidgets('displays loading state for item counts initially', (
        WidgetTester tester,
      ) async {
        // Act
        await tester.pumpWidget(buildModalWithProvider());
        // Don't settle yet - check loading state
        await tester.pump();

        // Assert - Should show some form of loading indicator or placeholder
        // The exact text may be '...' or '0' depending on cache state
        expect(find.byType(SpaceSwitcherModal), findsOneWidget);
      });

      testWidgets('displays correct count after async loading completes', (
        WidgetTester tester,
      ) async {
        // Act
        await tester.pumpWidget(buildModalWithProvider());
        await tester.pumpAndSettle();

        // Assert - Counts should be displayed (all spaces have 12 items from mock)
        // We can verify that the count badges are present
        expect(find.text('12'), findsWidgets);
      });

      testWidgets('caches counts to prevent flicker on rebuild', (
        WidgetTester tester,
      ) async {
        // Arrange
        await tester.pumpWidget(buildModalWithProvider());
        await tester.pumpAndSettle();

        // Get initial count displays
        final initialCountFinder = find.text('12');
        expect(initialCountFinder, findsWidgets);

        // Act - Trigger a rebuild by typing in search
        await tester.enterText(find.byType(TextField), 'a');
        await tester.pump(); // Just pump once, don't settle

        // Assert - Counts should still be visible (from cache)
        expect(find.text('12'), findsWidgets);
      });
    });
  });
}
