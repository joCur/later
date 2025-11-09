import 'dart:ui';
import 'package:flutter/material.dart';
import 'app_error.dart';
import 'error_codes.dart';
import 'error_logger.dart';
import 'package:later_mobile/design_system/organisms/error/custom_error_widget.dart';
import 'package:later_mobile/design_system/organisms/error/error_dialog.dart';
import 'package:later_mobile/design_system/organisms/error/error_snackbar.dart';

/// Global error handler for the application.
///
/// This class provides methods for initializing global error handling,
/// handling errors throughout the app, and displaying error UI.
///
/// Example usage:
/// ```dart
/// void main() {
///   ErrorHandler.initialize();
///   runApp(MyApp());
/// }
/// ```
class ErrorHandler {
  ErrorHandler._();

  static AppError? _lastError;

  /// Initializes the global error handler.
  ///
  /// This sets up handlers for:
  /// - Flutter framework errors (FlutterError.onError)
  /// - Async errors outside the Flutter framework (PlatformDispatcher.instance.onError)
  ///
  /// Call this in main() before runApp().
  static void initialize() {
    // Configure custom error widget builder
    ErrorWidget.builder = (FlutterErrorDetails details) {
      // Log the error using our error handler
      handleFlutterError(details);
      // Return our custom error widget
      return CustomErrorWidget(details: details);
    };

    // Handle Flutter framework errors
    FlutterError.onError = (FlutterErrorDetails details) {
      handleFlutterError(details);
    };

    // Handle errors outside Flutter framework (e.g., in isolates)
    PlatformDispatcher.instance.onError = (error, stack) {
      handleError(error, stackTrace: stack);
      return true; // Prevent default error handling
    };
  }

  /// Handles a generic error.
  ///
  /// This method:
  /// 1. Converts the error to an AppError if needed
  /// 2. Logs the error
  /// 3. Stores it as the last error
  ///
  /// Parameters:
  ///   - [error]: The error to handle (can be AppError, Exception, Error, or any object)
  ///   - [stackTrace]: Optional stack trace
  ///   - [context]: Optional context string for logging
  static void handleError(
    Object error, {
    StackTrace? stackTrace,
    String? context,
  }) {
    final appError = convertToAppError(error);
    _lastError = appError;

    ErrorLogger.logError(
      appError,
      stackTrace: stackTrace ?? StackTrace.current,
      context: context,
    );
  }

  /// Handles a FlutterErrorDetails object.
  ///
  /// This is specifically for errors caught by the Flutter framework.
  static void handleFlutterError(FlutterErrorDetails details) {
    final appError = convertToAppError(details.exception);
    _lastError = appError;

    final context = details.context?.toString();

    ErrorLogger.logError(appError, stackTrace: details.stack, context: context);

    // Also report to Flutter's default error handler in debug mode
    FlutterError.presentError(details);
  }

  /// Shows an error dialog to the user.
  ///
  /// Parameters:
  ///   - [context]: BuildContext for showing the dialog
  ///   - [error]: The AppError to display
  ///   - [title]: Optional custom title (defaults to "Something Went Wrong")
  ///   - [onRetry]: Optional callback for retry action
  static void showErrorDialog(
    BuildContext context,
    AppError error, {
    String? title,
    VoidCallback? onRetry,
  }) {
    showDialog<void>(
      context: context,
      builder: (context) =>
          ErrorDialog(error: error, title: title, onRetry: onRetry),
    );
  }

  /// Shows an error snackbar to the user.
  ///
  /// Parameters:
  ///   - [context]: BuildContext for showing the snackbar
  ///   - [error]: The AppError to display
  ///   - [onRetry]: Optional callback for retry action
  static void showErrorSnackBar(
    BuildContext context,
    AppError error, {
    VoidCallback? onRetry,
  }) {
    ErrorSnackBar.show(context, error, onRetry: onRetry);
  }

  /// Converts any error object to an AppError.
  ///
  /// If the error is already an AppError, returns it as-is.
  /// Otherwise, attempts to categorize and convert it.
  static AppError convertToAppError(Object error) {
    if (error is AppError) {
      return error;
    }

    if (error is ArgumentError) {
      return AppError(
        code: ErrorCode.validationRequired,
        message: error.toString(),
        technicalDetails: error.message?.toString(),
      );
    }

    if (error is Exception) {
      // Generic exception - wrap in unknownError
      return AppError(
        code: ErrorCode.unknownError,
        message: error.toString(),
        technicalDetails: error.toString(),
      );
    }

    if (error is Error) {
      return AppError(
        code: ErrorCode.unknownError,
        message: error.toString(),
        technicalDetails: error.stackTrace?.toString(),
      );
    }

    return AppError(
      code: ErrorCode.unknownError,
      message: error.toString(),
    );
  }

  /// Gets the last error that was handled.
  ///
  /// Returns null if no error has been handled yet.
  static AppError? getLastError() {
    return _lastError;
  }

  /// Clears the last error.
  static void clearLastError() {
    _lastError = null;
  }
}
