import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:later_mobile/design_system/organisms/empty_states/no_spaces_state.dart';
import 'package:later_mobile/design_system/organisms/empty_states/animated_empty_state.dart';

import '../../../test_helpers.dart';

void main() {
  group('NoSpacesState Widget Tests', () {
    testWidgets('renders correctly with required properties', (tester) async {
      // Act
      await tester.pumpWidget(
        testApp(
          NoSpacesState(
            onActionPressed: () {},
          ),
        ),
      );

      // Wait for animations to complete
      await tester.pumpAndSettle();

      // Assert
      expect(find.text('Welcome to Later'), findsOneWidget);
      expect(
        find.text(
          'Spaces organize your tasks, notes, and lists by context. Let\'s create your first one!',
        ),
        findsOneWidget,
      );
      expect(find.text('Create Your First Space'), findsOneWidget);
      expect(find.byIcon(Icons.folder_outlined), findsOneWidget);

      // Verify callback works (need to find the actual button through AnimatedEmptyState)
      // Since NoSpacesState wraps AnimatedEmptyState, we verify the structure exists
      expect(find.byType(AnimatedEmptyState), findsOneWidget);
    });

    testWidgets('onActionPressed callback fires when button tapped',
        (tester) async {
      // Arrange
      var actionPressed = false;

      // Act
      await tester.pumpWidget(
        testApp(
          NoSpacesState(
            onActionPressed: () {
              actionPressed = true;
            },
          ),
        ),
      );

      // Wait for animations to complete
      await tester.pumpAndSettle();

      // Tap the button
      await tester.tap(find.text('Create Your First Space'));
      await tester.pump();

      // Assert
      expect(actionPressed, isTrue);
    });

    testWidgets('does not render secondary action when not provided',
        (tester) async {
      // Act
      await tester.pumpWidget(
        testApp(
          NoSpacesState(
            onActionPressed: () {},
          ),
        ),
      );

      // Wait for animations to complete
      await tester.pumpAndSettle();

      // Assert
      expect(find.text('Learn more'), findsNothing);
    });

    testWidgets('renders secondary action when provided', (tester) async {
      // Arrange
      var secondaryPressed = false;

      // Act
      await tester.pumpWidget(
        testApp(
          NoSpacesState(
            onActionPressed: () {},
            onSecondaryPressed: () {
              secondaryPressed = true;
            },
          ),
        ),
      );

      // Wait for animations to complete
      await tester.pumpAndSettle();

      // Assert
      expect(find.text('Learn more'), findsOneWidget);

      // Tap secondary action
      await tester.tap(find.text('Learn more'));
      await tester.pump();

      expect(secondaryPressed, isTrue);
    });

    testWidgets('passes enableFabPulse callback to AnimatedEmptyState',
        (tester) async {
      // Arrange
      bool? fabPulseEnabled;

      // Act
      await tester.pumpWidget(
        testApp(
          NoSpacesState(
            onActionPressed: () {},
            enableFabPulse: (enabled) {
              fabPulseEnabled = enabled;
            },
          ),
        ),
      );

      // Wait for animations to complete
      await tester.pumpAndSettle();

      // Assert - FAB pulse callback should have been triggered
      expect(fabPulseEnabled, isNotNull);
    });

    testWidgets('uses correct icon for spaces', (tester) async {
      // Act
      await tester.pumpWidget(
        testApp(
          NoSpacesState(
            onActionPressed: () {},
          ),
        ),
      );

      // Wait for animations to complete
      await tester.pumpAndSettle();

      // Assert
      final iconFinder = find.byIcon(Icons.folder_outlined);
      expect(iconFinder, findsOneWidget);

      // Verify icon properties
      final iconWidget = tester.widget<Icon>(iconFinder);
      expect(iconWidget.icon, Icons.folder_outlined);
    });

    testWidgets('displays in both light and dark mode', (tester) async {
      // Test light mode
      await tester.pumpWidget(
        testApp(
          NoSpacesState(
            onActionPressed: () {},
          ),
        ),
      );
      await tester.pumpAndSettle();

      expect(find.text('Welcome to Later'), findsOneWidget);

      // Test dark mode
      await tester.pumpWidget(
        testAppDark(
          NoSpacesState(
            onActionPressed: () {},
          ),
        ),
      );
      await tester.pumpAndSettle();

      expect(find.text('Welcome to Later'), findsOneWidget);
    });

    testWidgets('contains AnimatedEmptyState with correct properties',
        (tester) async {
      // Act
      await tester.pumpWidget(
        testApp(
          NoSpacesState(
            onActionPressed: () {},
          ),
        ),
      );

      // Wait for animations to complete
      await tester.pumpAndSettle();

      // Assert
      final animatedEmptyState = tester.widget<AnimatedEmptyState>(
        find.byType(AnimatedEmptyState),
      );

      expect(animatedEmptyState.icon, Icons.folder_outlined);
      expect(animatedEmptyState.title, 'Welcome to Later');
      expect(
        animatedEmptyState.message,
        'Spaces organize your tasks, notes, and lists by context. Let\'s create your first one!',
      );
      expect(
        animatedEmptyState.actionLabel,
        'Create Your First Space',
      );
      expect(animatedEmptyState.onActionPressed, isNotNull);
    });

    testWidgets('full integration test with all callbacks', (tester) async {
      // Arrange
      var actionCalled = false;
      var secondaryCalled = false;
      bool? fabPulseState;

      // Act
      await tester.pumpWidget(
        testApp(
          NoSpacesState(
            onActionPressed: () {
              actionCalled = true;
            },
            onSecondaryPressed: () {
              secondaryCalled = true;
            },
            enableFabPulse: (enabled) {
              fabPulseState = enabled;
            },
          ),
        ),
      );

      // Wait for animations to complete
      await tester.pumpAndSettle();

      // Assert - all elements present
      expect(find.byIcon(Icons.folder_outlined), findsOneWidget);
      expect(find.text('Welcome to Later'), findsOneWidget);
      expect(
        find.text(
          'Spaces organize your tasks, notes, and lists by context. Let\'s create your first one!',
        ),
        findsOneWidget,
      );
      expect(find.text('Create Your First Space'), findsOneWidget);
      expect(find.text('Learn more'), findsOneWidget);

      // Test primary action
      await tester.tap(find.text('Create Your First Space'));
      await tester.pump();
      expect(actionCalled, isTrue);

      // Test secondary action
      await tester.tap(find.text('Learn more'));
      await tester.pump();
      expect(secondaryCalled, isTrue);

      // Test FAB pulse
      expect(fabPulseState, isNotNull);
    });
  });
}
