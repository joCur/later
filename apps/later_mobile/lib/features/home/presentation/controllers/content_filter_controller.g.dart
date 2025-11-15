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
    r'c6fe9e799379fa97db1ac073f25788019bfe6206';

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
