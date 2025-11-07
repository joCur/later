import 'package:supabase_flutter/supabase_flutter.dart';
import '../../core/config/supabase_config.dart';

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
  /// Throws an exception if no user is authenticated.
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
      throw Exception('No authenticated user found. User must be logged in.');
    }
    return user.id;
  }

  /// Execute a Supabase query with error handling
  ///
  /// Wraps query execution in try-catch and maps Supabase exceptions
  /// to user-friendly error messages.
  ///
  /// Parameters:
  ///   - [query]: The async query function to execute
  ///
  /// Returns:
  ///   The result of the query
  ///
  /// Throws:
  ///   Mapped exceptions with user-friendly error messages
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
      throw _handlePostgrestException(e);
    } on AuthException catch (e) {
      throw _handleAuthException(e);
    } catch (e) {
      throw Exception('Database operation failed: ${e.toString()}');
    }
  }

  /// Map Supabase Postgrest exceptions to user-friendly errors
  Exception _handlePostgrestException(PostgrestException e) {
    switch (e.code) {
      case '23505': // Unique constraint violation
        return Exception('A record with this ID already exists.');
      case '23503': // Foreign key violation
        return Exception('Cannot complete operation: related records exist.');
      case '23502': // Not null violation
        return Exception('Required field is missing.');
      case '42501': // Insufficient privileges (RLS policy violation)
        return Exception(
          'Access denied. You do not have permission to access this data.',
        );
      default:
        return Exception('Database error: ${e.message}');
    }
  }

  /// Map Supabase Auth exceptions to user-friendly errors
  Exception _handleAuthException(AuthException e) {
    return Exception('Authentication error: ${e.message}');
  }
}
