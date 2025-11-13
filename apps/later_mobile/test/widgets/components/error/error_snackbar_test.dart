import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:later_mobile/core/error/app_error.dart';
import 'package:later_mobile/core/error/error_codes.dart';
import 'package:later_mobile/design_system/organisms/error/error_snackbar.dart';
import '../../../test_helpers.dart';

void main() {
  group('ErrorSnackBar', () {
    testWidgets('shows snackbar with error message', (tester) async {
      const error = AppError(
        code: ErrorCode.databaseTimeout,
        message: 'Storage error',
        userMessage: 'Failed to save',
      );

      await tester.pumpWidget(
        testApp(
          Builder(
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
      );

      await tester.tap(find.text('Show'));
      await tester.pump();

      expect(find.byType(SnackBar), findsOneWidget);
      expect(find.text('Failed to save'), findsOneWidget);
    });

    testWidgets('shows action button for retryable errors', (tester) async {
      const error = AppError(
        code: ErrorCode.databaseTimeout,
        message: 'Test',
      ); // Retryable

      await tester.pumpWidget(
        testApp(
          Builder(
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
      );

      await tester.tap(find.text('Show'));
      await tester.pump();

      expect(find.text('Retry'), findsOneWidget);
    });

    testWidgets('does not show action for non-retryable errors', (
      tester,
    ) async {
      const error = AppError(
        code: ErrorCode.validationRequired,
        message: 'Test',
      ); // Not retryable

      await tester.pumpWidget(
        testApp(
          Builder(
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
      );

      await tester.tap(find.text('Show'));
      await tester.pump();

      expect(find.byType(SnackBar), findsOneWidget);
      // Should not have retry action
      expect(find.text('Retry'), findsNothing);
    });

    testWidgets('calls onRetry when action tapped', (tester) async {
      const error = AppError(
        code: ErrorCode.databaseTimeout,
        message: 'Test',
      );
      bool retryCalled = false;

      await tester.pumpWidget(
        testApp(
          Builder(
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
      );

      await tester.tap(find.text('Show'));
      await tester.pumpAndSettle();

      // Find the SnackBarAction button and tap it
      final retryButton = find.descendant(
        of: find.byType(SnackBar),
        matching: find.text('Retry'),
      );

      await tester.tap(retryButton, warnIfMissed: false);
      await tester.pumpAndSettle();

      expect(retryCalled, isTrue);
    });

    testWidgets('shows error icon', (tester) async {
      const error = AppError(
        code: ErrorCode.databaseTimeout,
        message: 'Test',
      );

      await tester.pumpWidget(
        testApp(
          Builder(
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
      );

      await tester.tap(find.text('Show'));
      await tester.pump();

      // Should have error icon
      expect(find.byIcon(Icons.error_outline), findsOneWidget);
    });

    testWidgets('handles different error types', (tester) async {
      final errors = [
        const AppError(
          code: ErrorCode.databaseTimeout,
          message: 'Storage',
        ),
        const AppError(
          code: ErrorCode.networkGeneric,
          message: 'Network',
        ),
        const AppError(
          code: ErrorCode.validationRequired,
          message: 'Validation',
        ),
        const AppError(
          code: ErrorCode.databaseGeneric,
          message: 'Corruption',
        ),
      ];

      for (final error in errors) {
        await tester.pumpWidget(
          testApp(
            Builder(
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
        );

        await tester.tap(find.text('Show'));
        await tester.pump();

        expect(find.byType(SnackBar), findsOneWidget);

        // Clear snackbar for next iteration
        await tester.pumpAndSettle(const Duration(seconds: 5));
      }
    });

    testWidgets('dismisses previous snackbar when showing new one', (
      tester,
    ) async {
      const error1 = AppError(
        code: ErrorCode.databaseTimeout,
        message: 'Error 1',
      );
      const error2 = AppError(
        code: ErrorCode.networkGeneric,
        message: 'Error 2',
      );

      await tester.pumpWidget(
        testApp(
          Builder(
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
      );

      await tester.tap(find.text('Show 1'));
      await tester.pump();

      // Check for keyword from databaseTimeout localized message
      expect(
        find.textContaining('took too long', findRichText: true),
        findsOneWidget,
      );

      await tester.tap(find.text('Show 2'));
      await tester.pump();

      // Should only show the second snackbar with networkGeneric localized keyword
      expect(
        find.textContaining('network error', findRichText: true),
        findsOneWidget,
      );
    });

    testWidgets('snackbar has error background color', (tester) async {
      const error = AppError(
        code: ErrorCode.databaseTimeout,
        message: 'Test',
      );

      await tester.pumpWidget(
        testApp(
          Builder(
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
      );

      await tester.tap(find.text('Show'));
      await tester.pump();

      final snackBar = tester.widget<SnackBar>(find.byType(SnackBar));
      // Should have error background color
      expect(snackBar.backgroundColor, isNotNull);
    });

    testWidgets('can show custom action label', (tester) async {
      const error = AppError(
        code: ErrorCode.databaseTimeout, // Use retryable error code
        message: 'Test',
        actionLabel: 'Try Again',
      );

      await tester.pumpWidget(
        testApp(
          Builder(
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
      );

      await tester.tap(find.text('Show'));
      await tester.pump();

      expect(find.text('Try Again'), findsOneWidget);
    });

    testWidgets('snackbar contains user-friendly message', (tester) async {
      const error = AppError(
        code: ErrorCode.networkGeneric,
        message: 'Connection failed',
        userMessage: 'Please check your internet connection',
      );

      await tester.pumpWidget(
        testApp(
          Builder(
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
      );

      await tester.tap(find.text('Show'));
      await tester.pump();

      expect(
        find.text('Please check your internet connection'),
        findsOneWidget,
      );
    });

    testWidgets('action button is visible for retryable storage errors', (
      tester,
    ) async {
      const error = AppError(
        code: ErrorCode.databaseTimeout,
        message: 'Storage failed',
      );

      await tester.pumpWidget(
        testApp(
          Builder(
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
      );

      await tester.tap(find.text('Show'));
      await tester.pump();

      // Storage errors are retryable
      expect(find.text('Retry'), findsOneWidget);
    });

    testWidgets('action button is visible for retryable network errors', (
      tester,
    ) async {
      const error = AppError(
        code: ErrorCode.networkGeneric,
        message: 'Network failed',
      );

      await tester.pumpWidget(
        testApp(
          Builder(
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
      );

      await tester.tap(find.text('Show'));
      await tester.pump();

      // Network errors are retryable
      expect(find.text('Retry'), findsOneWidget);
    });
  });
}
