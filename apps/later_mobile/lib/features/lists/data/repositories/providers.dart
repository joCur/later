import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'list_repository.dart';

part 'providers.g.dart';

/// Provider for ListRepository.
///
/// Uses keepAlive: true to maintain a singleton instance throughout the app lifecycle.
/// The repository handles all data access for ListModel and ListItem entities.
@Riverpod(keepAlive: true)
ListRepository listRepository(Ref ref) {
  return ListRepository();
}
