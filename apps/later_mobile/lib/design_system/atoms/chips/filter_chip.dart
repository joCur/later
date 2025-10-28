import 'package:flutter/material.dart';
import 'package:later_mobile/core/theme/temporal_flow_theme.dart';
import 'package:later_mobile/design_system/tokens/tokens.dart';

/// A pill-shaped filter chip component with gradient border when selected
///
/// Features:
/// - Gradient border (2px) when selected, solid border (1px) when unselected
/// - Scale animation on tap (1.0 → 1.05 → 1.0 over 200ms)
/// - Haptic feedback on selection
/// - Optional icon support
/// - Theme-aware colors (light/dark mode)
/// - Pill-shaped border radius (20px)
/// - Fixed height (36px) with horizontal padding (16px)
/// - Medium weight font (14px)
///
/// Used for filtering content in lists, grids, and other collection views.
/// Provides clear visual feedback for selection state with smooth animations.
///
/// Example:
/// ```dart
/// TemporalFilterChip(
///   label: 'All',
///   isSelected: selectedFilter == FilterType.all,
///   onSelected: () => setState(() => selectedFilter = FilterType.all),
///   icon: Icons.grid_view_rounded,
/// )
/// ```
///
/// Animation behavior:
/// - Tap triggers scale animation from 1.0 → 1.05 → 1.0
/// - Animation uses easeOut for expansion, easeIn for contraction
/// - Light haptic feedback on tap (mobile only)
///
/// Visual states:
/// - **Selected**: 2px gradient border around transparent background, primary text color
/// - **Unselected**: 1px neutral border, transparent background, secondary text color
///
/// Note: Named `TemporalFilterChip` to avoid conflict with Flutter's built-in FilterChip.
class TemporalFilterChip extends StatefulWidget {
  const TemporalFilterChip({
    super.key,
    required this.label,
    required this.isSelected,
    required this.onSelected,
    this.icon,
  });

  /// The text label displayed in the chip
  final String label;

  /// Whether this chip is currently selected
  final bool isSelected;

  /// Callback invoked when the chip is tapped
  final VoidCallback onSelected;

  /// Optional icon displayed before the label (16px size)
  final IconData? icon;

  @override
  State<TemporalFilterChip> createState() => _TemporalFilterChipState();
}

class _TemporalFilterChipState extends State<TemporalFilterChip>
    with SingleTickerProviderStateMixin {
  late AnimationController _animationController;
  late Animation<double> _scaleAnimation;

  @override
  void initState() {
    super.initState();

    // Initialize animation controller for selection animation
    _animationController = AnimationController(
      duration: const Duration(milliseconds: 200),
      vsync: this,
    );

    // Create scale animation: 1.0 -> 1.05 -> 1.0
    _scaleAnimation = TweenSequence<double>([
      TweenSequenceItem(
        tween: Tween<double>(
          begin: 1.0,
          end: 1.05,
        ).chain(CurveTween(curve: Curves.easeOut)),
        weight: 50.0,
      ),
      TweenSequenceItem(
        tween: Tween<double>(
          begin: 1.05,
          end: 1.0,
        ).chain(CurveTween(curve: Curves.easeIn)),
        weight: 50.0,
      ),
    ]).animate(_animationController);
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  void _handleTap() {
    // Trigger scale animation and haptic feedback on selection
    _animationController.forward(from: 0.0);
    AppAnimations.lightHaptic();
    widget.onSelected();
  }

  @override
  Widget build(BuildContext context) {
    // Pill-shaped chips with gradient border when selected
    // Selected: 2px gradient border (not full background)
    // Unselected: 1px solid border (neutral)
    // Height: 36px, padding: 16px horizontal
    // Font: 14px medium weight

    // Wrap with AnimatedBuilder for scale animation
    return AnimatedBuilder(
      animation: _scaleAnimation,
      builder: (context, child) {
        return Transform.scale(scale: _scaleAnimation.value, child: child);
      },
      child: _buildChipContent(),
    );
  }

  Widget _buildChipContent() {
    final temporalTheme = Theme.of(context).extension<TemporalFlowTheme>()!;
    final isDark = Theme.of(context).brightness == Brightness.dark;

    if (widget.isSelected) {
      return Container(
        height: 36,
        decoration: BoxDecoration(
          gradient: temporalTheme.primaryGradient,
          borderRadius: BorderRadius.circular(20), // Pill shape
        ),
        child: Container(
          margin: const EdgeInsets.all(2), // 2px border width
          decoration: BoxDecoration(
            color: temporalTheme.glassBackground,
            borderRadius: BorderRadius.circular(18), // 20 - 2 = 18
          ),
          child: Material(
            color: Colors.transparent,
            child: InkWell(
              onTap: _handleTap,
              borderRadius: BorderRadius.circular(18),
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: AppSpacing.md),
                child: Center(
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      if (widget.icon != null) ...[
                        Icon(
                          widget.icon,
                          size: 16,
                          color: isDark
                              ? AppColors.neutral400
                              : AppColors.neutral600,
                        ),
                        const SizedBox(width: 6),
                      ],
                      Text(
                        widget.label,
                        style: AppTypography.labelLarge.copyWith(
                          fontWeight:
                              AppTypography.medium, // medium weight override
                          color: isDark
                              ? AppColors.neutral400
                              : AppColors.neutral600,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ),
      );
    }

    // Unselected state - 1px solid border
    return Container(
      height: 36,
      decoration: BoxDecoration(
        border: Border.all(
          color: isDark
              ? AppColors.neutral600.withValues(alpha: 0.3)
              : AppColors.neutral400.withValues(alpha: 0.3),
        ),
        borderRadius: BorderRadius.circular(20), // Pill shape
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: _handleTap,
          borderRadius: BorderRadius.circular(20),
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: AppSpacing.md),
            child: Center(
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  if (widget.icon != null) ...[
                    Icon(
                      widget.icon,
                      size: 16,
                      color: isDark
                          ? AppColors.neutral500
                          : AppColors.neutral500,
                    ),
                    const SizedBox(width: 6),
                  ],
                  Text(
                    widget.label,
                    style: AppTypography.labelLarge.copyWith(
                      fontWeight:
                          AppTypography.medium, // medium weight override
                      color: isDark
                          ? AppColors.neutral500
                          : AppColors.neutral500,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
