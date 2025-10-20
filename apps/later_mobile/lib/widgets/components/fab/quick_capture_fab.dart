import 'package:flutter/material.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_typography.dart';
import '../../../core/theme/app_spacing.dart';
import '../../../core/theme/app_animations.dart';

/// Quick Capture Floating Action Button - Temporal Flow Design
///
/// Features:
/// - Squircle shape: 64×64px with 16px border radius (Temporal Flow)
/// - Primary gradient background (twilight: indigo→purple)
/// - Colored shadow (16px blur, 30% opacity, tinted with gradient end color)
/// - Icon rotation animation (Plus → X, 250ms spring physics)
/// - Scale animation on press (0.92 scale)
/// - Pulsing glow effect for long press hint
/// - 64×64px touch target for accessibility
/// - Position: 16px from bottom/right edges
/// - Hero animation tag for modal transition
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
    this.isOpen = false,
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

  /// Whether the FAB is in an "open" state (for icon rotation)
  final bool isOpen;

  @override
  State<QuickCaptureFab> createState() => _QuickCaptureFabState();
}

class _QuickCaptureFabState extends State<QuickCaptureFab>
    with TickerProviderStateMixin {
  late AnimationController _scaleController;
  late Animation<double> _scaleAnimation;

  late AnimationController _rotationController;
  late Animation<double> _rotationAnimation;

  @override
  void initState() {
    super.initState();

    // Scale animation controller
    _scaleController = AnimationController(
      duration: AppAnimations.fabPress,
      reverseDuration: AppAnimations.fabRelease,
      vsync: this,
    );
    _scaleAnimation = Tween<double>(
      begin: 1.0,
      end: AppAnimations.fabPressScale,
    ).animate(
      CurvedAnimation(
        parent: _scaleController,
        curve: AppAnimations.fabPressEasing,
        reverseCurve: AppAnimations.fabReleaseEasing,
      ),
    );

    // Icon rotation animation controller (Plus → X rotation: 45 degrees)
    _rotationController = AnimationController(
      duration: AppAnimations.fabIconRotation,
      vsync: this,
    );
    _rotationAnimation = Tween<double>(
      begin: 0.0,
      end: 0.125, // 45 degrees = 1/8 turn
    ).animate(
      CurvedAnimation(
        parent: _rotationController,
        curve: AppAnimations.springCurve,
      ),
    );

    // Set initial rotation state
    if (widget.isOpen) {
      _rotationController.value = 1.0;
    }
  }

  @override
  void didUpdateWidget(QuickCaptureFab oldWidget) {
    super.didUpdateWidget(oldWidget);

    // Animate icon rotation when isOpen changes
    if (widget.isOpen != oldWidget.isOpen) {
      if (widget.isOpen) {
        _rotationController.forward();
      } else {
        _rotationController.reverse();
      }
    }
  }

  @override
  void dispose() {
    _scaleController.dispose();
    _rotationController.dispose();
    super.dispose();
  }

  void _handleTapDown(TapDownDetails details) {
    if (widget.onPressed != null) {
      _scaleController.forward();
      // Medium haptic feedback on FAB press
      // Provides satisfying feedback for primary action button
      AppAnimations.mediumHaptic();
    }
  }

  void _handleTapUp(TapUpDetails details) {
    if (widget.onPressed != null) {
      _scaleController.reverse();
    }
  }

  void _handleTapCancel() {
    if (widget.onPressed != null) {
      _scaleController.reverse();
    }
  }

  void _handleTap() {
    if (widget.onPressed != null) {
      widget.onPressed?.call();
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final isExtended = widget.label != null;

    // Get the appropriate gradient for the current theme
    final gradient = isDark
        ? AppColors.primaryGradientDark
        : AppColors.primaryGradient;

    // Colored shadow tinted with gradient end color (16px blur, 30% opacity)
    final shadowColor = (isDark ? AppColors.primaryEndDark : AppColors.primaryEnd)
        .withValues(alpha: 0.3);

    // FAB content with rotation animation
    Widget fabContent;
    if (isExtended) {
      fabContent = Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          RotationTransition(
            turns: _rotationAnimation,
            child: Icon(
              widget.icon,
              color: Colors.white, // White icon on gradient background
              size: 24,
            ),
          ),
          const SizedBox(width: AppSpacing.xxs),
          Text(
            widget.label!,
            style: AppTypography.button.copyWith(
              color: Colors.white,
            ),
          ),
        ],
      );
    } else {
      fabContent = RotationTransition(
        turns: _rotationAnimation,
        child: Icon(
          widget.icon,
          color: Colors.white, // White icon on gradient background
          size: 24,
        ),
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
                // Squircle shape: 64×64px with 16px border radius (Temporal Flow)
                width: isExtended ? null : AppSpacing.fabSize,
                height: isExtended ? null : AppSpacing.fabSize,
                constraints: isExtended
                    ? const BoxConstraints(
                        minWidth: 80,
                        minHeight: AppSpacing.fabSize,
                      )
                    : null,
                padding: isExtended
                    ? const EdgeInsets.symmetric(
                        horizontal: AppSpacing.sm,
                        vertical: AppSpacing.xs,
                      )
                    : null,
                decoration: BoxDecoration(
                  // Primary gradient background (twilight: indigo→purple)
                  gradient: widget.useGradient ? gradient : null,
                  color: widget.useGradient ? null : AppColors.primarySolid,
                  // Squircle border radius: 16px
                  borderRadius: BorderRadius.circular(
                    isExtended ? AppSpacing.fabRadius : AppSpacing.fabRadius,
                  ),
                  // Colored shadow (16px blur, 30% opacity, tinted with gradient end color)
                  boxShadow: [
                    BoxShadow(
                      color: shadowColor,
                      blurRadius: 16,
                      offset: const Offset(0, 6),
                    ),
                    // Add soft diffused shadow for depth
                    BoxShadow(
                      color: (isDark ? AppColors.shadowDark : AppColors.shadowLight)
                          .withValues(alpha: 0.15),
                      blurRadius: 8,
                      offset: const Offset(0, 3),
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
