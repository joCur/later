import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:later_mobile/design_system/design_system.dart';
import 'package:later_mobile/features/search/domain/models/models.dart';
import 'package:later_mobile/features/search/presentation/controllers/search_controller.dart';
import 'package:later_mobile/features/search/presentation/controllers/search_filters_controller.dart';
import 'package:later_mobile/features/search/presentation/widgets/search_filters_widget.dart';
import 'package:later_mobile/features/search/presentation/widgets/search_result_card.dart';
import 'package:later_mobile/features/spaces/presentation/controllers/current_space_controller.dart';
import 'package:later_mobile/l10n/app_localizations.dart';

/// Screen for searching across all content types within the current space.
///
/// Provides a unified search interface with:
/// - Text input with debouncing (300ms)
/// - Content type filtering (notes, tasks, lists, child items)
/// - Real-time search results
/// - Empty state handling
/// - Error state handling
/// - Keyboard shortcuts: Escape to clear search
class SearchScreen extends ConsumerStatefulWidget {
  const SearchScreen({
    super.key,
    this.initialQuery,
  });

  /// Optional initial search query to execute on screen load
  final String? initialQuery;

  @override
  ConsumerState<SearchScreen> createState() => _SearchScreenState();
}

class _SearchScreenState extends ConsumerState<SearchScreen> {
  late final TextEditingController _searchController;

  @override
  void initState() {
    super.initState();
    _searchController = TextEditingController(text: widget.initialQuery);

    // Trigger search if initial query provided
    if (widget.initialQuery != null && widget.initialQuery!.isNotEmpty) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        _performSearch(_searchController.text);
      });
    }

    // Listen to filter changes and re-run search
    // This allows filters to work by triggering a new search when changed
    ref.listenManual(searchFiltersControllerProvider, (previous, next) {
      // Only trigger search if we have a non-empty query
      if (_searchController.text.isNotEmpty) {
        _performSearch(_searchController.text);
      }
    });
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  /// Performs search with current query and filters
  void _performSearch(String query) {
    ref.read(currentSpaceControllerProvider).when(
      data: (currentSpace) {
        if (currentSpace == null) {
          // No space selected, cannot search
          return;
        }

        final filters = ref.read(searchFiltersControllerProvider);

        final searchQuery = SearchQuery(
          query: query,
          spaceId: currentSpace.id,
          contentTypes: filters.contentTypes,
          tags: filters.tags,
        );

        ref.read(searchControllerProvider.notifier).search(searchQuery);
      },
      loading: () {
        // Space not loaded yet, cannot search
      },
      error: (_, _) {
        // Error loading space, cannot search
      },
    );
  }

  /// Clears the search input and results
  void _clearSearch() {
    _searchController.clear();
    ref.read(searchControllerProvider.notifier).clear();
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final searchState = ref.watch(searchControllerProvider);

    return Focus(
      onKeyEvent: (node, event) {
        // Handle Escape key to clear search
        if (event is KeyDownEvent &&
            event.logicalKey == LogicalKeyboardKey.escape) {
          _clearSearch();
          return KeyEventResult.handled;
        }
        return KeyEventResult.ignored;
      },
      child: Scaffold(
      appBar: AppBar(
        title: TextField(
          controller: _searchController,
          autofocus: true,
          decoration: InputDecoration(
            hintText: l10n.searchBarHint,
            border: InputBorder.none,
            suffixIcon: _searchController.text.isNotEmpty
                ? IconButton(
                    icon: const Icon(Icons.clear),
                    onPressed: _clearSearch,
                    tooltip: l10n.searchClearButton,
                  )
                : null,
          ),
          onChanged: _performSearch,
        ),
      ),
      body: Column(
        children: [
          // Filter chips
          const SearchFiltersWidget(),
          const SizedBox(height: AppSpacing.sm),

          // Search results
          Expanded(
            child: searchState.when(
              data: (results) {
                if (results.isEmpty) {
                  return Center(
                    child: EmptyState(
                      title: l10n.searchEmptyTitle,
                      message: l10n.searchEmptyMessage,
                      icon: Icons.search_off,
                    ),
                  );
                }

                return ListView.builder(
                  padding: const EdgeInsets.all(AppSpacing.md),
                  itemCount: results.length,
                  itemBuilder: (context, index) {
                    return SearchResultCard(
                      result: results[index],
                    );
                  },
                );
              },
              loading: () => const Center(
                child: CircularProgressIndicator(),
              ),
              error: (error, stackTrace) {
                return Center(
                  child: EmptyState(
                    title: 'Search Error',
                    message: error.toString(),
                    icon: Icons.error_outline,
                    actionLabel: 'Retry',
                    onActionPressed: () {
                      if (_searchController.text.isNotEmpty) {
                        _performSearch(_searchController.text);
                      }
                    },
                  ),
                );
              },
            ),
          ),
        ],
      ),
      ),
    );
  }
}
