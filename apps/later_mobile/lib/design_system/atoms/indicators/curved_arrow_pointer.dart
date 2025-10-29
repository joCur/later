import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:later_mobile/core/theme/temporal_flow_theme.dart';
import 'package:later_mobile/design_system/tokens/tokens.dart';

/// A curved arrow pointer component that draws an animated arrow
/// pointing from a start position to an end position using a smooth Bezier curve.
///
/// Features:
/// - Custom painted curved arrow using quadratic Bezier curves
/// - Animated entrance: fade in + draw animation along curve path
/// - Arrow head automatically rotates to align with curve tangent
/// - Configurable colors, stroke width, and arrow head size
/// - Respects reduced motion preferences
/// - Theme-aware coloring using primary gradient
///
/// Usage:
/// ```dart
/// CurvedArrowPointer(
///   startPosition: Offset(100, 200),
///   endPosition: Offset(300, 400),
/// )
/// ```
class CurvedArrowPointer extends StatelessWidget {
  const CurvedArrowPointer({
    super.key,
    required this.startPosition,
    required this.endPosition,
    this.color,
    this.strokeWidth = 12.0,
    this.arrowHeadSize = 36.0,
    this.animate = true,
  });

  /// The starting position of the arrow (typically near the empty state text)
  final Offset startPosition;

  /// The ending position of the arrow (typically pointing to FAB)
  final Offset endPosition;

  /// The color of the arrow. If null, uses theme's primary gradient color at 60% opacity
  final Color? color;

  /// The width of the arrow stroke
  final double strokeWidth;

  /// The size of the arrow head
  final double arrowHeadSize;

  /// Whether to animate the arrow entrance
  final bool animate;

  @override
  Widget build(BuildContext context) {
    final temporalTheme = Theme.of(context).extension<TemporalFlowTheme>()!;
    final arrowColor = color ?? temporalTheme.primaryGradient.colors.first.withValues(alpha: 0.85);

    final arrow = CustomPaint(
      painter: _CurvedArrowPainter(
        startPosition: startPosition,
        endPosition: endPosition,
        color: arrowColor,
        strokeWidth: strokeWidth,
        arrowHeadSize: arrowHeadSize,
      ),
      size: Size.infinite,
    );

    if (!animate || AppAnimations.prefersReducedMotion(context)) {
      // No animation - show arrow immediately
      return arrow;
    }

    // Animated entrance: fade in + draw animation
    return arrow
        .animate()
        .fadeIn(
          duration: AppAnimations.gentle,
          curve: AppAnimations.gentleSpringCurve,
        )
        .custom(
          duration: AppAnimations.gentle,
          curve: AppAnimations.smoothSpringCurve,
          builder: (context, value, child) {
            return CustomPaint(
              painter: _CurvedArrowPainter(
                startPosition: startPosition,
                endPosition: endPosition,
                color: arrowColor,
                strokeWidth: strokeWidth,
                arrowHeadSize: arrowHeadSize,
                drawProgress: value,
              ),
              size: Size.infinite,
            );
          },
        );
  }
}

/// Custom painter for drawing the curved arrow
class _CurvedArrowPainter extends CustomPainter {
  _CurvedArrowPainter({
    required this.startPosition,
    required this.endPosition,
    required this.color,
    required this.strokeWidth,
    required this.arrowHeadSize,
    this.drawProgress = 1.0,
  });

  final Offset startPosition;
  final Offset endPosition;
  final Color color;
  final double strokeWidth;
  final double arrowHeadSize;
  final double drawProgress;

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = color
      ..strokeWidth = strokeWidth
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.round
      ..strokeJoin = StrokeJoin.round;

    // Calculate control point for quadratic Bezier curve
    // The control point is offset vertically and horizontally to create a natural curve
    final midX = (startPosition.dx + endPosition.dx) / 2;
    final midY = (startPosition.dy + endPosition.dy) / 2;

    // Offset control point to create curved path
    // Use perpendicular offset for a more pronounced curve
    final dx = endPosition.dx - startPosition.dx;
    final dy = endPosition.dy - startPosition.dy;

    // Create perpendicular vector and scale it for curve amount
    // This makes the curve bow to the side instead of just shifting the midpoint
    final perpX = -dy * 0.25;  // Perpendicular to the line direction
    final perpY = dx * 0.25;

    final controlPoint = Offset(midX + perpX, midY + perpY);

    // Create the curved path
    final path = Path()
      ..moveTo(startPosition.dx, startPosition.dy)
      ..quadraticBezierTo(
        controlPoint.dx,
        controlPoint.dy,
        endPosition.dx,
        endPosition.dy,
      );

    // Apply draw progress animation
    if (drawProgress < 1.0) {
      final metrics = path.computeMetrics().first;
      final extractPath = metrics.extractPath(
        0.0,
        metrics.length * drawProgress,
      );
      canvas.drawPath(extractPath, paint);

      // Only draw arrow head when path is mostly drawn
      if (drawProgress > 0.8) {
        final arrowHeadProgress = (drawProgress - 0.8) / 0.2;
        _drawArrowHead(canvas, paint, path, arrowHeadProgress);
      }
    } else {
      // Draw full path
      canvas.drawPath(path, paint);
      _drawArrowHead(canvas, paint, path, 1.0);
    }
  }

  void _drawArrowHead(Canvas canvas, Paint paint, Path path, double progress) {
    // Get the tangent at the end of the path to align arrow head
    final metrics = path.computeMetrics().first;
    final tangent = metrics.getTangentForOffset(metrics.length);

    if (tangent == null) return;

    final arrowHeadPaint = Paint()
      ..color = color.withValues(alpha: color.a * progress)
      ..style = PaintingStyle.fill;

    // Calculate arrow head angle from tangent
    final angle = math.atan2(tangent.vector.dy, tangent.vector.dx);

    // Draw arrow head as a triangle
    final arrowPath = Path();
    final tipPoint = tangent.position;

    // Left point of arrow head (wider angle for more prominent arrow)
    final leftPoint = Offset(
      tipPoint.dx - arrowHeadSize * math.cos(angle - math.pi / 4.5),
      tipPoint.dy - arrowHeadSize * math.sin(angle - math.pi / 4.5),
    );

    // Right point of arrow head (wider angle for more prominent arrow)
    final rightPoint = Offset(
      tipPoint.dx - arrowHeadSize * math.cos(angle + math.pi / 4.5),
      tipPoint.dy - arrowHeadSize * math.sin(angle + math.pi / 4.5),
    );

    arrowPath.moveTo(tipPoint.dx, tipPoint.dy);
    arrowPath.lineTo(leftPoint.dx, leftPoint.dy);
    arrowPath.lineTo(rightPoint.dx, rightPoint.dy);
    arrowPath.close();

    canvas.drawPath(arrowPath, arrowHeadPaint);
  }

  @override
  bool shouldRepaint(covariant _CurvedArrowPainter oldDelegate) {
    return oldDelegate.startPosition != startPosition ||
        oldDelegate.endPosition != endPosition ||
        oldDelegate.color != color ||
        oldDelegate.strokeWidth != strokeWidth ||
        oldDelegate.arrowHeadSize != arrowHeadSize ||
        oldDelegate.drawProgress != drawProgress;
  }
}
