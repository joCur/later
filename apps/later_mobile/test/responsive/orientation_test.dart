import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:later_mobile/core/responsive/breakpoints.dart';
import 'package:later_mobile/widgets/navigation/app_sidebar.dart';
import 'package:later_mobile/widgets/navigation/icon_only_bottom_nav.dart';

import '../test_helpers.dart';

/// Responsive Behavior Test Suite: Orientation Tests
///
/// Tests that layouts adapt correctly between portrait and landscape orientations:
/// - Portrait to landscape transitions
/// - Landscape to portrait transitions
/// - Layout adjustments for orientation changes
/// - Mobile phone orientation changes
/// - Tablet orientation changes
///
/// Verifies:
/// - MediaQuery orientation detection
/// - Layout recalculation on orientation change
/// - Navigation visibility changes
/// - Content reflow and positioning
///
/// Success Criteria:
/// - Layouts adapt smoothly to orientation changes
/// - No overflow or clipping issues
/// - Correct breakpoint detection in both orientations
void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  group('Mobile Portrait to Landscape Tests', () {
    testWidgets('iPhone 12 portrait orientation (375x812)', (
      WidgetTester tester,
    ) async {
      const portraitSize = Size(375.0, 812.0);

      await tester.pumpWidget(
        MediaQuery(
          data: const MediaQueryData(size: portraitSize),
          child: testApp(
            Builder(
              builder: (context) {
                final orientation = MediaQuery.of(context).orientation;
                final isMobile = Breakpoints.isMobile(context);
                return Scaffold(
                  body: Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text('Orientation: ${orientation.name}'),
                        Text('Is Mobile: $isMobile'),
                      ],
                    ),
                  ),
                );
              },
            ),
          ),
        ),
      );

      expect(find.text('Orientation: portrait'), findsOneWidget);
      expect(find.text('Is Mobile: true'), findsOneWidget);
    });

    testWidgets('iPhone 12 landscape orientation (812x375)', (
      WidgetTester tester,
    ) async {
      const landscapeSize = Size(812.0, 375.0);

      await tester.pumpWidget(
        MediaQuery(
          data: const MediaQueryData(size: landscapeSize),
          child: testApp(
            Builder(
              builder: (context) {
                final orientation = MediaQuery.of(context).orientation;
                final isMobile = Breakpoints.isMobile(context);
                return Scaffold(
                  body: Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text('Orientation: ${orientation.name}'),
                        Text('Is Mobile: $isMobile'),
                      ],
                    ),
                  ),
                );
              },
            ),
          ),
        ),
      );

      expect(find.text('Orientation: landscape'), findsOneWidget);
      // Width is 812px which is >= 768px (tablet breakpoint)
      expect(
        find.text('Is Mobile: false'),
        findsOneWidget,
        reason: 'Landscape phone width crosses into tablet breakpoint',
      );
    });

    testWidgets('Bottom nav adapts to landscape on phone', (
      WidgetTester tester,
    ) async {
      const landscapeSize = Size(812.0, 375.0);

      await tester.pumpWidget(
        MediaQuery(
          data: const MediaQueryData(size: landscapeSize),
          child: testApp(
            Builder(
              builder: (context) {
                // In landscape, width is 812px (tablet), so bottom nav should hide
                final showBottomNav = Breakpoints.isMobile(context);
                return Scaffold(
                  body: const Center(child: Text('Content')),
                  bottomNavigationBar: showBottomNav
                      ? IconOnlyBottomNav(
                          currentIndex: 0,
                          onDestinationSelected: (_) {},
                        )
                      : null,
                );
              },
            ),
          ),
        ),
      );

      // At 812px width (landscape phone), it crosses into tablet breakpoint
      // so bottom nav should be hidden
      expect(
        find.byType(IconOnlyBottomNav),
        findsNothing,
        reason:
            'Bottom nav should hide when landscape width exceeds mobile breakpoint',
      );
    });

  });

  group('Tablet Portrait to Landscape Tests', () {
    testWidgets('iPad Air portrait orientation (834x1194)', (
      WidgetTester tester,
    ) async {
      const portraitSize = Size(834.0, 1194.0);

      await tester.pumpWidget(
        MediaQuery(
          data: const MediaQueryData(size: portraitSize),
          child: testApp(
            Builder(
              builder: (context) {
                final orientation = MediaQuery.of(context).orientation;
                final isTablet = Breakpoints.isTablet(context);
                return Scaffold(
                  body: Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text('Orientation: ${orientation.name}'),
                        Text('Is Tablet: $isTablet'),
                      ],
                    ),
                  ),
                );
              },
            ),
          ),
        ),
      );

      expect(find.text('Orientation: portrait'), findsOneWidget);
      expect(find.text('Is Tablet: true'), findsOneWidget);
    });

    testWidgets('iPad Air landscape orientation (1194x834)', (
      WidgetTester tester,
    ) async {
      const landscapeSize = Size(1194.0, 834.0);

      await tester.pumpWidget(
        MediaQuery(
          data: const MediaQueryData(size: landscapeSize),
          child: testApp(
            Builder(
              builder: (context) {
                final orientation = MediaQuery.of(context).orientation;
                final isDesktop = Breakpoints.isDesktop(context);
                return Scaffold(
                  body: Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text('Orientation: ${orientation.name}'),
                        Text('Is Desktop: $isDesktop'),
                      ],
                    ),
                  ),
                );
              },
            ),
          ),
        ),
      );

      expect(find.text('Orientation: landscape'), findsOneWidget);
      // Width is 1194px which is >= 1024px (desktop breakpoint)
      expect(
        find.text('Is Desktop: true'),
        findsOneWidget,
        reason: 'Landscape tablet width crosses into desktop breakpoint',
      );
    });

    testWidgets('Sidebar appears in tablet landscape', (
      WidgetTester tester,
    ) async {
      const landscapeSize = Size(1194.0, 834.0);

      await tester.pumpWidget(
        MediaQuery(
          data: const MediaQueryData(size: landscapeSize),
          child: testApp(
            Builder(
              builder: (context) {
                final showSidebar = Breakpoints.isDesktopOrLarger(context);
                return Scaffold(
                  body: Row(
                    children: [
                      if (showSidebar) AppSidebar(onToggleExpanded: () {}),
                      const Expanded(child: Center(child: Text('Content'))),
                    ],
                  ),
                );
              },
            ),
          ),
        ),
      );

      // In landscape with 1194px width (desktop), sidebar should appear
      expect(
        find.byType(AppSidebar),
        findsOneWidget,
        reason: 'Sidebar should appear in tablet landscape mode',
      );
    });

    testWidgets('Grid columns change in landscape', (
      WidgetTester tester,
    ) async {
      const portraitSize = Size(834.0, 1194.0);
      const landscapeSize = Size(1194.0, 834.0);

      // Portrait - should be 2 columns (tablet)
      int? portraitColumns;
      await tester.pumpWidget(
        testApp(
          MediaQuery(
            data: const MediaQueryData(size: portraitSize),
            child: Builder(
              builder: (context) {
                portraitColumns = Breakpoints.getGridColumns(context);
                return Container();
              },
            ),
          ),
        ),
      );

      expect(
        portraitColumns,
        equals(2),
        reason: 'Tablet portrait should have 2 columns',
      );

      // Landscape - should be 3 columns (desktop)
      int? landscapeColumns;
      await tester.pumpWidget(
        testApp(
          MediaQuery(
            data: const MediaQueryData(size: landscapeSize),
            child: Builder(
              builder: (context) {
                landscapeColumns = Breakpoints.getGridColumns(context);
                return Container();
              },
            ),
          ),
        ),
      );

      expect(
        landscapeColumns,
        equals(3),
        reason: 'Tablet landscape should have 3 columns (desktop breakpoint)',
      );
    });
  });

  group('Orientation Transition Animation Tests', () {
    testWidgets('Layout rebuilds on orientation change', (
      WidgetTester tester,
    ) async {
      const portraitSize = Size(375.0, 812.0);
      const landscapeSize = Size(812.0, 375.0);

      // Start in portrait
      await tester.pumpWidget(
        MediaQuery(
          data: const MediaQueryData(size: portraitSize),
          child: testApp(
            Scaffold(
              body: Builder(
                builder: (context) {
                  final orientation = MediaQuery.of(context).orientation;
                  return Center(
                    child: Text('Orientation: ${orientation.name}'),
                  );
                },
              ),
            ),
          ),
        ),
      );

      expect(find.text('Orientation: portrait'), findsOneWidget);

      // Change to landscape
      await tester.pumpWidget(
        MediaQuery(
          data: const MediaQueryData(size: landscapeSize),
          child: testApp(
            Scaffold(
              body: Builder(
                builder: (context) {
                  final orientation = MediaQuery.of(context).orientation;
                  return Center(
                    child: Text('Orientation: ${orientation.name}'),
                  );
                },
              ),
            ),
          ),
        ),
      );

      await tester.pumpAndSettle();

      expect(
        find.text('Orientation: landscape'),
        findsOneWidget,
        reason: 'Widget should rebuild with new orientation',
      );
    });

    testWidgets('No overflow errors during orientation change', (
      WidgetTester tester,
    ) async {
      const portraitSize = Size(375.0, 812.0);
      const landscapeSize = Size(812.0, 375.0);

      // Build complex layout in portrait
      await tester.pumpWidget(
        MediaQuery(
          data: const MediaQueryData(size: portraitSize),
          child: testApp(
            Scaffold(
              appBar: AppBar(title: const Text('App')),
              body: ListView.builder(
                itemCount: 50,
                itemBuilder: (context, index) => ListTile(
                  title: Text('Item $index'),
                  subtitle: Text('Subtitle $index'),
                  leading: const Icon(Icons.star),
                ),
              ),
              bottomNavigationBar: IconOnlyBottomNav(
                currentIndex: 0,
                onDestinationSelected: (_) {},
              ),
            ),
          ),
        ),
      );

      expect(
        tester.takeException(),
        isNull,
        reason: 'Portrait layout should not have errors',
      );

      // Change to landscape
      await tester.pumpWidget(
        MediaQuery(
          data: const MediaQueryData(size: landscapeSize),
          child: testApp(
            Scaffold(
              appBar: AppBar(title: const Text('App')),
              body: ListView.builder(
                itemCount: 50,
                itemBuilder: (context, index) => ListTile(
                  title: Text('Item $index'),
                  subtitle: Text('Subtitle $index'),
                  leading: const Icon(Icons.star),
                ),
              ),
              // Bottom nav hides in landscape (tablet breakpoint)
            ),
          ),
        ),
      );

      await tester.pumpAndSettle();

      expect(
        tester.takeException(),
        isNull,
        reason: 'Landscape layout should not have errors',
      );
    });
  });

  group('Orientation-specific Layout Tests', () {
    testWidgets('Landscape uses horizontal space efficiently', (
      WidgetTester tester,
    ) async {
      const landscapeSize = Size(812.0, 375.0);

      await tester.pumpWidget(
        MediaQuery(
          data: const MediaQueryData(size: landscapeSize),
          child: testApp(
            Scaffold(
              body: Row(
                children: [
                  // Sidebar in landscape
                  Container(
                    width: 240.0,
                    color: Colors.blue,
                    child: const Center(child: Text('Sidebar')),
                  ),
                  // Main content
                  Expanded(
                    child: Container(
                      color: Colors.white,
                      child: const Center(child: Text('Content')),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      );

      // Verify both sidebar and content are visible
      expect(find.text('Sidebar'), findsOneWidget);
      expect(find.text('Content'), findsOneWidget);

      // Content should take remaining space
      final contentSize = tester.getSize(find.text('Content'));
      expect(
        contentSize.width,
        greaterThan(0),
        reason: 'Content should have width in landscape',
      );
    });

    testWidgets('Portrait prioritizes vertical scrolling', (
      WidgetTester tester,
    ) async {
      const portraitSize = Size(375.0, 812.0);

      await tester.pumpWidget(
        MediaQuery(
          data: const MediaQueryData(size: portraitSize),
          child: testApp(
            Scaffold(
              body: ListView.builder(
                itemCount: 100,
                itemBuilder: (context, index) =>
                    ListTile(title: Text('Item $index')),
              ),
            ),
          ),
        ),
      );

      // Verify list is scrollable
      expect(find.text('Item 0'), findsOneWidget);
      expect(
        find.text('Item 99'),
        findsNothing,
        reason: 'Last item should be off-screen initially',
      );

      // Scroll to bottom
      await tester.drag(find.byType(ListView), const Offset(0, -10000));
      await tester.pumpAndSettle();

      // Last item should now be visible
      expect(find.text('Item 99'), findsOneWidget);
    });
  });
}
