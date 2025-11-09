import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:intl/intl.dart' as intl;

import 'app_localizations_en.dart';

// ignore_for_file: type=lint

/// Callers can lookup localized strings with an instance of AppLocalizations
/// returned by `AppLocalizations.of(context)`.
///
/// Applications need to include `AppLocalizations.delegate()` in their app's
/// `localizationDelegates` list, and the locales they support in the app's
/// `supportedLocales` list. For example:
///
/// ```dart
/// import 'l10n/app_localizations.dart';
///
/// return MaterialApp(
///   localizationsDelegates: AppLocalizations.localizationsDelegates,
///   supportedLocales: AppLocalizations.supportedLocales,
///   home: MyApplicationHome(),
/// );
/// ```
///
/// ## Update pubspec.yaml
///
/// Please make sure to update your pubspec.yaml to include the following
/// packages:
///
/// ```yaml
/// dependencies:
///   # Internationalization support.
///   flutter_localizations:
///     sdk: flutter
///   intl: any # Use the pinned version from flutter_localizations
///
///   # Rest of dependencies
/// ```
///
/// ## iOS Applications
///
/// iOS applications define key application metadata, including supported
/// locales, in an Info.plist file that is built into the application bundle.
/// To configure the locales supported by your app, you’ll need to edit this
/// file.
///
/// First, open your project’s ios/Runner.xcworkspace Xcode workspace file.
/// Then, in the Project Navigator, open the Info.plist file under the Runner
/// project’s Runner folder.
///
/// Next, select the Information Property List item, select Add Item from the
/// Editor menu, then select Localizations from the pop-up menu.
///
/// Select and expand the newly-created Localizations item then, for each
/// locale your application supports, add a new item and select the locale
/// you wish to add from the pop-up menu in the Value field. This list should
/// be consistent with the languages listed in the AppLocalizations.supportedLocales
/// property.
abstract class AppLocalizations {
  AppLocalizations(String locale)
    : localeName = intl.Intl.canonicalizedLocale(locale.toString());

  final String localeName;

  static AppLocalizations? of(BuildContext context) {
    return Localizations.of<AppLocalizations>(context, AppLocalizations);
  }

  static const LocalizationsDelegate<AppLocalizations> delegate =
      _AppLocalizationsDelegate();

  /// A list of this localizations delegate along with the default localizations
  /// delegates.
  ///
  /// Returns a list of localizations delegates containing this delegate along with
  /// GlobalMaterialLocalizations.delegate, GlobalCupertinoLocalizations.delegate,
  /// and GlobalWidgetsLocalizations.delegate.
  ///
  /// Additional delegates can be added by appending to this list in
  /// MaterialApp. This list does not have to be used at all if a custom list
  /// of delegates is preferred or required.
  static const List<LocalizationsDelegate<dynamic>> localizationsDelegates =
      <LocalizationsDelegate<dynamic>>[
        delegate,
        GlobalMaterialLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
      ];

  /// A list of this localizations delegate's supported locales.
  static const List<Locale> supportedLocales = <Locale>[Locale('en')];

  /// Error message shown when trying to create a duplicate record
  ///
  /// In en, this message translates to:
  /// **'A record with this value already exists.'**
  String get errorDatabaseUniqueConstraint;

  /// Error message for foreign key constraint violations
  ///
  /// In en, this message translates to:
  /// **'Cannot perform this operation because it would break data relationships.'**
  String get errorDatabaseForeignKeyViolation;

  /// Error message for NOT NULL constraint violations
  ///
  /// In en, this message translates to:
  /// **'Required data is missing. Please ensure all fields are filled.'**
  String get errorDatabaseNotNullViolation;

  /// Error message for database permission errors
  ///
  /// In en, this message translates to:
  /// **'You don\'t have permission to access this data.'**
  String get errorDatabasePermissionDenied;

  /// Error message for database query timeouts
  ///
  /// In en, this message translates to:
  /// **'The operation took too long. Please try again.'**
  String get errorDatabaseTimeout;

  /// Generic database error message
  ///
  /// In en, this message translates to:
  /// **'A database error occurred. Please try again.'**
  String get errorDatabaseGeneric;

  /// Error message for invalid login credentials
  ///
  /// In en, this message translates to:
  /// **'Invalid email or password. Please try again.'**
  String get errorAuthInvalidCredentials;

  /// Error message when trying to sign up with existing email
  ///
  /// In en, this message translates to:
  /// **'An account with this email already exists. Please sign in instead.'**
  String get errorAuthUserAlreadyExists;

  /// Error message for weak password
  ///
  /// In en, this message translates to:
  /// **'Password is too weak. Please use at least {minLength} characters.'**
  String errorAuthWeakPassword(String minLength);

  /// Error message for invalid email format
  ///
  /// In en, this message translates to:
  /// **'The email address is not valid. Please check and try again.'**
  String get errorAuthInvalidEmail;

  /// Error message when email is not confirmed
  ///
  /// In en, this message translates to:
  /// **'Please confirm your email address before signing in.'**
  String get errorAuthEmailNotConfirmed;

  /// Error message for expired authentication session
  ///
  /// In en, this message translates to:
  /// **'Your session has expired. Please sign in again.'**
  String get errorAuthSessionExpired;

  /// Error message for network errors during auth operations
  ///
  /// In en, this message translates to:
  /// **'Network error during authentication. Please check your connection and try again.'**
  String get errorAuthNetworkError;

  /// Error message when auth rate limit is exceeded
  ///
  /// In en, this message translates to:
  /// **'Too many attempts. Please wait a moment and try again.'**
  String get errorAuthRateLimitExceeded;

  /// Generic authentication error message
  ///
  /// In en, this message translates to:
  /// **'An authentication error occurred. Please try again.'**
  String get errorAuthGeneric;

  /// Error message for network timeouts
  ///
  /// In en, this message translates to:
  /// **'Connection timed out. Please check your internet connection and try again.'**
  String get errorNetworkTimeout;

  /// Error message when no internet connection is available
  ///
  /// In en, this message translates to:
  /// **'No internet connection. Please check your network and try again.'**
  String get errorNetworkNoConnection;

  /// Error message for server errors (5xx)
  ///
  /// In en, this message translates to:
  /// **'The server encountered an error. Please try again later.'**
  String get errorNetworkServerError;

  /// Error message for bad requests (4xx)
  ///
  /// In en, this message translates to:
  /// **'Invalid request. Please check your input and try again.'**
  String get errorNetworkBadRequest;

  /// Error message for 404 not found
  ///
  /// In en, this message translates to:
  /// **'The requested resource was not found.'**
  String get errorNetworkNotFound;

  /// Generic network error message
  ///
  /// In en, this message translates to:
  /// **'A network error occurred. Please try again.'**
  String get errorNetworkGeneric;

  /// Error message for required field validation
  ///
  /// In en, this message translates to:
  /// **'{fieldName} is required.'**
  String errorValidationRequired(String fieldName);

  /// Error message for invalid format validation
  ///
  /// In en, this message translates to:
  /// **'{fieldName} has an invalid format.'**
  String errorValidationInvalidFormat(String fieldName);

  /// Error message for out of range validation
  ///
  /// In en, this message translates to:
  /// **'{fieldName} must be between {min} and {max}.'**
  String errorValidationOutOfRange(String fieldName, String min, String max);

  /// Error message for duplicate value validation
  ///
  /// In en, this message translates to:
  /// **'{fieldName} already exists.'**
  String errorValidationDuplicate(String fieldName);

  /// Error message when a space is not found
  ///
  /// In en, this message translates to:
  /// **'The space you\'re looking for was not found.'**
  String get errorSpaceNotFound;

  /// Error message when a note is not found
  ///
  /// In en, this message translates to:
  /// **'The note you\'re looking for was not found.'**
  String get errorNoteNotFound;

  /// Error message for insufficient permissions
  ///
  /// In en, this message translates to:
  /// **'You don\'t have permission to perform this action.'**
  String get errorInsufficientPermissions;

  /// Error message for operations not allowed in current state
  ///
  /// In en, this message translates to:
  /// **'This operation is not allowed in the current state.'**
  String get errorOperationNotAllowed;

  /// Generic error message for unknown errors
  ///
  /// In en, this message translates to:
  /// **'An unexpected error occurred. Please try again.'**
  String get errorUnknownError;
}

class _AppLocalizationsDelegate
    extends LocalizationsDelegate<AppLocalizations> {
  const _AppLocalizationsDelegate();

  @override
  Future<AppLocalizations> load(Locale locale) {
    return SynchronousFuture<AppLocalizations>(lookupAppLocalizations(locale));
  }

  @override
  bool isSupported(Locale locale) =>
      <String>['en'].contains(locale.languageCode);

  @override
  bool shouldReload(_AppLocalizationsDelegate old) => false;
}

AppLocalizations lookupAppLocalizations(Locale locale) {
  // Lookup logic when only language code is specified.
  switch (locale.languageCode) {
    case 'en':
      return AppLocalizationsEn();
  }

  throw FlutterError(
    'AppLocalizations.delegate failed to load unsupported locale "$locale". This is likely '
    'an issue with the localizations generation tool. Please file an issue '
    'on GitHub with a reproducible sample app and the gen-l10n configuration '
    'that was used.',
  );
}
