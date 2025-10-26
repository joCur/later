import 'package:hive_flutter/hive_flutter.dart';
import '../models/item_model.dart';
import '../models/space_model.dart';
import '../models/todo_list_model.dart';
import '../models/list_model.dart';

/// Wrapper for Hive database operations
/// Provides a clean interface for box management and initialization
class HiveDatabase {
  // Singleton instance
  factory HiveDatabase() => _instance;
  HiveDatabase._internal();

  static final HiveDatabase _instance = HiveDatabase._internal();

  // Box names
  static const String notesBoxName = 'notes';
  static const String todoListsBoxName = 'todo_lists';
  static const String listsBoxName = 'lists';
  static const String spacesBoxName = 'spaces';

  /// Initialize Hive and register adapters
  /// Must be called before using any Hive operations
  static Future<void> initialize() async {
    try {
      // Initialize Hive with Flutter support
      await Hive.initFlutter();

      // Register type adapters for Item (Note) model
      if (!Hive.isAdapterRegistered(1)) {
        Hive.registerAdapter(ItemAdapter());
      }

      // Register type adapters for Space model
      if (!Hive.isAdapterRegistered(2)) {
        Hive.registerAdapter(SpaceAdapter());
      }

      // Register type adapters for TodoList model
      if (!Hive.isAdapterRegistered(20)) {
        Hive.registerAdapter(TodoListAdapter());
      }
      if (!Hive.isAdapterRegistered(21)) {
        Hive.registerAdapter(TodoItemAdapter());
      }
      if (!Hive.isAdapterRegistered(25)) {
        Hive.registerAdapter(TodoPriorityAdapter());
      }

      // Register type adapters for ListModel
      if (!Hive.isAdapterRegistered(22)) {
        Hive.registerAdapter(ListModelAdapter());
      }
      if (!Hive.isAdapterRegistered(23)) {
        Hive.registerAdapter(ListItemAdapter());
      }
      if (!Hive.isAdapterRegistered(24)) {
        Hive.registerAdapter(ListStyleAdapter());
      }

      // Open boxes
      await Hive.openBox<Item>(notesBoxName);
      await Hive.openBox<TodoList>(todoListsBoxName);
      await Hive.openBox<ListModel>(listsBoxName);
      await Hive.openBox<Space>(spacesBoxName);
    } catch (e) {
      // Log error and rethrow for caller to handle
      // ignore: avoid_print
      print('Error initializing Hive database: $e');
      rethrow;
    }
  }

  /// Get the notes box (formerly items box)
  Box<Item> get notesBox => Hive.box<Item>(notesBoxName);

  /// Get the todo lists box
  Box<TodoList> get todoListsBox => Hive.box<TodoList>(todoListsBoxName);

  /// Get the lists box
  Box<ListModel> get listsBox => Hive.box<ListModel>(listsBoxName);

  /// Get the spaces box
  Box<Space> get spacesBox => Hive.box<Space>(spacesBoxName);

  /// Check if the database has been initialized (for first run detection)
  bool get isInitialized {
    return spacesBox.isNotEmpty;
  }

  /// Clear all data (useful for testing or reset)
  Future<void> clearAll() async {
    await notesBox.clear();
    await todoListsBox.clear();
    await listsBox.clear();
    await spacesBox.clear();
  }

  /// Close all boxes
  Future<void> close() async {
    await notesBox.close();
    await todoListsBox.close();
    await listsBox.close();
    await spacesBox.close();
  }

  /// Delete all Hive data (including boxes)
  Future<void> deleteAll() async {
    await Hive.deleteBoxFromDisk(notesBoxName);
    await Hive.deleteBoxFromDisk(todoListsBoxName);
    await Hive.deleteBoxFromDisk(listsBoxName);
    await Hive.deleteBoxFromDisk(spacesBoxName);
  }

  /// Get database statistics
  Map<String, dynamic> getStats() {
    return {
      'noteCount': notesBox.length,
      'todoListCount': todoListsBox.length,
      'listCount': listsBox.length,
      'spaceCount': spacesBox.length,
      'isInitialized': isInitialized,
    };
  }
}
