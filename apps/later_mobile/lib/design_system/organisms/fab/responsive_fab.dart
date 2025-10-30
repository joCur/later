import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:later_mobile/design_system/tokens/tokens.dart';
import '../../../core/responsive/breakpoints.dart';
import 'package:later_mobile/design_system/molecules/fab/create_content_fab.dart';
import 'package:later_mobile/core/theme/temporal_flow_theme.dart';

/// A responsive Floating Action Button that adapts between mobile and desktop layouts.
///
/// On mobile (< 768px):
/// - Displays as a circular FAB (56×56px)
/// - Icon only, no label
/// - Uses CreateContentFab component for consistent styling
/// - Gradient background with 30% white overlay
///
/// On desktop/tablet (>= 768px):
/// - Displays as an extended FAB with icon and label
/// - Uses FloatingActionButton.extended
/// - Same gradient styling as mobile
///
/// Example usage:
/// ```dart
/// ResponsiveFab(
///   icon: Icons.add,
///   label: 'Add Todo',
///   onPressed: () => _addTodoItem(),
///   gradient: AppColors.taskGradient,
/// )
/// ```
class ResponsiveFab extends StatefulWidget {
  const ResponsiveFab({
    super.key,
    required this.icon,
    this.label,
    this.onPressed,
    this.gradient,
    this.tooltip,
    this.heroTag,
    this.enablePulse = false,
  });

  /// The icon to display in the FAB
  final IconData icon;

  /// The label to display (only shown on desktop)
  /// On mobile, this is used only for accessibility
  final String? label;

  /// Callback when the FAB is pressed
  final VoidCallback? onPressed;

  /// Optional gradient to use for the FAB background
  /// If null, uses the primary gradient
  final Gradient? gradient;

  /// Optional tooltip text
  /// If null, uses the label
  final String? tooltip;

  /// Optional hero tag for animations
  final Object? heroTag;

  /// Whether to enable pulsing animation (for empty state hints)
  final bool enablePulse;

  @override
  State<ResponsiveFab> createState() => _ResponsiveFabState();
}

/// Configuration for FAB pulse animation behavior.
///
/// This class controls the auto-stop behavior of the pulsing animation
/// that can be applied to FAB components (ResponsiveFab and CreateContentFab).
///
/// The pulse animation is typically used to draw user attention to the FAB,
/// especially in empty states or to encourage first-time user interaction.
///
/// ## Usage
///
/// To enable continuous pulsing without auto-stop (current configuration):
/// ```dart
/// ResponsiveFab(
///   enablePulse: true,
///   // ... other properties
/// )
/// ```
///
/// The pulse will continue until the user interacts with the FAB or
/// the widget is disposed/updated with `enablePulse: false`.
///
/// ## Auto-Stop Configuration
///
/// Set [autoStopDuration] to automatically stop the pulse after a duration:
/// ```dart
/// // In FabPulseConfig class:
/// static const Duration? autoStopDuration = Duration(seconds: 10);
/// ```
///
/// Setting [autoStopDuration] to `null` (current value) disables the
/// auto-stop feature, allowing the pulse to continue indefinitely.
class FabPulseConfig {
  const FabPulseConfig._();

  /// Duration before auto-stopping the pulse (null = never auto-stop)
  static const Duration? autoStopDuration = null;
}

class _ResponsiveFabState extends State<ResponsiveFab> {
  bool _isPulsing = false;
  Timer? _pulseTimer;

  @override
  void initState() {
    super.initState();
    if (widget.enablePulse) {
      _startPulsing();
    }
  }

  @override
  void didUpdateWidget(ResponsiveFab oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.enablePulse != oldWidget.enablePulse) {
      if (widget.enablePulse) {
        _startPulsing();
      } else {
        _stopPulsing();
      }
    }
  }

  @override
  void dispose() {
    _pulseTimer?.cancel();
    super.dispose();
  }

  void _startPulsing() {
    setState(() {
      _isPulsing = true;
    });

    // Auto-stop after configured duration (if set)
    if (FabPulseConfig.autoStopDuration != null) {
      _pulseTimer = Timer(FabPulseConfig.autoStopDuration!, () {
        if (mounted) {
          _stopPulsing();
        }
      });
    }
  }

  void _stopPulsing() {
    _pulseTimer?.cancel();
    _pulseTimer = null;
    if (mounted) {
      setState(() {
        _isPulsing = false;
      });
    }
  }

  void _handleTap() {
    if (_isPulsing) {
      _stopPulsing();
    }
    widget.onPressed?.call();
  }

  @override
  Widget build(BuildContext context) {
    final isMobile = Breakpoints.isMobile(context);

    if (isMobile) {
      return _buildMobileFab(context);
    } else {
      return _buildDesktopFab(context);
    }
  }

  /// Build mobile circular FAB using CreateContentFab
  Widget _buildMobileFab(BuildContext context) {
    return CreateContentFab(
      icon: widget.icon,
      onPressed: _handleTap,
      tooltip: widget.tooltip ?? widget.label ?? 'Action',
      heroTag: widget.heroTag,
      useGradient: widget.gradient != null,
      enablePulse: widget.enablePulse,
    );
  }

  /// Build desktop extended FAB
  Widget _buildDesktopFab(BuildContext context) {
    final temporalTheme = Theme.of(context).extension<TemporalFlowTheme>()!;

    // Get the appropriate gradient
    final effectiveGradient = widget.gradient ?? temporalTheme.primaryGradient;

    // Get shadow color from gradient
    final shadowColor = effectiveGradient is LinearGradient
        ? (effectiveGradient.colors.last).withValues(alpha: 0.15)
        : AppColors.primaryEnd.withValues(alpha: 0.15);

    Widget fabWidget = FloatingActionButton.extended(
      onPressed: _handleTap,
      heroTag: widget.heroTag,
      tooltip: widget.tooltip ?? widget.label,
      elevation: 0,
      highlightElevation: 0,
      backgroundColor: Colors.transparent,
      // Custom extended FAB with gradient
      label: Container(
        padding: const EdgeInsets.symmetric(
          horizontal: AppSpacing.sm,
          vertical: AppSpacing.xs,
        ),
        decoration: BoxDecoration(
          gradient: effectiveGradient,
          borderRadius: BorderRadius.circular(AppSpacing.fabRadius),
          boxShadow: [
            BoxShadow(
              color: shadowColor,
              blurRadius: 16,
              offset: const Offset(0, 8),
            ),
          ],
        ),
        // Apply 30% white overlay for mobile-first design consistency
        foregroundDecoration: BoxDecoration(
          color: Colors.white.withValues(alpha: 0.3),
          borderRadius: BorderRadius.circular(AppSpacing.fabRadius),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(widget.icon, color: Colors.white, size: 24),
            if (widget.label != null) ...[
              const SizedBox(width: AppSpacing.xs),
              Text(
                widget.label!,
                style: AppTypography.button.copyWith(color: Colors.white),
              ),
            ],
          ],
        ),
      ),
    );

    // Apply pulse animation if enabled and pulsing
    if (_isPulsing && !AppAnimations.prefersReducedMotion(context)) {
      fabWidget = fabWidget
          .animate(onPlay: (controller) => controller.repeat())
          .scale(
            begin: const Offset(1.0, 1.0),
            end: const Offset(1.08, 1.08),
            duration: const Duration(milliseconds: 1000),
            curve: AppAnimations.bouncySpringCurve,
          )
          .then()
          .scale(
            begin: const Offset(1.08, 1.08),
            end: const Offset(1.0, 1.0),
            duration: const Duration(milliseconds: 1000),
            curve: AppAnimations.bouncySpringCurve,
          );
    }

    return fabWidget;
  }
}
