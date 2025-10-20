import 'package:flutter/foundation.dart';
import 'app_error.dart';

/// Utility class for logging errors throughout the application.
///
/// This class provides methods for logging errors with various details
/// and retrieving recent logs. It respects debug mode and filters
/// sensitive data from logs.
///
/// Example usage:
/// ```dart
/// ErrorLogger.logError(
///   AppError.storage(message: 'Failed to save'),
///   context: 'ItemsProvider.addItem',
/// );
/// ```
class ErrorLogger {
  ErrorLogger._();

  // In-memory storage for recent logs (only in debug mode)
  static final List<Map<String, dynamic>> _logs = [];
  static const int _maxLogs = 100;

  // Sensitive keys that should never be logged
  static const Set<String> _sensitiveKeys = {
    'password',
    'token',
    'apiKey',
    'api_key',
    'secret',
    'auth',
    'authorization',
    'credential',
    'key',
  };

  /// Logs an error with optional stack trace, context, and additional data.
  ///
  /// Parameters:
  ///   - [error]: The AppError to log
  ///   - [stackTrace]: Optional stack trace for the error
  ///   - [context]: Optional context string (e.g., 'ItemsProvider.loadItems')
  ///   - [additionalData]: Optional map of additional data to log (will be sanitized)
  static void logError(
    AppError error, {
    StackTrace? stackTrace,
    String? context,
    Map<String, dynamic>? additionalData,
  }) {
    // Only log in debug mode
    if (!kDebugMode) {
      return;
    }

    // Format the log message
    final timestamp = DateTime.now().toIso8601String();
    final buffer = StringBuffer();

    buffer.writeln('[$timestamp] ERROR: ${error.type.name}');
    buffer.writeln('Message: ${error.message}');

    if (context != null) {
      buffer.writeln('Context: $context');
    }

    if (error.technicalDetails != null) {
      buffer.writeln('Details: ${error.technicalDetails}');
    }

    if (additionalData != null) {
      final sanitized = _sanitizeData(additionalData);
      if (sanitized.isNotEmpty) {
        buffer.writeln('Additional Data: $sanitized');
      }
    }

    if (stackTrace != null) {
      buffer.writeln('Stack Trace:');
      buffer.writeln(stackTrace.toString());
    }

    // Print to debug console
    debugPrint(buffer.toString());

    // Store in memory for retrieval (debug mode only)
    _storeLogs(
      timestamp: timestamp,
      type: error.type.name,
      message: error.message,
      context: context,
      technicalDetails: error.technicalDetails,
      hasStackTrace: stackTrace != null,
      additionalData: additionalData != null ? _sanitizeData(additionalData) : null,
    );
  }

  /// Logs an exception with optional stack trace and context.
  ///
  /// This is a convenience method that converts an exception to an AppError
  /// and logs it.
  static void logException(
    Object exception, {
    StackTrace? stackTrace,
    String? context,
  }) {
    final appError = AppError.fromException(exception);
    logError(
      appError,
      stackTrace: stackTrace,
      context: context,
    );
  }

  /// Formats an AppError into a readable string.
  static String formatError(AppError error) {
    final buffer = StringBuffer();
    buffer.write('${error.type.name}: ${error.message}');

    if (error.technicalDetails != null) {
      buffer.write(' (${error.technicalDetails})');
    }

    return buffer.toString();
  }

  /// Retrieves recent error logs.
  ///
  /// Parameters:
  ///   - [limit]: Maximum number of logs to return (default: 50)
  ///
  /// Returns a list of log entries with the most recent first.
  static List<Map<String, dynamic>> getRecentLogs({int limit = 50}) {
    if (!kDebugMode) {
      return [];
    }

    final logsToReturn = _logs.length > limit ? _logs.sublist(0, limit) : _logs;
    return List.unmodifiable(logsToReturn);
  }

  /// Clears all stored logs.
  static void clearLogs() {
    _logs.clear();
  }

  /// Stores a log entry in memory.
  static void _storeLogs({
    required String timestamp,
    required String type,
    required String message,
    String? context,
    String? technicalDetails,
    bool hasStackTrace = false,
    Map<String, dynamic>? additionalData,
  }) {
    // Only store in debug mode
    if (!kDebugMode) {
      return;
    }

    // Add to the beginning of the list (most recent first)
    _logs.insert(0, {
      'timestamp': timestamp,
      'type': type,
      'message': message,
      if (context != null) 'context': context,
      if (technicalDetails != null) 'technicalDetails': technicalDetails,
      'hasStackTrace': hasStackTrace,
      if (additionalData != null) 'additionalData': additionalData,
    });

    // Trim logs if we exceed the maximum
    if (_logs.length > _maxLogs) {
      _logs.removeRange(_maxLogs, _logs.length);
    }
  }

  /// Sanitizes data by removing sensitive keys.
  ///
  /// Returns a new map with sensitive keys removed or redacted.
  static Map<String, dynamic> _sanitizeData(Map<String, dynamic> data) {
    final sanitized = <String, dynamic>{};

    for (final entry in data.entries) {
      final key = entry.key.toLowerCase();

      // Check if the key contains any sensitive keywords
      final isSensitive = _sensitiveKeys.any((sensitiveKey) => key.contains(sensitiveKey));

      if (isSensitive) {
        // Skip sensitive data entirely
        continue;
      } else {
        // Include non-sensitive data
        sanitized[entry.key] = entry.value;
      }
    }

    return sanitized;
  }
}
