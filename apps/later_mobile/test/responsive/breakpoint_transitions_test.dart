import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:later_mobile/core/responsive/breakpoints.dart';
import 'package:later_mobile/shared/widgets/navigation/icon_only_bottom_nav.dart';

import '../test_helpers.dart';

/// Responsive Behavior Test Suite: Breakpoint Transitions
///
/// Tests that layouts transition smoothly at exact breakpoints:
/// - 767px to 768px (mobile to tablet)
/// - 768px to 769px (within tablet)
/// - 1023px to 1024px (tablet to desktop)
/// - 1024px to 1025px (within desktop)
/// - 1439px to 1440px (desktop to desktopLarge)
///
/// Verifies:
/// - Exact breakpoint behavior at boundaries
/// - No flickering or layout jumps
/// - Smooth transitions between layouts
/// - MediaQuery changes are handled correctly
/// - Edge cases at breakpoint boundaries
///
/// Success Criteria:
/// - Breakpoint detection is accurate at boundaries
/// - Layouts transition smoothly without errors
/// - No pixel-perfect edge cases cause issues
void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  group('Mobile to Tablet Breakpoint (768px)', () {
    testWidgets('767px is detected as mobile', (WidgetTester tester) async {
      bool? isMobile;
      bool? isTablet;

      await tester.pumpWidget(
        testApp(
          MediaQuery(
            data: const MediaQueryData(size: Size(767.0, 1024.0)),
            child: Builder(
              builder: (context) {
                isMobile = Breakpoints.isMobile(context);
                isTablet = Breakpoints.isTablet(context);
                return Container();
              },
            ),
          ),
        ),
      );

      expect(isMobile, isTrue, reason: '767px should be mobile');
      expect(isTablet, isFalse, reason: '767px should not be tablet');
    });

    testWidgets('768px is detected as tablet', (WidgetTester tester) async {
      bool? isMobile;
      bool? isTablet;

      await tester.pumpWidget(
        testApp(
          MediaQuery(
            data: const MediaQueryData(size: Size(768.0, 1024.0)),
            child: Builder(
              builder: (context) {
                isMobile = Breakpoints.isMobile(context);
                isTablet = Breakpoints.isTablet(context);
                return Container();
              },
            ),
          ),
        ),
      );

      expect(isMobile, isFalse, reason: '768px should not be mobile');
      expect(isTablet, isTrue, reason: '768px should be tablet');
    });

    testWidgets('769px is detected as tablet', (WidgetTester tester) async {
      bool? isTablet;

      await tester.pumpWidget(
        testApp(
          MediaQuery(
            data: const MediaQueryData(size: Size(769.0, 1024.0)),
            child: Builder(
              builder: (context) {
                isTablet = Breakpoints.isTablet(context);
                return Container();
              },
            ),
          ),
        ),
      );

      expect(isTablet, isTrue, reason: '769px should be tablet');
    });

    testWidgets('Bottom nav appears at 767px, disappears at 768px', (
      WidgetTester tester,
    ) async {
      // Test at 767px (mobile)
      await tester.pumpWidget(
        MediaQuery(
          data: const MediaQueryData(size: Size(767.0, 1024.0)),
          child: testApp(
            Builder(
              builder: (context) {
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

      expect(
        find.byType(IconOnlyBottomNav),
        findsOneWidget,
        reason: 'Bottom nav should be visible at 767px',
      );

      // Test at 768px (tablet)
      await tester.pumpWidget(
        MediaQuery(
          data: const MediaQueryData(size: Size(768.0, 1024.0)),
          child: testApp(
            Builder(
              builder: (context) {
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

      await tester.pump();

      expect(
        find.byType(IconOnlyBottomNav),
        findsNothing,
        reason: 'Bottom nav should be hidden at 768px',
      );
    });

    testWidgets('Grid columns change from 1 to 2 at 768px', (
      WidgetTester tester,
    ) async {
      int? columns767;
      int? columns768;

      // Test at 767px
      await tester.pumpWidget(
        testApp(
          MediaQuery(
            data: const MediaQueryData(size: Size(767.0, 1024.0)),
            child: Builder(
              builder: (context) {
                columns767 = Breakpoints.getGridColumns(context);
                return Container();
              },
            ),
          ),
        ),
      );

      // Test at 768px
      await tester.pumpWidget(
        testApp(
          MediaQuery(
            data: const MediaQueryData(size: Size(768.0, 1024.0)),
            child: Builder(
              builder: (context) {
                columns768 = Breakpoints.getGridColumns(context);
                return Container();
              },
            ),
          ),
        ),
      );

      expect(columns767, equals(1), reason: '767px should have 1 column');
      expect(columns768, equals(2), reason: '768px should have 2 columns');
    });

  });

  group('Tablet to Desktop Breakpoint (1024px)', () {
    testWidgets('1023px is detected as tablet', (WidgetTester tester) async {
      bool? isTablet;
      bool? isDesktop;

      await tester.pumpWidget(
        testApp(
          MediaQuery(
            data: const MediaQueryData(size: Size(1023.0, 768.0)),
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

      expect(isTablet, isTrue, reason: '1023px should be tablet');
      expect(isDesktop, isFalse, reason: '1023px should not be desktop');
    });

    testWidgets('1024px is detected as desktop', (WidgetTester tester) async {
      bool? isTablet;
      bool? isDesktop;

      await tester.pumpWidget(
        testApp(
          MediaQuery(
            data: const MediaQueryData(size: Size(1024.0, 768.0)),
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

      expect(isTablet, isFalse, reason: '1024px should not be tablet');
      expect(isDesktop, isTrue, reason: '1024px should be desktop');
    });

    testWidgets('1025px is detected as desktop', (WidgetTester tester) async {
      bool? isDesktop;

      await tester.pumpWidget(
        testApp(
          MediaQuery(
            data: const MediaQueryData(size: Size(1025.0, 768.0)),
            child: Builder(
              builder: (context) {
                isDesktop = Breakpoints.isDesktop(context);
                return Container();
              },
            ),
          ),
        ),
      );

      expect(isDesktop, isTrue, reason: '1025px should be desktop');
    });

    testWidgets('Sidebar appears at 1024px', (WidgetTester tester) async {
      // Test at 1023px (tablet - no sidebar)
      // Using a simple Container with key instead of AppSidebar to avoid dependencies
      await tester.pumpWidget(
        MediaQuery(
          data: const MediaQueryData(size: Size(1023.0, 768.0)),
          child: testApp(
            Builder(
              builder: (context) {
                final showSidebar = Breakpoints.isDesktopOrLarger(context);
                return Scaffold(
                  body: Row(
                    children: [
                      if (showSidebar)
                        Container(
                          key: const Key('mock_sidebar'),
                          width: 240,
                          color: Colors.grey,
                        ),
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
        find.byKey(const Key('mock_sidebar')),
        findsNothing,
        reason: 'Sidebar should not be visible at 1023px',
      );

      // Test at 1024px (desktop - sidebar appears)
      await tester.pumpWidget(
        MediaQuery(
          data: const MediaQueryData(size: Size(1024.0, 768.0)),
          child: testApp(
            Builder(
              builder: (context) {
                final showSidebar = Breakpoints.isDesktopOrLarger(context);
                return Scaffold(
                  body: Row(
                    children: [
                      if (showSidebar)
                        Container(
                          key: const Key('mock_sidebar'),
                          width: 240,
                          color: Colors.grey,
                        ),
                      const Expanded(child: Center(child: Text('Content'))),
                    ],
                  ),
                );
              },
            ),
          ),
        ),
      );

      await tester.pump();

      expect(
        find.byKey(const Key('mock_sidebar')),
        findsOneWidget,
        reason: 'Sidebar should appear at 1024px',
      );
    });

    testWidgets('Grid columns change from 2 to 3 at 1024px', (
      WidgetTester tester,
    ) async {
      int? columns1023;
      int? columns1024;

      // Test at 1023px
      await tester.pumpWidget(
        testApp(
          MediaQuery(
            data: const MediaQueryData(size: Size(1023.0, 768.0)),
            child: Builder(
              builder: (context) {
                columns1023 = Breakpoints.getGridColumns(context);
                return Container();
              },
            ),
          ),
        ),
      );

      // Test at 1024px
      await tester.pumpWidget(
        testApp(
          MediaQuery(
            data: const MediaQueryData(size: Size(1024.0, 768.0)),
            child: Builder(
              builder: (context) {
                columns1024 = Breakpoints.getGridColumns(context);
                return Container();
              },
            ),
          ),
        ),
      );

      expect(columns1023, equals(2), reason: '1023px should have 2 columns');
      expect(columns1024, equals(3), reason: '1024px should have 3 columns');
    });

    testWidgets('Max content width changes at 1024px', (
      WidgetTester tester,
    ) async {
      double? maxWidth1023;
      double? maxWidth1024;

      // Test at 1023px
      await tester.pumpWidget(
        testApp(
          MediaQuery(
            data: const MediaQueryData(size: Size(1023.0, 768.0)),
            child: Builder(
              builder: (context) {
                maxWidth1023 = Breakpoints.getMaxContentWidth(context);
                return Container();
              },
            ),
          ),
        ),
      );

      // Test at 1024px
      await tester.pumpWidget(
        testApp(
          MediaQuery(
            data: const MediaQueryData(size: Size(1024.0, 768.0)),
            child: Builder(
              builder: (context) {
                maxWidth1024 = Breakpoints.getMaxContentWidth(context);
                return Container();
              },
            ),
          ),
        ),
      );

      expect(
        maxWidth1023,
        equals(768.0),
        reason: 'Tablet max content width should be 768px',
      );
      expect(
        maxWidth1024,
        equals(1024.0),
        reason: 'Desktop max content width should be 1024px',
      );
    });
  });

  group('Desktop to DesktopLarge Breakpoint (1440px)', () {
    testWidgets('1439px is detected as desktop', (WidgetTester tester) async {
      bool? isDesktopLarge;
      ScreenSize? screenSize;

      await tester.pumpWidget(
        testApp(
          MediaQuery(
            data: const MediaQueryData(size: Size(1439.0, 900.0)),
            child: Builder(
              builder: (context) {
                isDesktopLarge = Breakpoints.isDesktopLarge(context);
                screenSize = Breakpoints.getScreenSize(context);
                return Container();
              },
            ),
          ),
        ),
      );

      expect(
        isDesktopLarge,
        isFalse,
        reason: '1439px should not be desktopLarge',
      );
      expect(screenSize, equals(ScreenSize.desktop));
    });

    testWidgets('1440px is detected as desktopLarge', (
      WidgetTester tester,
    ) async {
      bool? isDesktopLarge;
      ScreenSize? screenSize;

      await tester.pumpWidget(
        testApp(
          MediaQuery(
            data: const MediaQueryData(size: Size(1440.0, 900.0)),
            child: Builder(
              builder: (context) {
                isDesktopLarge = Breakpoints.isDesktopLarge(context);
                screenSize = Breakpoints.getScreenSize(context);
                return Container();
              },
            ),
          ),
        ),
      );

      expect(isDesktopLarge, isTrue, reason: '1440px should be desktopLarge');
      expect(screenSize, equals(ScreenSize.desktopLarge));
    });

    testWidgets('Grid columns change from 3 to 4 at 1440px', (
      WidgetTester tester,
    ) async {
      int? columns1439;
      int? columns1440;

      // Test at 1439px
      await tester.pumpWidget(
        testApp(
          MediaQuery(
            data: const MediaQueryData(size: Size(1439.0, 900.0)),
            child: Builder(
              builder: (context) {
                columns1439 = Breakpoints.getGridColumns(context);
                return Container();
              },
            ),
          ),
        ),
      );

      // Test at 1440px
      await tester.pumpWidget(
        testApp(
          MediaQuery(
            data: const MediaQueryData(size: Size(1440.0, 900.0)),
            child: Builder(
              builder: (context) {
                columns1440 = Breakpoints.getGridColumns(context);
                return Container();
              },
            ),
          ),
        ),
      );

      expect(columns1439, equals(3), reason: '1439px should have 3 columns');
      expect(columns1440, equals(4), reason: '1440px should have 4 columns');
    });

    testWidgets('Max content width remains 1200px after 1440px', (
      WidgetTester tester,
    ) async {
      double? maxWidth1440;
      double? maxWidth1920;

      // Test at 1440px
      await tester.pumpWidget(
        testApp(
          MediaQuery(
            data: const MediaQueryData(size: Size(1440.0, 900.0)),
            child: Builder(
              builder: (context) {
                maxWidth1440 = Breakpoints.getMaxContentWidth(context);
                return Container();
              },
            ),
          ),
        ),
      );

      // Test at 1920px
      await tester.pumpWidget(
        testApp(
          MediaQuery(
            data: const MediaQueryData(size: Size(1920.0, 1080.0)),
            child: Builder(
              builder: (context) {
                maxWidth1920 = Breakpoints.getMaxContentWidth(context);
                return Container();
              },
            ),
          ),
        ),
      );

      expect(
        maxWidth1440,
        equals(1200.0),
        reason: 'DesktopLarge max content width should be 1200px',
      );
      expect(
        maxWidth1920,
        equals(1200.0),
        reason: 'Max content width should remain 1200px at ultra-wide',
      );
    });
  });

  group('Smooth Transition Tests', () {
    testWidgets('No layout errors during resize simulation', (
      WidgetTester tester,
    ) async {
      // Simulate gradual resize from mobile to tablet
      for (double width = 767.0; width <= 769.0; width += 0.5) {
        await tester.pumpWidget(
          MediaQuery(
            data: MediaQueryData(size: Size(width, 1024.0)),
            child: testApp(
              Scaffold(
                body: Builder(
                  builder: (context) {
                    final isMobile = Breakpoints.isMobile(context);
                    return Center(
                      child: Text('Width: $width, Mobile: $isMobile'),
                    );
                  },
                ),
              ),
            ),
          ),
        );

        await tester.pump();

        // Verify no errors occurred
        expect(
          tester.takeException(),
          isNull,
          reason: 'No errors should occur at $width px',
        );
      }
    });

    testWidgets('Content constraints update smoothly', (
      WidgetTester tester,
    ) async {
      final widths = [767.0, 768.0, 1023.0, 1024.0, 1439.0, 1440.0];

      for (final width in widths) {
        await tester.pumpWidget(
          MediaQuery(
            data: MediaQueryData(size: Size(width, 800.0)),
            child: testApp(
              Scaffold(
                body: LayoutBuilder(
                  builder: (context, constraints) {
                    return Center(
                      child: Text('Width: ${constraints.maxWidth}'),
                    );
                  },
                ),
              ),
            ),
          ),
        );

        await tester.pump();

        // Verify layout is rendered correctly
        expect(
          find.textContaining('Width:'),
          findsOneWidget,
          reason: 'Layout should render at $width px',
        );
      }
    });
  });
}
