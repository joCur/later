import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:later_mobile/l10n/app_localizations.dart';
import 'package:later_mobile/design_system/atoms/buttons/primary_button.dart';
import 'package:later_mobile/design_system/atoms/chips/filter_chip.dart';
import 'package:later_mobile/design_system/organisms/cards/list_card.dart';
import 'package:later_mobile/design_system/organisms/cards/note_card.dart';
import 'package:later_mobile/design_system/organisms/cards/todo_list_card.dart';
import 'package:later_mobile/design_system/organisms/empty_states/empty_space_state.dart';
import 'package:later_mobile/design_system/organisms/empty_states/no_spaces_state.dart';
import 'package:later_mobile/design_system/organisms/empty_states/welcome_state.dart';
import 'package:later_mobile/design_system/organisms/fab/responsive_fab.dart';
import 'package:later_mobile/design_system/tokens/tokens.dart';

import 'package:later_mobile/core/responsive/breakpoints.dart';
import 'package:later_mobile/core/theme/temporal_flow_theme.dart';
import 'package:later_mobile/core/utils/item_type_detector.dart';
import 'package:later_mobile/core/utils/responsive_modal.dart';
import 'package:later_mobile/features/lists/domain/models/list_model.dart';
import 'package:later_mobile/features/notes/domain/models/note.dart';
import 'package:later_mobile/features/todo_lists/domain/models/todo_list.dart';
import 'package:later_mobile/features/spaces/domain/models/space.dart';
import 'package:later_mobile/features/spaces/presentation/controllers/spaces_controller.dart';
import 'package:later_mobile/features/spaces/presentation/controllers/current_space_controller.dart';
import 'package:later_mobile/features/auth/presentation/controllers/auth_state_controller.dart';
import 'package:later_mobile/features/notes/presentation/controllers/notes_controller.dart';
import 'package:later_mobile/features/todo_lists/presentation/controllers/todo_lists_controller.dart';
import 'package:later_mobile/features/lists/presentation/controllers/lists_controller.dart';
import 'package:later_mobile/features/home/presentation/controllers/content_filter_controller.dart';
import 'package:later_mobile/features/home/presentation/widgets/create_content_modal.dart';
import 'package:later_mobile/features/spaces/presentation/widgets/create_space_modal.dart'
    show CreateSpaceModal, SpaceModalMode;
import 'package:later_mobile/features/spaces/presentation/widgets/space_switcher_modal.dart';
import 'package:later_mobile/shared/widgets/navigation/app_sidebar.dart';
import 'package:later_mobile/shared/widgets/navigation/icon_only_bottom_nav.dart';
import 'package:later_mobile/features/lists/presentation/screens/list_detail_screen.dart';
import 'package:later_mobile/features/notes/presentation/screens/note_detail_screen.dart';
import 'package:later_mobile/features/todo_lists/presentation/screens/todo_list_detail_screen.dart';

/// Main home screen for the Later app
///
/// Performance optimizations:
/// - Pagination: Initially loads 100 items, then loads more on demand
/// - Keys: Uses ValueKey for efficient list updates
/// - Efficient filtering: Filters items without rebuilding entire tree
///
/// Serves as the primary entry point showing all items in the current space.
/// Features:
/// - App bar with space switcher, search, and menu
/// - Filter chips (All, Tasks, Notes, Lists)
/// - Item list with pull-to-refresh and pagination
/// - Empty state when no items
/// - Quick capture FAB
/// - Responsive layout (bottom nav on mobile, sidebar on desktop)
///
/// The screen adapts between mobile and desktop layouts based on screen width.
class HomeScreen extends ConsumerStatefulWidget {
  const HomeScreen({super.key});

  @override
  ConsumerState<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends ConsumerState<HomeScreen> {
  // Navigation state
  int _selectedNavIndex = 0;

  // Sidebar state for desktop
  bool _isSidebarExpanded = true;

  // Pagination state
  int _currentItemCount = 100; // Initially load 100 items
  bool _isLoadingMore = false;

  // FAB pulse state
  bool _enableFabPulse = false;

  @override
  void initState() {
    super.initState();
    // Load initial data
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _loadData();
    });
  }

  /// Load spaces and content
  Future<void> _loadData() async {
    // Load spaces first
    await ref.read(spacesControllerProvider.notifier).loadSpaces();

    // Load content for current space if available
    final currentSpace = ref.read(currentSpaceControllerProvider).when(
      data: (space) => space,
      loading: () => null,
      error: (error, stack) => null,
    );
    if (currentSpace != null) {
      // Load notes via Riverpod
      ref.invalidate(notesControllerProvider(currentSpace.id));
      // Load TodoLists via Riverpod
      ref.invalidate(todoListsControllerProvider(currentSpace.id));
      // Load Lists via Riverpod
      ref.invalidate(listsControllerProvider(currentSpace.id));
    }
  }

  /// Refresh content
  Future<void> _handleRefresh() async {
    final currentSpace = ref.read(currentSpaceControllerProvider).when(
      data: (space) => space,
      loading: () => null,
      error: (error, stack) => null,
    );

    if (currentSpace != null) {
      // Refresh notes via Riverpod
      await ref.read(notesControllerProvider(currentSpace.id).notifier).refresh();
      // Refresh TodoLists via Riverpod
      ref.invalidate(todoListsControllerProvider(currentSpace.id));
      // Refresh Lists via Riverpod
      ref.invalidate(listsControllerProvider(currentSpace.id));
    }
  }

  /// Get filtered content with pagination applied
  /// Returns a paginated list of mixed content (TodoList, ListModel, Note)
  List<dynamic> _getFilteredContentWithPagination(String spaceId) {
    // Get filtered content from ContentFilterController
    final allContent = ref.read(contentFilterControllerProvider.notifier)
        .getFilteredContent(spaceId);

    // Apply pagination: return only the current page of items
    return allContent.take(_currentItemCount).toList();
  }

  /// Load more items (pagination)
  void _loadMoreItems(int totalItemCount) {
    if (_isLoadingMore) return;

    setState(() {
      _isLoadingMore = true;
    });

    // Simulate loading delay for smooth UX
    Future.delayed(const Duration(milliseconds: 100), () {
      if (mounted) {
        setState(() {
          _currentItemCount =
              (_currentItemCount + 50) // Load 50 more items
                  .clamp(0, totalItemCount);
          _isLoadingMore = false;
        });
      }
    });
  }

  /// Reset pagination when filter or space changes
  void _resetPagination() {
    setState(() {
      _currentItemCount = 100; // Reset to initial 100 items
    });
  }

  /// Show create content modal
  void _showCreateContentModal([ContentType? initialType]) {
    ResponsiveModal.show<void>(
      context: context,
      child: CreateContentModal(
        onClose: () => Navigator.of(context).pop(),
        initialType: initialType,
      ),
    );
  }

  /// Show create space modal
  Future<void> _showCreateSpaceModal() async {
    final result = await ResponsiveModal.show<bool>(
      context: context,
      child: const CreateSpaceModal(mode: SpaceModalMode.create),
    );

    // If a space was created, load content for the newly selected space
    // Note: SpacesController.createSpace() automatically sets the new space as current
    // and updates the spaces list, so we don't need to call loadSpaces()
    if (result == true && mounted) {
      final currentSpace = ref.read(currentSpaceControllerProvider).when(
        data: (space) => space,
        loading: () => null,
        error: (error, stack) => null,
      );

      // Load content for the new current space
      // (which was automatically set by createSpace)
      if (currentSpace != null) {
        // Load Notes via Riverpod
        ref.invalidate(notesControllerProvider(currentSpace.id));
        // Load TodoLists via Riverpod
        ref.invalidate(todoListsControllerProvider(currentSpace.id));
        // Load Lists via Riverpod
        ref.invalidate(listsControllerProvider(currentSpace.id));
      }
    }
  }

  /// Handle keyboard shortcuts
  KeyEventResult _handleKeyEvent(FocusNode node, KeyEvent event) {
    if (event is KeyDownEvent) {
      final isNKey = event.logicalKey == LogicalKeyboardKey.keyN;

      // Check for Cmd/Ctrl+N
      if (isNKey &&
          (HardwareKeyboard.instance.isControlPressed ||
              HardwareKeyboard.instance.isMetaPressed)) {
        _showCreateContentModal();
        return KeyEventResult.handled;
      }
    }
    return KeyEventResult.ignored;
  }

  /// Build app bar
  PreferredSizeWidget _buildAppBar(BuildContext context, Space? currentSpace) {
    final l10n = AppLocalizations.of(context)!;
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final temporalTheme = Theme.of(context).extension<TemporalFlowTheme>()!;

    // Mobile-first Phase 4: Flat app bar with 1px bottom border
    // - No glass effect (solid background)
    // - 1px bottom border (neutral, 10% opacity)
    // - Elevation: 0 (flat, modern look)
    // - Height: 56px (Android standard - default AppBar)
    return AppBar(
      backgroundColor: AppColors.surface(context),
      elevation: 0, // Flat design
      automaticallyImplyLeading: false,
      shape: Border(
        bottom: BorderSide(
          color: isDark
              ? AppColors.neutral600.withValues(alpha: 0.1)
              : AppColors.neutral400.withValues(alpha: 0.1),
        ),
      ),
      title: Row(
        children: [
          // Space switcher button
          Expanded(
            child: InkWell(
              onTap: () async {
                final result = await ResponsiveModal.show<bool>(
                  context: context,
                  child: const SpaceSwitcherModal(),
                );
                if (!mounted) return;

                if (result == true) {
                  // Space was switched, reload content and reset pagination
                  _resetPagination();
                  final currentSpace = ref.read(currentSpaceControllerProvider).when(
                    data: (space) => space,
                    loading: () => null,
                    error: (error, stack) => null,
                  );
                  if (currentSpace != null) {
                    // Load Notes via Riverpod
                    ref.invalidate(notesControllerProvider(currentSpace.id));
                    // Load TodoLists via Riverpod
                    ref.invalidate(todoListsControllerProvider(currentSpace.id));
                    // Load Lists via Riverpod
                    ref.invalidate(listsControllerProvider(currentSpace.id));
                  }
                }
              },
              borderRadius: BorderRadius.circular(AppSpacing.radiusMD),
              child: Padding(
                padding: const EdgeInsets.symmetric(
                  horizontal: AppSpacing.xs,
                  vertical: AppSpacing.xxs,
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    // Space icon with gradient (if no emoji)
                    if (currentSpace?.icon != null)
                      Text(
                        currentSpace!.icon!,
                        style: const TextStyle(fontSize: 24),
                      )
                    else
                      ShaderMask(
                        shaderCallback: (bounds) =>
                            temporalTheme.primaryGradient.createShader(bounds),
                        child: Icon(
                          Icons.folder_outlined,
                          size: 24,
                          color: isDark
                              ? AppColors.neutral400
                              : AppColors.neutral600,
                        ),
                      ),
                    const SizedBox(width: AppSpacing.xs),

                    // Space name
                    Flexible(
                      child: Text(
                        currentSpace?.name ?? 'No Space',
                        style: AppTypography.h4.copyWith(
                          color: isDark
                              ? AppColors.neutral400
                              : AppColors.neutral600,
                        ),
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),

                    // Dropdown icon
                    const SizedBox(width: AppSpacing.xxs),
                    Icon(
                      Icons.arrow_drop_down,
                      color: isDark
                          ? AppColors.neutral500
                          : AppColors.neutral500,
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
      actions: [
        // Search button
        IconButton(
          icon: const Icon(Icons.search),
          onPressed: () {
            debugPrint('Search tapped');
          },
          tooltip: 'Search',
          color: AppColors.textSecondary(context),
        ),

        // Menu button
        PopupMenuButton<String>(
          icon: Icon(Icons.more_vert, color: AppColors.textSecondary(context)),
          tooltip: 'Menu',
          itemBuilder: (context) => [
            PopupMenuItem(
              value: 'signout',
              child: Row(
                children: [
                  const Icon(Icons.logout),
                  const SizedBox(width: AppSpacing.sm),
                  Text(l10n.menuSignOut),
                ],
              ),
            ),
          ],
          onSelected: (value) async {
            if (value == 'signout') {
              await ref.read(authStateControllerProvider.notifier).signOut();
            }
          },
        ),
      ],
    );
  }

  /// Build filter chips for content types
  Widget _buildFilterChips(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final selectedFilter = ref.watch(contentFilterControllerProvider);

    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      padding: const EdgeInsets.symmetric(
        horizontal: AppSpacing.sm,
        vertical: AppSpacing.xs,
      ),
      child: Wrap(
        spacing: AppSpacing.xs,
        children: [
          TemporalFilterChip(
            label: l10n.filterAll,
            icon: Icons.grid_view,
            isSelected: selectedFilter == ContentFilter.all,
            onSelected: () {
              ref.read(contentFilterControllerProvider.notifier)
                  .setFilter(ContentFilter.all);
              _resetPagination();
            },
          ),
          TemporalFilterChip(
            label: l10n.filterTodoLists,
            icon: Icons.check_box_outlined,
            isSelected: selectedFilter == ContentFilter.todoLists,
            onSelected: () {
              ref.read(contentFilterControllerProvider.notifier)
                  .setFilter(ContentFilter.todoLists);
              _resetPagination();
            },
          ),
          TemporalFilterChip(
            label: l10n.filterLists,
            icon: Icons.list_alt,
            isSelected: selectedFilter == ContentFilter.lists,
            onSelected: () {
              ref.read(contentFilterControllerProvider.notifier)
                  .setFilter(ContentFilter.lists);
              _resetPagination();
            },
          ),
          TemporalFilterChip(
            label: l10n.filterNotes,
            icon: Icons.description_outlined,
            isSelected: selectedFilter == ContentFilter.notes,
            onSelected: () {
              ref.read(contentFilterControllerProvider.notifier)
                  .setFilter(ContentFilter.notes);
              _resetPagination();
            },
          ),
        ],
      ),
    );
  }

  /// Build content list with mixed types and pagination
  Widget _buildContentList(
    BuildContext context,
    List<dynamic> content,
    Space? currentSpace,
    List<Space> spaces,
    int totalCount,
  ) {
    // Check for no spaces first (new user without any spaces)
    if (spaces.isEmpty) {
      return NoSpacesState(onActionPressed: _showCreateSpaceModal);
    }

    // Check if completely empty (no content at all)
    if (content.isEmpty && totalCount == 0) {
      // Check if this is a new user (welcome state)
      // Welcome state: no content AND default space is the only space
      final isNewUser =
          spaces.length == 1 &&
          spaces.first.name == 'Inbox';

      if (isNewUser) {
        // Show welcome state for first-time users
        return WelcomeState(
          onActionPressed: _showCreateContentModal,
          enableFabPulse: (enabled) {
            if (mounted) {
              setState(() {
                _enableFabPulse = enabled;
              });
            }
          },
        );
      } else {
        // Show empty space state for existing users with empty spaces
        return EmptySpaceState(
          spaceName: currentSpace?.name ?? 'space',
          onActionPressed: _showCreateContentModal,
          enableFabPulse: (enabled) {
            if (mounted) {
              setState(() {
                _enableFabPulse = enabled;
              });
            }
          },
        );
      }
    }

    // Calculate if there are more items to load
    final hasMoreItems = content.length < totalCount;
    final itemCount = hasMoreItems ? content.length + 1 : content.length;

    return ReorderableListView.builder(
      padding: const EdgeInsets.symmetric(
        horizontal: AppSpacing.sm,
        vertical: AppSpacing.xs,
      ),
      itemCount: itemCount,
      buildDefaultDragHandles: false,
      onReorder: (oldIndex, newIndex) async {
        // Adjust newIndex if moving down (Flutter's ReorderableListView behavior)
        if (newIndex > oldIndex) {
          newIndex -= 1;
        }

        // Get current space ID
        final currentSpace = ref.read(currentSpaceControllerProvider).when(
          data: (space) => space,
          loading: () => null,
          error: (error, stack) => null,
        );
        if (currentSpace == null) return;

        // Create a mutable copy of content and perform reorder
        final reorderedContent = List<dynamic>.from(content);
        final item = reorderedContent.removeAt(oldIndex);
        reorderedContent.insert(newIndex, item);

        // Group items by type and extract IDs in new order
        final noteIds = <String>[];
        final todoListIds = <String>[];
        final listIds = <String>[];

        for (final item in reorderedContent) {
          if (item is Note) {
            noteIds.add(item.id);
          } else if (item is TodoList) {
            todoListIds.add(item.id);
          } else if (item is ListModel) {
            listIds.add(item.id);
          }
        }

        // Call reorder on each controller with the new IDs in order
        final futures = <Future<void>>[];

        if (noteIds.isNotEmpty) {
          futures.add(
            ref.read(notesControllerProvider(currentSpace.id).notifier)
                .reorderLists(noteIds),
          );
        }

        if (todoListIds.isNotEmpty) {
          futures.add(
            ref.read(todoListsControllerProvider(currentSpace.id).notifier)
                .reorderLists(todoListIds),
          );
        }

        if (listIds.isNotEmpty) {
          futures.add(
            ref.read(listsControllerProvider(currentSpace.id).notifier)
                .reorderLists(listIds),
          );
        }

        // Wait for all reorders to complete
        await Future.wait(futures);
      },
      itemBuilder: (context, index) {
        // Load more button at the end
        if (hasMoreItems && index == content.length) {
          return Padding(
            key: const ValueKey('load_more_button'),
            padding: const EdgeInsets.symmetric(vertical: AppSpacing.md),
            child: Center(
              child: _isLoadingMore
                  ? const CircularProgressIndicator()
                  : PrimaryButton(
                      text:
                          'Load More (${totalCount - content.length} remaining)',
                      icon: Icons.expand_more,
                      onPressed: () => _loadMoreItems(totalCount),
                    ),
            ),
          );
        }

        final item = content[index];

        // Render different card types based on content type
        return _buildContentCard(item, index);
      },
    );
  }

  /// Build simple FAB for creating content
  /// Returns null when there are no spaces (user should create a space first)
  Widget? _buildFAB(BuildContext context, List<Space> spaces) {
    // Don't show FAB if there are no spaces
    // The NoSpacesState has its own action button to create the first space
    if (spaces.isEmpty) {
      return null;
    }

    return ResponsiveFab(
      icon: Icons.add,
      label: 'Create',
      onPressed: _showCreateContentModal,
      tooltip: 'Create content',
      enablePulse: _enableFabPulse,
      gradient: AppColors.listGradient,
    );
  }

  /// Build the appropriate card widget for each content type
  Widget _buildContentCard(dynamic item, int index) {
    // Build card with onTap callback for navigation
    // Cards internally wrap their drag handles with ReorderableDragStartListener
    Widget card;

    if (item is TodoList) {
      card = TodoListCard(
        key: ValueKey<String>(_getItemId(item)),
        todoList: item,
        reorderIndex: index,
        // index omitted (null) to disable entrance animation for reorderable items
        onTap: () {
          Navigator.of(context).push(
            MaterialPageRoute<void>(
              builder: (context) => TodoListDetailScreen(todoList: item),
            ),
          );
        },
      );
    } else if (item is ListModel) {
      card = ListCard(
        key: ValueKey<String>(_getItemId(item)),
        list: item,
        reorderIndex: index,
        // index omitted (null) to disable entrance animation for reorderable items
        onTap: () {
          Navigator.of(context).push(
            MaterialPageRoute<void>(
              builder: (context) => ListDetailScreen(list: item),
            ),
          );
        },
      );
    } else if (item is Note) {
      card = NoteCard(
        key: ValueKey<String>(_getItemId(item)),
        note: item,
        reorderIndex: index,
        // index omitted (null) to disable entrance animation for reorderable items
        onTap: () {
          Navigator.of(context).push(
            MaterialPageRoute<void>(
              builder: (context) => NoteDetailScreen(note: item),
            ),
          );
        },
      );
    } else {
      // Fallback for unknown types
      return const SizedBox.shrink();
    }

    return card;
  }

  /// Get item ID for any content type
  String _getItemId(dynamic item) {
    if (item is TodoList) {
      return 'todo-${item.id}';
    } else if (item is ListModel) {
      return 'list-${item.id}';
    } else if (item is Note) {
      return 'note-${item.id}';
    }
    return 'unknown';
  }

  /// Build mobile layout
  Widget _buildMobileLayout(
    BuildContext context,
    Space? currentSpace,
    List<Space> spaces,
  ) {
    final temporalTheme = Theme.of(context).extension<TemporalFlowTheme>()!;

    // Get filtered content and metadata from ContentFilterController
    final filteredContent = currentSpace != null
        ? _getFilteredContentWithPagination(currentSpace.id)
        : <dynamic>[];
    final isLoading = currentSpace != null
        ? ref.read(contentFilterControllerProvider.notifier).isLoading(currentSpace.id)
        : false;
    final totalCount = currentSpace != null
        ? ref.read(contentFilterControllerProvider.notifier).getTotalCount(currentSpace.id)
        : 0;

    return Scaffold(
      appBar: _buildAppBar(context, currentSpace),
      body: Stack(
        children: [
          // Main content
          Column(
            children: [
              // Filter chips
              _buildFilterChips(context),
              const Divider(height: 1),

              // Content list
              Expanded(
                child: RefreshIndicator(
                  onRefresh: _handleRefresh,
                  color: temporalTheme.primaryGradient.colors.first,
                  backgroundColor: AppColors.surface(context),
                  child: isLoading
                      ? const Center(child: CircularProgressIndicator())
                      : _buildContentList(
                          context,
                          filteredContent,
                          currentSpace,
                          spaces,
                          totalCount,
                        ),
                ),
              ),
            ],
          ),

          // Gradient overlay at top (2% opacity)
          Positioned(
            top: 0,
            left: 0,
            right: 0,
            child: IgnorePointer(
              child: Container(
                height: 100,
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                    colors: [
                      temporalTheme.primaryGradient.colors.first.withValues(
                        alpha: 0.02,
                      ),
                      Colors.transparent,
                    ],
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
      bottomNavigationBar: IconOnlyBottomNav(
        currentIndex: _selectedNavIndex,
        onDestinationSelected: (index) {
          setState(() => _selectedNavIndex = index);
        },
      ),
      floatingActionButton: _buildFAB(context, spaces),
    );
  }

  /// Build desktop layout
  Widget _buildDesktopLayout(
    BuildContext context,
    Space? currentSpace,
    List<Space> spaces,
  ) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final temporalTheme = Theme.of(context).extension<TemporalFlowTheme>()!;

    // Get filtered content and metadata from ContentFilterController
    final filteredContent = currentSpace != null
        ? _getFilteredContentWithPagination(currentSpace.id)
        : <dynamic>[];
    final isLoading = currentSpace != null
        ? ref.read(contentFilterControllerProvider.notifier).isLoading(currentSpace.id)
        : false;
    final totalCount = currentSpace != null
        ? ref.read(contentFilterControllerProvider.notifier).getTotalCount(currentSpace.id)
        : 0;

    return Scaffold(
      body: Row(
        children: [
          // Sidebar
          AppSidebar(
            isExpanded: _isSidebarExpanded,
            onToggleExpanded: () {
              setState(() => _isSidebarExpanded = !_isSidebarExpanded);
            },
          ),

          // Main content
          Expanded(
            child: Stack(
              children: [
                // Main content column
                Column(
                  children: [
                    // App bar
                    _buildAppBar(context, currentSpace),

                    // Filter chips
                    _buildFilterChips(context),
                    const Divider(height: 1),

                    // Content list
                    Expanded(
                      child: RefreshIndicator(
                        onRefresh: _handleRefresh,
                        color: temporalTheme.primaryGradient.colors.first,
                        backgroundColor: isDark
                            ? AppColors.neutral900
                            : Colors.white,
                        child: isLoading
                            ? const Center(child: CircularProgressIndicator())
                            : _buildContentList(
                                context,
                                filteredContent,
                                currentSpace,
                                spaces,
                                totalCount,
                              ),
                      ),
                    ),
                  ],
                ),

                // Gradient overlay at top (2% opacity)
                Positioned(
                  top: 0,
                  left: 0,
                  right: 0,
                  child: IgnorePointer(
                    child: Container(
                      height: 100,
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          begin: Alignment.topCenter,
                          end: Alignment.bottomCenter,
                          colors: [
                            temporalTheme.primaryGradient.colors.first
                                .withValues(alpha: 0.02),
                            Colors.transparent,
                          ],
                        ),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
      floatingActionButton: _buildFAB(context, spaces),
    );
  }

  @override
  Widget build(BuildContext context) {
    final isDesktop = context.isDesktopOrLarger;
    final currentSpace = ref.watch(currentSpaceControllerProvider).when(
      data: (space) => space,
      loading: () => null,
      error: (error, stack) => null,
    );
    final spaces = ref.watch(spacesControllerProvider).when(
      data: (data) => data,
      loading: () => <Space>[],
      error: (error, stack) => <Space>[],
    );

    return Focus(
      autofocus: true,
      onKeyEvent: _handleKeyEvent,
      child: isDesktop
          ? _buildDesktopLayout(context, currentSpace, spaces)
          : _buildMobileLayout(context, currentSpace, spaces),
    );
  }
}
