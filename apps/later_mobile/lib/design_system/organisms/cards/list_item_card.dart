import 'package:flutter/material.dart';
import 'package:later_mobile/design_system/tokens/tokens.dart';
import '../../../data/models/list_model.dart';

/// ListItem card component for displaying individual items within a List
/// This is a SUB-ITEM card (not a main container card like TodoListCard)
///
/// Design Features:
/// - Compact list item design (56-64px height range)
/// - NO gradient pill border (simpler than container cards)
/// - Left-aligned indicator based on list style:
///   - Bullets: bullet point (•)
///   - Numbered: number badge (1., 2., 3., etc)
///   - Checkboxes: interactive checkbox (24x24px)
/// - Title text (16px medium weight)
/// - Optional notes below title (14px, secondary color, 2 lines max)
/// - Reorder handle on the right (drag_indicator icon)
/// - Strikethrough text decoration for checked items (checkboxes style only)
/// - Reduced opacity (50%) for checked items
/// - Subtle hover state with background color change
///
/// Interaction Features:
/// - Tap card to trigger onTap (for checkboxes: toggle completion if no onTap)
/// - Tap checkbox to toggle completion (checkboxes style only, with light haptic)
/// - Long press for edit/context menu (with medium haptic)
/// - Mouse hover state on desktop/web
///
/// Accessibility Features:
/// - Semantic labels with list style, completion status, and notes
/// - Checkbox marked as interactive control (checkboxes style only)
/// - Screen reader friendly
///
/// Performance optimizations:
/// - Uses RepaintBoundary to isolate repaints
/// - Const constructors where possible
/// - Optimized for list rendering (minimal widget tree)
/// - Hover state only updates background color (no expensive rebuilds)
class ListItemCard extends StatefulWidget {
  const ListItemCard({
    super.key,
    required this.listItem,
    required this.listStyle,
    required this.itemIndex,
    this.onTap,
    this.onCheckboxChanged,
    this.onLongPress,
  });

  /// ListItem data to display
  final ListItem listItem;

  /// List style (bullets, numbered, checkboxes)
  final ListStyle listStyle;

  /// Item index for numbered lists (0-based, will be displayed as 1-based)
  final int itemIndex;

  /// Callback when card is tapped
  final VoidCallback? onTap;

  /// Callback when checkbox state changes (checkboxes style only)
  final ValueChanged<bool>? onCheckboxChanged;

  /// Callback when card is long-pressed
  final VoidCallback? onLongPress;

  @override
  State<ListItemCard> createState() => _ListItemCardState();
}

class _ListItemCardState extends State<ListItemCard> {
  // Layout constants
  static const double _indicatorSize = 24.0;
  static const double _indicatorSpacing = 12.0;
  static const double _reorderHandleSize = 20.0;
  static const double _reorderHandleSpacing = 12.0;
  static const double _cardBorderRadius = 8.0;
  static const double _cardMinHeight = 56.0;
  static const double _cardHorizontalPadding = 12.0;
  static const double _cardVerticalPadding = 12.0;
  static const double _cardBottomMargin = 8.0;

  // Numbered badge constants
  static const double _numberedBadgeSize = 24.0;
  static const double _numberedBadgeRadius = 12.0;

  // Notes constants
  static const double _notesSpacing = 4.0;
  static const int _notesMaxLines = 2;

  bool _isHovered = false;

  /// Build indicator widget based on list style
  ///
  /// Returns different widgets based on [ListStyle]:
  /// - [ListStyle.bullets]: Bullet point (•) with list color
  /// - [ListStyle.numbered]: Rounded badge with item number
  /// - [ListStyle.checkboxes]: Interactive checkbox with current state
  Widget _buildIndicator(BuildContext context, bool isDark) {
    switch (widget.listStyle) {
      case ListStyle.bullets:
        return SizedBox(
          width: _indicatorSize,
          height: _indicatorSize,
          child: Center(
            child: Text(
              '•',
              style: TextStyle(
                fontSize: 20,
                color: isDark
                    ? AppColors.listGradientEnd
                    : AppColors.listGradientStart,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        );

      case ListStyle.numbered:
        return Container(
          width: _numberedBadgeSize,
          height: _numberedBadgeSize,
          decoration: BoxDecoration(
            color: isDark
                ? AppColors.listGradientStart.withValues(alpha: 0.2)
                : AppColors.listLight,
            borderRadius: BorderRadius.circular(_numberedBadgeRadius),
          ),
          child: Center(
            child: Text(
              '${widget.itemIndex + 1}.',
              style: AppTypography.labelMedium.copyWith(
                color: isDark
                    ? AppColors.listGradientEnd
                    : AppColors.listGradientStart,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        );

      case ListStyle.checkboxes:
        return SizedBox(
          width: _indicatorSize,
          height: _indicatorSize,
          child: Checkbox(
            value: widget.listItem.isChecked,
            onChanged: _handleCheckboxChanged,
            materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
            visualDensity: VisualDensity.compact,
          ),
        );
    }
  }

  /// Build notes widget if notes are present
  ///
  /// Returns null if notes are empty or null, otherwise returns a Text widget
  /// with secondary text styling and 2-line ellipsis overflow
  Widget? _buildNotes(bool isDark) {
    if (widget.listItem.notes == null || widget.listItem.notes!.isEmpty) {
      return null;
    }

    return Text(
      widget.listItem.notes!,
      style: AppTypography.bodySmall.copyWith(
        color: AppColors.textSecondary(context),
      ),
      maxLines: _notesMaxLines,
      overflow: TextOverflow.ellipsis,
    );
  }

  /// Build semantic label for accessibility
  ///
  /// Creates a screen reader-friendly label that includes:
  /// - Item title
  /// - List style information (bullet, number, checked/not checked)
  /// - Optional notes
  String _buildSemanticLabel() {
    final buffer = StringBuffer(widget.listItem.title);

    // Add list style information
    switch (widget.listStyle) {
      case ListStyle.bullets:
        buffer.write(', bullet');
        break;
      case ListStyle.numbered:
        buffer.write(', number ${widget.itemIndex + 1}');
        break;
      case ListStyle.checkboxes:
        buffer.write(widget.listItem.isChecked ? ', checked' : ', not checked');
        break;
    }

    // Add notes if present
    if (widget.listItem.notes != null && widget.listItem.notes!.isNotEmpty) {
      buffer.write(', ${widget.listItem.notes}');
    }

    return buffer.toString();
  }

  void _handleTap() {
    // If onTap is provided, call it; otherwise toggle checkbox for checkboxes style
    if (widget.onTap != null) {
      widget.onTap!();
    } else if (widget.listStyle == ListStyle.checkboxes &&
        widget.onCheckboxChanged != null) {
      widget.onCheckboxChanged!(!widget.listItem.isChecked);
    }
  }

  void _handleCheckboxChanged(bool? value) {
    if (value != null) {
      AppAnimations.lightHaptic();
      widget.onCheckboxChanged?.call(value);
    }
  }

  void _handleLongPress() {
    AppAnimations.mediumHaptic();
    widget.onLongPress?.call();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    // Background color based on hover state
    final backgroundColor = _isHovered
        ? (AppColors.surfaceVariant(context))
        : (AppColors.surface(context));

    // Build semantic label
    final semanticLabel = _buildSemanticLabel();

    // Build notes widget if present
    final notesWidget = _buildNotes(isDark);

    // Determine if item is checked (only relevant for checkboxes style)
    final isChecked =
        widget.listStyle == ListStyle.checkboxes && widget.listItem.isChecked;

    // Build the card content with consistent spacing
    final cardContent = Container(
      constraints: const BoxConstraints(minHeight: _cardMinHeight),
      padding: const EdgeInsets.symmetric(
        horizontal: _cardHorizontalPadding,
        vertical: _cardVerticalPadding,
      ),
      decoration: BoxDecoration(
        color: backgroundColor,
        borderRadius: BorderRadius.circular(_cardBorderRadius),
        border: Border.all(
          color: AppColors.border(context),
        ),
      ),
      child: Row(
        children: [
          // Indicator (bullet, number, or checkbox)
          _buildIndicator(context, isDark),
          const SizedBox(width: _indicatorSpacing),

          // Content (title, notes)
          Expanded(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Title with optional strikethrough
                Text(
                  widget.listItem.title,
                  style: AppTypography.titleSmall.copyWith(
                    color: AppColors.text(context),
                    decoration: isChecked ? TextDecoration.lineThrough : null,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),

                // Notes (if present)
                if (notesWidget != null) ...[
                  const SizedBox(height: _notesSpacing),
                  notesWidget,
                ],
              ],
            ),
          ),

          const SizedBox(width: _reorderHandleSpacing),

          // Reorder handle with drag functionality
          ReorderableDragStartListener(
            index: widget.itemIndex,
            child: Icon(
              Icons.drag_indicator,
              size: _reorderHandleSize,
              color: AppColors.textDisabled(context),
            ),
          ),
        ],
      ),
    );

    // Wrap with Semantics and GestureDetector
    return RepaintBoundary(
      child: Semantics(
        container: true,
        button: true,
        enabled: true,
        label: semanticLabel,
        child: MouseRegion(
          onEnter: (_) => setState(() => _isHovered = true),
          onExit: (_) => setState(() => _isHovered = false),
          child: GestureDetector(
            onTap: _handleTap,
            onLongPress: _handleLongPress,
            child: Opacity(
              opacity: isChecked ? AppColors.completedOpacity : 1.0,
              child: Padding(
                padding: const EdgeInsets.only(bottom: _cardBottomMargin),
                child: cardContent,
              ),
            ),
          ),
        ),
      ),
    );
  }
}
