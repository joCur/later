import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:later_mobile/design_system/tokens/tokens.dart';
import '../../../data/models/todo_list_model.dart';

/// TodoItem card component for displaying individual tasks within a TodoList
/// This is a SUB-ITEM card (not a main container card like TodoListCard)
///
/// Design Features:
/// - Compact list item design (56-72px height range)
/// - NO gradient pill border (simpler than container cards)
/// - Left-aligned checkbox (24x24px, interactive)
/// - Title text (16px medium weight)
/// - Inline metadata (due date with calendar icon, priority badge)
/// - Reorder handle on the right (drag_indicator icon)
/// - Strikethrough text decoration for completed items
/// - Reduced opacity (50%) for completed items
/// - Subtle hover state with background color change
/// - Task-specific colors for priority badges:
///   - High: Red (error color)
///   - Medium: Amber (warning color)
///   - Low: Neutral gray
///
/// Interaction Features:
/// - Tap card to toggle completion (if onCheckboxChanged provided)
/// - Tap checkbox to toggle completion (with light haptic)
/// - Long press for edit/context menu (with medium haptic)
/// - Mouse hover state on desktop/web
///
/// Accessibility Features:
/// - Semantic labels with completion status, due date, and priority
/// - Checkbox marked as interactive control
/// - Screen reader friendly
///
/// Performance optimizations:
/// - Uses RepaintBoundary to isolate repaints
/// - Const constructors where possible
/// - Optimized for list rendering (minimal widget tree)
/// - Hover state only updates background color (no expensive rebuilds)
class TodoItemCard extends StatefulWidget {
  const TodoItemCard({
    super.key,
    required this.todoItem,
    this.onTap,
    this.onCheckboxChanged,
    this.onLongPress,
  });

  /// TodoItem data to display
  final TodoItem todoItem;

  /// Callback when card is tapped
  final VoidCallback? onTap;

  /// Callback when checkbox state changes
  final ValueChanged<bool>? onCheckboxChanged;

  /// Callback when card is long-pressed
  final VoidCallback? onLongPress;

  @override
  State<TodoItemCard> createState() => _TodoItemCardState();
}

class _TodoItemCardState extends State<TodoItemCard> {
  // Layout constants
  static const double _checkboxSize = 24.0;
  static const double _checkboxSpacing = 12.0;
  static const double _reorderHandleSize = 20.0;
  static const double _reorderHandleSpacing = 12.0;
  static const double _cardBorderRadius = 8.0;
  static const double _cardMinHeight = 56.0;
  static const double _cardMaxHeight = 72.0;
  static const double _cardHorizontalPadding = 12.0;
  static const double _cardVerticalPadding = 12.0;

  // Priority badge constants
  static const double _priorityBadgeHorizontalPadding = 6.0;
  static const double _priorityBadgeVerticalPadding = 2.0;
  static const double _priorityBadgeRadius = 4.0;
  static const double _priorityBadgeFontSize = 10.0;
  static const double _priorityBadgeLetterSpacing = 0.5;

  // Due date constants
  static const double _dueDateIconSize = 12.0;
  static const double _dueDateIconSpacing = 4.0;
  static const double _dueDateBadgeSpacing = 8.0;

  // Metadata row constants
  static const double _metadataSpacing = 2.0;

  bool _isHovered = false;

  /// Get priority badge color based on priority level
  Color _getPriorityColor(TodoPriority priority) {
    switch (priority) {
      case TodoPriority.high:
        return AppColors.error;
      case TodoPriority.medium:
        return AppColors.warning;
      case TodoPriority.low:
        return AppColors.neutral300;
    }
  }

  /// Get priority badge label
  String _getPriorityLabel(TodoPriority priority) {
    switch (priority) {
      case TodoPriority.high:
        return 'HIGH';
      case TodoPriority.medium:
        return 'MED';
      case TodoPriority.low:
        return 'LOW';
    }
  }

  /// Format due date as "MMM d" (e.g., "Mar 15")
  String _formatDueDate(DateTime date) {
    final formatter = DateFormat('MMM d');
    return formatter.format(date);
  }

  /// Build priority badge with appropriate color and label
  Widget _buildPriorityBadge(TodoPriority priority) {
    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: _priorityBadgeHorizontalPadding,
        vertical: _priorityBadgeVerticalPadding,
      ),
      decoration: BoxDecoration(
        color: _getPriorityColor(priority),
        borderRadius: BorderRadius.circular(_priorityBadgeRadius),
      ),
      child: Text(
        _getPriorityLabel(priority),
        style: AppTypography.labelSmall.copyWith(
          color: Colors.white,
          fontSize: _priorityBadgeFontSize,
          letterSpacing: _priorityBadgeLetterSpacing,
        ),
      ),
    );
  }

  /// Build due date display with calendar icon
  Widget _buildDueDate(DateTime dueDate, bool isDark) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(
          Icons.calendar_today,
          size: _dueDateIconSize,
          color: isDark ? AppColors.neutral500 : AppColors.neutral500,
        ),
        const SizedBox(width: _dueDateIconSpacing),
        Text(
          _formatDueDate(dueDate),
          style: AppTypography.metadata.copyWith(
            color: isDark ? AppColors.neutral500 : AppColors.neutral500,
          ),
        ),
      ],
    );
  }

  /// Build semantic label for accessibility
  String _buildSemanticLabel() {
    final buffer = StringBuffer(widget.todoItem.title);

    // Add completion status
    buffer.write(widget.todoItem.isCompleted ? ', completed' : ', not completed');

    // Add due date if present
    if (widget.todoItem.dueDate != null) {
      buffer.write(', due ${_formatDueDate(widget.todoItem.dueDate!)}');
    }

    // Add priority if present
    if (widget.todoItem.priority != null) {
      final priorityName = widget.todoItem.priority!.toString().split('.').last;
      buffer.write(', priority: $priorityName');
    }

    return buffer.toString();
  }

  void _handleTap() {
    // If onTap is provided, call it; otherwise toggle checkbox
    if (widget.onTap != null) {
      widget.onTap!();
    } else if (widget.onCheckboxChanged != null) {
      widget.onCheckboxChanged!(!widget.todoItem.isCompleted);
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
        ? (isDark ? AppColors.neutral800 : AppColors.neutral100)
        : (isDark ? AppColors.neutral900 : Colors.white);

    // Build semantic label
    final semanticLabel = _buildSemanticLabel();

    // Build the card content with consistent spacing
    final cardContent = Container(
      constraints: const BoxConstraints(
        minHeight: _cardMinHeight,
        maxHeight: _cardMaxHeight,
      ),
      padding: const EdgeInsets.symmetric(
        horizontal: _cardHorizontalPadding,
        vertical: _cardVerticalPadding,
      ),
      decoration: BoxDecoration(
        color: backgroundColor,
        borderRadius: BorderRadius.circular(_cardBorderRadius),
        border: Border.all(
          color: isDark ? AppColors.neutral700 : AppColors.neutral200,
        ),
      ),
      child: Row(
        children: [
          // Checkbox (24x24px)
          SizedBox(
            width: _checkboxSize,
            height: _checkboxSize,
            child: Checkbox(
              value: widget.todoItem.isCompleted,
              onChanged: _handleCheckboxChanged,
              materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
              visualDensity: VisualDensity.compact,
            ),
          ),
          const SizedBox(width: _checkboxSpacing),

          // Content (title, metadata)
          Expanded(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Title with optional strikethrough
                Text(
                  widget.todoItem.title,
                  style: AppTypography.titleSmall.copyWith(
                    color: isDark ? AppColors.neutral400 : AppColors.neutral600,
                    decoration: widget.todoItem.isCompleted
                        ? TextDecoration.lineThrough
                        : null,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),

                // Metadata row (due date, priority) - only show if present
                if (widget.todoItem.dueDate != null ||
                    widget.todoItem.priority != null) ...[
                  const SizedBox(height: _metadataSpacing),
                  Row(
                    children: [
                      // Due date
                      if (widget.todoItem.dueDate != null) ...[
                        _buildDueDate(widget.todoItem.dueDate!, isDark),
                        const SizedBox(width: _dueDateBadgeSpacing),
                      ],

                      // Priority badge
                      if (widget.todoItem.priority != null)
                        _buildPriorityBadge(widget.todoItem.priority!),
                    ],
                  ),
                ],
              ],
            ),
          ),

          const SizedBox(width: _reorderHandleSpacing),

          // Reorder handle
          Icon(
            Icons.drag_indicator,
            size: _reorderHandleSize,
            color: isDark ? AppColors.neutral600 : AppColors.neutral400,
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
              opacity: widget.todoItem.isCompleted ? AppColors.completedOpacity : 1.0,
              child: cardContent,
            ),
          ),
        ),
      ),
    );
  }
}
