import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_typography.dart';
import '../../../core/theme/app_spacing.dart';
import '../../../core/responsive/breakpoints.dart';
import '../../../data/models/item_model.dart';
import 'package:intl/intl.dart';

/// Unified item card component for tasks, notes, and lists
///
/// Performance optimizations:
/// - Uses RepaintBoundary to isolate repaints
/// - Const constructors where possible
/// - ValueKey for efficient list updates
///
/// Features:
/// - Three variants: TaskCard, NoteCard, ListCard
/// - 4px colored left border (blue/amber/violet based on type)
/// - Leading element: checkbox for tasks, icon for notes/lists
/// - Title: H4 typography, max 2 lines with ellipsis
/// - Content preview: 2 lines mobile, 3 lines desktop
/// - Metadata row: space indicator, date, item count for lists
/// - All states: default, hover, selected, pressed, completed (tasks)
/// - Gesture handlers: tap to open, long-press for multi-select
/// - Responsive behavior across breakpoints
class ItemCard extends StatefulWidget {
  const ItemCard({
    super.key,
    required this.item,
    this.onTap,
    this.onLongPress,
    this.onCheckboxChanged,
    this.isSelected = false,
    this.showMetadata = true,
  });

  /// Item data to display
  final Item item;

  /// Callback when card is tapped
  final VoidCallback? onTap;

  /// Callback when card is long-pressed
  final VoidCallback? onLongPress;

  /// Callback when checkbox is changed (tasks only)
  final ValueChanged<bool>? onCheckboxChanged;

  /// Whether card is in selected state
  final bool isSelected;

  /// Whether to show metadata row
  final bool showMetadata;

  @override
  State<ItemCard> createState() => _ItemCardState();
}

class _ItemCardState extends State<ItemCard> with SingleTickerProviderStateMixin {
  bool _isPressed = false;
  late AnimationController _checkboxAnimationController;
  late Animation<double> _checkboxScaleAnimation;

  @override
  void initState() {
    super.initState();

    // Initialize checkbox animation controller
    _checkboxAnimationController = AnimationController(
      duration: const Duration(milliseconds: 150),
      vsync: this,
    );

    // Create scale animation: 1.0 -> 1.05 -> 1.0
    _checkboxScaleAnimation = TweenSequence<double>([
      TweenSequenceItem(
        tween: Tween<double>(begin: 1.0, end: 1.05)
            .chain(CurveTween(curve: Curves.easeOut)),
        weight: 50.0,
      ),
      TweenSequenceItem(
        tween: Tween<double>(begin: 1.05, end: 1.0)
            .chain(CurveTween(curve: Curves.easeIn)),
        weight: 50.0,
      ),
    ]).animate(_checkboxAnimationController);
  }

  @override
  void dispose() {
    _checkboxAnimationController.dispose();
    super.dispose();
  }

  /// Get border color based on item type
  Color _getBorderColor() {
    if (widget.item.isCompleted && widget.item.type == ItemType.task) {
      return AppColors.accentGreen;
    }

    switch (widget.item.type) {
      case ItemType.task:
        return AppColors.itemBorderTask;
      case ItemType.note:
        return AppColors.itemBorderNote;
      case ItemType.list:
        return AppColors.itemBorderList;
    }
  }

  /// Get leading icon for notes and lists
  IconData _getLeadingIcon() {
    switch (widget.item.type) {
      case ItemType.task:
        return Icons.check_box_outline_blank;
      case ItemType.note:
        return Icons.description_outlined;
      case ItemType.list:
        return Icons.list_alt;
    }
  }

  /// Build leading element (checkbox for tasks, icon for notes/lists)
  Widget _buildLeadingElement() {
    if (widget.item.type == ItemType.task) {
      // Wrap in GestureDetector to prevent tap events from propagating to card
      return GestureDetector(
        onTap: () {
          // Absorb the tap event to prevent card's onTapDown from firing
        },
        onTapDown: (_) {
          // Absorb the tap down event
        },
        onTapUp: (_) {
          // Absorb the tap up event
        },
        child: SizedBox(
          // Expanded touch target (48×48px) for accessibility compliance
          // WCAG 2.5.5 requires 44×44dp minimum, 48×48px exceeds this
          width: 48,
          height: 48,
          child: Center(
            child: AnimatedBuilder(
              animation: _checkboxScaleAnimation,
              builder: (context, child) {
                return Transform.scale(
                  scale: _checkboxScaleAnimation.value,
                  child: child,
                );
              },
              child: SizedBox(
                width: 24,
                height: 24,
                child: Checkbox(
                  value: widget.item.isCompleted,
                  onChanged: widget.onCheckboxChanged != null
                      ? (value) {
                          if (value != null) {
                            // Trigger haptic feedback
                            HapticFeedback.lightImpact();

                            // Trigger scale animation
                            _checkboxAnimationController.forward(from: 0.0);

                            // Call the callback
                            widget.onCheckboxChanged?.call(value);
                          }
                        }
                      : null,
                  activeColor: AppColors.accentGreen,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(AppSpacing.radiusSM),
                  ),
                  // Use standard Material touch target for better accessibility
                  splashRadius: 20,
                  materialTapTargetSize: MaterialTapTargetSize.padded,
                  visualDensity: VisualDensity.standard,
                ),
              ),
            ),
          ),
        ),
      );
    }

    // For notes and lists, use same 48×48px container for alignment
    return SizedBox(
      width: 48,
      height: 48,
      child: Center(
        child: Icon(
          _getLeadingIcon(),
          size: 20,
          color: _getBorderColor(),
        ),
      ),
    );
  }

  /// Build title with proper styling
  Widget _buildTitle(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final isCompleted = widget.item.isCompleted && widget.item.type == ItemType.task;

    return Text(
      widget.item.title,
      style: AppTypography.itemTitle.copyWith(
        color: isCompleted
            ? (isDark ? AppColors.textSecondaryDark : AppColors.textSecondaryLight)
            : (isDark ? AppColors.textPrimaryDark : AppColors.textPrimaryLight),
        decoration: isCompleted ? TextDecoration.lineThrough : null,
      ),
      maxLines: 2,
      overflow: TextOverflow.ellipsis,
    );
  }

  /// Build content preview for notes
  Widget? _buildContentPreview(BuildContext context) {
    if (widget.item.content == null || widget.item.content!.isEmpty) {
      return null;
    }

    final isDark = Theme.of(context).brightness == Brightness.dark;
    final isMobile = context.isMobile;
    final maxLines = isMobile ? 2 : 3;

    return Text(
      widget.item.content!,
      style: AppTypography.itemContent.copyWith(
        color: isDark ? AppColors.textSecondaryDark : AppColors.textSecondaryLight,
      ),
      maxLines: maxLines,
      overflow: TextOverflow.ellipsis,
    );
  }

  /// Build metadata row
  Widget? _buildMetadata(BuildContext context) {
    if (!widget.showMetadata) return null;

    final isDark = Theme.of(context).brightness == Brightness.dark;
    final dateFormat = DateFormat('MMM d, y');

    return Row(
      children: [
        // Date
        if (widget.item.dueDate != null) ...[
          Icon(
            Icons.calendar_today,
            size: 12,
            color: isDark ? AppColors.textDisabledDark : AppColors.textDisabledLight,
          ),
          const SizedBox(width: AppSpacing.xxxs),
          Text(
            dateFormat.format(widget.item.dueDate!),
            style: AppTypography.metadata.copyWith(
              color: isDark ? AppColors.textDisabledDark : AppColors.textDisabledLight,
            ),
          ),
        ] else ...[
          Icon(
            Icons.access_time,
            size: 12,
            color: isDark ? AppColors.textDisabledDark : AppColors.textDisabledLight,
          ),
          const SizedBox(width: AppSpacing.xxxs),
          Text(
            dateFormat.format(widget.item.createdAt),
            style: AppTypography.metadata.copyWith(
              color: isDark ? AppColors.textDisabledDark : AppColors.textDisabledLight,
            ),
          ),
        ],
      ],
    );
  }

  void _handleTapDown(TapDownDetails details) {
    setState(() => _isPressed = true);
    HapticFeedback.lightImpact();
  }

  void _handleTapUp(TapUpDetails details) {
    setState(() => _isPressed = false);
  }

  void _handleTapCancel() {
    setState(() => _isPressed = false);
  }

  void _handleTap() {
    HapticFeedback.lightImpact();
    widget.onTap?.call();
  }

  void _handleLongPress() {
    HapticFeedback.mediumImpact();
    widget.onLongPress?.call();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final isMobile = context.isMobile;

    // Background color based on state
    Color backgroundColor;
    if (widget.isSelected) {
      backgroundColor = isDark
          ? AppColors.primaryAmber.withValues(alpha: 0.15)
          : AppColors.primaryAmber.withValues(alpha: 0.1);
    } else if (_isPressed) {
      backgroundColor = isDark
          ? AppColors.surfaceDarkVariant // Subtle dark gray for pressed state
          : AppColors.neutralGray100;
    } else {
      backgroundColor = isDark
          ? AppColors.surfaceDark
          : AppColors.surfaceLight;
    }

    // Border width
    final borderWidth = widget.isSelected
        ? AppSpacing.radiusSM
        : AppSpacing.itemBorderWidth;

    // Card opacity for completed tasks
    final opacity = widget.item.isCompleted && widget.item.type == ItemType.task
        ? 0.7
        : 1.0;

    // Wrap with RepaintBoundary to isolate repaints
    return RepaintBoundary(
      child: Semantics(
        container: true,
        button: true,
        enabled: widget.onTap != null,
        label: '${widget.item.type.toString().split('.').last}: ${widget.item.title}',
        child: GestureDetector(
          onTapDown: _handleTapDown,
          onTapUp: _handleTapUp,
          onTapCancel: _handleTapCancel,
          onTap: _handleTap,
          onLongPress: _handleLongPress,
          child: Opacity(
            opacity: opacity,
            child: Container(
              margin: const EdgeInsets.only(bottom: AppSpacing.xxs),
              decoration: BoxDecoration(
                color: backgroundColor,
                borderRadius: BorderRadius.circular(AppSpacing.cardRadius),
                border: Border(
                  left: BorderSide(
                    color: _getBorderColor(),
                    width: borderWidth,
                  ),
                ),
                boxShadow: _isPressed
                    ? null
                    : [
                        BoxShadow(
                          color: isDark
                              ? AppColors.shadowDark
                              : AppColors.shadowLight,
                          blurRadius: 3,
                          offset: const Offset(0, 1),
                        ),
                      ],
              ),
              child: Padding(
                padding: EdgeInsets.all(isMobile ? 12 : AppSpacing.sm),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Leading element (checkbox or icon)
                    _buildLeadingElement(),
                    const SizedBox(width: AppSpacing.xxxs),

                    // Content
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          // Title
                          _buildTitle(context),

                          // Content preview (if available)
                          if (_buildContentPreview(context) != null) ...[
                            const SizedBox(height: AppSpacing.xxxs),
                            _buildContentPreview(context)!,
                          ],

                          // Metadata
                          if (_buildMetadata(context) != null) ...[
                            const SizedBox(height: AppSpacing.xxs),
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
    );
  }
}
