/// Priority levels for todo items
enum TodoPriority {
  low,
  medium,
  high,
}

/// TodoItem model representing an individual task within a todo list
class TodoItem {
  TodoItem({
    required this.id,
    required this.title,
    this.description,
    this.isCompleted = false,
    this.dueDate,
    this.priority,
    List<String>? tags,
    required this.sortOrder,
  }) : tags = tags ?? [];

  /// Create from JSON for Supabase compatibility
  factory TodoItem.fromJson(Map<String, dynamic> json) {
    return TodoItem(
      id: json['id'] as String,
      title: json['title'] as String,
      description: json['description'] as String?,
      isCompleted: json['is_completed'] as bool? ?? false,
      dueDate: json['due_date'] != null
          ? DateTime.parse(json['due_date'] as String)
          : null,
      priority: json['priority'] != null
          ? TodoPriority.values.firstWhere(
              (e) => e.toString().split('.').last == json['priority'],
              orElse: () => TodoPriority.medium,
            )
          : null,
      tags: (json['tags'] as List<dynamic>?)?.cast<String>() ?? [],
      sortOrder: json['sort_order'] as int,
    );
  }

  /// Unique identifier for the todo item
  final String id;

  /// Title of the todo item
  final String title;

  /// Optional description providing more details
  final String? description;

  /// Whether the todo item is completed
  final bool isCompleted;

  /// Optional due date for the todo item
  final DateTime? dueDate;

  /// Optional priority level
  final TodoPriority? priority;

  /// Tags associated with the todo item
  final List<String> tags;

  /// Sort order for manual reordering of items
  final int sortOrder;

  /// Create a copy of this todo item with updated fields
  ///
  /// Note: To explicitly clear nullable fields like dueDate, use the clearDueDate parameter
  TodoItem copyWith({
    String? id,
    String? title,
    String? description,
    bool? isCompleted,
    DateTime? dueDate,
    bool clearDueDate = false,
    TodoPriority? priority,
    bool clearPriority = false,
    List<String>? tags,
    int? sortOrder,
  }) {
    return TodoItem(
      id: id ?? this.id,
      title: title ?? this.title,
      description: description ?? this.description,
      isCompleted: isCompleted ?? this.isCompleted,
      dueDate: clearDueDate ? null : (dueDate ?? this.dueDate),
      priority: clearPriority ? null : (priority ?? this.priority),
      tags: tags ?? this.tags,
      sortOrder: sortOrder ?? this.sortOrder,
    );
  }

  /// Convert to JSON for Supabase compatibility
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'title': title,
      'description': description,
      'is_completed': isCompleted,
      'due_date': dueDate?.toIso8601String(),
      'priority': priority?.toString().split('.').last,
      'tags': tags,
      'sort_order': sortOrder,
    };
  }

  @override
  String toString() {
    return 'TodoItem(id: $id, title: $title, isCompleted: $isCompleted, sortOrder: $sortOrder)';
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;

    return other is TodoItem && other.id == id;
  }

  @override
  int get hashCode => id.hashCode;
}

/// TodoList model representing a collection of todo items
class TodoList {
  TodoList({
    required this.id,
    required this.spaceId,
    required this.userId,
    required this.name,
    this.description,
    List<TodoItem>? items,
    DateTime? createdAt,
    DateTime? updatedAt,
    this.sortOrder = 0,
  }) : items = items ?? [],
       createdAt = createdAt ?? DateTime.now(),
       updatedAt = updatedAt ?? DateTime.now();

  /// Create from JSON for Supabase compatibility
  factory TodoList.fromJson(Map<String, dynamic> json) {
    return TodoList(
      id: json['id'] as String,
      spaceId: json['space_id'] as String,
      userId: json['user_id'] as String,
      name: json['name'] as String,
      description: json['description'] as String?,
      items:
          (json['items'] as List<dynamic>?)
              ?.map((item) => TodoItem.fromJson(item as Map<String, dynamic>))
              .toList() ??
          [],
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

  /// Collection of todo items in this list
  /// Note: In Supabase, items are stored in a separate table and fetched via repository methods
  /// This field is maintained for backward compatibility and will be populated by the repository
  final List<TodoItem> items;

  /// When the todo list was created
  final DateTime createdAt;

  /// When the todo list was last updated
  final DateTime updatedAt;

  /// Sort order within a space (space-scoped, not global)
  /// Used for user-defined ordering via drag-and-drop
  final int sortOrder;

  /// Total number of items in the list
  int get totalItems => items.length;

  /// Number of completed items in the list
  int get completedItems => items.where((item) => item.isCompleted).length;

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
    List<TodoItem>? items,
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
      items: items ?? this.items,
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
      'items': items.map((item) => item.toJson()).toList(),
      'created_at': createdAt.toIso8601String(),
      'updated_at': updatedAt.toIso8601String(),
      'sort_order': sortOrder,
    };
  }

  @override
  String toString() {
    return 'TodoList(id: $id, name: $name, spaceId: $spaceId, totalItems: $totalItems, completedItems: $completedItems)';
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;

    return other is TodoList && other.id == id;
  }

  @override
  int get hashCode => id.hashCode;
}
