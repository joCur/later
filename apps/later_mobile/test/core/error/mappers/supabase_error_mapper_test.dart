import 'package:flutter_test/flutter_test.dart';
import 'package:later_mobile/core/error/error.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

void main() {
  group('SupabaseErrorMapper', () {
    group('fromPostgrestException', () {
      test('maps unique constraint violation (23505) to databaseUniqueConstraint', () {
        const exception = PostgrestException(
          message: 'duplicate key value violates unique constraint',
          code: '23505',
        );

        final error = SupabaseErrorMapper.fromPostgrestException(exception);

        expect(error.code, ErrorCode.databaseUniqueConstraint);
        expect(error.message, contains('Database operation failed'));
        expect(error.technicalDetails, contains('23505'));
      });

      test('maps foreign key violation (23503) to databaseForeignKeyViolation', () {
        const exception = PostgrestException(
          message: 'violates foreign key constraint',
          code: '23503',
        );

        final error = SupabaseErrorMapper.fromPostgrestException(exception);

        expect(error.code, ErrorCode.databaseForeignKeyViolation);
        expect(error.message, contains('Database operation failed'));
        expect(error.technicalDetails, contains('23503'));
      });

      test('maps NOT NULL violation (23502) to databaseNotNullViolation', () {
        const exception = PostgrestException(
          message: 'null value in column violates not-null constraint',
          code: '23502',
        );

        final error = SupabaseErrorMapper.fromPostgrestException(exception);

        expect(error.code, ErrorCode.databaseNotNullViolation);
        expect(error.message, contains('Database operation failed'));
        expect(error.technicalDetails, contains('23502'));
      });

      test('maps permission denied (42501) to databasePermissionDenied', () {
        const exception = PostgrestException(
          message: 'permission denied for table',
          code: '42501',
        );

        final error = SupabaseErrorMapper.fromPostgrestException(exception);

        expect(error.code, ErrorCode.databasePermissionDenied);
        expect(error.message, contains('Database operation failed'));
        expect(error.technicalDetails, contains('42501'));
      });

      test('maps query timeout (57014) to databaseTimeout', () {
        const exception = PostgrestException(
          message: 'canceling statement due to statement timeout',
          code: '57014',
        );

        final error = SupabaseErrorMapper.fromPostgrestException(exception);

        expect(error.code, ErrorCode.databaseTimeout);
        expect(error.message, contains('Database operation failed'));
        expect(error.technicalDetails, contains('57014'));
        expect(error.isRetryable, isTrue);
      });

      test('maps unknown error code to databaseGeneric', () {
        const exception = PostgrestException(
          message: 'some unknown error',
          code: '99999',
        );

        final error = SupabaseErrorMapper.fromPostgrestException(exception);

        expect(error.code, ErrorCode.databaseGeneric);
        expect(error.message, contains('Database operation failed'));
        expect(error.technicalDetails, contains('99999'));
      });

      test('handles null error code by mapping to databaseGeneric', () {
        const exception = PostgrestException(
          message: 'error without code',
        );

        final error = SupabaseErrorMapper.fromPostgrestException(exception);

        expect(error.code, ErrorCode.databaseGeneric);
        expect(error.message, contains('Database operation failed'));
      });
    });

    group('fromAuthException', () {
      test('maps user_not_found code to authInvalidCredentials', () {
        const exception = AuthException(
          'User not found',
          statusCode: '404',
          code: 'user_not_found',
        );

        final error = SupabaseErrorMapper.fromAuthException(exception);

        expect(error.code, ErrorCode.authInvalidCredentials);
        expect(error.message, contains('Authentication failed'));
        expect(error.technicalDetails, contains('user_not_found'));
      });

      test('maps bad_jwt code to authInvalidCredentials', () {
        const exception = AuthException(
          'Invalid JWT token',
          statusCode: '401',
          code: 'bad_jwt',
        );

        final error = SupabaseErrorMapper.fromAuthException(exception);

        expect(error.code, ErrorCode.authInvalidCredentials);
      });

      test('maps no_authorization code to authInvalidCredentials', () {
        const exception = AuthException(
          'No authorization header',
          statusCode: '401',
          code: 'no_authorization',
        );

        final error = SupabaseErrorMapper.fromAuthException(exception);

        expect(error.code, ErrorCode.authInvalidCredentials);
      });

      test('handles null code with network message fallback', () {
        const exception = AuthException(
          'Network timeout occurred',
          statusCode: '0',
        );

        final error = SupabaseErrorMapper.fromAuthException(exception);

        expect(error.code, ErrorCode.authNetworkError);
      });

      test('maps user_already_exists code to authUserAlreadyExists', () {
        const exception = AuthException(
          'User already exists',
          statusCode: '400',
          code: 'user_already_exists',
        );

        final error = SupabaseErrorMapper.fromAuthException(exception);

        expect(error.code, ErrorCode.authUserAlreadyExists);
      });

      test('maps email_exists code to authUserAlreadyExists', () {
        const exception = AuthException(
          'Email already registered',
          statusCode: '400',
          code: 'email_exists',
        );

        final error = SupabaseErrorMapper.fromAuthException(exception);

        expect(error.code, ErrorCode.authUserAlreadyExists);
      });

      test('maps weak_password code to authWeakPassword with context', () {
        const exception = AuthException(
          'Password must be at least 8 characters',
          statusCode: '400',
          code: 'weak_password',
        );

        final error = SupabaseErrorMapper.fromAuthException(exception);

        expect(error.code, ErrorCode.authWeakPassword);
        expect(error.context, isNotNull);
        expect(error.context!['minLength'], '8');
      });

      test('maps weak_password code with default minLength', () {
        const exception = AuthException(
          'Password is too weak',
          statusCode: '400',
          code: 'weak_password',
        );

        final error = SupabaseErrorMapper.fromAuthException(exception);

        expect(error.code, ErrorCode.authWeakPassword);
        expect(error.context, isNotNull);
        expect(error.context!['minLength'], '8'); // Default
      });

      test('maps validation_failed code with email message to authInvalidEmail', () {
        const exception = AuthException(
          'Invalid email format',
          statusCode: '400',
          code: 'validation_failed',
        );

        final error = SupabaseErrorMapper.fromAuthException(exception);

        expect(error.code, ErrorCode.authInvalidEmail);
      });

      test('maps validation_failed code without email to authInvalidCredentials', () {
        const exception = AuthException(
          'Validation failed',
          statusCode: '400',
          code: 'validation_failed',
        );

        final error = SupabaseErrorMapper.fromAuthException(exception);

        expect(error.code, ErrorCode.authInvalidCredentials);
      });

      test('maps email_not_confirmed code to authEmailNotConfirmed', () {
        const exception = AuthException(
          'Email not confirmed',
          statusCode: '400',
          code: 'email_not_confirmed',
        );

        final error = SupabaseErrorMapper.fromAuthException(exception);

        expect(error.code, ErrorCode.authEmailNotConfirmed);
      });

      test('maps request_timeout code to authNetworkError', () {
        const exception = AuthException(
          'Request timeout',
          statusCode: '0',
          code: 'request_timeout',
        );

        final error = SupabaseErrorMapper.fromAuthException(exception);

        expect(error.code, ErrorCode.authNetworkError);
        expect(error.isRetryable, isTrue);
      });

      test('maps hook_timeout code to authNetworkError', () {
        const exception = AuthException(
          'Hook timeout',
          statusCode: '0',
          code: 'hook_timeout',
        );

        final error = SupabaseErrorMapper.fromAuthException(exception);

        expect(error.code, ErrorCode.authNetworkError);
        expect(error.isRetryable, isTrue);
      });

      test('maps over_request_rate_limit code to authRateLimitExceeded', () {
        const exception = AuthException(
          'Too many requests',
          statusCode: '429',
          code: 'over_request_rate_limit',
        );

        final error = SupabaseErrorMapper.fromAuthException(exception);

        expect(error.code, ErrorCode.authRateLimitExceeded);
      });

      test('maps over_email_send_rate_limit code to authRateLimitExceeded', () {
        const exception = AuthException(
          'Email rate limit exceeded',
          statusCode: '429',
          code: 'over_email_send_rate_limit',
        );

        final error = SupabaseErrorMapper.fromAuthException(exception);

        expect(error.code, ErrorCode.authRateLimitExceeded);
      });

      test('maps unknown auth code to authGeneric', () {
        const exception = AuthException(
          'Some unknown auth error',
          statusCode: '500',
          code: 'unknown_error_code',
        );

        final error = SupabaseErrorMapper.fromAuthException(exception);

        expect(error.code, ErrorCode.authGeneric);
        expect(error.message, contains('Authentication failed'));
      });

      test('extracts password minimum length from various message formats', () {
        final testCases = [
          ('Password must be at least 10 characters', '10'),
          ('Minimum 12 characters required', '12'),
          ('Min 6 chars', '6'),
        ];

        for (final testCase in testCases) {
          final exception = AuthException(
            testCase.$1,
            statusCode: '400',
            code: 'weak_password',
          );

          final error = SupabaseErrorMapper.fromAuthException(exception);

          expect(error.code, ErrorCode.authWeakPassword);
          expect(error.context!['minLength'], testCase.$2,
              reason: 'Failed to extract min length from: ${testCase.$1}');
        }
      });

      test('uses default minLength when extraction fails', () {
        const exception = AuthException(
          'Password is weak',
          statusCode: '400',
          code: 'weak_password',
        );

        final error = SupabaseErrorMapper.fromAuthException(exception);

        expect(error.code, ErrorCode.authWeakPassword);
        expect(error.context!['minLength'], '8');
      });
    });
  });
}
