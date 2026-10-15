import 'package:flutter_test/flutter_test.dart';
import 'package:kora/core/router/app_routes.dart';
import 'package:kora/core/router/app_session_state.dart';
import 'package:kora/core/router/route_guard.dart';

void main() {
  group('RouteGuard', () {
    const guard = RouteGuard();

    group('Uninitialized state', () {
      test('allows remaining on splash screen while bootstrapping', () {
        final session = AppSessionState();
        final redirect = guard.resolveRedirect(
          location: AppRoutes.splash,
          session: session,
        );

        expect(redirect, isNull);
        expect(session.intendedDestination, isNull);
      });

      test('redirects deep-link to splash and preserves destination', () {
        final session = AppSessionState();
        final redirect = guard.resolveRedirect(
          location: '/scan/result/scan-123',
          session: session,
        );

        expect(redirect, AppRoutes.splash);
        expect(session.intendedDestination, '/scan/result/scan-123');
      });

      test('sanitizes trailing slash before caching deep-link', () {
        final session = AppSessionState();
        final redirect = guard.resolveRedirect(
          location: '/routine/add/',
          session: session,
        );

        expect(redirect, AppRoutes.splash);
        expect(session.intendedDestination, '/routine/add');
      });
    });

    group('Splash exit transitions', () {
      test(
        'redirects from splash to onboarding welcome when onboarding pending',
        () {
          final session = AppSessionState(
            isInitialized: true,
          );
          final redirect = guard.resolveRedirect(
            location: AppRoutes.splash,
            session: session,
          );

          expect(redirect, AppRoutes.onboardingWelcome);
        },
      );

      test('redirects from splash to home when onboarding completed', () {
        final session = AppSessionState(
          isInitialized: true,
          isOnboardingCompleted: true,
        );
        final redirect = guard.resolveRedirect(
          location: AppRoutes.splash,
          session: session,
        );

        expect(redirect, AppRoutes.home);
      });

      test(
        'redirects from splash to preserved deep link and consumes it',
        () {
          final session = AppSessionState(
            isInitialized: true,
            isOnboardingCompleted: true,
            intendedDestination: '/progress/concern/redness',
          );
          final redirect = guard.resolveRedirect(
            location: AppRoutes.splash,
            session: session,
          );

          expect(redirect, '/progress/concern/redness');
          expect(session.intendedDestination, isNull);
        },
      );

      test(
        'redirects from splash to account secure when security needed',
        () {
          final session = AppSessionState(
            isInitialized: true,
            isOnboardingCompleted: true,
            isAccountSecureRequired: true,
          );
          final redirect = guard.resolveRedirect(
            location: AppRoutes.splash,
            session: session,
          );

          expect(redirect, AppRoutes.accountSecure);
        },
      );

      test(
        'redirects from splash to paywall when paywall enforced and not subbed',
        () {
          final session = AppSessionState(
            isInitialized: true,
            isOnboardingCompleted: true,
            isPaywallEnforced: true,
          );
          final redirect = guard.resolveRedirect(
            location: AppRoutes.splash,
            session: session,
          );

          expect(redirect, AppRoutes.paywall);
        },
      );
    });

    group('Onboarding gating', () {
      test(
        'allows free navigation in onboarding sub-routes when not completed',
        () {
          final session = AppSessionState(
            isInitialized: true,
          );

          expect(
            guard.resolveRedirect(
              location: AppRoutes.onboardingWelcome,
              session: session,
            ),
            isNull,
          );
          expect(
            guard.resolveRedirect(
              location: '/onboarding/quiz/2',
              session: session,
            ),
            isNull,
          );
          expect(
            guard.resolveRedirect(
              location: AppRoutes.onboardingCamera,
              session: session,
            ),
            isNull,
          );
          expect(
            guard.resolveRedirect(
              location: AppRoutes.onboardingReminder,
              session: session,
            ),
            isNull,
          );
        },
      );

      test('blocks non-onboarding routes when onboarding not completed', () {
        final session = AppSessionState(
          isInitialized: true,
        );

        final redirect = guard.resolveRedirect(
          location: AppRoutes.routine,
          session: session,
        );

        expect(redirect, AppRoutes.onboardingWelcome);
        expect(session.intendedDestination, AppRoutes.routine);
      });

      test(
        'prevents re-entering onboarding routes once onboarding is completed',
        () {
          final session = AppSessionState(
            isInitialized: true,
            isOnboardingCompleted: true,
          );

          expect(
            guard.resolveRedirect(
              location: AppRoutes.onboardingWelcome,
              session: session,
            ),
            AppRoutes.home,
          );
          expect(
            guard.resolveRedirect(
              location: '/onboarding/quiz/1',
              session: session,
            ),
            AppRoutes.home,
          );
          expect(
            guard.resolveRedirect(
              location: AppRoutes.onboardingBuild,
              session: session,
            ),
            AppRoutes.home,
          );
        },
      );

      test(
        'redirects to intended destination when completing onboarding',
        () {
          final session = AppSessionState(
            isInitialized: true,
            isOnboardingCompleted: true,
            intendedDestination: AppRoutes.scanCapture,
          );

          expect(
            guard.resolveRedirect(
              location: AppRoutes.onboardingQuestions,
              session: session,
            ),
            AppRoutes.scanCapture,
          );
          expect(session.intendedDestination, isNull);
        },
      );
    });

    group('Account secure checkpoint', () {
      test('redirects to account secure when required', () {
        final session = AppSessionState(
          isInitialized: true,
          isOnboardingCompleted: true,
          isAccountSecureRequired: true,
        );

        final redirect = guard.resolveRedirect(
          location: AppRoutes.home,
          session: session,
        );

        expect(redirect, AppRoutes.accountSecure);
      });

      test('allows remaining on account secure screen without loop', () {
        final session = AppSessionState(
          isInitialized: true,
          isOnboardingCompleted: true,
          isAccountSecureRequired: true,
        );

        final redirect = guard.resolveRedirect(
          location: AppRoutes.accountSecure,
          session: session,
        );

        expect(redirect, isNull);
      });
    });

    group('Paywall gating', () {
      test(
        'redirects gated routes to paywall when paywall enforced & unsubbed',
        () {
          final session = AppSessionState(
            isInitialized: true,
            isOnboardingCompleted: true,
            isPaywallEnforced: true,
          );

          expect(
            guard.resolveRedirect(
              location: AppRoutes.scanCapture,
              session: session,
            ),
            AppRoutes.paywall,
          );
          expect(
            guard.resolveRedirect(
              location: AppRoutes.experimentNew,
              session: session,
            ),
            AppRoutes.paywall,
          );
        },
      );

      test('allows remaining on paywall screen without loop', () {
        final session = AppSessionState(
          isInitialized: true,
          isOnboardingCompleted: true,
          isPaywallEnforced: true,
        );

        expect(
          guard.resolveRedirect(
            location: AppRoutes.paywall,
            session: session,
          ),
          isNull,
        );
      });

      test('allows profile help and privacy during paywall enforcement', () {
        final session = AppSessionState(
          isInitialized: true,
          isOnboardingCompleted: true,
          isPaywallEnforced: true,
        );

        expect(
          guard.resolveRedirect(
            location: AppRoutes.profileHelp,
            session: session,
          ),
          isNull,
        );
        expect(
          guard.resolveRedirect(
            location: AppRoutes.profilePrivacy,
            session: session,
          ),
          isNull,
        );
      });

      test('permits full access when user has active subscription', () {
        final session = AppSessionState(
          isInitialized: true,
          isOnboardingCompleted: true,
          isPaywallEnforced: true,
          hasActiveSubscription: true,
        );

        expect(
          guard.resolveRedirect(
            location: AppRoutes.scanCapture,
            session: session,
          ),
          isNull,
        );
        expect(
          guard.resolveRedirect(
            location: AppRoutes.routineAdd,
            session: session,
          ),
          isNull,
        );
      });
    });
  });
}
