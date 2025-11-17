import 'package:later_mobile/core/enums/content_type.dart';
import 'package:later_mobile/features/notes/domain/models/note.dart';
import 'package:later_mobile/features/todo_lists/domain/models/todo_list.dart';
import 'package:later_mobile/features/todo_lists/domain/models/todo_item.dart';
import 'package:later_mobile/features/lists/domain/models/list_model.dart';
import 'package:later_mobile/features/lists/domain/models/list_item_model.dart';

/// SearchResult model representing a unified search result
///
/// This model normalizes different content types into a consistent structure
/// for display in search results. It wraps the original model object and
/// provides common fields (title, preview, etc.) for rendering.
class SearchResult {
  SearchResult({
    required this.id,
    required this.type,
    required this.title,
    this.subtitle,
    this.preview,
    this.tags,
    required this.updatedAt,
    required this.content,
    this.parentId,
    this.parentName,
  });

  /// Factory constructor to create SearchResult from a Note
  factory SearchResult.fromNote(Note note) {
    return SearchResult(
      id: note.id,
      type: ContentType.note,
      title: note.title,
      preview: note.content,
      tags: note.tags,
      updatedAt: note.updatedAt,
      content: note,
    );
  }

  /// Factory constructor to create SearchResult from a TodoList
  factory SearchResult.fromTodoList(TodoList todoList) {
    return SearchResult(
      id: todoList.id,
      type: ContentType.todoList,
      title: todoList.name,
      subtitle: todoList.description,
      preview: todoList.description,
      updatedAt: todoList.updatedAt,
      content: todoList,
    );
  }

  /// Factory constructor to create SearchResult from a ListModel
  factory SearchResult.fromList(ListModel list) {
    return SearchResult(
      id: list.id,
      type: ContentType.list,
      title: list.name,
      updatedAt: list.updatedAt,
      content: list,
    );
  }

  /// Factory constructor to create SearchResult from a TodoItem
  /// Requires parent TodoList information for context
  factory SearchResult.fromTodoItem({
    required TodoItem item,
    required String parentId,
    required String parentName,
    required DateTime parentUpdatedAt,
  }) {
    return SearchResult(
      id: item.id,
      type: ContentType.todoItem,
      title: item.title,
      subtitle: item.description,
      preview: item.description,
      tags: item.tags,
      updatedAt: parentUpdatedAt, // Use parent's updated_at for sorting
      content: item,
      parentId: parentId,
      parentName: parentName,
    );
  }

  /// Factory constructor to create SearchResult from a ListItem
  /// Requires parent ListModel information for context
  factory SearchResult.fromListItem({
    required ListItem item,
    required String parentId,
    required String parentName,
    required DateTime parentUpdatedAt,
  }) {
    return SearchResult(
      id: item.id,
      type: ContentType.listItem,
      title: item.title,
      subtitle: item.notes,
      preview: item.notes,
      updatedAt: parentUpdatedAt, // Use parent's updated_at for sorting
      content: item,
      parentId: parentId,
      parentName: parentName,
    );
  }

  /// Unique identifier of the content item
  final String id;

  /// Type of content (note, todoList, list, todoItem, listItem)
  final ContentType type;

  /// Title or name of the content
  final String title;

  /// Optional subtitle (e.g., description for todo lists)
  final String? subtitle;

  /// Preview text to display in search results
  final String? preview;

  /// Tags associated with the content (for notes and todo items)
  final List<String>? tags;

  /// When the content was last updated (or parent's updated_at for child items)
  final DateTime updatedAt;

  /// The original content object (Note, TodoList, ListModel, TodoItem, or ListItem)
  /// Cast to appropriate type when rendering
  final dynamic content;

  /// Parent ID for child items (todoItem, listItem)
  final String? parentId;

  /// Parent name for child items (e.g., "in Shopping List")
  final String? parentName;

  /// Whether this result is a child item
  bool get isChildItem => type == ContentType.todoItem || type == ContentType.listItem;

  @override
  String toString() {
    return 'SearchResult(id: $id, type: $type, title: $title, parentName: $parentName)';
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;

    return other is SearchResult &&
        other.id == id &&
        other.type == type;
  }

  @override
  int get hashCode => id.hashCode ^ type.hashCode;
}
