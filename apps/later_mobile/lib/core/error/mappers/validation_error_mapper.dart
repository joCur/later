import '../app_error.dart';
import '../error_codes.dart';

/// Maps validation errors to AppError with appropriate error codes.
///
/// This mapper provides a centralized way to create validation errors
/// with proper error codes and context data for message interpolation.
///
/// Usage:
/// ```dart
/// if (name.isEmpty) {
///   throw ValidationErrorMapper.requiredField('Name');
/// }
///
/// if (!emailRegex.hasMatch(email)) {
///   throw ValidationErrorMapper.invalidFormat('Email');
/// }
///
/// if (age < 18 || age > 120) {
///   throw ValidationErrorMapper.outOfRange('Age', '18', '120');
/// }
/// ```
class ValidationErrorMapper {
  /// Private constructor to prevent instantiation (static class)
  const ValidationErrorMapper._();

  /// Creates an AppError for a required field validation failure.
  ///
  /// Parameters:
  ///   - fieldName: The name of the field that is required (e.g., 'Email', 'Name')
  ///
  /// Returns:
  ///   An AppError with ErrorCode.validationRequired and field name in context
  ///
  /// Example:
  /// ```dart
  /// if (email.isEmpty) {
  ///   throw ValidationErrorMapper.requiredField('Email');
  /// }
  /// // User will see: "Email is required."
  /// ```
  static AppError requiredField(String fieldName) {
    return AppError(
      code: ErrorCode.validationRequired,
      message: 'Required field is missing: $fieldName',
      context: {'fieldName': fieldName},
    );
  }

  /// Creates an AppError for an invalid format validation failure.
  ///
  /// Parameters:
  ///   - fieldName: The name of the field with invalid format (e.g., 'Email', 'Phone number')
  ///
  /// Returns:
  ///   An AppError with ErrorCode.validationInvalidFormat and field name in context
  ///
  /// Example:
  /// ```dart
  /// if (!emailRegex.hasMatch(email)) {
  ///   throw ValidationErrorMapper.invalidFormat('Email');
  /// }
  /// // User will see: "Email has an invalid format."
  /// ```
  static AppError invalidFormat(String fieldName) {
    return AppError(
      code: ErrorCode.validationInvalidFormat,
      message: 'Invalid format for field: $fieldName',
      context: {'fieldName': fieldName},
    );
  }

  /// Creates an AppError for an out-of-range validation failure.
  ///
  /// Parameters:
  ///   - fieldName: The name of the field that is out of range (e.g., 'Age', 'Price')
  ///   - min: The minimum acceptable value (as string for flexibility)
  ///   - max: The maximum acceptable value (as string for flexibility)
  ///
  /// Returns:
  ///   An AppError with ErrorCode.validationOutOfRange and field name, min, max in context
  ///
  /// Example:
  /// ```dart
  /// if (age < 18 || age > 120) {
  ///   throw ValidationErrorMapper.outOfRange('Age', '18', '120');
  /// }
  /// // User will see: "Age must be between 18 and 120."
  /// ```
  static AppError outOfRange(String fieldName, String min, String max) {
    return AppError(
      code: ErrorCode.validationOutOfRange,
      message: 'Field $fieldName is out of range: must be between $min and $max',
      context: {
        'fieldName': fieldName,
        'min': min,
        'max': max,
      },
    );
  }

  /// Creates an AppError for a duplicate value validation failure.
  ///
  /// Parameters:
  ///   - fieldName: The name of the field with duplicate value (e.g., 'Username', 'Email')
  ///
  /// Returns:
  ///   An AppError with ErrorCode.validationDuplicate and field name in context
  ///
  /// Example:
  /// ```dart
  /// if (existingUsers.contains(username)) {
  ///   throw ValidationErrorMapper.duplicate('Username');
  /// }
  /// // User will see: "Username already exists."
  /// ```
  static AppError duplicate(String fieldName) {
    return AppError(
      code: ErrorCode.validationDuplicate,
      message: 'Duplicate value for field: $fieldName',
      context: {'fieldName': fieldName},
    );
  }
}
