import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:intl/intl.dart' as intl;

import 'app_localizations_de.dart';
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
  static const List<Locale> supportedLocales = <Locale>[
    Locale('de'),
    Locale('en'),
  ];

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

  /// Error message when anonymous sign-in fails
  ///
  /// In en, this message translates to:
  /// **'Could not start trial. Please try again.'**
  String get errorAuthAnonymousSignInFailed;

  /// Error message when upgrading anonymous account to permanent fails
  ///
  /// In en, this message translates to:
  /// **'Could not create account. Please try again.'**
  String get errorAuthUpgradeFailed;

  /// Error message when trying to perform anonymous-only operation with authenticated account
  ///
  /// In en, this message translates to:
  /// **'You already have an account.'**
  String get errorAuthAlreadyAuthenticated;

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

  /// Title for sign in screen
  ///
  /// In en, this message translates to:
  /// **'Welcome Back'**
  String get authTitleSignIn;

  /// Title for sign up screen
  ///
  /// In en, this message translates to:
  /// **'Create Account'**
  String get authTitleSignUp;

  /// Label for email input field
  ///
  /// In en, this message translates to:
  /// **'Email'**
  String get authLabelEmail;

  /// Hint text for email input field
  ///
  /// In en, this message translates to:
  /// **'your@email.com'**
  String get authHintEmail;

  /// Label for password input field
  ///
  /// In en, this message translates to:
  /// **'Password'**
  String get authLabelPassword;

  /// Hint text for password input field
  ///
  /// In en, this message translates to:
  /// **'••••••••'**
  String get authHintPassword;

  /// Label for confirm password input field
  ///
  /// In en, this message translates to:
  /// **'Confirm Password'**
  String get authLabelConfirmPassword;

  /// Validation message when email field is empty
  ///
  /// In en, this message translates to:
  /// **'Please enter your email'**
  String get authValidationEmailRequired;

  /// Validation message when email format is invalid
  ///
  /// In en, this message translates to:
  /// **'Please enter a valid email'**
  String get authValidationEmailInvalid;

  /// Validation message when password field is empty on sign in
  ///
  /// In en, this message translates to:
  /// **'Please enter your password'**
  String get authValidationPasswordRequired;

  /// Validation message when password field is empty on sign up
  ///
  /// In en, this message translates to:
  /// **'Please enter a password'**
  String get authValidationPasswordRequiredSignUp;

  /// Validation message when password is too short
  ///
  /// In en, this message translates to:
  /// **'Password must be at least 8 characters'**
  String get authValidationPasswordMinLength;

  /// Validation message when confirm password field is empty
  ///
  /// In en, this message translates to:
  /// **'Please confirm your password'**
  String get authValidationConfirmPasswordRequired;

  /// Validation message when password and confirm password do not match
  ///
  /// In en, this message translates to:
  /// **'Passwords do not match'**
  String get authValidationPasswordsDoNotMatch;

  /// Sign in button text
  ///
  /// In en, this message translates to:
  /// **'Sign In'**
  String get authButtonSignIn;

  /// Sign up button text
  ///
  /// In en, this message translates to:
  /// **'Sign Up'**
  String get authButtonSignUp;

  /// Button text to skip authentication and continue as anonymous user
  ///
  /// In en, this message translates to:
  /// **'Continue without account'**
  String get authButtonContinueWithoutAccount;

  /// Link text to navigate to sign up screen
  ///
  /// In en, this message translates to:
  /// **'Sign up'**
  String get authLinkSignUp;

  /// Link text to navigate to sign in screen
  ///
  /// In en, this message translates to:
  /// **'Sign in'**
  String get authLinkSignIn;

  /// Text asking if user doesn't have an account
  ///
  /// In en, this message translates to:
  /// **'Don\'t have an account? '**
  String get authTextNoAccount;

  /// Text asking if user already has an account
  ///
  /// In en, this message translates to:
  /// **'Already have an account? '**
  String get authTextHaveAccount;

  /// Label for weak password strength
  ///
  /// In en, this message translates to:
  /// **'Weak'**
  String get authPasswordStrengthWeak;

  /// Label for medium password strength
  ///
  /// In en, this message translates to:
  /// **'Medium'**
  String get authPasswordStrengthMedium;

  /// Label for strong password strength
  ///
  /// In en, this message translates to:
  /// **'Strong'**
  String get authPasswordStrengthStrong;

  /// Helper text for password strength requirements
  ///
  /// In en, this message translates to:
  /// **'Use 8+ characters'**
  String get authPasswordStrengthHelper;

  /// Accessibility label for password strength indicator
  ///
  /// In en, this message translates to:
  /// **'Password strength'**
  String get authAccessibilityPasswordStrength;

  /// Title for welcome empty state
  ///
  /// In en, this message translates to:
  /// **'Welcome to later'**
  String get emptyWelcomeTitle;

  /// Message for welcome empty state
  ///
  /// In en, this message translates to:
  /// **'Your peaceful place for thoughts, tasks, and everything in between'**
  String get emptyWelcomeMessage;

  /// Action button text for welcome empty state
  ///
  /// In en, this message translates to:
  /// **'Create your first item'**
  String get emptyWelcomeAction;

  /// Secondary action button text for welcome empty state
  ///
  /// In en, this message translates to:
  /// **'Learn how it works'**
  String get emptyWelcomeSecondaryAction;

  /// Title for no spaces empty state
  ///
  /// In en, this message translates to:
  /// **'Welcome to Later'**
  String get emptyNoSpacesTitle;

  /// Message for no spaces empty state
  ///
  /// In en, this message translates to:
  /// **'Spaces organize your tasks, notes, and lists by context. Let\'s create your first one!'**
  String get emptyNoSpacesMessage;

  /// Action button text for no spaces empty state
  ///
  /// In en, this message translates to:
  /// **'Create Your First Space'**
  String get emptyNoSpacesAction;

  /// Secondary action button text for no spaces empty state
  ///
  /// In en, this message translates to:
  /// **'Learn more'**
  String get emptyNoSpacesSecondaryAction;

  /// Title for empty space state with space name
  ///
  /// In en, this message translates to:
  /// **'Your {spaceName} is empty'**
  String emptySpaceTitle(String spaceName);

  /// Message for empty space state
  ///
  /// In en, this message translates to:
  /// **'Start capturing your thoughts, tasks, and ideas'**
  String get emptySpaceMessage;

  /// Action button text for empty space state
  ///
  /// In en, this message translates to:
  /// **'Create'**
  String get emptySpaceAction;

  /// Bottom navigation label for home tab
  ///
  /// In en, this message translates to:
  /// **'Home'**
  String get navigationHome;

  /// Tooltip for home navigation button
  ///
  /// In en, this message translates to:
  /// **'View your spaces'**
  String get navigationHomeTooltip;

  /// Semantic label for home navigation (screen readers)
  ///
  /// In en, this message translates to:
  /// **'Home navigation'**
  String get navigationHomeSemanticLabel;

  /// Bottom navigation label for search tab
  ///
  /// In en, this message translates to:
  /// **'Search'**
  String get navigationSearch;

  /// Tooltip for search navigation button
  ///
  /// In en, this message translates to:
  /// **'Search items'**
  String get navigationSearchTooltip;

  /// Semantic label for search navigation (screen readers)
  ///
  /// In en, this message translates to:
  /// **'Search navigation'**
  String get navigationSearchSemanticLabel;

  /// Bottom navigation label and sidebar label for settings
  ///
  /// In en, this message translates to:
  /// **'Settings'**
  String get navigationSettings;

  /// Tooltip for settings navigation button
  ///
  /// In en, this message translates to:
  /// **'App settings'**
  String get navigationSettingsTooltip;

  /// Semantic label for settings navigation (screen readers)
  ///
  /// In en, this message translates to:
  /// **'Settings navigation'**
  String get navigationSettingsSemanticLabel;

  /// Header text for spaces section in sidebar
  ///
  /// In en, this message translates to:
  /// **'Spaces'**
  String get sidebarSpaces;

  /// Tooltip for collapse sidebar button
  ///
  /// In en, this message translates to:
  /// **'Collapse sidebar'**
  String get sidebarCollapse;

  /// Tooltip for expand sidebar button
  ///
  /// In en, this message translates to:
  /// **'Expand sidebar'**
  String get sidebarExpand;

  /// Sign out button text in sidebar
  ///
  /// In en, this message translates to:
  /// **'Sign Out'**
  String get sidebarSignOut;

  /// Message shown in sidebar when user has no spaces
  ///
  /// In en, this message translates to:
  /// **'No spaces yet'**
  String get sidebarNoSpaces;

  /// Filter chip label for showing all content types
  ///
  /// In en, this message translates to:
  /// **'All'**
  String get filterAll;

  /// Filter chip label for showing only todo lists
  ///
  /// In en, this message translates to:
  /// **'Todo Lists'**
  String get filterTodoLists;

  /// Filter chip label for showing only lists
  ///
  /// In en, this message translates to:
  /// **'Lists'**
  String get filterLists;

  /// Filter chip label for showing only notes
  ///
  /// In en, this message translates to:
  /// **'Notes'**
  String get filterNotes;

  /// Sign out menu item text in app bar
  ///
  /// In en, this message translates to:
  /// **'Sign Out'**
  String get menuSignOut;

  /// Validation error when note title is empty
  ///
  /// In en, this message translates to:
  /// **'Title cannot be empty'**
  String get noteDetailTitleEmpty;

  /// Error message when note save fails
  ///
  /// In en, this message translates to:
  /// **'Failed to save changes'**
  String get noteDetailSaveFailed;

  /// Validation error when tag input is empty
  ///
  /// In en, this message translates to:
  /// **'Tag cannot be empty'**
  String get noteDetailTagEmpty;

  /// Validation error when tag exceeds maximum length
  ///
  /// In en, this message translates to:
  /// **'Tag is too long (max {maxLength} characters)'**
  String noteDetailTagTooLong(String maxLength);

  /// Validation error when adding a duplicate tag
  ///
  /// In en, this message translates to:
  /// **'Tag already exists'**
  String get noteDetailTagExists;

  /// Success message after adding a tag
  ///
  /// In en, this message translates to:
  /// **'Tag added'**
  String get noteDetailTagAdded;

  /// Success message after removing a tag
  ///
  /// In en, this message translates to:
  /// **'Tag removed'**
  String get noteDetailTagRemoved;

  /// Error message when adding tag fails
  ///
  /// In en, this message translates to:
  /// **'Failed to add tag'**
  String get noteDetailTagAddFailed;

  /// Error message when removing tag fails
  ///
  /// In en, this message translates to:
  /// **'Failed to remove tag'**
  String get noteDetailTagRemoveFailed;

  /// Title for add tag dialog
  ///
  /// In en, this message translates to:
  /// **'Add Tag'**
  String get noteDetailAddTagTitle;

  /// Label for tag name input field
  ///
  /// In en, this message translates to:
  /// **'Tag Name'**
  String get noteDetailTagNameLabel;

  /// Hint text for tag name input field
  ///
  /// In en, this message translates to:
  /// **'Enter tag name'**
  String get noteDetailTagNameHint;

  /// Title for delete note confirmation dialog
  ///
  /// In en, this message translates to:
  /// **'Delete Note'**
  String get noteDetailDeleteTitle;

  /// Message for delete note confirmation dialog
  ///
  /// In en, this message translates to:
  /// **'Are you sure you want to delete \"{noteTitle}\"?\n\nThis action cannot be undone.'**
  String noteDetailDeleteMessage(String noteTitle);

  /// Error message when note deletion fails
  ///
  /// In en, this message translates to:
  /// **'Failed to delete note'**
  String get noteDetailDeleteFailed;

  /// Hint text for note content input field
  ///
  /// In en, this message translates to:
  /// **'Start writing your note...'**
  String get noteDetailContentHint;

  /// Hint text for note title input field
  ///
  /// In en, this message translates to:
  /// **'Note title'**
  String get noteDetailTitleHint;

  /// Label for tags section
  ///
  /// In en, this message translates to:
  /// **'Tags'**
  String get noteDetailTagsLabel;

  /// Message shown when note has no tags
  ///
  /// In en, this message translates to:
  /// **'No tags yet. Tap + to add tags.'**
  String get noteDetailTagsEmpty;

  /// Delete menu item text in note detail screen
  ///
  /// In en, this message translates to:
  /// **'Delete Note'**
  String get noteDetailMenuDelete;

  /// Validation error when todo list name is empty
  ///
  /// In en, this message translates to:
  /// **'TodoList name cannot be empty'**
  String get todoDetailNameEmpty;

  /// Error message when todo list save fails
  ///
  /// In en, this message translates to:
  /// **'Failed to save changes'**
  String get todoDetailSaveFailed;

  /// Error message when loading todo items fails
  ///
  /// In en, this message translates to:
  /// **'Failed to load items'**
  String get todoDetailLoadFailed;

  /// Success message after adding a todo item
  ///
  /// In en, this message translates to:
  /// **'TodoItem added'**
  String get todoDetailItemAdded;

  /// Error message when adding todo item fails
  ///
  /// In en, this message translates to:
  /// **'Failed to add item'**
  String get todoDetailItemAddFailed;

  /// Success message after updating a todo item
  ///
  /// In en, this message translates to:
  /// **'TodoItem updated'**
  String get todoDetailItemUpdated;

  /// Error message when updating todo item fails
  ///
  /// In en, this message translates to:
  /// **'Failed to update item'**
  String get todoDetailItemUpdateFailed;

  /// Success message after deleting a todo item
  ///
  /// In en, this message translates to:
  /// **'TodoItem deleted'**
  String get todoDetailItemDeleted;

  /// Error message when deleting todo item fails
  ///
  /// In en, this message translates to:
  /// **'Failed to delete item'**
  String get todoDetailItemDeleteFailed;

  /// Error message when toggling todo item fails
  ///
  /// In en, this message translates to:
  /// **'Failed to toggle item'**
  String get todoDetailItemToggleFailed;

  /// Error message when reordering todo items fails
  ///
  /// In en, this message translates to:
  /// **'Failed to reorder items'**
  String get todoDetailReorderFailed;

  /// Title for delete todo list confirmation dialog
  ///
  /// In en, this message translates to:
  /// **'Delete TodoList'**
  String get todoDetailDeleteListTitle;

  /// Message for delete todo list confirmation dialog
  ///
  /// In en, this message translates to:
  /// **'Are you sure you want to delete \"{listName}\"?\n\nThis will delete all {itemCount} items in this list. This action cannot be undone.'**
  String todoDetailDeleteListMessage(String listName, int itemCount);

  /// Error message when deleting todo list fails
  ///
  /// In en, this message translates to:
  /// **'Failed to delete list'**
  String get todoDetailDeleteListFailed;

  /// Title for add todo item dialog
  ///
  /// In en, this message translates to:
  /// **'Add TodoItem'**
  String get todoDetailAddItemTitle;

  /// Title for edit todo item dialog
  ///
  /// In en, this message translates to:
  /// **'Edit TodoItem'**
  String get todoDetailEditItemTitle;

  /// Label for todo item title field (required)
  ///
  /// In en, this message translates to:
  /// **'Title *'**
  String get todoDetailItemTitleLabel;

  /// Hint text for todo item title field
  ///
  /// In en, this message translates to:
  /// **'Enter task title'**
  String get todoDetailItemTitleHint;

  /// Validation error for required todo item title
  ///
  /// In en, this message translates to:
  /// **'Title is required'**
  String get todoDetailItemTitleRequired;

  /// Label for todo item description field
  ///
  /// In en, this message translates to:
  /// **'Description'**
  String get todoDetailItemDescriptionLabel;

  /// Hint text for todo item description field
  ///
  /// In en, this message translates to:
  /// **'Optional description'**
  String get todoDetailItemDescriptionHint;

  /// Text shown when todo item has no due date
  ///
  /// In en, this message translates to:
  /// **'No due date'**
  String get todoDetailItemDueDateNone;

  /// Label for todo item priority dropdown
  ///
  /// In en, this message translates to:
  /// **'Priority'**
  String get todoDetailItemPriorityLabel;

  /// High priority label
  ///
  /// In en, this message translates to:
  /// **'High'**
  String get todoDetailPriorityHigh;

  /// Medium priority label
  ///
  /// In en, this message translates to:
  /// **'Medium'**
  String get todoDetailPriorityMedium;

  /// Low priority label
  ///
  /// In en, this message translates to:
  /// **'Low'**
  String get todoDetailPriorityLow;

  /// Progress indicator showing completed items
  ///
  /// In en, this message translates to:
  /// **'{completed}/{total} completed'**
  String todoDetailProgressCompleted(int completed, int total);

  /// Empty state title for todo list with no items
  ///
  /// In en, this message translates to:
  /// **'No tasks yet'**
  String get todoDetailEmptyTitle;

  /// Empty state message for todo list with no items
  ///
  /// In en, this message translates to:
  /// **'Tap the + button to add your first task'**
  String get todoDetailEmptyMessage;

  /// Label for add todo item FAB
  ///
  /// In en, this message translates to:
  /// **'Add Todo'**
  String get todoDetailFabLabel;

  /// Hint text for todo list name field
  ///
  /// In en, this message translates to:
  /// **'TodoList name'**
  String get todoDetailNameHint;

  /// Delete menu item text in todo list detail screen
  ///
  /// In en, this message translates to:
  /// **'Delete List'**
  String get todoDetailMenuDelete;

  /// Validation error when list name is empty
  ///
  /// In en, this message translates to:
  /// **'List name cannot be empty'**
  String get listDetailNameEmpty;

  /// Error message when list save fails
  ///
  /// In en, this message translates to:
  /// **'Failed to save changes'**
  String get listDetailSaveFailed;

  /// Error message when loading list items fails
  ///
  /// In en, this message translates to:
  /// **'Failed to load items'**
  String get listDetailLoadFailed;

  /// Success message after adding a list item
  ///
  /// In en, this message translates to:
  /// **'Item added'**
  String get listDetailItemAdded;

  /// Error message when adding list item fails
  ///
  /// In en, this message translates to:
  /// **'Failed to add item'**
  String get listDetailItemAddFailed;

  /// Success message after updating a list item
  ///
  /// In en, this message translates to:
  /// **'Item updated'**
  String get listDetailItemUpdated;

  /// Error message when updating list item fails
  ///
  /// In en, this message translates to:
  /// **'Failed to update item'**
  String get listDetailItemUpdateFailed;

  /// Success message after deleting a list item
  ///
  /// In en, this message translates to:
  /// **'Item deleted'**
  String get listDetailItemDeleted;

  /// Error message when deleting list item fails
  ///
  /// In en, this message translates to:
  /// **'Failed to delete item'**
  String get listDetailItemDeleteFailed;

  /// Error message when toggling list item checkbox fails
  ///
  /// In en, this message translates to:
  /// **'Failed to toggle item'**
  String get listDetailItemToggleFailed;

  /// Error message when reordering list items fails
  ///
  /// In en, this message translates to:
  /// **'Failed to reorder items'**
  String get listDetailReorderFailed;

  /// Success message after changing list style
  ///
  /// In en, this message translates to:
  /// **'List style updated'**
  String get listDetailStyleUpdated;

  /// Error message when changing list style fails
  ///
  /// In en, this message translates to:
  /// **'Failed to change style'**
  String get listDetailStyleChangeFailed;

  /// Success message after changing list icon
  ///
  /// In en, this message translates to:
  /// **'List icon updated'**
  String get listDetailIconUpdated;

  /// Error message when changing list icon fails
  ///
  /// In en, this message translates to:
  /// **'Failed to change icon'**
  String get listDetailIconChangeFailed;

  /// Title for delete list confirmation dialog
  ///
  /// In en, this message translates to:
  /// **'Delete List'**
  String get listDetailDeleteTitle;

  /// Message for delete list confirmation dialog
  ///
  /// In en, this message translates to:
  /// **'Are you sure you want to delete \"{listName}\"?\n\nThis will delete all {itemCount} items in this list. This action cannot be undone.'**
  String listDetailDeleteMessage(String listName, int itemCount);

  /// Error message when deleting list fails
  ///
  /// In en, this message translates to:
  /// **'Failed to delete list'**
  String get listDetailDeleteFailed;

  /// Title for add list item dialog
  ///
  /// In en, this message translates to:
  /// **'Add Item'**
  String get listDetailAddItemTitle;

  /// Title for edit list item dialog
  ///
  /// In en, this message translates to:
  /// **'Edit Item'**
  String get listDetailEditItemTitle;

  /// Label for list item title field (required)
  ///
  /// In en, this message translates to:
  /// **'Title *'**
  String get listDetailItemTitleLabel;

  /// Hint text for list item title field
  ///
  /// In en, this message translates to:
  /// **'Enter item title'**
  String get listDetailItemTitleHint;

  /// Validation error for required list item title
  ///
  /// In en, this message translates to:
  /// **'Title is required'**
  String get listDetailItemTitleRequired;

  /// Label for list item notes field
  ///
  /// In en, this message translates to:
  /// **'Notes'**
  String get listDetailItemNotesLabel;

  /// Hint text for list item notes field
  ///
  /// In en, this message translates to:
  /// **'Optional notes'**
  String get listDetailItemNotesHint;

  /// Title for list style selection dialog
  ///
  /// In en, this message translates to:
  /// **'Select Style'**
  String get listDetailStyleDialogTitle;

  /// Bullets list style label
  ///
  /// In en, this message translates to:
  /// **'Bullets'**
  String get listDetailStyleBullets;

  /// Description for bullets list style
  ///
  /// In en, this message translates to:
  /// **'Simple bullet points'**
  String get listDetailStyleBulletsDesc;

  /// Numbered list style label
  ///
  /// In en, this message translates to:
  /// **'Numbered'**
  String get listDetailStyleNumbered;

  /// Description for numbered list style
  ///
  /// In en, this message translates to:
  /// **'Numbered list items'**
  String get listDetailStyleNumberedDesc;

  /// Checkboxes list style label
  ///
  /// In en, this message translates to:
  /// **'Checkboxes'**
  String get listDetailStyleCheckboxes;

  /// Description for checkboxes list style
  ///
  /// In en, this message translates to:
  /// **'Checkable task items'**
  String get listDetailStyleCheckboxesDesc;

  /// Title for list icon selection dialog
  ///
  /// In en, this message translates to:
  /// **'Select Icon'**
  String get listDetailIconDialogTitle;

  /// Progress indicator for checkboxes style lists
  ///
  /// In en, this message translates to:
  /// **'{checked}/{total} completed'**
  String listDetailProgressCompleted(int checked, int total);

  /// Empty state title for list with no items
  ///
  /// In en, this message translates to:
  /// **'No items yet'**
  String get listDetailEmptyTitle;

  /// Empty state message for list with no items
  ///
  /// In en, this message translates to:
  /// **'Tap the + button to add your first item'**
  String get listDetailEmptyMessage;

  /// Label for add item FAB
  ///
  /// In en, this message translates to:
  /// **'Add Item'**
  String get listDetailFabLabel;

  /// Hint text for list name field
  ///
  /// In en, this message translates to:
  /// **'List name'**
  String get listDetailNameHint;

  /// Change style menu item text
  ///
  /// In en, this message translates to:
  /// **'Change Style'**
  String get listDetailMenuChangeStyle;

  /// Change icon menu item text
  ///
  /// In en, this message translates to:
  /// **'Change Icon'**
  String get listDetailMenuChangeIcon;

  /// Delete menu item text in list detail screen
  ///
  /// In en, this message translates to:
  /// **'Delete List'**
  String get listDetailMenuDelete;

  /// Title for space switcher modal
  ///
  /// In en, this message translates to:
  /// **'Switch Space'**
  String get spaceModalTitle;

  /// Hint text for space search input
  ///
  /// In en, this message translates to:
  /// **'Search spaces...'**
  String get spaceModalSearchHint;

  /// Message when space search returns no results
  ///
  /// In en, this message translates to:
  /// **'No spaces found'**
  String get spaceModalNoSpacesFound;

  /// Message when user has no spaces
  ///
  /// In en, this message translates to:
  /// **'No spaces available'**
  String get spaceModalNoSpacesAvailable;

  /// Badge label for archived spaces
  ///
  /// In en, this message translates to:
  /// **'Archived'**
  String get spaceModalArchived;

  /// Toggle label for showing archived spaces
  ///
  /// In en, this message translates to:
  /// **'Show Archived Spaces'**
  String get spaceModalShowArchived;

  /// Button text for creating a new space
  ///
  /// In en, this message translates to:
  /// **'Create New Space'**
  String get spaceModalCreateNew;

  /// Edit menu item text in space options
  ///
  /// In en, this message translates to:
  /// **'Edit Space'**
  String get spaceModalMenuEdit;

  /// Archive menu item text in space options
  ///
  /// In en, this message translates to:
  /// **'Archive Space'**
  String get spaceModalMenuArchive;

  /// Hint shown when trying to archive current space
  ///
  /// In en, this message translates to:
  /// **'Switch to another space first'**
  String get spaceModalMenuArchiveHint;

  /// Hint showing item count when archiving
  ///
  /// In en, this message translates to:
  /// **'This space contains {itemCount} items'**
  String spaceModalMenuArchiveHintItems(int itemCount);

  /// Restore menu item text in space options
  ///
  /// In en, this message translates to:
  /// **'Restore Space'**
  String get spaceModalMenuRestore;

  /// Hint for restore space action
  ///
  /// In en, this message translates to:
  /// **'Make this space active again'**
  String get spaceModalMenuRestoreHint;

  /// Cancel menu item text
  ///
  /// In en, this message translates to:
  /// **'Cancel'**
  String get spaceModalMenuCancel;

  /// Error message when space switch fails
  ///
  /// In en, this message translates to:
  /// **'Failed to switch space'**
  String get spaceModalSwitchFailed;

  /// Error message when trying to archive current space
  ///
  /// In en, this message translates to:
  /// **'Cannot archive the current space. Switch to another space first.'**
  String get spaceModalArchiveCurrent;

  /// Title for archive space confirmation dialog
  ///
  /// In en, this message translates to:
  /// **'Archive Space?'**
  String get spaceModalArchiveConfirmTitle;

  /// Message for archive space confirmation dialog
  ///
  /// In en, this message translates to:
  /// **'This space contains {itemCount} items. Archiving will hide the space but keep all items. You can restore it later from archived spaces.'**
  String spaceModalArchiveConfirmMessage(int itemCount);

  /// Success message after archiving space
  ///
  /// In en, this message translates to:
  /// **'{spaceName} has been archived'**
  String spaceModalArchiveSuccess(String spaceName);

  /// Error message when archiving space fails
  ///
  /// In en, this message translates to:
  /// **'Failed to archive space'**
  String get spaceModalArchiveFailed;

  /// Success message after restoring space
  ///
  /// In en, this message translates to:
  /// **'{spaceName} has been restored'**
  String spaceModalRestoreSuccess(String spaceName);

  /// Error message when restoring space fails
  ///
  /// In en, this message translates to:
  /// **'Failed to restore space'**
  String get spaceModalRestoreFailed;

  /// Title prefix for create content modal
  ///
  /// In en, this message translates to:
  /// **'Create'**
  String get createModalTitle;

  /// Todo List type label in create modal
  ///
  /// In en, this message translates to:
  /// **'Todo List'**
  String get createModalTypeTodoList;

  /// List type label in create modal
  ///
  /// In en, this message translates to:
  /// **'List'**
  String get createModalTypeList;

  /// Note type label in create modal
  ///
  /// In en, this message translates to:
  /// **'Note'**
  String get createModalTypeNote;

  /// Hint text for todo list name input
  ///
  /// In en, this message translates to:
  /// **'Todo list name'**
  String get createModalTodoListNameHint;

  /// Hint text for list name input
  ///
  /// In en, this message translates to:
  /// **'List name'**
  String get createModalListNameHint;

  /// Hint text for note title input (desktop)
  ///
  /// In en, this message translates to:
  /// **'Note title'**
  String get createModalNoteTitleHint;

  /// Hint text for note content input (desktop)
  ///
  /// In en, this message translates to:
  /// **'Note content'**
  String get createModalNoteContentHint;

  /// Hint text for note smart field (mobile)
  ///
  /// In en, this message translates to:
  /// **'Note title or content...\n(First line becomes title)'**
  String get createModalNoteSmartFieldHint;

  /// Label for list style selector
  ///
  /// In en, this message translates to:
  /// **'List Style'**
  String get createModalListStyleLabel;

  /// Bullets style option
  ///
  /// In en, this message translates to:
  /// **'Bullets'**
  String get createModalListStyleBullets;

  /// Numbered style option
  ///
  /// In en, this message translates to:
  /// **'Numbered'**
  String get createModalListStyleNumbered;

  /// Checklist style option
  ///
  /// In en, this message translates to:
  /// **'Checklist'**
  String get createModalListStyleCheckboxes;

  /// Simple style option
  ///
  /// In en, this message translates to:
  /// **'Simple'**
  String get createModalListStyleSimple;

  /// Label for todo list description field
  ///
  /// In en, this message translates to:
  /// **'Description (optional)'**
  String get createModalTodoDescriptionLabel;

  /// Hint text for todo list description field
  ///
  /// In en, this message translates to:
  /// **'Add description (optional)'**
  String get createModalTodoDescriptionHint;

  /// Link text to show description field
  ///
  /// In en, this message translates to:
  /// **'+ Add description (optional)'**
  String get createModalTodoDescriptionAdd;

  /// Validation error for description length
  ///
  /// In en, this message translates to:
  /// **'Description too long (max 500 characters)'**
  String get createModalTodoDescriptionTooLong;

  /// Label for space selector
  ///
  /// In en, this message translates to:
  /// **'Save to: '**
  String get createModalSaveToLabel;

  /// Keyboard shortcut hint for Mac
  ///
  /// In en, this message translates to:
  /// **'⌘+Enter to create • Esc to close'**
  String get createModalKeyboardShortcutMac;

  /// Keyboard shortcut hint for non-Mac platforms
  ///
  /// In en, this message translates to:
  /// **'Ctrl+Enter to create • Esc to close'**
  String get createModalKeyboardShortcutOther;

  /// Create button text for todo list
  ///
  /// In en, this message translates to:
  /// **'Create Todo List'**
  String get createModalButtonTodoList;

  /// Create button text for list
  ///
  /// In en, this message translates to:
  /// **'Create List'**
  String get createModalButtonList;

  /// Create button text for note
  ///
  /// In en, this message translates to:
  /// **'Create Note'**
  String get createModalButtonNote;

  /// Generic create button text
  ///
  /// In en, this message translates to:
  /// **'Create'**
  String get createModalButtonGeneric;

  /// Title for close confirmation dialog
  ///
  /// In en, this message translates to:
  /// **'Discard unsaved content?'**
  String get createModalCloseTitle;

  /// Message for close confirmation dialog
  ///
  /// In en, this message translates to:
  /// **'You haven\'t created this item yet. Would you like to create it or discard your changes?'**
  String get createModalCloseMessage;

  /// Cancel button text in close confirmation
  ///
  /// In en, this message translates to:
  /// **'Cancel'**
  String get createModalCloseCancel;

  /// Discard button text in close confirmation
  ///
  /// In en, this message translates to:
  /// **'Discard'**
  String get createModalCloseDiscard;

  /// Create and close button text in close confirmation
  ///
  /// In en, this message translates to:
  /// **'Create & Close'**
  String get createModalCloseCreate;

  /// Generic add button text
  ///
  /// In en, this message translates to:
  /// **'Add'**
  String get buttonAdd;

  /// Generic save button text
  ///
  /// In en, this message translates to:
  /// **'Save'**
  String get buttonSave;

  /// Generic cancel button text
  ///
  /// In en, this message translates to:
  /// **'Cancel'**
  String get buttonCancel;

  /// Generic delete button text
  ///
  /// In en, this message translates to:
  /// **'Delete'**
  String get buttonDelete;

  /// Generic close button text
  ///
  /// In en, this message translates to:
  /// **'Close'**
  String get buttonClose;

  /// Generic archive button text
  ///
  /// In en, this message translates to:
  /// **'Archive'**
  String get buttonArchive;

  /// Accessibility label for close buttons
  ///
  /// In en, this message translates to:
  /// **'Close'**
  String get accessibilityCloseButton;

  /// Accessibility label for collapsed description field
  ///
  /// In en, this message translates to:
  /// **'Add description, collapsed'**
  String get accessibilityAddDescription;

  /// Accessibility hint for add description action
  ///
  /// In en, this message translates to:
  /// **'Tap to add optional description field'**
  String get accessibilityAddDescriptionHint;

  /// Accessibility label for remove description button
  ///
  /// In en, this message translates to:
  /// **'Remove description field'**
  String get accessibilityRemoveDescription;

  /// Accessibility label for create new space button
  ///
  /// In en, this message translates to:
  /// **'Create new space'**
  String get accessibilityCreateNewSpace;

  /// Accessibility label for space list items
  ///
  /// In en, this message translates to:
  /// **'{spaceName}, {itemCount} items'**
  String accessibilitySpaceItemCount(String spaceName, int itemCount);

  /// Title for space switcher modal
  ///
  /// In en, this message translates to:
  /// **'Switch Space'**
  String get spaceSwitcherTitle;

  /// Hint text for space search field
  ///
  /// In en, this message translates to:
  /// **'Search spaces...'**
  String get spaceSwitcherSearchHint;

  /// Error message when switching spaces fails
  ///
  /// In en, this message translates to:
  /// **'Failed to switch space: {error}'**
  String spaceSwitcherErrorSwitch(String error);

  /// Empty state message when search returns no results
  ///
  /// In en, this message translates to:
  /// **'No spaces found'**
  String get spaceSwitcherEmptyNoResults;

  /// Empty state message when there are no spaces
  ///
  /// In en, this message translates to:
  /// **'No spaces available'**
  String get spaceSwitcherEmptyNoSpaces;

  /// Item count label in space switcher
  ///
  /// In en, this message translates to:
  /// **'{count} items'**
  String spaceSwitcherItemCount(int count);

  /// Menu item to edit space
  ///
  /// In en, this message translates to:
  /// **'Edit Space'**
  String get spaceSwitcherMenuEdit;

  /// Menu item to archive space
  ///
  /// In en, this message translates to:
  /// **'Archive Space'**
  String get spaceSwitcherMenuArchive;

  /// Menu item to restore archived space
  ///
  /// In en, this message translates to:
  /// **'Restore Space'**
  String get spaceSwitcherMenuRestore;

  /// Menu item to cancel
  ///
  /// In en, this message translates to:
  /// **'Cancel'**
  String get spaceSwitcherMenuCancel;

  /// Subtitle when trying to archive current space
  ///
  /// In en, this message translates to:
  /// **'Switch to another space first'**
  String get spaceSwitcherSubtitleSwitchFirst;

  /// Subtitle showing item count before archiving
  ///
  /// In en, this message translates to:
  /// **'This space contains {count} items'**
  String spaceSwitcherSubtitleContainsItems(int count);

  /// Subtitle for restore action
  ///
  /// In en, this message translates to:
  /// **'Make this space active again'**
  String get spaceSwitcherSubtitleRestore;

  /// Title for archive confirmation dialog
  ///
  /// In en, this message translates to:
  /// **'Archive Space?'**
  String get spaceSwitcherDialogArchiveTitle;

  /// Content for archive confirmation dialog
  ///
  /// In en, this message translates to:
  /// **'This space contains {count} items. Archiving will hide the space but keep all items. You can restore it later from archived spaces.'**
  String spaceSwitcherDialogArchiveContent(int count);

  /// Success message when space is archived
  ///
  /// In en, this message translates to:
  /// **'{name} has been archived'**
  String spaceSwitcherSuccessArchived(String name);

  /// Success message when space is restored
  ///
  /// In en, this message translates to:
  /// **'{name} has been restored'**
  String spaceSwitcherSuccessRestored(String name);

  /// Error message when archiving fails
  ///
  /// In en, this message translates to:
  /// **'Failed to archive space: {error}'**
  String spaceSwitcherErrorArchive(String error);

  /// Error message when restoring fails
  ///
  /// In en, this message translates to:
  /// **'Failed to restore space: {error}'**
  String spaceSwitcherErrorRestore(String error);

  /// Error message when trying to archive current space
  ///
  /// In en, this message translates to:
  /// **'Cannot archive the current space. Switch to another space first.'**
  String get spaceSwitcherErrorCannotArchiveCurrent;

  /// Badge label for archived spaces
  ///
  /// In en, this message translates to:
  /// **'Archived'**
  String get spaceSwitcherBadgeArchived;

  /// Toggle label to show archived spaces
  ///
  /// In en, this message translates to:
  /// **'Show Archived Spaces'**
  String get spaceSwitcherToggleShowArchived;

  /// Button text to create new space
  ///
  /// In en, this message translates to:
  /// **'Create New Space'**
  String get spaceSwitcherButtonCreateNew;

  /// Title for empty search state when no results match query
  ///
  /// In en, this message translates to:
  /// **'No results found'**
  String get searchEmptyTitle;

  /// Message for empty search state suggesting alternative search strategies
  ///
  /// In en, this message translates to:
  /// **'Try different keywords or check your spelling'**
  String get searchEmptyMessage;

  /// Accessibility hint for drag handle reordering interaction
  ///
  /// In en, this message translates to:
  /// **'Double tap and hold to reorder'**
  String get accessibilityDragHandleHint;

  /// Bottom navigation label for Home tab
  ///
  /// In en, this message translates to:
  /// **'Home'**
  String get navigationBottomHome;

  /// Tooltip for Home tab in bottom navigation
  ///
  /// In en, this message translates to:
  /// **'View your spaces'**
  String get navigationBottomHomeTooltip;

  /// Accessibility label for Home tab
  ///
  /// In en, this message translates to:
  /// **'Home navigation'**
  String get navigationBottomHomeSemanticLabel;

  /// Bottom navigation label for Search tab
  ///
  /// In en, this message translates to:
  /// **'Search'**
  String get navigationBottomSearch;

  /// Tooltip for Search tab in bottom navigation
  ///
  /// In en, this message translates to:
  /// **'Search items'**
  String get navigationBottomSearchTooltip;

  /// Accessibility label for Search tab
  ///
  /// In en, this message translates to:
  /// **'Search navigation'**
  String get navigationBottomSearchSemanticLabel;

  /// Bottom navigation label for Settings tab
  ///
  /// In en, this message translates to:
  /// **'Settings'**
  String get navigationBottomSettings;

  /// Tooltip for Settings tab in bottom navigation
  ///
  /// In en, this message translates to:
  /// **'App settings'**
  String get navigationBottomSettingsTooltip;

  /// Accessibility label for Settings tab
  ///
  /// In en, this message translates to:
  /// **'Settings navigation'**
  String get navigationBottomSettingsSemanticLabel;

  /// Title for generic item delete confirmation dialog
  ///
  /// In en, this message translates to:
  /// **'Delete Item?'**
  String get dialogDeleteItemTitle;

  /// Message for generic item delete confirmation with item name
  ///
  /// In en, this message translates to:
  /// **'Are you sure you want to delete \"{itemName}\"? This action cannot be undone.'**
  String dialogDeleteItemMessage(String itemName);

  /// Banner message prompting anonymous users to upgrade to a full account
  ///
  /// In en, this message translates to:
  /// **'Create an account to keep your data safe'**
  String get authUpgradeBannerMessage;

  /// Button text on upgrade banner to start account creation
  ///
  /// In en, this message translates to:
  /// **'Create Account'**
  String get authUpgradeBannerButton;

  /// Title for the account upgrade screen
  ///
  /// In en, this message translates to:
  /// **'Create Your Account'**
  String get authUpgradeScreenTitle;

  /// Subtitle for the account upgrade screen explaining benefits
  ///
  /// In en, this message translates to:
  /// **'Upgrade to unlock unlimited features'**
  String get authUpgradeScreenSubtitle;

  /// Label for email input field on upgrade screen
  ///
  /// In en, this message translates to:
  /// **'Email'**
  String get authUpgradeEmailLabel;

  /// Label for password input field on upgrade screen
  ///
  /// In en, this message translates to:
  /// **'Password'**
  String get authUpgradePasswordLabel;

  /// Label for confirm password input field on upgrade screen
  ///
  /// In en, this message translates to:
  /// **'Confirm Password'**
  String get authUpgradeConfirmPasswordLabel;

  /// Submit button text on upgrade screen
  ///
  /// In en, this message translates to:
  /// **'Create Account'**
  String get authUpgradeSubmitButton;

  /// Cancel button text on upgrade screen
  ///
  /// In en, this message translates to:
  /// **'Maybe Later'**
  String get authUpgradeCancelButton;

  /// Success message shown after successful account upgrade
  ///
  /// In en, this message translates to:
  /// **'Account created successfully!'**
  String get authUpgradeSuccessMessage;

  /// Button text for dismissing a banner or dialog
  ///
  /// In en, this message translates to:
  /// **'Dismiss'**
  String get buttonDismiss;

  /// Accessibility label for warning icons
  ///
  /// In en, this message translates to:
  /// **'Warning'**
  String get accessibilityWarning;

  /// Validation error when email field is empty
  ///
  /// In en, this message translates to:
  /// **'Email is required'**
  String get validationEmailRequired;

  /// Validation error when email format is invalid
  ///
  /// In en, this message translates to:
  /// **'Please enter a valid email'**
  String get validationEmailInvalid;

  /// Validation error when password field is empty
  ///
  /// In en, this message translates to:
  /// **'Password is required'**
  String get validationPasswordRequired;

  /// Validation error when password is too short
  ///
  /// In en, this message translates to:
  /// **'Password must be at least 8 characters'**
  String get validationPasswordMinLength;

  /// Validation error when password confirmation field is empty
  ///
  /// In en, this message translates to:
  /// **'Please confirm your password'**
  String get validationPasswordConfirmRequired;

  /// Validation error when password and confirmation don't match
  ///
  /// In en, this message translates to:
  /// **'Passwords do not match'**
  String get validationPasswordsDoNotMatch;

  /// Generic error message for unexpected errors
  ///
  /// In en, this message translates to:
  /// **'An unexpected error occurred'**
  String get errorUnexpected;
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
      <String>['de', 'en'].contains(locale.languageCode);

  @override
  bool shouldReload(_AppLocalizationsDelegate old) => false;
}

AppLocalizations lookupAppLocalizations(Locale locale) {
  // Lookup logic when only language code is specified.
  switch (locale.languageCode) {
    case 'de':
      return AppLocalizationsDe();
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
