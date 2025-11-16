import 'todo_priority.dart';

/// TodoItem model representing an individual task within a todo list
class TodoItem {
  TodoItem({
    required this.id,
    required this.todoListId,
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
      todoListId: json['todo_list_id'] as String,
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

  /// Foreign key to parent TodoList
  final String todoListId;

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
    String? todoListId,
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
      todoListId: todoListId ?? this.todoListId,
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
      'todo_list_id': todoListId,
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
