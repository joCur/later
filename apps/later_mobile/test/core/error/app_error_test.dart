import 'package:flutter_test/flutter_test.dart';
import 'package:later_mobile/core/error/app_error.dart';
import 'package:later_mobile/core/error/error_codes.dart';

void main() {
  group('AppError', () {
    group('constructor', () {
      test('creates error with message', () {
        const error = AppError(
          code: ErrorCode.databaseGeneric,
          message: 'Storage error occurred',
        );

        expect(error.code, ErrorCode.databaseGeneric);
        expect(error.message, 'Storage error occurred');
        expect(error.technicalDetails, isNull);
        expect(error.userMessage, isNull);
        expect(error.actionLabel, isNull);
      });

      test('creates error with all fields', () {
        const error = AppError(
          code: ErrorCode.networkTimeout,
          message: 'Network error occurred',
          technicalDetails: 'Connection timeout after 30s',
          userMessage: 'Please check your internet connection',
          actionLabel: 'Retry',
        );

        expect(error.code, ErrorCode.networkTimeout);
        expect(error.message, 'Network error occurred');
        expect(error.technicalDetails, 'Connection timeout after 30s');
        expect(error.userMessage, 'Please check your internet connection');
        expect(error.actionLabel, 'Retry');
      });
    });

    group('error properties', () {
      test('has correct code and message', () {
        const error = AppError(
          code: ErrorCode.databaseTimeout,
          message: 'Failed to save data',
          technicalDetails: 'Box is full',
        );

        expect(error.code, ErrorCode.databaseTimeout);
        expect(error.message, 'Failed to save data');
        expect(error.technicalDetails, 'Box is full');
      });

      test('network error has correct properties', () {
        const error = AppError(
          code: ErrorCode.networkGeneric,
          message: 'Connection failed',
          technicalDetails: 'Timeout',
        );

        expect(error.code, ErrorCode.networkGeneric);
        expect(error.message, 'Connection failed');
        expect(error.technicalDetails, 'Timeout');
      });

      test('validation error has correct properties', () {
        const error = AppError(
          code: ErrorCode.validationRequired,
          message: 'Invalid input',
          technicalDetails: 'Title cannot be empty',
        );

        expect(error.code, ErrorCode.validationRequired);
        expect(error.message, 'Invalid input');
        expect(error.technicalDetails, 'Title cannot be empty');
      });
    });

    group('isRetryable', () {
      test('network errors are retryable', () {
        const error = AppError(
          code: ErrorCode.networkGeneric,
          message: 'Connection failed',
        );
        expect(error.isRetryable, isTrue);
      });

      test('database timeout errors are retryable', () {
        const error = AppError(
          code: ErrorCode.databaseTimeout,
          message: 'Save failed',
        );
        expect(error.isRetryable, isTrue);
      });

      test('database errors are not retryable', () {
        const error = AppError(
          code: ErrorCode.databaseGeneric,
          message: 'Save failed',
        );
        expect(error.isRetryable, isFalse);
      });

      test('validation errors are not retryable', () {
        const error = AppError(
          code: ErrorCode.validationRequired,
          message: 'Invalid input',
        );
        expect(error.isRetryable, isFalse);
      });

      test('unknown errors are not retryable', () {
        const error = AppError(
          code: ErrorCode.unknownError,
          message: 'Something wrong',
        );
        expect(error.isRetryable, isFalse);
      });
    });

    group('getUserMessageLocalized', () {
      test('returns custom user message if provided', () {
        const error = AppError(
          code: ErrorCode.databaseGeneric,
          message: 'Technical message',
          userMessage: 'Custom user message',
        );

        expect(error.getUserMessageLocalized(), 'Custom user message');
      });

      test('returns default message for database error', () {
        const error = AppError(
          code: ErrorCode.databaseTimeout,
          message: 'Technical',
        );
        final userMessage = error.getUserMessageLocalized();

        expect(userMessage, isNotNull);
        expect(userMessage, isNot(contains('Technical')));
      });

      test('returns default message for network error', () {
        const error = AppError(
          code: ErrorCode.networkGeneric,
          message: 'Technical',
        );
        final userMessage = error.getUserMessageLocalized();

        expect(userMessage, isNotNull);
        expect(userMessage, contains('connection'));
      });
    });

    group('getActionLabel', () {
      test('returns custom action label if provided', () {
        const error = AppError(
          code: ErrorCode.databaseGeneric,
          message: 'Error',
          actionLabel: 'Custom Action',
        );

        expect(error.getActionLabel(), 'Custom Action');
      });

      test('returns Retry for retryable errors', () {
        const error = AppError(
          code: ErrorCode.networkGeneric,
          message: 'Error',
        );
        expect(error.getActionLabel(), 'Retry');
      });

      test('returns Dismiss for non-retryable errors', () {
        const error = AppError(
          code: ErrorCode.validationRequired,
          message: 'Error',
        );
        expect(error.getActionLabel(), 'Dismiss');
      });
    });

    group('toString', () {
      test('includes code and message', () {
        const error = AppError(
          code: ErrorCode.databaseGeneric,
          message: 'Storage error',
        );

        final str = error.toString();
        expect(str, contains('databaseGeneric'));
        expect(str, contains('Storage error'));
      });

      test('includes technical details if present', () {
        const error = AppError(
          code: ErrorCode.networkTimeout,
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
          code: ErrorCode.databaseGeneric,
          message: 'Original',
        );

        final copy = original.copyWith(message: 'Updated');

        expect(copy.code, original.code);
        expect(copy.message, 'Updated');
      });

      test('copies with updated userMessage', () {
        const original = AppError(
          code: ErrorCode.databaseGeneric,
          message: 'Error',
          userMessage: 'Original user message',
        );

        final copy = original.copyWith(userMessage: 'Updated user message');

        expect(copy.code, original.code);
        expect(copy.message, original.message);
        expect(copy.userMessage, 'Updated user message');
      });

      test('preserves original values if not specified', () {
        const original = AppError(
          code: ErrorCode.networkTimeout,
          message: 'Error',
          technicalDetails: 'Details',
          userMessage: 'User message',
          actionLabel: 'Action',
        );

        final copy = original.copyWith();

        expect(copy.code, original.code);
        expect(copy.message, original.message);
        expect(copy.technicalDetails, original.technicalDetails);
        expect(copy.userMessage, original.userMessage);
        expect(copy.actionLabel, original.actionLabel);
      });
    });
  });
}
