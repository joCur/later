// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'providers.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning
/// Provider for TodoListService (singleton)
///
/// This service handles business logic for todo lists and items.
/// Uses keepAlive to maintain service instance across the app.

@ProviderFor(todoListService)
const todoListServiceProvider = TodoListServiceProvider._();

/// Provider for TodoListService (singleton)
///
/// This service handles business logic for todo lists and items.
/// Uses keepAlive to maintain service instance across the app.

final class TodoListServiceProvider
    extends
        $FunctionalProvider<TodoListService, TodoListService, TodoListService>
    with $Provider<TodoListService> {
  /// Provider for TodoListService (singleton)
  ///
  /// This service handles business logic for todo lists and items.
  /// Uses keepAlive to maintain service instance across the app.
  const TodoListServiceProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'todoListServiceProvider',
        isAutoDispose: false,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$todoListServiceHash();

  @$internal
  @override
  $ProviderElement<TodoListService> $createElement($ProviderPointer pointer) =>
      $ProviderElement(pointer);

  @override
  TodoListService create(Ref ref) {
    return todoListService(ref);
  }

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(TodoListService value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<TodoListService>(value),
    );
  }
}

String _$todoListServiceHash() => r'cdefab21c481ceb258a682e7a23375c752c99563';

/// Provider for fetching a single TodoList by ID
///
/// This is a family provider that creates a separate provider instance
/// for each todoListId. Auto-disposes when no longer watched.
///
/// Returns null if the todo list is not found or user doesn't have access.

@ProviderFor(todoListById)
const todoListByIdProvider = TodoListByIdFamily._();

/// Provider for fetching a single TodoList by ID
///
/// This is a family provider that creates a separate provider instance
/// for each todoListId. Auto-disposes when no longer watched.
///
/// Returns null if the todo list is not found or user doesn't have access.

final class TodoListByIdProvider
    extends
        $FunctionalProvider<
          AsyncValue<TodoList?>,
          TodoList?,
          FutureOr<TodoList?>
        >
    with $FutureModifier<TodoList?>, $FutureProvider<TodoList?> {
  /// Provider for fetching a single TodoList by ID
  ///
  /// This is a family provider that creates a separate provider instance
  /// for each todoListId. Auto-disposes when no longer watched.
  ///
  /// Returns null if the todo list is not found or user doesn't have access.
  const TodoListByIdProvider._({
    required TodoListByIdFamily super.from,
    required String super.argument,
  }) : super(
         retry: null,
         name: r'todoListByIdProvider',
         isAutoDispose: true,
         dependencies: null,
         $allTransitiveDependencies: null,
       );

  @override
  String debugGetCreateSourceHash() => _$todoListByIdHash();

  @override
  String toString() {
    return r'todoListByIdProvider'
        ''
        '($argument)';
  }

  @$internal
  @override
  $FutureProviderElement<TodoList?> $createElement($ProviderPointer pointer) =>
      $FutureProviderElement(pointer);

  @override
  FutureOr<TodoList?> create(Ref ref) {
    final argument = this.argument as String;
    return todoListById(ref, argument);
  }

  @override
  bool operator ==(Object other) {
    return other is TodoListByIdProvider && other.argument == argument;
  }

  @override
  int get hashCode {
    return argument.hashCode;
  }
}

String _$todoListByIdHash() => r'f96c6c36c6a2edd8443833785106447e3f3ac225';

/// Provider for fetching a single TodoList by ID
///
/// This is a family provider that creates a separate provider instance
/// for each todoListId. Auto-disposes when no longer watched.
///
/// Returns null if the todo list is not found or user doesn't have access.

final class TodoListByIdFamily extends $Family
    with $FunctionalFamilyOverride<FutureOr<TodoList?>, String> {
  const TodoListByIdFamily._()
    : super(
        retry: null,
        name: r'todoListByIdProvider',
        dependencies: null,
        $allTransitiveDependencies: null,
        isAutoDispose: true,
      );

  /// Provider for fetching a single TodoList by ID
  ///
  /// This is a family provider that creates a separate provider instance
  /// for each todoListId. Auto-disposes when no longer watched.
  ///
  /// Returns null if the todo list is not found or user doesn't have access.

  TodoListByIdProvider call(String todoListId) =>
      TodoListByIdProvider._(argument: todoListId, from: this);

  @override
  String toString() => r'todoListByIdProvider';
}
