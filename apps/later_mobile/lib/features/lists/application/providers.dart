import 'package:riverpod_annotation/riverpod_annotation.dart';
import '../data/repositories/providers.dart';
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
