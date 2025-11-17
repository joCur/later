// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'lists_controller.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning
/// Controller for managing lists within a space
///
/// This controller uses family pattern to scope state by spaceId.
/// It manages an AsyncValue with list of ListModel and provides methods for CRUD operations.
///
/// Usage:
/// ```dart
/// // Watch the controller
/// final listsAsync = ref.watch(listsControllerProvider(spaceId));
///
/// // Call methods
/// ref.read(listsControllerProvider(spaceId).notifier).createList(list);
/// ```

@ProviderFor(ListsController)
const listsControllerProvider = ListsControllerFamily._();

/// Controller for managing lists within a space
///
/// This controller uses family pattern to scope state by spaceId.
/// It manages an AsyncValue with list of ListModel and provides methods for CRUD operations.
///
/// Usage:
/// ```dart
/// // Watch the controller
/// final listsAsync = ref.watch(listsControllerProvider(spaceId));
///
/// // Call methods
/// ref.read(listsControllerProvider(spaceId).notifier).createList(list);
/// ```
final class ListsControllerProvider
    extends $AsyncNotifierProvider<ListsController, List<ListModel>> {
  /// Controller for managing lists within a space
  ///
  /// This controller uses family pattern to scope state by spaceId.
  /// It manages an AsyncValue with list of ListModel and provides methods for CRUD operations.
  ///
  /// Usage:
  /// ```dart
  /// // Watch the controller
  /// final listsAsync = ref.watch(listsControllerProvider(spaceId));
  ///
  /// // Call methods
  /// ref.read(listsControllerProvider(spaceId).notifier).createList(list);
  /// ```
  const ListsControllerProvider._({
    required ListsControllerFamily super.from,
    required String super.argument,
  }) : super(
         retry: null,
         name: r'listsControllerProvider',
         isAutoDispose: true,
         dependencies: null,
         $allTransitiveDependencies: null,
       );

  @override
  String debugGetCreateSourceHash() => _$listsControllerHash();

  @override
  String toString() {
    return r'listsControllerProvider'
        ''
        '($argument)';
  }

  @$internal
  @override
  ListsController create() => ListsController();

  @override
  bool operator ==(Object other) {
    return other is ListsControllerProvider && other.argument == argument;
  }

  @override
  int get hashCode {
    return argument.hashCode;
  }
}

String _$listsControllerHash() => r'38406eaea07acb9560fd789150b4796847c776f8';

/// Controller for managing lists within a space
///
/// This controller uses family pattern to scope state by spaceId.
/// It manages an AsyncValue with list of ListModel and provides methods for CRUD operations.
///
/// Usage:
/// ```dart
/// // Watch the controller
/// final listsAsync = ref.watch(listsControllerProvider(spaceId));
///
/// // Call methods
/// ref.read(listsControllerProvider(spaceId).notifier).createList(list);
/// ```

final class ListsControllerFamily extends $Family
    with
        $ClassFamilyOverride<
          ListsController,
          AsyncValue<List<ListModel>>,
          List<ListModel>,
          FutureOr<List<ListModel>>,
          String
        > {
  const ListsControllerFamily._()
    : super(
        retry: null,
        name: r'listsControllerProvider',
        dependencies: null,
        $allTransitiveDependencies: null,
        isAutoDispose: true,
      );

  /// Controller for managing lists within a space
  ///
  /// This controller uses family pattern to scope state by spaceId.
  /// It manages an AsyncValue with list of ListModel and provides methods for CRUD operations.
  ///
  /// Usage:
  /// ```dart
  /// // Watch the controller
  /// final listsAsync = ref.watch(listsControllerProvider(spaceId));
  ///
  /// // Call methods
  /// ref.read(listsControllerProvider(spaceId).notifier).createList(list);
  /// ```

  ListsControllerProvider call(String spaceId) =>
      ListsControllerProvider._(argument: spaceId, from: this);

  @override
  String toString() => r'listsControllerProvider';
}

/// Controller for managing lists within a space
///
/// This controller uses family pattern to scope state by spaceId.
/// It manages an AsyncValue with list of ListModel and provides methods for CRUD operations.
///
/// Usage:
/// ```dart
/// // Watch the controller
/// final listsAsync = ref.watch(listsControllerProvider(spaceId));
///
/// // Call methods
/// ref.read(listsControllerProvider(spaceId).notifier).createList(list);
/// ```

abstract class _$ListsController extends $AsyncNotifier<List<ListModel>> {
  late final _$args = ref.$arg as String;
  String get spaceId => _$args;

  FutureOr<List<ListModel>> build(String spaceId);
  @$mustCallSuper
  @override
  void runBuild() {
    final created = build(_$args);
    final ref = this.ref as $Ref<AsyncValue<List<ListModel>>, List<ListModel>>;
    final element =
        ref.element
            as $ClassProviderElement<
              AnyNotifier<AsyncValue<List<ListModel>>, List<ListModel>>,
              AsyncValue<List<ListModel>>,
              Object?,
              Object?
            >;
    element.handleValue(ref, created);
  }
}
