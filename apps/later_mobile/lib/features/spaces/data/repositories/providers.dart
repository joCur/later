// ignore_for_file: depend_on_referenced_packages
import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'space_repository.dart';

part 'providers.g.dart';

/// Provider for SpaceRepository singleton.
///
/// Uses keepAlive to maintain repository instance across app lifecycle.
/// Repository handles all space-related data operations with Supabase.
@Riverpod(keepAlive: true)
SpaceRepository spaceRepository(Ref ref) {
  return SpaceRepository();
}
