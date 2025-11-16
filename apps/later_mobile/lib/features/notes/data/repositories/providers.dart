// ignore_for_file: depend_on_referenced_packages
import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'note_repository.dart';

part 'providers.g.dart';

/// Provider for NoteRepository singleton.
///
/// Uses keepAlive to maintain repository instance across app lifecycle.
/// Repository handles all note-related data operations with Supabase.
@Riverpod(keepAlive: true)
NoteRepository noteRepository(Ref ref) {
  return NoteRepository();
}
