// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'providers.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning
/// Provider for NoteRepository singleton.
///
/// Uses keepAlive to maintain repository instance across app lifecycle.
/// Repository handles all note-related data operations with Supabase.

@ProviderFor(noteRepository)
const noteRepositoryProvider = NoteRepositoryProvider._();

/// Provider for NoteRepository singleton.
///
/// Uses keepAlive to maintain repository instance across app lifecycle.
/// Repository handles all note-related data operations with Supabase.

final class NoteRepositoryProvider
    extends $FunctionalProvider<NoteRepository, NoteRepository, NoteRepository>
    with $Provider<NoteRepository> {
  /// Provider for NoteRepository singleton.
  ///
  /// Uses keepAlive to maintain repository instance across app lifecycle.
  /// Repository handles all note-related data operations with Supabase.
  const NoteRepositoryProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'noteRepositoryProvider',
        isAutoDispose: false,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$noteRepositoryHash();

  @$internal
  @override
  $ProviderElement<NoteRepository> $createElement($ProviderPointer pointer) =>
      $ProviderElement(pointer);

  @override
  NoteRepository create(Ref ref) {
    return noteRepository(ref);
  }

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(NoteRepository value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<NoteRepository>(value),
    );
  }
}

String _$noteRepositoryHash() => r'b069203cb731ea8aba7cca3bb3a70a9ec88d1680';
