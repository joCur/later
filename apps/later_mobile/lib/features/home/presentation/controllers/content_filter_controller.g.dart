// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'content_filter_controller.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning
/// Controller for managing content filtering and search on the home screen

@ProviderFor(ContentFilterController)
const contentFilterControllerProvider = ContentFilterControllerProvider._();

/// Controller for managing content filtering and search on the home screen
final class ContentFilterControllerProvider
    extends $NotifierProvider<ContentFilterController, ContentFilter> {
  /// Controller for managing content filtering and search on the home screen
  const ContentFilterControllerProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'contentFilterControllerProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$contentFilterControllerHash();

  @$internal
  @override
  ContentFilterController create() => ContentFilterController();

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(ContentFilter value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<ContentFilter>(value),
    );
  }
}

String _$contentFilterControllerHash() =>
    r'17fa3f36fc3b16f2cba20ea34189f48a5df3b982';

/// Controller for managing content filtering and search on the home screen

abstract class _$ContentFilterController extends $Notifier<ContentFilter> {
  ContentFilter build();
  @$mustCallSuper
  @override
  void runBuild() {
    final created = build();
    final ref = this.ref as $Ref<ContentFilter, ContentFilter>;
    final element =
        ref.element
            as $ClassProviderElement<
              AnyNotifier<ContentFilter, ContentFilter>,
              ContentFilter,
              Object?,
              Object?
            >;
    element.handleValue(ref, created);
  }
}

/// Provider for checking if content is loading for a specific space
/// This is a separate provider so it can be watched and trigger rebuilds

@ProviderFor(contentIsLoading)
const contentIsLoadingProvider = ContentIsLoadingFamily._();

/// Provider for checking if content is loading for a specific space
/// This is a separate provider so it can be watched and trigger rebuilds

final class ContentIsLoadingProvider
    extends $FunctionalProvider<bool, bool, bool>
    with $Provider<bool> {
  /// Provider for checking if content is loading for a specific space
  /// This is a separate provider so it can be watched and trigger rebuilds
  const ContentIsLoadingProvider._({
    required ContentIsLoadingFamily super.from,
    required String super.argument,
  }) : super(
         retry: null,
         name: r'contentIsLoadingProvider',
         isAutoDispose: true,
         dependencies: null,
         $allTransitiveDependencies: null,
       );

  @override
  String debugGetCreateSourceHash() => _$contentIsLoadingHash();

  @override
  String toString() {
    return r'contentIsLoadingProvider'
        ''
        '($argument)';
  }

  @$internal
  @override
  $ProviderElement<bool> $createElement($ProviderPointer pointer) =>
      $ProviderElement(pointer);

  @override
  bool create(Ref ref) {
    final argument = this.argument as String;
    return contentIsLoading(ref, argument);
  }

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(bool value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<bool>(value),
    );
  }

  @override
  bool operator ==(Object other) {
    return other is ContentIsLoadingProvider && other.argument == argument;
  }

  @override
  int get hashCode {
    return argument.hashCode;
  }
}

String _$contentIsLoadingHash() => r'942020b5574664c4345463e6bad9cf1c41d8eeeb';

/// Provider for checking if content is loading for a specific space
/// This is a separate provider so it can be watched and trigger rebuilds

final class ContentIsLoadingFamily extends $Family
    with $FunctionalFamilyOverride<bool, String> {
  const ContentIsLoadingFamily._()
    : super(
        retry: null,
        name: r'contentIsLoadingProvider',
        dependencies: null,
        $allTransitiveDependencies: null,
        isAutoDispose: true,
      );

  /// Provider for checking if content is loading for a specific space
  /// This is a separate provider so it can be watched and trigger rebuilds

  ContentIsLoadingProvider call(String spaceId) =>
      ContentIsLoadingProvider._(argument: spaceId, from: this);

  @override
  String toString() => r'contentIsLoadingProvider';
}
