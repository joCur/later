import 'package:hive_flutter/hive_flutter.dart';
import '../models/item_model.dart';
import '../models/space_model.dart';

/// Wrapper for Hive database operations
/// Provides a clean interface for box management and initialization
class HiveDatabase {
  // Box names
  static const String itemsBoxName = 'items';
  static const String spacesBoxName = 'spaces';

  // Singleton instance
  static final HiveDatabase _instance = HiveDatabase._internal();
  factory HiveDatabase() => _instance;
  HiveDatabase._internal();

  /// Initialize Hive and register adapters
  /// Must be called before using any Hive operations
  static Future<void> initialize() async {
    // Initialize Hive with Flutter support
    await Hive.initFlutter();

    // Register type adapters
    if (!Hive.isAdapterRegistered(0)) {
      Hive.registerAdapter(ItemTypeAdapter());
    }
    if (!Hive.isAdapterRegistered(1)) {
      Hive.registerAdapter(ItemAdapter());
    }
    if (!Hive.isAdapterRegistered(2)) {
      Hive.registerAdapter(SpaceAdapter());
    }

    // Open boxes
    await Hive.openBox<Item>(itemsBoxName);
    await Hive.openBox<Space>(spacesBoxName);
  }

  /// Get the items box
  Box<Item> get itemsBox => Hive.box<Item>(itemsBoxName);

  /// Get the spaces box
  Box<Space> get spacesBox => Hive.box<Space>(spacesBoxName);

  /// Check if the database has been initialized (for first run detection)
  bool get isInitialized {
    return spacesBox.isNotEmpty;
  }

  /// Clear all data (useful for testing or reset)
  Future<void> clearAll() async {
    await itemsBox.clear();
    await spacesBox.clear();
  }

  /// Close all boxes
  Future<void> close() async {
    await itemsBox.close();
    await spacesBox.close();
  }

  /// Delete all Hive data (including boxes)
  Future<void> deleteAll() async {
    await Hive.deleteBoxFromDisk(itemsBoxName);
    await Hive.deleteBoxFromDisk(spacesBoxName);
  }

  /// Get database statistics
  Map<String, dynamic> getStats() {
    return {
      'itemCount': itemsBox.length,
      'spaceCount': spacesBox.length,
      'isInitialized': isInitialized,
    };
  }
}
