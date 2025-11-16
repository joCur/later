// ignore_for_file: depend_on_referenced_packages
import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'theme_service.dart';

part 'providers.g.dart';

/// Provider for theme service (singleton)
///
/// Provides access to theme business logic for loading and saving
/// theme preferences. This provider is kept alive for the app lifetime.
@Riverpod(keepAlive: true)
ThemeService themeService(Ref ref) {
  return ThemeService();
}
