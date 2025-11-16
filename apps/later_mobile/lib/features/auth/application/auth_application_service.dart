import 'package:later_mobile/core/error/error.dart';
import 'package:later_mobile/features/auth/data/services/auth_service.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

/// Application service for authentication business logic
///
/// Coordinates authentication operations by:
/// - Validating user input before calling data layer
/// - Applying business rules (email format, password strength)
/// - Handling error mapping from data layer
/// - Managing authentication state transitions
///
/// This service sits in the application layer and orchestrates
/// calls to the data layer (AuthService) while applying business logic.
class AuthApplicationService {
  AuthApplicationService({required AuthService authService})
      : _authService = authService;

  final AuthService _authService;

  /// Sign up a new user with email and password
  ///
  /// Validates:
  /// - Email is not empty
  /// - Email format is valid
  /// - Password is not empty
  /// - Password meets minimum requirements
  ///
  /// Returns [User] on success.
  /// Throws [AppError] on validation failure or auth failure.
  Future<User> signUp({
    required String email,
    required String password,
  }) async {
    // Validate email
    if (email.trim().isEmpty) {
      throw ValidationErrorMapper.requiredField('Email');
    }

    if (!_isValidEmail(email)) {
      throw ValidationErrorMapper.invalidFormat('Email');
    }

    // Validate password
    if (password.isEmpty) {
      throw ValidationErrorMapper.requiredField('Password');
    }

    if (password.length < 6) {
      throw const AppError(
        code: ErrorCode.authWeakPassword,
        message: 'Password must be at least 6 characters long',
      );
    }

    // Call data layer (AuthService handles Supabase errors)
    return await _authService.signUpWithEmail(
      email: email.trim(),
      password: password,
    );
  }

  /// Sign in an existing user with email and password
  ///
  /// Validates:
  /// - Email is not empty
  /// - Password is not empty
  ///
  /// Returns [User] on success.
  /// Throws [AppError] on validation failure or auth failure.
  Future<User> signIn({
    required String email,
    required String password,
  }) async {
    // Validate email
    if (email.trim().isEmpty) {
      throw ValidationErrorMapper.requiredField('Email');
    }

    // Validate password
    if (password.isEmpty) {
      throw ValidationErrorMapper.requiredField('Password');
    }

    // Call data layer (AuthService handles Supabase errors)
    return await _authService.signInWithEmail(
      email: email.trim(),
      password: password,
    );
  }

  /// Sign out the current user
  ///
  /// Clears the current session and authentication state.
  /// Throws [AppError] on failure.
  Future<void> signOut() async {
    // No validation needed - just call data layer
    await _authService.signOut();
  }

  /// Check the current authentication status
  ///
  /// Returns the currently authenticated [User] if session is active,
  /// null otherwise.
  User? checkAuthStatus() {
    return _authService.getCurrentUser();
  }

  /// Get stream of authentication state changes
  ///
  /// Emits [AuthState] events whenever:
  /// - User signs in
  /// - User signs out
  /// - Session expires
  /// - Session is refreshed
  Stream<AuthState> authStateChanges() {
    return _authService.authStateChanges();
  }

  /// Validate email format using regex
  bool _isValidEmail(String email) {
    // Simple email validation regex
    // More comprehensive validation happens server-side
    final emailRegex = RegExp(
      r'^[a-zA-Z0-9._%+-]+@[a-zA-Z0-9.-]+\.[a-zA-Z]{2,}$',
    );
    return emailRegex.hasMatch(email.trim());
  }
}
