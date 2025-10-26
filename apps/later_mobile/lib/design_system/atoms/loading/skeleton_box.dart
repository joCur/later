import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:later_mobile/design_system/tokens/tokens.dart';

/// Shape options for skeleton loaders
enum SkeletonShape {
  /// Rectangular shape with no border radius
  rectangle,

  /// Rounded rectangle with border radius
  roundedRectangle,

  /// Circular shape (width and height should be equal)
  circle,
}

/// A generic skeleton loading widget with shimmer animation.
///
/// Features:
/// - Shimmer animation with gradient sweep (left → right)
/// - Multiple shape variants: rectangle, rounded rectangle, circle
/// - Theme-adaptive colors (neutral-100 light, neutral-800 dark)
/// - Customizable dimensions and border radius
/// - Pre-built factory constructors for common use cases
/// - Performance optimized with RepaintBoundary
///
/// Example usage:
/// ```dart
/// SkeletonLoader() // Default rectangular skeleton
/// SkeletonLoader.text() // Text line skeleton
/// SkeletonLoader.avatar() // Circular avatar skeleton
/// SkeletonLoader.card() // Card skeleton
/// SkeletonLoader(
///   width: 200,
///   height: 50,
///   shape: SkeletonShape.roundedRectangle,
///   borderRadius: 12,
/// )
/// ```
class SkeletonLoader extends StatefulWidget {

  /// Creates a text line skeleton (16px height, full width).
  factory SkeletonLoader.text({
    Key? key,
    double? width,
    double height = 16.0,
  }) {
    return SkeletonLoader(
      key: key,
      width: width,
      height: height,
      borderRadius: 4.0,
    );
  }

  /// Creates a circular avatar skeleton (40px diameter by default).
  factory SkeletonLoader.avatar({
    Key? key,
    double size = 40.0,
  }) {
    return SkeletonLoader(
      key: key,
      width: size,
      height: size,
      shape: SkeletonShape.circle,
    );
  }

  /// Creates a card skeleton with typical card dimensions.
  factory SkeletonLoader.card({
    Key? key,
    double? width,
    double height = 120.0,
  }) {
    return SkeletonLoader(
      key: key,
      width: width,
      height: height,
      borderRadius: AppSpacing.cardRadius,
    );
  }

  /// Creates a list item skeleton with typical list item dimensions.
  factory SkeletonLoader.listItem({
    Key? key,
    double? width,
    double height = 64.0,
  }) {
    return SkeletonLoader(
      key: key,
      width: width,
      height: height,
      borderRadius: 8.0,
    );
  }
  const SkeletonLoader({
    super.key,
    this.width,
    this.height = 16.0,
    this.shape = SkeletonShape.roundedRectangle,
    this.borderRadius,
  });

  /// Width of the skeleton. If null, takes full available width.
  final double? width;

  /// Height of the skeleton.
  final double height;

  /// Shape of the skeleton.
  final SkeletonShape shape;

  /// Border radius for rounded shapes. If null, uses default values.
  final double? borderRadius;

  @override
  State<SkeletonLoader> createState() => _SkeletonLoaderState();
}

class _SkeletonLoaderState extends State<SkeletonLoader>
    with SingleTickerProviderStateMixin {
  late AnimationController _shimmerController;

  @override
  void initState() {
    super.initState();
    _shimmerController = AnimationController(
      duration: AppAnimations.shimmerDuration,
      vsync: this,
    )..repeat();
  }

  @override
  void dispose() {
    _shimmerController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    // Base color: neutral-100 (light mode), neutral-800 (dark mode)
    final baseColor = isDark ? AppColors.neutral800 : AppColors.neutral100;

    // Calculate border radius based on shape
    BorderRadius? effectiveBorderRadius;
    if (widget.shape == SkeletonShape.roundedRectangle) {
      final radius = widget.borderRadius ?? 4.0;
      effectiveBorderRadius = BorderRadius.circular(radius);
    } else if (widget.shape == SkeletonShape.circle) {
      effectiveBorderRadius = BorderRadius.circular(9999);
    }

    return RepaintBoundary(
      child: AnimatedBuilder(
        animation: _shimmerController,
        builder: (context, child) {
          return Container(
            width: widget.width,
            height: widget.height,
            decoration: BoxDecoration(
              color: baseColor,
              borderRadius: effectiveBorderRadius,
            ),
            child: ClipRRect(
              borderRadius: effectiveBorderRadius ?? BorderRadius.zero,
              child: CustomPaint(
                painter: _ShimmerPainter(
                  animation: _shimmerController,
                  baseColor: baseColor,
                  shimmerColor: Colors.white.withValues(alpha: isDark ? 0.05 : 0.3),
                ),
              ),
            ),
          );
        },
      ),
    );
  }
}

/// Custom painter for shimmer effect
class _ShimmerPainter extends CustomPainter {
  _ShimmerPainter({
    required this.animation,
    required this.baseColor,
    required this.shimmerColor,
  }) : super(repaint: animation);

  final Animation<double> animation;
  final Color baseColor;
  final Color shimmerColor;

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..shader = LinearGradient(
        begin: Alignment(-1.0 + animation.value * 3, 0),
        end: Alignment(0.0 + animation.value * 3, 0),
        colors: [
          baseColor,
          shimmerColor,
          baseColor,
        ],
        stops: const [0.0, 0.5, 1.0],
      ).createShader(Rect.fromLTWH(0, 0, size.width, size.height));

    canvas.drawRect(Rect.fromLTWH(0, 0, size.width, size.height), paint);
  }

  @override
  bool shouldRepaint(_ShimmerPainter oldDelegate) {
    return animation != oldDelegate.animation;
  }
}

/// A skeleton loading card that mimics the structure of an ItemCard.
///
/// Features:
/// - Glass morphism background matching ItemCard
/// - Three skeleton loaders for title, content, and metadata
/// - Proper spacing matching ItemCard layout
/// - Theme-adaptive styling
///
/// Used to show loading state for item lists while data is being fetched.
class ItemCardSkeleton extends StatelessWidget {
  const ItemCardSkeleton({super.key});

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Container(
      decoration: BoxDecoration(
        color: isDark ? AppColors.glassDark : AppColors.glassLight,
        borderRadius: BorderRadius.circular(AppSpacing.cardRadius),
      ),
      child: BackdropFilter(
        filter: ImageFilter.blur(
          sigmaX: AppSpacing.glassBlurRadius,
          sigmaY: AppSpacing.glassBlurRadius,
        ),
        child: const Padding(
          padding: EdgeInsets.all(AppSpacing.md),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Title skeleton (20px height, full width)
              SkeletonLoader(
                height: 20,
                width: double.infinity,
              ),
              SizedBox(height: AppSpacing.xs),
              // Content preview skeleton (16px height, 200px width)
              SkeletonLoader(
                width: 200,
              ),
              SizedBox(height: AppSpacing.xs),
              // Metadata skeleton (14px height, 120px width)
              SkeletonLoader(
                height: 14,
                width: 120,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
