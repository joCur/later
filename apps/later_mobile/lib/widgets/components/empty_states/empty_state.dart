import 'package:flutter/material.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_typography.dart';
import '../../../core/theme/app_spacing.dart';
import '../buttons/primary_button.dart';

/// Base empty state component following Temporal Flow design system
///
/// Features (Phase 4, Task 4.3 - Redesigned):
/// - Display Large typography for title (40px/48px on mobile)
/// - Body Large for descriptions (17px/26px -> 16px/24px Material)
/// - Icons: 64px (XXL) with gradient tint (ShaderMask + primaryGradient)
/// - Animated gradient background (2-3% opacity, 2s fade-in)
/// - Colors: adaptive gradients for light/dark mode
/// - Spacing: 64px (3xl) vertical spacing between sections
/// - CTA buttons: Primary button style with gradient
/// - Layout: Center-aligned, max width 480px
///
/// Example usage:
/// ```dart
/// EmptyState(
///   icon: Icons.inbox,
///   iconSize: 64.0,
///   title: 'Your space is empty',
///   description: 'Start capturing your thoughts',
///   ctaText: 'Quick Capture',
///   onCtaPressed: () => _showQuickCapture(),
/// )
/// ```
class EmptyState extends StatefulWidget {
  /// Creates an empty state widget.
  const EmptyState({
    super.key,
    required this.icon,
    required this.iconSize,
    required this.title,
    required this.description,
    this.ctaText,
    this.onCtaPressed,
    this.secondaryText,
    this.onSecondaryPressed,
  });

  /// Icon to display above the title
  final IconData icon;

  /// Size of the icon (typically 64px for major empty states)
  final double iconSize;

  /// Title text for the empty state (Display Large)
  final String title;

  /// Descriptive message explaining the empty state (Body Large)
  final String description;

  /// Optional label for the primary call-to-action button
  final String? ctaText;

  /// Optional callback when the CTA button is pressed
  final VoidCallback? onCtaPressed;

  /// Optional label for the secondary text link
  final String? secondaryText;

  /// Optional callback when the secondary link is pressed
  final VoidCallback? onSecondaryPressed;

  @override
  State<EmptyState> createState() => _EmptyStateState();
}

class _EmptyStateState extends State<EmptyState> {
  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    // Get adaptive gradients based on theme
    final iconGradient = isDark
        ? AppColors.primaryGradientDark
        : AppColors.primaryGradient;
    final backgroundGradient = isDark
        ? AppColors.primaryGradientDark
        : AppColors.primaryGradient;

    // Text colors following design system
    final titleColor = isDark ? AppColors.textPrimaryDark : AppColors.textPrimaryLight;
    final descriptionColor = isDark ? AppColors.textSecondaryDark : AppColors.textSecondaryLight;

    return Stack(
      children: [
        // Animated gradient background (subtle, 2-3% opacity)
        Positioned.fill(
          child: AnimatedOpacity(
            opacity: 0.03, // 3% opacity for subtle effect
            duration: const Duration(seconds: 2),
            curve: Curves.easeOut,
            child: Container(
              decoration: BoxDecoration(
                gradient: backgroundGradient,
              ),
            ),
          ),
        ),

        // Main content
        Center(
          child: SingleChildScrollView(
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 480.0),
              child: Padding(
                padding: const EdgeInsets.symmetric(
                  horizontal: AppSpacing.md,
                  vertical: AppSpacing.lg,
                ),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    // Icon with gradient tint (64px)
                    ShaderMask(
                      shaderCallback: (Rect bounds) {
                        return iconGradient.createShader(bounds);
                      },
                      blendMode: BlendMode.srcIn,
                      child: Icon(
                        widget.icon,
                        size: widget.iconSize,
                        color: Colors.white, // White for ShaderMask to apply gradient
                      ),
                    ),

                    // Spacing: 64px (3xl) between sections
                    const SizedBox(height: AppSpacing.xxxl),

                    // Title - Display Large for mobile (40px)
                    Text(
                      widget.title,
                      style: const TextStyle(
                        fontFamily: AppTypography.fontFamily,
                        fontSize: 40.0, // Display Large on mobile as per spec
                        fontWeight: AppTypography.regular,
                        height: 1.2, // 48px line height
                        letterSpacing: -0.25,
                      ).copyWith(color: titleColor),
                      textAlign: TextAlign.center,
                    ),

                    // Spacing between title and description
                    const SizedBox(height: AppSpacing.sm),

                    // Description - Body Large (17px -> using 16px Material)
                    Text(
                      widget.description,
                      style: AppTypography.bodyLarge.copyWith(
                        color: descriptionColor,
                      ),
                      textAlign: TextAlign.center,
                    ),

                    // Spacing before CTA (64px)
                    if (widget.ctaText != null && widget.onCtaPressed != null) ...[
                      const SizedBox(height: AppSpacing.xxxl),

                      // Primary CTA Button
                      PrimaryButton(
                        text: widget.ctaText!,
                        onPressed: widget.onCtaPressed,
                        size: ButtonSize.large,
                      ),
                    ],

                    // Secondary text link (optional)
                    if (widget.secondaryText != null && widget.onSecondaryPressed != null) ...[
                      const SizedBox(height: AppSpacing.sm),

                      TextButton(
                        onPressed: widget.onSecondaryPressed,
                        style: TextButton.styleFrom(
                          foregroundColor: isDark
                              ? AppColors.primaryAmberLight
                              : AppColors.primaryAmber,
                          textStyle: AppTypography.button,
                        ),
                        child: Text(widget.secondaryText!),
                      ),
                    ],
                  ],
                ),
              ),
            ),
          ),
        ),
      ],
    );
  }
}
