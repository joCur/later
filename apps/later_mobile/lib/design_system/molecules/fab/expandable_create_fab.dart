import 'package:flutter/material.dart';
import 'package:later_mobile/core/theme/temporal_flow_theme.dart';
import 'package:later_mobile/core/utils/item_type_detector.dart';
import 'package:later_mobile/design_system/tokens/tokens.dart';

/// Expandable FAB option
class FabOption {
  const FabOption({
    required this.label,
    required this.icon,
    required this.type,
  });

  final String label;
  final IconData icon;
  final ContentType type;
}

/// Expandable Create Content FAB (Speed Dial)
///
/// Opens to reveal three create options: Todo, List, Note
///
/// Features:
/// - Main FAB with plus icon (rotates 45° when open)
/// - Three mini FABs that slide up when expanded
/// - Each option opens the modal with a specific type
/// - Backdrop overlay when expanded
/// - Smooth spring animations
class ExpandableCreateFab extends StatefulWidget {
  const ExpandableCreateFab({
    super.key,
    required this.onOptionSelected,
    this.heroTag = 'create-content-fab',
  });

  /// Callback when an option is selected
  final Function(ContentType) onOptionSelected;

  /// Hero tag for animation
  final Object heroTag;

  static const List<FabOption> options = [
    FabOption(
      label: 'Note',
      icon: Icons.description_outlined,
      type: ContentType.note,
    ),
    FabOption(
      label: 'List',
      icon: Icons.list_alt,
      type: ContentType.list,
    ),
    FabOption(
      label: 'Todo',
      icon: Icons.check_box_outlined,
      type: ContentType.todoList,
    ),
  ];

  @override
  State<ExpandableCreateFab> createState() => _ExpandableCreateFabState();
}

class _ExpandableCreateFabState extends State<ExpandableCreateFab>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _rotationAnimation;
  late Animation<double> _scaleAnimation;
  bool _isExpanded = false;

  @override
  void initState() {
    super.initState();

    _controller = AnimationController(
      duration: const Duration(milliseconds: 250),
      vsync: this,
    );

    _rotationAnimation = Tween<double>(begin: 0.0, end: 0.125).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeOut),
    );

    _scaleAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeOut),
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _toggle() {
    setState(() {
      _isExpanded = !_isExpanded;
      if (_isExpanded) {
        _controller.forward();
      } else {
        _controller.reverse();
      }
    });
  }

  void _selectOption(ContentType type) {
    _toggle();
    Future.delayed(const Duration(milliseconds: 100), () {
      widget.onOptionSelected(type);
    });
  }

  @override
  Widget build(BuildContext context) {
    final temporalTheme = Theme.of(context).extension<TemporalFlowTheme>()!;

    return Stack(
      alignment: Alignment.bottomRight,
      children: [
        // Backdrop overlay
        if (_isExpanded)
          Positioned.fill(
            child: GestureDetector(
              onTap: _toggle,
              child: AnimatedOpacity(
                duration: const Duration(milliseconds: 200),
                opacity: _isExpanded ? 1.0 : 0.0,
                child: Container(
                  color: Colors.black.withValues(alpha: 0.3),
                ),
              ),
            ),
          ),

        // Mini FABs (options)
        ...List.generate(
          ExpandableCreateFab.options.length,
          (index) {
            final option = ExpandableCreateFab.options[index];
            final offset = (index + 1) * 72.0; // 72px spacing between buttons

            return AnimatedBuilder(
              animation: _controller,
              builder: (context, child) {
                return Transform.translate(
                  offset: Offset(0, -offset * _scaleAnimation.value),
                  child: Transform.scale(
                    scale: _scaleAnimation.value,
                    child: Opacity(
                      opacity: _scaleAnimation.value,
                      child: child,
                    ),
                  ),
                );
              },
              child: _buildMiniFab(
                option.label,
                option.icon,
                () => _selectOption(option.type),
                temporalTheme,
              ),
            );
          },
        ),

        // Main FAB
        FloatingActionButton(
          heroTag: widget.heroTag,
          onPressed: _toggle,
          elevation: 8,
          backgroundColor: Colors.transparent,
          child: AnimatedBuilder(
            animation: _rotationAnimation,
            builder: (context, child) {
              return RotationTransition(
                turns: _rotationAnimation,
                child: Container(
                  width: 56,
                  height: 56,
                  decoration: BoxDecoration(
                    gradient: temporalTheme.primaryGradient,
                    shape: BoxShape.circle,
                    boxShadow: [
                      BoxShadow(
                        color: temporalTheme.primaryGradient.colors.first
                            .withValues(alpha: 0.3),
                        blurRadius: 16,
                        offset: const Offset(0, 8),
                      ),
                    ],
                  ),
                  child: const Icon(
                    Icons.add,
                    color: Colors.white,
                    size: 24,
                  ),
                ),
              );
            },
          ),
        ),
      ],
    );
  }

  Widget _buildMiniFab(
    String label,
    IconData icon,
    VoidCallback onPressed,
    TemporalFlowTheme theme,
  ) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        // Label
        Material(
          elevation: 4,
          borderRadius: BorderRadius.circular(8),
          child: Container(
            padding: const EdgeInsets.symmetric(
              horizontal: AppSpacing.sm,
              vertical: AppSpacing.xs,
            ),
            decoration: BoxDecoration(
              color: AppColors.surface(context),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Text(
              label,
              style: AppTypography.labelMedium.copyWith(
                color: AppColors.text(context),
              ),
            ),
          ),
        ),
        const SizedBox(width: AppSpacing.xs),

        // Mini FAB button
        FloatingActionButton.small(
          heroTag: 'mini-fab-$label',
          onPressed: onPressed,
          elevation: 6,
          backgroundColor: Colors.transparent,
          child: Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              gradient: theme.primaryGradient,
              shape: BoxShape.circle,
            ),
            child: Icon(
              icon,
              color: Colors.white,
              size: 20,
            ),
          ),
        ),
      ],
    );
  }
}
