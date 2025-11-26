import 'package:riverpod_annotation/riverpod_annotation.dart';
import '../data/repositories/providers.dart';
import '../domain/models/list_model.dart';
import 'services/list_service.dart';

part 'providers.g.dart';

/// Provider for ListService (singleton).
///
/// The service layer handles business logic and validation.
/// Uses keepAlive to maintain service instance across the app.
@Riverpod(keepAlive: true)
ListService listService(Ref ref) {
  final repository = ref.watch(listRepositoryProvider);
  return ListService(repository: repository);
}

/// Provider for fetching a single list by ID.
///
/// This is a family provider that takes a listId parameter.
/// Returns `AsyncValue<ListModel?>` - null if list not found.
/// Auto-disposes when no longer watched.
@riverpod
Future<ListModel?> listById(Ref ref, String listId) async {
  final repository = ref.watch(listRepositoryProvider);
  return repository.getById(listId);
}
