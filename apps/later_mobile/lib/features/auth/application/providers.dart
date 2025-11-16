// ignore_for_file: depend_on_referenced_packages
import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:later_mobile/features/auth/application/auth_application_service.dart';
import 'package:later_mobile/features/auth/data/services/providers.dart';

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
