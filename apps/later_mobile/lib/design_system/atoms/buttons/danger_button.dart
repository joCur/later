import 'package:flutter/material.dart';
import 'package:later_mobile/core/theme/temporal_flow_theme.dart';
import 'package:later_mobile/design_system/tokens/tokens.dart';
import 'primary_button.dart';

/// Danger button component for destructive actions with Temporal Flow design
///
/// Use this button for actions that:
/// - Delete or permanently remove data
/// - Cannot be easily undone
/// - Have significant consequences
/// - Require extra user attention and caution
///
/// Examples: "Delete Account", "Remove Item", "Clear All Data", "Cancel Subscription"
///
/// Features:
/// - Red gradient background (error colors, adapts to dark mode)
/// - White text for maximum contrast and visibility
/// - Three sizes: small (36px), medium (44px), large (52px)
/// - Spring press animation (scale 1.0 → 0.92)
/// - Soft, diffused shadows (4px blur, 10% opacity)
/// - 10px border radius
/// - States: default, pressed, disabled, loading
/// - Haptic feedback on mobile
/// - Accessibility: semantic labels, focus indicators
/// - Optional icon support with 8px gap
/// - Disabled state: 40% opacity
///
/// Usage:
/// ```dart
/// DangerButton(
///   text: 'Delete Item',
///   onPressed: () => _handleDelete(),
///   icon: Icons.delete_outline,
///   size: ButtonSize.medium,
/// )
/// ```
class DangerButton extends StatefulWidget {
  const DangerButton({
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
  State<DangerButton> createState() => _DangerButtonState();
}

class _DangerButtonState extends State<DangerButton> {
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
    final temporalTheme = Theme.of(context).extension<TemporalFlowTheme>()!;

    // Danger gradient: Error colors (Red-600 → Red-500)
    // Provides strong visual warning for destructive actions
    const gradient = LinearGradient(
      begin: Alignment.topLeft,
      end: Alignment.bottomRight,
      colors: [
        AppColors.errorDark, // Red-600
        AppColors.error, // Red-500
      ],
    );

    // White text for maximum contrast against red background
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
                Icon(widget.icon, size: _iconSize, color: foregroundColor),
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
                    color: temporalTheme.shadowColor,
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
