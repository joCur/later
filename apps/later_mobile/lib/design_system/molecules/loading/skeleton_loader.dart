import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:later_mobile/design_system/tokens/tokens.dart';

/// A skeleton loading card that mimics the structure of an ItemCard.
///
/// Features:
/// - Glass morphism background
/// - Shimmer animation effect
/// - Matches ItemCard dimensions and layout
/// - Theme-adaptive colors
///
/// Used to show loading state for item lists while data is being fetched.
class SkeletonItemCard extends StatelessWidget {
  const SkeletonItemCard({super.key});

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
        child: Padding(
          padding: const EdgeInsets.all(AppSpacing.md),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Title skeleton
              _buildShimmerBox(
                context,
                height: 20,
                width: double.infinity,
              ),
              const SizedBox(height: AppSpacing.xs),
              // Content preview skeleton
              _buildShimmerBox(
                context,
                height: 16,
                width: 200,
              ),
              const SizedBox(height: AppSpacing.xs),
              // Metadata skeleton
              _buildShimmerBox(
                context,
                height: 14,
                width: 120,
              ),
            ],
          ),
        ),
      ),
    )
        .animate()
        .fadeIn(duration: AppAnimations.quick)
        .shimmer(
          duration: AppAnimations.shimmerDuration,
          color: Colors.white.withValues(alpha: 0.3),
        );
  }

  Widget _buildShimmerBox(
    BuildContext context, {
    required double height,
    required double width,
  }) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Container(
      height: height,
      width: width,
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            Colors.white.withValues(alpha: isDark ? 0.05 : 0.1),
            Colors.white.withValues(alpha: isDark ? 0.15 : 0.3),
            Colors.white.withValues(alpha: isDark ? 0.05 : 0.1),
          ],
        ),
        borderRadius: BorderRadius.circular(4),
      ),
    );
  }
}

/// A list view containing multiple skeleton item cards.
///
/// Features:
/// - Displays specified number of skeleton cards
/// - Proper spacing between items
/// - Scrollable when content overflows
/// - Customizable padding
///
/// Used for list loading states with multiple items.
class SkeletonListView extends StatelessWidget {
  const SkeletonListView({
    super.key,
    this.itemCount = 3,
    this.padding,
  });

  /// Number of skeleton cards to display.
  final int itemCount;

  /// Optional padding around the list.
  final EdgeInsets? padding;

  @override
  Widget build(BuildContext context) {
    return ListView.separated(
      padding: padding ?? const EdgeInsets.all(AppSpacing.md),
      itemCount: itemCount,
      separatorBuilder: (context, index) => const SizedBox(
        height: AppSpacing.sm,
      ),
      itemBuilder: (context, index) {
        return const SkeletonItemCard();
      },
    );
  }
}

/// A skeleton loading view for item detail screens.
///
/// Features:
/// - Header section skeleton with gradient background
/// - Content sections with glass morphism
/// - Metadata section skeletons
/// - Fade in animation
///
/// Used to show loading state for item detail screen while data is being fetched.
class SkeletonDetailView extends StatelessWidget {
  const SkeletonDetailView({super.key});

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return SingleChildScrollView(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header skeleton with gradient
          Container(
            height: 120,
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [
                  AppColors.primaryStart.withValues(alpha: 0.3),
                  AppColors.primaryEnd.withValues(alpha: 0.3),
                ],
              ),
            ),
            child: Padding(
              padding: const EdgeInsets.all(AppSpacing.lg),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  _buildShimmerBox(
                    context,
                    height: 28,
                    width: 250,
                  ),
                  const SizedBox(height: AppSpacing.sm),
                  _buildShimmerBox(
                    context,
                    height: 16,
                    width: 150,
                  ),
                ],
              ),
            ),
          ),
          // Content section skeleton
          Padding(
            padding: const EdgeInsets.all(AppSpacing.lg),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  padding: const EdgeInsets.all(AppSpacing.md),
                  decoration: BoxDecoration(
                    color: isDark ? AppColors.glassDark : AppColors.glassLight,
                    borderRadius: BorderRadius.circular(AppSpacing.cardRadius),
                  ),
                  child: BackdropFilter(
                    filter: ImageFilter.blur(
                      sigmaX: AppSpacing.glassBlurRadius,
                      sigmaY: AppSpacing.glassBlurRadius,
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        _buildShimmerBox(context, height: 20, width: double.infinity),
                        const SizedBox(height: AppSpacing.sm),
                        _buildShimmerBox(context, height: 16, width: double.infinity),
                        const SizedBox(height: AppSpacing.xs),
                        _buildShimmerBox(context, height: 16, width: 300),
                        const SizedBox(height: AppSpacing.xs),
                        _buildShimmerBox(context, height: 16, width: 250),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: AppSpacing.lg),
                // Metadata section
                _buildShimmerBox(context, height: 14, width: 180),
                const SizedBox(height: AppSpacing.xs),
                _buildShimmerBox(context, height: 14, width: 160),
              ],
            ),
          ),
        ],
      ),
    ).animate().fadeIn(duration: AppAnimations.quick);
  }

  Widget _buildShimmerBox(
    BuildContext context, {
    required double height,
    required double width,
  }) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Container(
      height: height,
      width: width,
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            Colors.white.withValues(alpha: isDark ? 0.05 : 0.1),
            Colors.white.withValues(alpha: isDark ? 0.15 : 0.3),
            Colors.white.withValues(alpha: isDark ? 0.05 : 0.1),
          ],
        ),
        borderRadius: BorderRadius.circular(4),
      ),
    );
  }
}

/// A skeleton loading view for the sidebar.
///
/// Features:
/// - Glass morphism background
/// - Multiple space item skeletons
/// - Gradient overlay at top
/// - Fade in animation
///
/// Used to show loading state for sidebar while data is being fetched.
class SkeletonSidebar extends StatelessWidget {
  const SkeletonSidebar({super.key});

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Container(
      decoration: BoxDecoration(
        color: isDark ? AppColors.glassDark : AppColors.glassLight,
      ),
      child: BackdropFilter(
        filter: ImageFilter.blur(
          sigmaX: AppSpacing.glassBlurRadius,
          sigmaY: AppSpacing.glassBlurRadius,
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Gradient header
            Container(
              height: 120,
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [
                    AppColors.primaryStart.withValues(alpha: 0.1),
                    AppColors.primaryEnd.withValues(alpha: 0.05),
                  ],
                ),
              ),
              padding: const EdgeInsets.all(AppSpacing.lg),
              child: Align(
                alignment: Alignment.bottomLeft,
                child: _buildShimmerBox(
                  context,
                  height: 24,
                  width: 150,
                ),
              ),
            ),
            // Space items
            Expanded(
              child: ListView.builder(
                padding: const EdgeInsets.all(AppSpacing.md),
                itemCount: 5,
                itemBuilder: (context, index) {
                  return Padding(
                    padding: const EdgeInsets.only(bottom: AppSpacing.sm),
                    child: _buildShimmerBox(
                      context,
                      height: 48,
                      width: double.infinity,
                    ),
                  );
                },
              ),
            ),
          ],
        ),
      ),
    ).animate().fadeIn(duration: AppAnimations.quick);
  }

  Widget _buildShimmerBox(
    BuildContext context, {
    required double height,
    required double width,
  }) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Container(
      height: height,
      width: width,
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            Colors.white.withValues(alpha: isDark ? 0.05 : 0.1),
            Colors.white.withValues(alpha: isDark ? 0.15 : 0.3),
            Colors.white.withValues(alpha: isDark ? 0.05 : 0.1),
          ],
        ),
        borderRadius: BorderRadius.circular(8),
      ),
    );
  }
}
