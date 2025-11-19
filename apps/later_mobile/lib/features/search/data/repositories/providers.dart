import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'search_repository.dart';

part 'providers.g.dart';

/// Provider for SearchRepository
///
/// Provides a singleton instance of the SearchRepository for dependency injection.
/// The repository is kept alive for the lifetime of the application.
@Riverpod(keepAlive: true)
SearchRepository searchRepository(Ref ref) {
  return SearchRepository();
}
