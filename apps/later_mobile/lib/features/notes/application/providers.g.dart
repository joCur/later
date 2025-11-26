// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'providers.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning
/// Provider for NoteService singleton.
///
/// Uses keepAlive to maintain service instance across app lifecycle.
/// Service handles all note-related business logic.

@ProviderFor(noteService)
const noteServiceProvider = NoteServiceProvider._();

/// Provider for NoteService singleton.
///
/// Uses keepAlive to maintain service instance across app lifecycle.
/// Service handles all note-related business logic.

final class NoteServiceProvider
    extends $FunctionalProvider<NoteService, NoteService, NoteService>
    with $Provider<NoteService> {
  /// Provider for NoteService singleton.
  ///
  /// Uses keepAlive to maintain service instance across app lifecycle.
  /// Service handles all note-related business logic.
  const NoteServiceProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'noteServiceProvider',
        isAutoDispose: false,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$noteServiceHash();

  @$internal
  @override
  $ProviderElement<NoteService> $createElement($ProviderPointer pointer) =>
      $ProviderElement(pointer);

  @override
  NoteService create(Ref ref) {
    return noteService(ref);
  }

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(NoteService value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<NoteService>(value),
    );
  }
}

String _$noteServiceHash() => r'8a5a9889b10513fa310808f21f4a4a26e251cac8';

/// Provider for fetching a single note by ID.
///
/// This is a family provider that takes a noteId parameter.
/// Returns `AsyncValue<Note?>` - null if note not found.
/// Auto-disposes when no longer watched.

@ProviderFor(noteById)
const noteByIdProvider = NoteByIdFamily._();

/// Provider for fetching a single note by ID.
///
/// This is a family provider that takes a noteId parameter.
/// Returns `AsyncValue<Note?>` - null if note not found.
/// Auto-disposes when no longer watched.

final class NoteByIdProvider
    extends $FunctionalProvider<AsyncValue<Note?>, Note?, FutureOr<Note?>>
    with $FutureModifier<Note?>, $FutureProvider<Note?> {
  /// Provider for fetching a single note by ID.
  ///
  /// This is a family provider that takes a noteId parameter.
  /// Returns `AsyncValue<Note?>` - null if note not found.
  /// Auto-disposes when no longer watched.
  const NoteByIdProvider._({
    required NoteByIdFamily super.from,
    required String super.argument,
  }) : super(
         retry: null,
         name: r'noteByIdProvider',
         isAutoDispose: true,
         dependencies: null,
         $allTransitiveDependencies: null,
       );

  @override
  String debugGetCreateSourceHash() => _$noteByIdHash();

  @override
  String toString() {
    return r'noteByIdProvider'
        ''
        '($argument)';
  }

  @$internal
  @override
  $FutureProviderElement<Note?> $createElement($ProviderPointer pointer) =>
      $FutureProviderElement(pointer);

  @override
  FutureOr<Note?> create(Ref ref) {
    final argument = this.argument as String;
    return noteById(ref, argument);
  }

  @override
  bool operator ==(Object other) {
    return other is NoteByIdProvider && other.argument == argument;
  }

  @override
  int get hashCode {
    return argument.hashCode;
  }
}

String _$noteByIdHash() => r'10767b8fd489f3f1495c78af92b87dac472bafe5';

/// Provider for fetching a single note by ID.
///
/// This is a family provider that takes a noteId parameter.
/// Returns `AsyncValue<Note?>` - null if note not found.
/// Auto-disposes when no longer watched.

final class NoteByIdFamily extends $Family
    with $FunctionalFamilyOverride<FutureOr<Note?>, String> {
  const NoteByIdFamily._()
    : super(
        retry: null,
        name: r'noteByIdProvider',
        dependencies: null,
        $allTransitiveDependencies: null,
        isAutoDispose: true,
      );

  /// Provider for fetching a single note by ID.
  ///
  /// This is a family provider that takes a noteId parameter.
  /// Returns `AsyncValue<Note?>` - null if note not found.
  /// Auto-disposes when no longer watched.

  NoteByIdProvider call(String noteId) =>
      NoteByIdProvider._(argument: noteId, from: this);

  @override
  String toString() => r'noteByIdProvider';
}
