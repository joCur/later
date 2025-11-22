import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

/// Supabase configuration with dual-source support
///
/// Credentials can be provided via two methods:
/// 1. **CI/CD builds**: --dart-define flags (takes precedence)
/// 2. **Local development**: .env file (fallback)
///
/// This approach ensures:
/// - Secure credential injection in production builds
/// - Convenient .env file usage for local development
/// - No hardcoded credentials in the codebase
class SupabaseConfig {
  /// Compile-time environment variable from --dart-define flags
  /// Empty string if not provided during build
  static const String _dartDefineUrl = String.fromEnvironment('SUPABASE_URL');

  /// Compile-time environment variable from --dart-define flags
  /// Empty string if not provided during build
  static const String _dartDefineAnonKey =
      String.fromEnvironment('SUPABASE_ANON_KEY');

  /// Initialize the Supabase client singleton
  ///
  /// Call this once at app startup before using any Supabase features.
  ///
  /// Priority order:
  /// 1. --dart-define values (if provided during build)
  /// 2. .env file values (for local development)
  ///
  /// Example usage in main.dart:
  /// ```dart
  /// // Load .env for local development
  /// await dotenv.load(fileName: '.env');
  /// // Initialize Supabase (uses --dart-define if available, else .env)
  /// await SupabaseConfig.initialize();
  /// ```
  ///
  /// CI/CD build example:
  /// ```bash
  /// flutter build appbundle \
  ///   --dart-define=SUPABASE_URL=https://xxx.supabase.co \
  ///   --dart-define=SUPABASE_ANON_KEY=your_anon_key
  /// ```
  static Future<void> initialize() async {
    // Try --dart-define first (CI/CD), then fall back to .env (local dev)
    final url = _dartDefineUrl.isNotEmpty
        ? _dartDefineUrl
        : dotenv.env['SUPABASE_URL'];

    final anonKey = _dartDefineAnonKey.isNotEmpty
        ? _dartDefineAnonKey
        : dotenv.env['SUPABASE_ANON_KEY'];

    if (url == null || url.isEmpty) {
      throw Exception(
        'SUPABASE_URL not found. '
        'Provide via --dart-define=SUPABASE_URL=xxx or add to .env file.',
      );
    }

    if (anonKey == null || anonKey.isEmpty) {
      throw Exception(
        'SUPABASE_ANON_KEY not found. '
        'Provide via --dart-define=SUPABASE_ANON_KEY=xxx or add to .env file.',
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
