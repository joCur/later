import 'package:supabase_flutter/supabase_flutter.dart';
import '../../core/config/supabase_config.dart';
import '../../core/error/error.dart';

/// Base repository providing common functionality for Supabase repositories
///
/// All repositories should extend this class to inherit:
/// - Supabase client access via singleton
/// - User ID retrieval from authenticated session
/// - Error handling utilities
/// - Query execution with consistent error handling
///
/// Usage:
/// ```dart
/// final repo = SpaceRepository();
/// ```
abstract class BaseRepository {
  /// Get the Supabase client singleton
  SupabaseClient get supabase => SupabaseConfig.client;

  /// Get the current authenticated user's ID
  ///
  /// Throws [AppError] with [ErrorCode.authSessionExpired] if no user is authenticated.
  ///
  /// Example:
  /// ```dart
  /// final spaces = await supabase
  ///   .from('spaces')
  ///   .select()
  ///   .eq('user_id', userId);
  /// ```
  String get userId {
    final user = supabase.auth.currentUser;
    if (user == null) {
      throw const AppError(
        code: ErrorCode.authSessionExpired,
        message: 'No authenticated user found. User must be logged in.',
      );
    }
    return user.id;
  }

  /// Execute a Supabase query with error handling
  ///
  /// Wraps query execution in try-catch and maps Supabase exceptions
  /// to AppError with proper error codes.
  ///
  /// Parameters:
  ///   - [query]: The async query function to execute
  ///
  /// Returns:
  ///   The result of the query
  ///
  /// Throws:
  ///   [AppError] with appropriate error code
  ///
  /// Example:
  /// ```dart
  /// final result = await executeQuery<List<Map<String, dynamic>>>(() async {
  ///   return await supabase.from('spaces').select();
  /// });
  /// ```
  Future<T> executeQuery<T>(Future<T> Function() query) async {
    try {
      return await query();
    } on PostgrestException catch (e) {
      throw SupabaseErrorMapper.fromPostgrestException(e);
    } on AuthException catch (e) {
      throw SupabaseErrorMapper.fromAuthException(e);
    } on AppError {
      // Re-throw AppError without modification (already mapped)
      rethrow;
    } catch (e, stackTrace) {
      // Wrap unexpected errors in AppError with unknownError code
      ErrorLogger.logError(
        AppError(
          code: ErrorCode.unknownError,
          message: 'Unexpected database operation error: ${e.toString()}',
          technicalDetails: stackTrace.toString(),
        ),
      );
      throw AppError(
        code: ErrorCode.unknownError,
        message: 'Unexpected database operation error: ${e.toString()}',
        technicalDetails: stackTrace.toString(),
      );
    }
  }
}
