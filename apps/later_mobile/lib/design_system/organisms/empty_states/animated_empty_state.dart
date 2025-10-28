import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:later_mobile/design_system/atoms/indicators/curved_arrow_pointer.dart';
import 'package:later_mobile/design_system/organisms/empty_states/empty_state.dart';
import 'package:later_mobile/design_system/tokens/tokens.dart';

/// An animated wrapper around EmptyState that adds entrance animations
/// and an optional curved arrow pointer to guide users to the FAB.
///
/// Features:
/// - Staggered animations: empty state content → arrow → FAB pulse
/// - Curved arrow pointing from empty state to FAB location
/// - Optional dismiss button (X icon) in top-right corner
/// - Respects reduced motion preferences
/// - Auto-dismisses after 10 seconds
///
/// Usage:
/// ```dart
/// AnimatedEmptyState(
///   title: 'No items yet',
///   message: 'Create your first item to get started',
///   fabPosition: Offset(320, 700),
///   showArrow: true,
///   onDismissed: () => setState(() => _showAnimation = false),
///   enableFabPulse: (enabled) => setState(() => _fabPulse = enabled),
/// )
/// ```
class AnimatedEmptyState extends StatefulWidget {
  const AnimatedEmptyState({
    super.key,
    this.icon,
    required this.title,
    required this.message,
    this.actionLabel,
    this.onActionPressed,
    this.secondaryActionLabel,
    this.onSecondaryPressed,
    required this.fabPosition,
    this.showArrow = true,
    this.onDismissed,
    this.enableFabPulse,
    this.autoHideDuration = const Duration(seconds: 10),
  });

  /// Optional icon to display above the title
  final IconData? icon;

  /// Title text for the empty state
  final String title;

  /// Descriptive message explaining the empty state
  final String message;

  /// Optional label for the call-to-action button
  final String? actionLabel;

  /// Optional callback when the CTA button is pressed
  final VoidCallback? onActionPressed;

  /// Optional label for the secondary action button
  final String? secondaryActionLabel;

  /// Optional callback when the secondary action button is pressed
  final VoidCallback? onSecondaryPressed;

  /// Position of the FAB (used to calculate arrow endpoint)
  final Offset fabPosition;

  /// Whether to show the curved arrow pointer
  final bool showArrow;

  /// Callback when animation is dismissed
  final VoidCallback? onDismissed;

  /// Callback to enable/disable FAB pulse animation
  /// Called with true after arrow animation completes
  /// Called with false when dismissed
  final ValueChanged<bool>? enableFabPulse;

  /// Duration after which animation auto-dismisses (default: 10 seconds)
  final Duration autoHideDuration;

  @override
  State<AnimatedEmptyState> createState() => _AnimatedEmptyStateState();
}

class _AnimatedEmptyStateState extends State<AnimatedEmptyState> {
  bool _isDismissed = false;
  final GlobalKey _emptyStateKey = GlobalKey();

  @override
  void initState() {
    super.initState();

    // Schedule FAB pulse to start after arrow animation completes
    if (widget.showArrow && widget.enableFabPulse != null) {
      // Arrow completes at 300ms (delay) + 400ms (gentle duration) = 700ms
      Future.delayed(const Duration(milliseconds: 700), () {
        if (mounted && !_isDismissed) {
          widget.enableFabPulse?.call(true);
        }
      });
    }

    // Auto-dismiss after duration
    Future.delayed(widget.autoHideDuration, () {
      if (mounted && !_isDismissed) {
        _dismiss();
      }
    });
  }

  @override
  void dispose() {
    // Ensure FAB pulse stops when widget is disposed
    widget.enableFabPulse?.call(false);
    super.dispose();
  }

  void _dismiss() {
    if (_isDismissed) return;

    setState(() {
      _isDismissed = true;
    });

    // Stop FAB pulse
    widget.enableFabPulse?.call(false);

    // Notify parent after fade out animation completes
    Future.delayed(AppAnimations.normal, () {
      if (mounted) {
        widget.onDismissed?.call();
      }
    });
  }

  Offset _calculateArrowStartPosition() {
    // Try to get the position of the message text
    final RenderBox? renderBox =
        _emptyStateKey.currentContext?.findRenderObject() as RenderBox?;

    if (renderBox != null) {
      // Get the center of the empty state widget
      final size = renderBox.size;
      final position = renderBox.localToGlobal(Offset.zero);

      // Start arrow from bottom-center of empty state content
      return Offset(
        position.dx + size.width / 2,
        position.dy + size.height * 0.75,
      );
    }

    // Fallback: calculate from screen center
    return Offset(
      MediaQuery.of(context).size.width / 2,
      MediaQuery.of(context).size.height / 2 + 50,
    );
  }

  @override
  Widget build(BuildContext context) {
    final reducedMotion = AppAnimations.prefersReducedMotion(context);

    // Build the empty state content with animations
    Widget emptyStateContent = EmptyState(
      key: _emptyStateKey,
      icon: widget.icon,
      title: widget.title,
      message: widget.message,
      actionLabel: widget.actionLabel,
      onActionPressed: widget.onActionPressed,
      secondaryActionLabel: widget.secondaryActionLabel,
      onSecondaryPressed: widget.onSecondaryPressed,
    );

    // Add entrance animation to empty state
    if (!reducedMotion && !_isDismissed) {
      emptyStateContent = emptyStateContent
          .animate()
          .fadeIn(
            duration: AppAnimations.gentle,
            curve: AppAnimations.gentleSpringCurve,
          )
          .scale(
            begin: const Offset(0.95, 0.95),
            end: const Offset(1.0, 1.0),
            duration: AppAnimations.gentle,
            curve: AppAnimations.gentleSpringCurve,
          );
    }

    // Wrap with dismiss animation if dismissed
    if (_isDismissed) {
      emptyStateContent = emptyStateContent
          .animate()
          .fadeOut(
            duration: AppAnimations.normal,
            curve: Curves.easeOut,
          )
          .scale(
            begin: const Offset(1.0, 1.0),
            end: const Offset(0.95, 0.95),
            duration: AppAnimations.normal,
            curve: Curves.easeOut,
          );
    }

    return Stack(
      children: [
        // Empty state content
        emptyStateContent,

        // Curved arrow pointer (if enabled and not dismissed)
        if (widget.showArrow && !_isDismissed)
          Positioned.fill(
            child: LayoutBuilder(
              builder: (context, constraints) {
                // Wait for first frame to get accurate positions
                WidgetsBinding.instance.addPostFrameCallback((_) {
                  if (mounted) {
                    setState(() {});
                  }
                });

                final startPosition = _calculateArrowStartPosition();

                Widget arrow = CurvedArrowPointer(
                  startPosition: startPosition,
                  endPosition: widget.fabPosition,
                  animate: !reducedMotion,
                );

                // Add delay to arrow appearance
                if (!reducedMotion) {
                  arrow = arrow.animate().fadeIn(
                        duration: AppAnimations.gentle,
                        delay: const Duration(milliseconds: 300),
                        curve: AppAnimations.smoothSpringCurve,
                      );
                }

                return arrow;
              },
            ),
          ),

        // Dismiss button (top-right corner)
        if (!_isDismissed)
          Positioned(
            top: AppSpacing.sm,
            right: AppSpacing.sm,
            child: IconButton(
              icon: const Icon(Icons.close, size: 20),
              onPressed: _dismiss,
              tooltip: 'Dismiss',
              style: IconButton.styleFrom(
                foregroundColor: AppColors.textSecondary(context),
                backgroundColor:
                    AppColors.textSecondary(context).withValues(alpha: 0.1),
                minimumSize: const Size(32, 32),
                padding: EdgeInsets.zero,
              ),
            ),
          )
              .animate()
              .fadeIn(
                duration: AppAnimations.gentle,
                delay: const Duration(milliseconds: 600),
                curve: Curves.easeOut,
              )
              .scale(
                begin: const Offset(0.8, 0.8),
                end: const Offset(1.0, 1.0),
                duration: AppAnimations.gentle,
                delay: const Duration(milliseconds: 600),
                curve: AppAnimations.gentleSpringCurve,
              ),
      ],
    );
  }
}
