import 'package:flutter_test/flutter_test.dart';
import 'package:kora/core/router/app_routes.dart';

void main() {
  group('AppRoutes', () {
    test('contains expected root and splash constants', () {
      expect(AppRoutes.splash, '/');
      expect(AppRoutes.splashName, 'splash');
    });

    test('contains expected onboarding route constants', () {
      expect(AppRoutes.onboardingWelcome, '/onboarding/welcome');
      expect(AppRoutes.onboardingMascot, '/onboarding/mascot');
      expect(AppRoutes.onboardingDemographics, '/onboarding/demographics');
      expect(AppRoutes.onboardingDisclaimer, '/onboarding/disclaimer');
      expect(AppRoutes.onboardingQuestions, '/onboarding/questions');
      expect(AppRoutes.onboardingQuiz, '/onboarding/quiz/:step');
      expect(AppRoutes.onboardingBuild, '/onboarding/build');
      expect(AppRoutes.onboardingHow, '/onboarding/how');
      expect(AppRoutes.onboardingConsent, '/onboarding/consent');
      expect(AppRoutes.onboardingCamera, '/onboarding/camera');
      expect(AppRoutes.onboardingReminder, '/onboarding/reminder');
    });

    test('contains expected scan route constants', () {
      expect(AppRoutes.scanGuide, '/scan/guide');
      expect(AppRoutes.scanCapture, '/scan/capture');
      expect(AppRoutes.scanReview, '/scan/review');
      expect(AppRoutes.scanAnalyzing, '/scan/analyzing');
      expect(AppRoutes.scanResult, '/scan/result/:id');
    });

    test('contains expected paywall and auth route constants', () {
      expect(AppRoutes.paywall, '/paywall');
      expect(AppRoutes.accountSecure, '/account/secure');
    });

    test('contains expected app shell and detail route constants', () {
      expect(AppRoutes.home, '/home');
      expect(AppRoutes.progress, '/progress');
      expect(AppRoutes.progressConcern, '/progress/concern/:type');
      expect(AppRoutes.compare, '/compare/:a/:b');
      expect(AppRoutes.routine, '/routine');
      expect(AppRoutes.routineAdd, '/routine/add');
      expect(AppRoutes.routineLabel, '/routine/label');
      expect(AppRoutes.routineIngredients, '/routine/ingredients/:id');
      expect(AppRoutes.experimentNew, '/experiment/new');
      expect(AppRoutes.experimentDetail, '/experiment/:id');
      expect(AppRoutes.experimentVerdict, '/experiment/:id/verdict');
      expect(AppRoutes.coach, '/coach');
      expect(AppRoutes.learn, '/learn');
      expect(AppRoutes.learnVideo, '/learn/video/:id');
      expect(AppRoutes.shop, '/shop');
      expect(AppRoutes.shopProduct, '/shop/product/:id');
      expect(AppRoutes.profile, '/profile');
      expect(AppRoutes.profileSubscription, '/profile/subscription');
      expect(AppRoutes.profilePrivacy, '/profile/privacy');
      expect(AppRoutes.profileNotifications, '/profile/notifications');
      expect(AppRoutes.profileHelp, '/profile/help');
    });

    test('builds dynamic paths accurately', () {
      expect(AppRoutes.buildQuizPath(3), '/onboarding/quiz/3');
      expect(AppRoutes.buildScanResultPath('scan-99'), '/scan/result/scan-99');
      expect(
        AppRoutes.buildProgressConcernPath('redness'),
        '/progress/concern/redness',
      );
      expect(
        AppRoutes.buildComparePath('scan-1', 'scan-2'),
        '/compare/scan-1/scan-2',
      );
      expect(
        AppRoutes.buildRoutineIngredientsPath('serum-12'),
        '/routine/ingredients/serum-12',
      );
      expect(AppRoutes.buildExperimentPath('exp-1'), '/experiment/exp-1');
      expect(
        AppRoutes.buildExperimentVerdictPath('exp-1'),
        '/experiment/exp-1/verdict',
      );
      expect(AppRoutes.buildLearnVideoPath('vid-5'), '/learn/video/vid-5');
      expect(AppRoutes.buildShopProductPath('prod-8'), '/shop/product/prod-8');
    });
  });
}
