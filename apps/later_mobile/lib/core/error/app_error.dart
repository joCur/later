/// Error types for categorizing different kinds of errors in the app.
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
///   final error = AppError.storage(
///     message: 'Failed to save data',
///     details: e.toString(),
///   );
///   ErrorHandler.handleError(error);
/// }
/// ```
class AppError implements Exception {
  /// Creates an AppError with the specified properties.
  const AppError({
    required this.type,
    required this.message,
    this.technicalDetails,
    this.userMessage,
    this.actionLabel,
  });

  /// Factory constructor for storage-related errors.
  factory AppError.storage({
    required String message,
    String? details,
    String? userMessage,
  }) {
    return AppError(
      type: ErrorType.storage,
      message: message,
      technicalDetails: details,
      userMessage: userMessage ??
          'Unable to save or load data. Please try again or free up storage space.',
    );
  }

  /// Factory constructor for network-related errors.
  factory AppError.network({
    required String message,
    String? details,
    String? userMessage,
  }) {
    return AppError(
      type: ErrorType.network,
      message: message,
      technicalDetails: details,
      userMessage:
          userMessage ?? 'Connection failed. Please check your internet connection and try again.',
    );
  }

  /// Factory constructor for validation errors.
  factory AppError.validation({
    required String message,
    String? details,
    String? userMessage,
  }) {
    return AppError(
      type: ErrorType.validation,
      message: message,
      technicalDetails: details,
      userMessage: userMessage ?? 'Invalid input. Please check your data and try again.',
    );
  }

  /// Factory constructor for data corruption errors.
  factory AppError.corruption({
    required String message,
    String? details,
    String? userMessage,
  }) {
    return AppError(
      type: ErrorType.corruption,
      message: message,
      technicalDetails: details,
      userMessage:
          userMessage ?? 'Data is corrupted. You may need to reset and restore from backup.',
    );
  }

  /// Factory constructor for unknown errors.
  factory AppError.unknown({
    required String message,
    String? details,
    String? userMessage,
  }) {
    return AppError(
      type: ErrorType.unknown,
      message: message,
      technicalDetails: details,
      userMessage: userMessage ?? 'An unexpected error occurred. Please try again.',
    );
  }

  /// Factory constructor to create an AppError from an Exception.
  ///
  /// This attempts to categorize the exception based on its message content.
  factory AppError.fromException(Object exception) {
    final message = exception.toString();

    // Try to categorize based on exception content
    if (message.contains('Hive') ||
        message.contains('storage') ||
        message.contains('Box') ||
        message.contains('file')) {
      return AppError.storage(
        message: message,
        details: exception.toString(),
      );
    } else if (message.contains('network') ||
        message.contains('connection') ||
        message.contains('timeout') ||
        message.contains('socket')) {
      return AppError.network(
        message: message,
        details: exception.toString(),
      );
    } else if (exception is ArgumentError || message.contains('validation')) {
      return AppError.validation(
        message: message,
        details: exception.toString(),
      );
    } else {
      return AppError.unknown(
        message: message,
        details: exception.toString(),
      );
    }
  }

  /// The type of error.
  final ErrorType type;

  /// Technical error message for logging and debugging.
  final String message;

  /// Additional technical details about the error.
  final String? technicalDetails;

  /// User-friendly error message to display in the UI.
  final String? userMessage;

  /// Custom action label for error dialogs/snackbars.
  final String? actionLabel;

  /// Returns true if this error type is retryable.
  bool get isRetryable {
    switch (type) {
      case ErrorType.storage:
      case ErrorType.network:
        return true;
      case ErrorType.validation:
      case ErrorType.corruption:
      case ErrorType.unknown:
        return false;
    }
  }

  /// Gets the user-friendly message for this error.
  ///
  /// Returns the custom [userMessage] if provided, otherwise returns
  /// a default message based on the error type.
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
    ErrorType? type,
    String? message,
    String? technicalDetails,
    String? userMessage,
    String? actionLabel,
  }) {
    return AppError(
      type: type ?? this.type,
      message: message ?? this.message,
      technicalDetails: technicalDetails ?? this.technicalDetails,
      userMessage: userMessage ?? this.userMessage,
      actionLabel: actionLabel ?? this.actionLabel,
    );
  }

  @override
  String toString() {
    final buffer = StringBuffer('AppError(${type.name}): $message');
    if (technicalDetails != null) {
      buffer.write(' - Details: $technicalDetails');
    }
    return buffer.toString();
  }
}
