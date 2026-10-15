import 'package:flutter_test/flutter_test.dart';
import 'package:kora/core/router/app_session_state.dart';

void main() {
  group('AppSessionState', () {
    test('initializes with default uninitialized state', () {
      final state = AppSessionState();

      expect(state.isInitialized, isFalse);
      expect(state.isAuthenticated, isFalse);
      expect(state.isOnboardingCompleted, isFalse);
      expect(state.hasActiveSubscription, isFalse);
      expect(state.isPaywallEnforced, isFalse);
      expect(state.isAccountSecureRequired, isFalse);
      expect(state.intendedDestination, isNull);
    });

    test('completeInitialization updates values and notifies listeners', () {
      var notificationCount = 0;
      final state = AppSessionState()
        ..addListener(() => notificationCount++)
        ..completeInitialization(
          isOnboardingCompleted: true,
          isAuthenticated: true,
          hasActiveSubscription: true,
        );

      expect(state.isInitialized, isTrue);
      expect(state.isOnboardingCompleted, isTrue);
      expect(state.isAuthenticated, isTrue);
      expect(state.hasActiveSubscription, isTrue);
      expect(state.isPaywallEnforced, isFalse);
      expect(state.isAccountSecureRequired, isFalse);
      expect(notificationCount, 1);
    });

    test('setOnboardingCompleted notifies only on real change', () {
      var notificationCount = 0;
      final state = AppSessionState()
        ..addListener(() => notificationCount++)
        ..setOnboardingCompleted(completed: true);

      expect(state.isOnboardingCompleted, isTrue);
      expect(notificationCount, 1);

      state.setOnboardingCompleted(completed: true);
      expect(notificationCount, 1);
    });

    test('setAuthenticated notifies only on change', () {
      var notificationCount = 0;
      final state = AppSessionState()
        ..addListener(() => notificationCount++)
        ..setAuthenticated(authenticated: true);

      expect(state.isAuthenticated, isTrue);
      expect(notificationCount, 1);

      state.setAuthenticated(authenticated: true);
      expect(notificationCount, 1);
    });

    test('setSubscriptionStatus modifies flags and notifies', () {
      var notificationCount = 0;
      final state = AppSessionState()
        ..addListener(() => notificationCount++)
        ..setSubscriptionStatus(
          hasActiveSubscription: true,
          isPaywallEnforced: true,
        );

      expect(state.hasActiveSubscription, isTrue);
      expect(state.isPaywallEnforced, isTrue);
      expect(notificationCount, 1);

      // Repeat with same values
      state.setSubscriptionStatus(
        hasActiveSubscription: true,
        isPaywallEnforced: true,
      );
      expect(notificationCount, 1);
    });

    test('setAccountSecureRequired updates properly', () {
      var notificationCount = 0;
      final state = AppSessionState()
        ..addListener(() => notificationCount++)
        ..setAccountSecureRequired(required: true);

      expect(state.isAccountSecureRequired, isTrue);
      expect(notificationCount, 1);

      state.setAccountSecureRequired(required: true);
      expect(notificationCount, 1);
    });

    test('saves and consumes intended deep-link destination', () {
      var notificationCount = 0;
      final state = AppSessionState()
        ..addListener(() => notificationCount++)
        ..setIntendedDestination('/scan/result/42');

      expect(state.intendedDestination, '/scan/result/42');
      expect(notificationCount, 1);

      final consumed = state.consumeIntendedDestination();
      expect(consumed, '/scan/result/42');
      expect(state.intendedDestination, isNull);
    });

    test('reset clears all session parameters and notifies', () {
      var notificationCount = 0;
      final state =
          AppSessionState(
              isInitialized: true,
              isAuthenticated: true,
              isOnboardingCompleted: true,
              hasActiveSubscription: true,
              isPaywallEnforced: true,
              isAccountSecureRequired: true,
              intendedDestination: '/routine',
            )
            ..addListener(() => notificationCount++)
            ..reset();

      expect(state.isInitialized, isFalse);
      expect(state.isAuthenticated, isFalse);
      expect(state.isOnboardingCompleted, isFalse);
      expect(state.hasActiveSubscription, isFalse);
      expect(state.isPaywallEnforced, isFalse);
      expect(state.isAccountSecureRequired, isFalse);
      expect(state.intendedDestination, isNull);
      expect(notificationCount, 1);
    });
  });
}
