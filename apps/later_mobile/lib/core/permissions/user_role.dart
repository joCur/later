/// Represents the role of a user in the application.
///
/// This enum is used to determine feature access and permission levels
/// for different types of users.
enum UserRole {
  /// Anonymous (temporary) user with limited feature access
  anonymous,

  /// Authenticated (permanent) user with full feature access
  authenticated,
}

/// Extension providing permission checks and limits for each user role.
extension UserRolePermissions on UserRole {
  // Permission getters for unlimited access

  /// Whether the user can create unlimited spaces.
  ///
  /// Returns `true` for authenticated users, `false` for anonymous users.
  bool get canCreateUnlimitedSpaces => this == UserRole.authenticated;

  /// Whether the user can create unlimited notes.
  ///
  /// Returns `true` for authenticated users, `false` for anonymous users.
  bool get canCreateUnlimitedNotes => this == UserRole.authenticated;

  /// Whether the user can create unlimited todo lists.
  ///
  /// Returns `true` for authenticated users, `false` for anonymous users.
  bool get canCreateUnlimitedTodoLists => this == UserRole.authenticated;

  /// Whether the user can create unlimited custom lists.
  ///
  /// Returns `true` for authenticated users, `false` for anonymous users.
  bool get canCreateUnlimitedLists => this == UserRole.authenticated;

  // Numeric limit getters for anonymous users

  /// Maximum number of spaces an anonymous user can create.
  int get maxSpacesForAnonymous => 1;

  /// Maximum number of notes per space an anonymous user can create.
  int get maxNotesPerSpaceForAnonymous => 20;

  /// Maximum number of todo lists per space an anonymous user can create.
  int get maxTodoListsPerSpaceForAnonymous => 10;

  /// Maximum number of custom lists per space an anonymous user can create.
  int get maxListsPerSpaceForAnonymous => 5;
}
