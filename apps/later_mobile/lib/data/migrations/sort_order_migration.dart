import 'package:hive_flutter/hive_flutter.dart';
import '../local/preferences_service.dart';
import '../models/note_model.dart';
import '../models/list_model.dart';
import '../models/space_model.dart';
import '../models/todo_list_model.dart';

/// Migration utility for assigning sortOrder to existing content items
///
/// This migration runs once on first app launch after upgrading to a version
/// that includes the sortOrder field. It:
/// 1. Checks if migration has already been completed (idempotent)
/// 2. Groups all content items by space
/// 3. Sorts items by createdAt timestamp (preserves existing order)
/// 4. Assigns sequential sortOrder values (0, 1, 2, ...) per space
/// 5. Updates all items in their respective Hive boxes
/// 6. Marks migration as complete in SharedPreferences
///
/// The migration is safe to run multiple times and handles errors gracefully.
class SortOrderMigration {
  /// Run the sortOrder migration
  ///
  /// This method is idempotent - it checks if migration has already been
  /// completed and returns early if so. Errors are caught and logged but
  /// don't throw to prevent blocking app startup.
  static Future<void> run() async {
    try {
      final prefs = PreferencesService();

      // Check if migration already ran
      if (prefs.hasMigratedSortOrder()) {
        // ignore: avoid_print
        print('SortOrder migration already completed, skipping');
        return;
      }

      // ignore: avoid_print
      print('Running sortOrder migration...');

      // Get all Hive boxes
      final notesBox = Hive.box<Item>('notes');
      final todoListsBox = Hive.box<TodoList>('todo_lists');
      final listsBox = Hive.box<ListModel>('lists');
      final spacesBox = Hive.box<Space>('spaces');

      // Process each space independently
      for (final spaceKey in spacesBox.keys) {
        final space = spacesBox.get(spaceKey);
        if (space == null) continue;

        await _migrateSpace(space.id, notesBox, todoListsBox, listsBox);
      }

      // Mark migration as complete
      await prefs.setMigratedSortOrder();

      // ignore: avoid_print
      print('SortOrder migration completed successfully');
    } catch (e) {
      // Log error but don't fail - migration errors are non-critical
      // The app can still function with default sortOrder values (0)
      // ignore: avoid_print
      print('Warning: SortOrder migration error (non-critical): $e');
    }
  }

  /// Migrate content in a single space
  ///
  /// Groups all content items in the space, sorts by createdAt, and assigns
  /// sequential sortOrder values starting from 0.
  static Future<void> _migrateSpace(
    String spaceId,
    Box<Item> notesBox,
    Box<TodoList> todoListsBox,
    Box<ListModel> listsBox,
  ) async {
    // Collect all content items for this space
    final List<_ContentItem> allContent = [];

    // Gather notes
    for (final key in notesBox.keys) {
      final item = notesBox.get(key);
      if (item != null && item.spaceId == spaceId) {
        allContent.add(_ContentItem(
          type: _ContentType.note,
          id: item.id,
          createdAt: item.createdAt,
          data: item,
        ));
      }
    }

    // Gather todo lists
    for (final key in todoListsBox.keys) {
      final item = todoListsBox.get(key);
      if (item != null && item.spaceId == spaceId) {
        allContent.add(_ContentItem(
          type: _ContentType.todoList,
          id: item.id,
          createdAt: item.createdAt,
          data: item,
        ));
      }
    }

    // Gather lists
    for (final key in listsBox.keys) {
      final item = listsBox.get(key);
      if (item != null && item.spaceId == spaceId) {
        allContent.add(_ContentItem(
          type: _ContentType.list,
          id: item.id,
          createdAt: item.createdAt,
          data: item,
        ));
      }
    }

    // Sort by createdAt (ascending - oldest first)
    // This preserves the existing chronological order
    allContent.sort((a, b) => a.createdAt.compareTo(b.createdAt));

    // Assign sequential sortOrder values and update items
    for (int i = 0; i < allContent.length; i++) {
      final contentItem = allContent[i];
      final newSortOrder = i;

      switch (contentItem.type) {
        case _ContentType.note:
          final note = contentItem.data as Item;
          await notesBox.put(
            note.id,
            note.copyWith(sortOrder: newSortOrder),
          );
        case _ContentType.todoList:
          final todoList = contentItem.data as TodoList;
          await todoListsBox.put(
            todoList.id,
            todoList.copyWith(sortOrder: newSortOrder),
          );
        case _ContentType.list:
          final list = contentItem.data as ListModel;
          await listsBox.put(
            list.id,
            list.copyWith(sortOrder: newSortOrder),
          );
      }
    }
  }
}

/// Enum for content types
enum _ContentType {
  note,
  todoList,
  list,
}

/// Helper class for grouping content items during migration
class _ContentItem {
  _ContentItem({
    required this.type,
    required this.id,
    required this.createdAt,
    required this.data,
  });

  final _ContentType type;
  final String id;
  final DateTime createdAt;
  final dynamic data; // Item, TodoList, or ListModel
}
