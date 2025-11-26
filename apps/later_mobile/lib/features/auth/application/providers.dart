// ignore_for_file: depend_on_referenced_packages
import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:later_mobile/features/auth/application/auth_application_service.dart';
import 'package:later_mobile/features/auth/data/services/providers.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

part 'providers.g.dart';

/// Provider for [AuthApplicationService] singleton
///
/// This service coordinates authentication business logic and depends
/// on the auth data service. Kept alive for the app lifetime.
@Riverpod(keepAlive: true)
AuthApplicationService authApplicationService(Ref ref) {
  final authService = ref.watch(authServiceProvider);
  return AuthApplicationService(authService: authService);
}

/// Stream provider for authentication state
///
/// Emits the current [User] when authenticated, null when unauthenticated.
/// This stream is used by go_router for reactive authentication-based routing.
///
/// The stream emits immediately with the current user state and then
/// on every auth state change (sign in, sign out, session refresh).
@Riverpod(keepAlive: true)
Stream<User?> authStream(Ref ref) {
  final authService = ref.watch(authApplicationServiceProvider);
  return authService.authStateChanges().map((authState) => authState.session?.user);
}
