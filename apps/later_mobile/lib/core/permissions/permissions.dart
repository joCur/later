/// Permissions module for managing user roles and feature access.
///
/// This module provides:
/// - [UserRole] enum for distinguishing anonymous vs authenticated users
/// - [PermissionService] for checking current user permissions
/// - Riverpod providers for accessing permission state throughout the app
library;

export 'user_role.dart';
export 'permission_service.dart';
