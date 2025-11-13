import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:later_mobile/design_system/tokens/tokens.dart';
import 'package:later_mobile/l10n/app_localizations.dart';

/// Drag handle widget for reorderable content cards
///
/// Features:
/// - 3×2 grid of grip dots (4×4px circles) with 4px vertical, 6px horizontal spacing
/// - Visible icon size: 20×24px centered in 48×48px touch target
/// - Gradient shader applied to dots (matches card type)
/// - Interaction states: 40% default → 60% hover → 100% active
/// - Haptic feedback on drag start (medium impact)
/// - Accessibility: semantic labels, 48×48px touch target
/// - Reduced motion support: instant opacity changes
///
/// Usage:
/// ```dart
/// DragHandleWidget(
///   gradient: AppColors.taskGradient,
///   semanticLabel: 'Reorder Shopping List',
///   onDragStart: () => print('Drag started'),
///   onDragEnd: () => print('Drag ended'),
/// )
/// ```
class DragHandleWidget extends StatefulWidget {
  const DragHandleWidget({
    super.key,
    required this.gradient,
    required this.semanticLabel,
    this.onDragStart,
    this.onDragEnd,
    this.size = 48.0,
  });

  /// Gradient to apply to grip dots (e.g., AppColors.taskGradient)
  final Gradient gradient;

  /// Semantic label for accessibility (e.g., 'Reorder Shopping List')
  final String semanticLabel;

  /// Callback when drag starts (onTapDown)
  final VoidCallback? onDragStart;

  /// Callback when drag ends (onTapUp/onTapCancel)
  final VoidCallback? onDragEnd;

  /// Touch target size (default 48.0 for accessibility)
  final double size;

  @override
  State<DragHandleWidget> createState() => _DragHandleWidgetState();
}

class _DragHandleWidgetState extends State<DragHandleWidget> {
  bool _isPressed = false;
  bool _isHovered = false;

  /// Get current opacity based on interaction state
  double get _opacity {
    if (_isPressed) {
      return 1.0; // 100% active
    } else if (_isHovered) {
      return 0.6; // 60% hover
    } else {
      return 0.4; // 40% default (subtle)
    }
  }

  void _handleTapDown(TapDownDetails details) {
    setState(() => _isPressed = true);

    // Trigger haptic feedback
    AppAnimations.mediumHaptic();

    // Call callback if provided
    widget.onDragStart?.call();
  }

  void _handleTapUp(TapUpDetails details) {
    setState(() => _isPressed = false);

    // Light haptic on release
    AppAnimations.lightHaptic();

    // Call callback if provided
    widget.onDragEnd?.call();
  }

  void _handleTapCancel() {
    setState(() => _isPressed = false);

    // Light haptic on cancel
    AppAnimations.lightHaptic();

    // Call callback if provided
    widget.onDragEnd?.call();
  }

  void _handleMouseEnter(PointerEnterEvent event) {
    setState(() => _isHovered = true);
  }

  void _handleMouseExit(PointerExitEvent event) {
    setState(() => _isHovered = false);
  }

  /// Build grip dots pattern (3×2 grid of circles)
  Widget _buildGripDots() {
    return ShaderMask(
      shaderCallback: (Rect bounds) {
        return widget.gradient.createShader(bounds);
      },
      child: SizedBox(
        width:
            20, // Total visible width (4px dot + 6px spacing + 4px dot + 6px padding)
        height:
            30, // Total visible height (4px dot + 6px spacing + 4px dot + 6px spacing + 4px dot + 6px padding)
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            _buildDotRow(),
            const SizedBox(height: 6),
            _buildDotRow(),
            const SizedBox(height: 6),
            _buildDotRow(),
          ],
        ),
      ),
    );
  }

  /// Build a single row of 2 dots
  Widget _buildDotRow() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [_buildDot(), const SizedBox(width: 4), _buildDot()],
    );
  }

  /// Build a single dot (4×4px circle)
  Widget _buildDot() {
    return Container(
      width: 4,
      height: 4,
      decoration: const BoxDecoration(
        color: Colors.white, // ShaderMask will apply gradient
        shape: BoxShape.circle,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;

    // Check if reduced motion is preferred
    final reducedMotion = AppAnimations.prefersReducedMotion(context);

    // Use instant transitions if reduced motion is enabled
    final animationDuration = reducedMotion
        ? Duration.zero
        : const Duration(milliseconds: 200);

    return Semantics(
      button: true,
      label: widget.semanticLabel,
      hint: l10n.accessibilityDragHandleHint,
      child: MouseRegion(
        onEnter: _handleMouseEnter,
        onExit: _handleMouseExit,
        child: GestureDetector(
          onTapDown: _handleTapDown,
          onTapUp: _handleTapUp,
          onTapCancel: _handleTapCancel,
          child: Tooltip(
            message: widget.semanticLabel,
            child: SizedBox(
              width: widget.size,
              height: widget.size,
              child: Center(
                child: AnimatedOpacity(
                  opacity: _opacity,
                  duration: animationDuration,
                  curve: AppAnimations.springCurve,
                  child: ExcludeSemantics(child: _buildGripDots()),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
