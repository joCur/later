// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'todo_items_controller.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning
/// Controller for managing todo items within a todo list
///
/// This controller uses family pattern to scope state by listId.
/// It manages an AsyncValue with list of TodoItem and provides methods for CRUD operations.
///
/// When items are added/removed/toggled, it invalidates the parent TodoListsController
/// to refresh counts (totalItemCount, completedItemCount).
///
/// Usage:
/// ```dart
/// // Watch the controller
/// final itemsAsync = ref.watch(todoItemsControllerProvider(listId));
///
/// // Call methods
/// ref.read(todoItemsControllerProvider(listId).notifier).createItem(item);
/// ```

@ProviderFor(TodoItemsController)
const todoItemsControllerProvider = TodoItemsControllerFamily._();

/// Controller for managing todo items within a todo list
///
/// This controller uses family pattern to scope state by listId.
/// It manages an AsyncValue with list of TodoItem and provides methods for CRUD operations.
///
/// When items are added/removed/toggled, it invalidates the parent TodoListsController
/// to refresh counts (totalItemCount, completedItemCount).
///
/// Usage:
/// ```dart
/// // Watch the controller
/// final itemsAsync = ref.watch(todoItemsControllerProvider(listId));
///
/// // Call methods
/// ref.read(todoItemsControllerProvider(listId).notifier).createItem(item);
/// ```
final class TodoItemsControllerProvider
    extends $AsyncNotifierProvider<TodoItemsController, List<TodoItem>> {
  /// Controller for managing todo items within a todo list
  ///
  /// This controller uses family pattern to scope state by listId.
  /// It manages an AsyncValue with list of TodoItem and provides methods for CRUD operations.
  ///
  /// When items are added/removed/toggled, it invalidates the parent TodoListsController
  /// to refresh counts (totalItemCount, completedItemCount).
  ///
  /// Usage:
  /// ```dart
  /// // Watch the controller
  /// final itemsAsync = ref.watch(todoItemsControllerProvider(listId));
  ///
  /// // Call methods
  /// ref.read(todoItemsControllerProvider(listId).notifier).createItem(item);
  /// ```
  const TodoItemsControllerProvider._({
    required TodoItemsControllerFamily super.from,
    required String super.argument,
  }) : super(
         retry: null,
         name: r'todoItemsControllerProvider',
         isAutoDispose: true,
         dependencies: null,
         $allTransitiveDependencies: null,
       );

  @override
  String debugGetCreateSourceHash() => _$todoItemsControllerHash();

  @override
  String toString() {
    return r'todoItemsControllerProvider'
        ''
        '($argument)';
  }

  @$internal
  @override
  TodoItemsController create() => TodoItemsController();

  @override
  bool operator ==(Object other) {
    return other is TodoItemsControllerProvider && other.argument == argument;
  }

  @override
  int get hashCode {
    return argument.hashCode;
  }
}

String _$todoItemsControllerHash() =>
    r'0f576e318d2a40d9a1801961abb6e215dbf22035';

/// Controller for managing todo items within a todo list
///
/// This controller uses family pattern to scope state by listId.
/// It manages an AsyncValue with list of TodoItem and provides methods for CRUD operations.
///
/// When items are added/removed/toggled, it invalidates the parent TodoListsController
/// to refresh counts (totalItemCount, completedItemCount).
///
/// Usage:
/// ```dart
/// // Watch the controller
/// final itemsAsync = ref.watch(todoItemsControllerProvider(listId));
///
/// // Call methods
/// ref.read(todoItemsControllerProvider(listId).notifier).createItem(item);
/// ```

final class TodoItemsControllerFamily extends $Family
    with
        $ClassFamilyOverride<
          TodoItemsController,
          AsyncValue<List<TodoItem>>,
          List<TodoItem>,
          FutureOr<List<TodoItem>>,
          String
        > {
  const TodoItemsControllerFamily._()
    : super(
        retry: null,
        name: r'todoItemsControllerProvider',
        dependencies: null,
        $allTransitiveDependencies: null,
        isAutoDispose: true,
      );

  /// Controller for managing todo items within a todo list
  ///
  /// This controller uses family pattern to scope state by listId.
  /// It manages an AsyncValue with list of TodoItem and provides methods for CRUD operations.
  ///
  /// When items are added/removed/toggled, it invalidates the parent TodoListsController
  /// to refresh counts (totalItemCount, completedItemCount).
  ///
  /// Usage:
  /// ```dart
  /// // Watch the controller
  /// final itemsAsync = ref.watch(todoItemsControllerProvider(listId));
  ///
  /// // Call methods
  /// ref.read(todoItemsControllerProvider(listId).notifier).createItem(item);
  /// ```

  TodoItemsControllerProvider call(String listId) =>
      TodoItemsControllerProvider._(argument: listId, from: this);

  @override
  String toString() => r'todoItemsControllerProvider';
}

/// Controller for managing todo items within a todo list
///
/// This controller uses family pattern to scope state by listId.
/// It manages an AsyncValue with list of TodoItem and provides methods for CRUD operations.
///
/// When items are added/removed/toggled, it invalidates the parent TodoListsController
/// to refresh counts (totalItemCount, completedItemCount).
///
/// Usage:
/// ```dart
/// // Watch the controller
/// final itemsAsync = ref.watch(todoItemsControllerProvider(listId));
///
/// // Call methods
/// ref.read(todoItemsControllerProvider(listId).notifier).createItem(item);
/// ```

abstract class _$TodoItemsController extends $AsyncNotifier<List<TodoItem>> {
  late final _$args = ref.$arg as String;
  String get listId => _$args;

  FutureOr<List<TodoItem>> build(String listId);
  @$mustCallSuper
  @override
  void runBuild() {
    final created = build(_$args);
    final ref = this.ref as $Ref<AsyncValue<List<TodoItem>>, List<TodoItem>>;
    final element =
        ref.element
            as $ClassProviderElement<
              AnyNotifier<AsyncValue<List<TodoItem>>, List<TodoItem>>,
              AsyncValue<List<TodoItem>>,
              Object?,
              Object?
            >;
    element.handleValue(ref, created);
  }
}
