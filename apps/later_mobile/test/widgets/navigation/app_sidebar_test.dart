import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:later_mobile/data/models/space_model.dart';
import 'package:later_mobile/data/repositories/space_repository.dart';
import 'package:later_mobile/providers/spaces_provider.dart';
import 'package:later_mobile/widgets/navigation/app_sidebar.dart';
import 'package:provider/provider.dart';

/// Mock implementation of SpaceRepository for testing
class MockSpaceRepository extends SpaceRepository {
  List<Space> mockSpaces = [];
  bool shouldThrowError = false;
  String? errorMessage;

  @override
  Future<List<Space>> getSpaces({bool includeArchived = false}) async {
    if (shouldThrowError) {
      throw Exception(errorMessage ?? 'Failed to get spaces');
    }
    if (includeArchived) {
      return List.from(mockSpaces);
    }
    return mockSpaces.where((space) => !space.isArchived).toList();
  }

  @override
  Future<Space?> getSpaceById(String id) async {
    if (shouldThrowError) {
      throw Exception(errorMessage ?? 'Failed to get space');
    }
    try {
      return mockSpaces.firstWhere((space) => space.id == id);
    } catch (_) {
      return null;
    }
  }

  @override
  Future<Space> createSpace(Space space) async {
    if (shouldThrowError) {
      throw Exception(errorMessage ?? 'Failed to create space');
    }
    mockSpaces.add(space);
    return space;
  }

  @override
  Future<Space> updateSpace(Space space) async {
    if (shouldThrowError) {
      throw Exception(errorMessage ?? 'Failed to update space');
    }
    final index = mockSpaces.indexWhere((s) => s.id == space.id);
    if (index != -1) {
      mockSpaces[index] = space;
      return space;
    }
    throw Exception('Space not found');
  }

  @override
  Future<void> deleteSpace(String id) async {
    if (shouldThrowError) {
      throw Exception(errorMessage ?? 'Failed to delete space');
    }
    mockSpaces.removeWhere((space) => space.id == id);
  }

  @override
  Future<void> incrementItemCount(String spaceId) async {
    if (shouldThrowError) {
      throw Exception(errorMessage ?? 'Failed to increment item count');
    }
    final index = mockSpaces.indexWhere((s) => s.id == spaceId);
    if (index != -1) {
      mockSpaces[index] = mockSpaces[index].copyWith(
        itemCount: mockSpaces[index].itemCount + 1,
      );
    }
  }

  @override
  Future<void> decrementItemCount(String spaceId) async {
    if (shouldThrowError) {
      throw Exception(errorMessage ?? 'Failed to decrement item count');
    }
    final index = mockSpaces.indexWhere((s) => s.id == spaceId);
    if (index != -1) {
      final currentCount = mockSpaces[index].itemCount;
      mockSpaces[index] = mockSpaces[index].copyWith(
        itemCount: currentCount > 0 ? currentCount - 1 : 0,
      );
    }
  }
}

void main() {
  group('AppSidebar', () {
    late MockSpaceRepository mockRepository;
    late SpacesProvider spacesProvider;

    setUp(() {
      mockRepository = MockSpaceRepository();
      spacesProvider = SpacesProvider(mockRepository);
    });

    Widget createTestWidget({
      bool isExpanded = true,
      VoidCallback? onToggleExpanded,
    }) {
      return MaterialApp(
        home: ChangeNotifierProvider<SpacesProvider>.value(
          value: spacesProvider,
          child: Scaffold(
            body: AppSidebar(
              isExpanded: isExpanded,
              onToggleExpanded: onToggleExpanded,
            ),
          ),
        ),
      );
    }

    testWidgets('renders in expanded state', (tester) async {
      await tester.pumpWidget(createTestWidget());

      expect(find.text('Spaces'), findsOneWidget);
      expect(find.byType(AppSidebar), findsOneWidget);
    });

    testWidgets('renders in collapsed state', (tester) async {
      await tester.pumpWidget(createTestWidget(isExpanded: false));

      // In collapsed state, "Spaces" text should not be visible
      expect(find.text('Spaces'), findsNothing);
      expect(find.byType(AppSidebar), findsOneWidget);
    });

    testWidgets('displays empty state when no spaces', (tester) async {
      mockRepository.mockSpaces = [];

      await spacesProvider.loadSpaces();

      await tester.pumpWidget(createTestWidget());
      await tester.pumpAndSettle();

      expect(find.text('No spaces yet'), findsOneWidget);
    });

    testWidgets('displays space list with item counts', (tester) async {
      final spaces = [
        Space(
          id: 'space-1',
          name: 'Work',
          icon: '💼',
          itemCount: 5,
        ),
        Space(
          id: 'space-2',
          name: 'Personal',
          icon: '🏠',
          itemCount: 3,
        ),
      ];

      mockRepository.mockSpaces = spaces;

      await spacesProvider.loadSpaces();

      await tester.pumpWidget(createTestWidget());
      await tester.pumpAndSettle();

      // Verify space names are displayed
      expect(find.text('Work'), findsOneWidget);
      expect(find.text('Personal'), findsOneWidget);

      // Verify icons are displayed
      expect(find.text('💼'), findsOneWidget);
      expect(find.text('🏠'), findsOneWidget);

      // Verify item counts are displayed
      expect(find.text('5'), findsOneWidget);
      expect(find.text('3'), findsOneWidget);
    });

    testWidgets('highlights selected space', (tester) async {
      final spaces = [
        Space(id: 'space-1', name: 'Work', itemCount: 5),
        Space(id: 'space-2', name: 'Personal', itemCount: 3),
      ];

      mockRepository.mockSpaces = spaces;

      await spacesProvider.loadSpaces();

      await tester.pumpWidget(createTestWidget());
      await tester.pumpAndSettle();

      // First space should be selected by default
      expect(spacesProvider.currentSpace?.id, equals('space-1'));
    });

    testWidgets('switches space on tap', (tester) async {
      final spaces = [
        Space(id: 'space-1', name: 'Work', itemCount: 5),
        Space(id: 'space-2', name: 'Personal', itemCount: 3),
      ];

      mockRepository.mockSpaces = spaces;

      await spacesProvider.loadSpaces();

      await tester.pumpWidget(createTestWidget());
      await tester.pumpAndSettle();

      // Tap on Personal space
      await tester.tap(find.text('Personal'));
      await tester.pumpAndSettle();

      // Verify current space changed
      expect(spacesProvider.currentSpace?.id, equals('space-2'));
    });

    testWidgets('calls onToggleExpanded when toggle button tapped',
        (tester) async {
      bool toggleCalled = false;

      await tester.pumpWidget(
        createTestWidget(
          onToggleExpanded: () {
            toggleCalled = true;
          },
        ),
      );

      // Find and tap the toggle button
      final toggleButton = find.byIcon(Icons.menu_open);
      expect(toggleButton, findsOneWidget);

      await tester.tap(toggleButton);
      await tester.pumpAndSettle();

      expect(toggleCalled, isTrue);
    });

    testWidgets('shows correct icon in collapsed state', (tester) async {
      await tester.pumpWidget(
        createTestWidget(
          isExpanded: false,
          onToggleExpanded: () {},
        ),
      );

      // In collapsed state, should show menu icon instead of menu_open
      expect(find.byIcon(Icons.menu), findsOneWidget);
      expect(find.byIcon(Icons.menu_open), findsNothing);
    });

    testWidgets('animates width when expanding/collapsing', (tester) async {
      bool isExpanded = true;

      await tester.pumpWidget(
        StatefulBuilder(
          builder: (context, setState) {
            return MaterialApp(
              home: ChangeNotifierProvider<SpacesProvider>.value(
                value: spacesProvider,
                child: Scaffold(
                  body: AppSidebar(
                    isExpanded: isExpanded,
                    onToggleExpanded: () {
                      setState(() {
                        isExpanded = !isExpanded;
                      });
                    },
                  ),
                ),
              ),
            );
          },
        ),
      );

      // Initially expanded (240px)
      final expandedContainer = tester.widget<AnimatedContainer>(
        find.byType(AnimatedContainer).first,
      );
      expect(expandedContainer.constraints?.maxWidth, equals(240.0));

      // Tap toggle
      await tester.tap(find.byIcon(Icons.menu_open));
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 100));

      await tester.pumpAndSettle();

      // Now collapsed (72px)
      final collapsedContainer = tester.widget<AnimatedContainer>(
        find.byType(AnimatedContainer).first,
      );
      expect(collapsedContainer.constraints?.maxWidth, equals(72.0));
    });

    testWidgets('keyboard shortcut 1 switches to first space', (tester) async {
      final spaces = [
        Space(id: 'space-1', name: 'Work', itemCount: 5),
        Space(id: 'space-2', name: 'Personal', itemCount: 3),
      ];

      mockRepository.mockSpaces = spaces;

      await spacesProvider.loadSpaces();
      // Switch to second space first
      await spacesProvider.switchSpace('space-2');

      await tester.pumpWidget(createTestWidget());
      await tester.pumpAndSettle();

      // Simulate pressing "1" key
      await tester.sendKeyEvent(LogicalKeyboardKey.digit1);
      await tester.pumpAndSettle();

      expect(spacesProvider.currentSpace?.id, equals('space-1'));
    });

    testWidgets('keyboard shortcut 2 switches to second space', (tester) async {
      final spaces = [
        Space(id: 'space-1', name: 'Work', itemCount: 5),
        Space(id: 'space-2', name: 'Personal', itemCount: 3),
      ];

      mockRepository.mockSpaces = spaces;

      await spacesProvider.loadSpaces();

      await tester.pumpWidget(createTestWidget());
      await tester.pumpAndSettle();

      // Simulate pressing "2" key
      await tester.sendKeyEvent(LogicalKeyboardKey.digit2);
      await tester.pumpAndSettle();

      expect(spacesProvider.currentSpace?.id, equals('space-2'));
    });

    testWidgets('keyboard shortcuts work for spaces 1-9', (tester) async {
      final spaces = List.generate(
        9,
        (i) => Space(
          id: 'space-${i + 1}',
          name: 'Space ${i + 1}',
          itemCount: i,
        ),
      );

      mockRepository.mockSpaces = spaces;

      await spacesProvider.loadSpaces();

      await tester.pumpWidget(createTestWidget());
      await tester.pumpAndSettle();

      // Test pressing "5" key
      await tester.sendKeyEvent(LogicalKeyboardKey.digit5);
      await tester.pumpAndSettle();

      expect(spacesProvider.currentSpace?.id, equals('space-5'));
    });

    testWidgets('displays settings button in footer', (tester) async {
      await tester.pumpWidget(createTestWidget());

      expect(find.byIcon(Icons.settings_outlined), findsOneWidget);
    });

    testWidgets('shows settings text when expanded', (tester) async {
      await tester.pumpWidget(createTestWidget());

      expect(find.text('Settings'), findsOneWidget);
    });

    testWidgets('hides settings text when collapsed', (tester) async {
      await tester.pumpWidget(createTestWidget(isExpanded: false));

      // Settings text should not be visible in collapsed state
      expect(find.text('Settings'), findsNothing);
      // But icon should still be there
      expect(find.byIcon(Icons.settings_outlined), findsOneWidget);
    });

    testWidgets('has proper semantic labels for accessibility', (tester) async {
      final spaces = [
        Space(id: 'space-1', name: 'Work', icon: '💼', itemCount: 5),
      ];

      mockRepository.mockSpaces = spaces;

      await spacesProvider.loadSpaces();

      await tester.pumpWidget(createTestWidget());
      await tester.pumpAndSettle();

      // Find the space item
      final spaceItem = find.text('Work');
      expect(spaceItem, findsOneWidget);

      // Verify semantic label includes item count and keyboard shortcut
      final semantics = tester.getSemantics(spaceItem);
      expect(
        semantics.label,
        contains('Work, 5 items, keyboard shortcut 1'),
      );
    });

    testWidgets('displays tooltips on hover', (tester) async {
      final spaces = [
        Space(id: 'space-1', name: 'Work', itemCount: 5),
      ];

      mockRepository.mockSpaces = spaces;

      await spacesProvider.loadSpaces();

      await tester.pumpWidget(createTestWidget());
      await tester.pumpAndSettle();

      // Find tooltips (they exist but aren't visible until hover)
      expect(find.byType(Tooltip), findsWidgets);
    });

    testWidgets('collapsed view shows space icon or first letter',
        (tester) async {
      final spaces = [
        Space(id: 'space-1', name: 'Work', icon: '💼', itemCount: 5),
        Space(id: 'space-2', name: 'Personal', itemCount: 3),
      ];

      mockRepository.mockSpaces = spaces;

      await spacesProvider.loadSpaces();

      await tester.pumpWidget(createTestWidget(isExpanded: false));
      await tester.pumpAndSettle();

      // Should show icon for first space
      expect(find.text('💼'), findsOneWidget);
      // Should show first letter for second space (no icon)
      expect(find.text('P'), findsOneWidget);
    });

    testWidgets('maintains minimum touch target size', (tester) async {
      final spaces = [
        Space(id: 'space-1', name: 'Work', itemCount: 5),
      ];

      mockRepository.mockSpaces = spaces;

      await spacesProvider.loadSpaces();

      await tester.pumpWidget(createTestWidget());
      await tester.pumpAndSettle();

      // Each space item should be at least 44px tall (minimum touch target)
      final spaceItemContainer = find
          .ancestor(
            of: find.text('Work'),
            matching: find.byType(Container),
          )
          .first;

      final container = tester.widget<Container>(spaceItemContainer);
      expect(container.constraints?.minHeight ?? 0, greaterThanOrEqualTo(44.0));
    });

    testWidgets('works with dark theme', (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          theme: ThemeData.dark(),
          home: ChangeNotifierProvider<SpacesProvider>.value(
            value: spacesProvider,
            child: const Scaffold(
              body: AppSidebar(),
            ),
          ),
        ),
      );

      expect(find.byType(AppSidebar), findsOneWidget);
    });

    testWidgets('works with light theme', (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          theme: ThemeData.light(),
          home: ChangeNotifierProvider<SpacesProvider>.value(
            value: spacesProvider,
            child: const Scaffold(
              body: AppSidebar(),
            ),
          ),
        ),
      );

      expect(find.byType(AppSidebar), findsOneWidget);
    });
  });
}
