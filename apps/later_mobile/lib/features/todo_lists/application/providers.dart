import 'package:riverpod_annotation/riverpod_annotation.dart';
import '../data/repositories/providers.dart';
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
