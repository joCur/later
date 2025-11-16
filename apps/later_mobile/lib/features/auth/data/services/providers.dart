// ignore_for_file: depend_on_referenced_packages
import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'auth_service.dart';

part 'providers.g.dart';

/// Provider for [AuthService] singleton
///
/// Keep alive to maintain the service instance throughout the app lifecycle.
/// The AuthService is lightweight and handles Supabase auth operations.
@Riverpod(keepAlive: true)
AuthService authService(Ref ref) {
  return AuthService();
}
