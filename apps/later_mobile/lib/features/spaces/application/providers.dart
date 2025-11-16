// ignore_for_file: depend_on_referenced_packages
import 'package:riverpod_annotation/riverpod_annotation.dart';
import '../data/repositories/providers.dart';
import 'services/space_service.dart';

part 'providers.g.dart';

/// Provider for [SpaceService] singleton.
///
/// Depends on [spaceRepositoryProvider] for data access.
/// Keep alive to maintain service instance throughout app lifecycle.
@Riverpod(keepAlive: true)
SpaceService spaceService(Ref ref) {
  final repository = ref.watch(spaceRepositoryProvider);
  return SpaceService(repository: repository);
}
