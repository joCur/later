// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'providers.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning
/// Provider for TodoListRepository (singleton)
///
/// This repository handles both TodoList and TodoItem operations.
/// Uses keepAlive to maintain repository instance across the app.

@ProviderFor(todoListRepository)
const todoListRepositoryProvider = TodoListRepositoryProvider._();

/// Provider for TodoListRepository (singleton)
///
/// This repository handles both TodoList and TodoItem operations.
/// Uses keepAlive to maintain repository instance across the app.

final class TodoListRepositoryProvider
    extends
        $FunctionalProvider<
          TodoListRepository,
          TodoListRepository,
          TodoListRepository
        >
    with $Provider<TodoListRepository> {
  /// Provider for TodoListRepository (singleton)
  ///
  /// This repository handles both TodoList and TodoItem operations.
  /// Uses keepAlive to maintain repository instance across the app.
  const TodoListRepositoryProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'todoListRepositoryProvider',
        isAutoDispose: false,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$todoListRepositoryHash();

  @$internal
  @override
  $ProviderElement<TodoListRepository> $createElement(
    $ProviderPointer pointer,
  ) => $ProviderElement(pointer);

  @override
  TodoListRepository create(Ref ref) {
    return todoListRepository(ref);
  }

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(TodoListRepository value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<TodoListRepository>(value),
    );
  }
}

String _$todoListRepositoryHash() =>
    r'1bfdd9e3dcdc36bb3cc58b07b561416b8df6b973';
