import 'package:flutter/material.dart';
import 'package:later_mobile/design_system/tokens/colors.dart';
import 'package:later_mobile/design_system/tokens/spacing.dart';
import 'package:later_mobile/design_system/tokens/typography.dart';

/// Visual feedback for password quality during account creation
///
/// Provides real-time strength analysis based on:
/// - Length (40% weight): 8+ chars = 20%, 12+ chars = additional 20%
/// - Character diversity (60% weight): lowercase, uppercase, numbers, symbols
///
/// Features:
/// - Color-coded progress bar (red/amber/green)
/// - Semantic labels (Weak/Medium/Strong)
/// - Helper text for password requirements
/// - Accessibility-friendly (color is not the only indicator)
///
/// Usage:
/// ```dart
/// PasswordStrengthIndicator(
///   password: passwordController.text,
///   padding: EdgeInsets.symmetric(vertical: AppSpacing.xs),
/// )
/// ```
class PasswordStrengthIndicator extends StatelessWidget {
  const PasswordStrengthIndicator({
    super.key,
    required this.password,
    this.padding,
    this.showHelperText = true,
  });

  /// The password to analyze
  final String password;

  /// Optional padding around the indicator
  final EdgeInsets? padding;

  /// Whether to show helper text ("Use 8+ characters")
  final bool showHelperText;

  /// Calculate password strength (0.0 to 1.0)
  double _calculateStrength(String password) {
    if (password.isEmpty) return 0.0;

    double strength = 0.0;

    // Length component (40% of total)
    if (password.length >= 8) strength += 0.2;
    if (password.length >= 12) strength += 0.2;

    // Character diversity (60% of total)
    if (RegExp(r'[a-z]').hasMatch(password)) strength += 0.15; // Lowercase
    if (RegExp(r'[A-Z]').hasMatch(password)) strength += 0.15; // Uppercase
    if (RegExp(r'[0-9]').hasMatch(password)) strength += 0.15; // Numbers
    if (RegExp(r'[!@#$%^&*(),.?":{}|<>]').hasMatch(password)) {
      strength += 0.15; // Symbols
    }

    return strength.clamp(0.0, 1.0);
  }

  /// Get semantic label for strength value
  String _getStrengthLabel(double strength) {
    if (strength < 0.33) return 'Weak';
    if (strength < 0.66) return 'Medium';
    return 'Strong';
  }

  /// Get color for strength value
  Color _getStrengthColor(double strength) {
    if (strength < 0.33) return AppColors.error;
    if (strength < 0.66) return AppColors.warning;
    return AppColors.success;
  }

  @override
  Widget build(BuildContext context) {
    final strength = _calculateStrength(password);
    final strengthLabel = _getStrengthLabel(strength);
    final strengthColor = _getStrengthColor(strength);
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return Padding(
      padding: padding ?? EdgeInsets.zero,
      child: Semantics(
        label: 'Password strength',
        value: strengthLabel,
        liveRegion: true,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: [
            // Progress bar
            ClipRRect(
              borderRadius: BorderRadius.circular(2),
              child: LinearProgressIndicator(
                value: strength,
                backgroundColor: isDark
                    ? AppColors.glassBorderDark.withValues(alpha: 0.2)
                    : AppColors.glassBorderLight.withValues(alpha: 0.2),
                valueColor: AlwaysStoppedAnimation<Color>(strengthColor),
                minHeight: 4,
              ),
            ),
            const SizedBox(height: AppSpacing.xs),

            // Labels row
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                // Strength label
                Text(
                  strengthLabel,
                  style: AppTypography.caption.copyWith(
                    color: strengthColor,
                    fontWeight: FontWeight.w600,
                  ),
                ),

                // Helper text
                if (showHelperText)
                  Text(
                    'Use 8+ characters',
                    style: AppTypography.caption.copyWith(
                      color: AppColors.textSecondary(context),
                    ),
                  ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
