import 'package:flutter/material.dart';
import '../../../core/error/app_error.dart';
import '../../../core/theme/app_typography.dart';

/// Helper class for showing error snackbars.
///
/// This provides a consistent way to display transient error messages
/// to users following Material 3 design guidelines.
///
/// Example usage:
/// ```dart
/// ErrorSnackBar.show(
///   context,
///   AppError.storage(message: 'Failed to save'),
///   onRetry: () => saveData(),
/// );
/// ```
class ErrorSnackBar {
  ErrorSnackBar._();

  /// Shows an error snackbar.
  ///
  /// Parameters:
  ///   - [context]: BuildContext for showing the snackbar
  ///   - [error]: The AppError to display
  ///   - [onRetry]: Optional callback for retry action
  static void show(
    BuildContext context,
    AppError error, {
    VoidCallback? onRetry,
  }) {
    // Clear any existing snackbars
    ScaffoldMessenger.of(context).clearSnackBars();

    final snackBar = SnackBar(
      backgroundColor: Theme.of(context).colorScheme.error,
      content: Row(
        children: [
          Icon(
            Icons.error_outline,
            color: Theme.of(context).colorScheme.onError,
            size: 20,
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              error.getUserMessage(),
              style: AppTypography.bodyMedium.copyWith(
                color: Theme.of(context).colorScheme.onError,
              ),
            ),
          ),
        ],
      ),
      action: error.isRetryable
          ? SnackBarAction(
              label: error.getActionLabel(),
              textColor: Theme.of(context).colorScheme.onError,
              onPressed: () {
                onRetry?.call();
              },
            )
          : null,
    );

    ScaffoldMessenger.of(context).showSnackBar(snackBar);
  }
}
