// ignore_for_file: document_ignores

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:get_it/get_it.dart';
import 'package:go_router/go_router.dart';
import 'package:kora/core/router/app_routes.dart';
import 'package:kora/core/router/app_session_state.dart';
import 'package:kora/core/router/kora_shell_scaffold.dart';
import 'package:kora/core/router/route_error_screen.dart';
import 'package:kora/core/router/route_guard.dart';
import 'package:kora/core/router/route_screen_placeholder.dart';
import 'package:kora/core/router/route_transitions.dart';
import 'package:kora/features/guided_capture/guided_capture_injection.dart';
import 'package:kora/features/guided_capture/presentation/bloc/guided_capture_bloc.dart';
import 'package:kora/features/guided_capture/presentation/pages/guided_capture_page.dart';
import 'package:kora/features/onboarding/onboarding_injection.dart';
import 'package:kora/features/onboarding/presentation/bloc/onboarding_bloc.dart';
import 'package:kora/features/onboarding/presentation/pages/demographics_screen.dart';
import 'package:kora/features/onboarding/presentation/pages/disclaimer_screen.dart';
import 'package:kora/features/onboarding/presentation/pages/mascot_screen.dart';
import 'package:kora/features/onboarding/presentation/pages/quiz_questions_screen.dart';
import 'package:kora/features/onboarding/presentation/pages/welcome_screen.dart';
import 'package:kora/features/splash/presentation/bloc/splash_bloc.dart';
import 'package:kora/features/splash/presentation/pages/splash_screen.dart';
import 'package:kora/features/splash/splash_injection.dart';

/// Top-level factory for creating the enterprise [GoRouter] configuration.
class AppRouter {
  /// Creates an [AppRouter] instance with optional dependencies.
  AppRouter({
    AppSessionState? sessionState,
    RouteGuard? routeGuard,
    GlobalKey<NavigatorState>? rootNavigatorKey,
  }) : _sessionState = sessionState ?? AppSessionState(),
       _routeGuard = routeGuard ?? const RouteGuard(),
       _rootNavigatorKey =
           rootNavigatorKey ?? GlobalKey<NavigatorState>(debugLabel: 'root') {
    _router = _buildRouter();
  }

  final AppSessionState _sessionState;
  final RouteGuard _routeGuard;
  final GlobalKey<NavigatorState> _rootNavigatorKey;
  late final GoRouter _router;

  /// Underlying configured [GoRouter] instance.
  GoRouter get router => _router;

  /// Active [AppSessionState] powering the route guard.
  AppSessionState get sessionState => _sessionState;

  GoRouter _buildRouter() {
    return GoRouter(
      navigatorKey: _rootNavigatorKey,
      initialLocation: AppRoutes.splash,
      refreshListenable: _sessionState,
      redirect: (context, state) => _routeGuard(context, state, _sessionState),
      errorBuilder: (context, state) => RouteErrorScreen(
        errorMessage: state.error?.message,
      ),
      routes: [
        // =====================================================================
        // ROOT / SPLASH
        // =====================================================================
        GoRoute(
          path: AppRoutes.splash,
          name: AppRoutes.splashName,
          parentNavigatorKey: _rootNavigatorKey,
          pageBuilder: (context, state) {
            final getIt = GetIt.instance;
            if (!getIt.isRegistered<SplashBloc>()) {
              initSplashInjection(getIt);
            }
            return buildKoraTransitionPage(
              key: state.pageKey,
              name: state.name,
              child: SplashScreen(
                sessionState: _sessionState,
              ),
            );
          },
        ),

        // =====================================================================
        // ONBOARDING FULL-SCREEN FLOW
        // =====================================================================
        ShellRoute(
          parentNavigatorKey: _rootNavigatorKey,
          builder: (context, state, child) {
            final getIt = GetIt.instance;
            if (!getIt.isRegistered<OnboardingBloc>()) {
              initOnboardingInjection(getIt);
            }
            return BlocProvider<OnboardingBloc>(
              create: (_) => getIt<OnboardingBloc>(),
              child: child,
            );
          },
          routes: [
            GoRoute(
              path: AppRoutes.onboardingWelcome,
              name: AppRoutes.onboardingWelcomeName,
              pageBuilder: (context, state) => buildKoraTransitionPage(
                key: state.pageKey,
                name: state.name,
                child: const WelcomeScreen(),
              ),
            ),
            GoRoute(
              path: AppRoutes.onboardingMascot,
              name: AppRoutes.onboardingMascotName,
              pageBuilder: (context, state) => buildKoraTransitionPage(
                key: state.pageKey,
                name: state.name,
                child: const MascotScreen(),
              ),
            ),
            GoRoute(
              path: AppRoutes.onboardingDemographics,
              name: AppRoutes.onboardingDemographicsName,
              pageBuilder: (context, state) => buildKoraTransitionPage(
                key: state.pageKey,
                name: state.name,
                child: const DemographicsScreen(),
              ),
            ),
            GoRoute(
              path: AppRoutes.onboardingDisclaimer,
              name: AppRoutes.onboardingDisclaimerName,
              pageBuilder: (context, state) => buildKoraTransitionPage(
                key: state.pageKey,
                name: state.name,
                child: const DisclaimerScreen(),
              ),
            ),
            GoRoute(
              path: AppRoutes.onboardingQuestions,
              name: AppRoutes.onboardingQuestionsName,
              pageBuilder: (context, state) => buildKoraTransitionPage(
                key: state.pageKey,
                name: state.name,
                child: QuizQuestionsScreen(
                  sessionState: _sessionState,
                ),
              ),
            ),
          ],
        ),
        GoRoute(
          path: AppRoutes.onboardingQuiz,
          name: AppRoutes.onboardingQuizName,
          parentNavigatorKey: _rootNavigatorKey,
          pageBuilder: (context, state) => buildKoraTransitionPage(
            key: state.pageKey,
            name: state.name,
            child: RouteScreenPlaceholder(
              title: 'Skin Assessment Quiz',
              routePath: AppRoutes.onboardingQuiz,
              parameters: state.pathParameters,
            ),
          ),
        ),
        GoRoute(
          path: AppRoutes.onboardingBuild,
          name: AppRoutes.onboardingBuildName,
          parentNavigatorKey: _rootNavigatorKey,
          pageBuilder: (context, state) => buildKoraTransitionPage(
            key: state.pageKey,
            name: state.name,
            child: const RouteScreenPlaceholder(
              title: 'Building Routine',
              routePath: AppRoutes.onboardingBuild,
            ),
          ),
        ),
        GoRoute(
          path: AppRoutes.onboardingHow,
          name: AppRoutes.onboardingHowName,
          parentNavigatorKey: _rootNavigatorKey,
          pageBuilder: (context, state) => buildKoraTransitionPage(
            key: state.pageKey,
            name: state.name,
            child: const RouteScreenPlaceholder(
              title: 'How Kora Works',
              routePath: AppRoutes.onboardingHow,
            ),
          ),
        ),
        GoRoute(
          path: AppRoutes.onboardingConsent,
          name: AppRoutes.onboardingConsentName,
          parentNavigatorKey: _rootNavigatorKey,
          pageBuilder: (context, state) => buildKoraTransitionPage(
            key: state.pageKey,
            name: state.name,
            child: const RouteScreenPlaceholder(
              title: 'Consent & Privacy',
              routePath: AppRoutes.onboardingConsent,
            ),
          ),
        ),
        GoRoute(
          path: AppRoutes.onboardingCamera,
          name: AppRoutes.onboardingCameraName,
          parentNavigatorKey: _rootNavigatorKey,
          pageBuilder: (context, state) => buildKoraTransitionPage(
            key: state.pageKey,
            name: state.name,
            child: const RouteScreenPlaceholder(
              title: 'Camera Permission',
              routePath: AppRoutes.onboardingCamera,
            ),
          ),
        ),
        GoRoute(
          path: AppRoutes.onboardingReminder,
          name: AppRoutes.onboardingReminderName,
          parentNavigatorKey: _rootNavigatorKey,
          pageBuilder: (context, state) => buildKoraTransitionPage(
            key: state.pageKey,
            name: state.name,
            child: const RouteScreenPlaceholder(
              title: 'Scan Reminder',
              routePath: AppRoutes.onboardingReminder,
            ),
          ),
        ),

        // =====================================================================
        // SCAN FULL-SCREEN WORKFLOW
        // =====================================================================
        GoRoute(
          path: AppRoutes.scanGuide,
          name: AppRoutes.scanGuideName,
          parentNavigatorKey: _rootNavigatorKey,
          pageBuilder: (context, state) => buildKoraTransitionPage(
            key: state.pageKey,
            name: state.name,
            child: const RouteScreenPlaceholder(
              title: 'Scan Guide',
              routePath: AppRoutes.scanGuide,
            ),
          ),
        ),
        GoRoute(
          path: AppRoutes.scanCapture,
          name: AppRoutes.scanCaptureName,
          parentNavigatorKey: _rootNavigatorKey,
          pageBuilder: (context, state) {
            final getIt = GetIt.instance;
            if (!getIt.isRegistered<GuidedCaptureBloc>()) {
              initGuidedCaptureInjection(getIt);
            }
            return buildKoraTransitionPage(
              key: state.pageKey,
              name: state.name,
              child: GuidedCapturePage(
                onCaptureSuccess: (photo) =>
                    context.push<void>(AppRoutes.scanReview, extra: photo.path),
              ),
            );
          },
        ),
        GoRoute(
          path: AppRoutes.scanReview,
          name: AppRoutes.scanReviewName,
          parentNavigatorKey: _rootNavigatorKey,
          pageBuilder: (context, state) => buildKoraTransitionPage(
            key: state.pageKey,
            name: state.name,
            child: const RouteScreenPlaceholder(
              title: 'Review Photo Quality',
              routePath: AppRoutes.scanReview,
            ),
          ),
        ),
        GoRoute(
          path: AppRoutes.scanAnalyzing,
          name: AppRoutes.scanAnalyzingName,
          parentNavigatorKey: _rootNavigatorKey,
          pageBuilder: (context, state) => buildKoraTransitionPage(
            key: state.pageKey,
            name: state.name,
            child: const RouteScreenPlaceholder(
              title: 'Analyzing Skin',
              routePath: AppRoutes.scanAnalyzing,
              showBackButton: false,
            ),
          ),
        ),
        GoRoute(
          path: AppRoutes.scanResult,
          name: AppRoutes.scanResultName,
          parentNavigatorKey: _rootNavigatorKey,
          pageBuilder: (context, state) => buildKoraTransitionPage(
            key: state.pageKey,
            name: state.name,
            child: RouteScreenPlaceholder(
              title: 'Scan Result',
              routePath: AppRoutes.scanResult,
              parameters: state.pathParameters,
            ),
          ),
        ),

        // =====================================================================
        // PAYWALL & ACCOUNT SECURITY
        // =====================================================================
        GoRoute(
          path: AppRoutes.paywall,
          name: AppRoutes.paywallName,
          parentNavigatorKey: _rootNavigatorKey,
          pageBuilder: (context, state) => buildKoraTransitionPage(
            key: state.pageKey,
            name: state.name,
            child: const RouteScreenPlaceholder(
              title: 'Unlock Kora Premium',
              routePath: AppRoutes.paywall,
            ),
          ),
        ),
        GoRoute(
          path: AppRoutes.accountSecure,
          name: AppRoutes.accountSecureName,
          parentNavigatorKey: _rootNavigatorKey,
          pageBuilder: (context, state) => buildKoraTransitionPage(
            key: state.pageKey,
            name: state.name,
            child: const RouteScreenPlaceholder(
              title: 'Secure Account',
              routePath: AppRoutes.accountSecure,
            ),
          ),
        ),

        // =====================================================================
        // EXPERIMENT MODAL WORKFLOW
        // =====================================================================
        GoRoute(
          path: AppRoutes.experimentNew,
          name: AppRoutes.experimentNewName,
          parentNavigatorKey: _rootNavigatorKey,
          pageBuilder: (context, state) => buildKoraTransitionPage(
            key: state.pageKey,
            name: state.name,
            child: const RouteScreenPlaceholder(
              title: 'New Experiment',
              routePath: AppRoutes.experimentNew,
            ),
          ),
        ),
        GoRoute(
          path: AppRoutes.experimentDetail,
          name: AppRoutes.experimentDetailName,
          parentNavigatorKey: _rootNavigatorKey,
          pageBuilder: (context, state) => buildKoraTransitionPage(
            key: state.pageKey,
            name: state.name,
            child: RouteScreenPlaceholder(
              title: 'Experiment Detail',
              routePath: AppRoutes.experimentDetail,
              parameters: state.pathParameters,
            ),
          ),
        ),
        GoRoute(
          path: AppRoutes.experimentVerdict,
          name: AppRoutes.experimentVerdictName,
          parentNavigatorKey: _rootNavigatorKey,
          pageBuilder: (context, state) => buildKoraTransitionPage(
            key: state.pageKey,
            name: state.name,
            child: RouteScreenPlaceholder(
              title: 'Experiment Verdict',
              routePath: AppRoutes.experimentVerdict,
              parameters: state.pathParameters,
            ),
          ),
        ),

        // =====================================================================
        // MAIN APP STATEFUL SHELL TABS
        // =====================================================================
        StatefulShellRoute.indexedStack(
          parentNavigatorKey: _rootNavigatorKey,
          builder: (context, state, navigationShell) => KoraShellScaffold(
            navigationShell: navigationShell,
          ),
          branches: [
            // -----------------------------------------------------------------
            // Branch 0: Home
            // -----------------------------------------------------------------
            StatefulShellBranch(
              routes: [
                GoRoute(
                  path: AppRoutes.home,
                  name: AppRoutes.homeName,
                  pageBuilder: (context, state) => buildKoraTransitionPage(
                    key: state.pageKey,
                    name: state.name,
                    child: const RouteScreenPlaceholder(
                      title: 'Home Dashboard',
                      routePath: AppRoutes.home,
                      showBackButton: false,
                    ),
                  ),
                ),
              ],
            ),

            // -----------------------------------------------------------------
            // Branch 1: Progress & Comparison
            // -----------------------------------------------------------------
            StatefulShellBranch(
              routes: [
                GoRoute(
                  path: AppRoutes.progress,
                  name: AppRoutes.progressName,
                  pageBuilder: (context, state) => buildKoraTransitionPage(
                    key: state.pageKey,
                    name: state.name,
                    child: const RouteScreenPlaceholder(
                      title: 'Skin Progress',
                      routePath: AppRoutes.progress,
                      showBackButton: false,
                    ),
                  ),
                  routes: [
                    GoRoute(
                      path: 'concern/:type',
                      name: AppRoutes.progressConcernName,
                      pageBuilder: (context, state) => buildKoraTransitionPage(
                        key: state.pageKey,
                        name: state.name,
                        child: RouteScreenPlaceholder(
                          title: 'Concern Progression',
                          routePath: AppRoutes.progressConcern,
                          parameters: state.pathParameters,
                        ),
                      ),
                    ),
                  ],
                ),
                GoRoute(
                  path: AppRoutes.compare,
                  name: AppRoutes.compareName,
                  pageBuilder: (context, state) => buildKoraTransitionPage(
                    key: state.pageKey,
                    name: state.name,
                    child: RouteScreenPlaceholder(
                      title: 'Compare Scans',
                      routePath: AppRoutes.compare,
                      parameters: state.pathParameters,
                    ),
                  ),
                ),
              ],
            ),

            // -----------------------------------------------------------------
            // Branch 2: Routine
            // -----------------------------------------------------------------
            StatefulShellBranch(
              routes: [
                GoRoute(
                  path: AppRoutes.routine,
                  name: AppRoutes.routineName,
                  pageBuilder: (context, state) => buildKoraTransitionPage(
                    key: state.pageKey,
                    name: state.name,
                    child: const RouteScreenPlaceholder(
                      title: 'Skincare Routine',
                      routePath: AppRoutes.routine,
                      showBackButton: false,
                    ),
                  ),
                  routes: [
                    GoRoute(
                      path: 'add',
                      name: AppRoutes.routineAddName,
                      pageBuilder: (context, state) => buildKoraTransitionPage(
                        key: state.pageKey,
                        name: state.name,
                        child: const RouteScreenPlaceholder(
                          title: 'Add Routine Product',
                          routePath: AppRoutes.routineAdd,
                        ),
                      ),
                    ),
                    GoRoute(
                      path: 'label',
                      name: AppRoutes.routineLabelName,
                      pageBuilder: (context, state) => buildKoraTransitionPage(
                        key: state.pageKey,
                        name: state.name,
                        child: const RouteScreenPlaceholder(
                          title: 'Scan Product Label',
                          routePath: AppRoutes.routineLabel,
                        ),
                      ),
                    ),
                    GoRoute(
                      path: 'ingredients/:id',
                      name: AppRoutes.routineIngredientsName,
                      pageBuilder: (context, state) => buildKoraTransitionPage(
                        key: state.pageKey,
                        name: state.name,
                        child: RouteScreenPlaceholder(
                          title: 'Product Ingredients',
                          routePath: AppRoutes.routineIngredients,
                          parameters: state.pathParameters,
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),

            // -----------------------------------------------------------------
            // Branch 3: Coach, Learn & Shop
            // -----------------------------------------------------------------
            StatefulShellBranch(
              routes: [
                GoRoute(
                  path: AppRoutes.coach,
                  name: AppRoutes.coachName,
                  pageBuilder: (context, state) => buildKoraTransitionPage(
                    key: state.pageKey,
                    name: state.name,
                    child: const RouteScreenPlaceholder(
                      title: 'AI Skin Coach',
                      routePath: AppRoutes.coach,
                      showBackButton: false,
                    ),
                  ),
                ),
                GoRoute(
                  path: AppRoutes.learn,
                  name: AppRoutes.learnName,
                  pageBuilder: (context, state) => buildKoraTransitionPage(
                    key: state.pageKey,
                    name: state.name,
                    child: const RouteScreenPlaceholder(
                      title: 'Skin Academy',
                      routePath: AppRoutes.learn,
                    ),
                  ),
                  routes: [
                    GoRoute(
                      path: 'video/:id',
                      name: AppRoutes.learnVideoName,
                      pageBuilder: (context, state) => buildKoraTransitionPage(
                        key: state.pageKey,
                        name: state.name,
                        child: RouteScreenPlaceholder(
                          title: 'Video Guide',
                          routePath: AppRoutes.learnVideo,
                          parameters: state.pathParameters,
                        ),
                      ),
                    ),
                  ],
                ),
                GoRoute(
                  path: AppRoutes.shop,
                  name: AppRoutes.shopName,
                  pageBuilder: (context, state) => buildKoraTransitionPage(
                    key: state.pageKey,
                    name: state.name,
                    child: const RouteScreenPlaceholder(
                      title: 'Recommended Shop',
                      routePath: AppRoutes.shop,
                    ),
                  ),
                  routes: [
                    GoRoute(
                      path: 'product/:id',
                      name: AppRoutes.shopProductName,
                      pageBuilder: (context, state) => buildKoraTransitionPage(
                        key: state.pageKey,
                        name: state.name,
                        child: RouteScreenPlaceholder(
                          title: 'Product Detail',
                          routePath: AppRoutes.shopProduct,
                          parameters: state.pathParameters,
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),

            // -----------------------------------------------------------------
            // Branch 4: Profile & Settings
            // -----------------------------------------------------------------
            StatefulShellBranch(
              routes: [
                GoRoute(
                  path: AppRoutes.profile,
                  name: AppRoutes.profileName,
                  pageBuilder: (context, state) => buildKoraTransitionPage(
                    key: state.pageKey,
                    name: state.name,
                    child: const RouteScreenPlaceholder(
                      title: 'My Profile',
                      routePath: AppRoutes.profile,
                      showBackButton: false,
                    ),
                  ),
                  routes: [
                    GoRoute(
                      path: 'subscription',
                      name: AppRoutes.profileSubscriptionName,
                      pageBuilder: (context, state) => buildKoraTransitionPage(
                        key: state.pageKey,
                        name: state.name,
                        child: const RouteScreenPlaceholder(
                          title: 'Subscription',
                          routePath: AppRoutes.profileSubscription,
                        ),
                      ),
                    ),
                    GoRoute(
                      path: 'privacy',
                      name: AppRoutes.profilePrivacyName,
                      pageBuilder: (context, state) => buildKoraTransitionPage(
                        key: state.pageKey,
                        name: state.name,
                        child: const RouteScreenPlaceholder(
                          title: 'Privacy & Data',
                          routePath: AppRoutes.profilePrivacy,
                        ),
                      ),
                    ),
                    GoRoute(
                      path: 'notifications',
                      name: AppRoutes.profileNotificationsName,
                      pageBuilder: (context, state) => buildKoraTransitionPage(
                        key: state.pageKey,
                        name: state.name,
                        child: const RouteScreenPlaceholder(
                          title: 'Notifications',
                          routePath: AppRoutes.profileNotifications,
                        ),
                      ),
                    ),
                    GoRoute(
                      path: 'help',
                      name: AppRoutes.profileHelpName,
                      pageBuilder: (context, state) => buildKoraTransitionPage(
                        key: state.pageKey,
                        name: state.name,
                        child: const RouteScreenPlaceholder(
                          title: 'Help & Support',
                          routePath: AppRoutes.profileHelp,
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ],
        ),
      ],
    );
  }
}
