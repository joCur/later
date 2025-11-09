import 'package:flutter/foundation.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../app_error.dart';
import '../error_codes.dart';

/// Maps Supabase exceptions to AppError with appropriate error codes.
///
/// This mapper provides a centralized way to convert Supabase-specific
/// exceptions (PostgrestException, AuthException) into structured AppError
/// objects with proper error codes and user-friendly messages.
///
/// Usage:
/// ```dart
/// try {
///   await supabase.from('spaces').insert(data);
/// } on PostgrestException catch (e) {
///   throw SupabaseErrorMapper.fromPostgrestException(e);
/// } on AuthException catch (e) {
///   throw SupabaseErrorMapper.fromAuthException(e);
/// }
/// ```
class SupabaseErrorMapper {
  /// Private constructor to prevent instantiation (static class)
  const SupabaseErrorMapper._();

  /// Maps a PostgrestException to an AppError with the appropriate error code.
  ///
  /// Maps PostgreSQL error codes to ErrorCode values:
  /// - '23505' → databaseUniqueConstraint (unique constraint violation)
  /// - '23503' → databaseForeignKeyViolation (foreign key violation)
  /// - '23502' → databaseNotNullViolation (NOT NULL violation)
  /// - '42501' → databasePermissionDenied (permission denied / RLS policy)
  /// - '57014' → databaseTimeout (query timeout)
  /// - Default → databaseGeneric (unknown database error)
  ///
  /// Parameters:
  ///   - exception: The PostgrestException to map
  ///
  /// Returns:
  ///   An AppError with the appropriate error code and technical details
  static AppError fromPostgrestException(PostgrestException exception) {
    final code = exception.code;
    final message = exception.message;

    // Log unmapped error codes for debugging
    if (code != null && !_isKnownPostgrestCode(code)) {
      debugPrint('⚠️ Unmapped Postgrest error code: $code - $message');
    }

    final errorCode = _mapPostgrestCode(code);

    return AppError(
      code: errorCode,
      message: 'Database operation failed: $message',
      technicalDetails: 'PostgrestException(code: $code, message: $message)',
    );
  }

  /// Maps a PostgreSQL error code to an ErrorCode.
  static ErrorCode _mapPostgrestCode(String? code) {
    switch (code) {
      case '23505':
        return ErrorCode.databaseUniqueConstraint;
      case '23503':
        return ErrorCode.databaseForeignKeyViolation;
      case '23502':
        return ErrorCode.databaseNotNullViolation;
      case '42501':
        return ErrorCode.databasePermissionDenied;
      case '57014':
        return ErrorCode.databaseTimeout;
      default:
        return ErrorCode.databaseGeneric;
    }
  }

  /// Checks if a Postgrest error code is known/mapped.
  static bool _isKnownPostgrestCode(String code) {
    return const ['23505', '23503', '23502', '42501', '57014'].contains(code);
  }

  /// Maps an AuthException to an AppError with the appropriate error code.
  ///
  /// Uses the `code` property from Supabase AuthException for accurate mapping:
  /// - 'user_not_found', 'validation_failed' → authInvalidCredentials
  /// - 'user_already_exists', 'email_exists' → authUserAlreadyExists
  /// - 'weak_password' → authWeakPassword
  /// - 'validation_failed' (with email pattern) → authInvalidEmail
  /// - 'email_not_confirmed' → authEmailNotConfirmed
  /// - 'over_request_rate_limit' → authRateLimitExceeded
  /// - Default → authGeneric
  ///
  /// Parameters:
  ///   - exception: The AuthException to map
  ///
  /// Returns:
  ///   An AppError with the appropriate error code and technical details
  static AppError fromAuthException(AuthException exception) {
    final code = exception.code;
    final message = exception.message;
    final statusCode = exception.statusCode;

    // Log unmapped error codes for debugging
    if (code != null && !_isKnownAuthCode(code)) {
      debugPrint('⚠️ Unmapped auth error code: $code - $message (status: $statusCode)');
    }

    final errorCode = _mapAuthCode(code, message);
    final context = _getAuthErrorContext(errorCode, exception);

    return AppError(
      code: errorCode,
      message: 'Authentication failed: $message',
      technicalDetails: 'AuthException(code: $code, message: $message, statusCode: $statusCode)',
      context: context,
    );
  }

  /// Maps a Supabase auth error code to an ErrorCode.
  static ErrorCode _mapAuthCode(String? code, String message) {
    // Handle null code (fallback for exceptions without codes)
    if (code == null) {
      // Check for network-related errors in message as fallback
      final lowerMessage = message.toLowerCase();
      if (lowerMessage.contains('network') ||
          lowerMessage.contains('timeout') ||
          lowerMessage.contains('connection')) {
        return ErrorCode.authNetworkError;
      }
      return ErrorCode.authGeneric;
    }

    switch (code) {
      // Invalid credentials - covers login failures
      case 'user_not_found':
      case 'bad_jwt':
      case 'no_authorization':
        return ErrorCode.authInvalidCredentials;

      // User/email already exists - signup conflicts
      case 'user_already_exists':
      case 'email_exists':
        return ErrorCode.authUserAlreadyExists;

      // Weak password
      case 'weak_password':
        return ErrorCode.authWeakPassword;

      // Email validation - check message for email-specific validation errors
      case 'validation_failed':
        if (message.toLowerCase().contains('email')) {
          return ErrorCode.authInvalidEmail;
        }
        // Generic validation treated as invalid credentials
        return ErrorCode.authInvalidCredentials;

      // Email not confirmed
      case 'email_not_confirmed':
        return ErrorCode.authEmailNotConfirmed;

      // Rate limiting
      case 'over_request_rate_limit':
      case 'over_email_send_rate_limit':
      case 'over_sms_send_rate_limit':
        return ErrorCode.authRateLimitExceeded;

      // Session/timeout issues
      case 'request_timeout':
      case 'hook_timeout':
        return ErrorCode.authNetworkError;

      // Default to generic auth error for unmapped codes
      default:
        return ErrorCode.authGeneric;
    }
  }

  /// Checks if a Supabase auth error code is known/mapped.
  static bool _isKnownAuthCode(String code) {
    return const [
      'user_not_found',
      'bad_jwt',
      'no_authorization',
      'user_already_exists',
      'email_exists',
      'weak_password',
      'validation_failed',
      'email_not_confirmed',
      'over_request_rate_limit',
      'over_email_send_rate_limit',
      'over_sms_send_rate_limit',
      'request_timeout',
      'hook_timeout',
    ].contains(code);
  }

  /// Gets context data for auth error messages that need interpolation.
  static Map<String, dynamic>? _getAuthErrorContext(
    ErrorCode code,
    AuthException exception,
  ) {
    switch (code) {
      case ErrorCode.authWeakPassword:
        // Try to extract minimum length from message, otherwise default to 8
        final minLength = _extractMinPasswordLength(exception.message) ?? '8';
        return {'minLength': minLength};
      default:
        return null;
    }
  }

  /// Attempts to extract minimum password length from error message.
  static String? _extractMinPasswordLength(String message) {
    // Try to find a number in common password error message formats
    final patterns = [
      RegExp(r'at least (\d+)', caseSensitive: false),
      RegExp(r'minimum (\d+)', caseSensitive: false),
      RegExp(r'min (\d+)', caseSensitive: false),
    ];

    for (final pattern in patterns) {
      final match = pattern.firstMatch(message);
      if (match != null && match.groupCount >= 1) {
        return match.group(1);
      }
    }

    return null;
  }
}
