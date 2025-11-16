// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'list_items_controller.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning
/// Controller for managing list items within a list
///
/// This controller uses family pattern to scope state by listId.
/// It manages an AsyncValue with list of ListItem and provides methods for CRUD operations.
///
/// When items are added/removed/toggled, it invalidates the parent ListsController
/// to refresh counts (totalItemCount, checkedItemCount for checklists).
///
/// Usage:
/// ```dart
/// // Watch the controller
/// final itemsAsync = ref.watch(listItemsControllerProvider(listId));
///
/// // Call methods
/// ref.read(listItemsControllerProvider(listId).notifier).createItem(item);
/// ```

@ProviderFor(ListItemsController)
const listItemsControllerProvider = ListItemsControllerFamily._();

/// Controller for managing list items within a list
///
/// This controller uses family pattern to scope state by listId.
/// It manages an AsyncValue with list of ListItem and provides methods for CRUD operations.
///
/// When items are added/removed/toggled, it invalidates the parent ListsController
/// to refresh counts (totalItemCount, checkedItemCount for checklists).
///
/// Usage:
/// ```dart
/// // Watch the controller
/// final itemsAsync = ref.watch(listItemsControllerProvider(listId));
///
/// // Call methods
/// ref.read(listItemsControllerProvider(listId).notifier).createItem(item);
/// ```
final class ListItemsControllerProvider
    extends $AsyncNotifierProvider<ListItemsController, List<ListItem>> {
  /// Controller for managing list items within a list
  ///
  /// This controller uses family pattern to scope state by listId.
  /// It manages an AsyncValue with list of ListItem and provides methods for CRUD operations.
  ///
  /// When items are added/removed/toggled, it invalidates the parent ListsController
  /// to refresh counts (totalItemCount, checkedItemCount for checklists).
  ///
  /// Usage:
  /// ```dart
  /// // Watch the controller
  /// final itemsAsync = ref.watch(listItemsControllerProvider(listId));
  ///
  /// // Call methods
  /// ref.read(listItemsControllerProvider(listId).notifier).createItem(item);
  /// ```
  const ListItemsControllerProvider._({
    required ListItemsControllerFamily super.from,
    required String super.argument,
  }) : super(
         retry: null,
         name: r'listItemsControllerProvider',
         isAutoDispose: true,
         dependencies: null,
         $allTransitiveDependencies: null,
       );

  @override
  String debugGetCreateSourceHash() => _$listItemsControllerHash();

  @override
  String toString() {
    return r'listItemsControllerProvider'
        ''
        '($argument)';
  }

  @$internal
  @override
  ListItemsController create() => ListItemsController();

  @override
  bool operator ==(Object other) {
    return other is ListItemsControllerProvider && other.argument == argument;
  }

  @override
  int get hashCode {
    return argument.hashCode;
  }
}

String _$listItemsControllerHash() =>
    r'287a057527b943112af52608a5e8b5512ddc5280';

/// Controller for managing list items within a list
///
/// This controller uses family pattern to scope state by listId.
/// It manages an AsyncValue with list of ListItem and provides methods for CRUD operations.
///
/// When items are added/removed/toggled, it invalidates the parent ListsController
/// to refresh counts (totalItemCount, checkedItemCount for checklists).
///
/// Usage:
/// ```dart
/// // Watch the controller
/// final itemsAsync = ref.watch(listItemsControllerProvider(listId));
///
/// // Call methods
/// ref.read(listItemsControllerProvider(listId).notifier).createItem(item);
/// ```

final class ListItemsControllerFamily extends $Family
    with
        $ClassFamilyOverride<
          ListItemsController,
          AsyncValue<List<ListItem>>,
          List<ListItem>,
          FutureOr<List<ListItem>>,
          String
        > {
  const ListItemsControllerFamily._()
    : super(
        retry: null,
        name: r'listItemsControllerProvider',
        dependencies: null,
        $allTransitiveDependencies: null,
        isAutoDispose: true,
      );

  /// Controller for managing list items within a list
  ///
  /// This controller uses family pattern to scope state by listId.
  /// It manages an AsyncValue with list of ListItem and provides methods for CRUD operations.
  ///
  /// When items are added/removed/toggled, it invalidates the parent ListsController
  /// to refresh counts (totalItemCount, checkedItemCount for checklists).
  ///
  /// Usage:
  /// ```dart
  /// // Watch the controller
  /// final itemsAsync = ref.watch(listItemsControllerProvider(listId));
  ///
  /// // Call methods
  /// ref.read(listItemsControllerProvider(listId).notifier).createItem(item);
  /// ```

  ListItemsControllerProvider call(String listId) =>
      ListItemsControllerProvider._(argument: listId, from: this);

  @override
  String toString() => r'listItemsControllerProvider';
}

/// Controller for managing list items within a list
///
/// This controller uses family pattern to scope state by listId.
/// It manages an AsyncValue with list of ListItem and provides methods for CRUD operations.
///
/// When items are added/removed/toggled, it invalidates the parent ListsController
/// to refresh counts (totalItemCount, checkedItemCount for checklists).
///
/// Usage:
/// ```dart
/// // Watch the controller
/// final itemsAsync = ref.watch(listItemsControllerProvider(listId));
///
/// // Call methods
/// ref.read(listItemsControllerProvider(listId).notifier).createItem(item);
/// ```

abstract class _$ListItemsController extends $AsyncNotifier<List<ListItem>> {
  late final _$args = ref.$arg as String;
  String get listId => _$args;

  FutureOr<List<ListItem>> build(String listId);
  @$mustCallSuper
  @override
  void runBuild() {
    final created = build(_$args);
    final ref = this.ref as $Ref<AsyncValue<List<ListItem>>, List<ListItem>>;
    final element =
        ref.element
            as $ClassProviderElement<
              AnyNotifier<AsyncValue<List<ListItem>>, List<ListItem>>,
              AsyncValue<List<ListItem>>,
              Object?,
              Object?
            >;
    element.handleValue(ref, created);
  }
}
