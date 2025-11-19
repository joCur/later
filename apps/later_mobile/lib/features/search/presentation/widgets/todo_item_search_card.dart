import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:later_mobile/design_system/tokens/tokens.dart';
import 'package:later_mobile/features/todo_lists/domain/models/todo_item.dart';
import 'package:later_mobile/features/todo_lists/domain/models/todo_priority.dart';
import 'package:later_mobile/l10n/app_localizations.dart';

/// Search result card for TodoItem child items.
///
/// Displays:
/// - TodoItem title with checkbox indicator
/// - Parent context: "in [TodoList Name]" subtitle
/// - Due date and priority (if set)
/// - Task-specific styling/gradient
/// - Completion status (strikethrough, opacity)
///
/// On tap: Navigates to parent TodoListDetailScreen
class TodoItemSearchCard extends StatefulWidget {
  const TodoItemSearchCard({
    super.key,
    required this.todoItem,
    required this.parentName,
    this.onTap,
  });

  final TodoItem todoItem;
  final String parentName;
  final VoidCallback? onTap;

  @override
  State<TodoItemSearchCard> createState() => _TodoItemSearchCardState();
}

class _TodoItemSearchCardState extends State<TodoItemSearchCard> {
  bool _isHovered = false;

  /// Get priority badge color based on priority level
  Color _getPriorityColor(TodoPriority priority) {
    return switch (priority) {
      TodoPriority.high => AppColors.error,
      TodoPriority.medium => AppColors.warning,
      TodoPriority.low => AppColors.neutral500,
    };
  }

  /// Get priority text
  String _getPriorityText(TodoPriority priority) {
    return switch (priority) {
      TodoPriority.high => 'HIGH',
      TodoPriority.medium => 'MED',
      TodoPriority.low => 'LOW',
    };
  }

  /// Build checkbox icon indicator
  Widget _buildCheckboxIndicator() {
    const gradient = AppColors.taskGradient;

    return SizedBox(
      width: 24,
      height: 24,
      child: ShaderMask(
        shaderCallback: (bounds) => gradient.createShader(bounds),
        child: Icon(
          widget.todoItem.isCompleted
              ? Icons.check_box
              : Icons.check_box_outline_blank,
          size: 24,
          color: Colors.white,
        ),
      ),
    );
  }

  /// Build title with completion styling
  Widget _buildTitle(BuildContext context) {
    final opacity = widget.todoItem.isCompleted ? 0.5 : 1.0;

    return Text(
      widget.todoItem.title,
      style: AppTypography.bodyMedium.copyWith(
        color: AppColors.text(context).withValues(alpha: opacity),
        decoration: widget.todoItem.isCompleted
            ? TextDecoration.lineThrough
            : TextDecoration.none,
        decorationColor: AppColors.text(context).withValues(alpha: opacity),
      ),
      maxLines: 2,
      overflow: TextOverflow.ellipsis,
    );
  }

  /// Build parent context subtitle
  Widget _buildParentContext(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(
          Icons.list_alt,
          size: 12,
          color: AppColors.textSecondary(context),
        ),
        const SizedBox(width: 4),
        Flexible(
          child: Text(
            l10n.searchResultInTodoList(widget.parentName),
            style: AppTypography.caption.copyWith(
              color: AppColors.textSecondary(context),
            ),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
        ),
      ],
    );
  }

  /// Build metadata row (due date and priority)
  Widget? _buildMetadata(BuildContext context) {
    final hasDueDate = widget.todoItem.dueDate != null;
    final hasPriority = widget.todoItem.priority != null;

    if (!hasDueDate && !hasPriority) {
      return null;
    }

    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        // Due date
        if (hasDueDate) ...[
          Icon(
            Icons.calendar_today,
            size: 12,
            color: AppColors.textSecondary(context),
          ),
          const SizedBox(width: 4),
          Text(
            DateFormat('MMM d').format(widget.todoItem.dueDate!),
            style: AppTypography.caption.copyWith(
              color: AppColors.textSecondary(context),
            ),
          ),
        ],

        // Spacing between date and priority
        if (hasDueDate && hasPriority) const SizedBox(width: 8),

        // Priority badge
        if (hasPriority)
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
            decoration: BoxDecoration(
              color: _getPriorityColor(widget.todoItem.priority!).withValues(alpha: 0.15),
              borderRadius: BorderRadius.circular(4),
              border: Border.all(
                color: _getPriorityColor(widget.todoItem.priority!).withValues(alpha: 0.3),
              ),
            ),
            child: Text(
              _getPriorityText(widget.todoItem.priority!),
              style: TextStyle(
                fontSize: 10,
                fontWeight: FontWeight.w600,
                letterSpacing: 0.5,
                color: _getPriorityColor(widget.todoItem.priority!),
              ),
            ),
          ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    // Background color with task-specific tint
    final baseBgColor = AppColors.surface(context);
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final tintColor = AppColors.typeLightBg('task', isDark: isDark);
    final backgroundColor = Color.alphaBlend(
      tintColor.withValues(alpha: 0.05),
      baseBgColor,
    );

    // Hover background
    final hoverBackgroundColor = AppColors.surfaceVariant(context);

    return MouseRegion(
      onEnter: (_) => setState(() => _isHovered = true),
      onExit: (_) => setState(() => _isHovered = false),
      child: GestureDetector(
        onTap: widget.onTap,
        child: Container(
          margin: const EdgeInsets.only(bottom: AppSpacing.sm),
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: _isHovered ? hoverBackgroundColor : backgroundColor,
            borderRadius: BorderRadius.circular(8),
            border: Border.all(
              color: AppColors.taskGradientStart.withValues(alpha: 0.2),
            ),
          ),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Checkbox indicator
              _buildCheckboxIndicator(),
              const SizedBox(width: 12),

              // Content
              Expanded(
                child: Builder(
                  builder: (context) {
                    final metadata = _buildMetadata(context);

                    return Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        // Title
                        _buildTitle(context),
                        const SizedBox(height: 4),

                        // Parent context
                        _buildParentContext(context),

                        // Metadata (due date, priority)
                        if (metadata != null) ...[
                          const SizedBox(height: 4),
                          metadata,
                        ],
                      ],
                    );
                  },
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
