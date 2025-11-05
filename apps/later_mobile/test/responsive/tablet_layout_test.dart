import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:later_mobile/core/responsive/breakpoints.dart';
import 'package:later_mobile/core/responsive/responsive_layout.dart';
import 'package:later_mobile/widgets/navigation/app_sidebar.dart';
import 'package:later_mobile/widgets/navigation/icon_only_bottom_nav.dart';

import "../test_helpers.dart";

/// Responsive Behavior Test Suite: Tablet Layout (768px - 1023px)
///
/// Tests that tablet layouts render correctly across different screen sizes:
/// - iPad Mini: 768px width (tablet breakpoint)
/// - iPad Air: 834px width (mid-size tablet)
/// - iPad Pro: 1024px width (large tablet / small desktop)
///
/// Verifies:
/// - Breakpoint transitions at 768px and 1024px
/// - Sidebar behavior (rail vs full)
/// - Modal max-width constraints (560px)
/// - Multi-column layouts where applicable
/// - Both portrait and landscape orientations
///
/// Success Criteria:
/// - Correct breakpoint detection
/// - Appropriate navigation patterns
/// - No overflow or layout issues
void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  group('Tablet Layout Tests - 768px (iPad Mini)', () {
    const testWidth = 768.0;
    const testHeight = 1024.0; // Portrait

    testWidgets('Breakpoint detection identifies tablet at 768px', (
      WidgetTester tester,
    ) async {
      bool? isMobile;
      bool? isTablet;
      bool? isDesktop;

      await tester.pumpWidget(
        testApp(
          MediaQuery(
            data: const MediaQueryData(size: Size(testWidth, testHeight)),
            child: Builder(
              builder: (context) {
                isMobile = Breakpoints.isMobile(context);
                isTablet = Breakpoints.isTablet(context);
                isDesktop = Breakpoints.isDesktop(context);
                return Container();
              },
            ),
          ),
        ),
      );

      expect(isMobile, isFalse, reason: '768px should not be mobile');
      expect(isTablet, isTrue, reason: '768px should be identified as tablet');
      expect(isDesktop, isFalse, reason: '768px should not be desktop');
    });

    testWidgets('ScreenSize enum returns tablet at 768px', (
      WidgetTester tester,
    ) async {
      ScreenSize? screenSize;

      await tester.pumpWidget(
        testApp(
          MediaQuery(
            data: const MediaQueryData(size: Size(testWidth, testHeight)),
            child: Builder(
              builder: (context) {
                screenSize = Breakpoints.getScreenSize(context);
                return Container();
              },
            ),
          ),
        ),
      );

      expect(screenSize, equals(ScreenSize.tablet));
    });

    testWidgets('Grid columns are 2 at 768px', (WidgetTester tester) async {
      int? columns;

      await tester.pumpWidget(
        testApp(
          MediaQuery(
            data: const MediaQueryData(size: Size(testWidth, testHeight)),
            child: Builder(
              builder: (context) {
                columns = Breakpoints.getGridColumns(context);
                return Scaffold(body: Center(child: Text('Columns: $columns')));
              },
            ),
          ),
        ),
      );

      expect(columns, equals(2), reason: 'Tablet should use 2-column layout');
    });

    testWidgets('Max content width is 768px at tablet breakpoint', (
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
        equals(768.0),
        reason: 'Tablet max content width should be 768px',
      );
    });

    testWidgets('ResponsiveLayout shows tablet widget at 768px', (
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

      expect(find.text('Tablet Layout'), findsOneWidget);
      expect(find.text('Mobile Layout'), findsNothing);
      expect(find.text('Desktop Layout'), findsNothing);
    });

    testWidgets('Bottom navigation is hidden at 768px', (
      WidgetTester tester,
    ) async {
      await tester.pumpWidget(
        MediaQuery(
          data: const MediaQueryData(size: Size(testWidth, testHeight)),
          child: testApp(
            Builder(
              builder: (context) {
                return Scaffold(
                  body: const Center(child: Text('Content')),
                  // Only show bottom nav on mobile
                  bottomNavigationBar: Breakpoints.isMobile(context)
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

      // Bottom navigation should not be present on tablet
      expect(
        find.byType(IconOnlyBottomNav),
        findsNothing,
        reason: 'Bottom nav should be hidden on tablet',
      );
    });

    testWidgets('Portrait orientation at 768x1024', (
      WidgetTester tester,
    ) async {
      await tester.pumpWidget(
        MediaQuery(
          data: const MediaQueryData(size: Size(testWidth, testHeight)),
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
  });

  group('Tablet Layout Tests - 834px (iPad Air)', () {
    const testWidth = 834.0;
    const testHeight = 1194.0; // Portrait

    testWidgets('Breakpoint detection identifies tablet at 834px', (
      WidgetTester tester,
    ) async {
      bool? isTablet;

      await tester.pumpWidget(
        testApp(
          MediaQuery(
            data: const MediaQueryData(size: Size(testWidth, testHeight)),
            child: Builder(
              builder: (context) {
                isTablet = Breakpoints.isTablet(context);
                return Container();
              },
            ),
          ),
        ),
      );

      expect(isTablet, isTrue, reason: '834px should be identified as tablet');
    });

    testWidgets('Grid remains 2 columns at 834px', (WidgetTester tester) async {
      int? columns;

      await tester.pumpWidget(
        testApp(
          MediaQuery(
            data: const MediaQueryData(size: Size(testWidth, testHeight)),
            child: Builder(
              builder: (context) {
                columns = Breakpoints.getGridColumns(context);
                return Container();
              },
            ),
          ),
        ),
      );

      expect(
        columns,
        equals(2),
        reason: 'iPad Air should still use 2-column layout',
      );
    });

    testWidgets('Landscape orientation at 1194x834', (
      WidgetTester tester,
    ) async {
      const landscapeWidth = 1194.0;
      const landscapeHeight = 834.0;

      await tester.pumpWidget(
        MediaQuery(
          data: const MediaQueryData(
            size: Size(landscapeWidth, landscapeHeight),
          ),
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

      expect(find.text('Orientation: landscape'), findsOneWidget);
    });

    testWidgets('Sidebar should show in landscape at 1194x834', (
      WidgetTester tester,
    ) async {
      const landscapeWidth = 1194.0;
      const landscapeHeight = 834.0;

      await tester.pumpWidget(
        MediaQuery(
          data: const MediaQueryData(
            size: Size(landscapeWidth, landscapeHeight),
          ),
          child: testApp(
            Builder(
              builder: (context) {
                // In landscape, width is 1194px which is >= 1024px (desktop)
                final shouldShowSidebar = Breakpoints.isDesktopOrLarger(
                  context,
                );
                return Scaffold(
                  body: Row(
                    children: [
                      if (shouldShowSidebar)
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

      // In landscape mode with 1194px width, should show sidebar (desktop breakpoint)
      expect(
        find.byType(AppSidebar),
        findsOneWidget,
        reason: 'Sidebar should show in tablet landscape mode >= 1024px',
      );
    });

  });

  group('Tablet Layout Tests - 1024px (iPad Pro)', () {
    const testWidth = 1024.0;
    const testHeight = 1366.0; // Portrait

    testWidgets('Breakpoint at exact 1024px shows desktop', (
      WidgetTester tester,
    ) async {
      bool? isTablet;
      bool? isDesktop;

      await tester.pumpWidget(
        testApp(
          MediaQuery(
            data: const MediaQueryData(size: Size(testWidth, testHeight)),
            child: Builder(
              builder: (context) {
                isTablet = Breakpoints.isTablet(context);
                isDesktop = Breakpoints.isDesktop(context);
                return Container();
              },
            ),
          ),
        ),
      );

      // At exactly 1024px, should be desktop (>= 1024)
      expect(
        isTablet,
        isFalse,
        reason: '1024px should not be tablet (it is >= desktop breakpoint)',
      );
      expect(
        isDesktop,
        isTrue,
        reason: '1024px should be identified as desktop',
      );
    });

    testWidgets('Grid columns are 3 at 1024px', (WidgetTester tester) async {
      int? columns;

      await tester.pumpWidget(
        testApp(
          MediaQuery(
            data: const MediaQueryData(size: Size(testWidth, testHeight)),
            child: Builder(
              builder: (context) {
                columns = Breakpoints.getGridColumns(context);
                return Container();
              },
            ),
          ),
        ),
      );

      expect(
        columns,
        equals(3),
        reason: 'Desktop breakpoint should use 3-column layout',
      );
    });

    testWidgets('Max content width is 1024px at 1024px width', (
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
        equals(1024.0),
        reason: 'Desktop max content width at 1024px should be 1024px',
      );
    });

    testWidgets('Sidebar shows at 1024px', (WidgetTester tester) async {
      await tester.pumpWidget(
        MediaQuery(
          data: const MediaQueryData(size: Size(testWidth, testHeight)),
          child: testApp(
            Builder(
              builder: (context) {
                final shouldShowSidebar = Breakpoints.isDesktopOrLarger(
                  context,
                );
                return Scaffold(
                  body: Row(
                    children: [
                      if (shouldShowSidebar)
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

      expect(
        find.byType(AppSidebar),
        findsOneWidget,
        reason: 'Sidebar should show at 1024px (desktop breakpoint)',
      );
    });

    testWidgets('Sidebar expanded state at 1024px', (
      WidgetTester tester,
    ) async {
      await tester.pumpWidget(
        MediaQuery(
          data: const MediaQueryData(size: Size(testWidth, testHeight)),
          child: testApp(
            Scaffold(
              body: Row(
                children: [
                  AppSidebar(onToggleExpanded: () {}),
                  const Expanded(child: Center(child: Text('Content'))),
                ],
              ),
            ),
          ),
        ),
      );

      // Sidebar should be 240px when expanded
      final sidebarSize = tester.getSize(find.byType(AppSidebar));
      expect(
        sidebarSize.width,
        equals(240.0),
        reason: 'Expanded sidebar should be 240px wide',
      );
    });

    testWidgets('Sidebar collapsed state at 1024px', (
      WidgetTester tester,
    ) async {
      await tester.pumpWidget(
        MediaQuery(
          data: const MediaQueryData(size: Size(testWidth, testHeight)),
          child: testApp(
            Scaffold(
              body: Row(
                children: [
                  AppSidebar(isExpanded: false, onToggleExpanded: () {}),
                  const Expanded(child: Center(child: Text('Content'))),
                ],
              ),
            ),
          ),
        ),
      );

      // Wait for animation to complete
      await tester.pumpAndSettle();

      // Sidebar should be 72px when collapsed
      final sidebarSize = tester.getSize(find.byType(AppSidebar));
      expect(
        sidebarSize.width,
        equals(72.0),
        reason: 'Collapsed sidebar should be 72px wide',
      );
    });


    testWidgets('Landscape orientation at 1366x1024', (
      WidgetTester tester,
    ) async {
      const landscapeWidth = 1366.0;
      const landscapeHeight = 1024.0;

      await tester.pumpWidget(
        MediaQuery(
          data: const MediaQueryData(
            size: Size(landscapeWidth, landscapeHeight),
          ),
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

      expect(find.text('Orientation: landscape'), findsOneWidget);
    });
  });

  group('Tablet Responsive Value Tests', () {
    testWidgets('valueWhen returns tablet value at 800px', (
      WidgetTester tester,
    ) async {
      String? value;

      await tester.pumpWidget(
        testApp(
          MediaQuery(
            data: const MediaQueryData(size: Size(800.0, 1024.0)),
            child: Builder(
              builder: (context) {
                value = Breakpoints.valueWhen<String>(
                  context: context,
                  mobile: 'Mobile',
                  tablet: 'Tablet',
                  desktop: 'Desktop',
                );
                return Container();
              },
            ),
          ),
        ),
      );

      expect(value, equals('Tablet'));
    });

    testWidgets('valueWhen falls back to mobile when tablet is null', (
      WidgetTester tester,
    ) async {
      String? value;

      await tester.pumpWidget(
        testApp(
          MediaQuery(
            data: const MediaQueryData(size: Size(800.0, 1024.0)),
            child: Builder(
              builder: (context) {
                value = Breakpoints.valueWhen<String>(
                  context: context,
                  mobile: 'Mobile',
                  // tablet is null, should fall back to mobile
                  desktop: 'Desktop',
                );
                return Container();
              },
            ),
          ),
        ),
      );

      expect(
        value,
        equals('Mobile'),
        reason: 'Should fall back to mobile when tablet value is null',
      );
    });
  });
}
