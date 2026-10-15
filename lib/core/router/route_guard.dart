// ignore_for_file: document_ignores

import 'package:flutter/widgets.dart';
import 'package:go_router/go_router.dart';
import 'package:kora/core/router/app_routes.dart';
import 'package:kora/core/router/app_session_state.dart';

/// Pure, deterministic route redirection resolver for Kora.
///
/// Ensures resilient navigation, prevents infinite redirect cycles,
/// and handles deep linking preservation, onboarding gating, and
/// paywall checkpoints.
class RouteGuard {
  /// Creates a [RouteGuard].
  const RouteGuard();

  /// Resolves the next route redirect based on the current URI [location]
  /// and the active [session] state.
  ///
  /// Returns `null` if navigation to [location] is permitted without redirect.
  String? resolveRedirect({
    required String location,
    required AppSessionState session,
  }) {
    final sanitizedLocation = _sanitize(location);

    // 1. Bootstrapping / Initialization Phase
    if (!session.isInitialized) {
      if (sanitizedLocation == AppRoutes.splash) {
        return null;
      }
      // Preserve deep link destination for post-initialization restoration
      if (session.intendedDestination == null &&
          _isValidDeepLink(sanitizedLocation)) {
        session.setIntendedDestination(sanitizedLocation);
      }
      return AppRoutes.splash;
    }

    // 2. Active Session on Splash Screen
    if (sanitizedLocation == AppRoutes.splash) {
      if (!session.isOnboardingCompleted) {
        return AppRoutes.onboardingWelcome;
      }
      if (session.isAccountSecureRequired) {
        return AppRoutes.accountSecure;
      }
      if (session.isPaywallEnforced && !session.hasActiveSubscription) {
        return AppRoutes.paywall;
      }

      // Check for deep link restoration
      final intended = session.consumeIntendedDestination();
      if (intended != null &&
          intended != AppRoutes.splash &&
          !_isOnboardingRoute(intended)) {
        return intended;
      }
      return AppRoutes.home;
    }

    // 3. User has NOT completed onboarding
    if (!session.isOnboardingCompleted) {
      if (_isOnboardingRoute(sanitizedLocation)) {
        return null; // Allowed to freely traverse onboarding sequence
      }

      // Block access to authenticated app routes, preserve destination
      if (_isValidDeepLink(sanitizedLocation)) {
        session.setIntendedDestination(sanitizedLocation);
      }
      return AppRoutes.onboardingWelcome;
    }

    // 4. User HAS completed onboarding but tries to re-enter onboarding
    if (session.isOnboardingCompleted &&
        _isOnboardingRoute(sanitizedLocation)) {
      final intended = session.consumeIntendedDestination();
      if (intended != null &&
          intended != AppRoutes.splash &&
          !_isOnboardingRoute(intended)) {
        return intended;
      }
      return AppRoutes.home;
    }

    // 5. Account Security Checkpoint
    if (session.isAccountSecureRequired) {
      if (sanitizedLocation == AppRoutes.accountSecure) {
        return null;
      }
      return AppRoutes.accountSecure;
    }

    // 6. Monetization / Hard Paywall Gate
    if (session.isPaywallEnforced && !session.hasActiveSubscription) {
      if (sanitizedLocation == AppRoutes.paywall) {
        return null;
      }
      if (_isPaywallGatedRoute(sanitizedLocation)) {
        return AppRoutes.paywall;
      }
    }

    // 7. Navigation is allowed
    return null;
  }

  /// GoRouter-compatible redirect callback adapter.
  String? call(
    BuildContext? context,
    GoRouterState state,
    AppSessionState session,
  ) {
    final target = resolveRedirect(
      location: state.matchedLocation,
      session: session,
    );

    // Safeguard: Never redirect to the exact location currently matched
    if (target == state.matchedLocation) {
      return null;
    }
    return target;
  }

  /// Sanitizes raw URI string (removes trailing slashes, empty fallbacks).
  static String _sanitize(String uri) {
    if (uri.isEmpty) return AppRoutes.splash;
    if (uri.length > 1 && uri.endsWith('/')) {
      return uri.substring(0, uri.length - 1);
    }
    return uri;
  }

  /// Checks whether a given path belongs to the onboarding flow.
  static bool _isOnboardingRoute(String path) {
    return path.startsWith('/onboarding');
  }

  /// Checks whether a given path is an eligible deep-link candidate.
  static bool _isValidDeepLink(String path) {
    if (path == AppRoutes.splash) return false;
    if (_isOnboardingRoute(path)) return false;
    return true;
  }

  /// Checks whether a given path is gated behind the paywall when enforced.
  static bool _isPaywallGatedRoute(String path) {
    // Paywall itself and security screen are never blocked
    if (path == AppRoutes.paywall || path == AppRoutes.accountSecure) {
      return false;
    }
    // Profile settings / help are kept accessible
    if (path == AppRoutes.profile ||
        path == AppRoutes.profileHelp ||
        path == AppRoutes.profilePrivacy ||
        path == AppRoutes.profileSubscription) {
      return false;
    }
    return true;
  }
}
