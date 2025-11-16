/// TodoList model representing a collection of todo items
///
/// In Supabase, todo items are stored in a separate `todo_items` table
/// and fetched via repository methods when needed. This model contains
/// aggregate counts (totalItemCount, completedItemCount) populated from
/// database GROUP BY queries for efficient list views.
class TodoList {
  TodoList({
    required this.id,
    required this.spaceId,
    required this.userId,
    required this.name,
    this.description,
    this.totalItemCount = 0,
    this.completedItemCount = 0,
    DateTime? createdAt,
    DateTime? updatedAt,
    this.sortOrder = 0,
  }) : createdAt = createdAt ?? DateTime.now(),
       updatedAt = updatedAt ?? DateTime.now();

  /// Create from JSON for Supabase compatibility
  factory TodoList.fromJson(Map<String, dynamic> json) {
    return TodoList(
      id: json['id'] as String,
      spaceId: json['space_id'] as String,
      userId: json['user_id'] as String,
      name: json['name'] as String,
      description: json['description'] as String?,
      totalItemCount: (json['total_item_count'] as int?) ?? 0,
      completedItemCount: (json['completed_item_count'] as int?) ?? 0,
      createdAt: DateTime.parse(json['created_at'] as String),
      updatedAt: DateTime.parse(json['updated_at'] as String),
      sortOrder: (json['sort_order'] as int?) ?? 0,
    );
  }

  /// Unique identifier for the todo list
  final String id;

  /// ID of the space this todo list belongs to
  final String spaceId;

  /// ID of the user who owns this todo list
  final String userId;

  /// Name of the todo list
  final String name;

  /// Optional description of the todo list
  final String? description;

  /// Total number of todo items (populated from database aggregate)
  final int totalItemCount;

  /// Number of completed items (populated from database aggregate)
  final int completedItemCount;

  /// When the todo list was created
  final DateTime createdAt;

  /// When the todo list was last updated
  final DateTime updatedAt;

  /// Sort order within a space (space-scoped, not global)
  /// Used for user-defined ordering via drag-and-drop
  final int sortOrder;

  /// Total number of items in the list
  int get totalItems => totalItemCount;

  /// Number of completed items in the list
  int get completedItems => completedItemCount;

  /// Progress as a value between 0.0 and 1.0
  /// Returns 0.0 if there are no items to avoid division by zero
  double get progress {
    if (totalItems == 0) return 0.0;
    return completedItems / totalItems;
  }

  /// Create a copy of this todo list with updated fields
  TodoList copyWith({
    String? id,
    String? spaceId,
    String? userId,
    String? name,
    String? description,
    int? totalItemCount,
    int? completedItemCount,
    DateTime? createdAt,
    DateTime? updatedAt,
    int? sortOrder,
  }) {
    return TodoList(
      id: id ?? this.id,
      spaceId: spaceId ?? this.spaceId,
      userId: userId ?? this.userId,
      name: name ?? this.name,
      description: description ?? this.description,
      totalItemCount: totalItemCount ?? this.totalItemCount,
      completedItemCount: completedItemCount ?? this.completedItemCount,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      sortOrder: sortOrder ?? this.sortOrder,
    );
  }

  /// Convert to JSON for Supabase compatibility
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'space_id': spaceId,
      'user_id': userId,
      'name': name,
      'description': description,
      'total_item_count': totalItemCount,
      'completed_item_count': completedItemCount,
      'created_at': createdAt.toIso8601String(),
      'updated_at': updatedAt.toIso8601String(),
      'sort_order': sortOrder,
    };
  }

  @override
  String toString() {
    return 'TodoList(id: $id, name: $name, spaceId: $spaceId, userId: $userId)';
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;

    return other is TodoList && other.id == id;
  }

  @override
  int get hashCode => id.hashCode;
}
