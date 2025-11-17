// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'todo_lists_controller.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning
/// Controller for managing todo lists within a space
///
/// This controller uses family pattern to scope state by spaceId.
/// It manages an AsyncValue with list of TodoList and provides methods for CRUD operations.
///
/// Usage:
/// ```dart
/// // Watch the controller
/// final todoListsAsync = ref.watch(todoListsControllerProvider(spaceId));
///
/// // Call methods
/// ref.read(todoListsControllerProvider(spaceId).notifier).createTodoList(todoList);
/// ```

@ProviderFor(TodoListsController)
const todoListsControllerProvider = TodoListsControllerFamily._();

/// Controller for managing todo lists within a space
///
/// This controller uses family pattern to scope state by spaceId.
/// It manages an AsyncValue with list of TodoList and provides methods for CRUD operations.
///
/// Usage:
/// ```dart
/// // Watch the controller
/// final todoListsAsync = ref.watch(todoListsControllerProvider(spaceId));
///
/// // Call methods
/// ref.read(todoListsControllerProvider(spaceId).notifier).createTodoList(todoList);
/// ```
final class TodoListsControllerProvider
    extends $AsyncNotifierProvider<TodoListsController, List<TodoList>> {
  /// Controller for managing todo lists within a space
  ///
  /// This controller uses family pattern to scope state by spaceId.
  /// It manages an AsyncValue with list of TodoList and provides methods for CRUD operations.
  ///
  /// Usage:
  /// ```dart
  /// // Watch the controller
  /// final todoListsAsync = ref.watch(todoListsControllerProvider(spaceId));
  ///
  /// // Call methods
  /// ref.read(todoListsControllerProvider(spaceId).notifier).createTodoList(todoList);
  /// ```
  const TodoListsControllerProvider._({
    required TodoListsControllerFamily super.from,
    required String super.argument,
  }) : super(
         retry: null,
         name: r'todoListsControllerProvider',
         isAutoDispose: true,
         dependencies: null,
         $allTransitiveDependencies: null,
       );

  @override
  String debugGetCreateSourceHash() => _$todoListsControllerHash();

  @override
  String toString() {
    return r'todoListsControllerProvider'
        ''
        '($argument)';
  }

  @$internal
  @override
  TodoListsController create() => TodoListsController();

  @override
  bool operator ==(Object other) {
    return other is TodoListsControllerProvider && other.argument == argument;
  }

  @override
  int get hashCode {
    return argument.hashCode;
  }
}

String _$todoListsControllerHash() =>
    r'341909fd06c659b6ab9ce59024af4d42e4ee0b5d';

/// Controller for managing todo lists within a space
///
/// This controller uses family pattern to scope state by spaceId.
/// It manages an AsyncValue with list of TodoList and provides methods for CRUD operations.
///
/// Usage:
/// ```dart
/// // Watch the controller
/// final todoListsAsync = ref.watch(todoListsControllerProvider(spaceId));
///
/// // Call methods
/// ref.read(todoListsControllerProvider(spaceId).notifier).createTodoList(todoList);
/// ```

final class TodoListsControllerFamily extends $Family
    with
        $ClassFamilyOverride<
          TodoListsController,
          AsyncValue<List<TodoList>>,
          List<TodoList>,
          FutureOr<List<TodoList>>,
          String
        > {
  const TodoListsControllerFamily._()
    : super(
        retry: null,
        name: r'todoListsControllerProvider',
        dependencies: null,
        $allTransitiveDependencies: null,
        isAutoDispose: true,
      );

  /// Controller for managing todo lists within a space
  ///
  /// This controller uses family pattern to scope state by spaceId.
  /// It manages an AsyncValue with list of TodoList and provides methods for CRUD operations.
  ///
  /// Usage:
  /// ```dart
  /// // Watch the controller
  /// final todoListsAsync = ref.watch(todoListsControllerProvider(spaceId));
  ///
  /// // Call methods
  /// ref.read(todoListsControllerProvider(spaceId).notifier).createTodoList(todoList);
  /// ```

  TodoListsControllerProvider call(String spaceId) =>
      TodoListsControllerProvider._(argument: spaceId, from: this);

  @override
  String toString() => r'todoListsControllerProvider';
}

/// Controller for managing todo lists within a space
///
/// This controller uses family pattern to scope state by spaceId.
/// It manages an AsyncValue with list of TodoList and provides methods for CRUD operations.
///
/// Usage:
/// ```dart
/// // Watch the controller
/// final todoListsAsync = ref.watch(todoListsControllerProvider(spaceId));
///
/// // Call methods
/// ref.read(todoListsControllerProvider(spaceId).notifier).createTodoList(todoList);
/// ```

abstract class _$TodoListsController extends $AsyncNotifier<List<TodoList>> {
  late final _$args = ref.$arg as String;
  String get spaceId => _$args;

  FutureOr<List<TodoList>> build(String spaceId);
  @$mustCallSuper
  @override
  void runBuild() {
    final created = build(_$args);
    final ref = this.ref as $Ref<AsyncValue<List<TodoList>>, List<TodoList>>;
    final element =
        ref.element
            as $ClassProviderElement<
              AnyNotifier<AsyncValue<List<TodoList>>, List<TodoList>>,
              AsyncValue<List<TodoList>>,
              Object?,
              Object?
            >;
    element.handleValue(ref, created);
  }
}
