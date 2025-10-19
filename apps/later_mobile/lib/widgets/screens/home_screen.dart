import 'package:flutter/material.dart';
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
import '../components/empty_state.dart';
import '../navigation/bottom_navigation_bar.dart';
import '../navigation/app_sidebar.dart';
import '../modals/space_switcher_modal.dart';
import 'item_detail_screen.dart';

/// Main home screen for the Later app
///
/// Serves as the primary entry point showing all items in the current space.
/// Features:
/// - App bar with space switcher, search, and menu
/// - Filter chips (All, Tasks, Notes, Lists)
/// - Item list with pull-to-refresh
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
    switch (_selectedFilter) {
      case ItemFilter.all:
        return items;
      case ItemFilter.tasks:
        return items.where((item) => item.type == ItemType.task).toList();
      case ItemFilter.notes:
        return items.where((item) => item.type == ItemType.note).toList();
      case ItemFilter.lists:
        return items.where((item) => item.type == ItemType.list).toList();
    }
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
                  // Space was switched, reload items
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
                    // Space icon
                    if (currentSpace?.icon != null)
                      Text(
                        currentSpace!.icon!,
                        style: const TextStyle(fontSize: 24),
                      )
                    else
                      Icon(
                        Icons.folder_outlined,
                        size: 24,
                        color: isDark
                            ? AppColors.textPrimaryDark
                            : AppColors.textPrimaryLight,
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
        horizontal: AppSpacing.paddingSM,
        vertical: AppSpacing.paddingXS,
      ),
      child: Wrap(
        spacing: AppSpacing.xs,
        children: [
          _FilterChip(
            label: 'All',
            isSelected: _selectedFilter == ItemFilter.all,
            onSelected: () {
              setState(() => _selectedFilter = ItemFilter.all);
            },
            isDark: isDark,
          ),
          _FilterChip(
            label: 'Tasks',
            isSelected: _selectedFilter == ItemFilter.tasks,
            onSelected: () {
              setState(() => _selectedFilter = ItemFilter.tasks);
            },
            isDark: isDark,
          ),
          _FilterChip(
            label: 'Notes',
            isSelected: _selectedFilter == ItemFilter.notes,
            onSelected: () {
              setState(() => _selectedFilter = ItemFilter.notes);
            },
            isDark: isDark,
          ),
          _FilterChip(
            label: 'Lists',
            isSelected: _selectedFilter == ItemFilter.lists,
            onSelected: () {
              setState(() => _selectedFilter = ItemFilter.lists);
            },
            isDark: isDark,
          ),
        ],
      ),
    );
  }

  /// Build item list
  Widget _buildItemList(BuildContext context, List<Item> items) {
    if (items.isEmpty) {
      return EmptyState(
        icon: Icons.inbox_outlined,
        title: 'No items yet',
        message: _getEmptyMessage(),
        actionLabel: 'Create Item',
        onActionPressed: () {
          debugPrint('Create item from empty state');
        },
      );
    }

    return ListView.builder(
      padding: const EdgeInsets.symmetric(
        horizontal: AppSpacing.paddingSM,
        vertical: AppSpacing.paddingXS,
      ),
      itemCount: items.length,
      itemBuilder: (context, index) {
        final item = items[index];
        return ItemCard(
          item: item,
          onTap: () {
            Navigator.of(context).push(
              MaterialPageRoute(
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

  /// Get appropriate empty message based on filter
  String _getEmptyMessage() {
    switch (_selectedFilter) {
      case ItemFilter.all:
        return 'Create your first item to get started. Tap the + button below.';
      case ItemFilter.tasks:
        return 'No tasks yet. Create a task to track your to-dos.';
      case ItemFilter.notes:
        return 'No notes yet. Create a note to capture your thoughts.';
      case ItemFilter.lists:
        return 'No lists yet. Create a list to organize related items.';
    }
  }

  /// Build mobile layout
  Widget _buildMobileLayout(
    BuildContext context,
    ItemsProvider itemsProvider,
    SpacesProvider spacesProvider,
  ) {
    final filteredItems = _getFilteredItems(itemsProvider.items);

    return Scaffold(
      appBar: _buildAppBar(context, spacesProvider.currentSpace),
      body: Column(
        children: [
          // Filter chips
          _buildFilterChips(context),

          // Divider
          const Divider(height: 1),

          // Item list
          Expanded(
            child: RefreshIndicator(
              onRefresh: _handleRefresh,
              child: itemsProvider.isLoading
                  ? const Center(child: CircularProgressIndicator())
                  : _buildItemList(context, filteredItems),
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
        onPressed: () {
          debugPrint('Quick capture tapped');
        },
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
            child: Column(
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
                    child: itemsProvider.isLoading
                        ? const Center(child: CircularProgressIndicator())
                        : _buildItemList(context, filteredItems),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
      floatingActionButton: QuickCaptureFab(
        onPressed: () {
          debugPrint('Quick capture tapped');
        },
        tooltip: 'Quick capture',
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final isDesktop = context.isDesktopOrLarger;
    final itemsProvider = context.watch<ItemsProvider>();
    final spacesProvider = context.watch<SpacesProvider>();

    return isDesktop
        ? _buildDesktopLayout(context, itemsProvider, spacesProvider)
        : _buildMobileLayout(context, itemsProvider, spacesProvider);
  }
}

/// Filter chip widget
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
    return FilterChip(
      label: Text(label),
      selected: isSelected,
      onSelected: (_) => onSelected(),
      selectedColor: isDark
          ? AppColors.primaryAmber.withValues(alpha: 0.2)
          : AppColors.primaryAmber.withValues(alpha: 0.15),
      backgroundColor: isDark
          ? AppColors.surfaceDarkVariant
          : AppColors.surfaceLightVariant,
      checkmarkColor: isDark
          ? AppColors.textPrimaryDark
          : AppColors.textPrimaryLight,
      labelStyle: AppTypography.bodyMedium.copyWith(
        color: isSelected
            ? (isDark ? AppColors.textPrimaryDark : AppColors.textPrimaryLight)
            : (isDark
                ? AppColors.textSecondaryDark
                : AppColors.textSecondaryLight),
        fontWeight: isSelected ? FontWeight.w600 : FontWeight.normal,
      ),
      padding: const EdgeInsets.symmetric(
        horizontal: AppSpacing.paddingSM,
        vertical: AppSpacing.paddingXS,
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
