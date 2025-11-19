import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:later_mobile/core/enums/content_type.dart';
import 'package:later_mobile/design_system/design_system.dart';
import 'package:later_mobile/features/search/presentation/controllers/search_filters_controller.dart';
import 'package:later_mobile/l10n/app_localizations.dart';

/// Widget that displays filter chips for content type filtering.
///
/// Allows users to filter search results by:
/// - All content types (default)
/// - Notes only
/// - Tasks (TodoLists) only
/// - Lists only
/// - Todo Items only
/// - List Items only
class SearchFiltersWidget extends ConsumerWidget {
  const SearchFiltersWidget({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context)!;
    final filters = ref.watch(searchFiltersControllerProvider);

    // Determine if "All" is selected (no content type filter)
    final isAllSelected = filters.contentTypes == null ||
                          filters.contentTypes!.isEmpty;

    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      padding: const EdgeInsets.symmetric(
        horizontal: AppSpacing.md,
        vertical: AppSpacing.sm,
      ),
      child: Wrap(
        spacing: AppSpacing.sm,
        children: [
          // All filter
          TemporalFilterChip(
            label: l10n.filterAll,
            isSelected: isAllSelected,
            onSelected: () {
              ref
                  .read(searchFiltersControllerProvider.notifier)
                  .setContentTypes(null);
            },
          ),

          // Notes filter
          TemporalFilterChip(
            label: l10n.filterNotes,
            isSelected: !isAllSelected &&
                filters.contentTypes!.contains(ContentType.note),
            onSelected: () {
              _toggleContentType(ref, ContentType.note, isAllSelected ? false : !filters.contentTypes!.contains(ContentType.note));
            },
          ),

          // Tasks (TodoLists) filter
          TemporalFilterChip(
            label: l10n.filterTodoLists,
            isSelected: !isAllSelected &&
                filters.contentTypes!.contains(ContentType.todoList),
            onSelected: () {
              _toggleContentType(ref, ContentType.todoList, isAllSelected ? false : !filters.contentTypes!.contains(ContentType.todoList));
            },
          ),

          // Lists filter
          TemporalFilterChip(
            label: l10n.filterLists,
            isSelected: !isAllSelected &&
                filters.contentTypes!.contains(ContentType.list),
            onSelected: () {
              _toggleContentType(ref, ContentType.list, isAllSelected ? false : !filters.contentTypes!.contains(ContentType.list));
            },
          ),

          // Todo Items filter
          TemporalFilterChip(
            label: l10n.filterTodoItems,
            isSelected: !isAllSelected &&
                filters.contentTypes!.contains(ContentType.todoItem),
            onSelected: () {
              _toggleContentType(ref, ContentType.todoItem, isAllSelected ? false : !filters.contentTypes!.contains(ContentType.todoItem));
            },
          ),

          // List Items filter
          TemporalFilterChip(
            label: l10n.filterListItems,
            isSelected: !isAllSelected &&
                filters.contentTypes!.contains(ContentType.listItem),
            onSelected: () {
              _toggleContentType(ref, ContentType.listItem, isAllSelected ? false : !filters.contentTypes!.contains(ContentType.listItem));
            },
          ),
        ],
      ),
    );
  }

  /// Toggles a content type filter on/off
  void _toggleContentType(
    WidgetRef ref,
    ContentType type,
    bool selected,
  ) {
    final currentFilters = ref.read(searchFiltersControllerProvider);
    final currentTypes = currentFilters.contentTypes ?? [];

    List<ContentType> newTypes;
    if (selected) {
      // Add type if not already present
      newTypes = [...currentTypes, type];
    } else {
      // Remove type
      newTypes = currentTypes.where((t) => t != type).toList();
    }

    // If no types remain, set to null (show all)
    ref
        .read(searchFiltersControllerProvider.notifier)
        .setContentTypes(newTypes.isEmpty ? null : newTypes);
  }
}
