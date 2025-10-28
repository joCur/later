import 'package:flutter/material.dart';
import 'package:later_mobile/design_system/tokens/tokens.dart';

/// A reusable skeleton line component for loading states
///
/// Features:
/// - Configurable width and height
/// - Automatic color adaptation for light/dark mode
/// - Rounded corners for visual consistency
/// - Used as building block for skeleton cards
///
/// Usage:
/// ```dart
/// SkeletonLine(
///   width: 200,
///   height: 16,
/// )
/// ```
class SkeletonLine extends StatelessWidget {
  const SkeletonLine({super.key, this.width, this.height = 16});

  /// Width of the skeleton line
  /// If null, takes full available width
  final double? width;

  /// Height of the skeleton line
  /// Default: 16px
  final double height;

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    // Base color based on theme
    final baseColor = isDark ? AppColors.neutral800 : AppColors.neutral200;

    return SizedBox(
      width: width,
      height: height,
      child: Container(
        decoration: BoxDecoration(
          color: baseColor,
          borderRadius: BorderRadius.circular(AppSpacing.radiusXS),
        ),
      ),
    );
  }
}
