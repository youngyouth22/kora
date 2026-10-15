// ignore_for_file: document_ignores
// ignore_for_file: prefer_initializing_formals

import 'package:flutter/foundation.dart';

/// Manages reactive authentication, onboarding, and subscription state
/// for GoRouter navigation and redirection.
///
/// Implements [ChangeNotifier] so GoRouter can listen for state mutations
/// and recalculate route guards without reconstructing the router instance.
class AppSessionState extends ChangeNotifier {
  /// Creates an [AppSessionState] with optional initial parameters.
  AppSessionState({
    bool isInitialized = false,
    bool isAuthenticated = false,
    bool isOnboardingCompleted = false,
    bool hasActiveSubscription = false,
    bool isPaywallEnforced = false,
    bool isAccountSecureRequired = false,
    String? intendedDestination,
  }) : _isInitialized = isInitialized,
       _isAuthenticated = isAuthenticated,
       _isOnboardingCompleted = isOnboardingCompleted,
       _hasActiveSubscription = hasActiveSubscription,
       _isPaywallEnforced = isPaywallEnforced,
       _isAccountSecureRequired = isAccountSecureRequired,
       _intendedDestination = intendedDestination;

  bool _isInitialized;
  bool _isAuthenticated;
  bool _isOnboardingCompleted;
  bool _hasActiveSubscription;
  bool _isPaywallEnforced;
  bool _isAccountSecureRequired;
  String? _intendedDestination;

  /// Whether the core app dependencies, Supabase session, and Drift DB
  /// have completed bootstrapping on splash.
  bool get isInitialized => _isInitialized;

  /// Whether the user has an active authenticated session.
  bool get isAuthenticated => _isAuthenticated;

  /// Whether the user has completed the onboarding flow.
  bool get isOnboardingCompleted => _isOnboardingCompleted;

  /// Whether the user has an active paid subscription or trial.
  bool get hasActiveSubscription => _hasActiveSubscription;

  /// Whether monetization paywall is hard-gated for app access.
  bool get isPaywallEnforced => _isPaywallEnforced;

  /// Whether the user needs to complete account security verification.
  bool get isAccountSecureRequired => _isAccountSecureRequired;

  /// The deferred deep-link target path to restore after onboarding or auth.
  String? get intendedDestination => _intendedDestination;

  /// Marks the app initialization complete with the given session state.
  void completeInitialization({
    required bool isOnboardingCompleted,
    bool isAuthenticated = false,
    bool hasActiveSubscription = false,
    bool isPaywallEnforced = false,
    bool isAccountSecureRequired = false,
  }) {
    _isInitialized = true;
    _isOnboardingCompleted = isOnboardingCompleted;
    _isAuthenticated = isAuthenticated;
    _hasActiveSubscription = hasActiveSubscription;
    _isPaywallEnforced = isPaywallEnforced;
    _isAccountSecureRequired = isAccountSecureRequired;
    notifyListeners();
  }

  /// Updates the onboarding completion status.
  void setOnboardingCompleted({required bool completed}) {
    if (_isOnboardingCompleted == completed) return;
    _isOnboardingCompleted = completed;
    notifyListeners();
  }

  /// Updates authentication status.
  void setAuthenticated({required bool authenticated}) {
    if (_isAuthenticated == authenticated) return;
    _isAuthenticated = authenticated;
    notifyListeners();
  }

  /// Updates subscription and paywall gating conditions.
  void setSubscriptionStatus({
    required bool hasActiveSubscription,
    bool? isPaywallEnforced,
  }) {
    var changed = false;
    if (_hasActiveSubscription != hasActiveSubscription) {
      _hasActiveSubscription = hasActiveSubscription;
      changed = true;
    }
    if (isPaywallEnforced != null && _isPaywallEnforced != isPaywallEnforced) {
      _isPaywallEnforced = isPaywallEnforced;
      changed = true;
    }
    if (changed) {
      notifyListeners();
    }
  }

  /// Updates whether account security is mandatory.
  void setAccountSecureRequired({required bool required}) {
    if (_isAccountSecureRequired == required) return;
    _isAccountSecureRequired = required;
    notifyListeners();
  }

  /// Saves an intended deep-link route to restore once onboarding or auth ends.
  void setIntendedDestination(String? path) {
    if (_intendedDestination == path) return;
    _intendedDestination = path;
    notifyListeners();
  }

  /// Consumes and clears the intended destination path.
  String? consumeIntendedDestination() {
    final destination = _intendedDestination;
    _intendedDestination = null;
    return destination;
  }

  /// Resets the session state back to default uninitialized state.
  void reset() {
    _isInitialized = false;
    _isAuthenticated = false;
    _isOnboardingCompleted = false;
    _hasActiveSubscription = false;
    _isPaywallEnforced = false;
    _isAccountSecureRequired = false;
    _intendedDestination = null;
    notifyListeners();
  }
}
