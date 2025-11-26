// ignore_for_file: depend_on_referenced_packages
import 'package:riverpod_annotation/riverpod_annotation.dart';
import '../data/repositories/providers.dart';
import '../domain/models/note.dart';
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

/// Provider for fetching a single note by ID.
///
/// This is a family provider that takes a noteId parameter.
/// Returns `AsyncValue<Note?>` - null if note not found.
/// Auto-disposes when no longer watched.
@riverpod
Future<Note?> noteById(Ref ref, String noteId) async {
  final repository = ref.watch(noteRepositoryProvider);
  return repository.getById(noteId);
}
