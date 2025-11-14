// ignore_for_file: depend_on_referenced_packages
import 'package:riverpod_annotation/riverpod_annotation.dart';
import '../data/repositories/providers.dart';
import 'services/note_service.dart';

part 'providers.g.dart';

/// Provider for NoteService singleton.
///
/// Uses keepAlive to maintain service instance across app lifecycle.
/// Service handles all note-related business logic.
@Riverpod(keepAlive: true)
NoteService noteService(Ref ref) {
  final repository = ref.watch(noteRepositoryProvider);
  return NoteService(repository: repository);
}
