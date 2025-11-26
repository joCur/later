import 'package:riverpod_annotation/riverpod_annotation.dart';
import '../data/repositories/providers.dart';
import '../domain/models/todo_list.dart';
import 'services/todo_list_service.dart';

part 'providers.g.dart';

/// Provider for TodoListService (singleton)
///
/// This service handles business logic for todo lists and items.
/// Uses keepAlive to maintain service instance across the app.
@Riverpod(keepAlive: true)
TodoListService todoListService(Ref ref) {
  final repository = ref.watch(todoListRepositoryProvider);
  return TodoListService(repository: repository);
}

/// Provider for fetching a single TodoList by ID
///
/// This is a family provider that creates a separate provider instance
/// for each todoListId. Auto-disposes when no longer watched.
///
/// Returns null if the todo list is not found or user doesn't have access.
@riverpod
Future<TodoList?> todoListById(Ref ref, String todoListId) async {
  final repository = ref.watch(todoListRepositoryProvider);
  return repository.getById(todoListId);
}
