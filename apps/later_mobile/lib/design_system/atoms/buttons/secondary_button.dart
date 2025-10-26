import 'package:flutter/material.dart';
import 'package:later_mobile/design_system/tokens/tokens.dart';
import 'primary_button.dart';

/// Secondary button component for supporting actions with Temporal Flow design
///
/// Features:
/// - Gradient border (1px, primary gradient at 50% opacity)
/// - Glass background on hover (semi-transparent overlay)
/// - Three sizes: small (36px), medium (44px), large (52px)
/// - Spring press animation (scale 1.0 → 0.92)
/// - 10px border radius
/// - States: default, hover, pressed, disabled, loading
/// - Haptic feedback on mobile
/// - Accessibility: semantic labels, focus indicators
/// - Optional icon support with 8px gap
/// - Disabled state: 40% opacity
class SecondaryButton extends StatefulWidget {
  const SecondaryButton({
    super.key,
    required this.text,
    required this.onPressed,
    this.icon,
    this.size = ButtonSize.medium,
    this.isLoading = false,
    this.isExpanded = false,
  });

  /// Button text label
  final String text;

  /// Callback when button is pressed
  final VoidCallback? onPressed;

  /// Optional icon to display before text
  final IconData? icon;

  /// Button size variant
  final ButtonSize size;

  /// Whether to show loading indicator
  final bool isLoading;

  /// Whether button should expand to full width
  final bool isExpanded;

  @override
  State<SecondaryButton> createState() => _SecondaryButtonState();
}

class _SecondaryButtonState extends State<SecondaryButton> {
  bool _isPressed = false;
  bool _isHovered = false;

  double get _height {
    switch (widget.size) {
      case ButtonSize.small:
        return 36.0;
      case ButtonSize.medium:
        return 44.0;
      case ButtonSize.large:
        return 52.0;
    }
  }

  double get _horizontalPadding {
    switch (widget.size) {
      case ButtonSize.small:
        return 12.0;
      case ButtonSize.medium:
        return 16.0;
      case ButtonSize.large:
        return 24.0;
    }
  }

  double get _fontSize {
    switch (widget.size) {
      case ButtonSize.small:
        return 12;
      case ButtonSize.medium:
        return 14;
      case ButtonSize.large:
        return 16;
    }
  }

  double get _iconSize {
    switch (widget.size) {
      case ButtonSize.small:
        return 16;
      case ButtonSize.medium:
        return 20;
      case ButtonSize.large:
        return 24;
    }
  }

  double get _loadingSize {
    switch (widget.size) {
      case ButtonSize.small:
        return 16;
      case ButtonSize.medium:
        return 20;
      case ButtonSize.large:
        return 20;
    }
  }

  bool get _isEnabled => widget.onPressed != null && !widget.isLoading;

  void _handleTapDown(TapDownDetails details) {
    if (_isEnabled) {
      setState(() => _isPressed = true);
      // Light haptic feedback on button press
      AppAnimations.lightHaptic();
    }
  }

  void _handleTapUp(TapUpDetails details) {
    if (_isEnabled) {
      setState(() => _isPressed = false);
    }
  }

  void _handleTapCancel() {
    if (_isEnabled) {
      setState(() => _isPressed = false);
    }
  }

  void _handleTap() {
    if (_isEnabled) {
      widget.onPressed?.call();
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    // Get gradient based on theme
    final gradient = isDark
        ? AppColors.primaryGradientDark
        : AppColors.primaryGradient;

    // Foreground color - use gradient colors
    final foregroundColor = isDark
        ? AppColors.primaryStartDark
        : AppColors.primaryStart;

    final Widget buttonContent = widget.isLoading
        ? SizedBox(
            width: _loadingSize,
            height: _loadingSize,
            child: CircularProgressIndicator(
              strokeWidth: 2,
              valueColor: AlwaysStoppedAnimation<Color>(foregroundColor),
            ),
          )
        : Row(
            mainAxisSize: MainAxisSize.min,
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              if (widget.icon != null) ...[
                Icon(
                  widget.icon,
                  size: _iconSize,
                  color: foregroundColor,
                ),
                const SizedBox(width: AppSpacing.xs),
              ],
              Text(
                widget.text,
                style: AppTypography.button.copyWith(
                  fontSize: _fontSize,
                  color: foregroundColor,
                ),
              ),
            ],
          );

    // Glass hover effect
    final hoverOverlay = _isHovered && _isEnabled
        ? Container(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [
                  (isDark
                          ? AppColors.primaryStartDark
                          : AppColors.primaryStart)
                      .withValues(alpha: 0.05),
                  (isDark ? AppColors.primaryEndDark : AppColors.primaryEnd)
                      .withValues(alpha: 0.08),
                ],
              ),
              borderRadius: BorderRadius.circular(AppSpacing.buttonRadius - 1),
            ),
          )
        : null;

    final Widget button = MouseRegion(
      onEnter: (_) {
        if (_isEnabled) setState(() => _isHovered = true);
      },
      onExit: (_) {
        if (_isEnabled) setState(() => _isHovered = false);
      },
      child: AnimatedScale(
        scale: _isPressed ? AppAnimations.fabPressScale : 1.0,
        duration: AppAnimations.quick,
        curve: AppAnimations.springCurve,
        child: Container(
          height: _height,
          padding: const EdgeInsets.all(AppSpacing.borderWidthThin),
          decoration: BoxDecoration(
            gradient: gradient.scale(0.5), // 50% opacity gradient for border
            borderRadius: BorderRadius.circular(AppSpacing.buttonRadius),
          ),
          child: Stack(
            children: [
              // Inner container with background
              Container(
                padding: EdgeInsets.symmetric(horizontal: _horizontalPadding - 1),
                decoration: BoxDecoration(
                  color: isDark ? AppColors.neutral900 : Colors.white,
                  borderRadius:
                      BorderRadius.circular(AppSpacing.buttonRadius - 1),
                ),
                child: Center(child: buttonContent),
              ),
              // Hover overlay
              if (hoverOverlay != null)
                Positioned.fill(child: hoverOverlay),
            ],
          ),
        ),
      ),
    );

    // Wrap in Opacity for disabled state
    final Widget finalButton = _isEnabled
        ? button
        : Opacity(
            opacity: AppColors.disabledOpacity,
            child: IgnorePointer(child: button),
          );

    return Semantics(
      button: true,
      enabled: _isEnabled,
      label: widget.text,
      child: GestureDetector(
        onTapDown: _handleTapDown,
        onTapUp: _handleTapUp,
        onTapCancel: _handleTapCancel,
        onTap: _handleTap,
        child: Focus(
          child: widget.isExpanded
              ? SizedBox(width: double.infinity, child: finalButton)
              : finalButton,
        ),
      ),
    );
  }
}

// Extension to scale gradient opacity
extension GradientScale on LinearGradient {
  LinearGradient scale(double factor) {
    return LinearGradient(
      begin: begin,
      end: end,
      colors: colors
          .map((color) => color.withValues(alpha: color.a * factor))
          .toList(),
    );
  }
}
