import 'package:uuid/uuid.dart';
import '../models/item_model.dart';
import '../models/space_model.dart';
import '../repositories/item_repository.dart';
import '../repositories/space_repository.dart';

/// Utility class for seeding the database with initial data on first run.
///
/// This class provides methods to detect first run and initialize the app
/// with a default "Personal" space and sample items to help users get started.
///
/// The seed data includes:
/// - 1 default "Personal" space
/// - 2 tasks (one completed, one with due date)
/// - 1 note with getting started information
/// - 1 list with feature ideas
///
/// Example usage:
/// ```dart
/// // In main.dart after Hive initialization
/// await HiveDatabase.initialize();
/// await SeedData.initialize();
/// ```
class SeedData {
  static const Uuid _uuid = Uuid();
  static final SpaceRepository _spaceRepository = SpaceRepository();
  static final ItemRepository _itemRepository = ItemRepository();

  /// Check if this is the first run by checking if any spaces exist.
  ///
  /// Returns true if no spaces exist in the database, indicating this is
  /// the first time the app is being run and seed data should be created.
  ///
  /// Example:
  /// ```dart
  /// final isFirstRun = await SeedData.isFirstRun();
  /// if (isFirstRun) {
  ///   print('Welcome! Setting up your workspace...');
  /// }
  /// ```
  static Future<bool> isFirstRun() async {
    final spaces = await _spaceRepository.getSpaces();
    return spaces.isEmpty;
  }

  /// Initialize the app with default space and sample items.
  ///
  /// This method should be called during app startup, after Hive has been
  /// initialized but before the UI is loaded. It checks if this is the first
  /// run and creates seed data if needed.
  ///
  /// The method is idempotent - it can be safely called multiple times and
  /// will only create seed data on the first run (when no spaces exist).
  ///
  /// Example:
  /// ```dart
  /// await HiveDatabase.initialize();
  /// await SeedData.initialize();
  /// // Now providers can be initialized with seed data present
  /// ```
  static Future<void> initialize() async {
    // Only initialize if this is the first run
    final firstRun = await isFirstRun();
    if (!firstRun) {
      return;
    }

    // Create the default space
    final space = await _createDefaultSpace();

    // Create sample items
    await _createSampleItems(space.id);

    // Update the space's item count
    await _spaceRepository.updateSpace(
      space.copyWith(itemCount: 4),
    );
  }

  /// Create the default "Personal" space.
  ///
  /// Creates a space with the following properties:
  /// - Name: "Personal"
  /// - Icon: "🏠" (home emoji)
  /// - Color: "#6366F1" (indigo - app's primary color)
  /// - itemCount: 0 (will be updated after items are created)
  ///
  /// Returns the created Space object.
  static Future<Space> _createDefaultSpace() async {
    final space = Space(
      id: _uuid.v4(),
      name: 'Personal',
      icon: '🏠',
      color: '#6366F1',
    );

    return await _spaceRepository.createSpace(space);
  }

  /// Create sample items for user onboarding.
  ///
  /// Creates 4 sample items to help users understand the app:
  /// 1. A completed task demonstrating task completion
  /// 2. An active task with a due date demonstrating task management
  /// 3. A note with getting started information
  /// 4. A list with feature ideas
  ///
  /// All items are created in the specified space and tagged appropriately
  /// to help users learn about the app's features.
  ///
  /// Parameters:
  ///   - [spaceId]: The ID of the space to create items in
  static Future<void> _createSampleItems(String spaceId) async {
    final now = DateTime.now();
    final tomorrow = now.add(const Duration(days: 1));

    // Sample Item 1: Completed Task
    final completedTask = Item(
      id: _uuid.v4(),
      type: ItemType.task,
      title: 'Welcome to Later!',
      content: 'Check off this task to see how completion works',
      spaceId: spaceId,
      isCompleted: true,
      tags: ['onboarding'],
    );

    // Sample Item 2: Active Task with Due Date
    final activeTask = Item(
      id: _uuid.v4(),
      type: ItemType.task,
      title: 'Try creating your first item',
      content: 'Tap the + button to create a new task, note, or list',
      spaceId: spaceId,
      dueDate: tomorrow,
      tags: ['onboarding', 'tutorial'],
    );

    // Sample Item 3: Getting Started Note
    final note = Item(
      id: _uuid.v4(),
      type: ItemType.note,
      title: 'Getting Started with Later',
      content: 'Later helps you capture and organize your thoughts, tasks, '
          'and lists in one place. Use spaces to organize different areas of '
          'your life. \n\nTip: You can switch spaces by tapping the space name '
          'at the top.',
      spaceId: spaceId,
      tags: ['onboarding', 'help'],
    );

    // Sample Item 4: Feature Ideas List
    final list = Item(
      id: _uuid.v4(),
      type: ItemType.list,
      title: 'Feature Ideas',
      content: '• Add tags to items\n'
          '• Set due dates\n'
          '• Create more spaces\n'
          '• Archive completed tasks',
      spaceId: spaceId,
      tags: ['ideas'],
    );

    // Create all items in the repository
    await _itemRepository.createItem(completedTask);
    await _itemRepository.createItem(activeTask);
    await _itemRepository.createItem(note);
    await _itemRepository.createItem(list);
  }
}
