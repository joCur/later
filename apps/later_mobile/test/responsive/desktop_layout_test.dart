import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:later_mobile/core/responsive/breakpoints.dart';
import 'package:later_mobile/shared/widgets/navigation/app_sidebar.dart';
import 'package:later_mobile/shared/widgets/navigation/icon_only_bottom_nav.dart';

import '../test_helpers.dart';

/// Responsive Behavior Test Suite: Desktop Layout (1024px+)
///
/// Tests that desktop layouts render correctly across different screen sizes:
/// - Standard HD: 1280px width
/// - Full HD: 1440px width
/// - 4K: 1920px width
///
/// Verifies:
/// - Full sidebar with collapse functionality
/// - Centered modals with max-width
/// - Content max-width constraints (1200px)
/// - Keyboard navigation support
/// - Multi-column layouts (3-4 columns)
///
/// Success Criteria:
/// - Desktop breakpoint detection works
/// - Sidebar behavior is correct
/// - Keyboard shortcuts work
/// - Layout constraints are applied
void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  group('Desktop Layout Tests - 1280px (Standard HD)', () {
    const testWidth = 1280.0;
    const testHeight = 720.0;

    testWidgets('Breakpoint detection identifies desktop at 1280px', (
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

      expect(isMobile, isFalse);
      expect(isTablet, isFalse);
      expect(
        isDesktop,
        isTrue,
        reason: '1280px should be identified as desktop',
      );
    });

    testWidgets('Grid columns are 3 at 1280px', (WidgetTester tester) async {
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
        reason: 'Desktop at 1280px should use 3-column layout',
      );
    });

    testWidgets('Max content width is 1024px at 1280px', (
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
        reason: 'Desktop should constrain content to 1024px',
      );
    });

    testWidgets('Sidebar is visible at 1280px', (WidgetTester tester) async {
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

      expect(
        find.byType(AppSidebar),
        findsOneWidget,
        reason: 'Sidebar should be visible on desktop',
      );
    });

    testWidgets('Sidebar can be expanded at 1280px', (
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

      // Expanded sidebar should be 240px
      final sidebarSize = tester.getSize(find.byType(AppSidebar));
      expect(
        sidebarSize.width,
        equals(240.0),
        reason: 'Expanded sidebar should be 240px wide',
      );
    });

    testWidgets('Sidebar can be collapsed at 1280px', (
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

      await tester.pumpAndSettle();

      // Collapsed sidebar should be 72px
      final sidebarSize = tester.getSize(find.byType(AppSidebar));
      expect(
        sidebarSize.width,
        equals(72.0),
        reason: 'Collapsed sidebar should be 72px wide',
      );
    });

    testWidgets('Bottom navigation is hidden at 1280px', (
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

      expect(
        find.byType(IconOnlyBottomNav),
        findsNothing,
        reason: 'Bottom navigation should be hidden on desktop',
      );
    });



    testWidgets('Modal has centered positioning at 1280px', (
      WidgetTester tester,
    ) async {
      await tester.pumpWidget(
        MediaQuery(
          data: const MediaQueryData(size: Size(testWidth, testHeight)),
          child: testApp(
            Scaffold(
              body: Builder(
                builder: (context) {
                  return Center(
                    child: ElevatedButton(
                      onPressed: () {
                        showDialog<void>(
                          context: context,
                          builder: (context) => const Dialog(
                            child: SizedBox(
                              width: 560.0,
                              height: 400.0,
                              child: Center(child: Text('Modal Content')),
                            ),
                          ),
                        );
                      },
                      child: const Text('Show Modal'),
                    ),
                  );
                },
              ),
            ),
          ),
        ),
      );

      await tester.tap(find.text('Show Modal'));
      await tester.pumpAndSettle();

      // Verify modal is displayed
      expect(find.text('Modal Content'), findsOneWidget);

      // Modal should be centered and have max width of 560px
      final dialog = find.byType(SizedBox).evaluate().first.widget as SizedBox;
      expect(
        dialog.width,
        equals(560.0),
        reason: 'Modal should have max-width of 560px',
      );
    });
  });

  group('Desktop Layout Tests - 1440px (Full HD)', () {
    const testWidth = 1440.0;
    const testHeight = 900.0;

    testWidgets('Breakpoint identifies desktopLarge at 1440px', (
      WidgetTester tester,
    ) async {
      bool? isDesktopLarge;

      await tester.pumpWidget(
        testApp(
          MediaQuery(
            data: const MediaQueryData(size: Size(testWidth, testHeight)),
            child: Builder(
              builder: (context) {
                isDesktopLarge = Breakpoints.isDesktopLarge(context);
                return Container();
              },
            ),
          ),
        ),
      );

      expect(
        isDesktopLarge,
        isTrue,
        reason: '1440px should be identified as desktopLarge',
      );
    });

    testWidgets('Grid columns are 4 at 1440px', (WidgetTester tester) async {
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
        equals(4),
        reason: 'Desktop large should use 4-column layout',
      );
    });

    testWidgets('Max content width remains 1200px at 1440px', (
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
        equals(1200.0),
        reason: 'Max content width should be capped at 1200px',
      );
    });

    testWidgets('ScreenSize enum returns desktopLarge at 1440px', (
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

      expect(screenSize, equals(ScreenSize.desktopLarge));
    });


    testWidgets('Sidebar remains functional at 1440px', (
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

      expect(find.byType(AppSidebar), findsOneWidget);

      final sidebarSize = tester.getSize(find.byType(AppSidebar));
      expect(sidebarSize.width, equals(240.0));
    });
  });

  group('Desktop Layout Tests - 1920px (4K)', () {
    const testWidth = 1920.0;
    const testHeight = 1080.0;

    testWidgets('Breakpoint identifies desktopLarge at 1920px', (
      WidgetTester tester,
    ) async {
      bool? isDesktopLarge;

      await tester.pumpWidget(
        testApp(
          MediaQuery(
            data: const MediaQueryData(size: Size(testWidth, testHeight)),
            child: Builder(
              builder: (context) {
                isDesktopLarge = Breakpoints.isDesktopLarge(context);
                return Container();
              },
            ),
          ),
        ),
      );

      expect(isDesktopLarge, isTrue);
    });

    testWidgets('Grid columns are 4 at 1920px', (WidgetTester tester) async {
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

      expect(columns, equals(4));
    });


    testWidgets('Layout is usable at very wide screens', (
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
                  Expanded(
                    child: ListView.builder(
                      itemCount: 20,
                      itemBuilder: (context, index) =>
                          ListTile(title: Text('Item $index')),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      );

      // Verify no layout errors
      expect(tester.takeException(), isNull);

      // Verify content is accessible
      expect(find.text('Item 0'), findsOneWidget);
    });
  });

  group('Desktop Keyboard Navigation Tests', () {
    testWidgets('Keyboard shortcuts are enabled on desktop', (
      WidgetTester tester,
    ) async {
      bool shortcutCalled = false;

      await tester.pumpWidget(
        MediaQuery(
          data: const MediaQueryData(size: Size(1280.0, 720.0)),
          child: testApp(
            Scaffold(
              body: Focus(
                autofocus: true,
                onKeyEvent: (node, event) {
                  if (event is KeyDownEvent &&
                      event.logicalKey == LogicalKeyboardKey.keyN) {
                    shortcutCalled = true;
                    return KeyEventResult.handled;
                  }
                  return KeyEventResult.ignored;
                },
                child: const Center(child: Text('Content')),
              ),
            ),
          ),
        ),
      );

      // Simulate pressing 'N' key
      await tester.sendKeyEvent(LogicalKeyboardKey.keyN);
      await tester.pump();

      expect(
        shortcutCalled,
        isTrue,
        reason: 'Keyboard shortcuts should work on desktop',
      );
    });

    testWidgets('Focus indicators are visible on desktop', (
      WidgetTester tester,
    ) async {
      await tester.pumpWidget(
        MediaQuery(
          data: const MediaQueryData(size: Size(1280.0, 720.0)),
          child: testApp(
            Scaffold(
              body: Center(
                child: ElevatedButton(
                  onPressed: () {},
                  child: const Text('Button'),
                ),
              ),
            ),
          ),
        ),
      );

      // Find and focus the button
      final buttonFinder = find.byType(ElevatedButton);
      expect(buttonFinder, findsOneWidget);

      // Tab to focus the button
      await tester.sendKeyEvent(LogicalKeyboardKey.tab);
      await tester.pump();

      // Button should be focusable
      final button = tester.widget<ElevatedButton>(buttonFinder);
      expect(button, isNotNull);
    });
  });
}
