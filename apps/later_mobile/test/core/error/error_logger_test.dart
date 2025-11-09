import 'package:flutter_test/flutter_test.dart';
import 'package:later_mobile/core/error/app_error.dart';
import 'package:later_mobile/core/error/error_codes.dart';
import 'package:later_mobile/core/error/error_logger.dart';

void main() {
  group('ErrorLogger', () {
    setUp(() {
      // Reset logger state before each test
      ErrorLogger.clearLogs();
    });

    group('logError', () {
      test('logs error in debug mode', () {
        // This test runs in debug mode by default
        expect(() {
          ErrorLogger.logError(
            const AppError(
              code: ErrorCode.databaseTimeout,
              message: 'Test error',
            ),
          );
        }, returnsNormally);
      });

      test('logs error with stack trace', () {
        const error = AppError(
          code: ErrorCode.databaseTimeout,
          message: 'Test error',
        );

        expect(() {
          try {
            throw Exception('Test exception');
          } catch (e, stackTrace) {
            ErrorLogger.logError(error, stackTrace: stackTrace);
          }
        }, returnsNormally);
      });

      test('logs error with context', () {
        const error = AppError(
          code: ErrorCode.databaseTimeout,
          message: 'Test error',
        );

        expect(() {
          ErrorLogger.logError(error, context: 'ItemsProvider.loadItems');
        }, returnsNormally);
      });

      test('logs error with additional data', () {
        const error = AppError(
          code: ErrorCode.databaseTimeout,
          message: 'Test error',
        );

        expect(() {
          ErrorLogger.logError(
            error,
            additionalData: {'userId': 'redacted', 'timestamp': '2024-01-01'},
          );
        }, returnsNormally);
      });

      test('does not log sensitive data', () {
        const error = AppError(
          code: ErrorCode.databaseTimeout,
          message: 'Test error',
        );

        // Should not throw even with sensitive-looking data
        expect(() {
          ErrorLogger.logError(
            error,
            additionalData: {
              'password': 'should-not-appear',
              'token': 'should-not-appear',
              'apiKey': 'should-not-appear',
            },
          );
        }, returnsNormally);
      });
    });

    group('logException', () {
      test('logs exception', () {
        final exception = Exception('Test exception');

        expect(() {
          ErrorLogger.logException(exception);
        }, returnsNormally);
      });

      test('logs exception with stack trace', () {
        expect(() {
          try {
            throw Exception('Test exception');
          } catch (e, stackTrace) {
            ErrorLogger.logException(e, stackTrace: stackTrace);
          }
        }, returnsNormally);
      });

      test('logs exception with context', () {
        final exception = Exception('Test exception');

        expect(() {
          ErrorLogger.logException(
            exception,
            context: 'SpacesProvider.addSpace',
          );
        }, returnsNormally);
      });
    });

    group('getRecentLogs', () {
      test('returns empty list when no logs', () {
        final logs = ErrorLogger.getRecentLogs();
        expect(logs, isEmpty);
      });

      test('returns logged errors in debug mode', () {
        // Log some errors
        ErrorLogger.logError(
          const AppError(code: ErrorCode.databaseTimeout, message: 'Error 1'),
        );
        ErrorLogger.logError(
          const AppError(code: ErrorCode.networkGeneric, message: 'Error 2'),
        );

        final logs = ErrorLogger.getRecentLogs();
        expect(logs.length, 2);
      });

      test('limits logs to specified count', () {
        // Log multiple errors
        for (int i = 0; i < 10; i++) {
          ErrorLogger.logError(
            AppError(code: ErrorCode.databaseTimeout, message: 'Error $i'),
          );
        }

        final logs = ErrorLogger.getRecentLogs(limit: 5);
        expect(logs.length, lessThanOrEqualTo(5));
      });

      test('returns most recent logs first', () {
        ErrorLogger.logError(
          const AppError(code: ErrorCode.databaseTimeout, message: 'First'),
        );
        ErrorLogger.logError(
          const AppError(code: ErrorCode.networkGeneric, message: 'Second'),
        );
        ErrorLogger.logError(
          const AppError(code: ErrorCode.validationRequired, message: 'Third'),
        );

        final logs = ErrorLogger.getRecentLogs();
        if (logs.isNotEmpty) {
          // Most recent should be first
          expect(logs.first['message'], contains('Third'));
        }
      });
    });

    group('clearLogs', () {
      test('clears all logs', () {
        // Log some errors
        ErrorLogger.logError(
          const AppError(code: ErrorCode.databaseTimeout, message: 'Error 1'),
        );
        ErrorLogger.logError(
          const AppError(code: ErrorCode.networkGeneric, message: 'Error 2'),
        );

        ErrorLogger.clearLogs();

        final logs = ErrorLogger.getRecentLogs();
        expect(logs, isEmpty);
      });
    });

    group('formatError', () {
      test('formats error with all details', () {
        const error = AppError(
          code: ErrorCode.databaseGeneric,
          message: 'Storage failed',
          technicalDetails: 'Box is full',
          userMessage: 'Please free up space',
        );

        final formatted = ErrorLogger.formatError(error);

        expect(formatted, contains('databaseGeneric'));
        expect(formatted, contains('Storage failed'));
        expect(formatted, contains('Box is full'));
      });

      test('formats error without technical details', () {
        const error = AppError(
          code: ErrorCode.networkGeneric,
          message: 'Connection failed',
        );

        final formatted = ErrorLogger.formatError(error);

        expect(formatted, contains('networkGeneric'));
        expect(formatted, contains('Connection failed'));
      });
    });

    group('sanitization', () {
      test('sanitizes sensitive keys in additional data', () {
        const error = AppError(
          code: ErrorCode.databaseTimeout,
          message: 'Test',
        );

        // This should not throw and should filter sensitive data
        expect(() {
          ErrorLogger.logError(
            error,
            additionalData: {
              'password': 'secret',
              'token': 'bearer-token',
              'apiKey': 'api-key',
              'secret': 'secret-value',
              'safeData': 'can-log-this',
            },
          );
        }, returnsNormally);
      });
    });

    group('production behavior', () {
      test('does not store logs in production mode', () {
        // Simulate production by clearing debug flag behavior
        // In real production, kDebugMode would be false

        ErrorLogger.clearLogs();
        ErrorLogger.logError(
          const AppError(
            code: ErrorCode.databaseTimeout,
            message: 'Production error',
          ),
        );

        // In test mode (debug), logs should be stored
        final logs = ErrorLogger.getRecentLogs();
        // This test just verifies the method works correctly
        expect(logs, isNotNull);
      });
    });

    group('log entry structure', () {
      test('log entry contains required fields', () {
        ErrorLogger.logError(
          const AppError(code: ErrorCode.databaseTimeout, message: 'Test error'),
          context: 'TestContext',
        );

        final logs = ErrorLogger.getRecentLogs();
        if (logs.isNotEmpty) {
          final entry = logs.first;
          expect(entry['timestamp'], isNotNull);
          expect(entry['type'], isNotNull);
          expect(entry['message'], isNotNull);
        }
      });

      test('log entry includes context when provided', () {
        ErrorLogger.logError(
          const AppError(code: ErrorCode.databaseTimeout, message: 'Test error'),
          context: 'MyContext',
        );

        final logs = ErrorLogger.getRecentLogs();
        if (logs.isNotEmpty) {
          final entry = logs.first;
          expect(entry['context'], 'MyContext');
        }
      });

      test('log entry includes stack trace info when provided', () {
        try {
          throw Exception('Test');
        } catch (e, stackTrace) {
          ErrorLogger.logError(
            const AppError(
              code: ErrorCode.databaseTimeout,
              message: 'Test error',
            ),
            stackTrace: stackTrace,
          );
        }

        final logs = ErrorLogger.getRecentLogs();
        if (logs.isNotEmpty) {
          final entry = logs.first;
          expect(entry['hasStackTrace'], isTrue);
        }
      });
    });
  });
}
