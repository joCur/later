import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:later_mobile/design_system/tokens/tokens.dart';
import '../../../data/models/item_model.dart';
import '../text/gradient_text.dart';
import '../borders/gradient_pill_border.dart';
import 'package:intl/intl.dart';

/// Item card component for Notes (dual-model architecture)
/// Mobile-First Bold Redesign
///
/// IMPORTANT: This card is for the Item model (Notes) only in the dual-model architecture.
/// TodoList and ListModel will have their own dedicated card components.
///
/// Performance optimizations:
/// - Uses RepaintBoundary to isolate repaints
/// - Const constructors where possible
/// - ValueKey for efficient list updates
/// - Optimized 6px gradient border for 60fps performance
///
/// Mobile-First Bold Design Features:
/// - 6px gradient pill border (3× more visible than 2px) wrapping entire card
/// - 20px border radius (pill shape, not 12px rounded)
/// - 18px bold title (12.5% larger + bold weight for scannability)
/// - 15px content preview (improved readability)
/// - 20px card padding (comfortable thumb zones)
/// - Solid background (no gradient overlay for 60fps performance)
/// - Note gradient colors: Blue→Cyan
/// - Leading element: note icon
/// - Content preview: 2 lines with ellipsis for consistent height
/// - Metadata row: date with gradient text
/// - States: default, pressed, selected
/// - Gesture handlers: tap to open, long-press for multi-select
class ItemCard extends StatefulWidget {
  const ItemCard({
    super.key,
    required this.item,
    this.onTap,
    this.onLongPress,
    this.isSelected = false,
    this.showMetadata = true,
    this.index,
  });

  /// Item data to display
  final Item item;

  /// Callback when card is tapped
  final VoidCallback? onTap;

  /// Callback when card is long-pressed
  final VoidCallback? onLongPress;

  /// Whether card is in selected state
  final bool isSelected;

  /// Whether to show metadata row
  final bool showMetadata;

  /// Index in the list for staggered entrance animation
  /// If null, no entrance animation is applied
  final int? index;

  @override
  State<ItemCard> createState() => _ItemCardState();
}

class _ItemCardState extends State<ItemCard> with TickerProviderStateMixin {
  bool _isPressed = false;
  late AnimationController _pressAnimationController;
  late Animation<double> _pressScaleAnimation;

  @override
  void initState() {
    super.initState();

    // Initialize press animation controller for Phase 5 micro-interaction
    _pressAnimationController = AnimationController(
      duration: AppAnimations.itemPress,
      vsync: this,
    );

    // Create press scale animation: 1.0 -> 0.98 (scale down on press)
    _pressScaleAnimation = Tween<double>(
      begin: 1.0,
      end: AppAnimations.itemPressScale,
    ).animate(CurvedAnimation(
      parent: _pressAnimationController,
      curve: Curves.easeOut,
      reverseCurve: Curves.easeOutBack,
    ));
  }

  @override
  void dispose() {
    _pressAnimationController.dispose();
    super.dispose();
  }

  /// Get border gradient for notes
  LinearGradient _getBorderGradient() {
    // Item model represents Notes in dual-model architecture
    return AppColors.noteGradient;
  }

  /// Get background color with subtle gradient tint (5% opacity)
  Color _getBackgroundTint(bool isDark) {
    return AppColors.typeLightBg(
      'note',
      isDark: isDark,
    );
  }

  /// Get leading icon for notes
  IconData _getLeadingIcon() {
    return Icons.description_outlined;
  }

  /// Build leading element (icon for notes)
  Widget _buildLeadingElement() {
    // Item model represents Notes - use note icon
    final gradient = _getBorderGradient();

    return SizedBox(
      width: 48,
      height: 48,
      child: Center(
        child: ShaderMask(
          shaderCallback: (bounds) => gradient.createShader(bounds),
          child: Icon(
            _getLeadingIcon(),
            size: 20,
            color: Colors.white, // Base color for shader mask
          ),
        ),
      ),
    );
  }

  /// Build title with proper styling
  Widget _buildTitle(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Text(
      widget.item.title,
      style: AppTypography.itemTitle.copyWith(
        color: isDark ? AppColors.textPrimaryDark : AppColors.textPrimaryLight,
      ),
      maxLines: AppTypography.itemTitleMaxLines,
      overflow: TextOverflow.ellipsis,
    );
  }

  /// Build content preview for notes
  Widget? _buildContentPreview(BuildContext context) {
    if (widget.item.content == null || widget.item.content!.isEmpty) {
      return null;
    }

    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Text(
      widget.item.content!,
      style: AppTypography.itemContent.copyWith(
        color: isDark ? AppColors.textSecondaryDark : AppColors.textSecondaryLight,
      ),
      maxLines: 2, // Fixed 2 lines for consistent card height (mobile-first design)
      overflow: TextOverflow.ellipsis,
    );
  }

  /// Build metadata row
  Widget? _buildMetadata(BuildContext context) {
    if (!widget.showMetadata) return null;

    final dateFormat = DateFormat('MMM d, y');

    return Row(
      children: [
        // Icon with gradient tint for created dates
        ShaderMask(
          shaderCallback: (bounds) => AppColors.primaryGradientAdaptive(context).createShader(bounds),
          blendMode: BlendMode.srcIn,
          child: const Icon(
            Icons.access_time,
            size: 12,
            color: Colors.white,
          ),
        ),
        const SizedBox(width: AppSpacing.xxxs),
        // Created date with subtle primary gradient
        GradientText.subtle(
          dateFormat.format(widget.item.createdAt),
          style: AppTypography.metadata,
        ),
      ],
    );
  }

  void _handleTapDown(TapDownDetails details) {
    setState(() => _isPressed = true);
    // Phase 5: Animate scale down on press (100ms)
    _pressAnimationController.forward();
    // Light haptic on card press
    AppAnimations.lightHaptic();
  }

  void _handleTapUp(TapUpDetails details) {
    setState(() => _isPressed = false);
    // Phase 5: Spring back animation (150ms with easeOutBack curve)
    _pressAnimationController.reverse();
  }

  void _handleTapCancel() {
    setState(() => _isPressed = false);
    // Reset animation on cancel
    _pressAnimationController.reverse();
  }

  void _handleTap() {
    widget.onTap?.call();
  }

  void _handleLongPress() {
    // Medium haptic for long press (multi-select)
    AppAnimations.mediumHaptic();
    widget.onLongPress?.call();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    // Base background color with subtle gradient tint (5% opacity)
    final baseBgColor = isDark ? AppColors.surfaceDark : AppColors.surfaceLight;
    final tintColor = _getBackgroundTint(isDark);

    // Background color based on state with glass morphism for hover/selected
    Color backgroundColor;
    if (widget.isSelected) {
      // Glass morphism overlay (3% opacity) for selected state
      backgroundColor = isDark
          ? AppColors.glass(context).withValues(alpha: 0.03)
          : AppColors.glass(context).withValues(alpha: 0.03);
    } else if (_isPressed) {
      backgroundColor = isDark
          ? AppColors.surfaceDarkVariant
          : AppColors.neutralGray100;
    } else {
      // Blend base color with subtle type-specific tint
      backgroundColor = Color.alphaBlend(
        tintColor.withValues(alpha: 0.05),
        baseBgColor,
      );
    }

    // Notes don't have completion status - always full opacity
    const opacity = 1.0;

    // Build the card widget with mobile-first bold design
    // Phase 5: Wrap with AnimatedBuilder for press scale animation
    final cardWidget = RepaintBoundary(
      child: AnimatedBuilder(
        animation: _pressScaleAnimation,
        builder: (context, child) {
          return Transform.scale(
            scale: _pressScaleAnimation.value,
            child: child,
          );
        },
        child: Semantics(
          container: true,
          button: true,
          enabled: widget.onTap != null,
          label: 'Note: ${widget.item.title}',
          child: GestureDetector(
            onTapDown: _handleTapDown,
            onTapUp: _handleTapUp,
            onTapCancel: _handleTapCancel,
            onTap: _handleTap,
            onLongPress: _handleLongPress,
            child: Opacity(
              opacity: opacity,
              child: Container(
              margin: const EdgeInsets.only(bottom: AppSpacing.cardSpacing), // 16px spacing
              // Wrap entire card with gradient pill border (6px width, 20px radius)
              child: GradientPillBorder(
                gradient: _getBorderGradient(),
                child: Container(
                  decoration: BoxDecoration(
                    color: backgroundColor,
                    borderRadius: BorderRadius.circular(AppSpacing.cardRadius - AppSpacing.cardBorderWidth), // Inner radius reduced by border width to maintain consistent corner appearance
                    // Mobile-optimized shadow: 4px offset, 8px blur, 12% opacity
                    boxShadow: _isPressed
                        ? null
                        : [
                            BoxShadow(
                              color: (isDark ? AppColors.shadowDark : AppColors.shadowLight)
                                  .withValues(alpha: 0.12),
                              blurRadius: 8,
                              offset: const Offset(0, 4),
                            ),
                          ],
                  ),
                  // Clip the content to follow the border radius
                  clipBehavior: Clip.antiAlias,
                  // Main content with 20px padding (mobile-first comfortable touch zones)
                  padding: const EdgeInsets.all(AppSpacing.cardPaddingMobile), // 20px
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Leading element (checkbox or icon)
                      _buildLeadingElement(),
                      const SizedBox(width: AppSpacing.xs), // 8px

                      // Content
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            // Title (18px bold, max 2 lines)
                            _buildTitle(context),

                            // Content preview (15px, 2 lines)
                            if (_buildContentPreview(context) != null) ...[
                              const SizedBox(height: AppSpacing.xxs), // 4px
                              _buildContentPreview(context)!,
                            ],

                            // Metadata (gradient text)
                            if (_buildMetadata(context) != null) ...[
                              const SizedBox(height: AppSpacing.xs), // 8px
                              _buildMetadata(context)!,
                            ],
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
      ),
    );

    // Apply entrance animation if index is provided (Phase 5 optimized)
    if (widget.index != null) {
      final delay = AppAnimations.itemEntranceStagger * widget.index!;
      final duration = AppAnimations.getDuration(context, AppAnimations.itemEntrance);

      return cardWidget
          .animate()
          .fadeIn(
            duration: duration,
            delay: delay,
            curve: Curves.easeOut, // Phase 5: Use easeOut instead of springCurve for entrance
          )
          .slideY(
            begin: AppAnimations.itemEntranceSlideDistance, // Phase 5: Use 8px distance instead of percentage
            end: 0,
            duration: duration,
            delay: delay,
            curve: Curves.easeOut,
          )
          .scale(
            begin: const Offset(AppAnimations.itemEntranceScale, AppAnimations.itemEntranceScale),
            end: const Offset(1.0, 1.0),
            duration: duration,
            delay: delay,
            curve: Curves.easeOut,
          );
    }

    // Return without entrance animation
    return cardWidget;
  }
}
