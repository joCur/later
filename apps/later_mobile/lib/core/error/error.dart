/// Error handling module for the Later app.
///
/// This module provides:
/// - Centralized error code registry ([ErrorCode])
/// - Structured error class ([AppError])
/// - Domain-specific error mappers ([SupabaseErrorMapper], [ValidationErrorMapper])
/// - Error handling utilities ([ErrorHandler], [ErrorLogger])
///
/// Usage:
/// ```dart
/// import 'package:later_mobile/core/error/error.dart';
///
/// try {
///   await supabase.from('spaces').insert(data);
/// } on PostgrestException catch (e) {
///   throw SupabaseErrorMapper.fromPostgrestException(e);
/// }
/// ```
library;

export 'app_error.dart';
export 'error_codes.dart';
export 'error_handler.dart';
export 'error_logger.dart';
export 'mappers/supabase_error_mapper.dart';
export 'mappers/validation_error_mapper.dart';
