import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import '../../core/responsive/breakpoints.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_spacing.dart';
import '../../core/theme/app_typography.dart';
import '../../data/models/space_model.dart';
import '../../providers/spaces_provider.dart';

/// Space switcher modal that allows users to switch between spaces and create new spaces.
///
/// Displays as:
/// - Bottom sheet on mobile (using showModalBottomSheet)
/// - Dialog on desktop (using showDialog)
///
/// Features:
/// - List of all spaces with icon, name, and item count
/// - Highlights currently selected space
/// - Search/filter input at the top
/// - "Create New Space" button (placeholder for now)
/// - Slide-up animation (300ms with spring easing)
/// - Keyboard navigation (arrow keys, enter, esc, 1-9 number shortcuts)
/// - Accessibility support (semantic labels, screen reader)
class SpaceSwitcherModal extends StatefulWidget {
  const SpaceSwitcherModal({super.key});

  /// Shows the space switcher modal with responsive layout
  ///
  /// Returns true if a space was switched, false if cancelled
  static Future<bool?> show(BuildContext context) async {
    final isDesktop = Breakpoints.isDesktopOrLarger(context);

    if (isDesktop) {
      return showDialog<bool>(
        context: context,
        builder: (_) => const SpaceSwitcherModal(),
      );
    } else {
      return showModalBottomSheet<bool>(
        context: context,
        isScrollControlled: true,
        builder: (_) => const SpaceSwitcherModal(),
      );
    }
  }

  @override
  State<SpaceSwitcherModal> createState() => _SpaceSwitcherModalState();
}

class _SpaceSwitcherModalState extends State<SpaceSwitcherModal> {
  final TextEditingController _searchController = TextEditingController();
  final FocusNode _searchFocusNode = FocusNode();
  final FocusNode _listFocusNode = FocusNode();
  int _selectedIndex = -1; // -1 means no selection, keyboard navigation
  List<Space> _filteredSpaces = [];

  @override
  void initState() {
    super.initState();
    _searchController.addListener(_filterSpaces);
    // Don't auto-focus search field to prevent keyboard from covering modal
    // User can tap search field if they want to filter spaces
  }

  @override
  void dispose() {
    _searchController.dispose();
    _searchFocusNode.dispose();
    _listFocusNode.dispose();
    super.dispose();
  }

  /// Filter spaces based on search query
  void _filterSpaces() {
    setState(() {
      _selectedIndex = -1; // Reset keyboard selection when filtering
    });
  }

  /// Get filtered spaces based on search query
  List<Space> _getFilteredSpaces(List<Space> allSpaces) {
    final query = _searchController.text.toLowerCase().trim();
    if (query.isEmpty) {
      return allSpaces;
    }
    return allSpaces
        .where((space) => space.name.toLowerCase().contains(query))
        .toList();
  }

  /// Handle space selection
  Future<void> _selectSpace(
    Space space,
    String currentSpaceId,
  ) async {
    final navigator = Navigator.of(context);
    final messenger = ScaffoldMessenger.of(context);
    final spacesProvider = context.read<SpacesProvider>();

    if (space.id == currentSpaceId) {
      // Already on this space, just close
      navigator.pop(false);
      return;
    }

    final startTime = DateTime.now();

    try {
      await spacesProvider.switchSpace(space.id);

      final duration = DateTime.now().difference(startTime);
      debugPrint('Space switch took ${duration.inMilliseconds}ms');

      if (mounted) {
        navigator.pop(true);
      }
    } catch (e) {
      if (mounted) {
        messenger.showSnackBar(
          SnackBar(
            content: Text('Failed to switch space: ${e.toString()}'),
            behavior: SnackBarBehavior.floating,
          ),
        );
      }
    }
  }

  /// Handle keyboard events
  KeyEventResult _handleKeyEvent(
    FocusNode node,
    KeyEvent event,
    List<Space> spaces,
    String currentSpaceId,
  ) {
    if (event is! KeyDownEvent) {
      return KeyEventResult.ignored;
    }

    // Escape - close modal
    if (event.logicalKey == LogicalKeyboardKey.escape) {
      Navigator.of(context).pop(false);
      return KeyEventResult.handled;
    }

    // Number keys 1-9 - select space directly
    if (event.logicalKey.keyId >= LogicalKeyboardKey.digit1.keyId &&
        event.logicalKey.keyId <= LogicalKeyboardKey.digit9.keyId) {
      final index =
          event.logicalKey.keyId - LogicalKeyboardKey.digit1.keyId;
      if (index < spaces.length) {
        _selectSpace(spaces[index], currentSpaceId);
        return KeyEventResult.handled;
      }
    }

    // Arrow keys - navigate list
    if (event.logicalKey == LogicalKeyboardKey.arrowDown) {
      setState(() {
        if (_selectedIndex < spaces.length - 1) {
          _selectedIndex++;
        } else {
          _selectedIndex = 0; // Wrap to top
        }
      });
      return KeyEventResult.handled;
    }

    if (event.logicalKey == LogicalKeyboardKey.arrowUp) {
      setState(() {
        if (_selectedIndex > 0) {
          _selectedIndex--;
        } else {
          _selectedIndex = spaces.length - 1; // Wrap to bottom
        }
      });
      return KeyEventResult.handled;
    }

    // Enter - select highlighted space
    if (event.logicalKey == LogicalKeyboardKey.enter) {
      if (_selectedIndex >= 0 && _selectedIndex < spaces.length) {
        _selectSpace(spaces[_selectedIndex], currentSpaceId);
        return KeyEventResult.handled;
      }
    }

    return KeyEventResult.ignored;
  }

  /// Build search field
  Widget _buildSearchField(bool isDark) {
    return TextField(
      controller: _searchController,
      focusNode: _searchFocusNode,
      decoration: InputDecoration(
        hintText: 'Search spaces...',
        prefixIcon: Icon(
          Icons.search,
          color: isDark
              ? AppColors.textSecondaryDark
              : AppColors.textSecondaryLight,
        ),
        suffixIcon: _searchController.text.isNotEmpty
            ? IconButton(
                icon: Icon(
                  Icons.clear,
                  color: isDark
                      ? AppColors.textSecondaryDark
                      : AppColors.textSecondaryLight,
                ),
                onPressed: () {
                  _searchController.clear();
                },
                tooltip: 'Clear search',
              )
            : null,
        filled: true,
        fillColor: isDark
            ? AppColors.surfaceDarkVariant
            : AppColors.surfaceLightVariant,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(AppSpacing.inputRadius),
          borderSide: BorderSide.none,
        ),
        contentPadding: const EdgeInsets.symmetric(
          horizontal: AppSpacing.inputPaddingHorizontal,
          vertical: AppSpacing.inputPaddingVertical,
        ),
      ),
      style: AppTypography.bodyMedium.copyWith(
        color: isDark ? AppColors.textPrimaryDark : AppColors.textPrimaryLight,
      ),
      textInputAction: TextInputAction.search,
      onSubmitted: (_) {
        // Move focus to list for keyboard navigation
        _listFocusNode.requestFocus();
        if (_filteredSpaces.isNotEmpty) {
          setState(() {
            _selectedIndex = 0;
          });
        }
      },
    );
  }

  /// Build space list item
  Widget _buildSpaceItem({
    required BuildContext context,
    required Space space,
    required bool isSelected,
    required bool isKeyboardSelected,
    required VoidCallback onTap,
    required int index,
  }) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Semantics(
      label: '${space.name}, ${space.itemCount} items',
      selected: isSelected,
      button: true,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(AppSpacing.radiusMD),
        child: Container(
          constraints: const BoxConstraints(
            minHeight: AppSpacing.minTouchTarget,
          ),
          padding: const EdgeInsets.symmetric(
            horizontal: AppSpacing.paddingSM,
            vertical: AppSpacing.paddingXS,
          ),
          decoration: BoxDecoration(
            color: isSelected
                ? (isDark
                    ? AppColors.selectedDark
                    : AppColors.selectedLight)
                : (isKeyboardSelected
                    ? (isDark
                        ? AppColors.focusDark.withValues(alpha: 0.1)
                        : AppColors.focusLight.withValues(alpha: 0.1))
                    : Colors.transparent),
            borderRadius: BorderRadius.circular(AppSpacing.radiusMD),
            border: isSelected
                ? Border.all(
                    color: isDark
                        ? AppColors.primaryAmberLight
                        : AppColors.primaryAmber,
                    width: AppSpacing.borderWidthMedium,
                  )
                : null,
          ),
          child: Row(
            children: [
              // Number indicator for keyboard shortcuts (1-9)
              if (index < 9)
                Container(
                  width: 24,
                  height: 24,
                  margin: const EdgeInsets.only(right: AppSpacing.xs),
                  decoration: BoxDecoration(
                    color: isDark
                        ? AppColors.surfaceDarkVariant
                        : AppColors.surfaceLightVariant,
                    borderRadius: BorderRadius.circular(AppSpacing.radiusSM),
                  ),
                  child: Center(
                    child: Text(
                      '${index + 1}',
                      style: AppTypography.labelSmall.copyWith(
                        color: isDark
                            ? AppColors.textSecondaryDark
                            : AppColors.textSecondaryLight,
                      ),
                    ),
                  ),
                ),

              // Space icon
              if (space.icon != null)
                Text(
                  space.icon!,
                  style: const TextStyle(fontSize: 24),
                )
              else
                Icon(
                  Icons.folder_outlined,
                  size: 24,
                  color: isDark
                      ? AppColors.textSecondaryDark
                      : AppColors.textSecondaryLight,
                ),
              const SizedBox(width: AppSpacing.xs),

              // Space name
              Expanded(
                child: Text(
                  space.name,
                  style: AppTypography.bodyLarge.copyWith(
                    color: isDark
                        ? AppColors.textPrimaryDark
                        : AppColors.textPrimaryLight,
                    fontWeight: isSelected ? FontWeight.w600 : FontWeight.normal,
                  ),
                  overflow: TextOverflow.ellipsis,
                ),
              ),

              const SizedBox(width: AppSpacing.xs),

              // Item count badge
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: AppSpacing.xs,
                  vertical: AppSpacing.xxxs,
                ),
                decoration: BoxDecoration(
                  color: isDark
                      ? AppColors.surfaceDarkVariant
                      : AppColors.surfaceLightVariant,
                  borderRadius: BorderRadius.circular(AppSpacing.chipRadius),
                ),
                child: Text(
                  '${space.itemCount}',
                  style: AppTypography.labelMedium.copyWith(
                    color: isDark
                        ? AppColors.textSecondaryDark
                        : AppColors.textSecondaryLight,
                  ),
                ),
              ),

              // Selected indicator
              if (isSelected)
                Padding(
                  padding: const EdgeInsets.only(left: AppSpacing.xs),
                  child: Icon(
                    Icons.check_circle,
                    size: 20,
                    color: isDark
                        ? AppColors.primaryAmberLight
                        : AppColors.primaryAmber,
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }

  /// Build create space button
  Widget _buildCreateSpaceButton(bool isDark) {
    return Padding(
      padding: const EdgeInsets.symmetric(
        horizontal: AppSpacing.paddingSM,
        vertical: AppSpacing.paddingXS,
      ),
      child: Semantics(
        button: true,
        label: 'Create new space',
        child: ElevatedButton.icon(
          onPressed: () {
            // Show placeholder message
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(
                content: Text('Create space feature coming soon'),
                behavior: SnackBarBehavior.floating,
                duration: Duration(seconds: 2),
              ),
            );
          },
          icon: const Icon(Icons.add),
          label: const Text('Create New Space'),
          style: ElevatedButton.styleFrom(
            backgroundColor: AppColors.primaryAmber,
            foregroundColor: AppColors.neutralBlack,
            minimumSize: const Size(double.infinity, AppSpacing.minTouchTarget),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(AppSpacing.buttonRadius),
            ),
          ),
        ),
      ),
    );
  }

  /// Build modal content
  Widget _buildContent(BuildContext context, SpacesProvider spacesProvider) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final currentSpaceId = spacesProvider.currentSpace?.id ?? '';
    final allSpaces = spacesProvider.spaces;
    _filteredSpaces = _getFilteredSpaces(allSpaces);
    final isDesktop = context.isDesktopOrLarger;

    return Focus(
      focusNode: _listFocusNode,
      onKeyEvent: (node, event) {
        return _handleKeyEvent(node, event, _filteredSpaces, currentSpaceId);
      },
      child: Container(
        constraints: BoxConstraints(
          maxHeight: MediaQuery.of(context).size.height * 0.8,
          maxWidth: isDesktop ? 500 : double.infinity,
        ),
        decoration: BoxDecoration(
          color: isDark ? AppColors.surfaceDark : AppColors.surfaceLight,
          borderRadius: isDesktop
              ? BorderRadius.circular(AppSpacing.modalRadius)
              : const BorderRadius.vertical(
                  top: Radius.circular(AppSpacing.modalRadius),
                ),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // Header
            Padding(
              padding: const EdgeInsets.all(AppSpacing.paddingSM),
              child: Row(
                children: [
                  Expanded(
                    child: Text(
                      'Switch Space',
                      style: AppTypography.h4.copyWith(
                        color: isDark
                            ? AppColors.textPrimaryDark
                            : AppColors.textPrimaryLight,
                      ),
                    ),
                  ),
                  IconButton(
                    icon: const Icon(Icons.close),
                    onPressed: () => Navigator.of(context).pop(false),
                    tooltip: 'Close',
                    color: isDark
                        ? AppColors.textSecondaryDark
                        : AppColors.textSecondaryLight,
                  ),
                ],
              ),
            ),

            // Search field
            Padding(
              padding: const EdgeInsets.symmetric(
                horizontal: AppSpacing.paddingSM,
              ),
              child: _buildSearchField(isDark),
            ),

            const SizedBox(height: AppSpacing.paddingSM),

            // Divider
            Divider(
              height: 1,
              color: isDark ? AppColors.borderDark : AppColors.borderLight,
            ),

            // Space list
            Flexible(
              child: _filteredSpaces.isEmpty
                  ? Padding(
                      padding: const EdgeInsets.all(AppSpacing.paddingMD),
                      child: Center(
                        child: Text(
                          _searchController.text.isNotEmpty
                              ? 'No spaces found'
                              : 'No spaces available',
                          style: AppTypography.bodyMedium.copyWith(
                            color: isDark
                                ? AppColors.textSecondaryDark
                                : AppColors.textSecondaryLight,
                          ),
                        ),
                      ),
                    )
                  : ListView.separated(
                      shrinkWrap: true,
                      padding: const EdgeInsets.symmetric(
                        horizontal: AppSpacing.paddingSM,
                        vertical: AppSpacing.paddingXS,
                      ),
                      itemCount: _filteredSpaces.length,
                      separatorBuilder: (context, index) =>
                          const SizedBox(height: AppSpacing.xxxs),
                      itemBuilder: (context, index) {
                        final space = _filteredSpaces[index];
                        final isSelected = space.id == currentSpaceId;
                        final isKeyboardSelected = index == _selectedIndex;

                        return _buildSpaceItem(
                          context: context,
                          space: space,
                          isSelected: isSelected,
                          isKeyboardSelected: isKeyboardSelected,
                          onTap: () => _selectSpace(space, currentSpaceId),
                          index: index,
                        );
                      },
                    ),
            ),

            // Divider
            Divider(
              height: 1,
              color: isDark ? AppColors.borderDark : AppColors.borderLight,
            ),

            // Create space button
            _buildCreateSpaceButton(isDark),

            // Bottom padding for mobile (safe area + keyboard)
            if (!isDesktop)
              SizedBox(
                height: MediaQuery.of(context).padding.bottom +
                    MediaQuery.of(context).viewInsets.bottom,
              ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final isDesktop = context.isDesktopOrLarger;

    return Consumer<SpacesProvider>(
      builder: (context, spacesProvider, child) {
        if (isDesktop) {
          // Desktop: Dialog
          return Dialog(
            backgroundColor: Colors.transparent,
            child: _buildContent(context, spacesProvider),
          );
        } else {
          // Mobile: Bottom sheet
          return _buildContent(context, spacesProvider);
        }
      },
    );
  }
}
