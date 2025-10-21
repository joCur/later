import 'package:flutter/material.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_typography.dart';
import '../../../core/theme/app_spacing.dart';

/// Base empty state component following mobile-first redesign
///
/// Features (Phase 4, Task 4.3 - Mobile-First):
/// - Bold typography: 20px title (bold weight), 15px body
/// - Icons: 64px (XXL) with gradient tint (ShaderMask + primaryGradient)
/// - Animated gradient background (2-3% opacity, 2s fade-in)
/// - Colors: adaptive gradients for light/dark mode
/// - Generous spacing: 24px between elements
/// - CTA button: gradient background, 48px height
/// - Layout: Center-aligned, max width 280px (mobile-first)
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
    this.titleWidget,
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
  /// If [titleWidget] is provided, this is ignored.
  final String title;

  /// Optional custom widget for the title (e.g., gradient text)
  /// If provided, this takes precedence over [title].
  final Widget? titleWidget;

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

        // Main content - Mobile-first: max width 280px, 24px spacing
        Center(
          child: SingleChildScrollView(
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 280.0), // Mobile-first
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

                    // Spacing: 24px between elements (mobile-first)
                    const SizedBox(height: 24),

                    // Title - Bold 20px for mobile-first
                    // Use custom widget if provided, otherwise default text
                    widget.titleWidget ?? Text(
                      widget.title,
                      style: TextStyle(
                        fontFamily: AppTypography.fontFamily,
                        fontSize: 20.0, // Mobile-first: 20px
                        fontWeight: FontWeight.bold, // Bold weight
                        height: 1.3, // Good line height
                        letterSpacing: -0.15,
                        color: titleColor,
                      ),
                      textAlign: TextAlign.center,
                    ),

                    // Spacing between title and description: 24px
                    const SizedBox(height: 24),

                    // Description - 15px body text
                    Text(
                      widget.description,
                      style: TextStyle(
                        fontFamily: AppTypography.fontFamily,
                        fontSize: 15.0, // Mobile-first: 15px
                        fontWeight: FontWeight.normal,
                        height: 1.5,
                        color: descriptionColor,
                      ),
                      textAlign: TextAlign.center,
                    ),

                    // Spacing before CTA: 24px
                    if (widget.ctaText != null && widget.onCtaPressed != null) ...[
                      const SizedBox(height: 24),

                      // Primary CTA Button - 48px height for mobile-first
                      // Create custom container to ensure exact 48px height
                      GestureDetector(
                        onTap: widget.onCtaPressed,
                        child: Container(
                          height: 48, // Mobile-first: 48px height
                          padding: const EdgeInsets.symmetric(horizontal: 24),
                          decoration: BoxDecoration(
                            gradient: isDark
                                ? AppColors.primaryGradientDark
                                : AppColors.primaryGradient,
                            borderRadius: BorderRadius.circular(12),
                            boxShadow: [
                              BoxShadow(
                                color: isDark
                                    ? AppColors.shadowDark
                                    : AppColors.shadowLight,
                                blurRadius: 4.0,
                                offset: const Offset(0, 2),
                              ),
                            ],
                          ),
                          child: Center(
                            child: Text(
                              widget.ctaText!,
                              style: const TextStyle(
                                fontFamily: AppTypography.fontFamily,
                                fontSize: 15,
                                fontWeight: FontWeight.w600,
                                color: Colors.white,
                              ),
                            ),
                          ),
                        ),
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
