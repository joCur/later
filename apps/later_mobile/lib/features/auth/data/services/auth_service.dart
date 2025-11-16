import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:later_mobile/core/config/supabase_config.dart';
import 'package:later_mobile/core/error/error.dart';

/// Service for handling user authentication with Supabase
///
/// Provides methods for sign up, sign in, sign out, and session management.
/// All methods throw [AppError] on error with proper error codes.
class AuthService {
  /// Get the Supabase client instance
  SupabaseClient get _supabase => SupabaseConfig.client;

  /// Sign up a new user with email and password
  ///
  /// Returns the [User] object on success.
  /// Throws [AppError] with appropriate error code on failure.
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
        throw const AppError(
          code: ErrorCode.authGeneric,
          message: 'Sign up failed. Please try again.',
        );
      }

      return response.user!;
    } on AuthException catch (e) {
      throw SupabaseErrorMapper.fromAuthException(e);
    } on AppError {
      rethrow;
    } catch (e, stackTrace) {
      throw AppError(
        code: ErrorCode.unknownError,
        message: 'An unexpected error occurred during sign up: ${e.toString()}',
        technicalDetails: stackTrace.toString(),
      );
    }
  }

  /// Sign in an existing user with email and password
  ///
  /// Returns the [User] object on success.
  /// Throws [AppError] with appropriate error code on failure.
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
        throw const AppError(
          code: ErrorCode.authInvalidCredentials,
          message: 'Sign in failed. Please check your credentials.',
        );
      }

      return response.user!;
    } on AuthException catch (e) {
      throw SupabaseErrorMapper.fromAuthException(e);
    } on AppError {
      rethrow;
    } catch (e, stackTrace) {
      throw AppError(
        code: ErrorCode.unknownError,
        message: 'An unexpected error occurred during sign in: ${e.toString()}',
        technicalDetails: stackTrace.toString(),
      );
    }
  }

  /// Sign out the current user
  ///
  /// Clears the session and any cached authentication data.
  /// Throws [AppError] on failure.
  Future<void> signOut() async {
    try {
      await _supabase.auth.signOut();
    } on AuthException catch (e) {
      throw SupabaseErrorMapper.fromAuthException(e);
    } on AppError {
      rethrow;
    } catch (e, stackTrace) {
      throw AppError(
        code: ErrorCode.authGeneric,
        message: 'Failed to sign out: ${e.toString()}',
        technicalDetails: stackTrace.toString(),
      );
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
}
