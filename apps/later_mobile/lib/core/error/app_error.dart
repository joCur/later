import '../../l10n/app_localizations.dart';
import 'error_codes.dart';

/// Error types for categorizing different kinds of errors in the app.
/// @deprecated Use ErrorCode instead for more granular error categorization.
enum ErrorType {
  /// Storage-related errors (Hive, file system, etc.)
  storage,

  /// Network-related errors (connection, timeout, etc.)
  network,

  /// Validation errors (invalid input, missing data, etc.)
  validation,

  /// Data corruption errors (invalid format, parsing errors, etc.)
  corruption,

  /// Unknown or uncategorized errors
  unknown,
}

/// Custom error class for handling application errors with user-friendly messages.
///
/// This class provides a structured way to handle errors throughout the app,
/// including technical details for debugging and user-friendly messages for display.
///
/// Example usage:
/// ```dart
/// try {
///   await saveData();
/// } catch (e) {
///   final error = AppError(
///     code: ErrorCode.databaseGeneric,
///     message: 'Failed to save data',
///     technicalDetails: e.toString(),
///   );
///   ErrorHandler.handleError(error);
/// }
/// ```
class AppError implements Exception {
  /// Creates an AppError with the specified properties.
  const AppError({
    required this.code,
    required this.message,
    this.technicalDetails,
    this.context,
    this.userMessage,
    this.actionLabel,
    @Deprecated('Use ErrorCode instead') ErrorType? type,
  }) : type = type ?? ErrorType.unknown;

  /// Factory constructor for storage-related errors.
  /// @deprecated Use AppError with ErrorCode.databaseGeneric instead.
  @Deprecated('Use AppError with ErrorCode instead')
  factory AppError.storage({
    required String message,
    String? details,
    String? userMessage,
  }) {
    return AppError(
      code: ErrorCode.databaseGeneric,
      type: ErrorType.storage,
      message: message,
      technicalDetails: details,
      userMessage:
          userMessage ??
          'Unable to save or load data. Please try again or free up storage space.',
    );
  }

  /// Factory constructor for network-related errors.
  /// @deprecated Use AppError with ErrorCode.networkGeneric instead.
  @Deprecated('Use AppError with ErrorCode instead')
  factory AppError.network({
    required String message,
    String? details,
    String? userMessage,
  }) {
    return AppError(
      code: ErrorCode.networkGeneric,
      type: ErrorType.network,
      message: message,
      technicalDetails: details,
      userMessage:
          userMessage ??
          'Connection failed. Please check your internet connection and try again.',
    );
  }

  /// Factory constructor for validation errors.
  /// @deprecated Use AppError with ErrorCode.validationRequired or other validation codes instead.
  @Deprecated('Use AppError with ErrorCode instead')
  factory AppError.validation({
    required String message,
    String? details,
    String? userMessage,
  }) {
    return AppError(
      code: ErrorCode.validationRequired,
      type: ErrorType.validation,
      message: message,
      technicalDetails: details,
      userMessage:
          userMessage ?? 'Invalid input. Please check your data and try again.',
    );
  }

  /// Factory constructor for data corruption errors.
  /// @deprecated Use AppError with ErrorCode.databaseGeneric instead.
  @Deprecated('Use AppError with ErrorCode instead')
  factory AppError.corruption({
    required String message,
    String? details,
    String? userMessage,
  }) {
    return AppError(
      code: ErrorCode.databaseGeneric,
      type: ErrorType.corruption,
      message: message,
      technicalDetails: details,
      userMessage:
          userMessage ??
          'Data is corrupted. You may need to reset and restore from backup.',
    );
  }

  /// Factory constructor for unknown errors.
  /// @deprecated Use AppError with ErrorCode.unknownError instead.
  @Deprecated('Use AppError with ErrorCode instead')
  factory AppError.unknown({
    required String message,
    String? details,
    String? userMessage,
  }) {
    return AppError(
      code: ErrorCode.unknownError,
      type: ErrorType.unknown,
      message: message,
      technicalDetails: details,
      userMessage:
          userMessage ?? 'An unexpected error occurred. Please try again.',
    );
  }

  /// Factory constructor to create an AppError from an Exception.
  ///
  /// This attempts to categorize the exception based on its message content.
  /// @deprecated Use domain-specific error mappers (SupabaseErrorMapper, ValidationErrorMapper) instead.
  @Deprecated('Use domain-specific error mappers instead')
  factory AppError.fromException(Object exception) {
    final message = exception.toString();

    // Try to categorize based on exception content
    if (message.contains('Hive') ||
        message.contains('storage') ||
        message.contains('Box') ||
        message.contains('file')) {
      return AppError.storage(message: message, details: exception.toString());
    } else if (message.contains('network') ||
        message.contains('connection') ||
        message.contains('timeout') ||
        message.contains('socket')) {
      return AppError.network(message: message, details: exception.toString());
    } else if (exception is ArgumentError || message.contains('validation')) {
      return AppError.validation(
        message: message,
        details: exception.toString(),
      );
    } else {
      return AppError.unknown(message: message, details: exception.toString());
    }
  }

  /// The error code identifying the specific error type.
  final ErrorCode code;

  /// The type of error.
  /// @deprecated Use [code] instead for more granular error categorization.
  final ErrorType type;

  /// Technical error message for logging and debugging.
  final String message;

  /// Additional technical details about the error.
  final String? technicalDetails;

  /// Context data for message interpolation (e.g., field names, limits).
  final Map<String, dynamic>? context;

  /// User-friendly error message to display in the UI.
  final String? userMessage;

  /// Custom action label for error dialogs/snackbars.
  final String? actionLabel;

  /// Returns true if this error type is retryable.
  ///
  /// Delegates to [code.isRetryable] for the new error code system.
  bool get isRetryable => code.isRetryable;

  /// Returns the severity level of this error.
  ///
  /// Delegates to [code.severity] for the new error code system.
  ErrorSeverity get severity => code.severity;

  /// Gets the user-friendly message for this error.
  ///
  /// Returns the custom [userMessage] if provided, otherwise returns
  /// a default message based on the error type.
  ///
  /// @deprecated Use getUserMessageLocalized() with AppLocalizations once Phase 2 is complete.
  String getUserMessage() {
    if (userMessage != null) {
      return userMessage!;
    }

    switch (type) {
      case ErrorType.storage:
        return 'Unable to save or load data. Please try again or free up storage space.';
      case ErrorType.network:
        return 'Connection failed. Please check your internet connection and try again.';
      case ErrorType.validation:
        return 'Invalid input. Please check your data and try again.';
      case ErrorType.corruption:
        return 'Data is corrupted. You may need to reset and restore from backup.';
      case ErrorType.unknown:
        return 'An unexpected error occurred. Please try again.';
    }
  }

  /// Gets the localized user-friendly message for this error.
  ///
  /// Uses the AppLocalizations to retrieve the localized error message based
  /// on the error code. Falls back to English messages if localizations is null.
  ///
  /// Parameters:
  ///   - localizations: AppLocalizations instance from the current context
  ///
  /// Returns a user-friendly error message with interpolated context values.
  String getUserMessageLocalized([AppLocalizations? localizations]) {
    // Use custom userMessage if provided
    if (userMessage != null) {
      return userMessage!;
    }

    // If no localizations available, use fallback
    if (localizations == null) {
      return _getFallbackMessage();
    }

    // Get localized message based on error code
    return _getLocalizedMessage(localizations);
  }

  /// Gets the localized error message using AppLocalizations.
  String _getLocalizedMessage(AppLocalizations localizations) {
    switch (code) {
      // Database errors
      case ErrorCode.databaseUniqueConstraint:
        return localizations.errorDatabaseUniqueConstraint;
      case ErrorCode.databaseForeignKeyViolation:
        return localizations.errorDatabaseForeignKeyViolation;
      case ErrorCode.databaseNotNullViolation:
        return localizations.errorDatabaseNotNullViolation;
      case ErrorCode.databasePermissionDenied:
        return localizations.errorDatabasePermissionDenied;
      case ErrorCode.databaseTimeout:
        return localizations.errorDatabaseTimeout;
      case ErrorCode.databaseGeneric:
        return localizations.errorDatabaseGeneric;

      // Auth errors
      case ErrorCode.authInvalidCredentials:
        return localizations.errorAuthInvalidCredentials;
      case ErrorCode.authUserAlreadyExists:
        return localizations.errorAuthUserAlreadyExists;
      case ErrorCode.authWeakPassword:
        final minLength = context?['minLength']?.toString() ?? '8';
        return localizations.errorAuthWeakPassword(minLength);
      case ErrorCode.authInvalidEmail:
        return localizations.errorAuthInvalidEmail;
      case ErrorCode.authEmailNotConfirmed:
        return localizations.errorAuthEmailNotConfirmed;
      case ErrorCode.authSessionExpired:
        return localizations.errorAuthSessionExpired;
      case ErrorCode.authNetworkError:
        return localizations.errorAuthNetworkError;
      case ErrorCode.authRateLimitExceeded:
        return localizations.errorAuthRateLimitExceeded;
      case ErrorCode.authGeneric:
        return localizations.errorAuthGeneric;

      // Network errors
      case ErrorCode.networkTimeout:
        return localizations.errorNetworkTimeout;
      case ErrorCode.networkNoConnection:
        return localizations.errorNetworkNoConnection;
      case ErrorCode.networkServerError:
        return localizations.errorNetworkServerError;
      case ErrorCode.networkBadRequest:
        return localizations.errorNetworkBadRequest;
      case ErrorCode.networkNotFound:
        return localizations.errorNetworkNotFound;
      case ErrorCode.networkGeneric:
        return localizations.errorNetworkGeneric;

      // Validation errors
      case ErrorCode.validationRequired:
        final fieldName = context?['fieldName']?.toString() ?? 'Field';
        return localizations.errorValidationRequired(fieldName);
      case ErrorCode.validationInvalidFormat:
        final fieldName = context?['fieldName']?.toString() ?? 'Field';
        return localizations.errorValidationInvalidFormat(fieldName);
      case ErrorCode.validationOutOfRange:
        final fieldName = context?['fieldName']?.toString() ?? 'Value';
        final min = context?['min']?.toString() ?? '0';
        final max = context?['max']?.toString() ?? '100';
        return localizations.errorValidationOutOfRange(fieldName, min, max);
      case ErrorCode.validationDuplicate:
        final fieldName = context?['fieldName']?.toString() ?? 'Value';
        return localizations.errorValidationDuplicate(fieldName);

      // Business logic errors
      case ErrorCode.spaceNotFound:
        return localizations.errorSpaceNotFound;
      case ErrorCode.noteNotFound:
        return localizations.errorNoteNotFound;
      case ErrorCode.insufficientPermissions:
        return localizations.errorInsufficientPermissions;
      case ErrorCode.operationNotAllowed:
        return localizations.errorOperationNotAllowed;

      // Unknown error
      case ErrorCode.unknownError:
        return localizations.errorUnknownError;
    }
  }

  /// Gets a fallback English error message based on the error code.
  String _getFallbackMessage() {
    // Interpolate context values if present
    String interpolate(String message) {
      if (context == null) return message;
      var result = message;
      context!.forEach((key, value) {
        result = result.replaceAll('{$key}', value.toString());
      });
      return result;
    }

    switch (code) {
      // Database errors
      case ErrorCode.databaseUniqueConstraint:
        return 'A record with this value already exists.';
      case ErrorCode.databaseForeignKeyViolation:
        return 'Cannot complete this operation due to related data.';
      case ErrorCode.databaseNotNullViolation:
        return 'Required data is missing.';
      case ErrorCode.databasePermissionDenied:
        return 'You do not have permission to perform this operation.';
      case ErrorCode.databaseTimeout:
        return 'The operation timed out. Please try again.';
      case ErrorCode.databaseGeneric:
        return 'A database error occurred. Please try again.';

      // Auth errors
      case ErrorCode.authInvalidCredentials:
        return 'Invalid email or password. Please try again.';
      case ErrorCode.authUserAlreadyExists:
        return 'An account with this email already exists.';
      case ErrorCode.authWeakPassword:
        return interpolate('Password must be at least {minLength} characters long.');
      case ErrorCode.authInvalidEmail:
        return 'Please enter a valid email address.';
      case ErrorCode.authEmailNotConfirmed:
        return 'Please confirm your email address before signing in.';
      case ErrorCode.authSessionExpired:
        return 'Your session has expired. Please sign in again.';
      case ErrorCode.authNetworkError:
        return 'Network error during authentication. Please check your connection.';
      case ErrorCode.authRateLimitExceeded:
        return 'Too many attempts. Please try again later.';
      case ErrorCode.authGeneric:
        return 'Authentication failed. Please try again.';

      // Network errors
      case ErrorCode.networkTimeout:
        return 'Connection timed out. Please check your internet connection.';
      case ErrorCode.networkNoConnection:
        return 'No internet connection. Please check your network settings.';
      case ErrorCode.networkServerError:
        return 'Server error. Please try again later.';
      case ErrorCode.networkBadRequest:
        return 'Invalid request. Please try again.';
      case ErrorCode.networkNotFound:
        return 'The requested resource was not found.';
      case ErrorCode.networkGeneric:
        return 'Network error. Please check your connection and try again.';

      // Validation errors
      case ErrorCode.validationRequired:
        return interpolate('{fieldName} is required.');
      case ErrorCode.validationInvalidFormat:
        return interpolate('{fieldName} has an invalid format.');
      case ErrorCode.validationOutOfRange:
        return interpolate('{fieldName} must be between {min} and {max}.');
      case ErrorCode.validationDuplicate:
        return interpolate('{fieldName} already exists.');

      // Business logic errors
      case ErrorCode.spaceNotFound:
        return 'Space not found.';
      case ErrorCode.noteNotFound:
        return 'Note not found.';
      case ErrorCode.insufficientPermissions:
        return 'You do not have permission to perform this action.';
      case ErrorCode.operationNotAllowed:
        return 'This operation is not allowed.';

      // Unknown error
      case ErrorCode.unknownError:
        return 'An unexpected error occurred. Please try again.';
    }
  }

  /// Gets the action label for this error.
  ///
  /// Returns the custom [actionLabel] if provided, otherwise returns
  /// "Retry" for retryable errors and "Dismiss" for non-retryable errors.
  String getActionLabel() {
    if (actionLabel != null) {
      return actionLabel!;
    }

    return isRetryable ? 'Retry' : 'Dismiss';
  }

  /// Creates a copy of this error with updated fields.
  AppError copyWith({
    ErrorCode? code,
    ErrorType? type,
    String? message,
    String? technicalDetails,
    Map<String, dynamic>? context,
    String? userMessage,
    String? actionLabel,
  }) {
    return AppError(
      code: code ?? this.code,
      type: type ?? this.type,
      message: message ?? this.message,
      technicalDetails: technicalDetails ?? this.technicalDetails,
      context: context ?? this.context,
      userMessage: userMessage ?? this.userMessage,
      actionLabel: actionLabel ?? this.actionLabel,
    );
  }

  @override
  String toString() {
    final buffer = StringBuffer('AppError(${code.name}): $message');
    if (technicalDetails != null) {
      buffer.write(' - Details: $technicalDetails');
    }
    if (context != null && context!.isNotEmpty) {
      buffer.write(' - Context: $context');
    }
    return buffer.toString();
  }
}
