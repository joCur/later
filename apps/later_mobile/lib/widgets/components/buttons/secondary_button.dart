import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_typography.dart';
import '../../../core/theme/app_spacing.dart';
import '../../../core/theme/app_animations.dart';
import 'primary_button.dart';

/// Secondary button component for supporting actions
///
/// Features:
/// - Three sizes: small (32px), medium (40px), large (48px)
/// - States: default, hover, pressed, disabled, loading
/// - Haptic feedback on mobile
/// - Outlined style with transparent background
/// - Accessibility: semantic labels, focus indicators
/// - Optional icon support
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

class _SecondaryButtonState extends State<SecondaryButton>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _scaleAnimation;
  bool _isPressed = false;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: AppAnimations.buttonPress,
      vsync: this,
    );
    _scaleAnimation = Tween<double>(begin: 1.0, end: 0.98).animate(
      CurvedAnimation(parent: _controller, curve: AppAnimations.buttonEasing),
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  double get _height {
    switch (widget.size) {
      case ButtonSize.small:
        return AppSpacing.touchTargetSmall;
      case ButtonSize.medium:
        return AppSpacing.touchTargetMedium;
      case ButtonSize.large:
        return AppSpacing.touchTargetLarge;
    }
  }

  double get _horizontalPadding {
    switch (widget.size) {
      case ButtonSize.small:
        return AppSpacing.sm;
      case ButtonSize.medium:
        return AppSpacing.md;
      case ButtonSize.large:
        return AppSpacing.md;
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

  bool get _isEnabled => widget.onPressed != null && !widget.isLoading;

  void _handleTapDown(TapDownDetails details) {
    if (_isEnabled) {
      setState(() => _isPressed = true);
      _controller.forward();
      HapticFeedback.lightImpact();
    }
  }

  void _handleTapUp(TapUpDetails details) {
    if (_isEnabled) {
      setState(() => _isPressed = false);
      _controller.reverse();
    }
  }

  void _handleTapCancel() {
    if (_isEnabled) {
      setState(() => _isPressed = false);
      _controller.reverse();
    }
  }

  void _handleTap() {
    if (_isEnabled) {
      HapticFeedback.lightImpact();
      widget.onPressed?.call();
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    final borderColor = _isEnabled
        ? AppColors.primaryAmber
        : (isDark ? AppColors.neutralGray700 : AppColors.neutralGray300);

    final foregroundColor = _isEnabled
        ? AppColors.primaryAmber
        : (isDark ? AppColors.textDisabledDark : AppColors.textDisabledLight);

    final backgroundColor = _isPressed && _isEnabled
        ? (isDark
            ? AppColors.primaryAmber.withOpacity(0.1)
            : AppColors.primaryAmber.withOpacity(0.05))
        : Colors.transparent;

    Widget buttonContent = widget.isLoading
        ? SizedBox(
            width: _iconSize,
            height: _iconSize,
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
                SizedBox(width: AppSpacing.xxs),
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

    Widget button = ScaleTransition(
      scale: _scaleAnimation,
      child: Container(
        height: _height,
        padding: EdgeInsets.symmetric(horizontal: _horizontalPadding),
        decoration: BoxDecoration(
          color: backgroundColor,
          borderRadius: BorderRadius.circular(AppSpacing.buttonRadius),
          border: Border.all(
            color: borderColor,
            width: AppSpacing.borderWidthMedium,
          ),
        ),
        child: Center(child: buttonContent),
      ),
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
              ? SizedBox(width: double.infinity, child: button)
              : button,
        ),
      ),
    );
  }
}
