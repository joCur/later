import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:later_mobile/core/error/error_handler.dart';
import 'package:later_mobile/core/theme/temporal_flow_theme.dart';
import 'package:later_mobile/design_system/tokens/spacing.dart';
import 'package:later_mobile/design_system/tokens/typography.dart';

/// Custom error widget that displays when Flutter encounters a widget build error.
///
/// This replaces Flutter's default red error screen with a branded error UI
/// that matches the app's design system. It shows:
/// - A user-friendly error message in both light and dark modes
/// - Debug details (exception and stack trace) only in debug mode
/// - Theme-aware styling using TemporalFlowTheme
///
/// This widget is automatically shown when ErrorWidget.builder is configured
/// in ErrorHandler.initialize().
class CustomErrorWidget extends StatelessWidget {
  /// Creates a CustomErrorWidget with the given error details.
  const CustomErrorWidget({
    required this.details,
    super.key,
  });

  /// The Flutter error details to display
  final FlutterErrorDetails details;

  @override
  Widget build(BuildContext context) {
    // Get theme extension with fallback for when theme isn't available
    final temporalTheme = Theme.of(context).extension<TemporalFlowTheme>();
    final isDark = Theme.of(context).brightness == Brightness.dark;

    // Fallback colors if theme extension is null
    final backgroundColor = temporalTheme?.glassBackground ??
        (isDark ? Colors.grey[900]! : Colors.grey[50]!);
    final shadowColor = temporalTheme?.shadowColor ??
        (isDark ? Colors.black26 : Colors.black12);

    // Convert error to AppError for user-friendly message
    final appError = ErrorHandler.convertToAppError(details.exception);

    return Material(
      color: Theme.of(context).scaffoldBackgroundColor,
      child: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(AppSpacing.lg),
          child: Center(
            child: Container(
              constraints: const BoxConstraints(maxWidth: 500),
              padding: const EdgeInsets.all(AppSpacing.xl),
              decoration: BoxDecoration(
                color: backgroundColor,
                borderRadius: BorderRadius.circular(16),
                boxShadow: [
                  BoxShadow(
                    color: shadowColor,
                    blurRadius: 24,
                    offset: const Offset(0, 8),
                  ),
                ],
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  // Error icon
                  Icon(
                    Icons.error_outline,
                    size: 64,
                    color: Colors.red[400],
                  ),
                  const SizedBox(height: AppSpacing.lg),

                  // Error heading
                  Text(
                    'Something went wrong',
                    style: AppTypography.headlineSmall.copyWith(
                      color: Theme.of(context).colorScheme.onSurface,
                    ),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: AppSpacing.md),

                  // User-friendly message
                  Text(
                    appError.getUserMessage(),
                    style: AppTypography.bodyLarge.copyWith(
                      color: Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.8),
                    ),
                    textAlign: TextAlign.center,
                  ),

                  // Debug info section (only in debug mode)
                  if (kDebugMode) ...[
                    const SizedBox(height: AppSpacing.xl),
                    const Divider(),
                    const SizedBox(height: AppSpacing.md),

                    // Debug heading
                    Text(
                      'Debug Information',
                      style: AppTypography.titleMedium.copyWith(
                        color: Theme.of(context).colorScheme.onSurface,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: AppSpacing.sm),

                    // Exception details
                    Container(
                      padding: const EdgeInsets.all(AppSpacing.md),
                      decoration: BoxDecoration(
                        color: Theme.of(context).colorScheme.surface,
                        borderRadius: BorderRadius.circular(8),
                        border: Border.all(
                          color: Theme.of(context).colorScheme.outline.withValues(alpha: 0.2),
                        ),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Exception:',
                            style: AppTypography.labelSmall.copyWith(
                              color: Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.6),
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          const SizedBox(height: AppSpacing.xs),
                          Text(
                            details.exception.toString(),
                            style: AppTypography.bodySmall.copyWith(
                              color: Theme.of(context).colorScheme.onSurface,
                              fontFamily: 'monospace',
                            ),
                          ),
                          if (details.stack != null) ...[
                            const SizedBox(height: AppSpacing.md),
                            Text(
                              'Stack trace (first 5 lines):',
                              style: AppTypography.labelSmall.copyWith(
                                color: Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.6),
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            const SizedBox(height: AppSpacing.xs),
                            Text(
                              _getFirstStackTraceLines(details.stack!, 5),
                              style: AppTypography.bodySmall.copyWith(
                                color: Theme.of(context).colorScheme.onSurface,
                                fontFamily: 'monospace',
                                fontSize: 11,
                              ),
                              maxLines: 10,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ],
                        ],
                      ),
                    ),
                  ],
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  /// Gets the first N lines from a stack trace
  String _getFirstStackTraceLines(StackTrace stackTrace, int lineCount) {
    final lines = stackTrace.toString().split('\n');
    final limitedLines = lines.take(lineCount).toList();
    return limitedLines.join('\n');
  }
}
