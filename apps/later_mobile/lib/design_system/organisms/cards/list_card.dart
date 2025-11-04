import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:later_mobile/design_system/tokens/tokens.dart';
import 'package:later_mobile/data/models/list_model.dart';
import 'package:later_mobile/design_system/atoms/borders/gradient_pill_border.dart';
import 'package:later_mobile/design_system/atoms/drag_handle/drag_handle.dart';
import 'package:later_mobile/core/theme/temporal_flow_theme.dart';

/// List card component for displaying lists with item previews
/// Mobile-First Bold Redesign
///
/// Performance optimizations:
/// - Uses RepaintBoundary to isolate repaints
/// - Const constructors where possible
/// - ValueKey for efficient list updates
/// - Optimized 6px gradient border for 60fps performance
///
/// Mobile-First Bold Design Features:
/// - 6px gradient pill border (violet gradient)
/// - 20px border radius (pill shape)
/// - 18px bold title
/// - 20px card padding (comfortable thumb zones)
/// - Item count display (e.g., "12 items")
/// - Preview of first 3 items
/// - Custom icon or default list icon
/// - Press animations with haptic feedback
/// - Entrance animations with staggered delay
/// - Semantic labels for accessibility
class ListCard extends StatefulWidget {
  const ListCard({
    super.key,
    required this.list,
    this.onTap,
    this.onLongPress,
    this.index,
    this.reorderIndex,
  });

  /// List data to display
  final ListModel list;

  /// Callback when card is tapped
  final VoidCallback? onTap;

  /// Callback when card is long-pressed
  final VoidCallback? onLongPress;

  /// Index in the list for staggered entrance animation
  /// If null, no entrance animation is applied
  final int? index;

  /// Index for ReorderableListView
  /// If provided, the drag handle will be wrapped with ReorderableDragStartListener
  final int? reorderIndex;

  @override
  State<ListCard> createState() => _ListCardState();
}

class _ListCardState extends State<ListCard> with TickerProviderStateMixin {
  bool _isPressed = false;
  bool _isDragging = false;
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
    _pressScaleAnimation =
        Tween<double>(begin: 1.0, end: AppAnimations.itemPressScale).animate(
          CurvedAnimation(
            parent: _pressAnimationController,
            curve: Curves.easeOut,
            reverseCurve: Curves.easeOutBack,
          ),
        );
  }

  @override
  void dispose() {
    _pressAnimationController.dispose();
    super.dispose();
  }

  /// Get border gradient (violet list gradient)
  LinearGradient _getBorderGradient() {
    return AppColors.listGradient;
  }

  /// Get background color with subtle gradient tint (5% opacity)
  Color _getBackgroundTint(bool isDark) {
    return AppColors.typeLightBg('list', isDark: isDark);
  }

  /// Build leading icon with gradient shader or emoji
  ///
  /// Supports three icon types:
  /// 1. Emoji: Direct text rendering (e.g., "🛒")
  /// 2. Icon name: Mapped to Material Icon (e.g., "shopping_cart")
  /// 3. Default: list_alt icon when null or empty
  Widget _buildLeadingIcon() {
    final gradient = _getBorderGradient();
    final iconString = widget.list.icon;

    Widget iconWidget;

    if (iconString == null || iconString.isEmpty) {
      // Default icon
      iconWidget = const Icon(
        Icons.list_alt,
        size: 20,
        color: Colors.white, // Base color for shader mask
      );
    } else if (_IconParser.isEmoji(iconString)) {
      // Emoji icon - return text widget without shader mask
      return SizedBox(
        width: 48,
        height: 48,
        child: Center(
          child: Text(iconString, style: const TextStyle(fontSize: 20)),
        ),
      );
    } else {
      // Icon name - try to parse to IconData
      final iconData = _IconParser.parseIconName(iconString);
      iconWidget = Icon(
        iconData,
        size: 20,
        color: Colors.white, // Base color for shader mask
      );
    }

    return SizedBox(
      width: 48,
      height: 48,
      child: Center(
        child: ShaderMask(
          shaderCallback: (bounds) => gradient.createShader(bounds),
          child: iconWidget,
        ),
      ),
    );
  }

  /// Build title with proper styling
  Widget _buildTitle(BuildContext context) {

    return Text(
      widget.list.name,
      style: AppTypography.itemTitle.copyWith(
        color: AppColors.text(context),
      ),
      maxLines: AppTypography.itemTitleMaxLines,
      overflow: TextOverflow.ellipsis,
    );
  }

  /// Build item count text with singular/plural handling
  ///
  /// Returns "1 item" for single item, "N items" for multiple items
  /// Examples: "1 item", "5 items", "0 items"
  Widget _buildItemCount(BuildContext context) {
    final count = widget.list.totalItemCount;
    final text = count == 1 ? '1 item' : '$count items';

    return Text(
      text,
      style: AppTypography.metadata.copyWith(
        color: AppColors.textSecondary(context),
      ),
    );
  }

  /// Build preview showing item count (items are loaded separately)
  ///
  /// Shows a simple text preview indicating the number of items
  /// Examples: "No items yet", "5 items"
  Widget _buildItemPreview(BuildContext context) {
    final count = widget.list.totalItemCount;
    final preview = count == 0 ? 'No items yet' : '$count item${count == 1 ? '' : 's'}';

    return Text(
      preview,
      style: AppTypography.itemContent.copyWith(
        color: AppColors.textSecondary(context),
      ),
      maxLines: 1,
      overflow: TextOverflow.ellipsis,
    );
  }

  void _handleTapDown(TapDownDetails details) {
    // Don't trigger press animation if dragging
    if (_isDragging) return;

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
    final baseBgColor = AppColors.surface(context);
    final tintColor = _getBackgroundTint(isDark);

    // Background color based on state
    Color backgroundColor;
    if (_isPressed) {
      backgroundColor = AppColors.surfaceVariant(context);
    } else {
      // Blend base color with subtle type-specific tint
      backgroundColor = Color.alphaBlend(
        tintColor.withValues(alpha: 0.05),
        baseBgColor,
      );
    }

    // Build the semantic label
    final semanticLabel =
        'List: ${widget.list.name}, '
        '${widget.list.totalItemCount} ${widget.list.totalItemCount == 1 ? 'item' : 'items'}';

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
              margin: const EdgeInsets.only(
                bottom: AppSpacing.cardSpacing,
              ), // 16px spacing
              // Wrap entire card with gradient pill border (6px width, 20px radius)
              child: GradientPillBorder(
                gradient: _getBorderGradient(),
                child: Container(
                  decoration: BoxDecoration(
                    color: backgroundColor,
                    borderRadius: BorderRadius.circular(
                      AppSpacing.cardRadius - AppSpacing.cardBorderWidth,
                    ), // Inner radius reduced by border width
                    // Mobile-optimized shadow: 4px offset, 8px blur, 12% opacity
                    boxShadow: _isPressed
                        ? null
                        : [
                            BoxShadow(
                              color: Theme.of(context)
                                  .extension<TemporalFlowTheme>()!
                                  .shadowColor
                                  .withValues(alpha: 0.12),
                              blurRadius: 8,
                              offset: const Offset(0, 4),
                            ),
                          ],
                  ),
                  // Clip the content to follow the border radius
                  clipBehavior: Clip.antiAlias,
                  // Main content with 20px padding (mobile-first comfortable touch zones)
                  padding: const EdgeInsets.all(
                    AppSpacing.cardPaddingMobile,
                  ), // 20px
                  child: Row(
                    children: [
                      // Leading icon
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

                            // Item count
                            const SizedBox(height: AppSpacing.xxs), // 4px
                            _buildItemCount(context),

                            // Item preview
                            const SizedBox(height: AppSpacing.xs), // 8px
                            _buildItemPreview(context),
                          ],
                        ),
                      ),
                      // Spacing before drag handle
                      const SizedBox(width: AppSpacing.xs), // 8px
                      // Drag handle (centered vertically by Row's crossAxisAlignment)
                      // Wrap with ReorderableDragStartListener if reorderIndex is provided
                      if (widget.reorderIndex != null)
                        ReorderableDragStartListener(
                          index: widget.reorderIndex!,
                          child: DragHandleWidget(
                            gradient: AppColors.listGradient,
                            semanticLabel: 'Reorder ${widget.list.name}',
                            onDragStart: () => setState(() => _isDragging = true),
                            onDragEnd: () => setState(() => _isDragging = false),
                          ),
                        )
                      else
                        DragHandleWidget(
                          gradient: AppColors.listGradient,
                          semanticLabel: 'Reorder ${widget.list.name}',
                          onDragStart: () => setState(() => _isDragging = true),
                          onDragEnd: () => setState(() => _isDragging = false),
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
      final duration = AppAnimations.getDuration(
        context,
        AppAnimations.itemEntrance,
      );

      return cardWidget
          .animate()
          .fadeIn(
            duration: duration,
            delay: delay,
            curve: Curves
                .easeOut, // Phase 5: Use easeOut instead of springCurve for entrance
          )
          .slideY(
            begin: AppAnimations
                .itemEntranceSlideDistance, // Phase 5: Use 8px distance instead of percentage
            end: 0,
            duration: duration,
            delay: delay,
            curve: Curves.easeOut,
          )
          .scale(
            begin: const Offset(
              AppAnimations.itemEntranceScale,
              AppAnimations.itemEntranceScale,
            ),
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

/// Helper class for parsing icon strings
///
/// Handles three types of icon representations:
/// 1. Emoji strings (Unicode characters)
/// 2. Icon names (mapped to Material Icons)
/// 3. Default fallback (list_alt icon)
class _IconParser {
  _IconParser._(); // Private constructor to prevent instantiation

  /// Check if string is an emoji
  ///
  /// Uses Unicode range heuristics to detect emoji characters
  /// Common emoji ranges: 0x1F300-0x1F9FF, 0x2600-0x26FF, 0x2700-0x27BF
  static bool isEmoji(String text) {
    if (text.isEmpty) return false;
    final codeUnit = text.codeUnitAt(0);
    return (codeUnit >= 0x1F300 && codeUnit <= 0x1F9FF) ||
        (codeUnit >= 0x2600 && codeUnit <= 0x26FF) ||
        (codeUnit >= 0x2700 && codeUnit <= 0x27BF);
  }

  /// Parse icon name string to IconData
  ///
  /// Maps common icon name strings to Material IconData objects
  /// Returns Icons.list_alt as default fallback for unmapped names
  static IconData parseIconName(String iconName) {
    // Map common icon names to IconData
    const iconMap = <String, IconData>{
      'shopping_cart': Icons.shopping_cart,
      'favorite': Icons.favorite,
      'star': Icons.star,
      'home': Icons.home,
      'work': Icons.work,
      'school': Icons.school,
      'restaurant': Icons.restaurant,
      'local_grocery_store': Icons.local_grocery_store,
      'shopping_bag': Icons.shopping_bag,
      'list': Icons.list,
      'list_alt': Icons.list_alt,
      'checklist': Icons.checklist,
      'check_circle': Icons.check_circle,
      'folder': Icons.folder,
      'description': Icons.description,
      'note': Icons.note,
      'book': Icons.book,
      'library_books': Icons.library_books,
      'assignment': Icons.assignment,
    };

    return iconMap[iconName] ?? Icons.list_alt; // Default fallback
  }
}
