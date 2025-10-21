import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:later_mobile/widgets/navigation/icon_only_bottom_nav.dart';
import 'package:later_mobile/core/theme/app_colors.dart';
import 'package:later_mobile/core/theme/app_spacing.dart';

void main() {
  group('IconOnlyBottomNav', () {
    testWidgets('renders with correct height', (WidgetTester tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            bottomNavigationBar: IconOnlyBottomNav(
              currentIndex: 0,
              onDestinationSelected: (_) {},
            ),
          ),
        ),
      );

      // Find the container with the navigation bar
      final containerFinder = find.byType(Container);
      expect(containerFinder, findsWidgets);

      // Verify height is 60px as per Phase 2 spec
      final container = tester.widget<Container>(
        containerFinder.first,
      );
      expect(container.constraints?.minHeight, 60.0);
    });

    testWidgets('renders three icon buttons (Home, Search, Settings)',
        (WidgetTester tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            bottomNavigationBar: IconOnlyBottomNav(
              currentIndex: 0,
              onDestinationSelected: (_) {},
            ),
          ),
        ),
      );

      // Find icons - home is active (filled), others are outlined
      expect(find.byIcon(Icons.home), findsOneWidget);
      expect(find.byIcon(Icons.search_outlined), findsOneWidget);
      expect(find.byIcon(Icons.settings_outlined), findsOneWidget);
    });

    testWidgets('shows gradient underline for active tab',
        (WidgetTester tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            bottomNavigationBar: IconOnlyBottomNav(
              currentIndex: 0,
              onDestinationSelected: (_) {},
            ),
          ),
        ),
      );

      // Find the GradientUnderline widget
      final underlineFinder = find.byType(AnimatedContainer);
      expect(underlineFinder, findsWidgets);

      await tester.pumpAndSettle();

      // Verify one underline is visible (for active tab)
      final activeUnderlines = tester.widgetList<AnimatedContainer>(
        underlineFinder,
      ).where((container) {
        return container.decoration is BoxDecoration &&
            (container.decoration as BoxDecoration).gradient != null;
      });

      expect(activeUnderlines.length, greaterThan(0));
    });

    testWidgets('changes selection when tapping different tab',
        (WidgetTester tester) async {
      int selectedIndex = 0;

      await tester.pumpWidget(
        MaterialApp(
          home: StatefulBuilder(
            builder: (context, setState) {
              return Scaffold(
                bottomNavigationBar: IconOnlyBottomNav(
                  currentIndex: selectedIndex,
                  onDestinationSelected: (index) {
                    setState(() => selectedIndex = index);
                  },
                ),
              );
            },
          ),
        ),
      );

      // Tap search icon (middle button)
      await tester.tap(find.byIcon(Icons.search_outlined));
      await tester.pumpAndSettle();

      // Verify selection changed
      expect(selectedIndex, 1);

      // Tap settings icon (last button)
      await tester.tap(find.byIcon(Icons.settings_outlined));
      await tester.pumpAndSettle();

      // Verify selection changed again
      expect(selectedIndex, 2);
    });

    testWidgets('active tab shows filled icon', (WidgetTester tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            bottomNavigationBar: IconOnlyBottomNav(
              currentIndex: 0,
              onDestinationSelected: (_) {},
            ),
          ),
        ),
      );

      // Home is active (index 0), so should show filled icon
      expect(find.byIcon(Icons.home), findsOneWidget);
      expect(find.byIcon(Icons.home_outlined), findsNothing);

      // Search and Settings are inactive, should show outlined icons
      expect(find.byIcon(Icons.search_outlined), findsOneWidget);
      expect(find.byIcon(Icons.settings_outlined), findsOneWidget);
    });

    testWidgets('inactive tabs show gray icons', (WidgetTester tester) async {
      await tester.pumpWidget(
        MaterialApp(
          theme: ThemeData.light(),
          home: Scaffold(
            bottomNavigationBar: IconOnlyBottomNav(
              currentIndex: 0,
              onDestinationSelected: (_) {},
            ),
          ),
        ),
      );

      await tester.pumpAndSettle();

      // Find the search icon (inactive)
      final searchIcon = tester.widget<Icon>(
        find.byIcon(Icons.search_outlined),
      );

      // Verify it's gray (neutral600 for light mode)
      expect(searchIcon.color, AppColors.neutral600);
    });

    testWidgets('active tab shows white icon', (WidgetTester tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            bottomNavigationBar: IconOnlyBottomNav(
              currentIndex: 0,
              onDestinationSelected: (_) {},
            ),
          ),
        ),
      );

      await tester.pumpAndSettle();

      // Find the home icon (active)
      final homeIcon = tester.widget<Icon>(find.byIcon(Icons.home));

      // Verify it's white
      expect(homeIcon.color, Colors.white);
    });

    testWidgets('respects dark mode', (WidgetTester tester) async {
      await tester.pumpWidget(
        MaterialApp(
          theme: ThemeData.dark(),
          home: Scaffold(
            bottomNavigationBar: IconOnlyBottomNav(
              currentIndex: 1, // Search is active
              onDestinationSelected: (_) {},
            ),
          ),
        ),
      );

      await tester.pumpAndSettle();

      // Find an inactive icon (home)
      final homeIcon = tester.widget<Icon>(
        find.byIcon(Icons.home_outlined),
      );

      // Verify it uses dark mode color (neutral400)
      expect(homeIcon.color, AppColors.neutral400);
    });

    testWidgets('has proper touch targets (48x48px)',
        (WidgetTester tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            bottomNavigationBar: IconOnlyBottomNav(
              currentIndex: 0,
              onDestinationSelected: (_) {},
            ),
          ),
        ),
      );

      // Find all SizedBox widgets with touch target size
      final touchTargets = find.byWidgetPredicate((widget) {
        return widget is SizedBox &&
            widget.width == AppSpacing.minTouchTarget &&
            widget.height == AppSpacing.minTouchTarget;
      });

      // Should have exactly 3 touch targets
      expect(touchTargets, findsNWidgets(3));
    });

    testWidgets('underline animates when selection changes',
        (WidgetTester tester) async {
      int selectedIndex = 0;

      await tester.pumpWidget(
        MaterialApp(
          home: StatefulBuilder(
            builder: (context, setState) {
              return Scaffold(
                bottomNavigationBar: IconOnlyBottomNav(
                  currentIndex: selectedIndex,
                  onDestinationSelected: (index) {
                    setState(() => selectedIndex = index);
                  },
                ),
              );
            },
          ),
        ),
      );

      await tester.pumpAndSettle();

      // Tap search button to change selection
      await tester.tap(find.byIcon(Icons.search_outlined));

      // Pump with duration to capture animation
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 100));

      // Verify animation is in progress (not at final state yet)
      expect(tester.hasRunningAnimations, true);

      // Complete animation
      await tester.pumpAndSettle();

      // Verify animation completed
      expect(tester.hasRunningAnimations, false);
    });

    testWidgets('provides semantic labels for accessibility',
        (WidgetTester tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            bottomNavigationBar: IconOnlyBottomNav(
              currentIndex: 0,
              onDestinationSelected: (_) {},
            ),
          ),
        ),
      );

      // Verify semantic labels exist using Semantics widgets
      final semanticsFinder = find.byType(Semantics);
      expect(semanticsFinder, findsWidgets);

      // Check for semantic labels by finding Semantics with specific properties
      final allSemantics = tester.widgetList<Semantics>(semanticsFinder);
      final labels = allSemantics
          .map((s) => s.properties.label)
          .where((l) => l != null)
          .toList();

      expect(labels, contains('Home navigation (selected)'));
      expect(labels, contains('Search navigation'));
      expect(labels, contains('Settings navigation'));
    });

    testWidgets('shows tooltips on long press', (WidgetTester tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            bottomNavigationBar: IconOnlyBottomNav(
              currentIndex: 0,
              onDestinationSelected: (_) {},
            ),
          ),
        ),
      );

      // Long press on search button
      await tester.longPress(find.byIcon(Icons.search_outlined));
      await tester.pumpAndSettle();

      // Verify tooltip appears
      expect(find.text('Search items'), findsOneWidget);
    });

    testWidgets('gradient underline has correct dimensions',
        (WidgetTester tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            bottomNavigationBar: IconOnlyBottomNav(
              currentIndex: 0,
              onDestinationSelected: (_) {},
            ),
          ),
        ),
      );

      await tester.pumpAndSettle();

      // Find the underline container
      final underlineContainers = tester.widgetList<AnimatedContainer>(
        find.byType(AnimatedContainer),
      ).where((container) {
        final decoration = container.decoration;
        return decoration is BoxDecoration &&
               decoration.gradient != null &&
               container.constraints?.maxHeight == 3.0; // 3px height
      });

      expect(underlineContainers.length, greaterThan(0));

      // Verify underline dimensions (3px height, 32px width)
      final underline = underlineContainers.first;
      expect(underline.constraints?.maxHeight, 3.0);
      expect(underline.constraints?.maxWidth, 32.0);
    });
  });
}
