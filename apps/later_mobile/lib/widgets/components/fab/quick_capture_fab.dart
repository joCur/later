import 'package:flutter/material.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_typography.dart';
import '../../../core/theme/app_spacing.dart';
import '../../../core/theme/app_animations.dart';

/// Quick Capture Floating Action Button - Mobile-First Bold Design
///
/// Features:
/// - Circular shape: 56×56px (Android standard, mobile-first design)
/// - Primary gradient background with 30% white overlay
/// - Simplified shadow: 8px offset, 16px blur, 15% opacity (single shadow)
/// - Simple plus icon (no rotation for performance)
/// - Scale animation on press (0.9 scale for 100ms)
/// - 56×56px touch target for accessibility
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

  /// Whether the FAB is in an "open" state (kept for API compatibility, not used for rotation)
  final bool isOpen;

  @override
  State<QuickCaptureFab> createState() => _QuickCaptureFabState();
}

class _QuickCaptureFabState extends State<QuickCaptureFab>
    with SingleTickerProviderStateMixin {
  late AnimationController _scaleController;
  late Animation<double> _scaleAnimation;

  @override
  void initState() {
    super.initState();

    // Simplified scale animation: 0.9 → 1.0 (100ms for mobile-first design)
    _scaleController = AnimationController(
      duration: const Duration(milliseconds: 100),
      reverseDuration: const Duration(milliseconds: 150),
      vsync: this,
    );
    _scaleAnimation = Tween<double>(
      begin: 1.0,
      end: 0.9, // Scale down to 0.9 on press (mobile-first design)
    ).animate(
      CurvedAnimation(
        parent: _scaleController,
        curve: Curves.easeOut,
        reverseCurve: Curves.easeOutBack,
      ),
    );
  }

  @override
  void dispose() {
    _scaleController.dispose();
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

    // Simplified shadow: 8px offset, 16px blur, 15% opacity (mobile-first design)
    final shadowColor = (isDark ? AppColors.primaryEndDark : AppColors.primaryEnd)
        .withValues(alpha: 0.15);

    // FAB content: simple static icon (no rotation for mobile-first design)
    Widget fabContent;
    if (isExtended) {
      fabContent = Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            widget.icon,
            color: Colors.white, // White icon on gradient background
            size: 24,
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
      fabContent = Icon(
        widget.icon,
        color: Colors.white, // White icon on gradient background
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
                // Circular shape: 56×56px (Android standard, mobile-first design)
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
                  // Primary gradient background with 30% white overlay
                  gradient: widget.useGradient ? gradient : null,
                  color: widget.useGradient ? null : AppColors.primarySolid,
                  // Perfect circle border radius: 28px (mobile-first design)
                  borderRadius: BorderRadius.circular(AppSpacing.fabRadius),
                  // Simplified shadow: 8px offset, 16px blur, 15% opacity (single shadow)
                  boxShadow: [
                    BoxShadow(
                      color: shadowColor,
                      blurRadius: 16,
                      offset: const Offset(0, 8),
                    ),
                  ],
                ),
                // Apply 30% white overlay for mobile-first design
                foregroundDecoration: widget.useGradient
                    ? BoxDecoration(
                        color: Colors.white.withValues(alpha: 0.3),
                        borderRadius: BorderRadius.circular(AppSpacing.fabRadius),
                      )
                    : null,
                child: Center(child: fabContent),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
