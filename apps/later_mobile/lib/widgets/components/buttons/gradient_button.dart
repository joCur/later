import 'package:flutter/material.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_spacing.dart';

/// A button with gradient background styling, matching the app's design system.
///
/// Used primarily for primary actions in modals and forms.
/// - Applies gradient background (primary gradient by default)
/// - Adds subtle shadow for depth
/// - Supports both text-only and icon+text variants
/// - Automatically adapts to theme (light/dark)
///
/// Example usage:
/// ```dart
/// GradientButton(
///   onPressed: _handleSave,
///   label: 'Save',
/// )
///
/// GradientButton.icon(
///   onPressed: _handleAdd,
///   icon: Icons.add,
///   label: 'Add Item',
///   gradient: AppColors.taskGradient,
/// )
/// ```
class GradientButton extends StatelessWidget {
  const GradientButton({
    super.key,
    required this.onPressed,
    required this.label,
    this.gradient,
    this.fullWidth = false,
  }) : icon = null;

  const GradientButton.icon({
    super.key,
    required this.onPressed,
    required this.icon,
    required this.label,
    this.gradient,
    this.fullWidth = false,
  });

  /// Callback when button is pressed
  final VoidCallback? onPressed;

  /// Button label text
  final String label;

  /// Optional icon to display before the label
  final IconData? icon;

  /// Optional custom gradient (uses primary gradient if not specified)
  final Gradient? gradient;

  /// Whether button should take full width of parent
  final bool fullWidth;

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final buttonGradient = gradient ??
        (isDark ? AppColors.primaryGradientDark : AppColors.primaryGradient);

    // Extract first color from gradient for shadow
    final shadowColor = buttonGradient is LinearGradient
        ? buttonGradient.colors.first
        : (isDark ? AppColors.primaryStartDark : AppColors.primaryStart);

    return Container(
      decoration: BoxDecoration(
        gradient: buttonGradient,
        borderRadius: BorderRadius.circular(AppSpacing.buttonRadius),
        boxShadow: [
          BoxShadow(
            color: shadowColor.withValues(alpha: 0.3),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: icon != null
          ? ElevatedButton.icon(
              onPressed: onPressed,
              icon: Icon(icon),
              label: Text(label),
              style: _buttonStyle(fullWidth),
            )
          : ElevatedButton(
              onPressed: onPressed,
              style: _buttonStyle(fullWidth),
              child: Text(label),
            ),
    );
  }

  ButtonStyle _buttonStyle(bool fullWidth) {
    return ElevatedButton.styleFrom(
      backgroundColor: Colors.transparent,
      foregroundColor: Colors.white,
      shadowColor: Colors.transparent,
      minimumSize: fullWidth
          ? const Size(double.infinity, AppSpacing.minTouchTarget)
          : const Size(0, AppSpacing.minTouchTarget),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(AppSpacing.buttonRadius),
      ),
      padding: const EdgeInsets.symmetric(
        horizontal: AppSpacing.md,
        vertical: AppSpacing.sm,
      ),
    );
  }
}
