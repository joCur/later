import 'package:hive/hive.dart';

part 'todo_list_model.g.dart';

/// Priority levels for todo items
@HiveType(typeId: 25)
enum TodoPriority {
  @HiveField(0)
  low,
  @HiveField(1)
  medium,
  @HiveField(2)
  high,
}

/// TodoItem model representing an individual task within a todo list
@HiveType(typeId: 21)
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

  /// Create from JSON for serialization
  factory TodoItem.fromJson(Map<String, dynamic> json) {
    return TodoItem(
      id: json['id'] as String,
      title: json['title'] as String,
      description: json['description'] as String?,
      isCompleted: json['isCompleted'] as bool? ?? false,
      dueDate: json['dueDate'] != null
          ? DateTime.parse(json['dueDate'] as String)
          : null,
      priority: json['priority'] != null
          ? TodoPriority.values.firstWhere(
              (e) => e.toString().split('.').last == json['priority'],
              orElse: () => TodoPriority.medium,
            )
          : null,
      tags: (json['tags'] as List<dynamic>?)?.cast<String>() ?? [],
      sortOrder: json['sortOrder'] as int,
    );
  }

  /// Unique identifier for the todo item
  @HiveField(0)
  final String id;

  /// Title of the todo item
  @HiveField(1)
  final String title;

  /// Optional description providing more details
  @HiveField(2)
  final String? description;

  /// Whether the todo item is completed
  @HiveField(3)
  final bool isCompleted;

  /// Optional due date for the todo item
  @HiveField(4)
  final DateTime? dueDate;

  /// Optional priority level
  @HiveField(5)
  final TodoPriority? priority;

  /// Tags associated with the todo item
  @HiveField(6)
  final List<String> tags;

  /// Sort order for manual reordering of items
  @HiveField(7)
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

  /// Convert to JSON for serialization
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'title': title,
      'description': description,
      'isCompleted': isCompleted,
      'dueDate': dueDate?.toIso8601String(),
      'priority': priority?.toString().split('.').last,
      'tags': tags,
      'sortOrder': sortOrder,
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
@HiveType(typeId: 20)
class TodoList {
  TodoList({
    required this.id,
    required this.spaceId,
    required this.name,
    this.description,
    List<TodoItem>? items,
    DateTime? createdAt,
    DateTime? updatedAt,
  })  : items = items ?? [],
        createdAt = createdAt ?? DateTime.now(),
        updatedAt = updatedAt ?? DateTime.now();

  /// Create from JSON for serialization
  factory TodoList.fromJson(Map<String, dynamic> json) {
    return TodoList(
      id: json['id'] as String,
      spaceId: json['spaceId'] as String,
      name: json['name'] as String,
      description: json['description'] as String?,
      items: (json['items'] as List<dynamic>?)
              ?.map((item) => TodoItem.fromJson(item as Map<String, dynamic>))
              .toList() ??
          [],
      createdAt: DateTime.parse(json['createdAt'] as String),
      updatedAt: DateTime.parse(json['updatedAt'] as String),
    );
  }

  /// Unique identifier for the todo list
  @HiveField(0)
  final String id;

  /// ID of the space this todo list belongs to
  @HiveField(1)
  final String spaceId;

  /// Name of the todo list
  @HiveField(2)
  final String name;

  /// Optional description of the todo list
  @HiveField(3)
  final String? description;

  /// Collection of todo items in this list
  @HiveField(4)
  final List<TodoItem> items;

  /// When the todo list was created
  @HiveField(5)
  final DateTime createdAt;

  /// When the todo list was last updated
  @HiveField(6)
  final DateTime updatedAt;

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
    String? name,
    String? description,
    List<TodoItem>? items,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return TodoList(
      id: id ?? this.id,
      spaceId: spaceId ?? this.spaceId,
      name: name ?? this.name,
      description: description ?? this.description,
      items: items ?? this.items,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }

  /// Convert to JSON for serialization
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'spaceId': spaceId,
      'name': name,
      'description': description,
      'items': items.map((item) => item.toJson()).toList(),
      'createdAt': createdAt.toIso8601String(),
      'updatedAt': updatedAt.toIso8601String(),
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
