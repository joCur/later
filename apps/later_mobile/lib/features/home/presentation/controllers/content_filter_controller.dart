import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:later_mobile/features/notes/domain/models/note.dart';
import 'package:later_mobile/features/todo_lists/domain/models/todo_list.dart';
import 'package:later_mobile/features/lists/domain/models/list_model.dart';
import 'package:later_mobile/features/notes/presentation/controllers/notes_controller.dart';
import 'package:later_mobile/features/todo_lists/presentation/controllers/todo_lists_controller.dart';
import 'package:later_mobile/features/lists/presentation/controllers/lists_controller.dart';

part 'content_filter_controller.g.dart';

/// Content filter types for home screen
enum ContentFilter {
  all,
  todoLists,
  lists,
  notes,
}

/// Controller for managing content filtering and search on the home screen
@riverpod
class ContentFilterController extends _$ContentFilterController {
  @override
  ContentFilter build() {
    // Default filter is "all"
    return ContentFilter.all;
  }

  /// Set the active filter
  void setFilter(ContentFilter filter) {
    state = filter;
  }

  /// Get filtered content for a specific space
  /// Returns a list of mixed content (Note, TodoList, ListModel) based on current filter
  List<dynamic> getFilteredContent(String spaceId) {
    // Watch all content controllers for the space
    final notesAsync = ref.watch(notesControllerProvider(spaceId));
    final todoListsAsync = ref.watch(todoListsControllerProvider(spaceId));
    final listsAsync = ref.watch(listsControllerProvider(spaceId));

    // Extract data from AsyncValue, default to empty list on loading/error
    final notes = notesAsync.when(
      data: (data) => data,
      loading: () => <Note>[],
      error: (error, stack) => <Note>[],
    );

    final todoLists = todoListsAsync.when(
      data: (data) => data,
      loading: () => <TodoList>[],
      error: (error, stack) => <TodoList>[],
    );

    final lists = listsAsync.when(
      data: (data) => data,
      loading: () => <ListModel>[],
      error: (error, stack) => <ListModel>[],
    );

    // Filter based on current filter state
    List<dynamic> filteredContent;

    switch (state) {
      case ContentFilter.notes:
        filteredContent = notes;
      case ContentFilter.todoLists:
        filteredContent = todoLists;
      case ContentFilter.lists:
        filteredContent = lists;
      case ContentFilter.all:
        // Combine all content types and sort by updatedAt
        filteredContent = [...todoLists, ...lists, ...notes];
        filteredContent.sort((a, b) {
          final aUpdated = a is Note
              ? a.updatedAt
              : a is TodoList
                  ? a.updatedAt
                  : a is ListModel
                      ? a.updatedAt
                      : DateTime.now();
          final bUpdated = b is Note
              ? b.updatedAt
              : b is TodoList
                  ? b.updatedAt
                  : b is ListModel
                      ? b.updatedAt
                      : DateTime.now();
          return bUpdated.compareTo(aUpdated); // Most recent first
        });
    }

    return filteredContent;
  }

  /// Check if any content is loading
  /// Only returns true for initial loading state (not reloading with data)
  bool isLoading(String spaceId) {
    final notesAsync = ref.watch(notesControllerProvider(spaceId));
    final todoListsAsync = ref.watch(todoListsControllerProvider(spaceId));
    final listsAsync = ref.watch(listsControllerProvider(spaceId));

    // Only show loading spinner if ALL controllers are in loading state
    // AND none have data yet (initial load)
    final notesLoading = notesAsync.isLoading && !notesAsync.hasValue;
    final todoListsLoading = todoListsAsync.isLoading && !todoListsAsync.hasValue;
    final listsLoading = listsAsync.isLoading && !listsAsync.hasValue;

    return notesLoading || todoListsLoading || listsLoading;
  }

  /// Get total count of all content (for pagination purposes)
  int getTotalCount(String spaceId) {
    final notesAsync = ref.watch(notesControllerProvider(spaceId));
    final todoListsAsync = ref.watch(todoListsControllerProvider(spaceId));
    final listsAsync = ref.watch(listsControllerProvider(spaceId));

    final notesCount = notesAsync.when(
      data: (data) => data.length,
      loading: () => 0,
      error: (error, stack) => 0,
    );

    final todoListsCount = todoListsAsync.when(
      data: (data) => data.length,
      loading: () => 0,
      error: (error, stack) => 0,
    );

    final listsCount = listsAsync.when(
      data: (data) => data.length,
      loading: () => 0,
      error: (error, stack) => 0,
    );

    switch (state) {
      case ContentFilter.notes:
        return notesCount;
      case ContentFilter.todoLists:
        return todoListsCount;
      case ContentFilter.lists:
        return listsCount;
      case ContentFilter.all:
        return notesCount + todoListsCount + listsCount;
    }
  }
}

/// Provider for checking if content is loading for a specific space
/// This is a separate provider so it can be watched and trigger rebuilds
@riverpod
bool contentIsLoading(Ref ref, String spaceId) {
  final notesAsync = ref.watch(notesControllerProvider(spaceId));
  final todoListsAsync = ref.watch(todoListsControllerProvider(spaceId));
  final listsAsync = ref.watch(listsControllerProvider(spaceId));

  // Only show loading spinner if controllers are in loading state
  // AND none have data yet (initial load)
  final notesLoading = notesAsync.isLoading && !notesAsync.hasValue;
  final todoListsLoading = todoListsAsync.isLoading && !todoListsAsync.hasValue;
  final listsLoading = listsAsync.isLoading && !listsAsync.hasValue;

  return notesLoading || todoListsLoading || listsLoading;
}
