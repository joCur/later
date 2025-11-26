import 'dart:async';
import 'package:flutter/foundation.dart';

/// ChangeNotifier wrapper for auth stream to work with go_router
///
/// go_router's `refreshListenable` expects a ChangeNotifier, but our
/// auth stream provides a `Stream<T>`. This class bridges the gap by:
///
/// 1. Subscribing to any stream
/// 2. Calling notifyListeners() on stream events
/// 3. Converting to broadcast stream for multiple listeners
/// 4. Properly disposing the subscription
///
/// This is a generic wrapper that works with any stream type,
/// decoupling routing infrastructure from auth implementation details.
///
/// Usage:
/// ```dart
/// final authStream = ref.read(authApplicationServiceProvider).authStateChanges()
///     .map((authState) => authState.session?.user);
///
/// GoRouter(
///   refreshListenable: GoRouterRefreshStream(authStream),
///   redirect: (context, state) {
///     // Redirect logic based on auth state
///   },
/// )
/// ```
///
/// Reference: https://q.agency/blog/handling-authentication-state-with-go_router-and-riverpod/
class GoRouterRefreshStream extends ChangeNotifier {
  /// Creates a ChangeNotifier that triggers on stream events
  ///
  /// Accepts any stream type, making this a reusable utility for
  /// integrating streams with go_router's refreshListenable.
  GoRouterRefreshStream(Stream<dynamic> stream) {
    // Convert to broadcast stream to support multiple listeners
    final broadcastStream = stream.asBroadcastStream();

    // Subscribe to stream and notify listeners on changes
    _subscription = broadcastStream.listen(
      (_) {
        notifyListeners();
      },
    );
  }

  late final StreamSubscription<dynamic> _subscription;

  @override
  void dispose() {
    _subscription.cancel();
    super.dispose();
  }
}
