// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for English (`en`).
class AppLocalizationsEn extends AppLocalizations {
  AppLocalizationsEn([String locale = 'en']) : super(locale);

  @override
  String get errorDatabaseUniqueConstraint =>
      'A record with this value already exists.';

  @override
  String get errorDatabaseForeignKeyViolation =>
      'Cannot perform this operation because it would break data relationships.';

  @override
  String get errorDatabaseNotNullViolation =>
      'Required data is missing. Please ensure all fields are filled.';

  @override
  String get errorDatabasePermissionDenied =>
      'You don\'t have permission to access this data.';

  @override
  String get errorDatabaseTimeout =>
      'The operation took too long. Please try again.';

  @override
  String get errorDatabaseGeneric =>
      'A database error occurred. Please try again.';

  @override
  String get errorAuthInvalidCredentials =>
      'Invalid email or password. Please try again.';

  @override
  String get errorAuthUserAlreadyExists =>
      'An account with this email already exists. Please sign in instead.';

  @override
  String errorAuthWeakPassword(String minLength) {
    return 'Password is too weak. Please use at least $minLength characters.';
  }

  @override
  String get errorAuthInvalidEmail =>
      'The email address is not valid. Please check and try again.';

  @override
  String get errorAuthEmailNotConfirmed =>
      'Please confirm your email address before signing in.';

  @override
  String get errorAuthSessionExpired =>
      'Your session has expired. Please sign in again.';

  @override
  String get errorAuthNetworkError =>
      'Network error during authentication. Please check your connection and try again.';

  @override
  String get errorAuthRateLimitExceeded =>
      'Too many attempts. Please wait a moment and try again.';

  @override
  String get errorAuthGeneric =>
      'An authentication error occurred. Please try again.';

  @override
  String get errorNetworkTimeout =>
      'Connection timed out. Please check your internet connection and try again.';

  @override
  String get errorNetworkNoConnection =>
      'No internet connection. Please check your network and try again.';

  @override
  String get errorNetworkServerError =>
      'The server encountered an error. Please try again later.';

  @override
  String get errorNetworkBadRequest =>
      'Invalid request. Please check your input and try again.';

  @override
  String get errorNetworkNotFound => 'The requested resource was not found.';

  @override
  String get errorNetworkGeneric =>
      'A network error occurred. Please try again.';

  @override
  String errorValidationRequired(String fieldName) {
    return '$fieldName is required.';
  }

  @override
  String errorValidationInvalidFormat(String fieldName) {
    return '$fieldName has an invalid format.';
  }

  @override
  String errorValidationOutOfRange(String fieldName, String min, String max) {
    return '$fieldName must be between $min and $max.';
  }

  @override
  String errorValidationDuplicate(String fieldName) {
    return '$fieldName already exists.';
  }

  @override
  String get errorSpaceNotFound =>
      'The space you\'re looking for was not found.';

  @override
  String get errorNoteNotFound => 'The note you\'re looking for was not found.';

  @override
  String get errorInsufficientPermissions =>
      'You don\'t have permission to perform this action.';

  @override
  String get errorOperationNotAllowed =>
      'This operation is not allowed in the current state.';

  @override
  String get errorUnknownError =>
      'An unexpected error occurred. Please try again.';
}
