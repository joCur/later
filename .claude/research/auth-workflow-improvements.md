# Research: Authentication Workflow Improvements

## Executive Summary

The current authentication system has several UX issues that negatively impact user experience:
1. **Navigation on error**: Users get stuck on error screens with no way back
2. **Missing validation**: Users can submit forms without filling required fields
3. **No registration feedback**: No visual feedback or auto-login after successful registration
4. **AsyncValue error handling**: Errors redirect to error page via AuthGate instead of inline display

This research document outlines industry best practices for authentication UX in mobile applications and proposes specific implementation strategies to resolve these issues while leveraging the existing error handling infrastructure and Riverpod 3.0 state management.

**Key Recommendations:**
- Implement inline error display instead of navigation-based error handling
- Add real-time form validation with visual feedback
- Auto-login users after successful registration
- Add loading states and success feedback
- Prevent form submission when invalid

## Research Scope

### What Was Researched
- Current authentication implementation (SignInScreen, SignUpScreen, AuthStateController)
- Error handling system (AppError, ErrorHandler, error mappers)
- Flutter authentication UX best practices (2025)
- Riverpod 3.0 AsyncValue error handling patterns
- Mobile authentication UX patterns and industry standards

### What Was Explicitly Excluded
- Backend authentication changes (Supabase configuration)
- Password reset functionality (not mentioned in user requirements)
- Social login providers (OAuth, Google, Apple)
- Biometric authentication
- Two-factor authentication

### Research Methodology
1. Code analysis of existing auth implementation
2. Web research on Flutter authentication best practices
3. Review of mobile authentication UX patterns
4. Analysis of Riverpod state management patterns
5. Examination of the centralized error handling system

## Current State Analysis

### Existing Implementation

**Architecture:**
- **Clean Architecture**: Auth feature organized in layers (data → application → presentation)
- **State Management**: Riverpod 3.0 with code generation (`@riverpod`)
- **Error Handling**: Centralized error code system with localization support
- **Form Validation**: Basic TextFormField validation with GlobalKey<FormState>

**Current Flow:**
1. User enters credentials on SignInScreen/SignUpScreen
2. Form validates on submit using `_formKey.currentState!.validate()`
3. Controller method called (signIn/signUp)
4. Controller sets `state = AsyncValue.loading()`
5. Service layer performs operation
6. On error: `state = AsyncValue.error(error, stackTrace)`
7. AuthGate watches authStateControllerProvider
8. AuthGate.error() shows error page with no navigation back

**Key Files:**
- `lib/features/auth/presentation/screens/sign_in_screen.dart` - Login UI
- `lib/features/auth/presentation/screens/sign_up_screen.dart` - Registration UI
- `lib/features/auth/presentation/controllers/auth_state_controller.dart` - State management
- `lib/features/auth/application/auth_application_service.dart` - Business logic
- `lib/features/auth/data/services/auth_service.dart` - Supabase integration
- `lib/features/auth/presentation/widgets/auth_gate.dart` - Routes based on auth state

### Existing Strengths

1. **Comprehensive error handling infrastructure**:
   - Type-safe ErrorCode enum
   - Automatic error mapping from Supabase exceptions
   - Localized error messages (English + German)
   - Error metadata (retryable, severity)

2. **Well-structured validation**:
   - Email format validation (regex)
   - Password strength requirements (8 chars min for sign up)
   - Password confirmation matching
   - Empty field validation

3. **Good UX elements**:
   - Password visibility toggle
   - Auto-focus on email field
   - Keyboard navigation (textInputAction)
   - Loading states on buttons
   - Animated transitions
   - Password strength indicator on sign up

4. **Riverpod 3.0 best practices**:
   - Code generation with @riverpod
   - keepAlive for auth state
   - ref.mounted checks for async safety
   - Stream subscription for auth state changes

### Technical Debt and Limitations

**Issue #1: Error Navigation Problem**

The AuthGate widget shows an error page when auth state contains an error:

```dart
// auth_gate.dart:39-43
error: (error, stackTrace) => Scaffold(
  body: Center(
    child: Text('Authentication error: ${error.toString()}'),
  ),
),
```

**Problem**: This error screen has no navigation back to auth forms. Users are stuck.

**Root Cause**: AuthGate is the top-level router. When auth state is `AsyncValue.error`, the entire app shows the error page instead of the auth form with inline error.

**Issue #2: Missing Pre-Submit Validation**

Current validation only runs when user clicks submit:

```dart
// sign_in_screen.dart:51-54
Future<void> _handleSignIn() async {
  if (!_formKey.currentState!.validate()) {
    return;
  }
  // ... proceed with sign in
}
```

**Problem**: Users can click submit button with empty fields. Button becomes disabled during loading, but there's no visual feedback preventing submission before validation.

**Issue #3: No Registration Success Feedback**

After successful sign up:

```dart
// auth_state_controller.dart:53-70
Future<void> signUp({required String email, required String password}) async {
  state = const AsyncValue.loading();
  try {
    final user = await service.signUp(email: email, password: password);
    if (!ref.mounted) return;
    state = AsyncValue.data(user);  // ← Just sets state, no feedback
  } catch (error, stackTrace) {
    // ...
  }
}
```

**Problem**:
1. No visual success confirmation (checkmark, success message)
2. User is not automatically logged in (must manually go to sign in screen)
3. No indication that account was created successfully

**Issue #4: Duplicate Validation Logic**

Validation exists in three places:
1. UI layer (TextFormField validators)
2. Application layer (AuthApplicationService)
3. Widget state (password matching, strength indicator)

**Problem**:
- Code duplication
- Inconsistent validation rules
- Harder to maintain

**Issue #5: Form State Management**

Both screens use StatefulWidget with TextEditingController:

```dart
final _emailController = TextEditingController();
final _passwordController = TextEditingController();
```

**Problem**:
- Cannot validate in real-time without setState
- State loss if widget rebuilds
- Manual controller disposal required
- Harder to test

## Industry Standards

### Authentication UX Best Practices (2025)

Based on research from [Authgear](https://www.authgear.com/post/login-signup-ux-guide), [LearnUI](https://www.learnui.design/blog/tips-signup-login-ux.html), and [Flutter form validation guides](https://fluttercentral.com/forms/create-form-validation-flutter/):

**1. Inline Error Display**
- Show errors directly below input fields, not in separate screens
- Use red text and error icons for visual clarity
- Keep error messages concise and actionable
- Clear errors when user starts typing again

**2. Real-Time Validation**
- Validate as user types (debounced)
- Show checkmarks for valid fields
- Highlight invalid fields with red borders
- Provide immediate feedback on password strength

**3. Form Submission**
- Disable submit button when form is invalid
- Show loading spinner during async operations
- Provide success feedback (checkmark animation, success message)
- Auto-advance on success (don't make user manually navigate)

**4. Success Feedback**
- "Success! Redirecting..." message with animation
- Smooth transition to next screen
- Welcome message after login
- Avoid jarring transitions

**5. Persistent Sessions**
- Auto-login after successful registration
- Long-lived sessions (stay logged in)
- Skip login screen if already authenticated
- Clear session indicators

**6. Mobile-Specific**
- Auto-focus first input field
- Use appropriate keyboard types (email, password)
- Keep inputs visible when keyboard appears
- Minimize typing (show/hide password toggle)
- Large touch targets (48x48dp minimum)

### Flutter Form Validation Patterns

From [Form Validation in Flutter Guide](https://blog.logrocket.com/flutter-form-validation-complete-guide/):

**Pattern 1: Form + GlobalKey (Current Approach)**
```dart
final _formKey = GlobalKey<FormState>();
// Validate on submit
_formKey.currentState!.validate()
```

**Pros:**
- Built-in to Flutter
- Simple for basic validation
- No external dependencies

**Cons:**
- Only validates on demand (not real-time)
- Limited customization
- Hard to access validation state outside form

**Pattern 2: FormBuilder + Riverpod**
```dart
final emailProvider = StateProvider<String>((ref) => '');
final isEmailValidProvider = Provider<bool>((ref) {
  final email = ref.watch(emailProvider);
  return email.contains('@');
});
```

**Pros:**
- Real-time validation
- Reactive state updates
- Easy to test
- Can compose validation rules

**Cons:**
- More boilerplate
- Need to manage state manually

**Pattern 3: Riverpod Sugar (Package)**
```dart
@riverpodSugar
final email = Field<String>().email().required();
```

**Pros:**
- Minimal boilerplate
- Built-in validators
- Type-safe

**Cons:**
- External dependency
- Learning curve
- May not fit all use cases

### Riverpod Authentication State Management

From [Medium: Form validation using Riverpod](https://medium.com/@theaayushbhattarai/form-validation-using-riverpod-4e0f902331af) and [Stack Overflow discussions](https://stackoverflow.com/questions/64146088/handle-authentication-with-riverpod):

**Best Practice for Auth State:**
```dart
@riverpod
class AuthStateController extends _$AuthStateController {
  @override
  Future<User?> build() async {
    // Initialize auth state
  }

  Future<void> signIn() async {
    state = AsyncValue.loading();
    try {
      final user = await service.signIn();
      state = AsyncValue.data(user);
    } catch (e, st) {
      state = AsyncValue.error(e, st);
      // Don't navigate - let UI handle error display
    }
  }
}
```

**UI Pattern:**
```dart
// Listen to state changes for side effects
ref.listen(authStateControllerProvider, (previous, next) {
  next.whenOrNull(
    data: (user) {
      if (user != null) {
        // Navigate to home
        Navigator.pushReplacement(context, HomeScreen());
      }
    },
    error: (error, _) {
      // Show error inline (snackbar, banner)
      ErrorHandler.showErrorSnackBar(context, error);
    },
  );
});

// Build UI based on current state
final authState = ref.watch(authStateControllerProvider);
authState.when(
  data: (user) => SignInForm(isLoading: false),
  loading: () => SignInForm(isLoading: true),
  error: (error, _) => SignInForm(
    isLoading: false,
    error: error,
  ),
);
```

**Key Pattern:** Use `ref.listen` for side effects (navigation, snackbars) and `ref.watch` for UI state.

## Technical Analysis

### Approach 1: Refactor AuthGate to Handle Errors Inline

**Description**: Modify AuthGate to stay on auth screens when errors occur, pass error to screens as parameter.

**Implementation:**
```dart
// auth_gate.dart
@override
Widget build(BuildContext context, WidgetRef ref) {
  final authState = ref.watch(authStateControllerProvider);

  return authState.when(
    data: (user) {
      if (user != null) {
        return const HomeScreen();
      } else {
        return const SignInScreen(); // No error parameter
      }
    },
    loading: () => const Scaffold(
      body: Center(child: CircularProgressIndicator()),
    ),
    error: (error, stackTrace) {
      // Stay on auth screen, but show error
      return SignInScreen(initialError: error as AppError?);
    },
  );
}
```

**Pros:**
- Minimal changes to existing architecture
- Keeps AuthGate as central router
- Errors don't navigate away from auth

**Cons:**
- AuthGate becomes more complex
- Need to modify SignInScreen/SignUpScreen constructors
- Error state managed in two places (controller + widget parameter)
- Doesn't solve the problem of navigation between sign in/up with error

**Use Cases:**
- Quick fix for the navigation problem
- Minimal refactoring effort

**Code Example:**
```dart
class SignInScreen extends ConsumerStatefulWidget {
  const SignInScreen({this.initialError, super.key});

  final AppError? initialError;

  @override
  ConsumerState<SignInScreen> createState() => _SignInScreenState();
}

class _SignInScreenState extends ConsumerState<SignInScreen> {
  late final AppError? _displayError = widget.initialError;

  @override
  Widget build(BuildContext context) {
    // Show _displayError in banner
  }
}
```

### Approach 2: Use ref.listen for Error Handling (Recommended)

**Description**: Keep auth screens stateless for errors. Use `ref.listen` to show errors via snackbar/banner when they occur. Don't change auth state to error - reset after handling.

**Implementation:**
```dart
// sign_in_screen.dart
@override
Widget build(BuildContext context, WidgetRef ref) {
  final authState = ref.watch(authStateControllerProvider);

  // Listen for error state changes
  ref.listen(authStateControllerProvider, (previous, next) {
    next.whenOrNull(
      error: (error, _) {
        // Show error inline
        ErrorHandler.showErrorSnackBar(context, error as AppError);
        // Reset state back to unauthenticated after showing error
        Future.microtask(() {
          ref.read(authStateControllerProvider.notifier).resetToUnauthenticated();
        });
      },
    );
  });

  // Build form UI based on loading state only
  final isLoading = authState.isLoading;
  return _buildForm(isLoading);
}
```

**Controller Changes:**
```dart
@riverpod
class AuthStateController extends _$AuthStateController {
  // Add method to reset to unauthenticated without error
  void resetToUnauthenticated() {
    state = const AsyncValue.data(null);
  }

  Future<void> signIn({required String email, required String password}) async {
    state = const AsyncValue.loading();
    try {
      final user = await service.signIn(email: email, password: password);
      if (!ref.mounted) return;
      state = AsyncValue.data(user);
    } catch (error, stackTrace) {
      if (!ref.mounted) return;
      // Set error state (will be caught by ref.listen)
      state = AsyncValue.error(error, stackTrace);
      // State will be reset by UI after displaying error
    }
  }
}
```

**Pros:**
- Errors displayed inline without navigation
- Clean separation of concerns (state vs side effects)
- Follows Riverpod best practices
- No need to modify AuthGate
- Error state automatically resets after display
- Works with existing error infrastructure

**Cons:**
- Requires understanding of ref.listen pattern
- Need to add resetToUnauthenticated method
- Multiple listeners could fire (need to ensure idempotency)

**Use Cases:**
- Professional authentication UX
- Scalable error handling pattern
- Aligns with Riverpod 3.0 patterns

**Code Example:**
```dart
// Full implementation in sign_in_screen.dart
ref.listen(
  authStateControllerProvider,
  (previous, next) {
    next.whenOrNull(
      data: (user) {
        // Success! User is authenticated, AuthGate will handle navigation
        // Optional: Show success message
        if (previous?.isLoading == true && user != null) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Welcome back!')),
          );
        }
      },
      error: (error, _) {
        // Show error inline without navigation
        final appError = error as AppError;
        ErrorHandler.showErrorSnackBar(context, appError);

        // Reset auth state so AuthGate doesn't show error screen
        Future.microtask(() {
          ref.read(authStateControllerProvider.notifier).resetToUnauthenticated();
        });
      },
    );
  },
);
```

### Approach 3: Separate Auth Screens from AuthGate Entirely

**Description**: Create a dedicated AuthFlow widget that manages sign in/sign up screens internally. AuthGate only decides between AuthFlow and HomeScreen.

**Implementation:**
```dart
// auth_gate.dart
@override
Widget build(BuildContext context, WidgetRef ref) {
  final authState = ref.watch(authStateControllerProvider);

  return authState.when(
    data: (user) => user != null ? const HomeScreen() : const AuthFlow(),
    loading: () => const LoadingScreen(),
    error: (_, __) => const AuthFlow(), // Always show AuthFlow on error
  );
}

// auth_flow.dart
class AuthFlow extends ConsumerStatefulWidget {
  @override
  ConsumerState<AuthFlow> createState() => _AuthFlowState();
}

class _AuthFlowState extends ConsumerState<AuthFlow> {
  bool _showSignIn = true;

  void _toggleMode() {
    setState(() => _showSignIn = !_showSignIn);
  }

  @override
  Widget build(BuildContext context) {
    // Listen for auth errors
    ref.listen(authStateControllerProvider, (previous, next) {
      next.whenOrNull(
        error: (error, _) {
          ErrorHandler.showErrorSnackBar(context, error as AppError);
          ref.read(authStateControllerProvider.notifier).resetToUnauthenticated();
        },
      );
    });

    return _showSignIn
        ? SignInScreen(onNavigateToSignUp: _toggleMode)
        : SignUpScreen(onNavigateToSignIn: _toggleMode);
  }
}
```

**Pros:**
- Complete separation of auth routing from app routing
- Auth screens can freely navigate between each other
- Clean error handling within auth flow
- Easier to add more auth screens (forgot password, email verification)

**Cons:**
- More files and complexity
- Need to modify existing screen constructors
- Requires careful state management for navigation

**Use Cases:**
- Complex auth flows with multiple screens
- Future expansion (password reset, email verification)
- Clear architectural boundaries

### Approach 4: Inline Error Banner State

**Description**: Store error state locally in each auth screen instead of in controller. Controller only manages actual auth state (user/null).

**Implementation:**
```dart
class _SignInScreenState extends ConsumerState<SignInScreen> {
  AppError? _localError;

  Future<void> _handleSignIn() async {
    setState(() => _localError = null); // Clear previous error

    if (!_formKey.currentState!.validate()) {
      return;
    }

    try {
      await ref.read(authStateControllerProvider.notifier).signIn(
        email: _emailController.text.trim(),
        password: _passwordController.text,
      );
      // Success! AuthGate will navigate automatically
    } catch (error) {
      // Catch error locally
      setState(() {
        _localError = error is AppError ? error : ErrorHandler.convertToAppError(error);
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_localError != null) {
      // Show error banner
    }
  }
}
```

**Controller Changes:**
```dart
Future<void> signIn({required String email, required String password}) async {
  state = const AsyncValue.loading();

  final user = await service.signIn(email: email, password: password);
  // Let errors propagate instead of catching

  if (!ref.mounted) return;
  state = AsyncValue.data(user);
}
```

**Pros:**
- Error handling is local to each screen
- No need for ref.listen
- Controller only manages auth state (simpler)
- Error state doesn't interfere with AuthGate

**Cons:**
- Error state duplicated across screens
- Need to manually catch errors in widgets
- Loses centralized error handling benefits
- Breaking change to controller API

**Use Cases:**
- When errors should be scoped to specific screens
- Simpler mental model (error = local widget state)

## Tools and Libraries

### Option 1: riverpod_forms (Community Package)

- **Purpose**: Form validation with Riverpod state management
- **Maturity**: Beta (active development)
- **License**: MIT
- **Community**: Small but active
- **Integration Effort**: Medium
- **Key Features**:
  - Built-in validators
  - Real-time validation
  - Type-safe form state
  - Riverpod integration

**Verdict**: Not recommended. Adds dependency for functionality we can implement with existing tools.

### Option 2: flutter_form_builder

- **Purpose**: Comprehensive form building with built-in validation
- **Maturity**: Production-ready
- **License**: BSD
- **Community**: Large, well-maintained
- **Integration Effort**: High (different API)
- **Key Features**:
  - Rich set of form fields
  - Built-in validators
  - Conditional logic
  - Form state management

**Verdict**: Not recommended. Too heavyweight for our needs, requires significant refactoring.

### Option 3: reactive_forms

- **Purpose**: Model-driven forms inspired by Angular
- **Maturity**: Production-ready
- **License**: MIT
- **Community**: Medium, active
- **Integration Effort**: High
- **Key Features**:
  - Reactive form model
  - Complex validation
  - Form arrays and groups
  - Async validators

**Verdict**: Not recommended. Overkill for simple auth forms, steep learning curve.

### Option 4: Built-in Flutter + Riverpod (Recommended)

- **Purpose**: Use existing Form + TextFormField with Riverpod state
- **Maturity**: Production-ready
- **License**: N/A (built-in)
- **Community**: Largest possible
- **Integration Effort**: Low
- **Key Features**:
  - No dependencies
  - Familiar API
  - Works with existing code
  - Full control

**Verdict**: Recommended. Leverages existing tools, no new dependencies, minimal refactoring.

## Implementation Considerations

### Technical Requirements

**Dependencies:**
- No new dependencies required
- Uses existing Riverpod 3.0.3
- Uses existing error handling system
- Uses existing design system components

**Performance Implications:**
- Real-time validation may trigger rebuilds more frequently
- Use debouncing for async validation (email availability checks)
- ref.listen callbacks should be lightweight
- Consider using const widgets where possible

**Scalability Considerations:**
- Pattern scales to additional auth screens (password reset, email verification)
- Validation logic can be extracted to reusable functions
- Error handling pattern applies to all forms in app
- State management pattern consistent across features

**Security Aspects:**
- No changes to actual authentication mechanism
- Password visibility toggle already implemented
- Validation prevents common input errors
- Error messages don't leak sensitive information

### Integration Points

**How it fits with existing architecture:**
1. **Clean Architecture**: Changes isolated to presentation layer
2. **Error Handling**: Uses existing ErrorHandler, ErrorSnackBar
3. **Localization**: Uses existing AppLocalizations
4. **Design System**: Uses existing components (PrimaryButton, TextInputField)
5. **State Management**: Follows Riverpod 3.0 best practices

**Required Modifications:**
1. Add `resetToUnauthenticated()` method to AuthStateController
2. Add `ref.listen` blocks to SignInScreen and SignUpScreen
3. Modify error banner display logic (remove from when/error)
4. Add auto-login after successful registration
5. Add success feedback (optional but recommended)
6. Improve form validation (prevent empty submission)

**API Changes Needed:**
```dart
// AuthStateController additions
void resetToUnauthenticated() {
  state = const AsyncValue.data(null);
}

void showSuccessFeedback(BuildContext context, String message) {
  ScaffoldMessenger.of(context).showSnackBar(
    SnackBar(
      content: Text(message),
      backgroundColor: Colors.green,
      behavior: SnackBarBehavior.floating,
    ),
  );
}
```

**Database Impacts:**
- None (no changes to data layer)

### Risks and Mitigation

**Risk 1: ref.listen firing multiple times**
- **Mitigation**: Use `previous` parameter to check if state actually changed
- **Mitigation**: Ensure error display is idempotent
- **Mitigation**: Use Future.microtask for state reset to avoid race conditions

**Risk 2: Navigation after sign up breaks if auto-login fails**
- **Mitigation**: Sign up already returns User, no separate login needed
- **Mitigation**: Add error handling for unexpected sign up responses
- **Mitigation**: Test edge case where user is created but session fails

**Risk 3: Error state resets too quickly**
- **Mitigation**: SnackBar shows error for 4 seconds (default)
- **Mitigation**: Consider ErrorDialog for critical errors (persistent until dismissed)
- **Mitigation**: Use ErrorBanner for persistent but dismissible errors

**Risk 4: Breaking existing tests**
- **Mitigation**: Update tests to check for resetToUnauthenticated calls
- **Mitigation**: Mock ref.listen behavior in widget tests
- **Mitigation**: Add integration tests for full auth flow

**Fallback Options:**
- If Approach 2 proves problematic, fall back to Approach 1 (simpler but less clean)
- If ref.listen causes issues, use Approach 4 (local error state)
- Keep existing error page as fallback for unexpected errors

## Recommendations

### Recommended Approach: Hybrid Solution (Approach 2 + Validation Improvements)

Combine the best elements:

1. **Use ref.listen for error handling** (Approach 2)
   - Errors displayed inline via ErrorSnackBar
   - Auth state resets after error display
   - No navigation to error screen

2. **Add auto-login after registration**
   - Supabase already returns authenticated user after signUp
   - No additional work needed - just don't reset state

3. **Improve form validation**
   - Add real-time validation using autovalidateMode
   - Disable submit button when form invalid (track via _isFormValid state)
   - Show visual feedback (red borders, check marks)

4. **Add success feedback**
   - Brief success message before navigation
   - Smooth transition with animation
   - Welcome message on first login

**Implementation Priority:**

**Phase 1: Fix Critical Issues (High Priority)**
1. Add `resetToUnauthenticated()` to controller
2. Add `ref.listen` blocks to sign in/sign up screens
3. Remove auto-login after sign up (already works, just document)
4. Test error flow end-to-end

**Phase 2: Improve Validation (Medium Priority)**
1. Add `autovalidateMode: AutovalidateMode.onUserInteraction`
2. Track form validity in state
3. Disable submit button when invalid
4. Add visual validation indicators

**Phase 3: Polish UX (Low Priority)**
1. Add success feedback animations
2. Add welcome message after sign in
3. Improve error banner styling
4. Add haptic feedback on errors

**Alternative if constraints change:**
- If ref.listen proves too complex for team, use Approach 1 (pass error as param)
- If form validation needs to be more sophisticated, consider Approach 4 (local error state)

## References

### Documentation
- [Flutter Form Validation Guide - FlutterCentral](https://fluttercentral.com/forms/create-form-validation-flutter/)
- [Login & Signup UX Guide - Authgear](https://www.authgear.com/post/login-signup-ux-guide)
- [15 Tips for Better Signup/Login UX - LearnUI](https://www.learnui.design/blog/tips-signup-login-ux.html)
- [Flutter Form Validation Complete Guide - LogRocket](https://blog.logrocket.com/flutter-form-validation-complete-guide/)
- [Riverpod 3.0 Guide - Medium](https://medium.com/@jamalihassan0307/mastering-riverpod-3-0-the-ultimate-flutter-state-management-guide-cd89a6bb061d)

### Stack Overflow Resources
- [Handle authentication with Riverpod](https://stackoverflow.com/questions/64146088/handle-authentication-with-riverpod)
- [Form validation using Riverpod - Medium](https://medium.com/@theaayushbhattarai/form-validation-using-riverpod-4e0f902331af)

### API References
- [Flutter Form Widget](https://api.flutter.dev/flutter/widgets/Form-class.html)
- [Riverpod Documentation](https://riverpod.dev)
- [Supabase Auth Documentation](https://supabase.com/docs/reference/dart/auth-signin)

## Appendix

### Additional Notes

**Observations During Research:**

1. The existing error handling system is well-designed and comprehensive. The issue is not with error handling itself, but with how errors affect navigation via AuthGate.

2. The sign up flow already returns an authenticated user from Supabase. Auto-login after registration requires no backend changes - just avoid resetting auth state.

3. Both SignInScreen and SignUpScreen have nearly identical structure. Consider extracting common elements to reduce duplication in the future.

4. The password strength indicator on sign up is a good UX pattern that could be enhanced with real-time feedback.

5. Form validation is split between UI (TextFormField validators) and business logic (AuthApplicationService). This is acceptable but could be simplified.

### Questions for Further Investigation

1. Should we add email confirmation flow in the future? (Currently disabled for MVP)
2. Do we need "remember me" functionality? (Currently always persistent session)
3. Should we implement password reset functionality?
4. Do we need to handle rate limiting from Supabase more gracefully?
5. Should we add analytics/logging for auth failures?

### Related Topics Worth Exploring

1. **Biometric authentication**: Touch ID / Face ID integration
2. **Social login**: Google / Apple / GitHub OAuth
3. **Password strength requirements**: Enforce complexity rules
4. **Account security settings**: 2FA, security questions
5. **Session management**: Multiple device handling, force logout
6. **Onboarding flow**: First-time user experience after sign up
