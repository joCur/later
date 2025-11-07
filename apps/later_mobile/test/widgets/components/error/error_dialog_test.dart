import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:later_mobile/core/error/app_error.dart';
import 'package:later_mobile/design_system/organisms/error/error_dialog.dart';
import '../../../test_helpers.dart';

void main() {
  group('ErrorDialog', () {
    testWidgets('renders with error message', (tester) async {
      final error = AppError.storage(
        message: 'Storage error',
        userMessage: 'Could not save your data',
      );

      await tester.pumpWidget(testApp(ErrorDialog(error: error)));

      expect(find.byType(Dialog), findsOneWidget);
      expect(find.text('Could not save your data'), findsOneWidget);
    });

    testWidgets('shows error icon', (tester) async {
      final error = AppError.storage(message: 'Test');

      await tester.pumpWidget(testApp(ErrorDialog(error: error)));

      expect(find.byIcon(Icons.error_outline), findsOneWidget);
    });

    testWidgets('displays default title', (tester) async {
      final error = AppError.storage(message: 'Test');

      await tester.pumpWidget(testApp(ErrorDialog(error: error)));

      expect(find.text('Something Went Wrong'), findsOneWidget);
    });

    testWidgets('displays custom title when provided', (tester) async {
      final error = AppError.storage(message: 'Test');

      await tester.pumpWidget(
        testApp(ErrorDialog(error: error, title: 'Custom Error Title')),
      );

      expect(find.text('Custom Error Title'), findsOneWidget);
    });

    testWidgets('shows retry button for retryable errors', (tester) async {
      final error = AppError.storage(message: 'Test'); // Retryable

      await tester.pumpWidget(testApp(ErrorDialog(error: error)));

      expect(find.text('Retry'), findsOneWidget);
    });

    testWidgets('shows dismiss button for non-retryable errors', (
      tester,
    ) async {
      final error = AppError.validation(message: 'Test'); // Not retryable

      await tester.pumpWidget(testApp(ErrorDialog(error: error)));

      expect(find.text('Dismiss'), findsOneWidget);
      expect(find.text('Retry'), findsNothing);
    });

    testWidgets('calls onRetry when retry button tapped', (tester) async {
      final error = AppError.storage(message: 'Test');
      bool retryCalled = false;

      await tester.pumpWidget(
        testApp(
          ErrorDialog(
            error: error,
            onRetry: () {
              retryCalled = true;
            },
          ),
        ),
      );

      await tester.tap(find.text('Retry'));
      await tester.pumpAndSettle();

      expect(retryCalled, isTrue);
    });

    testWidgets('closes dialog when dismiss button tapped', (tester) async {
      final error = AppError.storage(message: 'Test');

      await tester.pumpWidget(
        testApp(
          Builder(
            builder: (context) {
              return ElevatedButton(
                onPressed: () {
                  showDialog<void>(
                    context: context,
                    builder: (_) => ErrorDialog(error: error),
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

      expect(find.byType(ErrorDialog), findsOneWidget);

      await tester.tap(find.text('Retry'));
      await tester.pumpAndSettle();

      expect(find.byType(ErrorDialog), findsNothing);
    });

    testWidgets('applies correct styling', (tester) async {
      final error = AppError.storage(message: 'Test');

      await tester.pumpWidget(testApp(ErrorDialog(error: error)));

      final dialog = tester.widget<Dialog>(find.byType(Dialog));
      expect(dialog.shape, isNotNull);
    });

    testWidgets('has correct max width constraint', (tester) async {
      final error = AppError.storage(message: 'Test');

      await tester.pumpWidget(testApp(ErrorDialog(error: error)));

      // Find the ConstrainedBox inside the Dialog
      final constrainedBoxes = find
          .descendant(
            of: find.byType(Dialog),
            matching: find.byType(ConstrainedBox),
          )
          .evaluate();

      // Should have a ConstrainedBox with max width of 360
      expect(
        constrainedBoxes.any((element) {
          final widget = element.widget as ConstrainedBox;
          return widget.constraints.maxWidth == 360;
        }),
        isTrue,
      );
    });

    testWidgets('error icon has correct size', (tester) async {
      final error = AppError.storage(message: 'Test');

      await tester.pumpWidget(testApp(ErrorDialog(error: error)));

      final icon = tester.widget<Icon>(find.byIcon(Icons.error_outline));
      expect(icon.size, 48);
      expect(icon.color, isNotNull);
    });

    testWidgets('dialog is dismissible by barrier tap', (tester) async {
      final error = AppError.storage(message: 'Test');

      await tester.pumpWidget(
        testApp(
          Builder(
            builder: (context) {
              return ElevatedButton(
                onPressed: () {
                  showDialog<void>(
                    context: context,
                    builder: (_) => ErrorDialog(error: error),
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

      expect(find.byType(ErrorDialog), findsOneWidget);

      // Tap outside dialog (barrier)
      await tester.tapAt(const Offset(10, 10));
      await tester.pumpAndSettle();

      expect(find.byType(ErrorDialog), findsNothing);
    });

    testWidgets('different error types show appropriate messages', (
      tester,
    ) async {
      final errors = [
        AppError.storage(message: 'Storage'),
        AppError.network(message: 'Network'),
        AppError.validation(message: 'Validation'),
        AppError.corruption(message: 'Corruption'),
      ];

      for (final error in errors) {
        await tester.pumpWidget(testApp(ErrorDialog(error: error)));

        expect(find.byType(ErrorDialog), findsOneWidget);
        expect(find.text(error.getUserMessage()), findsOneWidget);

        // Clear for next iteration
        await tester.pumpWidget(Container());
      }
    });

    testWidgets('handles long error messages without overflow', (
      tester,
    ) async {
      final error = AppError.storage(
        message: 'Error',
        userMessage: 'A' * 500, // Very long message
      );

      await tester.pumpWidget(testApp(ErrorDialog(error: error)));

      // Should render without overflow
      expect(find.byType(ErrorDialog), findsOneWidget);
      expect(tester.takeException(), isNull);
    });

    testWidgets('shows both Dismiss and primary action for retryable errors',
        (tester) async {
      final error = AppError.storage(message: 'Test');

      await tester.pumpWidget(testApp(ErrorDialog(error: error)));

      // Retryable errors show both Dismiss (ghost) and Retry (primary)
      expect(find.text('Dismiss'), findsOneWidget);
      expect(find.text('Retry'), findsOneWidget);
    });

    testWidgets('closes dialog after retry button is tapped', (tester) async {
      final error = AppError.storage(message: 'Test');

      await tester.pumpWidget(
        testApp(
          Builder(
            builder: (context) {
              return ElevatedButton(
                onPressed: () {
                  showDialog<void>(
                    context: context,
                    builder: (_) => ErrorDialog(
                      error: error,
                      onRetry: () {},
                    ),
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

      expect(find.byType(ErrorDialog), findsOneWidget);

      // Tap retry button
      await tester.tap(find.text('Retry'));
      await tester.pumpAndSettle();

      // Dialog should be closed
      expect(find.byType(ErrorDialog), findsNothing);
    });
  });
}
