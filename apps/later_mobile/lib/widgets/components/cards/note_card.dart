import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:later_mobile/design_system/tokens/tokens.dart';
import '../../../data/models/item_model.dart';
import '../text/gradient_text.dart';
import '../borders/gradient_pill_border.dart';
import 'package:intl/intl.dart';

/// Note card component for displaying notes with content preview and tags
/// Mobile-First Bold Redesign
///
/// Performance optimizations:
/// - Uses RepaintBoundary to isolate repaints
/// - Const constructors where possible
/// - ValueKey for efficient list updates
/// - Optimized 6px gradient border for 60fps performance
///
/// Mobile-First Bold Design Features:
/// - 6px gradient pill border (blue-cyan note gradient)
/// - 20px border radius (pill shape)
/// - 18px bold title
/// - 20px card padding (comfortable thumb zones)
/// - Content preview (first 100 chars, 2 lines max)
/// - Tags display (first 3 tags, "+X more" if more)
/// - Document icon with gradient
/// - Created date metadata
/// - Press animations with haptic feedback
/// - Entrance animations with staggered delay
/// - Semantic labels for accessibility
class NoteCard extends StatefulWidget {
  const NoteCard({
    super.key,
    required this.item,
    this.onTap,
    this.onLongPress,
    this.showMetadata = true,
    this.index,
  });

  /// Item (Note) data to display
  final Item item;

  /// Callback when card is tapped
  final VoidCallback? onTap;

  /// Callback when card is long-pressed
  final VoidCallback? onLongPress;

  /// Whether to show metadata row
  final bool showMetadata;

  /// Index in the list for staggered entrance animation
  /// If null, no entrance animation is applied
  final int? index;

  @override
  State<NoteCard> createState() => _NoteCardState();
}

class _NoteCardState extends State<NoteCard> with TickerProviderStateMixin {
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

  /// Get border gradient (blue-cyan note gradient)
  LinearGradient _getBorderGradient() {
    return AppColors.noteGradient;
  }

  /// Get background color with subtle gradient tint (5% opacity)
  Color _getBackgroundTint(bool isDark) {
    return AppColors.typeLightBg('note', isDark: isDark);
  }

  /// Build leading icon (document icon with gradient)
  Widget _buildLeadingIcon() {
    final gradient = _getBorderGradient();

    return SizedBox(
      width: 48,
      height: 48,
      child: Center(
        child: ShaderMask(
          shaderCallback: (bounds) => gradient.createShader(bounds),
          child: const Icon(
            Icons.description_outlined,
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

  /// Truncate content to 100 characters with ellipsis
  ///
  /// Returns:
  /// - Original content if 100 chars or less
  /// - First 100 chars + "..." if longer
  String _truncateContent(String content) {
    if (content.length <= 100) {
      return content;
    }
    // Find the last space within the first 100 characters
    final substring = content.substring(0, 100);
    final lastSpace = substring.lastIndexOf(' ');
    if (lastSpace == -1) {
      // No space found, fall back to hard cut
      return '$substring...';
    }
    return '${substring.substring(0, lastSpace)}...';
  }

  /// Build content preview (first 100 chars, 2 lines max)
  Widget? _buildContentPreview(BuildContext context) {
    if (widget.item.content == null || widget.item.content!.isEmpty) {
      return null;
    }

    final isDark = Theme.of(context).brightness == Brightness.dark;
    final truncatedContent = _truncateContent(widget.item.content!);

    return Text(
      truncatedContent,
      style: AppTypography.itemContent.copyWith(
        color: isDark ? AppColors.textSecondaryDark : AppColors.textSecondaryLight,
      ),
      maxLines: 2, // Fixed 2 lines for consistent card height
      overflow: TextOverflow.ellipsis,
    );
  }

  /// Build tags row (show first 3, "+X more" if more)
  Widget? _buildTags(BuildContext context) {
    if (widget.item.tags.isEmpty) {
      return null;
    }

    final isDark = Theme.of(context).brightness == Brightness.dark;
    final visibleTags = widget.item.tags.take(3).toList();
    final remainingCount = widget.item.tags.length - visibleTags.length;

    return Wrap(
      spacing: AppSpacing.xxs, // 4px between chips
      runSpacing: AppSpacing.xxs,
      children: [
        // Show first 3 tags as chips
        ...visibleTags.map((tag) => _buildTagChip(tag, isDark)),

        // Show "+X more" if there are more tags
        if (remainingCount > 0)
          _buildMoreTagsChip(remainingCount, isDark),
      ],
    );
  }

  /// Build individual tag chip with subtle border
  Widget _buildTagChip(String tag, bool isDark) {
    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: AppSpacing.xs, // 8px
        vertical: AppSpacing.xxxs, // 2px
      ),
      decoration: BoxDecoration(
        color: isDark
            ? AppColors.noteGradientStart.withValues(alpha: 0.15)
            : AppColors.noteLight.withValues(alpha: 0.5),
        borderRadius: BorderRadius.circular(AppSpacing.radiusSM), // 8px
        border: Border.all(
          color: isDark
              ? AppColors.noteGradientStart.withValues(alpha: 0.3)
              : AppColors.noteGradientStart.withValues(alpha: 0.2),
        ),
      ),
      child: Text(
        tag,
        style: AppTypography.metadata.copyWith(
          color: isDark
              ? AppColors.noteGradientStart.withValues(alpha: 0.9)
              : AppColors.noteGradientStart,
          fontSize: 11, // Slightly smaller for tags
        ),
      ),
    );
  }

  /// Build "+X more" chip
  Widget _buildMoreTagsChip(int count, bool isDark) {
    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: AppSpacing.xs, // 8px
        vertical: AppSpacing.xxxs, // 2px
      ),
      decoration: BoxDecoration(
        color: isDark
            ? AppColors.neutral700.withValues(alpha: 0.5)
            : AppColors.neutral200,
        borderRadius: BorderRadius.circular(AppSpacing.radiusSM), // 8px
        border: Border.all(
          color: isDark
              ? AppColors.neutral600
              : AppColors.neutral300,
        ),
      ),
      child: Text(
        '+$count more',
        style: AppTypography.metadata.copyWith(
          color: isDark ? AppColors.textSecondaryDark : AppColors.textSecondaryLight,
          fontSize: 11,
        ),
      ),
    );
  }

  /// Build metadata row (created date)
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

  /// Build semantic label for accessibility
  String _buildSemanticLabel() {
    final buffer = StringBuffer('Note: ${widget.item.title}');

    // Add tag count if tags exist
    if (widget.item.tags.isNotEmpty) {
      buffer.write(', ${widget.item.tags.length} ${widget.item.tags.length == 1 ? 'tag' : 'tags'}');
    }

    // Add content preview if exists
    if (widget.item.content != null && widget.item.content!.isNotEmpty) {
      final preview = _truncateContent(widget.item.content!);
      buffer.write(', $preview');
    }

    return buffer.toString();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    // Base background color with subtle gradient tint (5% opacity)
    final baseBgColor = isDark ? AppColors.surfaceDark : AppColors.surfaceLight;
    final tintColor = _getBackgroundTint(isDark);

    // Background color based on state
    Color backgroundColor;
    if (_isPressed) {
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

    // Build the semantic label
    final semanticLabel = _buildSemanticLabel();

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
          label: semanticLabel,
          child: GestureDetector(
            onTapDown: _handleTapDown,
            onTapUp: _handleTapUp,
            onTapCancel: _handleTapCancel,
            onTap: _handleTap,
            onLongPress: _handleLongPress,
            child: Container(
              margin: const EdgeInsets.only(bottom: AppSpacing.cardSpacing), // 16px spacing
              // Wrap entire card with gradient pill border (6px width, 20px radius)
              child: GradientPillBorder(
                gradient: _getBorderGradient(),
                child: Container(
                  decoration: BoxDecoration(
                    color: backgroundColor,
                    borderRadius: BorderRadius.circular(AppSpacing.cardRadius - AppSpacing.cardBorderWidth), // Inner radius reduced by border width
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
                      // Leading icon (document icon)
                      _buildLeadingIcon(),
                      const SizedBox(width: AppSpacing.xs), // 8px

                      // Content
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            // Title (18px bold, max 2 lines)
                            _buildTitle(context),

                            // Content preview (15px, 2 lines, first 100 chars)
                            if (_buildContentPreview(context) != null) ...[
                              const SizedBox(height: AppSpacing.xxs), // 4px
                              _buildContentPreview(context)!,
                            ],

                            // Tags (show first 3, "+X more")
                            if (_buildTags(context) != null) ...[
                              const SizedBox(height: AppSpacing.xs), // 8px
                              _buildTags(context)!,
                            ],

                            // Metadata (created date)
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
