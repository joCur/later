import 'package:flutter/material.dart';
import 'package:later_mobile/design_system/tokens/tokens.dart';
import 'package:later_mobile/core/responsive/breakpoints.dart';
import 'package:later_mobile/design_system/atoms/buttons/ghost_button.dart';
import 'package:later_mobile/design_system/atoms/buttons/primary_button.dart';

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
///   secondaryActionLabel: 'Learn More',
///   onSecondaryPressed: () => _showLearnMore(),
/// )
/// ```
class EmptyState extends StatelessWidget {
  /// Creates an empty state widget.
  ///
  /// The [title] and [message] parameters are required.
  /// The [icon], [actionLabel], [onActionPressed], [secondaryActionLabel],
  /// and [onSecondaryPressed] parameters are optional.
  const EmptyState({
    super.key,
    this.icon,
    required this.title,
    required this.message,
    this.actionLabel,
    this.onActionPressed,
    this.secondaryActionLabel,
    this.onSecondaryPressed,
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

  /// Optional label for the secondary action button
  final String? secondaryActionLabel;

  /// Optional callback when the secondary action button is pressed
  final VoidCallback? onSecondaryPressed;

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
                    ? AppColors.neutral600
                    : AppColors.neutral400,
              ),
              const SizedBox(height: AppSpacing.md),
            ],

            // Title
            Text(
              title,
              style: isMobile
                  ? AppTypography.h3.copyWith(
                      color: isDark
                          ? AppColors.neutral400
                          : AppColors.neutral600,
                    )
                  : AppTypography.h2.copyWith(
                      color: isDark
                          ? AppColors.neutral400
                          : AppColors.neutral600,
                    ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: AppSpacing.xs),

            // Message
            Text(
              message,
              style: AppTypography.bodyLarge.copyWith(
                color: isDark
                    ? AppColors.neutral500
                    : AppColors.neutral500,
              ),
              textAlign: TextAlign.center,
              maxLines: 3,
              overflow: TextOverflow.ellipsis,
            ),

            // Optional CTA button
            if (actionLabel != null && onActionPressed != null) ...[
              const SizedBox(height: AppSpacing.lg),
              PrimaryButton(
                text: actionLabel!,
                onPressed: onActionPressed,
                size: ButtonSize.large,
              ),
            ],

            // Optional secondary action button
            if (secondaryActionLabel != null && onSecondaryPressed != null) ...[
              const SizedBox(height: AppSpacing.sm),
              GhostButton(
                text: secondaryActionLabel!,
                onPressed: onSecondaryPressed,
                size: ButtonSize.large,
              ),
            ],
          ],
        ),
      ),
    );
  }
}
