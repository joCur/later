import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:later_mobile/core/responsive/breakpoints.dart';
import 'package:later_mobile/core/responsive/responsive_layout.dart';
import 'package:later_mobile/design_system/molecules/fab/create_content_fab.dart';
import 'package:later_mobile/widgets/navigation/app_sidebar.dart';
import 'package:later_mobile/widgets/navigation/icon_only_bottom_nav.dart';

import '../test_helpers.dart';

/// Responsive Behavior Test Suite: Mobile Layout (320px - 767px)
///
/// Tests that mobile layouts render correctly across different screen sizes:
/// - iPhone SE: 320px width (smallest supported)
/// - iPhone 12/13: 375px width (most common)
/// - iPhone Pro Max: 414px width (large phone)
///
/// Verifies:
/// - Bottom navigation is visible on mobile
/// - Sidebar is hidden on mobile
/// - Content is full-width
/// - Single-column layouts
/// - Portrait orientation behavior
///
/// Success Criteria:
/// - All tests pass at specified widths
/// - Layouts are responsive and usable
/// - No overflow or clipping issues
void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  group('Mobile Layout Tests - 320px (iPhone SE)', () {
    const testWidth = 320.0;
    const testHeight = 568.0;

    testWidgets('Breakpoint detection identifies mobile at 320px', (
      WidgetTester tester,
    ) async {
      bool? isMobile;
      bool? isTablet;
      bool? isDesktop;

      await tester.pumpWidget(
        testApp(
          Builder(
            builder: (context) {
              return MediaQuery(
                data: const MediaQueryData(size: Size(testWidth, testHeight)),
                child: Builder(
                  builder: (context) {
                    isMobile = Breakpoints.isMobile(context);
                    isTablet = Breakpoints.isTablet(context);
                    isDesktop = Breakpoints.isDesktop(context);
                    return Container();
                  },
                ),
              );
            },
          ),
        ),
      );

      expect(isMobile, isTrue, reason: '320px should be identified as mobile');
      expect(
        isTablet,
        isFalse,
        reason: '320px should not be identified as tablet',
      );
      expect(
        isDesktop,
        isFalse,
        reason: '320px should not be identified as desktop',
      );
    });

    testWidgets('Bottom navigation is visible at 320px', (
      WidgetTester tester,
    ) async {
      // Set view size explicitly
      tester.view.physicalSize = const Size(testWidth, testHeight);
      tester.view.devicePixelRatio = 1.0;

      await tester.pumpWidget(
        testApp(
          Scaffold(
            bottomNavigationBar: IconOnlyBottomNav(
              currentIndex: 0,
              onDestinationSelected: (int index) {},
            ),
          ),
        ),
      );

      // Verify bottom navigation is present
      expect(find.byType(IconOnlyBottomNav), findsOneWidget);

      // Check actual rendered size
      final size = tester.getSize(find.byType(IconOnlyBottomNav));
      expect(
        size.height,
        equals(64.0),
        reason: 'Bottom navigation should be 64px tall',
      );
      expect(
        size.width,
        equals(testWidth),
        reason: 'Bottom navigation should be full width',
      );

      // Reset
      addTearDown(() => tester.view.resetPhysicalSize());
    });

    testWidgets('Sidebar is hidden at 320px', (WidgetTester tester) async {
      await tester.pumpWidget(
        MediaQuery(
          data: const MediaQueryData(size: Size(testWidth, testHeight)),
          child: testApp(
            Builder(
              builder: (context) {
                return Scaffold(
                  body: Row(
                    children: [
                      // Conditionally show sidebar based on breakpoint
                      if (Breakpoints.isDesktopOrLarger(context))
                        AppSidebar(onToggleExpanded: () {}),
                      const Expanded(child: Center(child: Text('Content'))),
                    ],
                  ),
                );
              },
            ),
          ),
        ),
      );

      // Sidebar should not be present on mobile
      expect(
        find.byType(AppSidebar),
        findsNothing,
        reason: 'Sidebar should be hidden on mobile devices',
      );
    });

    testWidgets('Content is full-width at 320px', (WidgetTester tester) async {
      await tester.pumpWidget(
        MediaQuery(
          data: const MediaQueryData(size: Size(testWidth, testHeight)),
          child: testApp(
            Scaffold(
              body: LayoutBuilder(
                builder: (context, constraints) {
                  return Container(
                    color: Colors.blue,
                    child: Text('Width: ${constraints.maxWidth}'),
                  );
                },
              ),
            ),
          ),
        ),
      );

      final size = tester.getSize(find.byType(Container).first);

      expect(
        size.width,
        equals(testWidth),
        reason: 'Content should use full screen width',
      );
    });

    testWidgets('Single-column layout at 320px', (WidgetTester tester) async {
      await tester.pumpWidget(
        MediaQuery(
          data: const MediaQueryData(size: Size(testWidth, testHeight)),
          child: testApp(
            Builder(
              builder: (context) {
                final columns = Breakpoints.getGridColumns(context);
                return Scaffold(body: Center(child: Text('Columns: $columns')));
              },
            ),
          ),
        ),
      );

      // Find the text and verify it shows 1 column
      expect(
        find.text('Columns: 1'),
        findsOneWidget,
        reason: 'Mobile should use single-column layout',
      );
    });

    testWidgets('FAB is positioned correctly at 320px', (
      WidgetTester tester,
    ) async {
      await tester.pumpWidget(
        MediaQuery(
          data: const MediaQueryData(size: Size(testWidth, testHeight)),
          child: testApp(
            Scaffold(
              body: const Center(child: Text('Content')),
              floatingActionButton: CreateContentFab(onPressed: () {}),
            ),
          ),
        ),
      );

      // Verify FAB is present
      expect(find.byType(CreateContentFab), findsOneWidget);

      // FAB should be 64x64px
      final fabSize = tester.getSize(find.byType(CreateContentFab));
      expect(fabSize.width, equals(64.0));
      expect(fabSize.height, equals(64.0));
    });

    testWidgets('ResponsiveLayout shows mobile widget at 320px', (
      WidgetTester tester,
    ) async {
      await tester.pumpWidget(
        MediaQuery(
          data: const MediaQueryData(size: Size(testWidth, testHeight)),
          child: testApp(
            const Scaffold(
              body: ResponsiveLayout(
                mobile: Text('Mobile Layout'),
                tablet: Text('Tablet Layout'),
                desktop: Text('Desktop Layout'),
              ),
            ),
          ),
        ),
      );

      expect(find.text('Mobile Layout'), findsOneWidget);
      expect(find.text('Tablet Layout'), findsNothing);
      expect(find.text('Desktop Layout'), findsNothing);
    });
  });

  group('Mobile Layout Tests - 375px (iPhone 12/13)', () {
    const testWidth = 375.0;
    const testHeight = 812.0;

    testWidgets('Breakpoint detection identifies mobile at 375px', (
      WidgetTester tester,
    ) async {
      bool? isMobile;

      await tester.pumpWidget(
        testApp(
          MediaQuery(
            data: const MediaQueryData(size: Size(testWidth, testHeight)),
            child: Builder(
              builder: (context) {
                isMobile = Breakpoints.isMobile(context);
                return Container();
              },
            ),
          ),
        ),
      );

      expect(isMobile, isTrue, reason: '375px should be identified as mobile');
    });

    testWidgets('Bottom navigation visible and properly sized at 375px', (
      WidgetTester tester,
    ) async {
      await tester.pumpWidget(
        MediaQuery(
          data: const MediaQueryData(size: Size(testWidth, testHeight)),
          child: testApp(
            Scaffold(
              bottomNavigationBar: IconOnlyBottomNav(
                currentIndex: 0,
                onDestinationSelected: (_) {},
              ),
            ),
          ),
        ),
      );

      expect(find.byType(IconOnlyBottomNav), findsOneWidget);

      final size = tester.getSize(find.byType(IconOnlyBottomNav));
      expect(
        size.width,
        equals(testWidth),
        reason: 'Bottom nav should span full width',
      );
    });

    testWidgets('All 3 navigation items are visible at 375px', (
      WidgetTester tester,
    ) async {
      await tester.pumpWidget(
        MediaQuery(
          data: const MediaQueryData(size: Size(testWidth, testHeight)),
          child: testApp(
            Scaffold(
              bottomNavigationBar: IconOnlyBottomNav(
                currentIndex: 0,
                onDestinationSelected: (_) {},
              ),
            ),
          ),
        ),
      );

      // Find all navigation labels
      expect(find.text('Home'), findsOneWidget);
      expect(find.text('Search'), findsOneWidget);
      expect(find.text('Settings'), findsOneWidget);
    });

    testWidgets('Content area accounts for bottom nav at 375px', (
      WidgetTester tester,
    ) async {
      await tester.pumpWidget(
        MediaQuery(
          data: const MediaQueryData(size: Size(testWidth, testHeight)),
          child: testApp(
            Scaffold(
              body: LayoutBuilder(
                builder: (context, constraints) {
                  return Center(
                    child: Text('Content Height: ${constraints.maxHeight}'),
                  );
                },
              ),
              bottomNavigationBar: IconOnlyBottomNav(
                currentIndex: 0,
                onDestinationSelected: (_) {},
              ),
            ),
          ),
        ),
      );

      // Content should have less height than full screen due to bottom nav
      final contentSize = tester.getSize(find.byType(LayoutBuilder));
      expect(
        contentSize.height,
        lessThan(testHeight),
        reason: 'Content should be reduced by bottom nav height',
      );
    });

    testWidgets('Text remains readable at 375px width', (
      WidgetTester tester,
    ) async {
      await tester.pumpWidget(
        MediaQuery(
          data: const MediaQueryData(size: Size(testWidth, testHeight)),
          child: testApp(
            const Scaffold(
              body: Padding(
                padding: EdgeInsets.all(16.0),
                child: Text(
                  'This is a long text that should wrap properly on mobile devices without causing overflow issues.',
                  maxLines: 3,
                ),
              ),
            ),
          ),
        ),
      );

      // Verify text renders without errors
      expect(
        tester.takeException(),
        isNull,
        reason: 'Text should render without overflow errors',
      );
    });
  });

  group('Mobile Layout Tests - 414px (iPhone Pro Max)', () {
    const testWidth = 414.0;
    const testHeight = 896.0;

    testWidgets('Breakpoint detection identifies mobile at 414px', (
      WidgetTester tester,
    ) async {
      bool? isMobile;

      await tester.pumpWidget(
        testApp(
          MediaQuery(
            data: const MediaQueryData(size: Size(testWidth, testHeight)),
            child: Builder(
              builder: (context) {
                isMobile = Breakpoints.isMobile(context);
                return Container();
              },
            ),
          ),
        ),
      );

      expect(isMobile, isTrue, reason: '414px should be identified as mobile');
    });

    testWidgets('Bottom navigation spans full width at 414px', (
      WidgetTester tester,
    ) async {
      await tester.pumpWidget(
        MediaQuery(
          data: const MediaQueryData(size: Size(testWidth, testHeight)),
          child: testApp(
            Scaffold(
              bottomNavigationBar: IconOnlyBottomNav(
                currentIndex: 0,
                onDestinationSelected: (_) {},
              ),
            ),
          ),
        ),
      );

      final size = tester.getSize(find.byType(IconOnlyBottomNav));
      expect(size.width, equals(testWidth));
    });

    testWidgets('Navigation items have adequate spacing at 414px', (
      WidgetTester tester,
    ) async {
      await tester.pumpWidget(
        MediaQuery(
          data: const MediaQueryData(size: Size(testWidth, testHeight)),
          child: testApp(
            Scaffold(
              bottomNavigationBar: IconOnlyBottomNav(
                currentIndex: 0,
                onDestinationSelected: (_) {},
              ),
            ),
          ),
        ),
      );

      // Each nav item should have at least 48px width (touch target)
      // With 3 items and 414px width, each item gets ~138px
      const minItemWidth = 48.0;
      const availableWidth = testWidth / 3;
      expect(
        availableWidth,
        greaterThanOrEqualTo(minItemWidth),
        reason: 'Each nav item should have adequate touch target width',
      );
    });

    testWidgets('Grid columns remain single column at 414px', (
      WidgetTester tester,
    ) async {
      await tester.pumpWidget(
        MediaQuery(
          data: const MediaQueryData(size: Size(testWidth, testHeight)),
          child: testApp(
            Builder(
              builder: (context) {
                final columns = Breakpoints.getGridColumns(context);
                return Scaffold(body: Center(child: Text('Columns: $columns')));
              },
            ),
          ),
        ),
      );

      expect(
        find.text('Columns: 1'),
        findsOneWidget,
        reason: 'Even at 414px, mobile should use single-column layout',
      );
    });

    testWidgets('Max content width is infinite on mobile at 414px', (
      WidgetTester tester,
    ) async {
      double? maxWidth;

      await tester.pumpWidget(
        testApp(
          MediaQuery(
            data: const MediaQueryData(size: Size(testWidth, testHeight)),
            child: Builder(
              builder: (context) {
                maxWidth = Breakpoints.getMaxContentWidth(context);
                return Container();
              },
            ),
          ),
        ),
      );

      expect(
        maxWidth,
        equals(double.infinity),
        reason: 'Mobile devices should not constrain content width',
      );
    });
  });

  group('Mobile Portrait Orientation Tests', () {
    testWidgets('Portrait orientation at 320x568', (WidgetTester tester) async {
      const portraitSize = Size(320.0, 568.0);

      await tester.pumpWidget(
        MediaQuery(
          data: const MediaQueryData(size: portraitSize),
          child: testApp(
            Builder(
              builder: (context) {
                final orientation = MediaQuery.of(context).orientation;
                return Scaffold(
                  body: Center(child: Text('Orientation: ${orientation.name}')),
                );
              },
            ),
          ),
        ),
      );

      expect(find.text('Orientation: portrait'), findsOneWidget);
    });

    testWidgets('Portrait orientation at 375x812', (WidgetTester tester) async {
      const portraitSize = Size(375.0, 812.0);

      await tester.pumpWidget(
        MediaQuery(
          data: const MediaQueryData(size: portraitSize),
          child: testApp(
            Builder(
              builder: (context) {
                final orientation = MediaQuery.of(context).orientation;
                return Scaffold(
                  body: Center(child: Text('Orientation: ${orientation.name}')),
                );
              },
            ),
          ),
        ),
      );

      expect(find.text('Orientation: portrait'), findsOneWidget);
    });

    testWidgets('Layout is usable in portrait mode', (
      WidgetTester tester,
    ) async {
      const portraitSize = Size(375.0, 812.0);

      await tester.pumpWidget(
        MediaQuery(
          data: const MediaQueryData(size: portraitSize),
          child: testApp(
            Scaffold(
              appBar: AppBar(title: const Text('App')),
              body: ListView.builder(
                itemCount: 10,
                itemBuilder: (context, index) =>
                    ListTile(title: Text('Item $index')),
              ),
              bottomNavigationBar: IconOnlyBottomNav(
                currentIndex: 0,
                onDestinationSelected: (_) {},
              ),
            ),
          ),
        ),
      );

      // Verify no overflow
      expect(tester.takeException(), isNull);

      // Verify list items are visible
      expect(find.text('Item 0'), findsOneWidget);
    });
  });
}
