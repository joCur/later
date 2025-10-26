import 'package:flutter/material.dart';
import 'package:later_mobile/design_system/tokens/tokens.dart';
import 'package:later_mobile/core/responsive/breakpoints.dart';

/// Reusable empty state component
///
/// Displays a centered message with an optional icon and call-to-action button.
/// Used throughout the app to indicate empty lists, no search results, etc.
///
/// Features:
/// - Large icon at the top
/// - Title and message text
/// - Optional CTA button
/// - Center-aligned, vertically centered layout
/// - Responsive text sizes based on screen size
///
/// Example usage:
/// ```dart
/// EmptyState(
///   icon: Icons.inbox_outlined,
///   title: 'No items yet',
///   message: 'Create your first item to get started',
///   actionLabel: 'Create Item',
///   onActionPressed: () => _showCreateDialog(),
/// )
/// ```
class EmptyState extends StatelessWidget {
  /// Creates an empty state widget.
  ///
  /// The [title] and [message] parameters are required.
  /// The [icon], [actionLabel], and [onActionPressed] parameters are optional.
  const EmptyState({
    super.key,
    this.icon,
    required this.title,
    required this.message,
    this.actionLabel,
    this.onActionPressed,
  });

  /// Optional icon to display above the title
  final IconData? icon;

  /// Title text for the empty state
  final String title;

  /// Descriptive message explaining the empty state
  final String message;

  /// Optional label for the call-to-action button
  final String? actionLabel;

  /// Optional callback when the CTA button is pressed
  final VoidCallback? onActionPressed;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final isMobile = context.isMobile;

    // Responsive icon size
    final iconSize = isMobile ? 80.0 : 100.0;

    // Responsive padding
    final horizontalPadding = isMobile ? AppSpacing.md : AppSpacing.lg;

    return Center(
      child: Padding(
        padding: EdgeInsets.symmetric(
          horizontal: horizontalPadding,
          vertical: AppSpacing.lg,
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          mainAxisSize: MainAxisSize.min,
          children: [
            // Icon
            if (icon != null) ...[
              Icon(
                icon,
                size: iconSize,
                color: isDark
                    ? AppColors.textDisabledDark
                    : AppColors.textDisabledLight,
              ),
              const SizedBox(height: AppSpacing.md),
            ],

            // Title
            Text(
              title,
              style: isMobile
                  ? AppTypography.h3.copyWith(
                      color: isDark
                          ? AppColors.textPrimaryDark
                          : AppColors.textPrimaryLight,
                    )
                  : AppTypography.h2.copyWith(
                      color: isDark
                          ? AppColors.textPrimaryDark
                          : AppColors.textPrimaryLight,
                    ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: AppSpacing.xs),

            // Message
            Text(
              message,
              style: AppTypography.bodyLarge.copyWith(
                color: isDark
                    ? AppColors.textSecondaryDark
                    : AppColors.textSecondaryLight,
              ),
              textAlign: TextAlign.center,
              maxLines: 3,
              overflow: TextOverflow.ellipsis,
            ),

            // Optional CTA button
            if (actionLabel != null && onActionPressed != null) ...[
              const SizedBox(height: AppSpacing.lg),
              ElevatedButton(
                onPressed: onActionPressed,
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.primaryAmber,
                  foregroundColor: AppColors.neutralBlack,
                  padding: const EdgeInsets.symmetric(
                    horizontal: AppSpacing.lg,
                    vertical: AppSpacing.sm,
                  ),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(AppSpacing.radiusMD),
                  ),
                  minimumSize: const Size(
                    AppSpacing.minTouchTarget,
                    AppSpacing.minTouchTarget,
                  ),
                ),
                child: Text(
                  actionLabel!,
                  style: AppTypography.button,
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}
