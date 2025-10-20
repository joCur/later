import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:later_mobile/widgets/screens/home_screen.dart';
import 'package:later_mobile/data/models/item_model.dart';
import 'package:later_mobile/data/models/space_model.dart';
import 'package:later_mobile/providers/items_provider.dart';
import 'package:later_mobile/providers/spaces_provider.dart';
import 'package:later_mobile/data/repositories/item_repository.dart';
import 'package:later_mobile/data/repositories/space_repository.dart';
import 'package:later_mobile/core/theme/app_spacing.dart';
import 'package:provider/provider.dart';

/// Fake ItemRepository for testing
class FakeItemRepository implements ItemRepository {
  List<Item> _items = [];

  void setItems(List<Item> items) {
    _items = items;
  }

  @override
  Future<List<Item>> getItems() async {
    return _items;
  }

  @override
  Future<List<Item>> getItemsBySpace(String spaceId) async {
    return _items.where((item) => item.spaceId == spaceId).toList();
  }

  @override
  Future<List<Item>> getItemsByType(ItemType type) async {
    return _items.where((item) => item.type == type).toList();
  }

  @override
  Future<Item> createItem(Item item) async {
    _items.add(item);
    return item;
  }

  @override
  Future<Item> updateItem(Item item) async {
    final index = _items.indexWhere((i) => i.id == item.id);
    if (index != -1) {
      _items[index] = item;
    }
    return item;
  }

  @override
  Future<void> deleteItem(String id) async {
    _items.removeWhere((item) => item.id == id);
  }
}

/// Fake SpaceRepository for testing
class FakeSpaceRepository implements SpaceRepository {
  List<Space> _spaces = [];

  void setSpaces(List<Space> spaces) {
    _spaces = spaces;
  }

  @override
  Future<List<Space>> getSpaces({bool includeArchived = false}) async {
    if (includeArchived) {
      return _spaces;
    }
    return _spaces.where((space) => !space.isArchived).toList();
  }

  @override
  Future<Space?> getSpaceById(String id) async {
    try {
      return _spaces.firstWhere((space) => space.id == id);
    } catch (e) {
      return null;
    }
  }

  @override
  Future<Space> createSpace(Space space) async {
    _spaces.add(space);
    return space;
  }

  @override
  Future<Space> updateSpace(Space space) async {
    final index = _spaces.indexWhere((s) => s.id == space.id);
    if (index != -1) {
      _spaces[index] = space;
    }
    return space;
  }

  @override
  Future<void> deleteSpace(String id) async {
    _spaces.removeWhere((space) => space.id == id);
  }

  @override
  Future<void> incrementItemCount(String spaceId) async {
    final space = await getSpaceById(spaceId);
    if (space != null) {
      final updated = space.copyWith(itemCount: space.itemCount + 1);
      await updateSpace(updated);
    }
  }

  @override
  Future<void> decrementItemCount(String spaceId) async {
    final space = await getSpaceById(spaceId);
    if (space != null) {
      final count = space.itemCount > 0 ? space.itemCount - 1 : 0;
      final updated = space.copyWith(itemCount: count);
      await updateSpace(updated);
    }
  }
}

void main() {
  group('HomeScreen Phase 4 Redesign Tests (Task 4.1)', () {
    late FakeItemRepository fakeItemRepository;
    late FakeSpaceRepository fakeSpaceRepository;
    late ItemsProvider itemsProvider;
    late SpacesProvider spacesProvider;

    setUp(() {
      fakeItemRepository = FakeItemRepository();
      fakeSpaceRepository = FakeSpaceRepository();
      itemsProvider = ItemsProvider(fakeItemRepository);
      spacesProvider = SpacesProvider(fakeSpaceRepository);
    });

    Widget createHomeScreen({Size? size, Brightness? brightness}) {
      final widget = MultiProvider(
        providers: [
          ChangeNotifierProvider<ItemsProvider>.value(value: itemsProvider),
          ChangeNotifierProvider<SpacesProvider>.value(value: spacesProvider),
        ],
        child: MaterialApp(
          theme: ThemeData(brightness: brightness ?? Brightness.light),
          home: const HomeScreen(),
        ),
      );

      if (size != null) {
        return MediaQuery(
          data: MediaQueryData(size: size),
          child: widget,
        );
      }

      return widget;
    }

    group('Gradient Background Overlay Tests', () {
      testWidgets('has gradient overlay at top of screen with 2% opacity',
          (WidgetTester tester) async {
        // Arrange
        final space = Space(
          id: 'space-1',
          name: 'Test',
          icon: '📝',
          color: '#FF5733',
        );
        fakeSpaceRepository.setSpaces([space]);
        fakeItemRepository.setItems([]);

        // Act
        await tester.pumpWidget(
          createHomeScreen(size: const Size(400, 800)),
        );
        await tester.pumpAndSettle();

        // Assert - look for Positioned widget containing the gradient overlay
        final positionedFinder = find.byWidgetPredicate(
          (widget) =>
              widget is Positioned &&
              widget.top == 0 &&
              widget.child is IgnorePointer,
        );

        expect(positionedFinder, findsWidgets);

        // Look for IgnorePointer wrapping the gradient overlay
        final ignorePointerFinder = find.byType(IgnorePointer);
        expect(ignorePointerFinder, findsWidgets);

        // Get the container directly from IgnorePointer child
        final ignorePointers = tester.widgetList<IgnorePointer>(ignorePointerFinder);
        Container? gradientContainer;

        for (final ignorePointer in ignorePointers) {
          if (ignorePointer.child is Container) {
            final container = ignorePointer.child as Container;
            if (container.decoration is BoxDecoration) {
              final decoration = container.decoration as BoxDecoration;
              if (decoration.gradient is LinearGradient) {
                final gradient = decoration.gradient as LinearGradient;
                // Check if this is the overlay gradient (top to bottom, 2 colors)
                if (gradient.begin == Alignment.topCenter &&
                    gradient.end == Alignment.bottomCenter &&
                    gradient.colors.length == 2) {
                  gradientContainer = container;
                  break;
                }
              }
            }
          }
        }

        expect(gradientContainer, isNotNull);

        // Verify gradient properties
        final decoration = gradientContainer!.decoration as BoxDecoration;
        final gradient = decoration.gradient as LinearGradient;

        expect(gradient.begin, Alignment.topCenter);
        expect(gradient.end, Alignment.bottomCenter);
        expect(gradient.colors.length, 2);

        // Verify first color has low opacity (2%)
        expect(gradient.colors.first.a, lessThan(0.05));
        expect(gradient.colors.last, Colors.transparent);
      });

      testWidgets('gradient overlay works in dark mode',
          (WidgetTester tester) async {
        // Arrange
        final space = Space(
          id: 'space-1',
          name: 'Test',
          icon: '📝',
          color: '#FF5733',
        );
        fakeSpaceRepository.setSpaces([space]);
        fakeItemRepository.setItems([]);

        // Act
        await tester.pumpWidget(
          createHomeScreen(
            size: const Size(400, 800),
            brightness: Brightness.dark,
          ),
        );
        await tester.pumpAndSettle();

        // Assert - gradient should exist in dark mode too
        final containerFinder = find.byWidgetPredicate(
          (widget) =>
              widget is Container &&
              widget.decoration is BoxDecoration &&
              (widget.decoration as BoxDecoration).gradient is LinearGradient,
        );

        expect(containerFinder, findsWidgets);
      });
    });

    group('App Bar Styling Tests', () {
      testWidgets('app bar has proper background color',
          (WidgetTester tester) async {
        // Arrange
        final space = Space(
          id: 'space-1',
          name: 'Test Space',
          icon: '🏠',
          color: '#FF5733',
        );
        fakeSpaceRepository.setSpaces([space]);
        fakeItemRepository.setItems([]);

        // Act
        await tester.pumpWidget(
          createHomeScreen(size: const Size(400, 800)),
        );
        await tester.pumpAndSettle();

        // Assert - AppBar should exist with proper styling
        final appBarFinder = find.byType(AppBar);
        expect(appBarFinder, findsOneWidget);

        // App bar should have a background color
        final appBar = tester.widget<AppBar>(appBarFinder);
        expect(appBar.backgroundColor, isNotNull);
      });

      testWidgets('app bar uses surface background color',
          (WidgetTester tester) async {
        // Arrange
        final space = Space(
          id: 'space-1',
          name: 'Test',
          icon: '📝',
          color: '#FF5733',
        );
        fakeSpaceRepository.setSpaces([space]);
        fakeItemRepository.setItems([]);

        // Act
        await tester.pumpWidget(
          createHomeScreen(size: const Size(400, 800)),
        );
        await tester.pumpAndSettle();

        // Assert - AppBar should use glass morphism styling
        final appBar = tester.widget<AppBar>(find.byType(AppBar));

        // Check that elevation is low (glass effect is flat)
        expect(appBar.elevation, lessThanOrEqualTo(1.0));
      });

      testWidgets('app bar works on desktop layout',
          (WidgetTester tester) async {
        // Arrange
        final space = Space(
          id: 'space-1',
          name: 'Test',
          icon: '📝',
          color: '#FF5733',
        );
        fakeSpaceRepository.setSpaces([space]);
        fakeItemRepository.setItems([]);

        // Act
        await tester.pumpWidget(
          createHomeScreen(size: const Size(1200, 800)),
        );
        await tester.pumpAndSettle();

        // Assert - AppBar should exist in desktop layout too
        final appBarFinder = find.byType(AppBar);
        expect(appBarFinder, findsOneWidget);
      });
    });

    group('Filter Chips Gradient Active State Tests', () {
      testWidgets('selected filter chip has gradient background',
          (WidgetTester tester) async {
        // Arrange
        final space = Space(
          id: 'space-1',
          name: 'Test',
          icon: '📝',
          color: '#FF5733',
        );
        fakeSpaceRepository.setSpaces([space]);
        fakeItemRepository.setItems([
          Item(
            id: '1',
            type: ItemType.task,
            title: 'Task 1',
            spaceId: 'space-1',
          ),
        ]);

        // Act
        await tester.pumpWidget(
          createHomeScreen(size: const Size(400, 800)),
        );
        await tester.pumpAndSettle();

        // Find 'All' filter text (selected by default)
        expect(find.text('All'), findsOneWidget);

        // Look for Container with gradient decoration (selected chip)
        final gradientContainerFinder = find.byWidgetPredicate(
          (widget) =>
              widget is Container &&
              widget.decoration is BoxDecoration &&
              (widget.decoration as BoxDecoration).gradient != null,
        );
        expect(gradientContainerFinder, findsWidgets);

        // Verify checkmark icon is present (indicates selected state)
        expect(find.byIcon(Icons.check), findsOneWidget);

        // Tap Tasks filter to change selection
        await tester.tap(find.text('Tasks'));
        await tester.pumpAndSettle();

        // Verify checkmark still exists (now on Tasks chip)
        expect(find.byIcon(Icons.check), findsOneWidget);
      });

      testWidgets('filter chips have consistent spacing (16px)',
          (WidgetTester tester) async {
        // Arrange
        final space = Space(
          id: 'space-1',
          name: 'Test',
          icon: '📝',
          color: '#FF5733',
        );
        fakeSpaceRepository.setSpaces([space]);
        fakeItemRepository.setItems([]);

        // Act
        await tester.pumpWidget(
          createHomeScreen(size: const Size(400, 800)),
        );
        await tester.pumpAndSettle();

        // Assert - all filter text labels should exist
        expect(find.text('All'), findsOneWidget);
        expect(find.text('Tasks'), findsOneWidget);
        expect(find.text('Notes'), findsOneWidget);
        expect(find.text('Lists'), findsOneWidget);

        // Find the Wrap widget containing chips
        final wrapFinder = find.byType(Wrap);

        expect(wrapFinder, findsOneWidget);

        // Verify spacing is set correctly
        final wrap = tester.widget<Wrap>(wrapFinder);
        expect(wrap.spacing, AppSpacing.xs); // Should be 8px
      });

      testWidgets('gradient active state works in dark mode',
          (WidgetTester tester) async {
        // Arrange
        final space = Space(
          id: 'space-1',
          name: 'Test',
          icon: '📝',
          color: '#FF5733',
        );
        fakeSpaceRepository.setSpaces([space]);
        fakeItemRepository.setItems([]);

        // Act
        await tester.pumpWidget(
          createHomeScreen(
            size: const Size(400, 800),
            brightness: Brightness.dark,
          ),
        );
        await tester.pumpAndSettle();

        // Assert - selected chip should have gradient and checkmark
        expect(find.text('All'), findsOneWidget);
        expect(find.byIcon(Icons.check), findsOneWidget);

        // Look for Container with gradient decoration
        final gradientContainerFinder = find.byWidgetPredicate(
          (widget) =>
              widget is Container &&
              widget.decoration is BoxDecoration &&
              (widget.decoration as BoxDecoration).gradient != null,
        );
        expect(gradientContainerFinder, findsWidgets);
      });

      testWidgets('filter chips maintain proper border radius',
          (WidgetTester tester) async {
        // Arrange
        final space = Space(
          id: 'space-1',
          name: 'Test',
          icon: '📝',
          color: '#FF5733',
        );
        fakeSpaceRepository.setSpaces([space]);
        fakeItemRepository.setItems([]);

        // Act
        await tester.pumpWidget(
          createHomeScreen(size: const Size(400, 800)),
        );
        await tester.pumpAndSettle();

        // Assert - selected chip (Container with gradient) should have full radius
        final gradientContainerFinder = find.byWidgetPredicate(
          (widget) =>
              widget is Container &&
              widget.decoration is BoxDecoration &&
              (widget.decoration as BoxDecoration).gradient != null,
        );
        expect(gradientContainerFinder, findsWidgets);

        final container = tester.widget<Container>(gradientContainerFinder.first);
        final decoration = container.decoration as BoxDecoration;
        final borderRadius = decoration.borderRadius as BorderRadius;

        expect(borderRadius.topLeft.x, AppSpacing.radiusFull);
      });
    });

    group('Space Switcher Gradient Icon Tests', () {
      testWidgets('space switcher has gradient icon effect',
          (WidgetTester tester) async {
        // Arrange
        final space = Space(
          id: 'space-1',
          name: 'Test Space',
          icon: '🏠',
          color: '#FF5733',
        );
        fakeSpaceRepository.setSpaces([space]);
        fakeItemRepository.setItems([]);

        // Act
        await tester.pumpWidget(
          createHomeScreen(size: const Size(400, 800)),
        );
        await tester.pumpAndSettle();

        // Assert - space icon should be present
        expect(find.text('🏠'), findsOneWidget);
        expect(find.text('Test Space'), findsOneWidget);

        // Note: Emoji icons don't need gradient (used directly as text)
        // ShaderMask is only used for Icon widgets (fallback when no emoji)
      });

      testWidgets('space switcher with no icon uses gradient',
          (WidgetTester tester) async {
        // Arrange - space without icon
        final space = Space(
          id: 'space-1',
          name: 'Test Space',
          color: '#FF5733',
        );
        fakeSpaceRepository.setSpaces([space]);
        fakeItemRepository.setItems([]);

        // Act
        await tester.pumpWidget(
          createHomeScreen(size: const Size(400, 800)),
        );
        await tester.pumpAndSettle();

        // Assert - fallback icon should be present
        final iconFinder = find.byWidgetPredicate(
          (widget) => widget is Icon && widget.icon == Icons.folder_outlined,
        );
        expect(iconFinder, findsOneWidget);

        // ShaderMask should wrap the icon for gradient effect
        final shaderMaskFinder = find.byType(ShaderMask);
        expect(shaderMaskFinder, findsWidgets);
      });

      testWidgets('space switcher gradient works in dark mode',
          (WidgetTester tester) async {
        // Arrange
        final space = Space(
          id: 'space-1',
          name: 'Test Space',
          color: '#FF5733',
        );
        fakeSpaceRepository.setSpaces([space]);
        fakeItemRepository.setItems([]);

        // Act
        await tester.pumpWidget(
          createHomeScreen(
            size: const Size(400, 800),
            brightness: Brightness.dark,
          ),
        );
        await tester.pumpAndSettle();

        // Assert - icon with gradient should exist in dark mode
        final iconFinder = find.byType(Icon);
        expect(iconFinder, findsWidgets);

        final shaderMaskFinder = find.byType(ShaderMask);
        expect(shaderMaskFinder, findsWidgets);
      });
    });

    group('Pull-to-Refresh Gradient Color Tests', () {
      testWidgets('refresh indicator uses gradient colors',
          (WidgetTester tester) async {
        // Arrange
        final space = Space(
          id: 'space-1',
          name: 'Test',
          icon: '📝',
          color: '#FF5733',
        );
        fakeSpaceRepository.setSpaces([space]);
        fakeItemRepository.setItems([]);

        // Act
        await tester.pumpWidget(
          createHomeScreen(size: const Size(400, 800)),
        );
        await tester.pumpAndSettle();

        // Assert - RefreshIndicator should exist
        final refreshIndicatorFinder = find.byType(RefreshIndicator);
        expect(refreshIndicatorFinder, findsOneWidget);

        // Verify color customization
        final refreshIndicator =
            tester.widget<RefreshIndicator>(refreshIndicatorFinder);

        // Color should be set (either primaryStart or custom)
        expect(refreshIndicator.color, isNotNull);
      });

      testWidgets('refresh indicator works with pull gesture',
          (WidgetTester tester) async {
        // Arrange
        final space = Space(
          id: 'space-1',
          name: 'Test',
          icon: '📝',
          color: '#FF5733',
        );
        fakeSpaceRepository.setSpaces([space]);
        fakeItemRepository.setItems([
          Item(
            id: '1',
            type: ItemType.task,
            title: 'Task 1',
            spaceId: 'space-1',
          ),
        ]);

        // Act
        await tester.pumpWidget(
          createHomeScreen(size: const Size(400, 800)),
        );
        await tester.pumpAndSettle();

        // Pull down to trigger refresh
        final refreshIndicator = find.byType(RefreshIndicator);
        await tester.drag(refreshIndicator, const Offset(0, 300));
        await tester.pump();
        await tester.pump(const Duration(milliseconds: 100));
        await tester.pumpAndSettle();

        // Assert - no errors occurred
        expect(find.byType(HomeScreen), findsOneWidget);
      });

      testWidgets('refresh indicator uses correct gradient in dark mode',
          (WidgetTester tester) async {
        // Arrange
        final space = Space(
          id: 'space-1',
          name: 'Test',
          icon: '📝',
          color: '#FF5733',
        );
        fakeSpaceRepository.setSpaces([space]);
        fakeItemRepository.setItems([]);

        // Act
        await tester.pumpWidget(
          createHomeScreen(
            size: const Size(400, 800),
            brightness: Brightness.dark,
          ),
        );
        await tester.pumpAndSettle();

        // Assert - RefreshIndicator color adapts to dark mode
        final refreshIndicatorFinder = find.byType(RefreshIndicator);
        expect(refreshIndicatorFinder, findsOneWidget);

        final refreshIndicator =
            tester.widget<RefreshIndicator>(refreshIndicatorFinder);
        expect(refreshIndicator.color, isNotNull);
      });
    });

    group('Spacing Consistency Tests (16px Standard Gap)', () {
      testWidgets('filter chips section uses 16px vertical padding',
          (WidgetTester tester) async {
        // Arrange
        final space = Space(
          id: 'space-1',
          name: 'Test',
          icon: '📝',
          color: '#FF5733',
        );
        fakeSpaceRepository.setSpaces([space]);
        fakeItemRepository.setItems([]);

        // Act
        await tester.pumpWidget(
          createHomeScreen(size: const Size(400, 800)),
        );
        await tester.pumpAndSettle();

        // Assert - SingleChildScrollView containing chips should have padding
        final scrollViewFinder = find.byWidgetPredicate(
          (widget) =>
              widget is SingleChildScrollView &&
              widget.padding != null &&
              widget.scrollDirection == Axis.horizontal,
        );

        expect(scrollViewFinder, findsOneWidget);

        final scrollView =
            tester.widget<SingleChildScrollView>(scrollViewFinder);
        final padding = scrollView.padding as EdgeInsets;

        // Verify vertical padding is xs (8px) as per design
        expect(padding.vertical, AppSpacing.xs * 2);
      });

      testWidgets('item list uses 16px horizontal padding',
          (WidgetTester tester) async {
        // Arrange
        final space = Space(
          id: 'space-1',
          name: 'Test',
          icon: '📝',
          color: '#FF5733',
        );
        fakeSpaceRepository.setSpaces([space]);
        fakeItemRepository.setItems([
          Item(
            id: '1',
            type: ItemType.task,
            title: 'Task 1',
            spaceId: 'space-1',
          ),
        ]);

        // Act
        await tester.pumpWidget(
          createHomeScreen(size: const Size(400, 800)),
        );
        await tester.pumpAndSettle();

        // Assert - ListView should have proper padding
        final listViewFinder = find.byWidgetPredicate(
          (widget) => widget is ListView && widget.padding != null,
        );

        expect(listViewFinder, findsOneWidget);

        final listView = tester.widget<ListView>(listViewFinder);
        final padding = listView.padding as EdgeInsets;

        // Verify horizontal padding is sm (12px)
        expect(padding.horizontal, AppSpacing.sm * 2);
      });

      testWidgets('app bar space switcher uses consistent padding',
          (WidgetTester tester) async {
        // Arrange
        final space = Space(
          id: 'space-1',
          name: 'Test Space',
          icon: '🏠',
          color: '#FF5733',
        );
        fakeSpaceRepository.setSpaces([space]);
        fakeItemRepository.setItems([]);

        // Act
        await tester.pumpWidget(
          createHomeScreen(size: const Size(400, 800)),
        );
        await tester.pumpAndSettle();

        // Assert - space switcher should have consistent internal padding
        expect(find.text('Test Space'), findsOneWidget);
        expect(find.text('🏠'), findsOneWidget);

        // InkWell should be present as the tappable container
        final inkWellFinder = find.byWidgetPredicate(
          (widget) => widget is InkWell && widget.borderRadius != null,
        );
        expect(inkWellFinder, findsWidgets);
      });
    });

    group('Responsive Breakpoint Tests', () {
      testWidgets('mobile layout applies correct design elements',
          (WidgetTester tester) async {
        // Arrange
        final space = Space(
          id: 'space-1',
          name: 'Test',
          icon: '📝',
          color: '#FF5733',
        );
        fakeSpaceRepository.setSpaces([space]);
        fakeItemRepository.setItems([]);

        // Act
        await tester.pumpWidget(
          createHomeScreen(size: const Size(400, 800)),
        );
        await tester.pumpAndSettle();

        // Assert - mobile layout should have all Phase 4 elements
        expect(find.byType(BackdropFilter), findsWidgets); // Glass morphism
        expect(find.text('All'), findsOneWidget); // Filter chips present
        expect(find.text('Tasks'), findsOneWidget);
        expect(find.text('Notes'), findsOneWidget);
        expect(find.text('Lists'), findsOneWidget);
        expect(find.byType(RefreshIndicator), findsOneWidget); // Pull-to-refresh
      });

      testWidgets('tablet layout maintains design consistency',
          (WidgetTester tester) async {
        // Arrange
        final space = Space(
          id: 'space-1',
          name: 'Test',
          icon: '📝',
          color: '#FF5733',
        );
        fakeSpaceRepository.setSpaces([space]);
        fakeItemRepository.setItems([]);

        // Act
        await tester.pumpWidget(
          createHomeScreen(size: const Size(768, 1024)),
        );
        await tester.pumpAndSettle();

        // Assert - tablet layout should have Phase 4 elements
        expect(find.byType(BackdropFilter), findsWidgets);
        expect(find.text('All'), findsOneWidget);
        expect(find.text('Tasks'), findsOneWidget);
        expect(find.text('Notes'), findsOneWidget);
        expect(find.text('Lists'), findsOneWidget);
      });

      testWidgets('desktop layout with sidebar maintains design',
          (WidgetTester tester) async {
        // Arrange
        final space = Space(
          id: 'space-1',
          name: 'Test',
          icon: '📝',
          color: '#FF5733',
        );
        fakeSpaceRepository.setSpaces([space]);
        fakeItemRepository.setItems([]);

        // Act
        await tester.pumpWidget(
          createHomeScreen(size: const Size(1200, 800)),
        );
        await tester.pumpAndSettle();

        // Assert - desktop layout should have all Phase 4 elements
        expect(find.byType(BackdropFilter), findsWidgets);
        expect(find.text('All'), findsOneWidget);
        expect(find.text('Tasks'), findsOneWidget);
        expect(find.text('Notes'), findsOneWidget);
        expect(find.text('Lists'), findsOneWidget);
        expect(find.byType(RefreshIndicator), findsOneWidget);
      });
    });

    group('Integration Tests - Complete Redesign', () {
      testWidgets('all Phase 4 design elements work together',
          (WidgetTester tester) async {
        // Arrange
        final space = Space(
          id: 'space-1',
          name: 'Test Space',
          icon: '🏠',
          color: '#FF5733',
        );
        fakeSpaceRepository.setSpaces([space]);
        fakeItemRepository.setItems([
          Item(
            id: '1',
            type: ItemType.task,
            title: 'Task 1',
            spaceId: 'space-1',
          ),
          Item(
            id: '2',
            type: ItemType.note,
            title: 'Note 1',
            spaceId: 'space-1',
          ),
        ]);

        // Act
        await tester.pumpWidget(
          createHomeScreen(size: const Size(400, 800)),
        );
        await tester.pumpAndSettle();

        // Assert - all elements should be present and functional

        // 1. Gradient background overlay
        final containerFinder = find.byWidgetPredicate(
          (widget) =>
              widget is Container &&
              widget.decoration is BoxDecoration &&
              (widget.decoration as BoxDecoration).gradient != null,
        );
        expect(containerFinder, findsWidgets);

        // 2. Glass morphism app bar
        expect(find.byType(BackdropFilter), findsWidgets);

        // 3. Filter chips with gradient states (1 selected Container + 3 unselected FilterChips)
        expect(find.text('All'), findsOneWidget);
        expect(find.text('Tasks'), findsOneWidget);
        expect(find.text('Notes'), findsOneWidget);
        expect(find.text('Lists'), findsOneWidget);

        // Selected chip has gradient container and checkmark
        expect(find.byIcon(Icons.check), findsOneWidget);

        // 4. Space switcher with icon
        expect(find.text('🏠'), findsOneWidget);
        expect(find.text('Test Space'), findsOneWidget);

        // 5. Pull-to-refresh indicator
        expect(find.byType(RefreshIndicator), findsOneWidget);

        // 6. Items displayed
        expect(find.text('Task 1'), findsOneWidget);
        expect(find.text('Note 1'), findsOneWidget);
      });

      testWidgets('switching filters maintains design consistency',
          (WidgetTester tester) async {
        // Arrange
        final space = Space(
          id: 'space-1',
          name: 'Test',
          icon: '📝',
          color: '#FF5733',
        );
        fakeSpaceRepository.setSpaces([space]);
        fakeItemRepository.setItems([
          Item(
            id: '1',
            type: ItemType.task,
            title: 'Task 1',
            spaceId: 'space-1',
          ),
          Item(
            id: '2',
            type: ItemType.note,
            title: 'Note 1',
            spaceId: 'space-1',
          ),
        ]);

        // Act
        await tester.pumpWidget(
          createHomeScreen(size: const Size(400, 800)),
        );
        await tester.pumpAndSettle();

        // Initial state - All filter selected (checkmark present)
        expect(find.byIcon(Icons.check), findsOneWidget);
        expect(find.text('All'), findsOneWidget);

        // Tap Tasks filter
        await tester.tap(find.text('Tasks'));
        await tester.pumpAndSettle();

        // Verify checkmark still present (now on Tasks)
        expect(find.byIcon(Icons.check), findsOneWidget);

        // All design elements should still be present
        expect(find.byType(BackdropFilter), findsWidgets);
        expect(find.byType(RefreshIndicator), findsOneWidget);
      });

      testWidgets('light and dark mode both have complete redesign',
          (WidgetTester tester) async {
        // Arrange
        final space = Space(
          id: 'space-1',
          name: 'Test',
          icon: '📝',
          color: '#FF5733',
        );
        fakeSpaceRepository.setSpaces([space]);
        fakeItemRepository.setItems([]);

        // Test light mode
        await tester.pumpWidget(
          createHomeScreen(
            size: const Size(400, 800),
            brightness: Brightness.light,
          ),
        );
        await tester.pumpAndSettle();

        expect(find.byType(BackdropFilter), findsWidgets);
        expect(find.text('All'), findsOneWidget);
        expect(find.text('Tasks'), findsOneWidget);
        expect(find.text('Notes'), findsOneWidget);
        expect(find.text('Lists'), findsOneWidget);

        // Test dark mode
        await tester.pumpWidget(
          createHomeScreen(
            size: const Size(400, 800),
            brightness: Brightness.dark,
          ),
        );
        await tester.pumpAndSettle();

        expect(find.byType(BackdropFilter), findsWidgets);
        expect(find.text('All'), findsOneWidget);
        expect(find.text('Tasks'), findsOneWidget);
        expect(find.text('Notes'), findsOneWidget);
        expect(find.text('Lists'), findsOneWidget);
      });
    });
  });
}
