import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_typography.dart';
import '../../../core/theme/app_spacing.dart';
import '../../../core/theme/app_animations.dart';
import '../../../data/models/todo_list_model.dart';
import '../text/gradient_text.dart';
import '../borders/gradient_pill_border.dart';
import 'package:intl/intl.dart';

/// TodoList card component for displaying todo lists with progress tracking
/// Mobile-First Bold Redesign
///
/// Performance optimizations:
/// - Uses RepaintBoundary to isolate repaints
/// - Const constructors where possible
/// - ValueKey for efficient list updates
/// - Optimized 6px gradient border for 60fps performance
///
/// Mobile-First Bold Design Features:
/// - 6px gradient pill border (red-orange task gradient)
/// - 20px border radius (pill shape)
/// - 18px bold title
/// - 20px card padding (comfortable thumb zones)
/// - Progress indicator showing "X of Y completed"
/// - Linear progress bar with success color
/// - Checkbox outline icon with gradient
/// - Due date metadata from earliest item
/// - Press animations with haptic feedback
/// - Entrance animations with staggered delay
/// - Semantic labels for accessibility
class TodoListCard extends StatefulWidget {
  const TodoListCard({
    super.key,
    required this.todoList,
    this.onTap,
    this.onLongPress,
    this.showMetadata = true,
    this.index,
  });

  /// TodoList data to display
  final TodoList todoList;

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
  State<TodoListCard> createState() => _TodoListCardState();
}

class _TodoListCardState extends State<TodoListCard> with TickerProviderStateMixin {
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

  /// Get border gradient (red-orange task gradient for todo lists)
  LinearGradient _getBorderGradient() {
    return AppColors.taskGradient;
  }

  /// Get background color with subtle gradient tint (5% opacity)
  Color _getBackgroundTint(bool isDark) {
    return AppColors.typeLightBg('task', isDark: isDark);
  }

  /// Build leading icon (checkbox outline with gradient)
  Widget _buildLeadingIcon() {
    final gradient = _getBorderGradient();

    return SizedBox(
      width: 48,
      height: 48,
      child: Center(
        child: ShaderMask(
          shaderCallback: (bounds) => gradient.createShader(bounds),
          child: const Icon(
            Icons.check_box_outline_blank,
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
      widget.todoList.name,
      style: AppTypography.itemTitle.copyWith(
        color: isDark ? AppColors.textPrimaryDark : AppColors.textPrimaryLight,
      ),
      maxLines: AppTypography.itemTitleMaxLines,
      overflow: TextOverflow.ellipsis,
    );
  }

  /// Build progress text (e.g., "4 of 7 completed")
  Widget _buildProgressText(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final completed = widget.todoList.completedItems;
    final total = widget.todoList.totalItems;

    return Text(
      '$completed of $total completed',
      style: AppTypography.metadata.copyWith(
        color: isDark ? AppColors.textSecondaryDark : AppColors.textSecondaryLight,
      ),
    );
  }

  /// Build progress bar
  Widget _buildProgressBar() {
    final progress = widget.todoList.progress;

    return LinearProgressIndicator(
      value: progress,
      backgroundColor: AppColors.neutral200,
      valueColor: const AlwaysStoppedAnimation<Color>(AppColors.success),
      minHeight: 4,
      borderRadius: BorderRadius.circular(2),
    );
  }

  /// Get earliest due date from items
  DateTime? _getEarliestDueDate() {
    final itemsWithDueDates = widget.todoList.items
        .where((item) => item.dueDate != null)
        .toList();

    if (itemsWithDueDates.isEmpty) return null;

    itemsWithDueDates.sort((a, b) => a.dueDate!.compareTo(b.dueDate!));
    return itemsWithDueDates.first.dueDate;
  }

  /// Build metadata row
  Widget? _buildMetadata(BuildContext context) {
    if (!widget.showMetadata) return null;

    final earliestDueDate = _getEarliestDueDate();
    if (earliestDueDate == null) return null;

    final dateFormat = DateFormat('MMM d, y');

    return Row(
      children: [
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
          dateFormat.format(earliestDueDate),
          gradient: AppColors.secondaryGradient,
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
    final semanticLabel = 'Todo list: ${widget.todoList.name}, '
        '${widget.todoList.completedItems} of ${widget.todoList.totalItems} completed';

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
                      // Leading icon (checkbox outline)
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

                            // Progress text
                            const SizedBox(height: AppSpacing.xxs), // 4px
                            _buildProgressText(context),

                            // Progress bar
                            const SizedBox(height: AppSpacing.xs), // 8px
                            _buildProgressBar(),

                            // Metadata (due date if available)
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
