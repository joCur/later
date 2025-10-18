import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_typography.dart';
import '../../../core/theme/app_spacing.dart';
import '../../../core/theme/app_animations.dart';

/// Quick Capture Floating Action Button
///
/// Features:
/// - 56x56dp visual size, 64x64dp touch target
/// - Accent-primary amber color with gradient (if supported)
/// - Level 3 elevation shadow
/// - Position: bottom-right with 16dp margin
/// - Scale animation on press (0.95)
/// - Hero animation tag for modal transition
/// - Optional extended FAB with label
/// - Haptic feedback on press
class QuickCaptureFab extends StatefulWidget {
  const QuickCaptureFab({
    super.key,
    required this.onPressed,
    this.icon = Icons.add,
    this.label,
    this.tooltip,
    this.heroTag = 'quick-capture-fab',
    this.useGradient = true,
  });

  /// Callback when FAB is pressed
  final VoidCallback? onPressed;

  /// Icon to display
  final IconData icon;

  /// Optional label for extended FAB
  final String? label;

  /// Optional tooltip text
  final String? tooltip;

  /// Hero tag for animation
  final Object? heroTag;

  /// Whether to use gradient background
  final bool useGradient;

  @override
  State<QuickCaptureFab> createState() => _QuickCaptureFabState();
}

class _QuickCaptureFabState extends State<QuickCaptureFab>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _scaleAnimation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: AppAnimations.fabPress,
      reverseDuration: AppAnimations.fabRelease,
      vsync: this,
    );
    _scaleAnimation = Tween<double>(
      begin: 1.0,
      end: AppAnimations.fabPressScale,
    ).animate(
      CurvedAnimation(
        parent: _controller,
        curve: AppAnimations.fabPressEasing,
        reverseCurve: AppAnimations.fabReleaseEasing,
      ),
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _handleTapDown(TapDownDetails details) {
    if (widget.onPressed != null) {
      _controller.forward();
      HapticFeedback.lightImpact();
    }
  }

  void _handleTapUp(TapUpDetails details) {
    if (widget.onPressed != null) {
      _controller.reverse();
    }
  }

  void _handleTapCancel() {
    if (widget.onPressed != null) {
      _controller.reverse();
    }
  }

  void _handleTap() {
    if (widget.onPressed != null) {
      HapticFeedback.mediumImpact();
      widget.onPressed?.call();
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final isExtended = widget.label != null;

    // FAB content
    Widget fabContent;
    if (isExtended) {
      fabContent = Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            widget.icon,
            color: AppColors.neutralBlack,
            size: 24,
          ),
          const SizedBox(width: AppSpacing.xxs),
          Text(
            widget.label!,
            style: AppTypography.button.copyWith(
              color: AppColors.neutralBlack,
            ),
          ),
        ],
      );
    } else {
      fabContent = Icon(
        widget.icon,
        color: AppColors.neutralBlack,
        size: 24,
      );
    }

    return Hero(
      tag: widget.heroTag ?? UniqueKey(),
      child: Semantics(
        button: true,
        enabled: widget.onPressed != null,
        label: widget.tooltip ?? (widget.label ?? 'Quick Capture'),
        child: Tooltip(
          message: widget.tooltip ?? '',
          child: ScaleTransition(
            scale: _scaleAnimation,
            child: GestureDetector(
              onTapDown: _handleTapDown,
              onTapUp: _handleTapUp,
              onTapCancel: _handleTapCancel,
              onTap: _handleTap,
              child: Container(
                constraints: BoxConstraints(
                  minWidth: isExtended ? 80 : AppSpacing.touchTargetFAB,
                  minHeight: AppSpacing.touchTargetFAB,
                ),
                padding: isExtended
                    ? const EdgeInsets.symmetric(
                        horizontal: AppSpacing.sm,
                        vertical: AppSpacing.xs,
                      )
                    : null,
                decoration: BoxDecoration(
                  gradient: widget.useGradient
                      ? AppColors.fabGradient
                      : null,
                  color: widget.useGradient ? null : AppColors.primaryAmber,
                  borderRadius: BorderRadius.circular(
                    isExtended ? AppSpacing.fabRadius : AppSpacing.radiusFull,
                  ),
                  boxShadow: [
                    // Level 3 elevation
                    BoxShadow(
                      color: isDark
                          ? Colors.black.withOpacity(0.5)
                          : Colors.black.withOpacity(0.1),
                      blurRadius: 15,
                      offset: const Offset(0, 10),
                    ),
                    BoxShadow(
                      color: isDark
                          ? Colors.black.withOpacity(0.3)
                          : Colors.black.withOpacity(0.05),
                      blurRadius: 6,
                      offset: const Offset(0, 4),
                    ),
                  ],
                ),
                child: Center(child: fabContent),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
