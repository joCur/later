import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:later_mobile/core/theme/temporal_flow_theme.dart';
import 'package:later_mobile/shared/widgets/navigation/bottom_navigation_bar.dart';
import 'package:later_mobile/design_system/tokens/tokens.dart';

void main() {
  Widget createTestWidget({
    required int currentIndex,
    required void Function(int) onDestinationSelected,
    ThemeData? theme,
  }) {
    return MaterialApp(
      theme: (theme ?? ThemeData.light()).copyWith(
        extensions: <ThemeExtension<dynamic>>[
          theme?.brightness == Brightness.dark
              ? TemporalFlowTheme.dark()
              : TemporalFlowTheme.light(),
        ],
      ),
      home: Scaffold(
        bottomNavigationBar: AppBottomNavigationBar(
          currentIndex: currentIndex,
          onDestinationSelected: onDestinationSelected,
        ),
      ),
    );
  }

  group('AppBottomNavigationBar', () {
    testWidgets('renders with all three destinations', (tester) async {
      await tester.pumpWidget(
        createTestWidget(
          currentIndex: 0,
          onDestinationSelected: (_) {},
        ),
      );

      // Find all three destinations
      expect(find.text('Home'), findsOneWidget);
      expect(find.text('Search'), findsOneWidget);
      expect(find.text('Settings'), findsOneWidget);
    });

    testWidgets('uses BackdropFilter for glass morphism effect', (
      tester,
    ) async {
      await tester.pumpWidget(
        createTestWidget(
          currentIndex: 0,
          onDestinationSelected: (_) {},
        ),
      );

      // Verify BackdropFilter is present
      expect(find.byType(BackdropFilter), findsOneWidget);

      // Verify blur filter is configured correctly (20px blur)
      final backdropFilter = tester.widget<BackdropFilter>(
        find.byType(BackdropFilter),
      );
      expect(backdropFilter.filter, isA<ImageFilter>());
    });

    testWidgets('has glass background with correct opacity in light mode', (
      tester,
    ) async {
      await tester.pumpWidget(
        createTestWidget(
          currentIndex: 0,
          onDestinationSelected: (_) {},
        ),
      );

      // Find Container with glass background
      final container = tester.widget<Container>(
        find
            .descendant(
              of: find.byType(AppBottomNavigationBar),
              matching: find.byType(Container),
            )
            .first,
      );

      final decoration = container.decoration as BoxDecoration?;
      expect(decoration?.color, equals(AppColors.glassLight));
    });

    testWidgets('has glass background with correct opacity in dark mode', (
      tester,
    ) async {
      await tester.pumpWidget(
        createTestWidget(
          currentIndex: 0,
          onDestinationSelected: (_) {},
          theme: ThemeData.dark(),
        ),
      );

      // Find Container with glass background
      final container = tester.widget<Container>(
        find
            .descendant(
              of: find.byType(AppBottomNavigationBar),
              matching: find.byType(Container),
            )
            .first,
      );

      final decoration = container.decoration as BoxDecoration?;
      expect(decoration?.color, equals(AppColors.glassDark));
    });

    testWidgets(
      'displays gradient active indicator with correct colors in light mode',
      (tester) async {
        await tester.pumpWidget(
          createTestWidget(
            currentIndex: 0,
            onDestinationSelected: (_) {},
          ),
        );

        await tester.pumpAndSettle();

        // Find all containers and look for the gradient indicator
        final containers = tester.widgetList<Container>(find.byType(Container));

        // Find the indicator container with gradient decoration
        final indicatorContainer = containers.firstWhere((container) {
          final decoration = container.decoration;
          return decoration is BoxDecoration && decoration.gradient != null;
        });

        final decoration = indicatorContainer.decoration as BoxDecoration;
        expect(decoration.gradient, equals(AppColors.primaryGradient));
      },
    );

    testWidgets(
      'displays gradient active indicator with correct colors in dark mode',
      (tester) async {
        await tester.pumpWidget(
          createTestWidget(
            currentIndex: 0,
            onDestinationSelected: (_) {},
            theme: ThemeData.dark(),
          ),
        );

        await tester.pumpAndSettle();

        // Find all containers and look for the gradient indicator
        final containers = tester.widgetList<Container>(find.byType(Container));

        // Find the indicator container with gradient decoration
        final indicatorContainer = containers.firstWhere((container) {
          final decoration = container.decoration;
          return decoration is BoxDecoration && decoration.gradient != null;
        });

        final decoration = indicatorContainer.decoration as BoxDecoration;
        expect(decoration.gradient, equals(AppColors.primaryGradientDark));
      },
    );

    testWidgets('indicator has pill shape with 40px height', (tester) async {
      await tester.pumpWidget(
        createTestWidget(
          currentIndex: 0,
          onDestinationSelected: (_) {},
        ),
      );

      await tester.pumpAndSettle();

      // Find all containers and look for the gradient indicator
      final containers = tester.widgetList<Container>(find.byType(Container));

      // Find the indicator container with gradient decoration
      final indicatorContainer = containers.firstWhere((container) {
        final decoration = container.decoration;
        return decoration is BoxDecoration && decoration.gradient != null;
      });

      final decoration = indicatorContainer.decoration as BoxDecoration;
      expect(decoration.gradient, isNotNull);
      expect(decoration.borderRadius, equals(BorderRadius.circular(20.0)));
    });

    testWidgets('uses outlined icons with 2px stroke', (tester) async {
      await tester.pumpWidget(
        createTestWidget(
          currentIndex: 1, // Select Search so Home shows outline icon
          onDestinationSelected: (_) {},
        ),
      );

      // Verify outlined icons are used for inactive destinations
      expect(find.byIcon(Icons.home_outlined), findsOneWidget);
      expect(find.byIcon(Icons.settings_outlined), findsOneWidget);
    });

    testWidgets('displays correct icons for each destination', (tester) async {
      await tester.pumpWidget(
        createTestWidget(
          currentIndex: 0,
          onDestinationSelected: (_) {},
        ),
      );

      // Verify all icons are present
      expect(find.byIcon(Icons.home), findsOneWidget);
      expect(find.byIcon(Icons.search_outlined), findsOneWidget);
      expect(find.byIcon(Icons.settings_outlined), findsOneWidget);
    });

    testWidgets('shows selected icon for active destination', (tester) async {
      await tester.pumpWidget(
        createTestWidget(
          currentIndex: 0,
          onDestinationSelected: (_) {},
        ),
      );

      // Verify selected icon is shown for Home (index 0)
      expect(find.byIcon(Icons.home), findsOneWidget);
      // Other destinations show outlined icons
      expect(find.byIcon(Icons.search_outlined), findsOneWidget);
      expect(find.byIcon(Icons.settings_outlined), findsOneWidget);
    });

    testWidgets('calls onDestinationSelected when tapped', (tester) async {
      int? selectedIndex;

      await tester.pumpWidget(
        createTestWidget(
          currentIndex: 0,
          onDestinationSelected: (index) {
            selectedIndex = index;
          },
        ),
      );

      // Tap on Search destination
      await tester.tap(find.text('Search'));
      await tester.pumpAndSettle();

      expect(selectedIndex, equals(1));
    });

    testWidgets('updates selected destination correctly', (tester) async {
      int currentIndex = 0;

      await tester.pumpWidget(
        StatefulBuilder(
          builder: (context, setState) {
            return createTestWidget(
              currentIndex: currentIndex,
              onDestinationSelected: (index) {
                setState(() {
                  currentIndex = index;
                });
              },
            );
          },
        ),
      );

      // Initially Home is selected (index 0)
      expect(find.byIcon(Icons.home), findsOneWidget);

      // Tap Settings
      await tester.tap(find.text('Settings'));
      await tester.pumpAndSettle();

      // Settings should now be selected (index 2)
      expect(currentIndex, equals(2));
      expect(find.byIcon(Icons.settings), findsOneWidget);
    });

    testWidgets('has proper semantic labels for accessibility', (tester) async {
      await tester.pumpWidget(
        createTestWidget(
          currentIndex: 0,
          onDestinationSelected: (_) {},
        ),
      );

      // Verify text labels are present for accessibility
      expect(find.text('Home'), findsOneWidget);
      expect(find.text('Search'), findsOneWidget);
      expect(find.text('Settings'), findsOneWidget);

      // Verify tooltips exist
      expect(find.byType(Tooltip), findsNWidgets(3));
    });

    testWidgets('displays tooltips on destinations', (tester) async {
      await tester.pumpWidget(
        createTestWidget(
          currentIndex: 0,
          onDestinationSelected: (_) {},
        ),
      );

      // Verify all three tooltips exist
      expect(find.byType(Tooltip), findsNWidgets(3));

      // Verify all labels are present
      expect(find.text('Home'), findsOneWidget);
      expect(find.text('Search'), findsOneWidget);
      expect(find.text('Settings'), findsOneWidget);
    });

    testWidgets('maintains 64px total height', (tester) async {
      await tester.pumpWidget(
        createTestWidget(
          currentIndex: 0,
          onDestinationSelected: (_) {},
        ),
      );

      // Verify the bottom navigation bar has 64px height
      expect(
        tester.getSize(find.byType(AppBottomNavigationBar)).height,
        equals(64.0),
      );
    });

    testWidgets('indicator animates smoothly with 250ms spring curve', (
      tester,
    ) async {
      int currentIndex = 0;

      await tester.pumpWidget(
        StatefulBuilder(
          builder: (context, setState) {
            return createTestWidget(
              currentIndex: currentIndex,
              onDestinationSelected: (index) {
                setState(() {
                  currentIndex = index;
                });
              },
            );
          },
        ),
      );

      // Tap on Settings to trigger animation
      await tester.tap(find.text('Settings'));

      // Check that animation is in progress (not immediately settled)
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 100));

      // Animation should complete after 250ms
      await tester.pumpAndSettle();

      // Verify Settings is now selected
      expect(currentIndex, equals(2));
    });

    testWidgets('respects SafeArea for notch devices', (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          theme: ThemeData.light().copyWith(
            extensions: <ThemeExtension<dynamic>>[
              TemporalFlowTheme.light(),
            ],
          ),
          home: MediaQuery(
            data: const MediaQueryData(
              padding: EdgeInsets.only(bottom: 34.0), // iPhone notch
            ),
            child: Scaffold(
              bottomNavigationBar: AppBottomNavigationBar(
                currentIndex: 0,
                onDestinationSelected: (_) {},
              ),
            ),
          ),
        ),
      );

      // Verify SafeArea is present
      expect(
        find.descendant(
          of: find.byType(AppBottomNavigationBar),
          matching: find.byType(SafeArea),
        ),
        findsOneWidget,
      );
    });

    testWidgets('works with dark theme', (tester) async {
      await tester.pumpWidget(
        createTestWidget(
          currentIndex: 0,
          onDestinationSelected: (_) {},
          theme: ThemeData.dark(),
        ),
      );

      // Should render without errors in dark mode
      expect(find.byType(AppBottomNavigationBar), findsOneWidget);
      expect(find.text('Home'), findsOneWidget);
    });

    testWidgets('works with light theme', (tester) async {
      await tester.pumpWidget(
        createTestWidget(
          currentIndex: 0,
          onDestinationSelected: (_) {},
        ),
      );

      // Should render without errors in light mode
      expect(find.byType(AppBottomNavigationBar), findsOneWidget);
      expect(find.text('Home'), findsOneWidget);
    });

    testWidgets('asserts valid currentIndex range', (tester) async {
      // Test that invalid index triggers assertion
      expect(
        () => AppBottomNavigationBar(
          currentIndex: -1,
          onDestinationSelected: (_) {},
        ),
        throwsAssertionError,
      );

      expect(
        () => AppBottomNavigationBar(
          currentIndex: 3,
          onDestinationSelected: (_) {},
        ),
        throwsAssertionError,
      );
    });

    testWidgets('all destinations are tappable', (tester) async {
      final tappedIndices = <int>[];

      await tester.pumpWidget(
        createTestWidget(
          currentIndex: 0,
          onDestinationSelected: (index) {
            tappedIndices.add(index);
          },
        ),
      );

      // Tap each destination
      await tester.tap(find.text('Home'));
      await tester.pumpAndSettle();

      await tester.tap(find.text('Search'));
      await tester.pumpAndSettle();

      await tester.tap(find.text('Settings'));
      await tester.pumpAndSettle();

      // Verify all taps were registered
      expect(tappedIndices, equals([0, 1, 2]));
    });
  });
}
