import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'todo_list_repository.dart';

part 'providers.g.dart';

/// Provider for TodoListRepository (singleton)
///
/// This repository handles both TodoList and TodoItem operations.
/// Uses keepAlive to maintain repository instance across the app.
@Riverpod(keepAlive: true)
TodoListRepository todoListRepository(Ref ref) {
  return TodoListRepository();
}
