import 'package:hive/hive.dart';
import 'package:later_mobile/data/models/note_model.dart';
import 'package:later_mobile/data/models/list_model.dart';
import 'package:later_mobile/data/models/todo_list_model.dart';

/// Service for calculating item counts for spaces from Hive database.
///
/// This is the single source of truth for space item counts.
/// It calculates counts directly from the actual items stored in Hive boxes,
/// eliminating the need for stored counter values and preventing
/// desynchronization bugs.
///
/// The service counts items across three Hive boxes:
/// - notes (Item/Note objects)
/// - todo_lists (TodoList objects)
/// - lists (ListModel objects)
class SpaceItemCountService {
  /// Calculates the total number of items for a given space.
  ///
  /// This method queries all three content boxes (notes, todo_lists, lists)
  /// and sums the count of items belonging to the specified [spaceId].
  ///
  /// Returns 0 if:
  /// - The space has no items
  /// - Any of the Hive boxes are not open
  /// - The spaceId doesn't exist
  ///
  /// Example:
  /// ```dart
  /// final count = await SpaceItemCountService.calculateItemCount('space-123');
  /// print('Space has $count items');
  /// ```
  static Future<int> calculateItemCount(String spaceId) async {
    try {
      int totalCount = 0;

      // Count notes
      if (Hive.isBoxOpen('notes')) {
        final notesBox = Hive.box<Note>('notes');
        final notesCount =
            notesBox.values.where((item) => item.spaceId == spaceId).length;
        totalCount += notesCount;
      }

      // Count todo lists
      if (Hive.isBoxOpen('todo_lists')) {
        final todoListsBox = Hive.box<TodoList>('todo_lists');
        final todoListsCount = todoListsBox.values
            .where((todoList) => todoList.spaceId == spaceId)
            .length;
        totalCount += todoListsCount;
      }

      // Count regular lists
      if (Hive.isBoxOpen('lists')) {
        final listsBox = Hive.box<ListModel>('lists');
        final listsCount =
            listsBox.values.where((list) => list.spaceId == spaceId).length;
        totalCount += listsCount;
      }

      return totalCount;
    } catch (e) {
      // If any error occurs (box not found, etc.), return 0 as fallback
      return 0;
    }
  }
}
