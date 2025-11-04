import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:later_mobile/core/config/supabase_config.dart';

/// Service for handling user authentication with Supabase
///
/// Provides methods for sign up, sign in, sign out, and session management.
/// All methods throw [AuthException] on error with user-friendly messages.
class AuthService {
  /// Get the Supabase client instance
  SupabaseClient get _supabase => SupabaseConfig.client;

  /// Sign up a new user with email and password
  ///
  /// Returns the [User] object on success.
  /// Throws [AuthException] with user-friendly error message on failure.
  ///
  /// Common error scenarios:
  /// - Email already registered
  /// - Weak password
  /// - Invalid email format
  /// - Network errors
  Future<User> signUpWithEmail({
    required String email,
    required String password,
  }) async {
    try {
      final response = await _supabase.auth.signUp(
        email: email,
        password: password,
      );

      if (response.user == null) {
        throw const AuthException('Sign up failed. Please try again.');
      }

      return response.user!;
    } on AuthException catch (e) {
      // Re-throw Supabase auth exceptions with user-friendly messages
      throw AuthException(_mapAuthError(e));
    } catch (e) {
      // Handle unexpected errors
      throw const AuthException('An unexpected error occurred. Please try again.');
    }
  }

  /// Sign in an existing user with email and password
  ///
  /// Returns the [User] object on success.
  /// Throws [AuthException] with user-friendly error message on failure.
  ///
  /// Common error scenarios:
  /// - Invalid credentials
  /// - Email not confirmed (if confirmation enabled)
  /// - Network errors
  Future<User> signInWithEmail({
    required String email,
    required String password,
  }) async {
    try {
      final response = await _supabase.auth.signInWithPassword(
        email: email,
        password: password,
      );

      if (response.user == null) {
        throw const AuthException('Sign in failed. Please check your credentials.');
      }

      return response.user!;
    } on AuthException catch (e) {
      // Re-throw Supabase auth exceptions with user-friendly messages
      throw AuthException(_mapAuthError(e));
    } catch (e) {
      // Handle unexpected errors
      throw const AuthException('An unexpected error occurred. Please try again.');
    }
  }

  /// Sign out the current user
  ///
  /// Clears the session and any cached authentication data.
  /// Throws [AuthException] on failure.
  Future<void> signOut() async {
    try {
      await _supabase.auth.signOut();
    } on AuthException catch (e) {
      throw AuthException(_mapAuthError(e));
    } catch (e) {
      throw const AuthException('Failed to sign out. Please try again.');
    }
  }

  /// Get the currently authenticated user
  ///
  /// Returns [User] if there is an active session, null otherwise.
  User? getCurrentUser() {
    return _supabase.auth.currentUser;
  }

  /// Stream of authentication state changes
  ///
  /// Emits [AuthState] events whenever the user's authentication state changes:
  /// - User signs in → emits AuthState with user
  /// - User signs out → emits AuthState with null user
  /// - Session expires → emits AuthState with null user
  /// - Session refreshed → emits AuthState with updated user
  Stream<AuthState> authStateChanges() {
    return _supabase.auth.onAuthStateChange;
  }

  /// Map Supabase auth errors to user-friendly messages
  ///
  /// Uses error codes from AuthException for reliable error handling.
  /// Returns the original error message for unknown error codes.
  String _mapAuthError(AuthException exception) {
    final code = exception.code;

    // Map known error codes to user-friendly messages
    switch (code) {
      // Invalid credentials
      case 'invalid_credentials':
      case 'invalid_grant':
      case 'user_not_found':
        return 'Invalid email or password. Please try again.';

      // Email already exists
      case 'user_already_exists':
      case 'email_exists':
        return 'This email is already registered. Please sign in instead.';

      // Weak password
      case 'weak_password':
      case 'password_too_short':
        return 'Password is too weak. Use at least 8 characters with a mix of letters and numbers.';

      // Invalid email format
      case 'invalid_email':
        return 'Please enter a valid email address.';

      // Email not confirmed
      case 'email_not_confirmed':
        return 'Please confirm your email address before signing in.';

      // Network errors
      case 'network_error':
      case 'timeout':
        return 'Network error. Please check your connection and try again.';

      // Rate limiting
      case 'over_request_rate_limit':
        return 'Too many attempts. Please try again later.';

      // Unknown error code - return original message
      default:
        return exception.message;
    }
  }
}
