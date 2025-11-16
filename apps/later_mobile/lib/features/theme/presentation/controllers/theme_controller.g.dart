// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'theme_controller.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning
/// Theme controller managing application theme state with Riverpod 3.0
///
/// Manages theme mode (light, dark, system) with:
/// - Persistent storage via ThemeService
/// - Smooth animated transitions with transition state tracking
/// - Toggle between light/dark modes (skipping system)
/// - Ref.mounted checks for safe async state updates
///
/// Example usage:
/// ```dart
/// // Watch theme state
/// final themeMode = ref.watch(themeControllerProvider);
///
/// // Toggle theme
/// ref.read(themeControllerProvider.notifier).toggleTheme();
///
/// // Set specific mode
/// ref.read(themeControllerProvider.notifier).setThemeMode(ThemeMode.dark);
/// ```

@ProviderFor(ThemeController)
const themeControllerProvider = ThemeControllerProvider._();

/// Theme controller managing application theme state with Riverpod 3.0
///
/// Manages theme mode (light, dark, system) with:
/// - Persistent storage via ThemeService
/// - Smooth animated transitions with transition state tracking
/// - Toggle between light/dark modes (skipping system)
/// - Ref.mounted checks for safe async state updates
///
/// Example usage:
/// ```dart
/// // Watch theme state
/// final themeMode = ref.watch(themeControllerProvider);
///
/// // Toggle theme
/// ref.read(themeControllerProvider.notifier).toggleTheme();
///
/// // Set specific mode
/// ref.read(themeControllerProvider.notifier).setThemeMode(ThemeMode.dark);
/// ```
final class ThemeControllerProvider
    extends $NotifierProvider<ThemeController, ThemeMode> {
  /// Theme controller managing application theme state with Riverpod 3.0
  ///
  /// Manages theme mode (light, dark, system) with:
  /// - Persistent storage via ThemeService
  /// - Smooth animated transitions with transition state tracking
  /// - Toggle between light/dark modes (skipping system)
  /// - Ref.mounted checks for safe async state updates
  ///
  /// Example usage:
  /// ```dart
  /// // Watch theme state
  /// final themeMode = ref.watch(themeControllerProvider);
  ///
  /// // Toggle theme
  /// ref.read(themeControllerProvider.notifier).toggleTheme();
  ///
  /// // Set specific mode
  /// ref.read(themeControllerProvider.notifier).setThemeMode(ThemeMode.dark);
  /// ```
  const ThemeControllerProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'themeControllerProvider',
        isAutoDispose: false,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$themeControllerHash();

  @$internal
  @override
  ThemeController create() => ThemeController();

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(ThemeMode value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<ThemeMode>(value),
    );
  }
}

String _$themeControllerHash() => r'283aa689f1952db29e964653be3c56c5a3b106fc';

/// Theme controller managing application theme state with Riverpod 3.0
///
/// Manages theme mode (light, dark, system) with:
/// - Persistent storage via ThemeService
/// - Smooth animated transitions with transition state tracking
/// - Toggle between light/dark modes (skipping system)
/// - Ref.mounted checks for safe async state updates
///
/// Example usage:
/// ```dart
/// // Watch theme state
/// final themeMode = ref.watch(themeControllerProvider);
///
/// // Toggle theme
/// ref.read(themeControllerProvider.notifier).toggleTheme();
///
/// // Set specific mode
/// ref.read(themeControllerProvider.notifier).setThemeMode(ThemeMode.dark);
/// ```

abstract class _$ThemeController extends $Notifier<ThemeMode> {
  ThemeMode build();
  @$mustCallSuper
  @override
  void runBuild() {
    final created = build();
    final ref = this.ref as $Ref<ThemeMode, ThemeMode>;
    final element =
        ref.element
            as $ClassProviderElement<
              AnyNotifier<ThemeMode, ThemeMode>,
              ThemeMode,
              Object?,
              Object?
            >;
    element.handleValue(ref, created);
  }
}
