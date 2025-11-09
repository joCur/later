import 'package:flutter_test/flutter_test.dart';
import 'package:later_mobile/core/error/error_codes.dart';

void main() {
  group('ErrorCode localizationKey', () {
    test('returns correct format for database errors', () {
      expect(
        ErrorCode.databaseTimeout.localizationKey,
        equals('errorDatabaseTimeout'),
      );
      expect(
        ErrorCode.databaseUniqueConstraint.localizationKey,
        equals('errorDatabaseUniqueConstraint'),
      );
      expect(
        ErrorCode.databaseGeneric.localizationKey,
        equals('errorDatabaseGeneric'),
      );
    });

    test('returns correct format for auth errors', () {
      expect(
        ErrorCode.authInvalidCredentials.localizationKey,
        equals('errorAuthInvalidCredentials'),
      );
      expect(
        ErrorCode.authSessionExpired.localizationKey,
        equals('errorAuthSessionExpired'),
      );
      expect(
        ErrorCode.authWeakPassword.localizationKey,
        equals('errorAuthWeakPassword'),
      );
    });

    test('returns correct format for network errors', () {
      expect(
        ErrorCode.networkTimeout.localizationKey,
        equals('errorNetworkTimeout'),
      );
      expect(
        ErrorCode.networkNoConnection.localizationKey,
        equals('errorNetworkNoConnection'),
      );
      expect(
        ErrorCode.networkServerError.localizationKey,
        equals('errorNetworkServerError'),
      );
    });

    test('returns correct format for validation errors', () {
      expect(
        ErrorCode.validationRequired.localizationKey,
        equals('errorValidationRequired'),
      );
      expect(
        ErrorCode.validationInvalidFormat.localizationKey,
        equals('errorValidationInvalidFormat'),
      );
      expect(
        ErrorCode.validationOutOfRange.localizationKey,
        equals('errorValidationOutOfRange'),
      );
    });

    test('returns correct format for business logic errors', () {
      expect(
        ErrorCode.spaceNotFound.localizationKey,
        equals('errorSpaceNotFound'),
      );
      expect(
        ErrorCode.noteNotFound.localizationKey,
        equals('errorNoteNotFound'),
      );
      expect(
        ErrorCode.insufficientPermissions.localizationKey,
        equals('errorInsufficientPermissions'),
      );
    });

    test('returns correct format for unknown error', () {
      expect(
        ErrorCode.unknownError.localizationKey,
        equals('errorUnknownError'),
      );
    });

    test('all error codes have unique localization keys', () {
      final keys = ErrorCode.values.map((e) => e.localizationKey).toSet();
      expect(keys.length, equals(ErrorCode.values.length));
    });
  });

  group('ErrorCode isRetryable', () {
    test('network timeout errors are retryable', () {
      expect(ErrorCode.networkTimeout.isRetryable, isTrue);
    });

    test('network no connection errors are retryable', () {
      expect(ErrorCode.networkNoConnection.isRetryable, isTrue);
    });

    test('network server errors are retryable', () {
      expect(ErrorCode.networkServerError.isRetryable, isTrue);
    });

    test('generic network errors are retryable', () {
      expect(ErrorCode.networkGeneric.isRetryable, isTrue);
    });

    test('database timeout errors are retryable', () {
      expect(ErrorCode.databaseTimeout.isRetryable, isTrue);
    });

    test('auth network errors are retryable', () {
      expect(ErrorCode.authNetworkError.isRetryable, isTrue);
    });

    test('database constraint errors are not retryable', () {
      expect(ErrorCode.databaseUniqueConstraint.isRetryable, isFalse);
      expect(ErrorCode.databaseForeignKeyViolation.isRetryable, isFalse);
      expect(ErrorCode.databaseNotNullViolation.isRetryable, isFalse);
    });

    test('database permission errors are not retryable', () {
      expect(ErrorCode.databasePermissionDenied.isRetryable, isFalse);
    });

    test('generic database errors are not retryable', () {
      expect(ErrorCode.databaseGeneric.isRetryable, isFalse);
    });

    test('auth credential errors are not retryable', () {
      expect(ErrorCode.authInvalidCredentials.isRetryable, isFalse);
      expect(ErrorCode.authUserAlreadyExists.isRetryable, isFalse);
      expect(ErrorCode.authWeakPassword.isRetryable, isFalse);
    });

    test('auth session errors are not retryable', () {
      expect(ErrorCode.authSessionExpired.isRetryable, isFalse);
    });

    test('validation errors are not retryable', () {
      expect(ErrorCode.validationRequired.isRetryable, isFalse);
      expect(ErrorCode.validationInvalidFormat.isRetryable, isFalse);
      expect(ErrorCode.validationOutOfRange.isRetryable, isFalse);
      expect(ErrorCode.validationDuplicate.isRetryable, isFalse);
    });

    test('business logic errors are not retryable', () {
      expect(ErrorCode.spaceNotFound.isRetryable, isFalse);
      expect(ErrorCode.noteNotFound.isRetryable, isFalse);
      expect(ErrorCode.insufficientPermissions.isRetryable, isFalse);
      expect(ErrorCode.operationNotAllowed.isRetryable, isFalse);
    });

    test('unknown errors are not retryable', () {
      expect(ErrorCode.unknownError.isRetryable, isFalse);
    });
  });

  group('ErrorCode severity', () {
    test('critical severity assigned to data integrity errors', () {
      expect(
        ErrorCode.databaseForeignKeyViolation.severity,
        equals(ErrorSeverity.critical),
      );
      expect(
        ErrorCode.databaseNotNullViolation.severity,
        equals(ErrorSeverity.critical),
      );
    });

    test('high severity assigned to database errors', () {
      expect(
        ErrorCode.databaseUniqueConstraint.severity,
        equals(ErrorSeverity.high),
      );
      expect(
        ErrorCode.databasePermissionDenied.severity,
        equals(ErrorSeverity.high),
      );
      expect(
        ErrorCode.databaseTimeout.severity,
        equals(ErrorSeverity.high),
      );
      expect(
        ErrorCode.databaseGeneric.severity,
        equals(ErrorSeverity.high),
      );
    });

    test('high severity assigned to auth errors', () {
      expect(
        ErrorCode.authInvalidCredentials.severity,
        equals(ErrorSeverity.high),
      );
      expect(
        ErrorCode.authUserAlreadyExists.severity,
        equals(ErrorSeverity.high),
      );
      expect(
        ErrorCode.authWeakPassword.severity,
        equals(ErrorSeverity.high),
      );
      expect(
        ErrorCode.authInvalidEmail.severity,
        equals(ErrorSeverity.high),
      );
      expect(
        ErrorCode.authEmailNotConfirmed.severity,
        equals(ErrorSeverity.high),
      );
      expect(
        ErrorCode.authSessionExpired.severity,
        equals(ErrorSeverity.high),
      );
      expect(
        ErrorCode.authRateLimitExceeded.severity,
        equals(ErrorSeverity.high),
      );
      expect(
        ErrorCode.authGeneric.severity,
        equals(ErrorSeverity.high),
      );
      expect(
        ErrorCode.insufficientPermissions.severity,
        equals(ErrorSeverity.high),
      );
    });

    test('medium severity assigned to network errors', () {
      expect(
        ErrorCode.networkTimeout.severity,
        equals(ErrorSeverity.medium),
      );
      expect(
        ErrorCode.networkNoConnection.severity,
        equals(ErrorSeverity.medium),
      );
      expect(
        ErrorCode.networkServerError.severity,
        equals(ErrorSeverity.medium),
      );
      expect(
        ErrorCode.networkBadRequest.severity,
        equals(ErrorSeverity.medium),
      );
      expect(
        ErrorCode.networkNotFound.severity,
        equals(ErrorSeverity.medium),
      );
      expect(
        ErrorCode.networkGeneric.severity,
        equals(ErrorSeverity.medium),
      );
      expect(
        ErrorCode.authNetworkError.severity,
        equals(ErrorSeverity.medium),
      );
    });

    test('medium severity assigned to business logic errors', () {
      expect(
        ErrorCode.spaceNotFound.severity,
        equals(ErrorSeverity.medium),
      );
      expect(
        ErrorCode.noteNotFound.severity,
        equals(ErrorSeverity.medium),
      );
      expect(
        ErrorCode.operationNotAllowed.severity,
        equals(ErrorSeverity.medium),
      );
    });

    test('low severity assigned to validation errors', () {
      expect(
        ErrorCode.validationRequired.severity,
        equals(ErrorSeverity.low),
      );
      expect(
        ErrorCode.validationInvalidFormat.severity,
        equals(ErrorSeverity.low),
      );
      expect(
        ErrorCode.validationOutOfRange.severity,
        equals(ErrorSeverity.low),
      );
      expect(
        ErrorCode.validationDuplicate.severity,
        equals(ErrorSeverity.low),
      );
    });

    test('high severity assigned to unknown errors', () {
      expect(
        ErrorCode.unknownError.severity,
        equals(ErrorSeverity.high),
      );
    });

    test('all error codes have severity assigned', () {
      // This test ensures no error code is missed in the severity logic
      for (final errorCode in ErrorCode.values) {
        expect(
          () => errorCode.severity,
          returnsNormally,
          reason: 'ErrorCode.$errorCode should have severity assigned',
        );
      }
    });
  });

  group('ErrorCode completeness', () {
    test('all error codes can generate localization keys', () {
      for (final errorCode in ErrorCode.values) {
        expect(
          errorCode.localizationKey,
          isNotEmpty,
          reason: 'ErrorCode.$errorCode should have localization key',
        );
        expect(
          errorCode.localizationKey,
          startsWith('error'),
          reason: 'Localization key should start with "error"',
        );
      }
    });

    test('all error codes have retryable logic defined', () {
      for (final errorCode in ErrorCode.values) {
        expect(
          () => errorCode.isRetryable,
          returnsNormally,
          reason: 'ErrorCode.$errorCode should have retryable logic',
        );
      }
    });
  });
}
