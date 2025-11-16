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

  /// Sign in anonymously
  ///
  /// Creates an anonymous user session allowing users to try the app
  /// without creating a permanent account.
  ///
  /// Returns the [User] object with `isAnonymous = true`.
  /// Throws [AppError] with [ErrorCode.authAnonymousSignInFailed] on failure.
  ///
  /// Anonymous users can later upgrade to a permanent account using
  /// [upgradeAnonymousUser] without losing any data.
  Future<User> signInAnonymously() async {
    try {
      final response = await _supabase.auth.signInAnonymously();

      if (response.user == null) {
        throw const AppError(
          code: ErrorCode.authAnonymousSignInFailed,
          message: 'Anonymous sign in failed. Please try again.',
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
        message: 'An unexpected error occurred during anonymous sign in: ${e.toString()}',
        technicalDetails: stackTrace.toString(),
      );
    }
  }

  /// Upgrade an anonymous user to a permanent account
  ///
  /// Converts the current anonymous user session to a permanent account
  /// by setting an email and password. All existing data is preserved
  /// as the user ID remains unchanged.
  ///
  /// Returns the [User] object with `isAnonymous = false`.
  /// Throws [AppError] on failure with one of these codes:
  /// - [ErrorCode.authSessionExpired] - No active session
  /// - [ErrorCode.authAlreadyAuthenticated] - User is already permanent
  /// - [ErrorCode.authUpgradeFailed] - Upgrade operation failed
  ///
  /// Note: Email verification is disabled for MVP, so both email and password
  /// are set in a single operation.
  Future<User> upgradeAnonymousUser({
    required String email,
    required String password,
  }) async {
    try {
      final currentUser = _supabase.auth.currentUser;

      if (currentUser == null) {
        throw const AppError(
          code: ErrorCode.authSessionExpired,
          message: 'No active session to upgrade.',
        );
      }

      if (!currentUser.isAnonymous) {
        throw const AppError(
          code: ErrorCode.authAlreadyAuthenticated,
          message: 'User is already authenticated.',
        );
      }

      final response = await _supabase.auth.updateUser(
        UserAttributes(
          email: email,
          password: password,
        ),
      );

      if (response.user == null) {
        throw const AppError(
          code: ErrorCode.authUpgradeFailed,
          message: 'Account upgrade failed. Please try again.',
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
        message: 'An unexpected error occurred during account upgrade: ${e.toString()}',
        technicalDetails: stackTrace.toString(),
      );
    }
  }

  /// Check if the current user is anonymous
  ///
  /// Returns true if there is an active anonymous session, false otherwise.
  /// Returns false if no user is signed in.
  bool get isCurrentUserAnonymous {
    final user = getCurrentUser();
    return user?.isAnonymous ?? false;
  }
}
