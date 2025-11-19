/// Content type enum for the Later app
///
/// Represents different types of content that can be created and searched.
/// Container types (note, todoList, list) can contain child items.
/// Child types (todoItem, listItem) belong to a parent container.
enum ContentType {
  /// A free-form note with title and optional content
  note,

  /// A todo list container (has multiple todo items)
  todoList,

  /// A custom list container (has multiple list items)
  list,

  /// An individual todo item within a todo list
  todoItem,

  /// An individual item within a custom list
  listItem,
}

/// Extension for ContentType to provide helper methods
extension ContentTypeExtension on ContentType {
  /// Returns a display name for the content type
  String get displayName {
    switch (this) {
      case ContentType.todoList:
        return 'Todo List';
      case ContentType.list:
        return 'List';
      case ContentType.note:
        return 'Note';
      case ContentType.todoItem:
        return 'Todo Item';
      case ContentType.listItem:
        return 'List Item';
    }
  }

  /// Returns true if this is a container type (has child items)
  /// Container types: note, todoList, list
  /// Child types: todoItem, listItem
  bool get isContainer {
    switch (this) {
      case ContentType.todoList:
      case ContentType.list:
      case ContentType.note:
        return true;
      case ContentType.todoItem:
      case ContentType.listItem:
        return false;
    }
  }
}
