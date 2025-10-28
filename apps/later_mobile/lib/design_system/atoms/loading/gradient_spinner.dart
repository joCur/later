import 'dart:math';
import 'package:flutter/material.dart';
import 'package:later_mobile/core/theme/temporal_flow_theme.dart';
import 'package:later_mobile/design_system/tokens/tokens.dart';

/// A custom circular progress indicator with gradient colors.
///
/// Features:
/// - Gradient arc (75% of circle) that rotates continuously
/// - Four size variants: small (16px), medium (24px), large (48px)
/// - Optional pulsing animation for emphasis
/// - Customizable gradient and stroke width
/// - Smooth rotation animation (1000ms duration)
/// - Theme-adaptive gradient colors
/// - Performance optimized with RepaintBoundary
///
/// Example usage:
/// ```dart
/// GradientSpinner() // Default 48px
/// GradientSpinner.small() // 16px for inline loading
/// GradientSpinner.medium() // 24px for standard loading
/// GradientSpinner.large() // 48px for full-screen loading
/// GradientSpinner.pulsing() // With pulsing animation
/// GradientSpinner(
///   size: 60,
///   strokeWidth: 5,
///   gradient: AppColors.secondaryGradient,
/// )
/// ```
class GradientSpinner extends StatefulWidget {
  /// Creates a small spinner (16px) for inline loading states.
  const GradientSpinner.small({
    super.key,
    this.strokeWidth = 2.0,
    this.gradient,
    this.pulsing = false,
  }) : size = 16.0;

  /// Creates a medium spinner (24px) for standard loading states.
  const GradientSpinner.medium({
    super.key,
    this.strokeWidth = 3.0,
    this.gradient,
    this.pulsing = false,
  }) : size = 24.0;

  /// Creates a large spinner (48px) for full-screen loading states.
  const GradientSpinner.large({
    super.key,
    this.strokeWidth = 4.0,
    this.gradient,
    this.pulsing = false,
  }) : size = 48.0;

  /// Creates a spinner with pulsing animation for emphasis.
  const GradientSpinner.pulsing({
    super.key,
    this.size = 48.0,
    this.strokeWidth = 4.0,
    this.gradient,
  }) : pulsing = true;
  const GradientSpinner({
    super.key,
    this.size = 48.0,
    this.strokeWidth = 4.0,
    this.gradient,
    this.pulsing = false,
  });

  /// The diameter of the spinner in logical pixels.
  final double size;

  /// The width of the spinner arc stroke.
  final double strokeWidth;

  /// The gradient to apply to the spinner.
  ///
  /// If null, uses the theme-adaptive primary gradient.
  final Gradient? gradient;

  /// Whether to add a pulsing scale animation for emphasis.
  final bool pulsing;

  @override
  State<GradientSpinner> createState() => _GradientSpinnerState();
}

class _GradientSpinnerState extends State<GradientSpinner>
    with TickerProviderStateMixin {
  late AnimationController _rotationController;
  late AnimationController _pulseController;
  late Animation<double> _pulseAnimation;

  @override
  void initState() {
    super.initState();

    // Rotation animation
    _rotationController = AnimationController(
      duration: AppAnimations.spinnerRotation,
      vsync: this,
    )..repeat();

    // Pulsing animation (optional)
    _pulseController = AnimationController(
      duration: const Duration(milliseconds: 1500),
      vsync: this,
    );

    _pulseAnimation = TweenSequence<double>([
      TweenSequenceItem(
        tween: Tween<double>(
          begin: 1.0,
          end: 1.15,
        ).chain(CurveTween(curve: Curves.easeOut)),
        weight: 50.0,
      ),
      TweenSequenceItem(
        tween: Tween<double>(
          begin: 1.15,
          end: 1.0,
        ).chain(CurveTween(curve: Curves.easeIn)),
        weight: 50.0,
      ),
    ]).animate(_pulseController);

    if (widget.pulsing) {
      _pulseController.repeat();
    }
  }

  @override
  void dispose() {
    _rotationController.dispose();
    _pulseController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final temporalTheme = Theme.of(context).extension<TemporalFlowTheme>()!;
    final gradient = widget.gradient ?? temporalTheme.primaryGradient;

    Widget spinner = RepaintBoundary(
      child: SizedBox(
        width: widget.size,
        height: widget.size,
        child: AnimatedBuilder(
          animation: _rotationController,
          builder: (context, child) {
            return Transform.rotate(
              angle: _rotationController.value * 2 * pi,
              child: CustomPaint(
                painter: _GradientSpinnerPainter(
                  gradient: gradient,
                  strokeWidth: widget.strokeWidth,
                ),
              ),
            );
          },
        ),
      ),
    );

    // Add pulsing animation if enabled
    if (widget.pulsing) {
      spinner = AnimatedBuilder(
        animation: _pulseAnimation,
        builder: (context, child) {
          return Transform.scale(scale: _pulseAnimation.value, child: child);
        },
        child: spinner,
      );
    }

    return spinner;
  }
}

/// Custom painter that draws a gradient arc for the spinner.
///
/// Draws 75% of a circle (270 degrees) with a gradient stroke.
/// The arc starts at -90 degrees (top of circle) and sweeps clockwise.
class _GradientSpinnerPainter extends CustomPainter {
  _GradientSpinnerPainter({required this.gradient, required this.strokeWidth});

  final Gradient gradient;
  final double strokeWidth;

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    final radius = (size.width - strokeWidth) / 2;

    // Create rect for the arc
    final rect = Rect.fromCircle(center: center, radius: radius);

    // Create gradient shader
    final shader = gradient.createShader(rect);

    // Create paint with gradient
    final paint = Paint()
      ..shader = shader
      ..style = PaintingStyle.stroke
      ..strokeWidth = strokeWidth
      ..strokeCap = StrokeCap.round;

    // Draw arc (75% of circle = 270 degrees = 1.5 * pi radians)
    // Start at -90 degrees (top) and sweep 270 degrees clockwise
    const startAngle = -pi / 2; // -90 degrees
    const sweepAngle = pi * 1.5; // 270 degrees

    canvas.drawArc(rect, startAngle, sweepAngle, false, paint);
  }

  @override
  bool shouldRepaint(_GradientSpinnerPainter oldDelegate) {
    return oldDelegate.gradient != gradient ||
        oldDelegate.strokeWidth != strokeWidth;
  }
}
