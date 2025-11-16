// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'providers.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning
/// Provider for theme service (singleton)
///
/// Provides access to theme business logic for loading and saving
/// theme preferences. This provider is kept alive for the app lifetime.

@ProviderFor(themeService)
const themeServiceProvider = ThemeServiceProvider._();

/// Provider for theme service (singleton)
///
/// Provides access to theme business logic for loading and saving
/// theme preferences. This provider is kept alive for the app lifetime.

final class ThemeServiceProvider
    extends $FunctionalProvider<ThemeService, ThemeService, ThemeService>
    with $Provider<ThemeService> {
  /// Provider for theme service (singleton)
  ///
  /// Provides access to theme business logic for loading and saving
  /// theme preferences. This provider is kept alive for the app lifetime.
  const ThemeServiceProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'themeServiceProvider',
        isAutoDispose: false,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$themeServiceHash();

  @$internal
  @override
  $ProviderElement<ThemeService> $createElement($ProviderPointer pointer) =>
      $ProviderElement(pointer);

  @override
  ThemeService create(Ref ref) {
    return themeService(ref);
  }

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(ThemeService value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<ThemeService>(value),
    );
  }
}

String _$themeServiceHash() => r'524510aa093b71e529fc474a408ae9d6a40e2561';
