import 'package:flutter/material.dart';
import 'package:later_mobile/core/enums/content_type.dart';
import 'package:later_mobile/design_system/organisms/cards/list_card.dart';
import 'package:later_mobile/design_system/organisms/cards/note_card.dart';
import 'package:later_mobile/design_system/organisms/cards/todo_list_card.dart';
import 'package:later_mobile/features/lists/domain/models/list_item_model.dart';
import 'package:later_mobile/features/lists/domain/models/list_model.dart';
import 'package:later_mobile/features/lists/presentation/screens/list_detail_screen.dart';
import 'package:later_mobile/features/notes/domain/models/note.dart';
import 'package:later_mobile/features/notes/presentation/screens/note_detail_screen.dart';
import 'package:later_mobile/features/search/domain/models/models.dart';
import 'package:later_mobile/features/search/presentation/widgets/list_item_search_card.dart';
import 'package:later_mobile/features/search/presentation/widgets/todo_item_search_card.dart';
import 'package:later_mobile/features/todo_lists/domain/models/todo_item.dart';
import 'package:later_mobile/features/todo_lists/domain/models/todo_list.dart';
import 'package:later_mobile/features/todo_lists/presentation/screens/todo_list_detail_screen.dart';

/// Wrapper widget that renders the appropriate card component based on search result type
/// and handles navigation to detail screens.
///
/// Supports all content types:
/// - Notes → NoteCard with navigation to NoteDetailScreen
/// - TodoLists → TodoListCard with navigation to TodoListDetailScreen
/// - Lists → ListCard with navigation to ListDetailScreen
/// - TodoItems → TodoItemSearchCard with navigation to parent TodoListDetailScreen
/// - ListItems → ListItemSearchCard with navigation to parent ListDetailScreen
class SearchResultCard extends StatelessWidget {
  const SearchResultCard({super.key, required this.result});

  final SearchResult result;

  @override
  Widget build(BuildContext context) {
    return switch (result.type) {
      ContentType.note => _buildNoteCard(context),
      ContentType.todoList => _buildTodoListCard(context),
      ContentType.list => _buildListCard(context),
      ContentType.todoItem => _buildTodoItemCard(context),
      ContentType.listItem => _buildListItemCard(context),
    };
  }

  /// Build NoteCard with navigation
  Widget _buildNoteCard(BuildContext context) {
    final note = result.content as Note;

    return NoteCard(
      note: note,
      onTap: () {
        Navigator.of(context).push(
          MaterialPageRoute<void>(
            builder: (context) => NoteDetailScreen(note: note),
          ),
        );
      },
    );
  }

  /// Build TodoListCard with navigation
  Widget _buildTodoListCard(BuildContext context) {
    final todoList = result.content as TodoList;

    return TodoListCard(
      todoList: todoList,
      onTap: () {
        Navigator.of(context).push(
          MaterialPageRoute<void>(
            builder: (context) => TodoListDetailScreen(todoList: todoList),
          ),
        );
      },
    );
  }

  /// Build ListCard with navigation
  Widget _buildListCard(BuildContext context) {
    final list = result.content as ListModel;

    return ListCard(
      list: list,
      onTap: () {
        Navigator.of(context).push(
          MaterialPageRoute<void>(
            builder: (context) => ListDetailScreen(list: list),
          ),
        );
      },
    );
  }

  /// Build TodoItemSearchCard with navigation to parent TodoList
  Widget _buildTodoItemCard(BuildContext context) {
    final todoItem = result.content as TodoItem;

    return TodoItemSearchCard(
      todoItem: todoItem,
      parentName: result.parentName ?? 'Unknown List',
      onTap: () {
        // Navigate to parent TodoList detail screen
        if (result.parentId != null) {
          // We need to fetch the parent TodoList to navigate
          // For now, we'll create a minimal TodoList instance with just the ID
          // The detail screen will load the full data
          final parentTodoList = TodoList(
            id: result.parentId!,
            name: result.parentName ?? 'Unknown List',
            spaceId: '', // Will be loaded in detail screen
            userId: '', // Will be loaded in detail screen
            createdAt: DateTime.now(),
            updatedAt: DateTime.now(),
          );

          Navigator.of(context).push(
            MaterialPageRoute<void>(
              builder: (context) =>
                  TodoListDetailScreen(todoList: parentTodoList),
            ),
          );
        }
      },
    );
  }

  /// Build ListItemSearchCard with navigation to parent List
  Widget _buildListItemCard(BuildContext context) {
    final listItem = result.content as ListItem;

    return ListItemSearchCard(
      listItem: listItem,
      parentName: result.parentName ?? 'Unknown List',
      onTap: () {
        // Navigate to parent List detail screen
        if (result.parentId != null) {
          // We need to fetch the parent List to navigate
          // For now, we'll create a minimal ListModel instance with just the ID
          // The detail screen will load the full data
          final parentList = ListModel(
            id: result.parentId!,
            name: result.parentName ?? 'Unknown List',
            spaceId: '', // Will be loaded in detail screen
            userId: '', // Will be loaded in detail screen
            createdAt: DateTime.now(),
            updatedAt: DateTime.now(),
          );

          Navigator.of(context).push(
            MaterialPageRoute<void>(
              builder: (context) => ListDetailScreen(list: parentList),
            ),
          );
        }
      },
    );
  }
}
