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
