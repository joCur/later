import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_spacing.dart';
import '../../data/models/space_model.dart';
import '../../providers/spaces_provider.dart';

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

    if (key == LogicalKeyboardKey.digit1 && spaces.isNotEmpty) {
      spacesProvider.switchSpace(spaces[0].id);
    } else if (key == LogicalKeyboardKey.digit2 && spaces.length > 1) {
      spacesProvider.switchSpace(spaces[1].id);
    } else if (key == LogicalKeyboardKey.digit3 && spaces.length > 2) {
      spacesProvider.switchSpace(spaces[2].id);
    } else if (key == LogicalKeyboardKey.digit4 && spaces.length > 3) {
      spacesProvider.switchSpace(spaces[3].id);
    } else if (key == LogicalKeyboardKey.digit5 && spaces.length > 4) {
      spacesProvider.switchSpace(spaces[4].id);
    } else if (key == LogicalKeyboardKey.digit6 && spaces.length > 5) {
      spacesProvider.switchSpace(spaces[5].id);
    } else if (key == LogicalKeyboardKey.digit7 && spaces.length > 6) {
      spacesProvider.switchSpace(spaces[6].id);
    } else if (key == LogicalKeyboardKey.digit8 && spaces.length > 7) {
      spacesProvider.switchSpace(spaces[7].id);
    } else if (key == LogicalKeyboardKey.digit9 && spaces.length > 8) {
      spacesProvider.switchSpace(spaces[8].id);
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
        duration: const Duration(milliseconds: 200),
        curve: Curves.easeInOut,
        width: widget.isExpanded ? 240.0 : 72.0,
        decoration: BoxDecoration(
          color: isDarkMode
              ? AppColors.surfaceDark
              : AppColors.surfaceLight,
          border: const Border(
            right: BorderSide(),
          ),
        ),
        child: Column(
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
      ),
    );
  }

  Widget _buildHeader(bool isDarkMode) {
    return Container(
      height: 64.0,
      padding: EdgeInsets.symmetric(
        horizontal: widget.isExpanded
            ? AppSpacing.paddingSM
            : AppSpacing.paddingXS,
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
                padding: EdgeInsets.all(AppSpacing.paddingSM),
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
      padding: const EdgeInsets.symmetric(vertical: AppSpacing.paddingXS),
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
            spacesProvider.switchSpace(space.id);
          },
        );
      },
    );
  }

  Widget _buildFooter(bool isDarkMode) {
    return Container(
      padding: const EdgeInsets.all(AppSpacing.paddingXS),
      decoration: const BoxDecoration(
        border: Border(
          top: BorderSide(),
        ),
      ),
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
            padding: EdgeInsets.symmetric(
              horizontal: widget.isExpanded
                  ? AppSpacing.paddingSM
                  : AppSpacing.paddingXS,
            ),
            child: Row(
              mainAxisAlignment: widget.isExpanded
                  ? MainAxisAlignment.start
                  : MainAxisAlignment.center,
              children: [
                const Icon(Icons.settings_outlined),
                if (widget.isExpanded) ...[
                  const SizedBox(width: AppSpacing.gapSM),
                  const Text('Settings'),
                ],
              ],
            ),
          ),
        ),
      ),
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

  @override
  Widget build(BuildContext context) {
    final backgroundColor = widget.isSelected
        ? (widget.isDarkMode
            ? AppColors.selectedDark
            : AppColors.selectedLight)
        : (_isHovered
            ? (widget.isDarkMode
                ? AppColors.surfaceDarkVariant
                : AppColors.surfaceLightVariant)
            : Colors.transparent);

    final textColor = widget.isSelected
        ? (widget.isDarkMode
            ? AppColors.textPrimaryDark
            : AppColors.textPrimaryLight)
        : (widget.isDarkMode
            ? AppColors.textSecondaryDark
            : AppColors.textSecondaryLight);

    return Padding(
      padding: const EdgeInsets.symmetric(
        horizontal: AppSpacing.paddingXS,
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
              child: Container(
                height: AppSpacing.minTouchTarget,
                padding: EdgeInsets.symmetric(
                  horizontal: widget.isExpanded
                      ? AppSpacing.paddingSM
                      : AppSpacing.paddingXS,
                ),
                decoration: BoxDecoration(
                  color: backgroundColor,
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
                            // Icon or emoji
                            if (widget.space.icon != null) ...[
                              Text(
                                widget.space.icon!,
                                style: const TextStyle(fontSize: 20),
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
                      // Collapsed view - just show icon or first letter
                      Text(
                        widget.space.icon ?? widget.space.name[0].toUpperCase(),
                        style: TextStyle(
                          fontSize: widget.space.icon != null ? 20 : 16,
                          color: textColor,
                          fontWeight: widget.isSelected
                              ? FontWeight.w600
                              : FontWeight.normal,
                        ),
                      ),

                    // Item count badge
                    if (widget.isExpanded && widget.space.itemCount > 0)
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: AppSpacing.paddingXS,
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
            ),
          ),
        ),
      ),
    );
  }
}
