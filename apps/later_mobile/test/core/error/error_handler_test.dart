import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:later_mobile/core/error/app_error.dart';
import 'package:later_mobile/core/error/error_handler.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  group('ErrorHandler', () {
    setUp(() {
      ErrorHandler.clearLastError();
    });

    group('initialize', () {
      test('initializes without error', () {
        expect(() => ErrorHandler.initialize(), returnsNormally);
      });

      test('can be called multiple times safely', () {
        ErrorHandler.initialize();
        ErrorHandler.initialize();
        // Should not throw
      });
    });

    group('handleError', () {
      test('handles AppError', () {
        final error = AppError.storage(message: 'Test error');

        expect(() {
          ErrorHandler.handleError(error);
        }, returnsNormally);
      });

      test('handles Exception', () {
        final exception = Exception('Test exception');

        expect(() {
          ErrorHandler.handleError(exception);
        }, returnsNormally);
      });

      test('handles Error', () {
        final error = ArgumentError('Test argument error');

        expect(() {
          ErrorHandler.handleError(error);
        }, returnsNormally);
      });

      test('handles unknown error types', () {
        expect(() {
          ErrorHandler.handleError('String error');
        }, returnsNormally);
      });

      test('stores last error', () {
        final error = AppError.storage(message: 'Test error');
        ErrorHandler.handleError(error);

        final lastError = ErrorHandler.getLastError();
        expect(lastError, isNotNull);
        expect(lastError?.message, 'Test error');
      });

      test('handles error with stack trace', () {
        final error = AppError.storage(message: 'Test error');

        expect(() {
          try {
            throw Exception('Test');
          } catch (e, stackTrace) {
            ErrorHandler.handleError(error, stackTrace: stackTrace);
          }
        }, returnsNormally);
      });

      test('handles error with context', () {
        final error = AppError.storage(message: 'Test error');

        expect(() {
          ErrorHandler.handleError(error, context: 'ItemsProvider.loadItems');
        }, returnsNormally);
      });
    });

    group('handleFlutterError', () {
      test('handles FlutterErrorDetails', () {
        final details = FlutterErrorDetails(
          exception: Exception('Test exception'),
          stack: StackTrace.current,
          library: 'test library',
          context: ErrorDescription('test context'),
        );

        expect(() {
          ErrorHandler.handleFlutterError(details);
        }, returnsNormally);
      });

      test('extracts context from FlutterErrorDetails', () {
        final details = FlutterErrorDetails(
          exception: Exception('Test exception'),
          context: ErrorDescription('Widget rendering'),
        );

        ErrorHandler.handleFlutterError(details);

        final lastError = ErrorHandler.getLastError();
        expect(lastError, isNotNull);
      });
    });

    group('showErrorDialog', () {
      testWidgets('shows error dialog', (tester) async {
        final error = AppError.storage(
          message: 'Test error',
          userMessage: 'User friendly message',
        );

        await tester.pumpWidget(
          MaterialApp(
            home: Scaffold(
              body: Builder(
                builder: (context) {
                  return ElevatedButton(
                    onPressed: () {
                      ErrorHandler.showErrorDialog(context, error);
                    },
                    child: const Text('Show Error'),
                  );
                },
              ),
            ),
          ),
        );

        // Tap button to show dialog
        await tester.tap(find.text('Show Error'));
        await tester.pumpAndSettle();

        // Verify dialog is shown
        expect(find.byType(AlertDialog), findsOneWidget);
      });

      testWidgets('dialog contains error message', (tester) async {
        final error = AppError.storage(
          message: 'Technical error',
          userMessage: 'User friendly message',
        );

        await tester.pumpWidget(
          MaterialApp(
            home: Scaffold(
              body: Builder(
                builder: (context) {
                  return ElevatedButton(
                    onPressed: () {
                      ErrorHandler.showErrorDialog(context, error);
                    },
                    child: const Text('Show Error'),
                  );
                },
              ),
            ),
          ),
        );

        await tester.tap(find.text('Show Error'));
        await tester.pumpAndSettle();

        // Should show user-friendly message
        expect(find.text('User friendly message'), findsOneWidget);
      });

      testWidgets('dialog has action button', (tester) async {
        final error = AppError.storage(message: 'Test error');

        await tester.pumpWidget(
          MaterialApp(
            home: Scaffold(
              body: Builder(
                builder: (context) {
                  return ElevatedButton(
                    onPressed: () {
                      ErrorHandler.showErrorDialog(context, error);
                    },
                    child: const Text('Show Error'),
                  );
                },
              ),
            ),
          ),
        );

        await tester.tap(find.text('Show Error'));
        await tester.pumpAndSettle();

        // Should have action button
        expect(find.text('Retry'), findsOneWidget);
      });

      testWidgets('dialog can be dismissed', (tester) async {
        final error = AppError.storage(message: 'Test error');

        await tester.pumpWidget(
          MaterialApp(
            home: Scaffold(
              body: Builder(
                builder: (context) {
                  return ElevatedButton(
                    onPressed: () {
                      ErrorHandler.showErrorDialog(context, error);
                    },
                    child: const Text('Show Error'),
                  );
                },
              ),
            ),
          ),
        );

        await tester.tap(find.text('Show Error'));
        await tester.pumpAndSettle();

        // Dismiss dialog
        await tester.tap(find.text('Retry'));
        await tester.pumpAndSettle();

        // Dialog should be closed
        expect(find.byType(AlertDialog), findsNothing);
      });

      testWidgets('dialog calls onRetry callback', (tester) async {
        final error = AppError.storage(message: 'Test error');
        bool retryCalledVar = false;

        await tester.pumpWidget(
          MaterialApp(
            home: Scaffold(
              body: Builder(
                builder: (context) {
                  return ElevatedButton(
                    onPressed: () {
                      ErrorHandler.showErrorDialog(
                        context,
                        error,
                        onRetry: () {
                          retryCalledVar = true;
                        },
                      );
                    },
                    child: const Text('Show Error'),
                  );
                },
              ),
            ),
          ),
        );

        await tester.tap(find.text('Show Error'));
        await tester.pumpAndSettle();

        await tester.tap(find.text('Retry'));
        await tester.pumpAndSettle();

        expect(retryCalledVar, isTrue);
      });
    });

    group('showErrorSnackBar', () {
      testWidgets('shows error snackbar', (tester) async {
        final error = AppError.storage(message: 'Test error');

        await tester.pumpWidget(
          MaterialApp(
            home: Scaffold(
              body: Builder(
                builder: (context) {
                  return ElevatedButton(
                    onPressed: () {
                      ErrorHandler.showErrorSnackBar(context, error);
                    },
                    child: const Text('Show Error'),
                  );
                },
              ),
            ),
          ),
        );

        await tester.tap(find.text('Show Error'));
        await tester.pump();

        expect(find.byType(SnackBar), findsOneWidget);
      });

      testWidgets('snackbar contains error message', (tester) async {
        final error = AppError.storage(
          message: 'Technical',
          userMessage: 'User message',
        );

        await tester.pumpWidget(
          MaterialApp(
            home: Scaffold(
              body: Builder(
                builder: (context) {
                  return ElevatedButton(
                    onPressed: () {
                      ErrorHandler.showErrorSnackBar(context, error);
                    },
                    child: const Text('Show Error'),
                  );
                },
              ),
            ),
          ),
        );

        await tester.tap(find.text('Show Error'));
        await tester.pump();

        expect(find.text('User message'), findsOneWidget);
      });

      testWidgets('snackbar has action button for retryable errors', (
        tester,
      ) async {
        final error = AppError.storage(message: 'Test error');

        await tester.pumpWidget(
          MaterialApp(
            home: Scaffold(
              body: Builder(
                builder: (context) {
                  return ElevatedButton(
                    onPressed: () {
                      ErrorHandler.showErrorSnackBar(context, error);
                    },
                    child: const Text('Show Error'),
                  );
                },
              ),
            ),
          ),
        );

        await tester.tap(find.text('Show Error'));
        await tester.pump();

        expect(find.text('Retry'), findsOneWidget);
      });
    });

    group('getLastError', () {
      test('returns null when no error', () {
        expect(ErrorHandler.getLastError(), isNull);
      });

      test('returns last handled error', () {
        final error1 = AppError.storage(message: 'Error 1');
        final error2 = AppError.network(message: 'Error 2');

        ErrorHandler.handleError(error1);
        ErrorHandler.handleError(error2);

        final lastError = ErrorHandler.getLastError();
        expect(lastError?.message, 'Error 2');
      });
    });

    group('clearLastError', () {
      test('clears last error', () {
        final error = AppError.storage(message: 'Test error');
        ErrorHandler.handleError(error);

        ErrorHandler.clearLastError();

        expect(ErrorHandler.getLastError(), isNull);
      });
    });

    group('convertToAppError', () {
      test('returns AppError as-is', () {
        final error = AppError.storage(message: 'Test');
        final result = ErrorHandler.convertToAppError(error);

        expect(result, same(error));
      });

      test('converts Exception to AppError', () {
        final exception = Exception('Test exception');
        final result = ErrorHandler.convertToAppError(exception);

        expect(result, isA<AppError>());
        expect(result.message, contains('Test exception'));
      });

      test('converts ArgumentError to validation AppError', () {
        final error = ArgumentError('Invalid argument');
        final result = ErrorHandler.convertToAppError(error);

        expect(result, isA<AppError>());
        expect(result.type, ErrorType.validation);
      });

      test('converts unknown error to AppError', () {
        final result = ErrorHandler.convertToAppError('String error');

        expect(result, isA<AppError>());
        expect(result.type, ErrorType.unknown);
      });
    });
  });
}
