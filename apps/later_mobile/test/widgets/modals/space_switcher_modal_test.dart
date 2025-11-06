import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:later_mobile/core/theme/temporal_flow_theme.dart';
import 'package:later_mobile/data/models/space_model.dart';
import 'package:later_mobile/design_system/atoms/buttons/primary_button.dart';
import 'package:later_mobile/design_system/atoms/inputs/text_input_field.dart';
import 'package:later_mobile/providers/spaces_provider.dart';
import 'package:later_mobile/widgets/modals/space_switcher_modal.dart';
import 'package:mockito/annotations.dart';
import 'package:mockito/mockito.dart';
import 'package:provider/provider.dart';

import 'space_switcher_modal_test.mocks.dart';

@GenerateMocks([SpacesProvider])
void main() {
  late MockSpacesProvider mockSpacesProvider;
  late List<Space> testSpaces;

  // Test user ID for all test spaces
  const testUserId = 'test-user-id';

  setUp(() {
    mockSpacesProvider = MockSpacesProvider();

    // Create test spaces
    testSpaces = [
      Space(id: 'space-1', name: 'Personal', userId: testUserId, icon: '🏠'),
      Space(id: 'space-2', name: 'Work', userId: testUserId, icon: '💼'),
      Space(id: 'space-3', name: 'Shopping', userId: testUserId, icon: '🛒'),
    ];

    // Mock SpacesProvider to return test spaces
    when(mockSpacesProvider.spaces).thenReturn(testSpaces);
    when(mockSpacesProvider.currentSpace).thenReturn(testSpaces.first);
    when(mockSpacesProvider.isLoading).thenReturn(false);

    // Mock getSpaceItemCount to return consistent counts
    when(mockSpacesProvider.getSpaceItemCount('space-1'))
        .thenAnswer((_) async => 5);
    when(mockSpacesProvider.getSpaceItemCount('space-2'))
        .thenAnswer((_) async => 12);
    when(mockSpacesProvider.getSpaceItemCount('space-3'))
        .thenAnswer((_) async => 3);

    // Mock provider operations
    when(mockSpacesProvider.switchSpace(any)).thenAnswer((_) async {});
    when(mockSpacesProvider.loadSpaces(includeArchived: anyNamed('includeArchived')))
        .thenAnswer((_) async {});
  });

  Widget createTestWidget({required Widget child}) {
    return MaterialApp(
      theme: ThemeData.light().copyWith(
        extensions: <ThemeExtension<dynamic>>[TemporalFlowTheme.light()],
      ),
      home: Scaffold(
        body: ChangeNotifierProvider<SpacesProvider>.value(
          value: mockSpacesProvider,
          child: child,
        ),
      ),
    );
  }

  group('SpaceSwitcherModal - Rendering', () {
    testWidgets('renders list of spaces', (WidgetTester tester) async {
      await tester.pumpWidget(
        createTestWidget(
          child: const SpaceSwitcherModal(),
        ),
      );
      await tester.pumpAndSettle();

      // Should show all space names
      expect(find.text('Personal'), findsOneWidget);
      expect(find.text('Work'), findsOneWidget);
      expect(find.text('Shopping'), findsOneWidget);
    });

    testWidgets('renders search field', (WidgetTester tester) async {
      await tester.pumpWidget(
        createTestWidget(
          child: const SpaceSwitcherModal(),
        ),
      );
      await tester.pumpAndSettle();

      // Should show search field
      expect(find.byType(TextInputField), findsOneWidget);
    });

    testWidgets('renders Create New Space button', (WidgetTester tester) async {
      await tester.pumpWidget(
        createTestWidget(
          child: const SpaceSwitcherModal(),
        ),
      );
      await tester.pumpAndSettle();

      // Should show create button
      expect(find.text('Create New Space'), findsOneWidget);
      expect(find.byType(PrimaryButton), findsOneWidget);
    });

    testWidgets('shows current space from provider', (WidgetTester tester) async {
      await tester.pumpWidget(
        createTestWidget(
          child: const SpaceSwitcherModal(),
        ),
      );
      await tester.pumpAndSettle();

      // Current space (Personal) should be displayed
      expect(find.text('Personal'), findsOneWidget);
      // Verify current space is being accessed
      verify(mockSpacesProvider.currentSpace).called(greaterThan(0));
    });

    testWidgets('displays space icons', (WidgetTester tester) async {
      await tester.pumpWidget(
        createTestWidget(
          child: const SpaceSwitcherModal(),
        ),
      );
      await tester.pumpAndSettle();

      // Should show space icons
      expect(find.text('🏠'), findsOneWidget);
      expect(find.text('💼'), findsOneWidget);
      expect(find.text('🛒'), findsOneWidget);
    });

    testWidgets('renders when spaces list is empty', (
      WidgetTester tester,
    ) async {
      when(mockSpacesProvider.spaces).thenReturn([]);

      await tester.pumpWidget(
        createTestWidget(
          child: const SpaceSwitcherModal(),
        ),
      );
      await tester.pumpAndSettle();

      // Modal should still render (shows empty state)
      expect(find.byType(SpaceSwitcherModal), findsOneWidget);
    });

    testWidgets('shows empty state when no spaces', (
      WidgetTester tester,
    ) async {
      when(mockSpacesProvider.spaces).thenReturn([]);

      await tester.pumpWidget(
        createTestWidget(
          child: const SpaceSwitcherModal(),
        ),
      );
      await tester.pumpAndSettle();

      // Should show empty state message
      expect(find.textContaining('No spaces'), findsOneWidget);
    });
  });

  group('SpaceSwitcherModal - Search Functionality', () {
    testWidgets('filters spaces based on search query', (
      WidgetTester tester,
    ) async {
      await tester.pumpWidget(
        createTestWidget(
          child: const SpaceSwitcherModal(),
        ),
      );
      await tester.pumpAndSettle();

      // Enter search query
      await tester.enterText(find.byType(TextInputField), 'Shop');
      await tester.pumpAndSettle();

      // Should only show Shopping space
      expect(find.text('Shopping'), findsOneWidget);
      expect(find.text('Personal'), findsNothing);
      expect(find.text('Work'), findsNothing);
    });

    testWidgets('search is case-insensitive', (WidgetTester tester) async {
      await tester.pumpWidget(
        createTestWidget(
          child: const SpaceSwitcherModal(),
        ),
      );
      await tester.pumpAndSettle();

      // Enter lowercase search query for uppercase space name
      await tester.enterText(find.byType(TextInputField), 'work');
      await tester.pumpAndSettle();

      // Should find Work space
      expect(find.text('Work'), findsOneWidget);
    });

    testWidgets('clears filter when search is cleared', (
      WidgetTester tester,
    ) async {
      await tester.pumpWidget(
        createTestWidget(
          child: const SpaceSwitcherModal(),
        ),
      );
      await tester.pumpAndSettle();

      // Enter search query
      await tester.enterText(find.byType(TextInputField), 'Work');
      await tester.pumpAndSettle();
      expect(find.text('Personal'), findsNothing);

      // Clear search
      await tester.enterText(find.byType(TextInputField), '');
      await tester.pumpAndSettle();

      // Should show all spaces again
      expect(find.text('Personal'), findsOneWidget);
      expect(find.text('Work'), findsOneWidget);
      expect(find.text('Shopping'), findsOneWidget);
    });

    testWidgets('shows no results when search has no matches', (
      WidgetTester tester,
    ) async {
      await tester.pumpWidget(
        createTestWidget(
          child: const SpaceSwitcherModal(),
        ),
      );
      await tester.pumpAndSettle();

      // Enter search query with no matches
      await tester.enterText(find.byType(TextInputField), 'NonExistent');
      await tester.pumpAndSettle();

      // Should show no spaces
      expect(find.text('Personal'), findsNothing);
      expect(find.text('Work'), findsNothing);
      expect(find.text('Shopping'), findsNothing);
    });
  });

  group('SpaceSwitcherModal - Space Selection', () {
    testWidgets('switches space when tapped', (WidgetTester tester) async {
      await tester.pumpWidget(
        createTestWidget(
          child: const SpaceSwitcherModal(),
        ),
      );
      await tester.pumpAndSettle();

      // Tap on Work space
      await tester.tap(find.text('Work'));
      await tester.pumpAndSettle();

      // Should call switchSpace with correct ID
      verify(mockSpacesProvider.switchSpace('space-2')).called(1);
    });

    testWidgets('closes modal when tapping current space', (
      WidgetTester tester,
    ) async {
      await tester.pumpWidget(
        createTestWidget(
          child: const SpaceSwitcherModal(),
        ),
      );
      await tester.pumpAndSettle();

      // Tap on current space (Personal) - should just close, not switch
      await tester.tap(find.text('Personal'));
      await tester.pumpAndSettle();

      // Should not call switchSpace when tapping current space
      verifyNever(mockSpacesProvider.switchSpace(any));
    });
  });

  group('SpaceSwitcherModal - Item Counts', () {
    testWidgets('pre-fetches item counts for all spaces', (
      WidgetTester tester,
    ) async {
      await tester.pumpWidget(
        createTestWidget(
          child: const SpaceSwitcherModal(),
        ),
      );
      await tester.pumpAndSettle();

      // Wait for async pre-fetch
      await tester.pump(const Duration(milliseconds: 100));

      // Should have requested item counts (may be called multiple times during render)
      verify(mockSpacesProvider.getSpaceItemCount(any)).called(greaterThanOrEqualTo(3));
    });

  });

  group('SpaceSwitcherModal - Create New Space', () {
    testWidgets('has Create New Space button', (
      WidgetTester tester,
    ) async {
      await tester.pumpWidget(
        createTestWidget(
          child: const SpaceSwitcherModal(),
        ),
      );
      await tester.pumpAndSettle();

      // Should show Create New Space button
      expect(find.text('Create New Space'), findsOneWidget);
      expect(find.byType(PrimaryButton), findsOneWidget);
    });
  });

  group('SpaceSwitcherModal - Accessibility', () {
    testWidgets('spaces are tappable with semantic meaning', (
      WidgetTester tester,
    ) async {
      await tester.pumpWidget(
        createTestWidget(
          child: const SpaceSwitcherModal(),
        ),
      );
      await tester.pumpAndSettle();

      // All spaces should be findable and tappable
      expect(find.text('Personal'), findsOneWidget);
      expect(find.text('Work'), findsWidgets);
      expect(find.text('Shopping'), findsOneWidget);
    });

    testWidgets('search field is accessible', (WidgetTester tester) async {
      await tester.pumpWidget(
        createTestWidget(
          child: const SpaceSwitcherModal(),
        ),
      );
      await tester.pumpAndSettle();

      // Search field should have proper semantics
      final textField = tester.widget<TextInputField>(
        find.byType(TextInputField),
      );
      expect(textField.hintText, isNotEmpty);
    });
  });
}
