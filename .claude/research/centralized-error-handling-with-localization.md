# Research: Centralized Error Handling with Localization Support

## Executive Summary

The current error handling system in the Later app uses a custom `AppError` class with keyword-based exception categorization and hardcoded English error messages scattered across multiple files. This research evaluates modern approaches for centralizing error handling with support for localization, focusing on three main objectives:

1. **Eliminate keyword-based error detection** - Replace fragile string matching with structured error mapping
2. **Centralize error definitions** - Create a single source of truth for error types and messages
3. **Enable localization** - Support multi-language user-friendly error messages using Flutter's i18n system

**Recommended Approach**: Implement a three-layer error handling architecture using:
- **Error Code Registry** - Centralized enum-based error codes with metadata
- **Error Mapper Layer** - Domain-specific mappers that convert third-party exceptions to app errors
- **Localization Layer** - Integration with Flutter's `intl` package for translated error messages

This approach provides type-safety, extensibility, testability, and first-class localization support while preventing third-party error messages from leaking to users.

## Research Scope

### What Was Researched
- Current error handling implementation in the Later codebase
- Industry best practices for Flutter error handling (2025 standards)
- Functional error handling patterns (Either, Result types)
- Third-party exception mapping strategies
- Flutter localization approaches for error messages
- Error handling architectures that support internationalization

### What Was Explicitly Excluded
- Error monitoring/logging services (Sentry, Firebase Crashlytics)
- UI error display components (already implemented)
- Network retry logic (already implemented with exponential backoff)
- Testing strategies for error handling

### Research Methodology
- Analyzed existing codebase error handling patterns
- Reviewed 2025 Flutter best practices documentation
- Evaluated functional programming approaches (fpdart, dartz)
- Examined localization integration strategies
- Compared centralized error management patterns

## Current State Analysis

### Existing Implementation

**Error Infrastructure** (`lib/core/error/`)
- `AppError` class with 5 error types (storage, network, validation, corruption, unknown)
- `ErrorHandler` for global error handling setup
- `ErrorLogger` for debug-mode logging
- Factory constructors with default English messages
- `AppError.fromException()` using keyword matching

**Problems Identified:**

1. **Fragile Keyword Matching** (app_error.dart:127-149)
```dart
factory AppError.fromException(Object exception) {
  final message = exception.toString();

  // Brittle string matching
  if (message.contains('Hive') || message.contains('storage') ||
      message.contains('Box') || message.contains('file')) {
    return AppError.storage(message: message, details: exception.toString());
  }
  // ... more keyword matching
}
```

Issues:
- Checks for "Hive" keywords but app now uses Supabase
- "Dead keywords" that no longer match real exceptions
- False positives (e.g., user content containing "network" keyword)
- Cannot distinguish between different Supabase exception types

2. **Hardcoded English Messages**
```dart
factory AppError.network({...}) {
  return AppError(
    type: ErrorType.network,
    userMessage: userMessage ??
      'Connection failed. Please check your internet connection and try again.',
  );
}
```

All user messages are hardcoded English strings, making localization impossible.

3. **Scattered Error Handling**

Different approaches across the codebase:
- `BaseRepository` (base_repository.dart:59-93): Maps specific PostgrestException codes
- `AuthService` (auth_service.dart:111-157): Maps AuthException codes with switch statement
- `AuthProvider` (auth_provider.dart:157-166): Generic catch with hardcoded message
- Various repositories: Use `executeQuery()` wrapper but inconsistent error handling

4. **Multiple Mapping Locations**

Error mapping happens in three places:
- `AppError.fromException()` - Generic keyword matching
- `BaseRepository._handlePostgrestException()` - Database error codes
- `AuthService._mapAuthError()` - Auth error codes

No centralized registry of error codes or mapping strategy.

### Industry Standards (2025)

Based on research of Flutter best practices in 2025:

**Key Principles:**
1. **Domain-Driven Exception Handling** - Map third-party exceptions at repository boundaries
2. **Result/Either Pattern** - Use functional types for explicit error handling
3. **Centralized Error Registry** - Single source of truth for error codes and messages
4. **Localization-First** - Design error messages with i18n from the start
5. **Type-Safe Error Codes** - Use enums or sealed classes instead of strings

**Common Patterns:**
- Error code enums with metadata
- Mapper functions at data layer boundaries
- Separation of technical errors from user-facing messages
- Integration with Flutter's `intl` package for localization

## Technical Analysis

### Approach 1: Enhanced Current System (Minimal Change)

**Description**: Improve the existing `AppError` system by replacing keyword matching with exception type checking and adding localization keys.

**Implementation Strategy:**
```dart
// Enhanced ErrorType enum with more granular types
enum ErrorType {
  // Database errors
  databaseUniqueConstraint,
  databaseForeignKey,
  databaseNotNull,
  databasePermissionDenied,
  databaseGeneric,

  // Auth errors
  authInvalidCredentials,
  authUserExists,
  authWeakPassword,
  authInvalidEmail,
  authGeneric,

  // Network errors
  networkTimeout,
  networkNoConnection,
  networkGeneric,

  // ... more types
}

// AppError with localization key
class AppError implements Exception {
  final ErrorType type;
  final String message;
  final String? technicalDetails;
  final String localizationKey; // New field
  final Map<String, dynamic>? localizationParams; // For interpolation

  String getUserMessage(AppLocalizations localizations) {
    return localizations.getErrorMessage(localizationKey, localizationParams);
  }
}
```

**Pros:**
- Minimal disruption to existing code
- Gradual migration path
- Familiar structure for team
- Uses existing error handling infrastructure

**Cons:**
- ErrorType enum becomes very large (30-50+ values)
- Still requires updating all error creation sites
- Doesn't prevent third-party exceptions from bubbling up
- No compile-time guarantee that mapper exists for each exception type
- Tight coupling between error types and localization keys

**Use Cases:**
When time/resources are limited and you need a quick improvement without major refactoring.

**Code Example:**
```dart
// Error mapper in repository
Future<T> executeQuery<T>(Future<T> Function() query) async {
  try {
    return await query();
  } on PostgrestException catch (e) {
    throw _mapPostgrestException(e);
  } on AuthException catch (e) {
    throw _mapAuthException(e);
  }
}

AppError _mapPostgrestException(PostgrestException e) {
  switch (e.code) {
    case '23505':
      return AppError(
        type: ErrorType.databaseUniqueConstraint,
        message: 'Unique constraint violation: ${e.message}',
        localizationKey: 'error.database.uniqueConstraint',
      );
    // ... more cases
  }
}
```

---

### Approach 2: Error Code Registry with Domain Mappers (Recommended)

**Description**: Implement a three-layer architecture with centralized error codes, domain-specific mappers, and localization integration.

**Architecture:**

```
┌─────────────────────────────────────────────────────────────┐
│                     Presentation Layer                       │
│  (Widgets display localized messages via AppLocalizations)  │
└───────────────────┬─────────────────────────────────────────┘
                    │ AppError with ErrorCode
                    │
┌───────────────────▼─────────────────────────────────────────┐
│                    Error Handler Layer                       │
│  • ErrorCode enum (centralized registry)                     │
│  • AppError class (wraps ErrorCode + context)                │
│  • Localization integration                                  │
└───────────────────┬─────────────────────────────────────────┘
                    │ Domain-specific exceptions
                    │
┌───────────────────▼─────────────────────────────────────────┐
│                   Domain Mapper Layer                        │
│  • SupabaseErrorMapper (maps Postgrest/Auth exceptions)     │
│  • NetworkErrorMapper (maps Dio/HTTP exceptions)            │
│  • ValidationErrorMapper (maps validation failures)         │
└───────────────────┬─────────────────────────────────────────┘
                    │ Third-party exceptions
                    │
┌───────────────────▼─────────────────────────────────────────┐
│                     Data Layer                               │
│  (Repositories, Services - throw third-party exceptions)     │
└─────────────────────────────────────────────────────────────┘
```

**Implementation Components:**

**1. Error Code Registry** (`lib/core/error/error_codes.dart`)
```dart
/// Centralized registry of all application error codes.
/// Each code maps to a localization key and has metadata.
enum ErrorCode {
  // Database errors (1000-1999)
  databaseUniqueConstraint,
  databaseForeignKeyViolation,
  databaseNotNullViolation,
  databasePermissionDenied,
  databaseConnectionFailed,
  databaseTimeout,
  databaseGeneric,

  // Authentication errors (2000-2999)
  authInvalidCredentials,
  authUserAlreadyExists,
  authWeakPassword,
  authInvalidEmail,
  authEmailNotConfirmed,
  authSessionExpired,
  authNetworkError,
  authRateLimitExceeded,
  authGeneric,

  // Network errors (3000-3999)
  networkTimeout,
  networkNoConnection,
  networkServerError,
  networkBadRequest,
  networkNotFound,
  networkGeneric,

  // Validation errors (4000-4999)
  validationRequired,
  validationInvalidFormat,
  validationOutOfRange,
  validationDuplicate,

  // Business logic errors (5000-5999)
  spaceNotFound,
  noteNotFound,
  insufficientPermissions,
  operationNotAllowed,

  // Unknown errors (9000+)
  unknownError,
}

extension ErrorCodeMetadata on ErrorCode {
  /// Returns the localization key for this error code
  String get localizationKey {
    return 'error.${name}';
  }

  /// Returns whether this error type is retryable
  bool get isRetryable {
    switch (this) {
      case ErrorCode.networkTimeout:
      case ErrorCode.networkNoConnection:
      case ErrorCode.databaseTimeout:
      case ErrorCode.databaseConnectionFailed:
        return true;
      default:
        return false;
    }
  }

  /// Returns the error severity level
  ErrorSeverity get severity {
    if (name.startsWith('database') || name.startsWith('auth')) {
      return ErrorSeverity.high;
    } else if (name.startsWith('network')) {
      return ErrorSeverity.medium;
    } else if (name.startsWith('validation')) {
      return ErrorSeverity.low;
    }
    return ErrorSeverity.medium;
  }
}

enum ErrorSeverity { low, medium, high, critical }
```

**2. Enhanced AppError** (`lib/core/error/app_error.dart`)
```dart
/// Application error with error code and optional context parameters
class AppError implements Exception {
  const AppError({
    required this.code,
    required this.message,
    this.technicalDetails,
    this.context,
  });

  /// Structured error code from centralized registry
  final ErrorCode code;

  /// Technical message for logging (English only)
  final String message;

  /// Additional technical details (stack trace, etc.)
  final String? technicalDetails;

  /// Context parameters for error message interpolation
  /// Example: {'fieldName': 'email', 'maxLength': '255'}
  final Map<String, dynamic>? context;

  /// Gets localized user-friendly message
  String getUserMessage(AppLocalizations localizations) {
    return localizations.getErrorMessage(
      code.localizationKey,
      context,
    );
  }

  bool get isRetryable => code.isRetryable;
  ErrorSeverity get severity => code.severity;

  @override
  String toString() => 'AppError(${code.name}): $message';
}
```

**3. Domain Error Mappers** (`lib/core/error/mappers/`)

Each mapper handles exceptions from a specific domain:

```dart
// lib/core/error/mappers/supabase_error_mapper.dart
class SupabaseErrorMapper {
  /// Maps Supabase PostgrestException to AppError
  static AppError fromPostgrestException(PostgrestException exception) {
    switch (exception.code) {
      case '23505': // Unique constraint violation
        return AppError(
          code: ErrorCode.databaseUniqueConstraint,
          message: 'Unique constraint violation',
          technicalDetails: exception.message,
        );

      case '23503': // Foreign key violation
        return AppError(
          code: ErrorCode.databaseForeignKeyViolation,
          message: 'Foreign key constraint violation',
          technicalDetails: exception.message,
        );

      case '23502': // Not null violation
        return AppError(
          code: ErrorCode.databaseNotNullViolation,
          message: 'Required field missing',
          technicalDetails: exception.message,
        );

      case '42501': // Insufficient privileges (RLS)
        return AppError(
          code: ErrorCode.databasePermissionDenied,
          message: 'Permission denied by RLS policy',
          technicalDetails: exception.message,
        );

      default:
        return AppError(
          code: ErrorCode.databaseGeneric,
          message: 'Database operation failed',
          technicalDetails: '${exception.code}: ${exception.message}',
        );
    }
  }

  /// Maps Supabase AuthException to AppError
  static AppError fromAuthException(AuthException exception) {
    final code = exception.code;

    switch (code) {
      case 'invalid_credentials':
      case 'invalid_grant':
      case 'user_not_found':
        return AppError(
          code: ErrorCode.authInvalidCredentials,
          message: 'Invalid credentials',
          technicalDetails: exception.message,
        );

      case 'user_already_exists':
      case 'email_exists':
        return AppError(
          code: ErrorCode.authUserAlreadyExists,
          message: 'User already exists',
          technicalDetails: exception.message,
        );

      case 'weak_password':
      case 'password_too_short':
        return AppError(
          code: ErrorCode.authWeakPassword,
          message: 'Weak password',
          technicalDetails: exception.message,
          context: {'minLength': '8'},
        );

      case 'invalid_email':
        return AppError(
          code: ErrorCode.authInvalidEmail,
          message: 'Invalid email format',
          technicalDetails: exception.message,
        );

      case 'email_not_confirmed':
        return AppError(
          code: ErrorCode.authEmailNotConfirmed,
          message: 'Email not confirmed',
          technicalDetails: exception.message,
        );

      case 'network_error':
      case 'timeout':
        return AppError(
          code: ErrorCode.authNetworkError,
          message: 'Network error during authentication',
          technicalDetails: exception.message,
        );

      case 'over_request_rate_limit':
        return AppError(
          code: ErrorCode.authRateLimitExceeded,
          message: 'Rate limit exceeded',
          technicalDetails: exception.message,
        );

      default:
        return AppError(
          code: ErrorCode.authGeneric,
          message: 'Authentication error',
          technicalDetails: '${exception.code}: ${exception.message}',
        );
    }
  }
}
```

**4. Enhanced BaseRepository** (`lib/data/repositories/base_repository.dart`)
```dart
abstract class BaseRepository {
  SupabaseClient get supabase => SupabaseConfig.client;

  String get userId {
    final user = supabase.auth.currentUser;
    if (user == null) {
      throw AppError(
        code: ErrorCode.authSessionExpired,
        message: 'No authenticated user',
      );
    }
    return user.id;
  }

  /// Execute query with error mapping
  Future<T> executeQuery<T>(Future<T> Function() query) async {
    try {
      return await query();
    } on PostgrestException catch (e) {
      throw SupabaseErrorMapper.fromPostgrestException(e);
    } on AuthException catch (e) {
      throw SupabaseErrorMapper.fromAuthException(e);
    } on AppError {
      rethrow; // Already an AppError
    } catch (e, stackTrace) {
      // Unknown error - log and wrap
      debugPrint('Unexpected error in repository: $e\n$stackTrace');
      throw AppError(
        code: ErrorCode.unknownError,
        message: 'Unexpected database error',
        technicalDetails: e.toString(),
      );
    }
  }
}
```

**5. Localization Integration** (`lib/l10n/app_en.arb`)
```json
{
  "@@locale": "en",

  "error.databaseUniqueConstraint": "A record with this value already exists.",
  "error.databaseForeignKeyViolation": "Cannot complete operation: related records exist.",
  "error.databaseNotNullViolation": "Required field is missing.",
  "error.databasePermissionDenied": "Access denied. You do not have permission to access this data.",
  "error.databaseConnectionFailed": "Could not connect to the database. Please check your connection.",
  "error.databaseTimeout": "Database operation timed out. Please try again.",
  "error.databaseGeneric": "A database error occurred. Please try again.",

  "error.authInvalidCredentials": "Invalid email or password. Please try again.",
  "error.authUserAlreadyExists": "This email is already registered. Please sign in instead.",
  "error.authWeakPassword": "Password is too weak. Use at least {minLength} characters.",
  "@error.authWeakPassword": {
    "placeholders": {
      "minLength": {
        "type": "String"
      }
    }
  },
  "error.authInvalidEmail": "Please enter a valid email address.",
  "error.authEmailNotConfirmed": "Please confirm your email address before signing in.",
  "error.authSessionExpired": "Your session has expired. Please sign in again.",
  "error.authNetworkError": "Network error. Please check your connection and try again.",
  "error.authRateLimitExceeded": "Too many attempts. Please try again later.",
  "error.authGeneric": "Authentication failed. Please try again.",

  "error.networkTimeout": "Connection timed out. Please check your internet connection.",
  "error.networkNoConnection": "No internet connection. Please check your network settings.",
  "error.networkServerError": "Server error. Please try again later.",
  "error.networkBadRequest": "Invalid request. Please check your input.",
  "error.networkNotFound": "Resource not found.",
  "error.networkGeneric": "Network error. Please try again.",

  "error.validationRequired": "{fieldName} is required.",
  "@error.validationRequired": {
    "placeholders": {
      "fieldName": {
        "type": "String"
      }
    }
  },
  "error.validationInvalidFormat": "{fieldName} has an invalid format.",
  "@error.validationInvalidFormat": {
    "placeholders": {
      "fieldName": {
        "type": "String"
      }
    }
  },
  "error.validationOutOfRange": "{fieldName} must be between {min} and {max}.",
  "@error.validationOutOfRange": {
    "placeholders": {
      "fieldName": {"type": "String"},
      "min": {"type": "String"},
      "max": {"type": "String"}
    }
  },

  "error.unknownError": "An unexpected error occurred. Please try again."
}
```

**6. Usage in Providers** (`lib/providers/content_provider.dart`)
```dart
class ContentProvider extends ChangeNotifier {
  Future<void> createNote(Note note) async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      final created = await _noteRepository.create(note);
      _notes.add(created);
      _error = null;
    } on AppError catch (e) {
      // Already mapped to AppError by repository
      _error = e;
      ErrorLogger.logError(e);
    } catch (e, stackTrace) {
      // Unexpected error (shouldn't happen if mappers are complete)
      final appError = AppError(
        code: ErrorCode.unknownError,
        message: 'Unexpected error in createNote',
        technicalDetails: e.toString(),
      );
      _error = appError;
      ErrorLogger.logError(appError, stackTrace: stackTrace);
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }
}
```

**7. Display in UI** (`lib/widgets/screens/note_detail_screen.dart`)
```dart
class NoteDetailScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final localizations = AppLocalizations.of(context)!;
    final provider = context.watch<ContentProvider>();

    if (provider.error != null) {
      // Display localized error message
      final errorMessage = provider.error!.getUserMessage(localizations);

      return ErrorSnackBar.show(
        context,
        errorMessage,
        onRetry: provider.error!.isRetryable ? () => _retry() : null,
      );
    }

    // ... rest of UI
  }
}
```

**Pros:**
- ✅ Single source of truth for error codes
- ✅ Type-safe error handling with enums
- ✅ Clear separation of concerns (mappers, codes, localization)
- ✅ Easy to extend with new error codes
- ✅ Prevents third-party exceptions from reaching UI
- ✅ First-class localization support
- ✅ Compile-time safety for error codes
- ✅ Testable error mappers
- ✅ Metadata attached to error codes (retryable, severity)
- ✅ Supports error message interpolation

**Cons:**
- ⚠️ Requires significant refactoring
- ⚠️ Need to update all repositories and services
- ⚠️ Team needs to learn new pattern
- ⚠️ Initial setup time for error codes and translations

**Use Cases:**
- Production applications that need professional error handling
- Apps that will be localized to multiple languages
- Projects with complex error handling requirements
- Teams that want compile-time safety and maintainability

---

### Approach 3: Functional Error Handling with Either/Result

**Description**: Use functional programming patterns (Either/Result types from fpdart) for explicit error handling without exceptions.

**Implementation Strategy:**
```dart
// Using fpdart's Either type
import 'package:fpdart/fpdart.dart';

// Repository returns Either<AppError, Success>
class NoteRepository {
  Future<Either<AppError, Note>> create(Note note) async {
    try {
      final response = await supabase
        .from('notes')
        .insert(note.toJson())
        .select()
        .single();

      return Right(Note.fromJson(response));
    } on PostgrestException catch (e) {
      final error = SupabaseErrorMapper.fromPostgrestException(e);
      return Left(error);
    } catch (e) {
      return Left(AppError(
        code: ErrorCode.unknownError,
        message: e.toString(),
      ));
    }
  }
}

// Provider uses Either
class ContentProvider extends ChangeNotifier {
  Future<void> createNote(Note note) async {
    final result = await _noteRepository.create(note);

    result.match(
      (error) {
        // Handle error
        _error = error;
        ErrorLogger.logError(error);
      },
      (note) {
        // Handle success
        _notes.add(note);
        _error = null;
      },
    );

    notifyListeners();
  }
}
```

**Pros:**
- ✅ Errors are explicit in function signatures
- ✅ Compile-time guarantee that errors are handled
- ✅ Cannot forget to handle errors (no uncaught exceptions)
- ✅ Chainable with flatMap/map for complex flows
- ✅ Composable and functional
- ✅ Works well with immutable data structures

**Cons:**
- ⚠️ Steep learning curve for functional programming concepts
- ⚠️ Changes all function signatures across codebase
- ⚠️ Requires fpdart dependency (adds 100KB+ to bundle)
- ⚠️ Not idiomatic Dart/Flutter (most teams use exceptions)
- ⚠️ Difficult to integrate with existing Flutter async patterns
- ⚠️ More verbose code
- ⚠️ Still needs error code registry and localization

**Use Cases:**
- Teams with strong functional programming background
- Projects that want compile-time error handling guarantees
- Greenfield projects starting from scratch
- Applications with complex error chaining requirements

**Code Example:**
```dart
// Chaining operations with Either
Future<Either<AppError, TodoList>> createTodoListWithItems({
  required TodoList todoList,
  required List<TodoItem> items,
}) async {
  return (await _todoListRepository.create(todoList))
    .flatMap((createdList) async {
      final itemResults = await Future.wait(
        items.map((item) => _todoItemRepository.create(item)),
      );

      // If any item creation failed, return that error
      for (final result in itemResults) {
        if (result.isLeft()) return result.map((r) => createdList);
      }

      return Right(createdList);
    });
}
```

## Tools and Libraries

### Option 1: fpdart

- **Purpose**: Functional programming library for Dart with Either, Option, Task types
- **Maturity**: Production-ready (actively maintained, v3.x)
- **License**: MIT
- **Community**: ~1.5k GitHub stars, active development
- **Integration Effort**: High
- **Key Features**:
  - `Either<L, R>` for error handling
  - `Option<T>` for nullable values
  - `Task` and `TaskEither` for async operations
  - Pattern matching support
  - Composable with flatMap/map

**Recommendation**: Only if team is committed to functional programming paradigm. Adds complexity without solving localization problem.

---

### Option 2: Flutter Internationalization (intl)

- **Purpose**: Official Flutter localization package
- **Maturity**: Production-ready (part of Flutter ecosystem)
- **License**: BSD
- **Community**: Official Flutter package, millions of users
- **Integration Effort**: Medium
- **Key Features**:
  - ARB file format for translations
  - Code generation for type-safe translations
  - Pluralization and gender support
  - Message interpolation with placeholders
  - Date/number formatting

**Recommendation**: **Essential**. Use this for all localized error messages. Works seamlessly with Approach 2.

**Setup:**
```yaml
# pubspec.yaml
dependencies:
  flutter:
    sdk: flutter
  flutter_localizations:
    sdk: flutter
  intl: ^0.19.0

flutter:
  generate: true
```

```yaml
# l10n.yaml
arb-dir: lib/l10n
template-arb-file: app_en.arb
output-localization-file: app_localizations.dart
```

---

### Option 3: result_dart

- **Purpose**: Lightweight Result type for Dart (simpler than fpdart)
- **Maturity**: Production-ready (v2.x)
- **License**: MIT
- **Community**: ~200 GitHub stars
- **Integration Effort**: Medium
- **Key Features**:
  - `Result<Success, Failure>` type
  - Simpler API than Either
  - Less overhead than fpdart
  - Native Dart pattern matching support

**Recommendation**: Middle ground between exceptions and fpdart. Consider for new repositories, but not worth retrofitting entire codebase.

## Implementation Considerations

### Technical Requirements

**For Approach 2 (Recommended):**

**Dependencies:**
```yaml
dependencies:
  flutter_localizations:
    sdk: flutter
  intl: ^0.19.0

dev_dependencies:
  flutter_gen: ^5.3.0  # For generating localization code
```

**File Structure:**
```
lib/
├── core/
│   └── error/
│       ├── error_codes.dart          # ErrorCode enum
│       ├── app_error.dart            # AppError class
│       ├── error_handler.dart        # Global error handler
│       ├── error_logger.dart         # Logging utilities
│       └── mappers/
│           ├── supabase_error_mapper.dart
│           ├── network_error_mapper.dart
│           └── validation_error_mapper.dart
├── l10n/
│   ├── app_en.arb                    # English translations
│   ├── app_de.arb                    # German translations (future)
│   └── app_es.arb                    # Spanish translations (future)
└── generated/
    └── app_localizations.dart        # Generated by flutter_gen
```

**Performance:**
- Error code lookup: O(1) with enum
- Mapper execution: O(1) single switch/if-else
- Localization lookup: O(1) with generated code
- Memory: ~100KB for error infrastructure + ~50KB per language

**Scalability:**
- Can easily add new error codes (append to enum)
- Can add new mappers for new dependencies
- Can add new languages without code changes
- Error code enum can grow to 100+ values without performance impact

### Integration Points

**How it Fits with Existing Architecture:**

1. **Repositories** (lib/data/repositories/)
   - Replace `executeQuery()` implementation in `BaseRepository`
   - Use `SupabaseErrorMapper` for all Supabase exceptions
   - All repositories inherit centralized error handling

2. **Services** (lib/data/services/)
   - `AuthService`: Remove `_mapAuthError()`, use `SupabaseErrorMapper.fromAuthException()`
   - Add error mappers for any new services

3. **Providers** (lib/providers/)
   - Catch `AppError` directly (already mapped by repositories)
   - Use `error.getUserMessage(localizations)` for UI display
   - Remove error handling logic from providers (move to repositories)

4. **UI** (lib/widgets/, lib/design_system/organisms/error/)
   - Update `ErrorDialog` and `ErrorSnackBar` to accept `AppError` and `AppLocalizations`
   - Display `error.getUserMessage(localizations)` instead of `error.userMessage`
   - Use `error.isRetryable` to conditionally show retry button

**Required Modifications:**

| File | Change Required | Effort |
|------|----------------|--------|
| `base_repository.dart` | Replace `_handlePostgrestException` with mapper | Low |
| `auth_service.dart` | Replace `_mapAuthError` with mapper | Low |
| `note_repository.dart` | No changes (inherits from BaseRepository) | None |
| `todo_list_repository.dart` | No changes (inherits from BaseRepository) | None |
| `list_repository.dart` | No changes (inherits from BaseRepository) | None |
| `space_repository.dart` | No changes (inherits from BaseRepository) | None |
| `content_provider.dart` | Update error display logic | Low |
| `spaces_provider.dart` | Update error display logic | Low |
| `auth_provider.dart` | Update error display logic | Low |
| `error_dialog.dart` | Accept localizations parameter | Low |
| `error_snackbar.dart` | Accept localizations parameter | Low |

### Risks and Mitigation

**Risk 1: Missing Error Code Mappings**
- **Description**: A third-party exception is thrown that doesn't have a mapper
- **Impact**: Falls back to generic error, poor UX
- **Mitigation**:
  - Add catch-all clause in each mapper that maps to generic error
  - Log unmapped exceptions in debug mode for discovery
  - Add integration tests that trigger all known exception types

**Risk 2: Incorrect Localization Keys**
- **Description**: Error code references a localization key that doesn't exist
- **Impact**: Runtime error or missing translation
- **Mitigation**:
  - Use code generation to ensure keys exist at compile time
  - Add validation tests that check all ErrorCode values have corresponding ARB entries
  - Generate TypeScript-style strict localization files

**Risk 3: Incomplete Migration**
- **Description**: Some parts of codebase still use old error handling
- **Impact**: Inconsistent error messages, English hardcoded strings
- **Mitigation**:
  - Migrate incrementally by feature area (auth → database → network)
  - Add deprecation warnings to old `AppError` factory constructors
  - Use linting rules to prevent direct exception throwing

**Risk 4: Breaking Changes in Supabase**
- **Description**: Supabase changes exception codes or structure
- **Impact**: Error mapper breaks, wrong error messages shown
- **Mitigation**:
  - Version lock Supabase dependencies
  - Add integration tests for error mapping
  - Monitor Supabase changelog for breaking changes
  - Document which Supabase version mappers are tested against

## Recommendations

### Recommended Approach: Error Code Registry with Domain Mappers (Approach 2)

**Why This Approach:**
1. ✅ **Solves All Three Problems**:
   - Eliminates keyword matching → Structured error codes with type safety
   - Centralizes error definitions → Single ErrorCode enum + mappers
   - Enables localization → First-class integration with Flutter intl

2. ✅ **Industry Standard**: Aligns with 2025 Flutter best practices for enterprise apps

3. ✅ **Future-Proof**: Easy to extend with new error codes, mappers, and languages

4. ✅ **Testable**: Each mapper can be unit tested independently

5. ✅ **Gradual Migration**: Can be implemented incrementally without breaking existing code

6. ✅ **Team Friendly**: Uses familiar patterns (enums, switch statements, inheritance)

### Alternative Approach (If Constrained)

If time/resources are severely limited, implement **Approach 1** (Enhanced Current System) as a stepping stone:
- Add more specific ErrorType values
- Add localization keys to AppError
- Improve exception type checking in `fromException()`
- Plan to migrate to Approach 2 in next major release

**Do NOT use Approach 3** (Either/Result) unless:
- Entire team is proficient in functional programming
- Starting a greenfield project
- Have time to refactor all async code

## Implementation Phasing

**Phase 1: Foundation** (1-2 days)
- ✅ Create `ErrorCode` enum with metadata
- ✅ Update `AppError` class to use ErrorCode
- ✅ Set up Flutter localization (l10n.yaml, ARB files)
- ✅ Add English error messages to app_en.arb

**Phase 2: Domain Mappers** (2-3 days)
- ✅ Create `SupabaseErrorMapper` with complete coverage
- ✅ Create `ValidationErrorMapper` for input validation
- ✅ Update `BaseRepository.executeQuery()` to use mappers
- ✅ Update `AuthService` to use mappers

**Phase 3: Provider Integration** (1-2 days)
- ✅ Update all providers to use new error handling
- ✅ Remove hardcoded error messages from providers
- ✅ Update error display logic to use localizations

**Phase 4: UI Updates** (1 day)
- ✅ Update `ErrorDialog` to use localized messages
- ✅ Update `ErrorSnackBar` to use localized messages
- ✅ Add retry logic based on `error.isRetryable`

**Phase 5: Testing & Migration** (2-3 days)
- ✅ Write unit tests for all error mappers
- ✅ Add integration tests for error flows
- ✅ Deprecate old error handling code
- ✅ Update documentation

**Total Estimated Effort**: 7-11 days

## References

### Documentation
- [Flutter Internationalization Official Guide](https://docs.flutter.dev/ui/accessibility-and-internationalization/internationalization)
- [Flutter Error Handling Official Guide](https://docs.flutter.dev/testing/errors)
- [fpdart Package Documentation](https://github.com/sandromaglione/fpdart)
- [Intl Package Documentation](https://pub.dev/packages/intl)
- [Flutter Localization 2025 Guide](https://phrase.com/blog/posts/flutter-localization/)

### Articles & Resources
- [Functional Error Handling with Either and fpdart](https://codewithandrea.com/articles/functional-error-handling-either-fpdart/)
- [Domain-Driven Exception Handling](https://github.com/bizz84/flutter-tips-and-tricks/blob/main/tips/0029-domain-driven-exception-handling/index.md)
- [Centralized Logging in Flutter](https://openmobilekit.medium.com/centralized-logging-error-handling-in-flutter-the-scalable-way-with-dynamic-logger-0cdcdce7bca9)
- [Flutter Exception Handling with Result Type](https://codewithandrea.com/articles/flutter-exception-handling-try-catch-result-type/)

### Code Repositories
- [fpdart GitHub](https://github.com/sandromaglione/fpdart)
- [Flutter Samples](https://github.com/flutter/samples)

### Supabase Error Codes Reference
- PostgreSQL Error Codes: https://www.postgresql.org/docs/current/errcodes-appendix.html
- Supabase Auth Error Codes: https://supabase.com/docs/reference/dart/auth-error-codes

## Appendix

### A. Example Error Flow (Current vs Recommended)

**Current Flow:**
```
1. Supabase throws PostgrestException('23505', 'duplicate key')
2. BaseRepository._handlePostgrestException() catches it
3. Returns Exception('A record with this ID already exists.')
4. Provider catches Exception, converts to AppError.unknown
5. AppError.getUserMessage() returns hardcoded English string
6. UI displays "An unexpected error occurred. Please try again."
```

**Recommended Flow:**
```
1. Supabase throws PostgrestException('23505', 'duplicate key')
2. BaseRepository.executeQuery() catches it
3. SupabaseErrorMapper.fromPostgrestException() maps to:
   AppError(code: ErrorCode.databaseUniqueConstraint, ...)
4. Provider catches AppError directly
5. UI calls error.getUserMessage(localizations)
6. Localizations returns translated string: "Ein Datensatz mit diesem Wert existiert bereits." (German)
```

### B. Validation Error Example

Creating a validation error with context:

```dart
// In a form validator
String? validateEmail(String? value) {
  if (value == null || value.isEmpty) {
    throw AppError(
      code: ErrorCode.validationRequired,
      message: 'Email is required',
      context: {'fieldName': 'Email'},
    );
  }

  if (!RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$').hasMatch(value)) {
    throw AppError(
      code: ErrorCode.validationInvalidFormat,
      message: 'Email format is invalid',
      context: {'fieldName': 'Email'},
    );
  }

  return null;
}

// ARB file:
{
  "error.validationRequired": "{fieldName} is required.",
  "error.validationInvalidFormat": "{fieldName} has an invalid format."
}

// Displayed to user:
// English: "Email is required."
// German: "E-Mail ist erforderlich."
```

### C. Unmapped Exception Fallback

```dart
class SupabaseErrorMapper {
  static AppError fromPostgrestException(PostgrestException exception) {
    // Try to map known codes
    switch (exception.code) {
      case '23505':
        return AppError(code: ErrorCode.databaseUniqueConstraint, ...);
      // ... other cases

      default:
        // Fallback for unknown codes - log for discovery
        debugPrint('Unmapped PostgrestException code: ${exception.code}');
        debugPrint('Message: ${exception.message}');

        return AppError(
          code: ErrorCode.databaseGeneric,
          message: 'Unmapped database error: ${exception.code}',
          technicalDetails: exception.message,
          context: {'errorCode': exception.code},
        );
    }
  }
}
```

### D. Testing Strategy

```dart
// Test that all ErrorCode values have localization keys
test('all error codes have localization keys', () {
  final localizations = AppLocalizations.delegate;

  for (final code in ErrorCode.values) {
    final key = code.localizationKey;
    expect(
      localizations.hasKey(key),
      isTrue,
      reason: 'Missing localization for $code (key: $key)',
    );
  }
});

// Test error mapper
test('SupabaseErrorMapper maps unique constraint violation', () {
  final exception = PostgrestException(code: '23505', message: 'duplicate key');
  final error = SupabaseErrorMapper.fromPostgrestException(exception);

  expect(error.code, ErrorCode.databaseUniqueConstraint);
  expect(error.message, contains('Unique constraint'));
});
```

### E. Additional Notes

**Future Enhancements:**
1. **Error Analytics**: Add tracking for which error codes occur most frequently
2. **Contextual Help**: Link error codes to documentation/help articles
3. **Error Recovery**: Implement automatic recovery strategies for certain error types
4. **Crash Reporting**: Integrate with Sentry/Firebase Crashlytics with structured error data

**Questions for Further Investigation:**
1. Should we use error codes (enums) or error classes (sealed classes with subtypes)?
2. Do we need different error severity levels for UI presentation?
3. Should errors include timestamp and correlation IDs for debugging?
4. Do we need separate error codes for similar errors in different domains?

**Related Topics Worth Exploring:**
- Offline error handling and queue strategies
- Error state persistence across app restarts
- Error reporting to backend analytics
- Accessibility considerations for error messages (screen readers, TalkBack)
