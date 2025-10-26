import 'package:flutter/material.dart';
import 'package:later_mobile/design_system/tokens/tokens.dart';

/// Button size enum
enum ButtonSize {
  small, // 36px height
  medium, // 44px height
  large, // 52px height
}

/// Primary button component for main CTAs with Temporal Flow design
///
/// Features:
/// - Gradient background (primary gradient, adapts to dark mode)
/// - Three sizes: small (36px), medium (44px), large (52px)
/// - Spring press animation (scale 1.0 → 0.92)
/// - Soft, diffused shadows (4px blur, 10% opacity)
/// - 10px border radius
/// - States: default, pressed, disabled, loading
/// - Haptic feedback on mobile
/// - Accessibility: semantic labels, focus indicators
/// - Optional icon support with 8px gap
/// - Disabled state: 40% opacity
class PrimaryButton extends StatefulWidget {
  const PrimaryButton({
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
  State<PrimaryButton> createState() => _PrimaryButtonState();
}

class _PrimaryButtonState extends State<PrimaryButton> {
  bool _isPressed = false;

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

    // Foreground color (white for both light and dark)
    const foregroundColor = Colors.white;

    final Widget buttonContent = widget.isLoading
        ? SizedBox(
            width: _loadingSize,
            height: _loadingSize,
            child: const CircularProgressIndicator(
              strokeWidth: 2,
              valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
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

    final Widget button = AnimatedScale(
      scale: _isPressed ? AppAnimations.fabPressScale : 1.0,
      duration: AppAnimations.quick,
      curve: AppAnimations.springCurve,
      child: Container(
        height: _height,
        padding: EdgeInsets.symmetric(horizontal: _horizontalPadding),
        decoration: BoxDecoration(
          gradient: gradient,
          borderRadius: BorderRadius.circular(AppSpacing.buttonRadius),
          boxShadow: _isEnabled && !_isPressed
              ? [
                  BoxShadow(
                    color: isDark
                        ? AppColors.shadowDark
                        : AppColors.shadowLight,
                    blurRadius: 4.0,
                    offset: const Offset(0, 2),
                  ),
                ]
              : null,
        ),
        child: Center(child: buttonContent),
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
