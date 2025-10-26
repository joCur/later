import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import 'package:later_mobile/design_system/tokens/tokens.dart';
import '../../data/models/space_model.dart';
import '../../providers/spaces_provider.dart';
import '../components/buttons/theme_toggle_button.dart';

/// Desktop sidebar navigation component
///
/// Provides persistent navigation for desktop devices (>= 1024px) with:
/// - Collapsible sidebar (240px expanded, 72px collapsed)
/// - Space list with item counts
/// - Keyboard navigation (1-9 for first 9 spaces)
/// - Hover states and tooltips
/// - Expand/collapse toggle
///
/// Connects to [SpacesProvider] to display and switch between spaces.
///
/// Example usage:
/// ```dart
/// Scaffold(
///   body: Row(
///     children: [
///       AppSidebar(
///         isExpanded: _isExpanded,
///         onToggleExpanded: () {
///           setState(() => _isExpanded = !_isExpanded);
///         },
///       ),
///       Expanded(child: content),
///     ],
///   ),
/// )
/// ```
class AppSidebar extends StatefulWidget {
  /// Creates a desktop sidebar.
  ///
  /// The [isExpanded] parameter controls the sidebar width.
  /// The [onToggleExpanded] callback is called when the user toggles expansion.
  const AppSidebar({
    super.key,
    this.isExpanded = true,
    this.onToggleExpanded,
  });

  /// Whether the sidebar is expanded (240px) or collapsed (72px).
  final bool isExpanded;

  /// Called when the user clicks the expand/collapse toggle button.
  final VoidCallback? onToggleExpanded;

  @override
  State<AppSidebar> createState() => _AppSidebarState();
}

class _AppSidebarState extends State<AppSidebar> {
  final FocusNode _focusNode = FocusNode();

  @override
  void initState() {
    super.initState();
    // Request focus to enable keyboard shortcuts
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _focusNode.requestFocus();
    });
  }

  @override
  void dispose() {
    _focusNode.dispose();
    super.dispose();
  }

  void _handleKeyEvent(KeyEvent event, SpacesProvider spacesProvider) {
    if (event is! KeyDownEvent) return;

    // Handle number keys 1-9 for space navigation
    final key = event.logicalKey;
    final spaces = spacesProvider.spaces;

    // Helper to switch space with haptic feedback
    void switchWithHaptic(String spaceId) {
      if (spacesProvider.currentSpace?.id != spaceId) {
        AppAnimations.selectionHaptic();
      }
      spacesProvider.switchSpace(spaceId);
    }

    if (key == LogicalKeyboardKey.digit1 && spaces.isNotEmpty) {
      switchWithHaptic(spaces[0].id);
    } else if (key == LogicalKeyboardKey.digit2 && spaces.length > 1) {
      switchWithHaptic(spaces[1].id);
    } else if (key == LogicalKeyboardKey.digit3 && spaces.length > 2) {
      switchWithHaptic(spaces[2].id);
    } else if (key == LogicalKeyboardKey.digit4 && spaces.length > 3) {
      switchWithHaptic(spaces[3].id);
    } else if (key == LogicalKeyboardKey.digit5 && spaces.length > 4) {
      switchWithHaptic(spaces[4].id);
    } else if (key == LogicalKeyboardKey.digit6 && spaces.length > 5) {
      switchWithHaptic(spaces[5].id);
    } else if (key == LogicalKeyboardKey.digit7 && spaces.length > 6) {
      switchWithHaptic(spaces[6].id);
    } else if (key == LogicalKeyboardKey.digit8 && spaces.length > 7) {
      switchWithHaptic(spaces[7].id);
    } else if (key == LogicalKeyboardKey.digit9 && spaces.length > 8) {
      switchWithHaptic(spaces[8].id);
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDarkMode = theme.brightness == Brightness.dark;
    final spacesProvider = context.watch<SpacesProvider>();

    return Focus(
      focusNode: _focusNode,
      onKeyEvent: (node, event) {
        _handleKeyEvent(event, spacesProvider);
        return KeyEventResult.handled;
      },
      child: AnimatedContainer(
        duration: AppAnimations.normal,
        curve: AppAnimations.springCurve,
        width: widget.isExpanded ? 240.0 : 72.0,
        child: Stack(
          children: [
            // Base surface with glass morphism
            ClipRect(
              child: BackdropFilter(
                filter: ImageFilter.blur(
                  sigmaX: AppColors.glassBlurRadius,
                  sigmaY: AppColors.glassBlurRadius,
                ),
                child: Container(
                  decoration: BoxDecoration(
                    color: (isDarkMode
                            ? AppColors.surfaceDark
                            : AppColors.surfaceLight)
                        .withValues(alpha: 0.9),
                    border: Border(
                      right: BorderSide(
                        color: isDarkMode
                            ? AppColors.borderDark
                            : AppColors.borderLight,
                      ),
                    ),
                  ),
                ),
              ),
            ),

            // Gradient overlay at top (10% opacity)
            Positioned(
              top: 0,
              left: 0,
              right: 0,
              height: 120,
              child: Container(
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                    colors: [
                      (isDarkMode
                              ? AppColors.primaryStartDark
                              : AppColors.primaryStart)
                          .withValues(alpha: 0.1),
                      Colors.transparent,
                    ],
                  ),
                ),
              ),
            ),

            // Content
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Header with toggle button
                _buildHeader(isDarkMode),

                // Divider
                const Divider(
                  height: 1,
                  thickness: AppSpacing.borderWidthThin,
                ),

                // Spaces list
                Expanded(
                  child: _buildSpacesList(spacesProvider, isDarkMode),
                ),

                // Footer with settings
                _buildFooter(isDarkMode),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildHeader(bool isDarkMode) {
    return Container(
      height: 64.0,
      padding: EdgeInsets.symmetric(
        horizontal: widget.isExpanded
            ? AppSpacing.sm
            : AppSpacing.xs,
      ),
      child: Row(
        mainAxisAlignment: widget.isExpanded
            ? MainAxisAlignment.spaceBetween
            : MainAxisAlignment.center,
        children: [
          if (widget.isExpanded)
            Text(
              'Spaces',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.w600,
                color: isDarkMode
                    ? AppColors.textPrimaryDark
                    : AppColors.textPrimaryLight,
              ),
            ),
          if (widget.onToggleExpanded != null)
            Tooltip(
              message: widget.isExpanded ? 'Collapse sidebar' : 'Expand sidebar',
              child: IconButton(
                icon: Icon(
                  widget.isExpanded
                      ? Icons.menu_open
                      : Icons.menu,
                ),
                onPressed: widget.onToggleExpanded,
                color: isDarkMode
                    ? AppColors.textSecondaryDark
                    : AppColors.textSecondaryLight,
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildSpacesList(SpacesProvider spacesProvider, bool isDarkMode) {
    final spaces = spacesProvider.spaces;

    if (spaces.isEmpty) {
      return Center(
        child: widget.isExpanded
            ? const Padding(
                padding: EdgeInsets.all(AppSpacing.sm),
                child: Text(
                  'No spaces yet',
                  textAlign: TextAlign.center,
                ),
              )
            : const Icon(
                Icons.inbox_outlined,
              ),
      );
    }

    return ListView.builder(
      padding: const EdgeInsets.symmetric(vertical: AppSpacing.xs),
      itemCount: spaces.length,
      itemBuilder: (context, index) {
        final space = spaces[index];
        final isSelected = spacesProvider.currentSpace?.id == space.id;
        final keyboardShortcut = index < 9 ? '${index + 1}' : null;

        return _SpaceListItem(
          space: space,
          isSelected: isSelected,
          isExpanded: widget.isExpanded,
          isDarkMode: isDarkMode,
          keyboardShortcut: keyboardShortcut,
          onTap: () {
            // Only trigger haptic if actually changing spaces
            if (spacesProvider.currentSpace?.id != space.id) {
              AppAnimations.selectionHaptic();
            }
            spacesProvider.switchSpace(space.id);
          },
        );
      },
    );
  }

  Widget _buildFooter(bool isDarkMode) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        // Gradient separator line
        Container(
          height: 1,
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: [
                Colors.transparent,
                (isDarkMode
                        ? AppColors.primaryStartDark
                        : AppColors.primaryStart)
                    .withValues(alpha: 0.2),
                Colors.transparent,
              ],
            ),
          ),
        ),
        Container(
          padding: const EdgeInsets.all(AppSpacing.xs),
          child: Row(
            mainAxisAlignment: widget.isExpanded
                ? MainAxisAlignment.start
                : MainAxisAlignment.center,
            children: [
              // Theme toggle button
              const ThemeToggleButton(),

              if (widget.isExpanded) ...[
                const SizedBox(width: AppSpacing.gapSM),
                // Settings button
                Expanded(
                  child: Tooltip(
                    message: 'Settings',
                    child: InkWell(
                      onTap: () {
                        // Navigate to settings
                      },
                      borderRadius: const BorderRadius.all(
                        Radius.circular(AppSpacing.radiusSM),
                      ),
                      child: Container(
                        height: AppSpacing.minTouchTarget,
                        padding: const EdgeInsets.symmetric(
                          horizontal: AppSpacing.sm,
                        ),
                        child: const Row(
                          children: [
                            Icon(Icons.settings_outlined),
                            SizedBox(width: AppSpacing.gapSM),
                            Text('Settings'),
                          ],
                        ),
                      ),
                    ),
                  ),
                ),
              ] else ...[
                // In collapsed state, show settings icon below
                const SizedBox.shrink(),
              ],
            ],
          ),
        ),
        // Show settings button below in collapsed mode
        if (!widget.isExpanded)
          Container(
            padding: const EdgeInsets.all(AppSpacing.xs),
            child: Tooltip(
              message: 'Settings',
              child: InkWell(
                onTap: () {
                  // Navigate to settings
                },
                borderRadius: const BorderRadius.all(
                  Radius.circular(AppSpacing.radiusSM),
                ),
                child: Container(
                  height: AppSpacing.minTouchTarget,
                  padding: const EdgeInsets.symmetric(
                    horizontal: AppSpacing.xs,
                  ),
                  child: const Icon(Icons.settings_outlined),
                ),
              ),
            ),
          ),
      ],
    );
  }
}

/// Individual space list item with hover states and keyboard shortcuts
class _SpaceListItem extends StatefulWidget {
  const _SpaceListItem({
    required this.space,
    required this.isSelected,
    required this.isExpanded,
    required this.isDarkMode,
    required this.onTap,
    this.keyboardShortcut,
  });

  final Space space;
  final bool isSelected;
  final bool isExpanded;
  final bool isDarkMode;
  final VoidCallback onTap;
  final String? keyboardShortcut;

  @override
  State<_SpaceListItem> createState() => _SpaceListItemState();
}

class _SpaceListItemState extends State<_SpaceListItem> {
  bool _isHovered = false;

  LinearGradient _getTypeGradient() {
    // For now, use color field if available to determine gradient
    // In the future, this could be based on a space type field
    final spaceColor = widget.space.color;
    if (spaceColor != null) {
      // Map colors to gradients
      if (spaceColor.contains('red') || spaceColor.contains('orange')) {
        return AppColors.taskGradient;
      } else if (spaceColor.contains('blue') || spaceColor.contains('cyan')) {
        return AppColors.noteGradient;
      } else if (spaceColor.contains('violet') || spaceColor.contains('purple')) {
        return AppColors.listGradient;
      }
    }

    return widget.isDarkMode
        ? AppColors.primaryGradientDark
        : AppColors.primaryGradient;
  }

  @override
  Widget build(BuildContext context) {
    final gradient = _getTypeGradient();

    final textColor = widget.isSelected
        ? (widget.isDarkMode
            ? AppColors.textPrimaryDark
            : AppColors.textPrimaryLight)
        : (widget.isDarkMode
            ? AppColors.textSecondaryDark
            : AppColors.textSecondaryLight);

    return Padding(
      padding: const EdgeInsets.symmetric(
        horizontal: AppSpacing.xs,
        vertical: AppSpacing.xxxs,
      ),
      child: Semantics(
        label: widget.isExpanded
            ? '${widget.space.name}, ${widget.space.itemCount} items${widget.keyboardShortcut != null ? ", keyboard shortcut ${widget.keyboardShortcut}" : ""}'
            : widget.space.name,
        selected: widget.isSelected,
        button: true,
        child: MouseRegion(
          onEnter: (_) => setState(() => _isHovered = true),
          onExit: (_) => setState(() => _isHovered = false),
          child: Tooltip(
            message: widget.isExpanded
                ? (widget.keyboardShortcut != null
                    ? 'Press ${widget.keyboardShortcut} to switch'
                    : widget.space.name)
                : '${widget.space.name} (${widget.space.itemCount} items)',
            child: InkWell(
              onTap: widget.onTap,
              borderRadius: const BorderRadius.all(
                Radius.circular(AppSpacing.radiusSM),
              ),
              child: Stack(
                children: [
                  // Base container
                  Container(
                    height: AppSpacing.minTouchTarget,
                    padding: EdgeInsets.symmetric(
                      horizontal: widget.isExpanded
                          ? AppSpacing.sm
                          : AppSpacing.xs,
                    ),
                    decoration: BoxDecoration(
                      color: widget.isSelected
                          ? (widget.isDarkMode
                              ? AppColors.selectedDark
                              : AppColors.selectedLight)
                          : (_isHovered
                              ? (widget.isDarkMode
                                  ? AppColors.surfaceDarkVariant
                                  : AppColors.surfaceLightVariant)
                              : Colors.transparent),
                      borderRadius: const BorderRadius.all(
                        Radius.circular(AppSpacing.radiusSM),
                      ),
                    ),
                    child: Row(
                      mainAxisAlignment: widget.isExpanded
                          ? MainAxisAlignment.spaceBetween
                          : MainAxisAlignment.center,
                      children: [
                        if (widget.isExpanded)
                          Expanded(
                            child: Row(
                              children: [
                                // Icon with gradient tint container
                                if (widget.space.icon != null) ...[
                                  Container(
                                    padding: const EdgeInsets.all(2),
                                    decoration: BoxDecoration(
                                      gradient: gradient.scale(0.1),
                                      borderRadius: BorderRadius.circular(
                                        AppSpacing.radiusXS,
                                      ),
                                    ),
                                    child: Text(
                                      widget.space.icon!,
                                      style: const TextStyle(fontSize: 20),
                                    ),
                                  ),
                                  const SizedBox(width: AppSpacing.gapSM),
                                ],
                                // Space name
                                Expanded(
                                  child: Text(
                                    widget.space.name,
                                    style: TextStyle(
                                      color: textColor,
                                      fontWeight: widget.isSelected
                                          ? FontWeight.w600
                                          : FontWeight.normal,
                                    ),
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                ),
                              ],
                            ),
                          )
                        else
                          // Collapsed view - icon with gradient background
                          Container(
                            padding: const EdgeInsets.all(4),
                            decoration: BoxDecoration(
                              gradient: widget.isSelected
                                  ? gradient.scale(0.15)
                                  : null,
                              borderRadius: BorderRadius.circular(
                                AppSpacing.radiusXS,
                              ),
                            ),
                            child: Text(
                              widget.space.icon ?? widget.space.name[0].toUpperCase(),
                              style: TextStyle(
                                fontSize: widget.space.icon != null ? 20 : 16,
                                color: textColor,
                                fontWeight: widget.isSelected
                                    ? FontWeight.w600
                                    : FontWeight.normal,
                              ),
                            ),
                          ),

                        // Item count badge
                        if (widget.isExpanded && widget.space.itemCount > 0)
                          Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: AppSpacing.xs,
                              vertical: AppSpacing.xxxs,
                            ),
                            decoration: BoxDecoration(
                              color: widget.isDarkMode
                                  ? AppColors.surfaceDarkVariant
                                  : AppColors.surfaceLightVariant,
                              borderRadius: BorderRadius.circular(
                                AppSpacing.radiusFull,
                              ),
                            ),
                            child: Text(
                              widget.space.itemCount.toString(),
                              style: TextStyle(
                                fontSize: 12,
                                color: textColor,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                          ),
                      ],
                    ),
                  ),

                  // Gradient hover overlay (5% opacity)
                  if (_isHovered && !widget.isSelected)
                    Positioned.fill(
                      child: Container(
                        decoration: BoxDecoration(
                          gradient: gradient.scale(0.05),
                          borderRadius: const BorderRadius.all(
                            Radius.circular(AppSpacing.radiusSM),
                          ),
                        ),
                      ),
                    ),

                  // Gradient active indicator pill (left-aligned)
                  if (widget.isSelected)
                    Positioned(
                      left: 0,
                      top: AppSpacing.xs,
                      bottom: AppSpacing.xs,
                      child: Container(
                        width: 3,
                        decoration: BoxDecoration(
                          gradient: gradient,
                          borderRadius: BorderRadius.circular(
                            AppSpacing.radiusFull,
                          ),
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
  }
}

// Extension to scale gradient opacity
extension on LinearGradient {
  // ignore: unused_element
  LinearGradient scale(double opacity) {
    return LinearGradient(
      begin: begin,
      end: end,
      colors: colors.map((c) => c.withValues(alpha: opacity)).toList(),
    );
  }
}
