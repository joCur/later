import 'package:flutter/material.dart';
import 'package:later_mobile/core/theme/app_spacing.dart';

/// A custom widget that draws a gradient border around its child.
///
/// This widget is optimized for the mobile-first bold redesign with:
/// - 6px gradient border width (3x more visible than 2px)
/// - 20px border radius (pill shape)
/// - Performance-optimized with RepaintBoundary
/// - Supports any gradient (type-specific colors)
///
/// Example usage:
/// ```dart
/// GradientPillBorder(
///   gradient: AppColors.taskGradient,
///   child: Container(
///     padding: EdgeInsets.all(20),
///     child: Text('Task Card'),
///   ),
/// )
/// ```
class GradientPillBorder extends StatelessWidget {

  const GradientPillBorder({
    super.key,
    required this.gradient,
    required this.child,
    this.borderWidth = AppSpacing.cardBorderWidth,
    this.borderRadius = AppSpacing.cardRadius,
  });
  /// The gradient to use for the border
  final Gradient gradient;

  /// The child widget to wrap with the gradient border
  final Widget child;

  /// Border width (defaults to 6px for mobile-first bold design)
  final double borderWidth;

  /// Border radius (defaults to 20px for pill shape)
  final double borderRadius;

  @override
  Widget build(BuildContext context) {
    return RepaintBoundary(
      child: CustomPaint(
        painter: _GradientBorderPainter(
          gradient: gradient,
          borderWidth: borderWidth,
          borderRadius: borderRadius,
        ),
        child: Padding(
          padding: EdgeInsets.all(borderWidth),
          child: child,
        ),
      ),
    );
  }
}

/// Custom painter that draws the gradient border.
///
/// This painter is optimized for performance:
/// - Uses a single path for the border
/// - Applies gradient via shader
/// - Minimal repaints with RepaintBoundary
class _GradientBorderPainter extends CustomPainter {

  _GradientBorderPainter({
    required this.gradient,
    required this.borderWidth,
    required this.borderRadius,
  });
  final Gradient gradient;
  final double borderWidth;
  final double borderRadius;

  @override
  void paint(Canvas canvas, Size size) {
    // Create the border path with rounded corners
    final rect = Rect.fromLTWH(
      borderWidth / 2,
      borderWidth / 2,
      size.width - borderWidth,
      size.height - borderWidth,
    );

    final rrect = RRect.fromRectAndRadius(
      rect,
      Radius.circular(borderRadius),
    );

    // Create paint with gradient shader
    final paint = Paint()
      ..shader = gradient.createShader(Offset.zero & size)
      ..style = PaintingStyle.stroke
      ..strokeWidth = borderWidth
      ..strokeCap = StrokeCap.round
      ..strokeJoin = StrokeJoin.round;

    // Draw the gradient border
    canvas.drawRRect(rrect, paint);
  }

  @override
  bool shouldRepaint(covariant _GradientBorderPainter oldDelegate) {
    return gradient != oldDelegate.gradient ||
        borderWidth != oldDelegate.borderWidth ||
        borderRadius != oldDelegate.borderRadius;
  }
}
