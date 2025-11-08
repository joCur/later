/// Comprehensive error code registry for the Later app.
///
/// This enum provides a centralized, type-safe way to categorize all errors
/// in the application. Each error code can be mapped to localized user messages
/// and has associated metadata (retryability, severity).
///
/// Categories:
/// - Database errors: Issues with PostgreSQL/Supabase operations
/// - Auth errors: Authentication and authorization failures
/// - Network errors: Connection and communication issues
/// - Validation errors: Input validation failures
/// - Business logic errors: Domain-specific errors
enum ErrorCode {
  // Database errors
  /// Unique constraint violation (e.g., duplicate key)
  databaseUniqueConstraint,

  /// Foreign key constraint violation
  databaseForeignKeyViolation,

  /// NOT NULL constraint violation
  databaseNotNullViolation,

  /// Permission denied on database operation
  databasePermissionDenied,

  /// Database query timeout
  databaseTimeout,

  /// Generic database error
  databaseGeneric,

  // Authentication errors
  /// Invalid email or password
  authInvalidCredentials,

  /// User already exists (signup)
  authUserAlreadyExists,

  /// Password does not meet requirements
  authWeakPassword,

  /// Email format is invalid
  authInvalidEmail,

  /// Email not confirmed
  authEmailNotConfirmed,

  /// Session has expired
  authSessionExpired,

  /// Network error during auth operation
  authNetworkError,

  /// Rate limit exceeded for auth operations
  authRateLimitExceeded,

  /// Generic authentication error
  authGeneric,

  // Network errors
  /// Request timeout
  networkTimeout,

  /// No internet connection
  networkNoConnection,

  /// Server error (5xx)
  networkServerError,

  /// Bad request (4xx)
  networkBadRequest,

  /// Resource not found (404)
  networkNotFound,

  /// Generic network error
  networkGeneric,

  // Validation errors
  /// Required field is missing
  validationRequired,

  /// Invalid format
  validationInvalidFormat,

  /// Value out of acceptable range
  validationOutOfRange,

  /// Duplicate value
  validationDuplicate,

  // Business logic errors
  /// Space not found
  spaceNotFound,

  /// Note not found
  noteNotFound,

  /// Insufficient permissions for operation
  insufficientPermissions,

  /// Operation not allowed in current state
  operationNotAllowed,

  // Generic fallback
  /// Unknown or uncategorized error
  unknownError,
}

/// Severity levels for errors.
enum ErrorSeverity {
  /// Low severity - minor validation issues
  low,

  /// Medium severity - network issues, temporary problems
  medium,

  /// High severity - database errors, auth failures
  high,

  /// Critical severity - data corruption, system failures
  critical,
}

/// Extension providing metadata for ErrorCode values.
extension ErrorCodeMetadata on ErrorCode {
  /// Returns the localization key for this error code.
  ///
  /// The key follows the format 'error.{errorCodeName}' which maps to
  /// entries in the ARB localization files.
  ///
  /// Example: ErrorCode.databaseTimeout → 'error.databaseTimeout'
  String get localizationKey => 'error.$name';

  /// Returns true if this error type should allow retry operations.
  ///
  /// Typically, network errors and timeouts are retryable, while
  /// validation errors and permission denials are not.
  bool get isRetryable {
    switch (this) {
      // Network errors are typically retryable
      case ErrorCode.networkTimeout:
      case ErrorCode.networkNoConnection:
      case ErrorCode.networkServerError:
      case ErrorCode.networkGeneric:
        return true;

      // Database timeouts are retryable
      case ErrorCode.databaseTimeout:
        return true;

      // Auth network errors are retryable
      case ErrorCode.authNetworkError:
        return true;

      // All other errors are not retryable by default
      default:
        return false;
    }
  }

  /// Returns the severity level for this error code.
  ///
  /// Severity helps determine how errors should be logged, displayed,
  /// and potentially escalated to error monitoring services.
  ErrorSeverity get severity {
    switch (this) {
      // Critical errors - data integrity issues
      case ErrorCode.databaseForeignKeyViolation:
      case ErrorCode.databaseNotNullViolation:
        return ErrorSeverity.critical;

      // High severity - database and auth errors
      case ErrorCode.databaseUniqueConstraint:
      case ErrorCode.databasePermissionDenied:
      case ErrorCode.databaseTimeout:
      case ErrorCode.databaseGeneric:
      case ErrorCode.authInvalidCredentials:
      case ErrorCode.authUserAlreadyExists:
      case ErrorCode.authWeakPassword:
      case ErrorCode.authInvalidEmail:
      case ErrorCode.authEmailNotConfirmed:
      case ErrorCode.authSessionExpired:
      case ErrorCode.authRateLimitExceeded:
      case ErrorCode.authGeneric:
      case ErrorCode.insufficientPermissions:
        return ErrorSeverity.high;

      // Medium severity - network errors
      case ErrorCode.networkTimeout:
      case ErrorCode.networkNoConnection:
      case ErrorCode.networkServerError:
      case ErrorCode.networkBadRequest:
      case ErrorCode.networkNotFound:
      case ErrorCode.networkGeneric:
      case ErrorCode.authNetworkError:
      case ErrorCode.spaceNotFound:
      case ErrorCode.noteNotFound:
      case ErrorCode.operationNotAllowed:
        return ErrorSeverity.medium;

      // Low severity - validation errors
      case ErrorCode.validationRequired:
      case ErrorCode.validationInvalidFormat:
      case ErrorCode.validationOutOfRange:
      case ErrorCode.validationDuplicate:
        return ErrorSeverity.low;

      // Unknown errors default to high severity
      case ErrorCode.unknownError:
        return ErrorSeverity.high;
    }
  }
}
