import 'package:uuid/uuid.dart';
import '../models/item_model.dart';
import '../models/space_model.dart';
import '../repositories/note_repository.dart';
import '../repositories/space_repository.dart';

/// Utility class for seeding the database with initial data on first run.
///
/// This class provides methods to detect first run and initialize the app
/// with a default "Personal" space and sample notes to help users get started.
///
/// The seed data includes:
/// - 1 default "Personal" space
/// - 1 welcome note with getting started information
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
  static final NoteRepository _noteRepository = NoteRepository();

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

    // Update the space's item count (3 notes in dual-model architecture)
    await _spaceRepository.updateSpace(space.copyWith(itemCount: 3));
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
  /// UPDATED for dual-model architecture: Creates Notes (Item model) only
  /// TodoList and ListModel creation will be added in future phases
  ///
  /// Creates 3 sample notes to help users understand the app:
  /// 1. A welcome note
  /// 2. A getting started guide note
  /// 3. A feature ideas note
  ///
  /// All items are created in the specified space and tagged appropriately
  /// to help users learn about the app's features.
  ///
  /// Parameters:
  ///   - [spaceId]: The ID of the space to create items in
  static Future<void> _createSampleItems(String spaceId) async {
    // Sample Item 1: Welcome Note
    final welcomeNote = Item(
      id: _uuid.v4(),
      title: 'Welcome to Later!',
      content:
          'This is your personal space for capturing thoughts, ideas, and notes. '
          'Get started by creating your first note using the + button below.',
      spaceId: spaceId,
      tags: ['onboarding'],
    );

    // Sample Item 2: Getting Started Note
    final gettingStartedNote = Item(
      id: _uuid.v4(),
      title: 'Getting Started with Later',
      content:
          'Later helps you capture and organize your thoughts in one place. '
          'Use spaces to organize different areas of your life. '
          '\n\nTip: You can switch spaces by tapping the space name at the top. '
          '\n\nTip: Long-press on a note to select multiple notes for batch operations.',
      spaceId: spaceId,
      tags: ['onboarding', 'help'],
    );

    // Sample Item 3: Feature Ideas Note
    final featureIdeasNote = Item(
      id: _uuid.v4(),
      title: 'Feature Ideas',
      content:
          '• Add tags to organize notes\n'
          '• Create more spaces for different projects\n'
          '• Use rich text formatting\n'
          '• Add images and attachments\n'
          '• Share notes with others',
      spaceId: spaceId,
      tags: ['ideas'],
    );

    // Create all notes in the repository
    // Note: Item count is 3 (updated from 4)
    await _noteRepository.create(welcomeNote);
    await _noteRepository.create(gettingStartedNote);
    await _noteRepository.create(featureIdeasNote);
  }
}
