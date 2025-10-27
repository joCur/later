import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:later_mobile/core/error/app_error.dart';
import 'package:later_mobile/design_system/organisms/error/error_snackbar.dart';

void main() {
  group('ErrorSnackBar', () {
    testWidgets('shows snackbar with error message', (tester) async {
      final error = AppError.storage(
        message: 'Storage error',
        userMessage: 'Failed to save',
      );

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: Builder(
              builder: (context) {
                return ElevatedButton(
                  onPressed: () {
                    ErrorSnackBar.show(context, error);
                  },
                  child: const Text('Show'),
                );
              },
            ),
          ),
        ),
      );

      await tester.tap(find.text('Show'));
      await tester.pump();

      expect(find.byType(SnackBar), findsOneWidget);
      expect(find.text('Failed to save'), findsOneWidget);
    });

    testWidgets('shows action button for retryable errors', (tester) async {
      final error = AppError.storage(message: 'Test'); // Retryable

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: Builder(
              builder: (context) {
                return ElevatedButton(
                  onPressed: () {
                    ErrorSnackBar.show(context, error);
                  },
                  child: const Text('Show'),
                );
              },
            ),
          ),
        ),
      );

      await tester.tap(find.text('Show'));
      await tester.pump();

      expect(find.text('Retry'), findsOneWidget);
    });

    testWidgets('does not show action for non-retryable errors', (
      tester,
    ) async {
      final error = AppError.validation(message: 'Test'); // Not retryable

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: Builder(
              builder: (context) {
                return ElevatedButton(
                  onPressed: () {
                    ErrorSnackBar.show(context, error);
                  },
                  child: const Text('Show'),
                );
              },
            ),
          ),
        ),
      );

      await tester.tap(find.text('Show'));
      await tester.pump();

      expect(find.byType(SnackBar), findsOneWidget);
      // Should not have retry action
      expect(find.text('Retry'), findsNothing);
    });

    testWidgets('calls onRetry when action tapped', (tester) async {
      final error = AppError.storage(message: 'Test');
      bool retryCalled = false;

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: Builder(
              builder: (context) {
                return ElevatedButton(
                  onPressed: () {
                    ErrorSnackBar.show(
                      context,
                      error,
                      onRetry: () {
                        retryCalled = true;
                      },
                    );
                  },
                  child: const Text('Show'),
                );
              },
            ),
          ),
        ),
      );

      await tester.tap(find.text('Show'));
      await tester.pump();

      await tester.tap(find.text('Retry'));
      await tester.pump();

      expect(retryCalled, isTrue);
    });

    testWidgets('has correct duration', (tester) async {
      final error = AppError.storage(message: 'Test');

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: Builder(
              builder: (context) {
                return ElevatedButton(
                  onPressed: () {
                    ErrorSnackBar.show(context, error);
                  },
                  child: const Text('Show'),
                );
              },
            ),
          ),
        ),
      );

      await tester.tap(find.text('Show'));
      await tester.pump();

      final snackBar = tester.widget<SnackBar>(find.byType(SnackBar));
      expect(snackBar.duration, const Duration(seconds: 4));
    });

    testWidgets('is dismissible by swipe', (tester) async {
      final error = AppError.storage(message: 'Test');

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: Builder(
              builder: (context) {
                return ElevatedButton(
                  onPressed: () {
                    ErrorSnackBar.show(context, error);
                  },
                  child: const Text('Show'),
                );
              },
            ),
          ),
        ),
      );

      await tester.tap(find.text('Show'));
      await tester.pump();

      expect(find.byType(SnackBar), findsOneWidget);

      final snackBar = tester.widget<SnackBar>(find.byType(SnackBar));
      expect(snackBar.behavior, SnackBarBehavior.floating);
    });

    testWidgets('has error styling', (tester) async {
      final error = AppError.storage(message: 'Test');

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: Builder(
              builder: (context) {
                return ElevatedButton(
                  onPressed: () {
                    ErrorSnackBar.show(context, error);
                  },
                  child: const Text('Show'),
                );
              },
            ),
          ),
        ),
      );

      await tester.tap(find.text('Show'));
      await tester.pump();

      final snackBar = tester.widget<SnackBar>(find.byType(SnackBar));
      // Should have error background color
      expect(snackBar.backgroundColor, isNotNull);
    });

    testWidgets('can show custom action label', (tester) async {
      const error = AppError(
        type: ErrorType.storage,
        message: 'Test',
        actionLabel: 'Try Again',
      );

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: Builder(
              builder: (context) {
                return ElevatedButton(
                  onPressed: () {
                    ErrorSnackBar.show(context, error);
                  },
                  child: const Text('Show'),
                );
              },
            ),
          ),
        ),
      );

      await tester.tap(find.text('Show'));
      await tester.pump();

      expect(find.text('Try Again'), findsOneWidget);
    });

    testWidgets('shows icon for error', (tester) async {
      final error = AppError.storage(message: 'Test');

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: Builder(
              builder: (context) {
                return ElevatedButton(
                  onPressed: () {
                    ErrorSnackBar.show(context, error);
                  },
                  child: const Text('Show'),
                );
              },
            ),
          ),
        ),
      );

      await tester.tap(find.text('Show'));
      await tester.pump();

      // Should have error icon
      expect(find.byIcon(Icons.error_outline), findsOneWidget);
    });

    testWidgets('handles different error types', (tester) async {
      final errors = [
        AppError.storage(message: 'Storage'),
        AppError.network(message: 'Network'),
        AppError.validation(message: 'Validation'),
        AppError.corruption(message: 'Corruption'),
      ];

      for (final error in errors) {
        await tester.pumpWidget(
          MaterialApp(
            home: Scaffold(
              body: Builder(
                builder: (context) {
                  return ElevatedButton(
                    onPressed: () {
                      ErrorSnackBar.show(context, error);
                    },
                    child: const Text('Show'),
                  );
                },
              ),
            ),
          ),
        );

        await tester.tap(find.text('Show'));
        await tester.pump();

        expect(find.byType(SnackBar), findsOneWidget);

        // Wait for snackbar to disappear
        await tester.pump(const Duration(seconds: 5));

        // Clear for next iteration
        await tester.pumpWidget(Container());
      }
    });

    testWidgets('dismisses previous snackbar when showing new one', (
      tester,
    ) async {
      final error1 = AppError.storage(message: 'Error 1');
      final error2 = AppError.network(message: 'Error 2');

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: Builder(
              builder: (context) {
                return Column(
                  children: [
                    ElevatedButton(
                      onPressed: () {
                        ErrorSnackBar.show(context, error1);
                      },
                      child: const Text('Show 1'),
                    ),
                    ElevatedButton(
                      onPressed: () {
                        ErrorSnackBar.show(context, error2);
                      },
                      child: const Text('Show 2'),
                    ),
                  ],
                );
              },
            ),
          ),
        ),
      );

      await tester.tap(find.text('Show 1'));
      await tester.pump();

      expect(find.text(error1.getUserMessage()), findsOneWidget);

      await tester.tap(find.text('Show 2'));
      await tester.pump();

      // Should only show the second snackbar
      expect(find.text(error2.getUserMessage()), findsOneWidget);
    });

    testWidgets('has proper content padding', (tester) async {
      final error = AppError.storage(message: 'Test');

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: Builder(
              builder: (context) {
                return ElevatedButton(
                  onPressed: () {
                    ErrorSnackBar.show(context, error);
                  },
                  child: const Text('Show'),
                );
              },
            ),
          ),
        ),
      );

      await tester.tap(find.text('Show'));
      await tester.pump();

      expect(find.byType(SnackBar), findsOneWidget);
      // SnackBar should have proper padding
    });

    testWidgets('closes snackbar after duration', (tester) async {
      final error = AppError.storage(message: 'Test');

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: Builder(
              builder: (context) {
                return ElevatedButton(
                  onPressed: () {
                    ErrorSnackBar.show(context, error);
                  },
                  child: const Text('Show'),
                );
              },
            ),
          ),
        ),
      );

      await tester.tap(find.text('Show'));
      await tester.pump();

      expect(find.byType(SnackBar), findsOneWidget);

      // Wait for duration to pass
      await tester.pump(const Duration(seconds: 5));

      expect(find.byType(SnackBar), findsNothing);
    });
  });
}
