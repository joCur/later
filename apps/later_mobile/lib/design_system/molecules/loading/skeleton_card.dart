import 'package:flutter/material.dart';
import 'package:later_mobile/core/responsive/breakpoints.dart';
import 'package:later_mobile/design_system/atoms/loading/skeleton_line.dart';
import 'package:later_mobile/design_system/tokens/tokens.dart';
import 'package:shimmer/shimmer.dart';

/// A skeleton card component that mimics the ItemCard layout
///
/// Features (Mobile-First Phase 4):
/// - Shimmer animation with 1200ms duration
/// - Matches ItemCard structure (leading element, title, content, metadata)
/// - Automatic color adaptation for light/dark mode
/// - Respects reduce-motion accessibility preferences
/// - Smooth 60fps animation performance
///
/// Design Specifications (Mobile-First):
/// - Shimmer duration: 1200ms
/// - Border radius: 20px (pill shape, matching cards)
/// - Height: ~120px (typical card height)
/// - Spacing: 16px between skeletons
/// - Base color: AppColors.neutral200 (light) / surfaceDarkVariant (dark)
/// - Highlight color: AppColors.neutral100 (light) / surfaceDark (dark)
///
/// Usage:
/// ```dart
/// ListView.builder(
///   itemCount: isLoading ? 5 : items.length,
///   itemBuilder: (context, index) {
///     if (isLoading) {
///       return SkeletonCard();
///     }
///     return ItemCard(item: items[index]);
///   },
/// )
/// ```
class SkeletonCard extends StatelessWidget {
  const SkeletonCard({super.key});

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final isMobile = context.isMobile;

    // Shimmer colors based on theme
    final baseColor = isDark
        ? AppColors.neutral800
        : AppColors.neutral200;
    final highlightColor = isDark
        ? AppColors.neutral900
        : AppColors.neutral100;

    // Check for reduce motion preference
    final disableAnimations = MediaQuery.of(context).disableAnimations;

    // Card background color
    final backgroundColor = isDark
        ? AppColors.neutral900
        : Colors.white;

    return Container(
      margin: const EdgeInsets.only(
        bottom: AppSpacing.md,
      ), // Mobile-first: 16px spacing between skeletons
      decoration: BoxDecoration(
        color: backgroundColor,
        borderRadius: BorderRadius.circular(
          20,
        ), // Mobile-first: 20px border radius (pill shape)
        boxShadow: [
          BoxShadow(
            color: isDark ? AppColors.shadowDark : AppColors.shadowLight,
            blurRadius: 3,
            offset: const Offset(0, 1),
          ),
        ],
      ),
      child: Padding(
        padding: const EdgeInsets.all(
          AppSpacing.cardPaddingMobile,
        ), // Mobile-first: 20px padding matching cards
        child: disableAnimations
            ? _buildCardContent(context, isMobile)
            : Shimmer(
                gradient: LinearGradient(
                  colors: [baseColor, highlightColor, baseColor],
                  stops: const [0.0, 0.5, 1.0],
                  begin: const Alignment(-1.0, -0.3),
                  end: const Alignment(1.0, 0.3),
                ),
                period: const Duration(milliseconds: 1200),
                child: _buildCardContent(context, isMobile),
              ),
      ),
    );
  }

  /// Build the card content structure
  Widget _buildCardContent(BuildContext context, bool isMobile) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Leading element space (mimics checkbox/icon)
        _buildLeadingElement(),
        const SizedBox(width: AppSpacing.xxs),

        // Content
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              // Title line (mimics H4 typography)
              const SkeletonLine(height: 24),
              const SizedBox(height: AppSpacing.xxs),

              // Content preview lines (2-3 lines)
              SkeletonLine(
                height: 20,
                width: isMobile ? double.infinity : null,
              ),
              const SizedBox(height: AppSpacing.xxs),
              SkeletonLine(height: 20, width: isMobile ? 250 : 300),
              if (!isMobile) ...[
                const SizedBox(height: AppSpacing.xxs),
                const SkeletonLine(height: 20, width: 200),
              ],

              // Metadata row (mimics date/time info)
              const SizedBox(height: AppSpacing.xxs),
              const SkeletonLine(width: 120),
            ],
          ),
        ),
      ],
    );
  }

  /// Build the leading element (mimics checkbox or icon)
  Widget _buildLeadingElement() {
    return SizedBox(
      width: 48,
      height: 48,
      child: Center(
        child: Container(
          width: 24,
          height: 24,
          decoration: BoxDecoration(
            color: Colors.transparent,
            borderRadius: BorderRadius.circular(AppSpacing.radiusSM),
            border: Border.all(
              color: Colors.grey.withValues(alpha: 0.3),
              width: 2,
            ),
          ),
        ),
      ),
    );
  }
}
