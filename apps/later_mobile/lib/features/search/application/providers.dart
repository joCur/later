import 'package:later_mobile/features/search/application/services/search_service.dart';
import 'package:later_mobile/features/search/data/repositories/providers.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'providers.g.dart';

/// Provider for SearchService.
///
/// Auto-disposes when no longer in use.
@riverpod
SearchService searchService(Ref ref) {
  final repository = ref.watch(searchRepositoryProvider);
  return SearchService(repository);
}
