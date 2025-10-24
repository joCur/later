import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_typography.dart';
import '../../../core/theme/app_spacing.dart';
import '../../../core/theme/app_animations.dart';
import '../../../data/models/list_model.dart';
import '../borders/gradient_pill_border.dart';

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

  @override
  State<ListCard> createState() => _ListCardState();
}

class _ListCardState extends State<ListCard> with TickerProviderStateMixin {
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
          child: Text(
            iconString,
            style: const TextStyle(fontSize: 20),
          ),
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
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Text(
      widget.list.name,
      style: AppTypography.itemTitle.copyWith(
        color: isDark ? AppColors.textPrimaryDark : AppColors.textPrimaryLight,
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
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final count = widget.list.totalItems;
    final text = count == 1 ? '1 item' : '$count items';

    return Text(
      text,
      style: AppTypography.metadata.copyWith(
        color: isDark ? AppColors.textSecondaryDark : AppColors.textSecondaryLight,
      ),
    );
  }

  /// Build preview of first 3 items with ellipsis handling
  ///
  /// Shows comma-separated list of first 3 item titles
  /// Adds "..." if more than 3 items exist
  /// Shows "No items" when list is empty
  Widget _buildItemPreview(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final preview = _getItemPreview();

    return Text(
      preview,
      style: AppTypography.itemContent.copyWith(
        color: isDark ? AppColors.textSecondaryDark : AppColors.textSecondaryLight,
      ),
      maxLines: 2,
      overflow: TextOverflow.ellipsis,
    );
  }

  /// Generate item preview string from first 3 items
  ///
  /// Returns:
  /// - "No items" when list is empty
  /// - "Item1, Item2, Item3..." when more than 3 items (with ellipsis)
  /// - "Item1, Item2" when 2 items (no ellipsis)
  /// - "Item1" when 1 item (no ellipsis)
  String _getItemPreview() {
    if (widget.list.items.isEmpty) {
      return 'No items';
    }

    final firstThree = widget.list.items.take(3).map((item) => item.title).toList();
    final preview = firstThree.join(', ');

    // Add ellipsis if there are more than 3 items
    if (widget.list.items.length > 3) {
      return '$preview...';
    }

    return preview;
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
    final semanticLabel = 'List: ${widget.list.name}, '
        '${widget.list.totalItems} ${widget.list.totalItems == 1 ? 'item' : 'items'}';

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
    return codeUnit >= 0x1F300 ||
        (codeUnit >= 0x2600 && codeUnit <= 0x27BF) ||
        text.length <= 2;
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
