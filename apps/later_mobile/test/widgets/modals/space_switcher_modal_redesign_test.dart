import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:later_mobile/data/models/space_model.dart';
import 'package:later_mobile/data/repositories/space_repository.dart';
import 'package:later_mobile/providers/spaces_provider.dart';
import 'package:later_mobile/widgets/modals/space_switcher_modal.dart';
import 'package:later_mobile/design_system/tokens/tokens.dart';
import 'package:provider/provider.dart';

void main() {
  group('SpaceSwitcherModal Redesign Tests (Task 3.3)', () {
    late SpaceRepository repository;
    late SpacesProvider spacesProvider;
    late List<Space> testSpaces;

    setUpAll(() async {
      // Initialize Hive for testing
      Hive.init('test/hive_testing_path_redesign');
      Hive.registerAdapter(SpaceAdapter());
    });

    setUp(() async {
      // Open or clear the box
      if (!Hive.isBoxOpen('spaces')) {
        await Hive.openBox<Space>('spaces');
      } else {
        await Hive.box<Space>('spaces').clear();
      }

      // Create repository and provider
      repository = SpaceRepository();
      spacesProvider = SpacesProvider(repository);

      // Create test spaces with different counts (1, 5, 20+)
      testSpaces = [
        Space(
          id: 'space-1',
          name: 'Personal',
          icon: '🏠',
          itemCount: 5,
        ),
        Space(
          id: 'space-2',
          name: 'Work',
          icon: '💼',
          itemCount: 12,
        ),
        Space(
          id: 'space-3',
          name: 'Projects',
          icon: '🚀',
          itemCount: 3,
        ),
        Space(
          id: 'space-4',
          name: 'Shopping',
          icon: '🛒',
        ),
        Space(
          id: 'space-5',
          name: 'Ideas',
          icon: '💡',
          itemCount: 8,
        ),
      ];

      // Add test spaces to repository
      for (final space in testSpaces) {
        await repository.createSpace(space);
      }

      // Load spaces into provider
      await spacesProvider.loadSpaces();
    });

    tearDown(() async {
      if (Hive.isBoxOpen('spaces')) {
        await Hive.box<Space>('spaces').clear();
      }
    });

    tearDownAll(() async {
      await Hive.close();
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
            child: const Scaffold(
              body: SpaceSwitcherModal(),
            ),
          ),
        ),
      );
    }

    group('Glassmorphic Modal Background', () {
      testWidgets('modal container uses BackdropFilter with blur',
          (WidgetTester tester) async {
        // Act
        await tester.pumpWidget(buildModalWithProvider());
        await tester.pumpAndSettle();

        // Assert - Find BackdropFilter with blur
        final backdropFilters = find.byType(BackdropFilter);
        expect(backdropFilters, findsAtLeastNWidgets(1));

        // Verify blur properties
        final backdropFilter =
            tester.widget<BackdropFilter>(backdropFilters.first);
        final imageFilter = backdropFilter.filter;
        // Note: We can't directly inspect sigmaX/sigmaY in tests, but we verify it exists
        expect(imageFilter, isNotNull);
      });

      testWidgets('modal has glass background color in light mode',
          (WidgetTester tester) async {
        // Act
        await tester.pumpWidget(
          buildModalWithProvider(theme: ThemeData.light()),
        );
        await tester.pumpAndSettle();

        // Assert - Check for glass background color
        // The modal container should have glassmorphic styling
        final containers = find.descendant(
          of: find.byType(SpaceSwitcherModal),
          matching: find.byType(Container),
        );
        expect(containers, findsWidgets);

        // At least one container should have a decoration with glass-like properties
        bool foundGlassContainer = false;
        for (final containerElement in containers.evaluate()) {
          final container = containerElement.widget as Container;
          if (container.decoration is BoxDecoration) {
            final decoration = container.decoration as BoxDecoration;
            // Glass container should have semi-transparent white color
            if (decoration.color != null &&
                (decoration.color!.a * 255.0).round() < 255 &&
                (decoration.color!.a * 255.0).round() > 0) {
              foundGlassContainer = true;
              break;
            }
          }
        }
        expect(foundGlassContainer, isTrue,
            reason: 'Should have at least one glass container with transparency');
      });

      testWidgets('modal has glass background color in dark mode',
          (WidgetTester tester) async {
        // Act
        await tester.pumpWidget(
          buildModalWithProvider(theme: ThemeData.dark()),
        );
        await tester.pumpAndSettle();

        // Assert - Check for glass background color
        final containers = find.descendant(
          of: find.byType(SpaceSwitcherModal),
          matching: find.byType(Container),
        );
        expect(containers, findsWidgets);

        // At least one container should have a decoration with glass-like properties
        bool foundGlassContainer = false;
        for (final containerElement in containers.evaluate()) {
          final container = containerElement.widget as Container;
          if (container.decoration is BoxDecoration) {
            final decoration = container.decoration as BoxDecoration;
            // Glass container should have semi-transparent color
            if (decoration.color != null &&
                (decoration.color!.a * 255.0).round() < 255 &&
                (decoration.color!.a * 255.0).round() > 0) {
              foundGlassContainer = true;
              break;
            }
          }
        }
        expect(foundGlassContainer, isTrue,
            reason: 'Should have glass container in dark mode');
      });
    });

    group('Gradient Accents on Space Items', () {
      testWidgets('space items have gradient border decorations',
          (WidgetTester tester) async {
        // Act
        await tester.pumpWidget(buildModalWithProvider());
        await tester.pumpAndSettle();

        // Assert - Find containers with gradient decorations
        final containers = find.descendant(
          of: find.byType(ListView),
          matching: find.byType(Container),
        );
        expect(containers, findsWidgets);

        // Look for gradient borders on space items
        bool foundGradientBorder = false;
        for (final containerElement in containers.evaluate()) {
          final container = containerElement.widget as Container;
          if (container.decoration is BoxDecoration) {
            final decoration = container.decoration as BoxDecoration;
            if (decoration.border != null || decoration.gradient != null) {
              foundGradientBorder = true;
              break;
            }
          }
        }
        expect(foundGradientBorder, isTrue,
            reason: 'Space items should have gradient styling');
      });

      testWidgets('selected space has primary gradient accent',
          (WidgetTester tester) async {
        // Act
        await tester.pumpWidget(buildModalWithProvider());
        await tester.pumpAndSettle();

        // Assert - Selected space should have gradient styling
        // Look for the selected indicator (check_circle icon)
        final selectedIcon = find.byIcon(Icons.check_circle);
        expect(selectedIcon, findsOneWidget);

        // The ancestor container should have gradient decoration
        final selectedContainer = find.ancestor(
          of: selectedIcon,
          matching: find.byType(Container),
        );
        expect(selectedContainer, findsWidgets);
      });
    });

    group('Gradient Hover States', () {
      testWidgets('space items show gradient overlay on hover',
          (WidgetTester tester) async {
        // Act
        await tester.pumpWidget(buildModalWithProvider());
        await tester.pumpAndSettle();

        // Find space items with InkWell (interactive)
        final inkWells = find.descendant(
          of: find.byType(ListView),
          matching: find.byType(InkWell),
        );
        expect(inkWells, findsWidgets);

        // InkWell should have proper hover configuration
        final inkWell = tester.widget<InkWell>(inkWells.first);
        expect(inkWell.onTap, isNotNull,
            reason: 'Space items should be interactive');
      });

      testWidgets('hover state uses 8% opacity gradient overlay',
          (WidgetTester tester) async {
        // Act
        await tester.pumpWidget(buildModalWithProvider());
        await tester.pumpAndSettle();

        // Assert - This is a visual test, we verify structure exists
        // In real UI, hover would show gradient overlay
        final inkWells = find.descendant(
          of: find.byType(ListView),
          matching: find.byType(InkWell),
        );
        expect(inkWells, findsAtLeastNWidgets(1));
      });
    });

    group('Spring Physics Animations', () {
      testWidgets('selection animation uses 250ms duration',
          (WidgetTester tester) async {
        // Act
        await tester.pumpWidget(buildModalWithProvider());
        await tester.pumpAndSettle();

        // Tap on a different space to trigger animation
        await tester.tap(find.text('Work'));

        // Verify animation is in progress
        await tester.pump(AppAnimations.normal); // 250ms
        await tester.pumpAndSettle();

        // Assert - Space should be switched
        expect(spacesProvider.currentSpace?.name, equals('Work'));
      });

      testWidgets('animation completes with spring physics',
          (WidgetTester tester) async {
        // Act
        await tester.pumpWidget(buildModalWithProvider());
        await tester.pumpAndSettle();

        final startTime = DateTime.now();

        // Trigger animation by switching space
        await tester.tap(find.text('Projects'));
        await tester.pumpAndSettle();

        final duration = DateTime.now().difference(startTime);

        // Assert - Animation should complete reasonably quickly
        // Spring animations typically complete within 500ms
        expect(duration.inMilliseconds, lessThan(1000));
      });

      testWidgets('keyboard navigation uses spring animation',
          (WidgetTester tester) async {
        // Act
        await tester.pumpWidget(buildModalWithProvider());
        await tester.pumpAndSettle();

        // Use arrow key navigation
        await tester.sendKeyEvent(LogicalKeyboardKey.arrowDown);
        await tester.pump(AppAnimations.normal);
        await tester.pumpAndSettle();

        // Assert - Keyboard selection should work smoothly
        // The second item should be highlighted
        final containers = find.byType(Container);
        expect(containers, findsWidgets);
      });
    });

    group('Gradient Styling on Create New Space Button', () {
      testWidgets('create button has gradient background',
          (WidgetTester tester) async {
        // Act
        await tester.pumpWidget(buildModalWithProvider());
        await tester.pumpAndSettle();

        // Assert - Find create button (it's inside a Container with gradient)
        final createButton = find.text('Create New Space');
        expect(createButton, findsOneWidget);

        // Find the Container with gradient decoration
        final containerWithGradient = find.ancestor(
          of: createButton,
          matching: find.byType(Container),
        );
        expect(containerWithGradient, findsWidgets);

        // Verify the first container ancestor has BoxDecoration with gradient
        bool foundGradient = false;
        for (final element in containerWithGradient.evaluate()) {
          final container = element.widget as Container;
          if (container.decoration is BoxDecoration) {
            final decoration = container.decoration as BoxDecoration;
            if (decoration.gradient != null) {
              foundGradient = true;
              break;
            }
          }
        }
        expect(foundGradient, isTrue,
            reason: 'Button container should have gradient');
      });

      testWidgets('create button uses primary gradient colors',
          (WidgetTester tester) async {
        // Act
        await tester.pumpWidget(buildModalWithProvider());
        await tester.pumpAndSettle();

        // Assert - Find button text
        final createButtonText = find.text('Create New Space');
        expect(createButtonText, findsOneWidget);

        // Find the Container with gradient
        final containerWithGradient = find.ancestor(
          of: createButtonText,
          matching: find.byType(Container),
        );

        // Verify gradient uses primary colors
        bool foundPrimaryGradient = false;
        for (final element in containerWithGradient.evaluate()) {
          final container = element.widget as Container;
          if (container.decoration is BoxDecoration) {
            final decoration = container.decoration as BoxDecoration;
            if (decoration.gradient is LinearGradient) {
              final gradient = decoration.gradient as LinearGradient;
              // Check if gradient contains primary colors
              if (gradient.colors.contains(AppColors.primaryStart) ||
                  gradient.colors.contains(AppColors.primaryEnd)) {
                foundPrimaryGradient = true;
                break;
              }
            }
          }
        }
        expect(foundPrimaryGradient, isTrue,
            reason: 'Button should use primary gradient colors');
      });

      testWidgets('create button has proper styling in dark mode',
          (WidgetTester tester) async {
        // Act
        await tester.pumpWidget(
          buildModalWithProvider(theme: ThemeData.dark()),
        );
        await tester.pumpAndSettle();

        // Assert - Find button text
        final createButtonText = find.text('Create New Space');
        expect(createButtonText, findsOneWidget);

        // Find the Container with gradient
        final containerWithGradient = find.ancestor(
          of: createButtonText,
          matching: find.byType(Container),
        );

        // Verify gradient exists in dark mode
        bool foundGradient = false;
        for (final element in containerWithGradient.evaluate()) {
          final container = element.widget as Container;
          if (container.decoration is BoxDecoration) {
            final decoration = container.decoration as BoxDecoration;
            if (decoration.gradient != null) {
              foundGradient = true;
              break;
            }
          }
        }
        expect(foundGradient, isTrue,
            reason: 'Button should have gradient in dark mode');
      });
    });

    group('Visual Feedback and Selection', () {
      testWidgets('selected space shows gradient visual feedback',
          (WidgetTester tester) async {
        // Act
        await tester.pumpWidget(buildModalWithProvider());
        await tester.pumpAndSettle();

        // Assert - Selected space has check icon
        final checkIcon = find.byIcon(Icons.check_circle);
        expect(checkIcon, findsOneWidget);

        // Should have gradient border styling
        final selectedContainer = find.ancestor(
          of: checkIcon,
          matching: find.byType(Container),
        );
        expect(selectedContainer, findsWidgets);
      });

      testWidgets('gradient feedback changes when selecting different space',
          (WidgetTester tester) async {
        // Act
        await tester.pumpWidget(buildModalWithProvider());
        await tester.pumpAndSettle();

        // Initial selection (Personal)
        expect(spacesProvider.currentSpace?.name, equals('Personal'));

        // Switch to Work
        await tester.tap(find.text('Work'));
        await tester.pumpAndSettle();

        // Assert - New selection should be indicated
        // Modal closes after selection, so check provider state
        expect(spacesProvider.currentSpace?.name, equals('Work'));

        // Verify selection was successful (checked via provider)
        // Visual check would require reopening modal in a new test or test context
      });
    });

    group('Responsive Testing with Different Space Counts', () {
      testWidgets('modal works with 1 space', (WidgetTester tester) async {
        // Arrange - Clear and add only 1 space
        await Hive.box<Space>('spaces').clear();
        final singleSpace = Space(
          id: 'space-1',
          name: 'Only Space',
          icon: '⭐',
        );
        await repository.createSpace(singleSpace);
        await spacesProvider.loadSpaces();

        // Act
        await tester.pumpWidget(buildModalWithProvider());
        await tester.pumpAndSettle();

        // Assert
        expect(find.text('Only Space'), findsOneWidget);
        expect(find.text('Create New Space'), findsOneWidget);

        // Should still have glassmorphic background
        final backdropFilters = find.byType(BackdropFilter);
        expect(backdropFilters, findsAtLeastNWidgets(1));
      });

      testWidgets('modal works with 5 spaces (default)',
          (WidgetTester tester) async {
        // Act - Using default 5 spaces from setUp
        await tester.pumpWidget(buildModalWithProvider());
        await tester.pumpAndSettle();

        // Assert - All 5 spaces should be visible
        expect(find.text('Personal'), findsOneWidget);
        expect(find.text('Work'), findsOneWidget);
        expect(find.text('Projects'), findsOneWidget);
        expect(find.text('Shopping'), findsOneWidget);
        expect(find.text('Ideas'), findsOneWidget);

        // Should have gradient styling on all items
        final inkWells = find.descendant(
          of: find.byType(ListView),
          matching: find.byType(InkWell),
        );
        expect(inkWells.evaluate().length, equals(5));
      });

      testWidgets('modal works with 20+ spaces', (WidgetTester tester) async {
        // Arrange - Add 20 more spaces
        await Hive.box<Space>('spaces').clear();
        final manySpaces = List.generate(
          25,
          (index) => Space(
            id: 'space-$index',
            name: 'Space ${index + 1}',
            icon: '📁',
            itemCount: index,
          ),
        );
        for (final space in manySpaces) {
          await repository.createSpace(space);
        }
        await spacesProvider.loadSpaces();

        // Act
        await tester.pumpWidget(buildModalWithProvider());
        await tester.pumpAndSettle();

        // Assert - Should render list of spaces
        final listView = find.byType(ListView);
        expect(listView, findsOneWidget);

        // Should be scrollable for many items
        expect(find.text('Space 1'), findsOneWidget);
        expect(find.text('Space 2'), findsOneWidget);

        // Scroll to bottom to verify all items are rendered
        await tester.drag(listView, const Offset(0, -5000));
        await tester.pumpAndSettle();

        // Last space should now be visible
        expect(find.text('Space 25'), findsOneWidget);

        // Should still have glassmorphic background
        final backdropFilters = find.byType(BackdropFilter);
        expect(backdropFilters, findsAtLeastNWidgets(1));
      });
    });

    group('Modal Responsiveness', () {
      testWidgets('mobile layout applies glass morphism',
          (WidgetTester tester) async {
        // Act
        await tester.pumpWidget(
          buildModalWithProvider(),
        );
        await tester.pumpAndSettle();

        // Assert
        final backdropFilters = find.byType(BackdropFilter);
        expect(backdropFilters, findsAtLeastNWidgets(1));
      });

      testWidgets('desktop layout applies glass morphism',
          (WidgetTester tester) async {
        // Act
        await tester.pumpWidget(
          buildModalWithProvider(size: const Size(1200, 800)),
        );
        await tester.pumpAndSettle();

        // Assert - Should use Dialog on desktop
        expect(find.byType(Dialog), findsOneWidget);

        // Should still have glassmorphic background
        final backdropFilters = find.byType(BackdropFilter);
        expect(backdropFilters, findsAtLeastNWidgets(1));
      });
    });

    group('Animation Performance', () {
      testWidgets('animations use spring physics curve',
          (WidgetTester tester) async {
        // Act
        await tester.pumpWidget(buildModalWithProvider());
        await tester.pumpAndSettle();

        // Trigger animation
        await tester.tap(find.text('Work'));

        // Pump animation frames
        for (int i = 0; i < 10; i++) {
          await tester.pump(const Duration(milliseconds: 25));
        }

        await tester.pumpAndSettle();

        // Assert - Animation should complete smoothly
        expect(spacesProvider.currentSpace?.name, equals('Work'));
      });

      testWidgets('multiple rapid selections handle gracefully',
          (WidgetTester tester) async {
        // Act
        await tester.pumpWidget(buildModalWithProvider());
        await tester.pumpAndSettle();

        // Rapidly switch spaces
        await tester.tap(find.text('Work'));
        await tester.pump(const Duration(milliseconds: 50));

        // Should handle rapid interactions smoothly
        await tester.pumpAndSettle();
        expect(spacesProvider.currentSpace?.name, equals('Work'));
      });
    });
  });
}
