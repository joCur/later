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
