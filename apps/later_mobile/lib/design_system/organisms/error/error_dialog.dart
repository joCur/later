import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:later_mobile/design_system/tokens/tokens.dart';
import '../../../core/error/app_error.dart';
import 'package:later_mobile/design_system/atoms/buttons/primary_button.dart';
import 'package:later_mobile/design_system/atoms/buttons/ghost_button.dart';

/// A dialog widget for displaying errors to the user.
///
/// This dialog follows Material 3 design guidelines and displays
/// user-friendly error messages with appropriate actions.
///
/// Example usage:
/// ```dart
/// showDialog(
///   context: context,
///   builder: (_) => ErrorDialog(
///     error: AppError.storage(message: 'Failed to save'),
///     onRetry: () => saveData(),
///   ),
/// );
/// ```
class ErrorDialog extends StatelessWidget {
  /// Creates an ErrorDialog.
  ///
  /// Parameters:
  ///   - [error]: The AppError to display
  ///   - [title]: Optional custom title (defaults to "Something Went Wrong")
  ///   - [onRetry]: Optional callback when retry button is tapped
  const ErrorDialog({super.key, required this.error, this.title, this.onRetry});

  /// The error to display.
  final AppError error;

  /// Optional custom title for the dialog.
  final String? title;

  /// Optional callback for retry action.
  final VoidCallback? onRetry;

  @override
  Widget build(BuildContext context) {
    return Dialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 360),
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              // Scrollable content
              Flexible(
                child: SingleChildScrollView(
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      // Error icon
                      Icon(
                        Icons.error_outline,
                        size: 48,
                        color: Theme.of(context).colorScheme.error,
                      ),
                      const SizedBox(height: 16),

                      // Title
                      Text(
                        title ?? 'Something Went Wrong',
                        style: AppTypography.h3.copyWith(
                          color: Theme.of(context).colorScheme.onSurface,
                        ),
                        textAlign: TextAlign.center,
                      ),
                      const SizedBox(height: 12),

                      // User message
                      Text(
                        error.getUserMessage(),
                        style: AppTypography.bodyLarge.copyWith(
                          color: Theme.of(
                            context,
                          ).colorScheme.onSurface.withValues(alpha: 0.8),
                        ),
                        textAlign: TextAlign.center,
                      ),

                      // Technical details in debug mode
                      if (kDebugMode && error.technicalDetails != null) ...[
                        const SizedBox(height: 16),
                        Container(
                          padding: const EdgeInsets.all(12),
                          decoration: BoxDecoration(
                            color: Theme.of(
                              context,
                            ).colorScheme.surfaceContainerHighest,
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                'Debug Info:',
                                style: AppTypography.labelSmall.copyWith(
                                  color:
                                      Theme.of(context).colorScheme.onSurfaceVariant,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              const SizedBox(height: 4),
                              Text(
                                error.technicalDetails!,
                                style: AppTypography.bodySmall.copyWith(
                                  color:
                                      Theme.of(context).colorScheme.onSurfaceVariant,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ],
                  ),
                ),
              ),

              const SizedBox(height: 24),

              // Action buttons (fixed at bottom)
              Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  // Show Ghost button only if error is retryable
                  if (error.isRetryable)
                    GhostButton(
                      text: 'Dismiss',
                      onPressed: () {
                        Navigator.of(context).pop();
                      },
                    ),
                  if (error.isRetryable) const SizedBox(width: 12),

                  // Action button
                  PrimaryButton(
                    text: error.getActionLabel(),
                    onPressed: () {
                      Navigator.of(context).pop();
                      if (error.isRetryable) {
                        onRetry?.call();
                      }
                    },
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
