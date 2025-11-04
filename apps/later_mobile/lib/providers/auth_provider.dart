import 'dart:async';

import 'package:flutter/widgets.dart';
import 'package:later_mobile/data/services/auth_service.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

/// Authentication status enum for the provider
enum AuthStatus {
  /// User is authenticated with an active session
  authenticated,

  /// User is not authenticated (no session)
  unauthenticated,

  /// Authentication state is being checked or changed
  loading,
}

/// Provider for managing authentication state
///
/// Wraps [AuthService] and provides state management using [ChangeNotifier].
/// Listens to authentication state changes and notifies listeners when:
/// - User signs in
/// - User signs out
/// - Session expires
/// - Authentication errors occur
///
/// Usage:
/// ```dart
/// MultiProvider(
///   providers: [
///     ChangeNotifierProvider(create: (_) => AuthProvider()),
///     // ... other providers
///   ],
///   child: MyApp(),
/// )
/// ```
class AuthProvider with ChangeNotifier {
  AuthProvider() {
    // Don't initialize synchronously - do it after first frame
    // to avoid blocking app startup
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _initialize();
    });
  }

  final AuthService _authService = AuthService();
  StreamSubscription<AuthState>? _authStateSubscription;

  /// Current authentication status
  /// Start as unauthenticated (will check after first frame)
  AuthStatus _authStatus = AuthStatus.unauthenticated;

  /// Currently authenticated user (null if not authenticated)
  User? _currentUser;

  /// Loading state for async operations
  bool _isLoading = false;

  /// Error message from last failed operation
  String? _errorMessage;

  /// Public getters
  AuthStatus get authStatus => _authStatus;
  User? get currentUser => _currentUser;
  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;

  /// Check if user is authenticated
  bool get isAuthenticated => _authStatus == AuthStatus.authenticated;

  /// Initialize the provider and listen to auth state changes
  /// This runs after the first frame to avoid blocking app startup
  void _initialize() {
    try {
      // Get initial auth state
      _currentUser = _authService.getCurrentUser();
      _authStatus = _currentUser != null
          ? AuthStatus.authenticated
          : AuthStatus.unauthenticated;

      // Listen to auth state changes
      _authStateSubscription =
          _authService.authStateChanges().listen((AuthState event) {
        _currentUser = event.session?.user;
        _authStatus = _currentUser != null
            ? AuthStatus.authenticated
            : AuthStatus.unauthenticated;
        notifyListeners();
      });
    } catch (e) {
      // Supabase not initialized - assume unauthenticated (offline mode)
      _currentUser = null;
      _authStatus = AuthStatus.unauthenticated;
    }

    // Notify listeners of initial state
    notifyListeners();
  }

  /// Sign up a new user with email and password
  Future<void> signUp({
    required String email,
    required String password,
  }) async {
    await _executeAuthOperation(() async {
      final user = await _authService.signUpWithEmail(
        email: email,
        password: password,
      );
      _currentUser = user;
      _authStatus = AuthStatus.authenticated;
    });
  }

  /// Sign in an existing user with email and password
  Future<void> signIn({
    required String email,
    required String password,
  }) async {
    await _executeAuthOperation(() async {
      final user = await _authService.signInWithEmail(
        email: email,
        password: password,
      );
      _currentUser = user;
      _authStatus = AuthStatus.authenticated;
    });
  }

  /// Sign out the current user
  Future<void> signOut() async {
    await _executeAuthOperation(() async {
      await _authService.signOut();
      _currentUser = null;
      _authStatus = AuthStatus.unauthenticated;
    });
  }

  /// Clear the current error message
  void clearError() {
    _errorMessage = null;
    notifyListeners();
  }

  /// Execute an authentication operation with error handling
  Future<void> _executeAuthOperation(Future<void> Function() operation) async {
    // Set loading state
    _isLoading = true;
    _errorMessage = null;
    _authStatus = AuthStatus.loading;
    notifyListeners();

    try {
      await operation();
      _errorMessage = null;
    } on AuthException catch (e) {
      _errorMessage = e.message;
      _authStatus = _currentUser != null
          ? AuthStatus.authenticated
          : AuthStatus.unauthenticated;
    } catch (e) {
      _errorMessage = 'An unexpected error occurred. Please try again.';
      _authStatus = _currentUser != null
          ? AuthStatus.authenticated
          : AuthStatus.unauthenticated;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  @override
  void dispose() {
    _authStateSubscription?.cancel();
    super.dispose();
  }
}
