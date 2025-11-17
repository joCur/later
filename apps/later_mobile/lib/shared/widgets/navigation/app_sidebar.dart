import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:later_mobile/design_system/atoms/buttons/theme_toggle_button.dart';
import 'package:later_mobile/design_system/tokens/tokens.dart';
import 'package:later_mobile/l10n/app_localizations.dart';

import 'package:later_mobile/core/theme/temporal_flow_theme.dart';
import 'package:later_mobile/features/auth/presentation/controllers/auth_state_controller.dart';
import 'package:later_mobile/features/spaces/domain/models/space.dart';
import 'package:later_mobile/features/spaces/presentation/controllers/current_space_controller.dart';
import 'package:later_mobile/features/spaces/presentation/controllers/spaces_controller.dart';

/// Desktop sidebar navigation component
///
/// Provides persistent navigation for desktop devices (>= 1024px) with:
/// - Collapsible sidebar (240px expanded, 72px collapsed)
/// - Space list with item counts
/// - Keyboard navigation (1-9 for first 9 spaces)
/// - Hover states and tooltips
/// - Expand/collapse toggle
///
/// Connects to [SpacesController] to display and switch between spaces.
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
class AppSidebar extends ConsumerStatefulWidget {
  /// Creates a desktop sidebar.
  ///
  /// The [isExpanded] parameter controls the sidebar width.
  /// The [onToggleExpanded] callback is called when the user toggles expansion.
  const AppSidebar({super.key, this.isExpanded = true, this.onToggleExpanded});

  /// Whether the sidebar is expanded (240px) or collapsed (72px).
  final bool isExpanded;

  /// Called when the user clicks the expand/collapse toggle button.
  final VoidCallback? onToggleExpanded;

  @override
  ConsumerState<AppSidebar> createState() => _AppSidebarState();
}

class _AppSidebarState extends ConsumerState<AppSidebar> {
  final FocusNode _focusNode = FocusNode();
  final Map<String, int> _cachedCounts = {};

  @override
  void initState() {
    super.initState();
    // Request focus to enable keyboard shortcuts
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _focusNode.requestFocus();
      _preFetchItemCounts();
    });
  }

  @override
  void dispose() {
    _focusNode.dispose();
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
      final count = await ref
          .read(spacesControllerProvider.notifier)
          .getSpaceItemCount(space.id);
      if (mounted) {
        setState(() {
          _cachedCounts[space.id] = count;
        });
      }
    }
  }

  void _handleKeyEvent(KeyEvent event) {
    if (event is! KeyDownEvent) return;

    // Handle number keys 1-9 for space navigation
    final key = event.logicalKey;
    final spacesAsync = ref.read(spacesControllerProvider);
    final spaces = spacesAsync.when(
      data: (data) => data,
      loading: () => <Space>[],
      error: (error, stack) => <Space>[],
    );
    final currentSpaceId = ref
        .read(currentSpaceControllerProvider)
        .when(
          data: (currentSpace) => currentSpace?.id,
          loading: () => null,
          error: (error, stack) => null,
        );

    // Helper to switch space with haptic feedback
    void switchWithHaptic(Space space) {
      if (currentSpaceId != space.id) {
        AppAnimations.selectionHaptic();
      }
      ref.read(currentSpaceControllerProvider.notifier).switchSpace(space);
    }

    if (key == LogicalKeyboardKey.digit1 && spaces.isNotEmpty) {
      switchWithHaptic(spaces[0]);
    } else if (key == LogicalKeyboardKey.digit2 && spaces.length > 1) {
      switchWithHaptic(spaces[1]);
    } else if (key == LogicalKeyboardKey.digit3 && spaces.length > 2) {
      switchWithHaptic(spaces[2]);
    } else if (key == LogicalKeyboardKey.digit4 && spaces.length > 3) {
      switchWithHaptic(spaces[3]);
    } else if (key == LogicalKeyboardKey.digit5 && spaces.length > 4) {
      switchWithHaptic(spaces[4]);
    } else if (key == LogicalKeyboardKey.digit6 && spaces.length > 5) {
      switchWithHaptic(spaces[5]);
    } else if (key == LogicalKeyboardKey.digit7 && spaces.length > 6) {
      switchWithHaptic(spaces[6]);
    } else if (key == LogicalKeyboardKey.digit8 && spaces.length > 7) {
      switchWithHaptic(spaces[7]);
    } else if (key == LogicalKeyboardKey.digit9 && spaces.length > 8) {
      switchWithHaptic(spaces[8]);
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDarkMode = theme.brightness == Brightness.dark;
    final temporalTheme = Theme.of(context).extension<TemporalFlowTheme>()!;

    return Focus(
      focusNode: _focusNode,
      onKeyEvent: (node, event) {
        _handleKeyEvent(event);
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
                    color: (AppColors.surface(context)).withValues(alpha: 0.9),
                    border: Border(
                      right: BorderSide(
                        color: isDarkMode
                            ? AppColors.neutral700
                            : AppColors.neutral200,
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
                      temporalTheme.primaryGradient.colors.first.withValues(
                        alpha: 0.1,
                      ),
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
                const Divider(height: 1, thickness: AppSpacing.borderWidthThin),

                // Spaces list
                Expanded(child: _buildSpacesList(isDarkMode)),

                // Footer with settings
                _buildFooter(isDarkMode, temporalTheme),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildHeader(bool isDarkMode) {
    final l10n = AppLocalizations.of(context)!;

    return Container(
      height: 64.0,
      padding: EdgeInsets.symmetric(
        horizontal: widget.isExpanded ? AppSpacing.sm : AppSpacing.xs,
      ),
      child: Row(
        mainAxisAlignment: widget.isExpanded
            ? MainAxisAlignment.spaceBetween
            : MainAxisAlignment.center,
        children: [
          if (widget.isExpanded)
            Text(
              l10n.sidebarSpaces,
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.w600,
                color: AppColors.text(context),
              ),
            ),
          if (widget.onToggleExpanded != null)
            Tooltip(
              message: widget.isExpanded
                  ? l10n.sidebarCollapse
                  : l10n.sidebarExpand,
              child: IconButton(
                icon: Icon(widget.isExpanded ? Icons.menu_open : Icons.menu),
                onPressed: widget.onToggleExpanded,
                color: AppColors.textSecondary(context),
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildSpacesList(bool isDarkMode) {
    final l10n = AppLocalizations.of(context)!;
    final spacesAsync = ref.watch(spacesControllerProvider);
    final currentSpaceId = ref
        .watch(currentSpaceControllerProvider)
        .when(
          data: (currentSpace) => currentSpace?.id,
          loading: () => null,
          error: (error, stack) => null,
        );

    return spacesAsync.when(
      data: (spaces) {
        if (spaces.isEmpty) {
          return Center(
            child: widget.isExpanded
                ? Padding(
                    padding: const EdgeInsets.all(AppSpacing.sm),
                    child: Text(
                      l10n.sidebarNoSpaces,
                      textAlign: TextAlign.center,
                    ),
                  )
                : const Icon(Icons.inbox_outlined),
          );
        }

        return ListView.builder(
          padding: const EdgeInsets.symmetric(vertical: AppSpacing.xs),
          itemCount: spaces.length,
          itemBuilder: (context, index) {
            final space = spaces[index];
            final isSelected = currentSpaceId == space.id;
            final keyboardShortcut = index < 9 ? '${index + 1}' : null;

            return _SpaceListItem(
              space: space,
              isSelected: isSelected,
              isExpanded: widget.isExpanded,
              isDarkMode: isDarkMode,
              keyboardShortcut: keyboardShortcut,
              cachedCount: _cachedCounts[space.id],
              onTap: () {
                // Only trigger haptic if actually changing spaces
                if (currentSpaceId != space.id) {
                  AppAnimations.selectionHaptic();
                }
                ref
                    .read(currentSpaceControllerProvider.notifier)
                    .switchSpace(space);
              },
            );
          },
        );
      },
      loading: () => const Center(child: CircularProgressIndicator()),
      error: (error, stack) => Center(
        child: Text(
          'Error: $error',
          style: const TextStyle(color: AppColors.error),
        ),
      ),
    );
  }

  Widget _buildFooter(bool isDarkMode, TemporalFlowTheme temporalTheme) {
    final l10n = AppLocalizations.of(context)!;
    final isAnonymous = ref
        .watch(authStateControllerProvider.notifier)
        .isCurrentUserAnonymous;

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
                temporalTheme.primaryGradient.colors.first.withValues(
                  alpha: 0.2,
                ),
                Colors.transparent,
              ],
            ),
          ),
        ),
        Container(
          padding: const EdgeInsets.all(AppSpacing.xs),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Row(
                mainAxisAlignment: widget.isExpanded
                    ? MainAxisAlignment.start
                    : MainAxisAlignment.center,
                children: [
                  // Theme toggle button
                  const ThemeToggleButton(),

                  if (widget.isExpanded) ...[
                    const SizedBox(width: AppSpacing.xs),
                    // Settings button
                    Expanded(
                      child: Tooltip(
                        message: l10n.navigationSettings,
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
                            child: Row(
                              children: [
                                const Icon(Icons.settings_outlined),
                                const SizedBox(width: AppSpacing.xs),
                                Flexible(child: Text(l10n.navigationSettings)),
                              ],
                            ),
                          ),
                        ),
                      ),
                    ),
                  ],
                ],
              ),
              // Sign Out button (hidden for anonymous users)
              if (widget.isExpanded && !isAnonymous)
                Padding(
                  padding: const EdgeInsets.only(top: AppSpacing.xs),
                  child: Tooltip(
                    message: l10n.sidebarSignOut,
                    child: InkWell(
                      onTap: () async {
                        await ref
                            .read(authStateControllerProvider.notifier)
                            .signOut();
                      },
                      borderRadius: const BorderRadius.all(
                        Radius.circular(AppSpacing.radiusSM),
                      ),
                      child: Container(
                        height: AppSpacing.minTouchTarget,
                        padding: const EdgeInsets.symmetric(
                          horizontal: AppSpacing.sm,
                        ),
                        child: Row(
                          children: [
                            Icon(
                              Icons.logout,
                              color: AppColors.textSecondary(context),
                            ),
                            const SizedBox(width: AppSpacing.xs),
                            Flexible(
                              child: Text(
                                l10n.sidebarSignOut,
                                style: TextStyle(
                                  color: AppColors.textSecondary(context),
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                ),
            ],
          ),
        ),
        // Show buttons below in collapsed mode
        if (!widget.isExpanded) ...[
          Container(
            padding: const EdgeInsets.all(AppSpacing.xs),
            child: Tooltip(
              message: l10n.navigationSettings,
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
          // Sign out button in collapsed mode (hidden for anonymous users)
          if (!isAnonymous)
            Container(
              padding: const EdgeInsets.all(AppSpacing.xs),
              child: Tooltip(
                message: l10n.sidebarSignOut,
                child: InkWell(
                  onTap: () async {
                    await ref
                        .read(authStateControllerProvider.notifier)
                        .signOut();
                  },
                  borderRadius: const BorderRadius.all(
                    Radius.circular(AppSpacing.radiusSM),
                  ),
                  child: Container(
                    height: AppSpacing.minTouchTarget,
                    padding: const EdgeInsets.symmetric(
                      horizontal: AppSpacing.xs,
                    ),
                    child: Icon(
                      Icons.logout,
                      color: AppColors.textSecondary(context),
                    ),
                  ),
                ),
              ),
            ),
        ],
      ],
    );
  }
}

/// Individual space list item with hover states and keyboard shortcuts
class _SpaceListItem extends ConsumerStatefulWidget {
  const _SpaceListItem({
    required this.space,
    required this.isSelected,
    required this.isExpanded,
    required this.isDarkMode,
    required this.onTap,
    this.keyboardShortcut,
    this.cachedCount,
  });

  final Space space;
  final bool isSelected;
  final bool isExpanded;
  final bool isDarkMode;
  final VoidCallback onTap;
  final String? keyboardShortcut;
  final int? cachedCount;

  @override
  ConsumerState<_SpaceListItem> createState() => _SpaceListItemState();
}

class _SpaceListItemState extends ConsumerState<_SpaceListItem> {
  bool _isHovered = false;

  /// Build item count widget with async loading support
  Widget _buildItemCount(BuildContext context, WidgetRef ref) {
    // If we have a cached count, use it immediately
    if (widget.cachedCount != null) {
      return Text(widget.cachedCount.toString());
    }

    // Otherwise, load asynchronously
    return FutureBuilder<int>(
      future: ref
          .read(spacesControllerProvider.notifier)
          .getSpaceItemCount(widget.space.id),
      builder: (context, snapshot) {
        if (snapshot.hasData) {
          return Text(snapshot.data.toString());
        }
        return const Text('...');
      },
    );
  }

  LinearGradient _getTypeGradient(BuildContext context) {
    final temporalTheme = Theme.of(context).extension<TemporalFlowTheme>()!;

    // For now, use color field if available to determine gradient
    // In the future, this could be based on a space type field
    final spaceColor = widget.space.color;
    if (spaceColor != null) {
      // Map colors to gradients
      if (spaceColor.contains('red') || spaceColor.contains('orange')) {
        return temporalTheme.taskGradient;
      } else if (spaceColor.contains('blue') || spaceColor.contains('cyan')) {
        return temporalTheme.noteGradient;
      } else if (spaceColor.contains('violet') ||
          spaceColor.contains('purple')) {
        return temporalTheme.listGradient;
      }
    }

    return temporalTheme.primaryGradient;
  }

  @override
  Widget build(BuildContext context) {
    final gradient = _getTypeGradient(context);

    final textColor = widget.isSelected
        ? AppColors.text(context)
        : AppColors.textSecondary(context);

    return Padding(
      padding: const EdgeInsets.symmetric(
        horizontal: AppSpacing.xs,
        vertical: AppSpacing.xxs,
      ),
      child: Semantics(
        label: widget.isExpanded
            ? '${widget.space.name}${widget.cachedCount != null ? ", ${widget.cachedCount} items" : ""}${widget.keyboardShortcut != null ? ", keyboard shortcut ${widget.keyboardShortcut}" : ""}'
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
                : widget.cachedCount != null
                ? '${widget.space.name} (${widget.cachedCount} items)'
                : widget.space.name,
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
                                      ? AppColors.neutral800
                                      : AppColors.neutral100)
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
                                  const SizedBox(width: AppSpacing.xs),
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
                              widget.space.icon ??
                                  widget.space.name[0].toUpperCase(),
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
                        if (widget.isExpanded && (widget.cachedCount ?? 0) > 0)
                          Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: AppSpacing.xs,
                              vertical: AppSpacing.xxs,
                            ),
                            decoration: BoxDecoration(
                              color: widget.isDarkMode
                                  ? AppColors.neutral800
                                  : AppColors.neutral100,
                              borderRadius: BorderRadius.circular(
                                AppSpacing.radiusFull,
                              ),
                            ),
                            child: DefaultTextStyle(
                              style: TextStyle(
                                fontSize: 12,
                                color: textColor,
                                fontWeight: FontWeight.w500,
                              ),
                              child: _buildItemCount(context, ref),
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
