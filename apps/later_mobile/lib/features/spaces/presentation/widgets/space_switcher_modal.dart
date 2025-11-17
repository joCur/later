import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:later_mobile/core/permissions/permissions.dart';
import 'package:later_mobile/design_system/organisms/dialogs/upgrade_required_dialog.dart';
import 'package:later_mobile/design_system/tokens/tokens.dart';
import 'package:later_mobile/l10n/app_localizations.dart';
import 'package:later_mobile/core/theme/temporal_flow_theme.dart';
import 'package:later_mobile/core/utils/responsive_modal.dart';
import 'package:later_mobile/features/spaces/domain/models/space.dart';
import 'package:later_mobile/features/spaces/presentation/controllers/spaces_controller.dart';
import 'package:later_mobile/features/spaces/presentation/controllers/current_space_controller.dart';
import 'create_space_modal.dart';
import 'package:later_mobile/design_system/atoms/inputs/text_input_field.dart';
import 'package:later_mobile/design_system/atoms/buttons/primary_button.dart';
import 'package:later_mobile/design_system/organisms/modals/bottom_sheet_container.dart';

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
class SpaceSwitcherModal extends ConsumerStatefulWidget {
  const SpaceSwitcherModal({super.key});

  @override
  ConsumerState<SpaceSwitcherModal> createState() => _SpaceSwitcherModalState();
}

class _SpaceSwitcherModalState extends ConsumerState<SpaceSwitcherModal> {
  final TextEditingController _searchController = TextEditingController();
  final FocusNode _searchFocusNode = FocusNode();
  final FocusNode _listFocusNode = FocusNode();
  int _selectedIndex = -1; // -1 means no selection, keyboard navigation
  List<Space> _filteredSpaces = [];
  bool _showArchivedSpaces = false; // Toggle state for showing archived spaces
  final Map<String, int> _cachedCounts = {}; // Cache for item counts

  @override
  void initState() {
    super.initState();
    _searchController.addListener(_filterSpaces);
    // Don't auto-focus search field to prevent keyboard from covering modal
    // User can tap search field if they want to filter spaces
    // Pre-fetch item counts for all spaces to prevent flicker
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _preFetchItemCounts();
    });
  }

  @override
  void dispose() {
    _searchController.dispose();
    _searchFocusNode.dispose();
    _listFocusNode.dispose();
    _cachedCounts.clear();
    super.dispose();
  }

  /// Pre-fetch item counts for all spaces to prevent flicker
  Future<void> _preFetchItemCounts() async {
    final spacesAsync = ref.read(spacesControllerProvider);
    final spaces = spacesAsync.when(
      data: (data) => data,
      loading: () => <Space>[],
      error: (error, stack) => <Space>[],
    );

    for (final space in spaces) {
      try {
        final count = await ref.read(spacesControllerProvider.notifier).getSpaceItemCount(space.id);
        if (mounted) {
          setState(() {
            _cachedCounts[space.id] = count;
          });
        }
      } catch (e) {
        // Ignore errors during pre-fetch, will fallback to loading state
        debugPrint('Error pre-fetching count for space ${space.id}: $e');
      }
    }
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
  Future<void> _selectSpace(Space space, String currentSpaceId) async {
    final navigator = Navigator.of(context);
    final messenger = ScaffoldMessenger.of(context);
    final l10n = AppLocalizations.of(context)!;

    if (space.id == currentSpaceId) {
      // Already on this space, just close
      navigator.pop(false);
      return;
    }

    final startTime = DateTime.now();

    try {
      await ref.read(currentSpaceControllerProvider.notifier).switchSpace(space);

      final duration = DateTime.now().difference(startTime);
      debugPrint('Space switch took ${duration.inMilliseconds}ms');

      if (mounted) {
        navigator.pop(true);
      }
    } catch (e) {
      if (mounted) {
        messenger.showSnackBar(
          SnackBar(
            content: Text(l10n.spaceSwitcherErrorSwitch(e.toString())),
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
      final index = event.logicalKey.keyId - LogicalKeyboardKey.digit1.keyId;
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
  Widget _buildSearchField(BuildContext context, bool isDark) {
    final l10n = AppLocalizations.of(context)!;
    return TextInputField(
      controller: _searchController,
      focusNode: _searchFocusNode,
      hintText: l10n.spaceSwitcherSearchHint,
      prefixIcon: Icons.search,
      suffixIcon: _searchController.text.isNotEmpty ? Icons.clear : null,
      onSuffixIconPressed: _searchController.text.isNotEmpty
          ? () {
              _searchController.clear();
            }
          : null,
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

  /// Build item count widget with async loading
  Widget _buildItemCount(String spaceId, BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    // Check if we have a cached count
    if (_cachedCounts.containsKey(spaceId)) {
      return Container(
        padding: const EdgeInsets.symmetric(
          horizontal: AppSpacing.xs,
          vertical: AppSpacing.xxs,
        ),
        decoration: BoxDecoration(
          color: AppColors.surfaceVariant(context),
          borderRadius: BorderRadius.circular(AppSpacing.xs),
        ),
        child: Text(
          '${_cachedCounts[spaceId]}',
          style: AppTypography.labelMedium.copyWith(
            color: AppColors.neutral500,
          ),
        ),
      );
    }

    // If not cached, use FutureBuilder
    return FutureBuilder<int>(
      future: ref.read(spacesControllerProvider.notifier).getSpaceItemCount(spaceId),
      builder: (context, snapshot) {
        final displayText = snapshot.hasData ? '${snapshot.data}' : '...';
        return Container(
          padding: const EdgeInsets.symmetric(
            horizontal: AppSpacing.xs,
            vertical: AppSpacing.xxs,
          ),
          decoration: BoxDecoration(
            color: AppColors.surfaceVariant(context),
            borderRadius: BorderRadius.circular(AppSpacing.xs),
          ),
          child: Text(
            displayText,
            style: AppTypography.labelMedium.copyWith(
              color: isDark ? AppColors.neutral500 : AppColors.neutral500,
            ),
          ),
        );
      },
    );
  }

  /// Get gradient for space item based on index
  LinearGradient _getSpaceGradient(int index, BuildContext context) {
    final temporalTheme = Theme.of(context).extension<TemporalFlowTheme>()!;
    final isDark = Theme.of(context).brightness == Brightness.dark;

    // Cycle through type gradients for visual variety
    final gradients = [
      temporalTheme.primaryGradient,
      temporalTheme.secondaryGradient,
      isDark
          ? const LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [AppColors.accentCyanDark, AppColors.accentEmeraldDark],
            )
          : const LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [AppColors.accentCyan, AppColors.accentEmerald],
            ),
    ];
    return gradients[index % gradients.length];
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
    final isArchived = space.isArchived;
    final gradient = _getSpaceGradient(index, context);
    final l10n = AppLocalizations.of(context)!;

    // Get item count for accessibility label
    final itemCount = _cachedCounts[space.id] ?? 0;

    // Wrap entire item in Opacity if archived
    final itemContent = Semantics(
      label: l10n.accessibilitySpaceItemCount(space.name, itemCount),
      selected: isSelected,
      button: true,
      child: InkWell(
        onTap: isArchived ? null : onTap, // Disable tap for archived spaces
        onLongPress: () => _showSpaceOptionsMenu(context, space),
        borderRadius: BorderRadius.circular(AppSpacing.radiusMD),
        hoverColor: gradient.colors.first.withValues(alpha: 0.08),
        splashColor: gradient.colors.last.withValues(alpha: 0.12),
        child: AnimatedContainer(
          duration: AppAnimations.normal,
          curve: AppAnimations.springCurve,
          child: Container(
            constraints: const BoxConstraints(
              minHeight:
                  56, // Mobile-first: 56px height for comfortable tapping
            ),
            padding: const EdgeInsets.symmetric(
              horizontal: 20, // Mobile-first: 20px padding
              vertical: 12,
            ),
            decoration: BoxDecoration(
              color: isSelected
                  ? (isDark ? AppColors.selectedDark : AppColors.selectedLight)
                  : (isKeyboardSelected
                        ? (isDark
                              ? AppColors.focusDark.withValues(alpha: 0.1)
                              : AppColors.focusLight.withValues(alpha: 0.1))
                        : Colors.transparent),
              borderRadius: BorderRadius.circular(AppSpacing.radiusMD),
              // Mobile-first: 3px gradient left border for current space
              border: isSelected
                  ? Border(
                      left: BorderSide(width: 3, color: gradient.colors.first),
                    )
                  : null,
              gradient: isSelected
                  ? LinearGradient(
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                      colors: [
                        gradient.colors.first.withValues(alpha: 0.12),
                        gradient.colors.last.withValues(alpha: 0.12),
                      ],
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
                          ? AppColors.neutral800
                          : AppColors.neutral100,
                      borderRadius: BorderRadius.circular(AppSpacing.radiusSM),
                    ),
                    child: Center(
                      child: Text(
                        '${index + 1}',
                        style: AppTypography.labelSmall.copyWith(
                          color: isDark
                              ? AppColors.neutral500
                              : AppColors.neutral500,
                        ),
                      ),
                    ),
                  ),

                // Space icon - Mobile-first: 24px with gradient tint
                if (isArchived)
                  Icon(
                    Icons.archive,
                    size: 24,
                    color: AppColors.textSecondary(context),
                  )
                else if (space.icon != null)
                  Text(space.icon!, style: const TextStyle(fontSize: 24))
                else
                  // Gradient-tinted icon for default folder
                  ShaderMask(
                    shaderCallback: (bounds) => gradient.createShader(bounds),
                    blendMode: BlendMode.srcIn,
                    child: const Icon(
                      Icons.folder_outlined,
                      size: 24,
                      color: Colors.white,
                    ),
                  ),
                const SizedBox(width: AppSpacing.xs),

                // Space name
                Expanded(
                  child: Text(
                    space.name,
                    style: AppTypography.bodyLarge.copyWith(
                      color: isDark
                          ? AppColors.neutral400
                          : AppColors.neutral600,
                      fontWeight: isSelected
                          ? FontWeight.w600
                          : FontWeight.normal,
                    ),
                    overflow: TextOverflow.ellipsis,
                  ),
                ),

                const SizedBox(width: AppSpacing.xs),

                // Archived badge
                if (isArchived)
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: AppSpacing.xs,
                      vertical: AppSpacing.xxs,
                    ),
                    decoration: BoxDecoration(
                      color: isDark
                          ? AppColors.neutral500.withValues(alpha: 0.2)
                          : AppColors.neutral500.withValues(alpha: 0.2),
                      borderRadius: BorderRadius.circular(AppSpacing.xs),
                    ),
                    child: Text(
                      l10n.spaceSwitcherBadgeArchived,
                      style: AppTypography.labelSmall.copyWith(
                        color: isDark
                            ? AppColors.neutral500
                            : AppColors.neutral500,
                      ),
                    ),
                  ),

                if (isArchived) const SizedBox(width: AppSpacing.xxs),

                // Item count badge (async loaded)
                _buildItemCount(space.id, context),

                // Selected indicator
                if (isSelected)
                  Padding(
                    padding: const EdgeInsets.only(left: AppSpacing.xs),
                    child: Icon(
                      Icons.check_circle,
                      size: 20,
                      color: isDark
                          ? AppColors.primaryLight
                          : AppColors.primarySolid,
                    ),
                  ),
              ],
            ),
          ),
        ),
      ),
    );

    // Return with opacity if archived
    if (isArchived) {
      return Opacity(opacity: 0.5, child: itemContent);
    }

    return itemContent;
  }

  /// Show space options menu (long-press menu)
  Future<void> _showSpaceOptionsMenu(BuildContext context, Space space) async {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final currentSpaceId = ref.read(currentSpaceControllerProvider).when(
      data: (currentSpace) => currentSpace?.id ?? '',
      loading: () => '',
      error: (error, stack) => '',
    );
    final isCurrentSpace = space.id == currentSpaceId;
    final l10n = AppLocalizations.of(context)!;

    // Get item count for menu (use cached value or default to 0)
    final itemCount = _cachedCounts[space.id] ?? 0;

    // Trigger haptic feedback
    HapticFeedback.mediumImpact();

    await showModalBottomSheet<void>(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (BuildContext bottomSheetContext) {
        return Container(
          decoration: BoxDecoration(
            color: AppColors.surface(context),
            borderRadius: const BorderRadius.vertical(
              top: Radius.circular(AppSpacing.modalRadius),
            ),
          ),
          child: SafeArea(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                // Header with space info
                Padding(
                  padding: const EdgeInsets.all(AppSpacing.sm),
                  child: Row(
                    children: [
                      if (space.icon != null)
                        Text(space.icon!, style: const TextStyle(fontSize: 24))
                      else
                        Icon(
                          Icons.folder_outlined,
                          size: 24,
                          color: isDark
                              ? AppColors.neutral500
                              : AppColors.neutral500,
                        ),
                      const SizedBox(width: AppSpacing.xs),
                      Expanded(
                        child: Text(
                          space.name,
                          style: AppTypography.titleMedium.copyWith(
                            color: isDark
                                ? AppColors.neutral400
                                : AppColors.neutral600,
                          ),
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                      Text(
                        l10n.spaceSwitcherItemCount(itemCount),
                        style: AppTypography.labelMedium.copyWith(
                          color: isDark
                              ? AppColors.neutral500
                              : AppColors.neutral500,
                        ),
                      ),
                    ],
                  ),
                ),

                Divider(
                  height: 1,
                  color: AppColors.border(context),
                ),

                // Menu options
                ListTile(
                  leading: const Icon(Icons.edit),
                  title: Text(l10n.spaceSwitcherMenuEdit),
                  onTap: () {
                    Navigator.of(bottomSheetContext).pop();
                    _handleEditSpace(context, space);
                  },
                  iconColor: isDark
                      ? AppColors.neutral500
                      : AppColors.neutral500,
                  textColor: isDark
                      ? AppColors.neutral400
                      : AppColors.neutral600,
                  minTileHeight: AppSpacing.minTouchTarget,
                ),

                // Show either Archive or Restore based on space state
                if (!space.isArchived)
                  ListTile(
                    leading: const Icon(Icons.archive),
                    title: Text(l10n.spaceSwitcherMenuArchive),
                    subtitle: isCurrentSpace
                        ? Text(l10n.spaceSwitcherSubtitleSwitchFirst)
                        : (itemCount > 0
                              ? Text(l10n.spaceSwitcherSubtitleContainsItems(itemCount))
                              : null),
                    onTap: isCurrentSpace
                        ? null
                        : () {
                            Navigator.of(bottomSheetContext).pop();
                            _handleArchiveSpace(context, space);
                          },
                    iconColor: isCurrentSpace
                        ? (isDark
                              ? AppColors.neutral500.withValues(alpha: 0.5)
                              : AppColors.neutral500.withValues(alpha: 0.5))
                        : AppColors.error,
                    textColor: isCurrentSpace
                        ? (isDark
                              ? AppColors.neutral500.withValues(alpha: 0.5)
                              : AppColors.neutral500.withValues(alpha: 0.5))
                        : AppColors.error,
                    enabled: !isCurrentSpace,
                    minTileHeight: AppSpacing.minTouchTarget,
                  )
                else
                  ListTile(
                    leading: const Icon(Icons.unarchive),
                    title: Text(l10n.spaceSwitcherMenuRestore),
                    subtitle: Text(l10n.spaceSwitcherSubtitleRestore),
                    onTap: () {
                      Navigator.of(bottomSheetContext).pop();
                      _handleRestoreSpace(context, space);
                    },
                    iconColor: isDark
                        ? AppColors.neutral500
                        : AppColors.neutral500,
                    textColor: isDark
                        ? AppColors.neutral400
                        : AppColors.neutral600,
                    minTileHeight: AppSpacing.minTouchTarget,
                  ),

                ListTile(
                  leading: const Icon(Icons.close),
                  title: Text(l10n.spaceSwitcherMenuCancel),
                  onTap: () => Navigator.of(bottomSheetContext).pop(),
                  iconColor: isDark
                      ? AppColors.neutral500
                      : AppColors.neutral500,
                  textColor: isDark
                      ? AppColors.neutral400
                      : AppColors.neutral600,
                  minTileHeight: AppSpacing.minTouchTarget,
                ),

                const SizedBox(height: AppSpacing.sm),
              ],
            ),
          ),
        );
      },
    );
  }

  /// Handle edit space action
  Future<void> _handleEditSpace(BuildContext context, Space space) async {
    // Open CreateSpaceModal in edit mode
    final result = await ResponsiveModal.show<bool>(
      context: context,
      child: CreateSpaceModal(mode: SpaceModalMode.edit, initialSpace: space),
    );

    // If space was updated, the provider will have been updated automatically
    // Just need to refresh the UI
    if (result == true && mounted) {
      setState(() {
        // Trigger rebuild to show updated space
      });
    }
  }

  /// Handle archive space action
  Future<void> _handleArchiveSpace(BuildContext context, Space space) async {
    final messenger = ScaffoldMessenger.of(context);
    final currentSpaceId = ref.read(currentSpaceControllerProvider).when(
      data: (currentSpace) => currentSpace?.id ?? '',
      loading: () => '',
      error: (error, stack) => '',
    );
    final l10n = AppLocalizations.of(context)!;

    // Get item count (use cached value or default to 0)
    final itemCount = _cachedCounts[space.id] ?? 0;

    // Prevent archiving current space
    if (space.id == currentSpaceId) {
      messenger.showSnackBar(
        SnackBar(
          content: Text(l10n.spaceSwitcherErrorCannotArchiveCurrent),
          behavior: SnackBarBehavior.floating,
        ),
      );
      return;
    }

    // Show confirmation dialog if space has items
    if (itemCount > 0) {
      final confirmed = await showDialog<bool>(
        context: context,
        builder: (dialogContext) => AlertDialog(
          title: Text(l10n.spaceSwitcherDialogArchiveTitle),
          content: Text(l10n.spaceSwitcherDialogArchiveContent(itemCount)),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(dialogContext).pop(false),
              child: Text(l10n.buttonCancel),
            ),
            TextButton(
              onPressed: () => Navigator.of(dialogContext).pop(true),
              style: TextButton.styleFrom(foregroundColor: AppColors.error),
              child: Text(l10n.buttonArchive),
            ),
          ],
        ),
      );

      if (confirmed != true) return;
    }

    // Archive the space (update with isArchived: true)
    try {
      final archivedSpace = space.copyWith(
        isArchived: true,
        updatedAt: DateTime.now(),
      );
      await ref.read(spacesControllerProvider.notifier).updateSpace(archivedSpace);

      // Reload spaces without archived to hide the archived space
      if (!_showArchivedSpaces) {
        await ref.read(spacesControllerProvider.notifier).loadSpaces();
      }

      if (mounted) {
        messenger.showSnackBar(
          SnackBar(
            content: Text(l10n.spaceSwitcherSuccessArchived(space.name)),
            behavior: SnackBarBehavior.floating,
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        messenger.showSnackBar(
          SnackBar(
            content: Text(l10n.spaceSwitcherErrorArchive(e.toString())),
            behavior: SnackBarBehavior.floating,
          ),
        );
      }
    }
  }

  /// Handle restore space action
  Future<void> _handleRestoreSpace(BuildContext context, Space space) async {
    final messenger = ScaffoldMessenger.of(context);
    final l10n = AppLocalizations.of(context)!;

    // Restore the space (update with isArchived: false)
    try {
      final restoredSpace = space.copyWith(
        isArchived: false,
        updatedAt: DateTime.now(),
      );
      await ref.read(spacesControllerProvider.notifier).updateSpace(restoredSpace);

      if (mounted) {
        messenger.showSnackBar(
          SnackBar(
            content: Text(l10n.spaceSwitcherSuccessRestored(space.name)),
            behavior: SnackBarBehavior.floating,
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        messenger.showSnackBar(
          SnackBar(
            content: Text(l10n.spaceSwitcherErrorRestore(e.toString())),
            behavior: SnackBarBehavior.floating,
          ),
        );
      }
    }
  }

  /// Build show archived toggle
  Widget _buildShowArchivedToggle(BuildContext context, bool isDark) {
    final l10n = AppLocalizations.of(context)!;
    return Padding(
      padding: const EdgeInsets.symmetric(
        horizontal: AppSpacing.sm,
        vertical: AppSpacing.xs,
      ),
      child: SwitchListTile(
        title: Text(
          l10n.spaceSwitcherToggleShowArchived,
          style: AppTypography.bodyMedium.copyWith(
            color: AppColors.text(context),
          ),
        ),
        value: _showArchivedSpaces,
        onChanged: (value) async {
          setState(() {
            _showArchivedSpaces = value;
          });
          await ref.read(spacesControllerProvider.notifier).loadSpaces(includeArchived: value);
        },
        contentPadding: EdgeInsets.zero,
      ),
    );
  }

  /// Build create space button with gradient styling
  Widget _buildCreateSpaceButton(BuildContext context, bool isDark) {
    final temporalTheme = Theme.of(context).extension<TemporalFlowTheme>()!;
    final l10n = AppLocalizations.of(context)!;

    // Check if anonymous user has reached limit
    final role = ref.watch(currentUserRoleProvider);
    final spacesAsync = ref.watch(spacesControllerProvider);
    final currentSpaceCount = spacesAsync.whenData((spaces) => spaces.length).value ?? 0;
    final hasReachedLimit = role == UserRole.anonymous &&
        currentSpaceCount >= UserRolePermissions(role).maxSpacesForAnonymous;

    return Padding(
      padding: const EdgeInsets.symmetric(
        horizontal: AppSpacing.sm,
        vertical: AppSpacing.xs,
      ),
      child: Semantics(
        button: true,
        label: hasReachedLimit
            ? l10n.authUpgradeBannerButton
            : l10n.accessibilityCreateNewSpace,
        child: Container(
          decoration: BoxDecoration(
            gradient: temporalTheme.primaryGradient,
            borderRadius: BorderRadius.circular(AppSpacing.buttonRadius),
            boxShadow: [
              BoxShadow(
                color: temporalTheme.primaryGradient.colors.first.withValues(
                  alpha: 0.3,
                ),
                blurRadius: 8,
                offset: const Offset(0, 2),
              ),
            ],
          ),
          child: PrimaryButton(
            text: hasReachedLimit
                ? l10n.authUpgradeBannerButton
                : l10n.spaceSwitcherButtonCreateNew,
            icon: hasReachedLimit ? Icons.star : Icons.add,
            onPressed: () async {
              final navigator = Navigator.of(context);

              // If user has reached limit, show upgrade dialog
              if (hasReachedLimit) {
                await showUpgradeRequiredDialog(
                  context: context,
                  message: l10n.authUpgradeLimitSpaces,
                );
                return;
              }

              // Otherwise, show create space modal
              final result = await ResponsiveModal.show<bool>(
                context: context,
                child: const CreateSpaceModal(mode: SpaceModalMode.create),
              );

              // If space was created, close this modal and return true
              // so the HomeScreen knows to reload items
              if (result == true && mounted) {
                navigator.pop(true);
              }
            },
            isExpanded: true,
          ),
        ),
      ),
    );
  }

  /// Build space list view
  Widget _buildSpaceList(
    BuildContext context,
    String currentSpaceId,
    bool isDark,
  ) {
    final l10n = AppLocalizations.of(context)!;
    return _filteredSpaces.isEmpty
        ? Padding(
            padding: const EdgeInsets.all(AppSpacing.md),
            child: Center(
              child: Text(
                _searchController.text.isNotEmpty
                    ? l10n.spaceSwitcherEmptyNoResults
                    : l10n.spaceSwitcherEmptyNoSpaces,
                style: AppTypography.bodyMedium.copyWith(
                  color: AppColors.textSecondary(context),
                ),
              ),
            ),
          )
        : ListView.separated(
            shrinkWrap: true,
            padding: const EdgeInsets.symmetric(
              horizontal: AppSpacing.sm,
              vertical: AppSpacing.xs,
            ),
            itemCount: _filteredSpaces.length,
            separatorBuilder: (context, index) =>
                const SizedBox(height: AppSpacing.xxs),
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
          );
  }

  /// Build modal content (for BottomSheetContainer child)
  Widget _buildModalContent(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final spacesAsync = ref.watch(spacesControllerProvider);
    final currentSpaceId = ref.watch(currentSpaceControllerProvider).when(
      data: (currentSpace) => currentSpace?.id ?? '',
      loading: () => '',
      error: (error, stack) => '',
    );
    final allSpaces = spacesAsync.when(
      data: (data) => data,
      loading: () => <Space>[],
      error: (error, stack) => <Space>[],
    );
    _filteredSpaces = _getFilteredSpaces(allSpaces);

    return Focus(
      focusNode: _listFocusNode,
      onKeyEvent: (node, event) {
        return _handleKeyEvent(node, event, _filteredSpaces, currentSpaceId);
      },
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // Search field
          Padding(
            padding: const EdgeInsets.only(bottom: AppSpacing.md),
            child: _buildSearchField(context, isDark),
          ),

          // Space list
          Flexible(child: _buildSpaceList(context, currentSpaceId, isDark)),

          const SizedBox(height: AppSpacing.sm),

          // Divider
          Divider(
            height: 1,
            color: AppColors.border(context),
          ),

          // Show archived toggle
          _buildShowArchivedToggle(context, isDark),

          // Divider
          Divider(
            height: 1,
            color: AppColors.border(context),
          ),

          // Create space button
          _buildCreateSpaceButton(context, isDark),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    return BottomSheetContainer(
      title: l10n.spaceSwitcherTitle,
      showSecondaryButton: false,
      child: _buildModalContent(context),
    );
  }
}
