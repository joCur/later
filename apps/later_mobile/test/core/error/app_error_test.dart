import 'package:flutter_test/flutter_test.dart';
import 'package:later_mobile/core/error/app_error.dart';

void main() {
  group('AppError', () {
    group('constructor', () {
      test('creates error with message', () {
        const error = AppError(
          type: ErrorType.storage,
          message: 'Storage error occurred',
        );

        expect(error.type, ErrorType.storage);
        expect(error.message, 'Storage error occurred');
        expect(error.technicalDetails, isNull);
        expect(error.userMessage, isNull);
        expect(error.actionLabel, isNull);
      });

      test('creates error with all fields', () {
        const error = AppError(
          type: ErrorType.network,
          message: 'Network error occurred',
          technicalDetails: 'Connection timeout after 30s',
          userMessage: 'Please check your internet connection',
          actionLabel: 'Retry',
        );

        expect(error.type, ErrorType.network);
        expect(error.message, 'Network error occurred');
        expect(error.technicalDetails, 'Connection timeout after 30s');
        expect(error.userMessage, 'Please check your internet connection');
        expect(error.actionLabel, 'Retry');
      });
    });

    group('factory constructors', () {
      test('storage creates storage error', () {
        final error = AppError.storage(
          message: 'Failed to save data',
          details: 'Box is full',
        );

        expect(error.type, ErrorType.storage);
        expect(error.message, 'Failed to save data');
        expect(error.technicalDetails, 'Box is full');
        expect(error.userMessage, isNotNull);
        expect(error.userMessage, contains('storage'));
      });

      test('network creates network error', () {
        final error = AppError.network(
          message: 'Connection failed',
          details: 'Timeout',
        );

        expect(error.type, ErrorType.network);
        expect(error.message, 'Connection failed');
        expect(error.technicalDetails, 'Timeout');
        expect(error.userMessage, isNotNull);
        expect(error.userMessage, contains('connection'));
      });

      test('validation creates validation error', () {
        final error = AppError.validation(
          message: 'Invalid input',
          details: 'Title cannot be empty',
        );

        expect(error.type, ErrorType.validation);
        expect(error.message, 'Invalid input');
        expect(error.technicalDetails, 'Title cannot be empty');
        expect(error.userMessage, isNotNull);
      });

      test('corruption creates corruption error', () {
        final error = AppError.corruption(
          message: 'Data corrupted',
          details: 'Invalid format',
        );

        expect(error.type, ErrorType.corruption);
        expect(error.message, 'Data corrupted');
        expect(error.technicalDetails, 'Invalid format');
        expect(error.userMessage, isNotNull);
        expect(error.userMessage, contains('corrupted'));
      });

      test('unknown creates unknown error', () {
        final error = AppError.unknown(
          message: 'Something went wrong',
          details: 'Unknown cause',
        );

        expect(error.type, ErrorType.unknown);
        expect(error.message, 'Something went wrong');
        expect(error.technicalDetails, 'Unknown cause');
        expect(error.userMessage, isNotNull);
      });

      test('fromException creates error from exception', () {
        final exception = Exception('Test exception');
        final error = AppError.fromException(exception);

        expect(error.type, ErrorType.unknown);
        expect(error.message, contains('Test exception'));
        expect(error.userMessage, isNotNull);
      });

      test('fromException with known storage exception', () {
        final exception = Exception('Hive: Box is full');
        final error = AppError.fromException(exception);

        expect(error.type, ErrorType.storage);
        expect(error.message, contains('Hive'));
      });
    });

    group('isRetryable', () {
      test('network errors are retryable', () {
        final error = AppError.network(message: 'Connection failed');
        expect(error.isRetryable, isTrue);
      });

      test('storage errors are retryable', () {
        final error = AppError.storage(message: 'Save failed');
        expect(error.isRetryable, isTrue);
      });

      test('validation errors are not retryable', () {
        final error = AppError.validation(message: 'Invalid input');
        expect(error.isRetryable, isFalse);
      });

      test('corruption errors are not retryable', () {
        final error = AppError.corruption(message: 'Data corrupted');
        expect(error.isRetryable, isFalse);
      });

      test('unknown errors are not retryable', () {
        final error = AppError.unknown(message: 'Something wrong');
        expect(error.isRetryable, isFalse);
      });
    });

    group('getUserMessage', () {
      test('returns custom user message if provided', () {
        const error = AppError(
          type: ErrorType.storage,
          message: 'Technical message',
          userMessage: 'Custom user message',
        );

        expect(error.getUserMessage(), 'Custom user message');
      });

      test('returns default message for storage error', () {
        final error = AppError.storage(message: 'Technical');
        final userMessage = error.getUserMessage();

        expect(userMessage, isNotNull);
        expect(userMessage, isNot(contains('Technical')));
      });

      test('returns default message for network error', () {
        final error = AppError.network(message: 'Technical');
        final userMessage = error.getUserMessage();

        expect(userMessage, isNotNull);
        expect(userMessage, contains('connection'));
      });
    });

    group('getActionLabel', () {
      test('returns custom action label if provided', () {
        const error = AppError(
          type: ErrorType.storage,
          message: 'Error',
          actionLabel: 'Custom Action',
        );

        expect(error.getActionLabel(), 'Custom Action');
      });

      test('returns Retry for retryable errors', () {
        final error = AppError.network(message: 'Error');
        expect(error.getActionLabel(), 'Retry');
      });

      test('returns Dismiss for non-retryable errors', () {
        final error = AppError.validation(message: 'Error');
        expect(error.getActionLabel(), 'Dismiss');
      });
    });

    group('toString', () {
      test('includes type and message', () {
        const error = AppError(
          type: ErrorType.storage,
          message: 'Storage error',
        );

        final str = error.toString();
        expect(str, contains('storage'));
        expect(str, contains('Storage error'));
      });

      test('includes technical details if present', () {
        const error = AppError(
          type: ErrorType.network,
          message: 'Network error',
          technicalDetails: 'Timeout occurred',
        );

        final str = error.toString();
        expect(str, contains('Timeout occurred'));
      });
    });

    group('copyWith', () {
      test('copies with updated message', () {
        const original = AppError(
          type: ErrorType.storage,
          message: 'Original',
        );

        final copy = original.copyWith(message: 'Updated');

        expect(copy.type, original.type);
        expect(copy.message, 'Updated');
      });

      test('copies with updated userMessage', () {
        const original = AppError(
          type: ErrorType.storage,
          message: 'Error',
          userMessage: 'Original user message',
        );

        final copy = original.copyWith(userMessage: 'Updated user message');

        expect(copy.type, original.type);
        expect(copy.message, original.message);
        expect(copy.userMessage, 'Updated user message');
      });

      test('preserves original values if not specified', () {
        const original = AppError(
          type: ErrorType.network,
          message: 'Error',
          technicalDetails: 'Details',
          userMessage: 'User message',
          actionLabel: 'Action',
        );

        final copy = original.copyWith();

        expect(copy.type, original.type);
        expect(copy.message, original.message);
        expect(copy.technicalDetails, original.technicalDetails);
        expect(copy.userMessage, original.userMessage);
        expect(copy.actionLabel, original.actionLabel);
      });
    });
  });

  group('ErrorType', () {
    test('has all expected types', () {
      expect(ErrorType.values, contains(ErrorType.storage));
      expect(ErrorType.values, contains(ErrorType.network));
      expect(ErrorType.values, contains(ErrorType.validation));
      expect(ErrorType.values, contains(ErrorType.corruption));
      expect(ErrorType.values, contains(ErrorType.unknown));
    });
  });
}
