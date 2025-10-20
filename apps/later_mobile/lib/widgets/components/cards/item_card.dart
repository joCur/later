import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_typography.dart';
import '../../../core/theme/app_spacing.dart';
import '../../../core/theme/app_animations.dart';
import '../../../core/responsive/breakpoints.dart';
import '../../../data/models/item_model.dart';
import '../text/gradient_text.dart';
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
    this.index,
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

  /// Index in the list for staggered entrance animation
  /// If null, no entrance animation is applied
  final int? index;

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
      duration: const Duration(milliseconds: 250),
      vsync: this,
    );

    // Create scale animation: 1.0 -> 1.1 -> 1.0 (enhanced for Temporal Flow)
    _checkboxScaleAnimation = TweenSequence<double>([
      TweenSequenceItem(
        tween: Tween<double>(begin: 1.0, end: 1.1)
            .chain(CurveTween(curve: Curves.easeOut)),
        weight: 50.0,
      ),
      TweenSequenceItem(
        tween: Tween<double>(begin: 1.1, end: 1.0)
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

  /// Get border gradient based on item type
  LinearGradient _getBorderGradient() {
    final isCompleted = widget.item.isCompleted && widget.item.type == ItemType.task;

    if (isCompleted) {
      // Green gradient for completed tasks
      return const LinearGradient(
        colors: [AppColors.success, AppColors.successLight],
      );
    }

    switch (widget.item.type) {
      case ItemType.task:
        return AppColors.taskGradient;
      case ItemType.note:
        return AppColors.noteGradient;
      case ItemType.list:
        return AppColors.listGradient;
    }
  }

  /// Get background color with subtle gradient tint (5% opacity)
  Color _getBackgroundTint(bool isDark) {
    return AppColors.typeLightBg(
      widget.item.type.toString().split('.').last,
      isDark: isDark,
    );
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
                            // Trigger medium haptic feedback for checkbox toggle
                            // Medium haptic provides satisfying confirmation of state change
                            AppAnimations.mediumHaptic();

                            // Trigger scale animation (1.0 → 1.1 → 1.0)
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
    // Apply gradient shader to the icon
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

    final dateFormat = DateFormat('MMM d, y');

    return Row(
      children: [
        // Date - Use gradient text for visual emphasis
        if (widget.item.dueDate != null) ...[
          // Icon with gradient tint for due dates
          ShaderMask(
            shaderCallback: (bounds) => AppColors.secondaryGradient.createShader(bounds),
            blendMode: BlendMode.srcIn,
            child: const Icon(
              Icons.calendar_today,
              size: 12,
              color: Colors.white,
            ),
          ),
          const SizedBox(width: AppSpacing.xxxs),
          // Due date with subtle secondary gradient (amber→pink)
          GradientText.subtle(
            dateFormat.format(widget.item.dueDate!),
            gradient: AppColors.secondaryGradient,
            style: AppTypography.metadata,
          ),
        ] else ...[
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
      ],
    );
  }

  void _handleTapDown(TapDownDetails details) {
    setState(() => _isPressed = true);
    // Light haptic on card press
    AppAnimations.lightHaptic();
  }

  void _handleTapUp(TapUpDetails details) {
    setState(() => _isPressed = false);
  }

  void _handleTapCancel() {
    setState(() => _isPressed = false);
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
    final isMobile = context.isMobile;
    final isCompleted = widget.item.isCompleted && widget.item.type == ItemType.task;

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

    // Card opacity for completed tasks (70% for Temporal Flow)
    final opacity = isCompleted ? 0.7 : 1.0;

    // Build the card widget
    final cardWidget = RepaintBoundary(
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
                borderRadius: BorderRadius.circular(AppSpacing.cardRadius), // 12px
                // Add soft, diffused shadow (4px blur, 10% opacity)
                boxShadow: _isPressed
                    ? null
                    : [
                        BoxShadow(
                          color: (isDark ? AppColors.shadowDark : AppColors.shadowLight)
                              .withValues(alpha: 0.1),
                          blurRadius: 4,
                          offset: const Offset(0, 2),
                        ),
                      ],
              ),
              // Clip the content to follow the border radius
              clipBehavior: Clip.antiAlias,
              child: Stack(
                children: [
                  // Main content with top padding for the gradient border
                  Padding(
                    padding: EdgeInsets.only(
                      top: 3.0, // Height of gradient border
                      left: isMobile ? 12 : AppSpacing.sm,
                      right: isMobile ? 12 : AppSpacing.sm,
                      bottom: isMobile ? 12 : AppSpacing.sm,
                    ),
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
                  // Top gradient border positioned absolutely
                  Positioned(
                    top: 0,
                    left: 0,
                    right: 0,
                    child: Container(
                      height: 3.0,
                      decoration: BoxDecoration(
                        gradient: _getBorderGradient(),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );

    // Apply entrance animation if index is provided
    if (widget.index != null) {
      final delay = AppAnimations.itemEntranceStagger * widget.index!;
      final duration = AppAnimations.getDuration(context, AppAnimations.itemEntrance);

      return cardWidget
          .animate()
          .fadeIn(
            duration: duration,
            delay: delay,
            curve: AppAnimations.springCurve,
          )
          .slideY(
            begin: AppAnimations.itemEntranceSlideOffset.dy,
            end: 0,
            duration: duration,
            delay: delay,
            curve: AppAnimations.springCurve,
          )
          .scale(
            begin: const Offset(AppAnimations.itemEntranceScale, AppAnimations.itemEntranceScale),
            end: const Offset(1.0, 1.0),
            duration: duration,
            delay: delay,
            curve: AppAnimations.springCurve,
          );
    }

    // Return without entrance animation
    return cardWidget;
  }
}
