import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_typography.dart';
import '../../core/theme/app_spacing.dart';
import '../../core/theme/app_animations.dart';
import '../../core/responsive/breakpoints.dart';
import '../../data/models/item_model.dart';
import '../../data/models/space_model.dart';
import '../../data/models/todo_list_model.dart';
import '../../data/models/list_model.dart';
import '../../providers/content_provider.dart';
import '../../providers/spaces_provider.dart';
import '../components/cards/todo_list_card.dart';
import '../components/cards/list_card.dart';
import '../components/cards/note_card.dart';
import '../components/fab/quick_capture_fab.dart';
import '../components/empty_states/empty_space_state.dart';
import '../components/empty_states/welcome_state.dart';
import '../navigation/icon_only_bottom_nav.dart';
import '../navigation/app_sidebar.dart';
import '../modals/space_switcher_modal.dart';
import '../modals/quick_capture_modal.dart';
import 'todo_list_detail_screen.dart';
import 'list_detail_screen.dart';
import 'note_detail_screen.dart';

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
          _currentItemCount = (_currentItemCount + 50) // Load 50 more items
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

  /// Show quick capture modal
  void _showQuickCaptureModal() {
    final isMobile = Breakpoints.isMobile(context);

    if (isMobile) {
      // Show as bottom sheet on mobile
      showModalBottomSheet<void>(
        context: context,
        isScrollControlled: true,
        backgroundColor: Colors.transparent,
        builder: (context) => QuickCaptureModal(
          onClose: () => Navigator.of(context).pop(),
        ),
      );
    } else {
      // Show as dialog on desktop/tablet
      showDialog<void>(
        context: context,
        builder: (context) => QuickCaptureModal(
          onClose: () => Navigator.of(context).pop(),
        ),
      );
    }
  }

  /// Handle keyboard shortcuts
  KeyEventResult _handleKeyEvent(FocusNode node, KeyEvent event) {
    if (event is KeyDownEvent) {
      final isNKey = event.logicalKey == LogicalKeyboardKey.keyN;

      // Check for Cmd/Ctrl+N
      if (isNKey && (HardwareKeyboard.instance.isControlPressed ||
                     HardwareKeyboard.instance.isMetaPressed)) {
        _showQuickCaptureModal();
        return KeyEventResult.handled;
      }
    }
    return KeyEventResult.ignored;
  }

  /// Build app bar
  PreferredSizeWidget _buildAppBar(BuildContext context, Space? currentSpace) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    // Mobile-first Phase 4: Flat app bar with 1px bottom border
    // - No glass effect (solid background)
    // - 1px bottom border (neutral, 10% opacity)
    // - Elevation: 0 (flat, modern look)
    // - Height: 56px (Android standard - default AppBar)
    return AppBar(
            backgroundColor: isDark ? AppColors.surfaceDark : AppColors.surfaceLight,
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

                      final result = await SpaceSwitcherModal.show(context);
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
                              shaderCallback: (bounds) => AppColors
                                  .primaryGradientAdaptive(context)
                                  .createShader(bounds),
                              child: Icon(
                                Icons.folder_outlined,
                                size: 24,
                                color: isDark
                                    ? AppColors.textPrimaryDark
                                    : AppColors.textPrimaryLight,
                              ),
                            ),
                          const SizedBox(width: AppSpacing.xs),

                          // Space name
                          Flexible(
                            child: Text(
                              currentSpace?.name ?? 'No Space',
                              style: AppTypography.h4.copyWith(
                                color: isDark
                                    ? AppColors.textPrimaryDark
                                    : AppColors.textPrimaryLight,
                              ),
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),

                          // Dropdown icon
                          const SizedBox(width: AppSpacing.xxxs),
                          Icon(
                            Icons.arrow_drop_down,
                            color: isDark
                                ? AppColors.textSecondaryDark
                                : AppColors.textSecondaryLight,
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
                color: isDark
                    ? AppColors.textSecondaryDark
                    : AppColors.textSecondaryLight,
              ),

              // Menu button
              IconButton(
                icon: const Icon(Icons.more_vert),
                onPressed: () {
                  debugPrint('Menu tapped');
                },
                tooltip: 'Menu',
                color: isDark
                    ? AppColors.textSecondaryDark
                    : AppColors.textSecondaryLight,
              ),
            ],
          );
  }

  /// Build filter chips for content types
  Widget _buildFilterChips(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      padding: const EdgeInsets.symmetric(
        horizontal: AppSpacing.sm,
        vertical: AppSpacing.xs,
      ),
      child: Wrap(
        spacing: AppSpacing.xs,
        children: [
          _FilterChip(
            label: 'All',
            icon: Icons.grid_view,
            isSelected: _selectedFilter == ContentFilter.all,
            onSelected: () {
              setState(() {
                _selectedFilter = ContentFilter.all;
                _resetPagination();
              });
            },
            isDark: isDark,
          ),
          _FilterChip(
            label: 'Todo Lists',
            icon: Icons.check_box_outlined,
            isSelected: _selectedFilter == ContentFilter.todoLists,
            onSelected: () {
              setState(() {
                _selectedFilter = ContentFilter.todoLists;
                _resetPagination();
              });
            },
            isDark: isDark,
          ),
          _FilterChip(
            label: 'Lists',
            icon: Icons.list_alt,
            isSelected: _selectedFilter == ContentFilter.lists,
            onSelected: () {
              setState(() {
                _selectedFilter = ContentFilter.lists;
                _resetPagination();
              });
            },
            isDark: isDark,
          ),
          _FilterChip(
            label: 'Notes',
            icon: Icons.description_outlined,
            isSelected: _selectedFilter == ContentFilter.notes,
            onSelected: () {
              setState(() {
                _selectedFilter = ContentFilter.notes;
                _resetPagination();
              });
            },
            isDark: isDark,
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
      final isNewUser = spacesProvider.spaces.length == 1 &&
                        spacesProvider.spaces.first.name == 'Inbox';

      if (isNewUser) {
        // Show welcome state for first-time users
        return WelcomeState(
          onCreateFirstItem: _showQuickCaptureModal,
        );
      } else {
        // Show empty space state for existing users with empty spaces
        return EmptySpaceState(
          spaceName: currentSpace?.name ?? 'space',
          onQuickCapture: _showQuickCaptureModal,
        );
      }
    }

    // Calculate if there are more items to load
    final allContent = contentProvider.getFilteredContent(_selectedFilter);
    final hasMoreItems = content.length < allContent.length;
    final itemCount = hasMoreItems ? content.length + 1 : content.length;

    return ListView.builder(
      padding: const EdgeInsets.symmetric(
        horizontal: AppSpacing.sm,
        vertical: AppSpacing.xs,
      ),
      itemCount: itemCount,
      itemBuilder: (context, index) {
        // Load more button at the end
        if (hasMoreItems && index == content.length) {
          return Padding(
            padding: const EdgeInsets.symmetric(vertical: AppSpacing.md),
            child: Center(
              child: _isLoadingMore
                  ? const CircularProgressIndicator()
                  : ElevatedButton.icon(
                      onPressed: () => _loadMoreItems(allContent.length),
                      icon: const Icon(Icons.expand_more),
                      label: Text(
                        'Load More (${allContent.length - content.length} remaining)',
                      ),
                      style: ElevatedButton.styleFrom(
                        padding: const EdgeInsets.symmetric(
                          horizontal: AppSpacing.lg,
                          vertical: AppSpacing.sm,
                        ),
                      ),
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

  /// Build the appropriate card widget for each content type
  Widget _buildContentCard(dynamic item, int index) {
    // Use type checking to render correct card
    if (item is TodoList) {
      return TodoListCard(
        key: ValueKey<String>('todo-${item.id}'),
        todoList: item,
        onTap: () {
          Navigator.of(context).push(
            MaterialPageRoute<void>(
              builder: (context) => TodoListDetailScreen(todoList: item),
            ),
          );
        },
        onLongPress: () {
          debugPrint('TodoList long-pressed: ${item.id}');
        },
        index: index,
      );
    } else if (item is ListModel) {
      return ListCard(
        key: ValueKey<String>('list-${item.id}'),
        list: item,
        onTap: () {
          Navigator.of(context).push(
            MaterialPageRoute<void>(
              builder: (context) => ListDetailScreen(list: item),
            ),
          );
        },
        onLongPress: () {
          debugPrint('List long-pressed: ${item.id}');
        },
        index: index,
      );
    } else if (item is Item) {
      return NoteCard(
        key: ValueKey<String>('note-${item.id}'),
        item: item,
        onTap: () {
          Navigator.of(context).push(
            MaterialPageRoute<void>(
              builder: (context) => NoteDetailScreen(note: item),
            ),
          );
        },
        onLongPress: () {
          debugPrint('Note long-pressed: ${item.id}');
        },
        index: index,
      );
    } else {
      // Fallback for unknown types
      return const SizedBox.shrink();
    }
  }

  /// Build mobile layout
  Widget _buildMobileLayout(
    BuildContext context,
    ContentProvider contentProvider,
    SpacesProvider spacesProvider,
  ) {
    final filteredContent = _getFilteredContent(contentProvider);
    final isDark = Theme.of(context).brightness == Brightness.dark;

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
                  color: isDark ? AppColors.primaryStartDark : AppColors.primaryStart,
                  backgroundColor: isDark ? AppColors.surfaceDark : AppColors.surfaceLight,
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
                      (isDark ? AppColors.primaryStartDark : AppColors.primaryStart)
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
      bottomNavigationBar: IconOnlyBottomNav(
        currentIndex: _selectedNavIndex,
        onDestinationSelected: (index) {
          setState(() => _selectedNavIndex = index);
        },
      ),
      floatingActionButton: QuickCaptureFab(
        onPressed: _showQuickCaptureModal,
        tooltip: 'Quick capture',
      ),
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
                        color: isDark ? AppColors.primaryStartDark : AppColors.primaryStart,
                        backgroundColor: isDark ? AppColors.surfaceDark : AppColors.surfaceLight,
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
                            (isDark ? AppColors.primaryStartDark : AppColors.primaryStart)
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
      floatingActionButton: QuickCaptureFab(
        onPressed: _showQuickCaptureModal,
        tooltip: 'Quick capture',
      ),
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

/// Filter chip widget with gradient active state
class _FilterChip extends StatefulWidget {
  const _FilterChip({
    required this.label,
    required this.isSelected,
    required this.onSelected,
    required this.isDark,
    this.icon,
  });

  final String label;
  final bool isSelected;
  final VoidCallback onSelected;
  final bool isDark;
  final IconData? icon;

  @override
  State<_FilterChip> createState() => _FilterChipState();
}

class _FilterChipState extends State<_FilterChip> with SingleTickerProviderStateMixin {
  late AnimationController _animationController;
  late Animation<double> _scaleAnimation;

  @override
  void initState() {
    super.initState();

    // Phase 5: Initialize animation controller for selection animation
    _animationController = AnimationController(
      duration: const Duration(milliseconds: 200),
      vsync: this,
    );

    // Create scale animation: 1.0 -> 1.05 -> 1.0
    _scaleAnimation = TweenSequence<double>([
      TweenSequenceItem(
        tween: Tween<double>(begin: 1.0, end: 1.05)
            .chain(CurveTween(curve: Curves.easeOut)),
        weight: 50.0,
      ),
      TweenSequenceItem(
        tween: Tween<double>(begin: 1.05, end: 1.0)
            .chain(CurveTween(curve: Curves.easeIn)),
        weight: 50.0,
      ),
    ]).animate(_animationController);
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  void _handleTap() {
    // Phase 5: Trigger scale animation and haptic feedback on selection
    _animationController.forward(from: 0.0);
    AppAnimations.lightHaptic();
    widget.onSelected();
  }

  @override
  Widget build(BuildContext context) {
    // Mobile-first Phase 4: Pill-shaped chips with gradient border when selected
    // Phase 5: Added scale animation and haptic feedback
    // Selected: 2px gradient border (not full background)
    // Unselected: 1px solid border (neutral)
    // Height: 36px, padding: 16px horizontal
    // Font: 14px medium weight

    // Wrap with AnimatedBuilder for scale animation
    return AnimatedBuilder(
      animation: _scaleAnimation,
      builder: (context, child) {
        return Transform.scale(
          scale: _scaleAnimation.value,
          child: child,
        );
      },
      child: _buildChipContent(),
    );
  }

  Widget _buildChipContent() {
    final isDark = widget.isDark;

    if (widget.isSelected) {
      return Container(
        height: 36,
        decoration: BoxDecoration(
          gradient: isDark
              ? AppColors.primaryGradientDark
              : AppColors.primaryGradient,
          borderRadius: BorderRadius.circular(20), // Pill shape
        ),
        child: Container(
          margin: const EdgeInsets.all(2), // 2px border width
          decoration: BoxDecoration(
            color: isDark ? AppColors.surfaceDark : AppColors.surfaceLight,
            borderRadius: BorderRadius.circular(18), // 20 - 2 = 18
          ),
          child: Material(
            color: Colors.transparent,
            child: InkWell(
              onTap: _handleTap, // Phase 5: Use new handler with animation
              borderRadius: BorderRadius.circular(18),
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                child: Center(
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      if (widget.icon != null) ...[
                        Icon(
                          widget.icon,
                          size: 16,
                          color: isDark
                              ? AppColors.textPrimaryDark
                              : AppColors.textPrimaryLight,
                        ),
                        const SizedBox(width: 6),
                      ],
                      Text(
                        widget.label,
                        style: AppTypography.bodyMedium.copyWith(
                          fontSize: 14,
                          fontWeight: FontWeight.w500, // medium weight
                          color: isDark
                              ? AppColors.textPrimaryDark
                              : AppColors.textPrimaryLight,
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

    // Unselected state - 1px solid border
    return Container(
      height: 36,
      decoration: BoxDecoration(
        border: Border.all(
          color: isDark
              ? AppColors.neutral600.withValues(alpha: 0.3)
              : AppColors.neutral400.withValues(alpha: 0.3),
        ),
        borderRadius: BorderRadius.circular(20), // Pill shape
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: _handleTap, // Phase 5: Use new handler with animation
          borderRadius: BorderRadius.circular(20),
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: Center(
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  if (widget.icon != null) ...[
                    Icon(
                      widget.icon,
                      size: 16,
                      color: isDark
                          ? AppColors.textSecondaryDark
                          : AppColors.textSecondaryLight,
                    ),
                    const SizedBox(width: 6),
                  ],
                  Text(
                    widget.label,
                    style: AppTypography.bodyMedium.copyWith(
                      fontSize: 14,
                      fontWeight: FontWeight.w500, // medium weight
                      color: isDark
                          ? AppColors.textSecondaryDark
                          : AppColors.textSecondaryLight,
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

