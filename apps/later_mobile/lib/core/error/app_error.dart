import '../../l10n/app_localizations.dart';
import 'error_codes.dart';

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
  });

  /// The error code identifying the specific error type.
  final ErrorCode code;

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
    String? message,
    String? technicalDetails,
    Map<String, dynamic>? context,
    String? userMessage,
    String? actionLabel,
  }) {
    return AppError(
      code: code ?? this.code,
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
