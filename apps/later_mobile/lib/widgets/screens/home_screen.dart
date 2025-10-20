import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_typography.dart';
import '../../core/theme/app_spacing.dart';
import '../../core/responsive/breakpoints.dart';
import '../../data/models/item_model.dart';
import '../../data/models/space_model.dart';
import '../../providers/items_provider.dart';
import '../../providers/spaces_provider.dart';
import '../components/cards/item_card.dart';
import '../components/fab/quick_capture_fab.dart';
import '../components/empty_states/empty_space_state.dart';
import '../components/empty_states/welcome_state.dart';
import '../navigation/bottom_navigation_bar.dart';
import '../navigation/app_sidebar.dart';
import '../modals/space_switcher_modal.dart';
import '../modals/quick_capture_modal.dart';
import 'item_detail_screen.dart';

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
  ItemFilter _selectedFilter = ItemFilter.all;

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

  /// Load spaces and items
  Future<void> _loadData() async {
    final spacesProvider = context.read<SpacesProvider>();
    final itemsProvider = context.read<ItemsProvider>();

    // Load spaces first
    await spacesProvider.loadSpaces();

    // Load items for current space if available
    if (spacesProvider.currentSpace != null) {
      await itemsProvider.loadItemsBySpace(spacesProvider.currentSpace!.id);
    }
  }

  /// Refresh items
  Future<void> _handleRefresh() async {
    final spacesProvider = context.read<SpacesProvider>();
    final itemsProvider = context.read<ItemsProvider>();

    if (spacesProvider.currentSpace != null) {
      await itemsProvider.loadItemsBySpace(spacesProvider.currentSpace!.id);
    }
  }

  /// Filter items based on selected filter
  List<Item> _getFilteredItems(List<Item> items) {
    List<Item> filtered;
    switch (_selectedFilter) {
      case ItemFilter.all:
        filtered = items;
        break;
      case ItemFilter.tasks:
        filtered = items.where((item) => item.type == ItemType.task).toList();
        break;
      case ItemFilter.notes:
        filtered = items.where((item) => item.type == ItemType.note).toList();
        break;
      case ItemFilter.lists:
        filtered = items.where((item) => item.type == ItemType.list).toList();
        break;
    }

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

    return AppBar(
            backgroundColor: isDark ? AppColors.surfaceDark : AppColors.surfaceLight,
            elevation: AppSpacing.elevation1,
            automaticallyImplyLeading: false,
            title: Row(
              children: [
                // Space switcher button
                Expanded(
                  child: InkWell(
                    onTap: () async {
                      final spacesProvider = context.read<SpacesProvider>();
                      final itemsProvider = context.read<ItemsProvider>();

                      final result = await SpaceSwitcherModal.show(context);
                      if (!mounted) return;

                      if (result == true) {
                        // Space was switched, reload items and reset pagination
                        _resetPagination();
                        if (spacesProvider.currentSpace != null) {
                          await itemsProvider.loadItemsBySpace(
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

  /// Build filter chips
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
            isSelected: _selectedFilter == ItemFilter.all,
            onSelected: () {
              setState(() {
                _selectedFilter = ItemFilter.all;
                _resetPagination();
              });
            },
            isDark: isDark,
          ),
          _FilterChip(
            label: 'Tasks',
            isSelected: _selectedFilter == ItemFilter.tasks,
            onSelected: () {
              setState(() {
                _selectedFilter = ItemFilter.tasks;
                _resetPagination();
              });
            },
            isDark: isDark,
          ),
          _FilterChip(
            label: 'Notes',
            isSelected: _selectedFilter == ItemFilter.notes,
            onSelected: () {
              setState(() {
                _selectedFilter = ItemFilter.notes;
                _resetPagination();
              });
            },
            isDark: isDark,
          ),
          _FilterChip(
            label: 'Lists',
            isSelected: _selectedFilter == ItemFilter.lists,
            onSelected: () {
              setState(() {
                _selectedFilter = ItemFilter.lists;
                _resetPagination();
              });
            },
            isDark: isDark,
          ),
        ],
      ),
    );
  }

  /// Build item list with pagination
  Widget _buildItemList(
    BuildContext context,
    List<Item> items,
    Space? currentSpace,
    SpacesProvider spacesProvider,
    ItemsProvider itemsProvider,
  ) {
    if (items.isEmpty && itemsProvider.items.isEmpty) {
      // Check if this is a new user (welcome state)
      // Welcome state: no items AND default space is the only space
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
    final filteredItems = _selectedFilter == ItemFilter.all
        ? itemsProvider.items
        : itemsProvider.items.where((item) {
            switch (_selectedFilter) {
              case ItemFilter.tasks:
                return item.type == ItemType.task;
              case ItemFilter.notes:
                return item.type == ItemType.note;
              case ItemFilter.lists:
                return item.type == ItemType.list;
              case ItemFilter.all:
                return true;
            }
          }).toList();

    final hasMoreItems = items.length < filteredItems.length;
    final itemCount = hasMoreItems ? items.length + 1 : items.length;

    return ListView.builder(
      padding: const EdgeInsets.symmetric(
        horizontal: AppSpacing.sm,
        vertical: AppSpacing.xs,
      ),
      itemCount: itemCount,
      itemBuilder: (context, index) {
        // Load more button at the end
        if (hasMoreItems && index == items.length) {
          return Padding(
            padding: const EdgeInsets.symmetric(vertical: AppSpacing.md),
            child: Center(
              child: _isLoadingMore
                  ? const CircularProgressIndicator()
                  : ElevatedButton.icon(
                      onPressed: () => _loadMoreItems(filteredItems.length),
                      icon: const Icon(Icons.expand_more),
                      label: Text(
                        'Load More (${filteredItems.length - items.length} remaining)',
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

        final item = items[index];

        // Use ValueKey for efficient list updates
        return ItemCard(
          key: ValueKey<String>(item.id),
          item: item,
          onTap: () {
            Navigator.of(context).push(
              MaterialPageRoute<void>(
                builder: (context) => ItemDetailScreen(item: item),
              ),
            );
          },
          onLongPress: () {
            debugPrint('Item long-pressed: ${item.id}');
          },
          onCheckboxChanged: item.type == ItemType.task
              ? (value) {
                  context.read<ItemsProvider>().toggleCompletion(item.id);
                }
              : null,
        );
      },
    );
  }

  /// Build mobile layout
  Widget _buildMobileLayout(
    BuildContext context,
    ItemsProvider itemsProvider,
    SpacesProvider spacesProvider,
  ) {
    final filteredItems = _getFilteredItems(itemsProvider.items);
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

              // Divider
              const Divider(height: 1),

              // Item list
              Expanded(
                child: RefreshIndicator(
                  onRefresh: _handleRefresh,
                  color: isDark ? AppColors.primaryStartDark : AppColors.primaryStart,
                  backgroundColor: isDark ? AppColors.surfaceDark : AppColors.surfaceLight,
                  child: itemsProvider.isLoading
                      ? const Center(child: CircularProgressIndicator())
                      : _buildItemList(
                          context,
                          filteredItems,
                          spacesProvider.currentSpace,
                          spacesProvider,
                          itemsProvider,
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
      bottomNavigationBar: AppBottomNavigationBar(
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
    ItemsProvider itemsProvider,
    SpacesProvider spacesProvider,
  ) {
    final filteredItems = _getFilteredItems(itemsProvider.items);
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

                    // Divider
                    const Divider(height: 1),

                    // Item list
                    Expanded(
                      child: RefreshIndicator(
                        onRefresh: _handleRefresh,
                        color: isDark ? AppColors.primaryStartDark : AppColors.primaryStart,
                        backgroundColor: isDark ? AppColors.surfaceDark : AppColors.surfaceLight,
                        child: itemsProvider.isLoading
                            ? const Center(child: CircularProgressIndicator())
                            : _buildItemList(
                                context,
                                filteredItems,
                                spacesProvider.currentSpace,
                                spacesProvider,
                                itemsProvider,
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
    final itemsProvider = context.watch<ItemsProvider>();
    final spacesProvider = context.watch<SpacesProvider>();

    return Focus(
      autofocus: true,
      onKeyEvent: _handleKeyEvent,
      child: isDesktop
          ? _buildDesktopLayout(context, itemsProvider, spacesProvider)
          : _buildMobileLayout(context, itemsProvider, spacesProvider),
    );
  }
}

/// Filter chip widget with gradient active state
class _FilterChip extends StatelessWidget {
  const _FilterChip({
    required this.label,
    required this.isSelected,
    required this.onSelected,
    required this.isDark,
  });

  final String label;
  final bool isSelected;
  final VoidCallback onSelected;
  final bool isDark;

  @override
  Widget build(BuildContext context) {
    // Use gradient background when selected
    if (isSelected) {
      return Container(
        decoration: BoxDecoration(
          gradient: isDark
              ? AppColors.primaryGradientDark
              : AppColors.primaryGradient,
          borderRadius: BorderRadius.circular(AppSpacing.radiusFull),
        ),
        child: Material(
          color: Colors.transparent,
          child: InkWell(
            onTap: onSelected,
            borderRadius: BorderRadius.circular(AppSpacing.radiusFull),
            child: Padding(
              padding: const EdgeInsets.symmetric(
                horizontal: AppSpacing.md,
                vertical: AppSpacing.xs,
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Icon(
                    Icons.check,
                    size: 16,
                    color: Colors.white,
                  ),
                  const SizedBox(width: AppSpacing.xxs),
                  Text(
                    label,
                    style: AppTypography.bodyMedium.copyWith(
                      color: Colors.white,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      );
    }

    // Unselected state - flat background
    return FilterChip(
      label: Text(label),
      selected: isSelected,
      onSelected: (_) => onSelected(),
      backgroundColor: isDark
          ? AppColors.surfaceDarkVariant
          : AppColors.surfaceLightVariant,
      labelStyle: AppTypography.bodyMedium.copyWith(
        color: isDark
            ? AppColors.textSecondaryDark
            : AppColors.textSecondaryLight,
        fontWeight: FontWeight.normal,
      ),
      padding: const EdgeInsets.symmetric(
        horizontal: AppSpacing.sm,
        vertical: AppSpacing.xs,
      ),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(AppSpacing.radiusFull),
      ),
    );
  }
}

/// Item filter enum
enum ItemFilter {
  all,
  tasks,
  notes,
  lists,
}
