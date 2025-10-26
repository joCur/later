import 'package:flutter/material.dart';
import '../../../core/responsive/breakpoints.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_spacing.dart';
import '../../../core/theme/app_typography.dart';
import 'quick_capture_fab.dart';

/// A responsive Floating Action Button that adapts between mobile and desktop layouts.
///
/// On mobile (< 768px):
/// - Displays as a circular FAB (56×56px)
/// - Icon only, no label
/// - Uses QuickCaptureFab component for consistent styling
/// - Gradient background with 30% white overlay
///
/// On desktop/tablet (>= 768px):
/// - Displays as an extended FAB with icon and label
/// - Uses FloatingActionButton.extended
/// - Same gradient styling as mobile
///
/// Example usage:
/// ```dart
/// ResponsiveFab(
///   icon: Icons.add,
///   label: 'Add Todo',
///   onPressed: () => _addTodoItem(),
///   gradient: AppColors.taskGradient,
/// )
/// ```
class ResponsiveFab extends StatelessWidget {
  const ResponsiveFab({
    super.key,
    required this.icon,
    this.label,
    this.onPressed,
    this.gradient,
    this.tooltip,
    this.heroTag,
  });

  /// The icon to display in the FAB
  final IconData icon;

  /// The label to display (only shown on desktop)
  /// On mobile, this is used only for accessibility
  final String? label;

  /// Callback when the FAB is pressed
  final VoidCallback? onPressed;

  /// Optional gradient to use for the FAB background
  /// If null, uses the primary gradient
  final Gradient? gradient;

  /// Optional tooltip text
  /// If null, uses the label
  final String? tooltip;

  /// Optional hero tag for animations
  final Object? heroTag;

  @override
  Widget build(BuildContext context) {
    final isMobile = Breakpoints.isMobile(context);

    if (isMobile) {
      return _buildMobileFab(context);
    } else {
      return _buildDesktopFab(context);
    }
  }

  /// Build mobile circular FAB using QuickCaptureFab
  Widget _buildMobileFab(BuildContext context) {
    return QuickCaptureFab(
      icon: icon,
      onPressed: onPressed,
      tooltip: tooltip ?? label ?? 'Action',
      heroTag: heroTag,
      useGradient: gradient != null,
    );
  }

  /// Build desktop extended FAB
  Widget _buildDesktopFab(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    // Get the appropriate gradient
    final effectiveGradient = gradient ??
        (isDark ? AppColors.primaryGradientDark : AppColors.primaryGradient);

    // Get shadow color from gradient
    final shadowColor = effectiveGradient is LinearGradient
        ? (effectiveGradient.colors.last).withValues(alpha: 0.15)
        : AppColors.primaryEnd.withValues(alpha: 0.15);

    return FloatingActionButton.extended(
      onPressed: onPressed,
      heroTag: heroTag,
      tooltip: tooltip ?? label,
      elevation: 0,
      highlightElevation: 0,
      backgroundColor: Colors.transparent,
      // Custom extended FAB with gradient
      label: Container(
        padding: const EdgeInsets.symmetric(
          horizontal: AppSpacing.sm,
          vertical: AppSpacing.xs,
        ),
        decoration: BoxDecoration(
          gradient: effectiveGradient,
          borderRadius: BorderRadius.circular(AppSpacing.fabRadius),
          boxShadow: [
            BoxShadow(
              color: shadowColor,
              blurRadius: 16,
              offset: const Offset(0, 8),
            ),
          ],
        ),
        // Apply 30% white overlay for mobile-first design consistency
        foregroundDecoration: BoxDecoration(
          color: Colors.white.withValues(alpha: 0.3),
          borderRadius: BorderRadius.circular(AppSpacing.fabRadius),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              icon,
              color: Colors.white,
              size: 24,
            ),
            if (label != null) ...[
              const SizedBox(width: AppSpacing.xs),
              Text(
                label!,
                style: AppTypography.button.copyWith(
                  color: Colors.white,
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}
