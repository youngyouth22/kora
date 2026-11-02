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
import 'package:kora/features/auth/auth_injection.dart';
import 'package:kora/features/auth/presentation/bloc/auth_bloc.dart';
import 'package:kora/features/auth/presentation/pages/account_secure_page.dart';
import 'package:kora/features/coach/presentation/pages/coach_chat_page.dart';
import 'package:kora/features/coach/presentation/pages/coach_page.dart';
import 'package:kora/features/coach/presentation/pages/learn_page.dart';
import 'package:kora/features/coach/presentation/pages/learn_video_page.dart';
import 'package:kora/features/coach/presentation/pages/shop_page.dart';
import 'package:kora/features/coach/presentation/pages/shop_product_page.dart';
import 'package:kora/features/experiment/presentation/pages/experiment_detail_page.dart';
import 'package:kora/features/experiment/presentation/pages/experiment_verdict_page.dart';
import 'package:kora/features/experiment/presentation/pages/new_experiment_page.dart';
import 'package:kora/features/guided_capture/guided_capture_injection.dart';
import 'package:kora/features/guided_capture/presentation/bloc/guided_capture_bloc.dart';
import 'package:kora/features/guided_capture/presentation/pages/guided_capture_page.dart';
import 'package:kora/features/guided_capture/presentation/pages/photo_review_page.dart';
import 'package:kora/features/guided_capture/presentation/pages/scan_guide_screen.dart';
import 'package:kora/features/home/presentation/pages/home_page.dart';
import 'package:kora/features/notifications/notifications_injection.dart';
import 'package:kora/features/notifications/presentation/bloc/notification_bloc.dart';
import 'package:kora/features/notifications/presentation/bloc/notification_event.dart';
import 'package:kora/features/notifications/presentation/pages/notification_reminder_screen.dart';
import 'package:kora/features/onboarding/onboarding_injection.dart';
import 'package:kora/features/onboarding/presentation/bloc/onboarding_bloc.dart';
import 'package:kora/features/onboarding/presentation/pages/camera_permission_screen.dart';
import 'package:kora/features/onboarding/presentation/pages/demographics_screen.dart';
import 'package:kora/features/onboarding/presentation/pages/disclaimer_screen.dart';
import 'package:kora/features/onboarding/presentation/pages/mascot_screen.dart';
import 'package:kora/features/onboarding/presentation/pages/onboarding_build_screen.dart';
import 'package:kora/features/onboarding/presentation/pages/onboarding_consent_screen.dart';
import 'package:kora/features/onboarding/presentation/pages/onboarding_how_screen.dart';
import 'package:kora/features/onboarding/presentation/pages/quiz_questions_screen.dart';
import 'package:kora/features/onboarding/presentation/pages/welcome_screen.dart';
import 'package:kora/features/product_scanner/domain/entities/scanned_product_result.dart';
import 'package:kora/features/product_scanner/domain/entities/skincare_report.dart';
import 'package:kora/features/product_scanner/presentation/pages/product_scanner_page.dart';
import 'package:kora/features/profile/presentation/pages/help_page.dart';
import 'package:kora/features/profile/presentation/pages/notifications_page.dart';
import 'package:kora/features/profile/presentation/pages/privacy_page.dart';
import 'package:kora/features/profile/presentation/pages/profile_page.dart';
import 'package:kora/features/profile/presentation/pages/routine_preferences_page.dart';
import 'package:kora/features/profile/presentation/pages/skin_profile_page.dart';
import 'package:kora/features/profile/presentation/pages/subscription_page.dart';
import 'package:kora/features/progress/presentation/pages/compare_scans_page.dart';
import 'package:kora/features/progress/presentation/pages/concern_detail_page.dart';
import 'package:kora/features/progress/presentation/pages/progress_page.dart';
import 'package:kora/features/routine/presentation/pages/add_product_page.dart';
import 'package:kora/features/routine/presentation/pages/ingredient_analysis_page.dart';
import 'package:kora/features/routine/presentation/pages/product_scan_tutorial_page.dart';
import 'package:kora/features/routine/presentation/pages/routine_catalog_page.dart';
import 'package:kora/features/routine/presentation/pages/routine_checkin_page.dart';
import 'package:kora/features/routine/presentation/pages/routine_page.dart';
import 'package:kora/features/routine/presentation/pages/routine_product_detail_page.dart';
import 'package:kora/features/skin_analysis/domain/entities/skin_analysis_result.dart';
import 'package:kora/features/skin_analysis/presentation/pages/scan_analyzing_page.dart';
import 'package:kora/features/skin_analysis/presentation/pages/scan_result_page.dart';
import 'package:kora/features/splash/presentation/bloc/splash_bloc.dart';
import 'package:kora/features/splash/presentation/pages/splash_screen.dart';
import 'package:kora/features/splash/splash_injection.dart';
import 'package:kora/features/subscription/presentation/bloc/subscription_bloc.dart';
import 'package:kora/features/subscription/presentation/pages/kora_paywall_page.dart';
import 'package:kora/features/subscription/subscription_injection.dart';

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
    if (!GetIt.instance.isRegistered<AppSessionState>()) {
      GetIt.instance.registerSingleton<AppSessionState>(_sessionState);
    }
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
                child: WelcomeScreen(
                  sessionState: _sessionState,
                ),
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
            child: const OnboardingBuildScreen(),
          ),
        ),
        GoRoute(
          path: AppRoutes.onboardingHow,
          name: AppRoutes.onboardingHowName,
          parentNavigatorKey: _rootNavigatorKey,
          pageBuilder: (context, state) => buildKoraTransitionPage(
            key: state.pageKey,
            name: state.name,
            child: const OnboardingHowScreen(),
          ),
        ),
        GoRoute(
          path: AppRoutes.onboardingConsent,
          name: AppRoutes.onboardingConsentName,
          parentNavigatorKey: _rootNavigatorKey,
          pageBuilder: (context, state) => buildKoraTransitionPage(
            key: state.pageKey,
            name: state.name,
            child: const OnboardingConsentScreen(),
          ),
        ),
        GoRoute(
          path: AppRoutes.onboardingCamera,
          name: AppRoutes.onboardingCameraName,
          parentNavigatorKey: _rootNavigatorKey,
          pageBuilder: (context, state) => buildKoraTransitionPage(
            key: state.pageKey,
            name: state.name,
            child: const CameraPermissionScreen(),
          ),
        ),
        GoRoute(
          path: AppRoutes.onboardingReminder,
          name: AppRoutes.onboardingReminderName,
          parentNavigatorKey: _rootNavigatorKey,
          pageBuilder: (context, state) {
            final getIt = GetIt.instance;
            if (!getIt.isRegistered<NotificationBloc>()) {
              initNotificationsInjection(getIt);
            }
            return buildKoraTransitionPage(
              key: state.pageKey,
              name: state.name,
              child: BlocProvider<NotificationBloc>(
                create: (_) =>
                    getIt<NotificationBloc>()..add(const NotificationStarted()),
                child: NotificationReminderScreen(
                  sessionState: _sessionState,
                ),
              ),
            );
          },
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
            child: ScanGuideScreen(
              sessionState: _sessionState,
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
          pageBuilder: (context, state) {
            final imagePath = state.extra is String
                ? state.extra! as String
                : '';
            return buildKoraTransitionPage(
              key: state.pageKey,
              name: state.name,
              child: PhotoReviewPage(imagePath: imagePath),
            );
          },
        ),
        GoRoute(
          path: AppRoutes.scanAnalyzing,
          name: AppRoutes.scanAnalyzingName,
          parentNavigatorKey: _rootNavigatorKey,
          pageBuilder: (context, state) {
            final imagePath = state.extra is String
                ? state.extra! as String
                : '';
            return buildKoraTransitionPage(
              key: state.pageKey,
              name: state.name,
              child: ScanAnalyzingPage(imagePath: imagePath),
            );
          },
        ),
        GoRoute(
          path: AppRoutes.scanResult,
          name: AppRoutes.scanResultName,
          parentNavigatorKey: _rootNavigatorKey,
          pageBuilder: (context, state) {
            if (state.extra is SkinAnalysisResult) {
              return buildKoraTransitionPage(
                key: state.pageKey,
                name: state.name,
                child: ScanResultPage(
                  result: state.extra! as SkinAnalysisResult,
                ),
              );
            }
            return buildKoraTransitionPage(
              key: state.pageKey,
              name: state.name,
              child: RouteScreenPlaceholder(
                title: 'Scan Result',
                routePath: AppRoutes.scanResult,
                parameters: state.pathParameters,
              ),
            );
          },
        ),
        GoRoute(
          path: AppRoutes.productScanTutorial,
          name: AppRoutes.productScanTutorialName,
          parentNavigatorKey: _rootNavigatorKey,
          pageBuilder: (context, state) => buildKoraTransitionPage(
            key: state.pageKey,
            name: state.name,
            child: const ProductScanTutorialPage(),
          ),
        ),

        // =====================================================================
        // PAYWALL & ACCOUNT SECURITY
        // =====================================================================
        GoRoute(
          path: AppRoutes.paywall,
          name: AppRoutes.paywallName,
          parentNavigatorKey: _rootNavigatorKey,
          pageBuilder: (context, state) {
            final getIt = GetIt.instance;
            if (!getIt.isRegistered<SubscriptionBloc>()) {
              initSubscriptionInjection(getIt);
            }
            return buildKoraTransitionPage(
              key: state.pageKey,
              name: state.name,
              child: BlocProvider<SubscriptionBloc>(
                create: (_) => getIt<SubscriptionBloc>(),
                child: KoraPaywallPage(
                  sessionState: _sessionState,
                ),
              ),
            );
          },
        ),
        GoRoute(
          path: AppRoutes.accountSecure,
          name: AppRoutes.accountSecureName,
          parentNavigatorKey: _rootNavigatorKey,
          pageBuilder: (context, state) {
            final getIt = GetIt.instance;
            if (!getIt.isRegistered<AuthBloc>()) {
              initAuthInjection(getIt);
            }
            return buildKoraTransitionPage(
              key: state.pageKey,
              name: state.name,
              child: BlocProvider<AuthBloc>(
                create: (_) => getIt<AuthBloc>(),
                child: AccountSecurePage(
                  sessionState: _sessionState,
                ),
              ),
            );
          },
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
            child: const NewExperimentPage(),
          ),
        ),
        GoRoute(
          path: AppRoutes.experimentDetail,
          name: AppRoutes.experimentDetailName,
          parentNavigatorKey: _rootNavigatorKey,
          pageBuilder: (context, state) => buildKoraTransitionPage(
            key: state.pageKey,
            name: state.name,
            child: ExperimentDetailPage(
              experimentId: state.pathParameters[AppRoutes.paramId] ?? '1',
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
            child: ExperimentVerdictPage(
              experimentId: state.pathParameters[AppRoutes.paramId] ?? '1',
            ),
          ),
        ),

        // =====================================================================
        // PROGRESS SUBROUTES (FULL SCREEN OUTSIDE SHELL)
        // =====================================================================
        GoRoute(
          path: AppRoutes.progressConcern,
          name: AppRoutes.progressConcernName,
          parentNavigatorKey: _rootNavigatorKey,
          pageBuilder: (context, state) => buildKoraTransitionPage(
            key: state.pageKey,
            name: state.name,
            child: ConcernDetailPage(
              concernType:
                  state.pathParameters[AppRoutes.paramType] ?? 'age_spot',
            ),
          ),
        ),
        GoRoute(
          path: AppRoutes.compare,
          name: AppRoutes.compareName,
          parentNavigatorKey: _rootNavigatorKey,
          pageBuilder: (context, state) => buildKoraTransitionPage(
            key: state.pageKey,
            name: state.name,
            child: CompareScansPage(
              scanAId:
                  state.pathParameters[AppRoutes.paramCompareA] ?? 'scan_1',
              scanBId:
                  state.pathParameters[AppRoutes.paramCompareB] ?? 'scan_8',
            ),
          ),
        ),

        // =====================================================================
        // COACH, AI COMPANION & EDUCATION (FULL SCREEN)
        // =====================================================================
        GoRoute(
          path: AppRoutes.coach,
          name: AppRoutes.coachName,
          parentNavigatorKey: _rootNavigatorKey,
          pageBuilder: (context, state) => buildKoraTransitionPage(
            key: state.pageKey,
            name: state.name,
            child: const CoachPage(),
          ),
        ),
        GoRoute(
          path: AppRoutes.coachChat,
          name: AppRoutes.coachChatName,
          parentNavigatorKey: _rootNavigatorKey,
          pageBuilder: (context, state) => buildKoraTransitionPage(
            key: state.pageKey,
            name: state.name,
            child: CoachChatPage(
              initialQuestion: state.extra as String?,
            ),
          ),
        ),
        GoRoute(
          path: AppRoutes.learn,
          name: AppRoutes.learnName,
          parentNavigatorKey: _rootNavigatorKey,
          pageBuilder: (context, state) => buildKoraTransitionPage(
            key: state.pageKey,
            name: state.name,
            child: const LearnPage(),
          ),
          routes: [
            GoRoute(
              path: 'video/:id',
              name: AppRoutes.learnVideoName,
              pageBuilder: (context, state) => buildKoraTransitionPage(
                key: state.pageKey,
                name: state.name,
                child: LearnVideoPage(
                  videoId: state.pathParameters['id'] ?? '1',
                ),
              ),
            ),
          ],
        ),
        GoRoute(
          path: AppRoutes.shop,
          name: AppRoutes.shopName,
          parentNavigatorKey: _rootNavigatorKey,
          pageBuilder: (context, state) => buildKoraTransitionPage(
            key: state.pageKey,
            name: state.name,
            child: const ShopPage(),
          ),
          routes: [
            GoRoute(
              path: 'product/:id',
              name: AppRoutes.shopProductName,
              pageBuilder: (context, state) => buildKoraTransitionPage(
                key: state.pageKey,
                name: state.name,
                child: ShopProductPage(
                  productId: state.pathParameters['id'] ?? 'p1',
                ),
              ),
            ),
          ],
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
                    child: const HomePage(),
                  ),
                ),
              ],
            ),

            // -----------------------------------------------------------------
            // Branch 1: Products & Routine
            // -----------------------------------------------------------------
            StatefulShellBranch(
              routes: [
                GoRoute(
                  path: AppRoutes.routine,
                  name: AppRoutes.routineName,
                  pageBuilder: (context, state) => buildKoraTransitionPage(
                    key: state.pageKey,
                    name: state.name,
                    child: RoutinePage(
                      initialPeriod: state.uri.queryParameters['period'],
                    ),
                  ),
                  routes: [
                    GoRoute(
                      path: 'add',
                      name: AppRoutes.routineAddName,
                      parentNavigatorKey: _rootNavigatorKey,
                      pageBuilder: (context, state) => buildKoraTransitionPage(
                        key: state.pageKey,
                        name: state.name,
                        child: const AddProductPage(),
                      ),
                    ),
                    GoRoute(
                      path: 'label',
                      name: AppRoutes.routineLabelName,
                      parentNavigatorKey: _rootNavigatorKey,
                      pageBuilder: (context, state) => buildKoraTransitionPage(
                        key: state.pageKey,
                        name: state.name,
                        child: const ProductScannerPage(),
                      ),
                    ),
                    GoRoute(
                      path: 'ingredients/:id',
                      name: AppRoutes.routineIngredientsName,
                      parentNavigatorKey: _rootNavigatorKey,
                      pageBuilder: (context, state) => buildKoraTransitionPage(
                        key: state.pageKey,
                        name: state.name,
                        child: IngredientAnalysisPage(
                          productId: state.pathParameters['id'] ?? 'demo-1',
                          scanResult: state.extra is ScannedProductResult
                              ? state.extra! as ScannedProductResult
                              : null,
                          skincareReport: state.extra is SkincareReport
                              ? state.extra! as SkincareReport
                              : null,
                        ),
                      ),
                    ),
                    GoRoute(
                      path: 'product/:id',
                      name: AppRoutes.routineProductDetailName,
                      parentNavigatorKey: _rootNavigatorKey,
                      pageBuilder: (context, state) => buildKoraTransitionPage(
                        key: state.pageKey,
                        name: state.name,
                        child: RoutineProductDetailPage(
                          productId:
                              state.pathParameters['id'] ??
                              'item-cerave-cleanser',
                        ),
                      ),
                    ),
                    GoRoute(
                      path: 'catalog',
                      name: AppRoutes.routineCatalogName,
                      parentNavigatorKey: _rootNavigatorKey,
                      pageBuilder: (context, state) => buildKoraTransitionPage(
                        key: state.pageKey,
                        name: state.name,
                        child: const RoutineCatalogPage(),
                      ),
                    ),
                    GoRoute(
                      path: 'checkin',
                      name: AppRoutes.routineCheckinName,
                      parentNavigatorKey: _rootNavigatorKey,
                      pageBuilder: (context, state) => buildKoraTransitionPage(
                        key: state.pageKey,
                        name: state.name,
                        child: const RoutineCheckinPage(),
                      ),
                    ),
                  ],
                ),
              ],
            ),

            // -----------------------------------------------------------------
            // Branch 2: Skin Check
            // -----------------------------------------------------------------
            StatefulShellBranch(
              routes: [
                GoRoute(
                  path: AppRoutes.skinCheck,
                  name: AppRoutes.skinCheckName,
                  pageBuilder: (context, state) => buildKoraTransitionPage(
                    key: state.pageKey,
                    name: state.name,
                    child: ScanGuideScreen(
                      sessionState: _sessionState,
                    ),
                  ),
                ),
              ],
            ),

            // -----------------------------------------------------------------
            // Branch 3: Progress & Comparison
            // -----------------------------------------------------------------
            StatefulShellBranch(
              routes: [
                GoRoute(
                  path: AppRoutes.progress,
                  name: AppRoutes.progressName,
                  pageBuilder: (context, state) => buildKoraTransitionPage(
                    key: state.pageKey,
                    name: state.name,
                    child: const ProgressPage(),
                  ),
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
                    child: const ProfilePage(),
                  ),
                  routes: [
                    GoRoute(
                      path: 'subscription',
                      name: AppRoutes.profileSubscriptionName,
                      parentNavigatorKey: _rootNavigatorKey,
                      pageBuilder: (context, state) => buildKoraTransitionPage(
                        key: state.pageKey,
                        name: state.name,
                        child: const SubscriptionPage(),
                      ),
                    ),
                    GoRoute(
                      path: 'privacy',
                      name: AppRoutes.profilePrivacyName,
                      parentNavigatorKey: _rootNavigatorKey,
                      pageBuilder: (context, state) => buildKoraTransitionPage(
                        key: state.pageKey,
                        name: state.name,
                        child: const PrivacyPage(),
                      ),
                    ),
                    GoRoute(
                      path: 'notifications',
                      name: AppRoutes.profileNotificationsName,
                      parentNavigatorKey: _rootNavigatorKey,
                      pageBuilder: (context, state) => buildKoraTransitionPage(
                        key: state.pageKey,
                        name: state.name,
                        child: const NotificationsPage(),
                      ),
                    ),
                    GoRoute(
                      path: 'help',
                      name: AppRoutes.profileHelpName,
                      parentNavigatorKey: _rootNavigatorKey,
                      pageBuilder: (context, state) => buildKoraTransitionPage(
                        key: state.pageKey,
                        name: state.name,
                        child: const HelpPage(),
                      ),
                    ),
                    GoRoute(
                      path: 'routine-preferences',
                      name: AppRoutes.profileRoutinePreferencesName,
                      parentNavigatorKey: _rootNavigatorKey,
                      pageBuilder: (context, state) => buildKoraTransitionPage(
                        key: state.pageKey,
                        name: state.name,
                        child: const RoutinePreferencesPage(),
                      ),
                    ),
                    GoRoute(
                      path: 'skin-profile',
                      name: AppRoutes.profileSkinProfileName,
                      parentNavigatorKey: _rootNavigatorKey,
                      pageBuilder: (context, state) => buildKoraTransitionPage(
                        key: state.pageKey,
                        name: state.name,
                        child: const SkinProfilePage(),
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
