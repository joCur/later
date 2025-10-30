import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:later_mobile/design_system/organisms/empty_states/empty_state.dart';
import 'package:later_mobile/design_system/tokens/tokens.dart';

/// An animated wrapper around EmptyState that adds entrance animations
/// and triggers FAB pulse to guide users to create their first item.
///
/// Features:
/// - Entrance animations for empty state content
/// - Triggers FAB pulse animation after entrance completes
/// - Respects reduced motion preferences
///
/// Usage:
/// ```dart
/// AnimatedEmptyState(
///   title: 'No items yet',
///   message: 'Create your first item to get started',
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
    this.enableFabPulse,
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

  /// Callback to enable/disable FAB pulse animation
  /// Called with true after entrance animation completes
  /// Called with false when widget is disposed
  final ValueChanged<bool>? enableFabPulse;

  @override
  State<AnimatedEmptyState> createState() => _AnimatedEmptyStateState();
}

class _AnimatedEmptyStateState extends State<AnimatedEmptyState> {
  @override
  void initState() {
    super.initState();

    // Schedule FAB pulse to start after entrance animation completes
    if (widget.enableFabPulse != null) {
      // Use animation duration to sync with entrance animation completion
      Future.delayed(AppAnimations.gentle, () {
        if (mounted) {
          widget.enableFabPulse?.call(true);
        }
      });
    }
  }

  @override
  void dispose() {
    // Ensure FAB pulse stops when widget is disposed
    // Schedule after frame to avoid calling setState during build
    WidgetsBinding.instance.addPostFrameCallback((_) {
      widget.enableFabPulse?.call(false);
    });
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final reducedMotion = AppAnimations.prefersReducedMotion(context);

    // Build the empty state content with animations
    Widget emptyStateContent = EmptyState(
      icon: widget.icon,
      title: widget.title,
      message: widget.message,
      actionLabel: widget.actionLabel,
      onActionPressed: widget.onActionPressed,
      secondaryActionLabel: widget.secondaryActionLabel,
      onSecondaryPressed: widget.onSecondaryPressed,
    );

    // Add entrance animation to empty state
    if (!reducedMotion) {
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

    return emptyStateContent;
  }
}
