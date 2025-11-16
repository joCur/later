// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'notes_controller.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning
/// Controller for managing notes state for a specific space.
///
/// Manages AsyncValue with list of notes for a space.
/// Provides methods for CRUD operations on notes.
/// Uses NoteService for business logic.
///
/// This is a family provider that takes a spaceId parameter,
/// so each space has its own independent notes controller.

@ProviderFor(NotesController)
const notesControllerProvider = NotesControllerFamily._();

/// Controller for managing notes state for a specific space.
///
/// Manages AsyncValue with list of notes for a space.
/// Provides methods for CRUD operations on notes.
/// Uses NoteService for business logic.
///
/// This is a family provider that takes a spaceId parameter,
/// so each space has its own independent notes controller.
final class NotesControllerProvider
    extends $AsyncNotifierProvider<NotesController, List<Note>> {
  /// Controller for managing notes state for a specific space.
  ///
  /// Manages AsyncValue with list of notes for a space.
  /// Provides methods for CRUD operations on notes.
  /// Uses NoteService for business logic.
  ///
  /// This is a family provider that takes a spaceId parameter,
  /// so each space has its own independent notes controller.
  const NotesControllerProvider._({
    required NotesControllerFamily super.from,
    required String super.argument,
  }) : super(
         retry: null,
         name: r'notesControllerProvider',
         isAutoDispose: true,
         dependencies: null,
         $allTransitiveDependencies: null,
       );

  @override
  String debugGetCreateSourceHash() => _$notesControllerHash();

  @override
  String toString() {
    return r'notesControllerProvider'
        ''
        '($argument)';
  }

  @$internal
  @override
  NotesController create() => NotesController();

  @override
  bool operator ==(Object other) {
    return other is NotesControllerProvider && other.argument == argument;
  }

  @override
  int get hashCode {
    return argument.hashCode;
  }
}

String _$notesControllerHash() => r'0ba9bd8e2f9ee96818a4e14cbd250e181677f211';

/// Controller for managing notes state for a specific space.
///
/// Manages AsyncValue with list of notes for a space.
/// Provides methods for CRUD operations on notes.
/// Uses NoteService for business logic.
///
/// This is a family provider that takes a spaceId parameter,
/// so each space has its own independent notes controller.

final class NotesControllerFamily extends $Family
    with
        $ClassFamilyOverride<
          NotesController,
          AsyncValue<List<Note>>,
          List<Note>,
          FutureOr<List<Note>>,
          String
        > {
  const NotesControllerFamily._()
    : super(
        retry: null,
        name: r'notesControllerProvider',
        dependencies: null,
        $allTransitiveDependencies: null,
        isAutoDispose: true,
      );

  /// Controller for managing notes state for a specific space.
  ///
  /// Manages AsyncValue with list of notes for a space.
  /// Provides methods for CRUD operations on notes.
  /// Uses NoteService for business logic.
  ///
  /// This is a family provider that takes a spaceId parameter,
  /// so each space has its own independent notes controller.

  NotesControllerProvider call(String spaceId) =>
      NotesControllerProvider._(argument: spaceId, from: this);

  @override
  String toString() => r'notesControllerProvider';
}

/// Controller for managing notes state for a specific space.
///
/// Manages AsyncValue with list of notes for a space.
/// Provides methods for CRUD operations on notes.
/// Uses NoteService for business logic.
///
/// This is a family provider that takes a spaceId parameter,
/// so each space has its own independent notes controller.

abstract class _$NotesController extends $AsyncNotifier<List<Note>> {
  late final _$args = ref.$arg as String;
  String get spaceId => _$args;

  FutureOr<List<Note>> build(String spaceId);
  @$mustCallSuper
  @override
  void runBuild() {
    final created = build(_$args);
    final ref = this.ref as $Ref<AsyncValue<List<Note>>, List<Note>>;
    final element =
        ref.element
            as $ClassProviderElement<
              AnyNotifier<AsyncValue<List<Note>>, List<Note>>,
              AsyncValue<List<Note>>,
              Object?,
              Object?
            >;
    element.handleValue(ref, created);
  }
}
