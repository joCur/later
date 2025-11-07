import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

/// Supabase configuration loaded from .env file
///
/// Credentials are loaded from .env file at app startup.
/// Different environments can use different .env files (.env, .env.production, etc.)
class SupabaseConfig {
  /// Initialize the Supabase client singleton
  ///
  /// Call this once at app startup before using any Supabase features.
  /// Loads configuration from .env file.
  ///
  /// The .env file should contain:
  /// ```
  /// SUPABASE_URL=your_supabase_url
  /// SUPABASE_ANON_KEY=your_anon_key
  /// ```
  ///
  /// Example usage in main.dart:
  /// ```dart
  /// await dotenv.load(fileName: '.env');
  /// await SupabaseConfig.initialize();
  /// ```
  static Future<void> initialize() async {
    final url = dotenv.env['SUPABASE_URL'];
    final anonKey = dotenv.env['SUPABASE_ANON_KEY'];

    if (url == null || url.isEmpty) {
      throw Exception(
        'SUPABASE_URL not found in .env file. '
        'Please ensure .env file exists and contains SUPABASE_URL.',
      );
    }

    if (anonKey == null || anonKey.isEmpty) {
      throw Exception(
        'SUPABASE_ANON_KEY not found in .env file. '
        'Please ensure .env file exists and contains SUPABASE_ANON_KEY.',
      );
    }

    // Auto-detect debug mode based on URL
    final isLocal = _isLocalEnvironment(url);

    await Supabase.initialize(url: url, anonKey: anonKey, debug: isLocal);
  }

  /// Check if URL points to local development environment
  static bool _isLocalEnvironment(String url) {
    return url.contains('localhost') ||
        url.contains('127.0.0.1') ||
        url.contains('0.0.0.0');
  }

  /// Get the singleton Supabase client instance
  /// Throws an error if initialize() hasn't been called
  static SupabaseClient get client => Supabase.instance.client;
}
