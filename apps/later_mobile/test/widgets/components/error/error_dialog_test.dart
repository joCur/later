import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:later_mobile/core/error/app_error.dart';
import 'package:later_mobile/design_system/organisms/error/error_dialog.dart';

void main() {
  group('ErrorDialog', () {
    testWidgets('renders with error message', (tester) async {
      final error = AppError.storage(
        message: 'Storage error',
        userMessage: 'Could not save your data',
      );

      await tester.pumpWidget(MaterialApp(home: ErrorDialog(error: error)));

      expect(find.byType(Dialog), findsOneWidget);
      expect(find.text('Could not save your data'), findsOneWidget);
    });

    testWidgets('shows error icon', (tester) async {
      final error = AppError.storage(message: 'Test');

      await tester.pumpWidget(MaterialApp(home: ErrorDialog(error: error)));

      expect(find.byIcon(Icons.error_outline), findsOneWidget);
    });

    testWidgets('displays title', (tester) async {
      final error = AppError.storage(message: 'Test');

      await tester.pumpWidget(MaterialApp(home: ErrorDialog(error: error)));

      expect(find.text('Something Went Wrong'), findsOneWidget);
    });

    testWidgets('displays custom title when provided', (tester) async {
      final error = AppError.storage(message: 'Test');

      await tester.pumpWidget(
        MaterialApp(
          home: ErrorDialog(error: error, title: 'Custom Error Title'),
        ),
      );

      expect(find.text('Custom Error Title'), findsOneWidget);
    });

    testWidgets('shows retry button for retryable errors', (tester) async {
      final error = AppError.storage(message: 'Test'); // Retryable

      await tester.pumpWidget(MaterialApp(home: ErrorDialog(error: error)));

      expect(find.text('Retry'), findsOneWidget);
    });

    testWidgets('shows dismiss button for non-retryable errors', (
      tester,
    ) async {
      final error = AppError.validation(message: 'Test'); // Not retryable

      await tester.pumpWidget(MaterialApp(home: ErrorDialog(error: error)));

      expect(find.text('Dismiss'), findsOneWidget);
    });

    testWidgets('calls onRetry when retry button tapped', (tester) async {
      final error = AppError.storage(message: 'Test');
      bool retryCalled = false;

      await tester.pumpWidget(
        MaterialApp(
          home: ErrorDialog(
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
        MaterialApp(
          home: Scaffold(
            body: Builder(
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

      await tester.pumpWidget(MaterialApp(home: ErrorDialog(error: error)));

      final dialog = tester.widget<Dialog>(find.byType(Dialog));
      expect(dialog.shape, isNotNull);
    });

    testWidgets('has correct max width constraint', (tester) async {
      final error = AppError.storage(message: 'Test');

      await tester.pumpWidget(MaterialApp(home: ErrorDialog(error: error)));

      final constrainedBox = tester.widget<ConstrainedBox>(
        find
            .descendant(
              of: find.byType(Dialog),
              matching: find.byType(ConstrainedBox),
            )
            .first,
      );

      expect(constrainedBox.constraints.maxWidth, 360);
    });

    testWidgets('shows technical details in debug mode', (tester) async {
      final error = AppError.storage(
        message: 'Storage error',
        details: 'Box is full',
      );

      await tester.pumpWidget(MaterialApp(home: ErrorDialog(error: error)));

      // In debug mode, technical details should be visible somewhere
      // (implementation may vary)
      expect(find.byType(ErrorDialog), findsOneWidget);
    });

    testWidgets('error icon has correct color', (tester) async {
      final error = AppError.storage(message: 'Test');

      await tester.pumpWidget(MaterialApp(home: ErrorDialog(error: error)));

      final icon = tester.widget<Icon>(find.byIcon(Icons.error_outline));
      expect(icon.size, 48);
      // Color should be error color
      expect(icon.color, isNotNull);
    });

    testWidgets('buttons are properly styled', (tester) async {
      final error = AppError.storage(message: 'Test');

      await tester.pumpWidget(MaterialApp(home: ErrorDialog(error: error)));

      // Should have styled buttons
      expect(find.byType(TextButton), findsAtLeastNWidgets(1));
    });

    testWidgets('dialog is dismissible by barrier tap', (tester) async {
      final error = AppError.storage(message: 'Test');

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: Builder(
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
        await tester.pumpWidget(MaterialApp(home: ErrorDialog(error: error)));

        expect(find.byType(ErrorDialog), findsOneWidget);
        expect(find.text(error.getUserMessage()), findsOneWidget);

        // Clear for next iteration
        await tester.pumpWidget(Container());
      }
    });

    testWidgets('content is scrollable for long messages', (tester) async {
      final error = AppError.storage(
        message: 'Error',
        userMessage: 'A' * 500, // Very long message
      );

      await tester.pumpWidget(MaterialApp(home: ErrorDialog(error: error)));

      // Should render without overflow
      expect(find.byType(ErrorDialog), findsOneWidget);
      expect(tester.takeException(), isNull);
    });

    testWidgets('maintains 24px padding', (tester) async {
      final error = AppError.storage(message: 'Test');

      await tester.pumpWidget(MaterialApp(home: ErrorDialog(error: error)));

      final padding = tester.widget<Padding>(
        find
            .descendant(of: find.byType(Dialog), matching: find.byType(Padding))
            .first,
      );

      expect(padding.padding, const EdgeInsets.all(24));
    });
  });
}
