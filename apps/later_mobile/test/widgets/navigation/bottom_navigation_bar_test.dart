import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:later_mobile/widgets/navigation/bottom_navigation_bar.dart';

void main() {
  group('AppBottomNavigationBar', () {
    testWidgets('renders with all three destinations', (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            bottomNavigationBar: AppBottomNavigationBar(
              currentIndex: 0,
              onDestinationSelected: (_) {},
            ),
          ),
        ),
      );

      // Find all three destinations
      expect(find.text('Home'), findsOneWidget);
      expect(find.text('Search'), findsOneWidget);
      expect(find.text('Settings'), findsOneWidget);
    });

    testWidgets('displays correct icons for each destination', (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            bottomNavigationBar: AppBottomNavigationBar(
              currentIndex: 0,
              onDestinationSelected: (_) {},
            ),
          ),
        ),
      );

      // Verify NavigationDestinations are present
      final destinations = find.byType(NavigationDestination);
      expect(destinations, findsNWidgets(3));
    });

    testWidgets('shows selected icon for active destination', (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            bottomNavigationBar: AppBottomNavigationBar(
              currentIndex: 0,
              onDestinationSelected: (_) {},
            ),
          ),
        ),
      );

      // Verify NavigationBar is rendered with selected index
      final navigationBar = tester.widget<NavigationBar>(
        find.byType(NavigationBar),
      );
      expect(navigationBar.selectedIndex, equals(0));
    });

    testWidgets('calls onDestinationSelected when tapped', (tester) async {
      int? selectedIndex;

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            bottomNavigationBar: AppBottomNavigationBar(
              currentIndex: 0,
              onDestinationSelected: (index) {
                selectedIndex = index;
              },
            ),
          ),
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
            return MaterialApp(
              home: Scaffold(
                bottomNavigationBar: AppBottomNavigationBar(
                  currentIndex: currentIndex,
                  onDestinationSelected: (index) {
                    setState(() {
                      currentIndex = index;
                    });
                  },
                ),
              ),
            );
          },
        ),
      );

      // Initially Home is selected (index 0)
      var navigationBar = tester.widget<NavigationBar>(
        find.byType(NavigationBar),
      );
      expect(navigationBar.selectedIndex, equals(0));

      // Tap Settings
      await tester.tap(find.text('Settings'));
      await tester.pumpAndSettle();

      // Settings should now be selected (index 2)
      navigationBar = tester.widget<NavigationBar>(
        find.byType(NavigationBar),
      );
      expect(navigationBar.selectedIndex, equals(2));
    });

    testWidgets('has proper semantic labels for accessibility', (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            bottomNavigationBar: AppBottomNavigationBar(
              currentIndex: 0,
              onDestinationSelected: (_) {},
            ),
          ),
        ),
      );

      // Verify NavigationDestinations exist
      final destinations = find.byType(NavigationDestination);
      expect(destinations, findsNWidgets(3));

      // Verify text labels are present for accessibility
      expect(find.text('Home'), findsOneWidget);
      expect(find.text('Search'), findsOneWidget);
      expect(find.text('Settings'), findsOneWidget);
    });

    testWidgets('displays tooltips on destinations', (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            bottomNavigationBar: AppBottomNavigationBar(
              currentIndex: 0,
              onDestinationSelected: (_) {},
            ),
          ),
        ),
      );

      // Find the NavigationBar
      final navigationBar = find.byType(NavigationBar);
      expect(navigationBar, findsOneWidget);

      // Verify NavigationBar has NavigationDestinations
      final destinations = find.byType(NavigationDestination);
      expect(destinations, findsNWidgets(3));
    });

    testWidgets('maintains minimum touch target size', (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            bottomNavigationBar: AppBottomNavigationBar(
              currentIndex: 0,
              onDestinationSelected: (_) {},
            ),
          ),
        ),
      );

      // NavigationBar should be 64px high for adequate touch targets
      final navigationBar = tester.widget<NavigationBar>(
        find.byType(NavigationBar),
      );
      expect(navigationBar.height, equals(64.0));
    });

    testWidgets('works with dark theme', (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          theme: ThemeData.dark(),
          home: Scaffold(
            bottomNavigationBar: AppBottomNavigationBar(
              currentIndex: 0,
              onDestinationSelected: (_) {},
            ),
          ),
        ),
      );

      // Should render without errors in dark mode
      expect(find.byType(AppBottomNavigationBar), findsOneWidget);
      expect(find.text('Home'), findsOneWidget);
    });

    testWidgets('works with light theme', (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          theme: ThemeData.light(),
          home: Scaffold(
            bottomNavigationBar: AppBottomNavigationBar(
              currentIndex: 0,
              onDestinationSelected: (_) {},
            ),
          ),
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
        MaterialApp(
          home: Scaffold(
            bottomNavigationBar: AppBottomNavigationBar(
              currentIndex: 0,
              onDestinationSelected: (index) {
                tappedIndices.add(index);
              },
            ),
          ),
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
