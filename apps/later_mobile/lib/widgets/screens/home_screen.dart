import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:later_mobile/design_system/atoms/buttons/primary_button.dart';
import 'package:later_mobile/design_system/atoms/chips/filter_chip.dart';
import 'package:later_mobile/design_system/organisms/cards/list_card.dart';
import 'package:later_mobile/design_system/organisms/cards/note_card.dart';
import 'package:later_mobile/design_system/organisms/cards/todo_list_card.dart';
import 'package:later_mobile/design_system/organisms/empty_states/empty_space_state.dart';
import 'package:later_mobile/design_system/organisms/empty_states/welcome_state.dart';
import 'package:later_mobile/design_system/organisms/fab/responsive_fab.dart';
import 'package:later_mobile/design_system/tokens/tokens.dart';
import 'package:provider/provider.dart';

import '../../core/responsive/breakpoints.dart';
import '../../core/theme/temporal_flow_theme.dart';
import '../../core/utils/item_type_detector.dart';
import '../../core/utils/responsive_modal.dart';
import '../../data/models/note_model.dart';
import '../../data/models/list_model.dart';
import '../../data/models/space_model.dart';
import '../../data/models/todo_list_model.dart';
import '../../providers/auth_provider.dart';
import '../../providers/content_provider.dart';
import '../../providers/spaces_provider.dart';
import '../modals/create_content_modal.dart';
import '../modals/space_switcher_modal.dart';
import '../navigation/app_sidebar.dart';
import '../navigation/icon_only_bottom_nav.dart';
import 'list_detail_screen.dart';
import 'note_detail_screen.dart';
import 'todo_list_detail_screen.dart';

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
class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  // Navigation state
  int _selectedNavIndex = 0;

  // Sidebar state for desktop
  bool _isSidebarExpanded = true;

  // Filter state
  ContentFilter _selectedFilter = ContentFilter.all;

  // Pagination state
  int _currentItemCount = 100; // Initially load 100 items
  bool _isLoadingMore = false;

  // Reorder state
  bool _isReordering = false;

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
    final spacesProvider = context.read<SpacesProvider>();
    final contentProvider = context.read<ContentProvider>();

    // Load spaces first
    await spacesProvider.loadSpaces();

    // Load content for current space if available
    if (spacesProvider.currentSpace != null) {
      await contentProvider.loadSpaceContent(spacesProvider.currentSpace!.id);
    }
  }

  /// Refresh content
  Future<void> _handleRefresh() async {
    final spacesProvider = context.read<SpacesProvider>();
    final contentProvider = context.read<ContentProvider>();

    if (spacesProvider.currentSpace != null) {
      await contentProvider.loadSpaceContent(spacesProvider.currentSpace!.id);
    }
  }

  /// Filter content based on selected filter
  /// Returns a paginated list of mixed content (TodoList, ListModel, Item)
  List<dynamic> _getFilteredContent(ContentProvider contentProvider) {
    // Get filtered content from ContentProvider
    final filtered = contentProvider.getFilteredContent(_selectedFilter);

    // Apply pagination: return only the current page of items
    return filtered.take(_currentItemCount).toList();
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
                final spacesProvider = context.read<SpacesProvider>();
                final contentProvider = context.read<ContentProvider>();

                final result = await ResponsiveModal.show<bool>(
                  context: context,
                  child: const SpaceSwitcherModal(),
                );
                if (!mounted) return;

                if (result == true) {
                  // Space was switched, reload content and reset pagination
                  _resetPagination();
                  if (spacesProvider.currentSpace != null) {
                    await contentProvider.loadSpaceContent(
                      spacesProvider.currentSpace!.id,
                    );
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
          icon: Icon(
            Icons.more_vert,
            color: AppColors.textSecondary(context),
          ),
          tooltip: 'Menu',
          onSelected: (value) async {
            if (value == 'signout') {
              final authProvider = context.read<AuthProvider>();
              await authProvider.signOut();
            }
          },
          itemBuilder: (context) => [
            const PopupMenuItem(
              value: 'signout',
              child: Row(
                children: [
                  Icon(Icons.logout),
                  SizedBox(width: AppSpacing.sm),
                  Text('Sign Out'),
                ],
              ),
            ),
          ],
        ),
      ],
    );
  }

  /// Build filter chips for content types
  Widget _buildFilterChips(BuildContext context) {
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
            label: 'All',
            icon: Icons.grid_view,
            isSelected: _selectedFilter == ContentFilter.all,
            onSelected: () {
              setState(() {
                _selectedFilter = ContentFilter.all;
                _resetPagination();
              });
            },
          ),
          TemporalFilterChip(
            label: 'Todo Lists',
            icon: Icons.check_box_outlined,
            isSelected: _selectedFilter == ContentFilter.todoLists,
            onSelected: () {
              setState(() {
                _selectedFilter = ContentFilter.todoLists;
                _resetPagination();
              });
            },
          ),
          TemporalFilterChip(
            label: 'Lists',
            icon: Icons.list_alt,
            isSelected: _selectedFilter == ContentFilter.lists,
            onSelected: () {
              setState(() {
                _selectedFilter = ContentFilter.lists;
                _resetPagination();
              });
            },
          ),
          TemporalFilterChip(
            label: 'Notes',
            icon: Icons.description_outlined,
            isSelected: _selectedFilter == ContentFilter.notes,
            onSelected: () {
              setState(() {
                _selectedFilter = ContentFilter.notes;
                _resetPagination();
              });
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
    SpacesProvider spacesProvider,
    ContentProvider contentProvider,
  ) {
    // Check if completely empty (no content at all)
    if (content.isEmpty && contentProvider.getTotalCount() == 0) {
      // Check if this is a new user (welcome state)
      // Welcome state: no content AND default space is the only space
      final isNewUser =
          spacesProvider.spaces.length == 1 &&
          spacesProvider.spaces.first.name == 'Inbox';

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
    final allContent = contentProvider.getFilteredContent(_selectedFilter);
    final hasMoreItems = content.length < allContent.length;
    final itemCount = hasMoreItems ? content.length + 1 : content.length;

    return ReorderableListView.builder(
      padding: const EdgeInsets.symmetric(
        horizontal: AppSpacing.sm,
        vertical: AppSpacing.xs,
      ),
      itemCount: itemCount,
      buildDefaultDragHandles: false,
      onReorder: (oldIndex, newIndex) async {
        // Don't allow reordering the "Load More" button
        if (hasMoreItems && (oldIndex == content.length || newIndex > content.length)) {
          return;
        }

        // Don't allow reordering if already reordering
        if (_isReordering) return;

        setState(() {
          _isReordering = true;
        });

        try {
          await contentProvider.reorderContent(
            _selectedFilter,
            oldIndex,
            newIndex,
          );
        } finally {
          if (mounted) {
            setState(() {
              _isReordering = false;
            });
          }
        }
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
                          'Load More (${allContent.length - content.length} remaining)',
                      icon: Icons.expand_more,
                      onPressed: () => _loadMoreItems(allContent.length),
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
  Widget _buildFAB(BuildContext context) {
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
    } else if (item is Item) {
      card = NoteCard(
        key: ValueKey<String>(_getItemId(item)),
        item: item,
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
    } else if (item is Item) {
      return 'note-${item.id}';
    }
    return 'unknown';
  }

  /// Build mobile layout
  Widget _buildMobileLayout(
    BuildContext context,
    ContentProvider contentProvider,
    SpacesProvider spacesProvider,
  ) {
    final filteredContent = _getFilteredContent(contentProvider);
    final temporalTheme = Theme.of(context).extension<TemporalFlowTheme>()!;

    return Scaffold(
      appBar: _buildAppBar(context, spacesProvider.currentSpace),
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
                  child: contentProvider.isLoading
                      ? const Center(child: CircularProgressIndicator())
                      : _buildContentList(
                          context,
                          filteredContent,
                          spacesProvider.currentSpace,
                          spacesProvider,
                          contentProvider,
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
      floatingActionButton: _buildFAB(context),
    );
  }

  /// Build desktop layout
  Widget _buildDesktopLayout(
    BuildContext context,
    ContentProvider contentProvider,
    SpacesProvider spacesProvider,
  ) {
    final filteredContent = _getFilteredContent(contentProvider);
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final temporalTheme = Theme.of(context).extension<TemporalFlowTheme>()!;

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
                    _buildAppBar(context, spacesProvider.currentSpace),

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
                        child: contentProvider.isLoading
                            ? const Center(child: CircularProgressIndicator())
                            : _buildContentList(
                                context,
                                filteredContent,
                                spacesProvider.currentSpace,
                                spacesProvider,
                                contentProvider,
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
      floatingActionButton: _buildFAB(context),
    );
  }

  @override
  Widget build(BuildContext context) {
    final isDesktop = context.isDesktopOrLarger;
    final contentProvider = context.watch<ContentProvider>();
    final spacesProvider = context.watch<SpacesProvider>();

    return Focus(
      autofocus: true,
      onKeyEvent: _handleKeyEvent,
      child: isDesktop
          ? _buildDesktopLayout(context, contentProvider, spacesProvider)
          : _buildMobileLayout(context, contentProvider, spacesProvider),
    );
  }
}
