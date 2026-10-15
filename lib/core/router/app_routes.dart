// ignore_for_file: document_ignores

/// Centralized route definitions and path builders for the Kora application.
///
/// Houses all path constants, route names, path parameter keys, and
/// type-safe route generation utilities.
abstract final class AppRoutes {
  // ===========================================================================
  // ROOT & SPLASH
  // ===========================================================================

  /// Splash / boot route.
  static const String splash = '/';

  /// Route name for splash.
  static const String splashName = 'splash';

  // ===========================================================================
  // ONBOARDING FLOW
  // ===========================================================================

  /// Welcome screen.
  static const String onboardingWelcome = '/onboarding/welcome';

  /// Route name for onboarding welcome.
  static const String onboardingWelcomeName = 'onboarding_welcome';

  /// Mascot presentation screen.
  static const String onboardingMascot = '/onboarding/mascot';

  /// Route name for onboarding mascot.
  static const String onboardingMascotName = 'onboarding_mascot';

  /// 3-step demographics PageView screen.
  static const String onboardingDemographics = '/onboarding/demographics';

  /// Route name for onboarding demographics.
  static const String onboardingDemographicsName = 'onboarding_demographics';

  /// Medical non-diagnostic advisory screen.
  static const String onboardingDisclaimer = '/onboarding/disclaimer';

  /// Route name for onboarding disclaimer.
  static const String onboardingDisclaimerName = 'onboarding_disclaimer';

  /// Final 6-question questionnaire PageView screen.
  static const String onboardingQuestions = '/onboarding/questions';

  /// Route name for onboarding questions.
  static const String onboardingQuestionsName = 'onboarding_questions';

  /// Dynamic quiz step screen: `/onboarding/quiz/:step`.
  static const String onboardingQuiz = '/onboarding/quiz/:step';

  /// Route name for onboarding quiz.
  static const String onboardingQuizName = 'onboarding_quiz';

  /// Routine / Skin profile build screen.
  static const String onboardingBuild = '/onboarding/build';

  /// Route name for onboarding build.
  static const String onboardingBuildName = 'onboarding_build';

  /// Explainer / How Kora works.
  static const String onboardingHow = '/onboarding/how';

  /// Route name for onboarding how.
  static const String onboardingHowName = 'onboarding_how';

  /// Consent, terms & privacy screen.
  static const String onboardingConsent = '/onboarding/consent';

  /// Route name for onboarding consent.
  static const String onboardingConsentName = 'onboarding_consent';

  /// Camera permissions & preparation screen.
  static const String onboardingCamera = '/onboarding/camera';

  /// Route name for onboarding camera.
  static const String onboardingCameraName = 'onboarding_camera';

  /// Scan reminder / notifications setup.
  static const String onboardingReminder = '/onboarding/reminder';

  /// Route name for onboarding reminder.
  static const String onboardingReminderName = 'onboarding_reminder';

  // ===========================================================================
  // SCAN FLOW
  // ===========================================================================

  /// Scan tutorial & preparation guide.
  static const String scanGuide = '/scan/guide';

  /// Route name for scan guide.
  static const String scanGuideName = 'scan_guide';

  /// Live camera capture interface.
  static const String scanCapture = '/scan/capture';

  /// Route name for scan capture.
  static const String scanCaptureName = 'scan_capture';

  /// Image quality review & validation screen.
  static const String scanReview = '/scan/review';

  /// Route name for scan review.
  static const String scanReviewName = 'scan_review';

  /// Processing / asynchronous skin analysis screen.
  static const String scanAnalyzing = '/scan/analyzing';

  /// Route name for scan analyzing.
  static const String scanAnalyzingName = 'scan_analyzing';

  /// Detailed scan result screen: `/scan/result/:id`.
  static const String scanResult = '/scan/result/:id';

  /// Route name for scan result.
  static const String scanResultName = 'scan_result';

  // ===========================================================================
  // MONETIZATION & AUTH CHECKPOINTS
  // ===========================================================================

  /// Premium paywall / subscription screen.
  static const String paywall = '/paywall';

  /// Route name for paywall.
  static const String paywallName = 'paywall';

  /// Account security / authentication checkpoint.
  static const String accountSecure = '/account/secure';

  /// Route name for account secure.
  static const String accountSecureName = 'account_secure';

  // ===========================================================================
  // MAIN APP SHELL TABS & DETAIL SCREENS
  // ===========================================================================

  // 1. Home
  /// Home dashboard.
  static const String home = '/home';

  /// Route name for home.
  static const String homeName = 'home';

  // 2. Progress & Comparison
  /// Skin progress overview.
  static const String progress = '/progress';

  /// Route name for progress.
  static const String progressName = 'progress';

  /// Filtered concern progression: `/progress/concern/:type`.
  static const String progressConcern = '/progress/concern/:type';

  /// Route name for progress concern.
  static const String progressConcernName = 'progress_concern';

  /// Side-by-side scan comparison: `/compare/:a/:b`.
  static const String compare = '/compare/:a/:b';

  /// Route name for compare.
  static const String compareName = 'compare';

  // 3. Routine
  /// Active skincare routines list.
  static const String routine = '/routine';

  /// Route name for routine.
  static const String routineName = 'routine';

  /// Add routine product screen.
  static const String routineAdd = '/routine/add';

  /// Route name for routine add.
  static const String routineAddName = 'routine_add';

  /// OCR / bottle label scanner.
  static const String routineLabel = '/routine/label';

  /// Route name for routine label.
  static const String routineLabelName = 'routine_label';

  /// Product ingredient breakdown: `/routine/ingredients/:id`.
  static const String routineIngredients = '/routine/ingredients/:id';

  /// Route name for routine ingredients.
  static const String routineIngredientsName = 'routine_ingredients';

  // 4. Experiments
  /// Start a new product experiment.
  static const String experimentNew = '/experiment/new';

  /// Route name for experiment new.
  static const String experimentNewName = 'experiment_new';

  /// Active experiment detail: `/experiment/:id`.
  static const String experimentDetail = '/experiment/:id';

  /// Route name for experiment detail.
  static const String experimentDetailName = 'experiment_detail';

  /// Experiment final verdict: `/experiment/:id/verdict`.
  static const String experimentVerdict = '/experiment/:id/verdict';

  /// Route name for experiment verdict.
  static const String experimentVerdictName = 'experiment_verdict';

  // 5. Coach, Learn & Shop
  /// AI skin coach chat.
  static const String coach = '/coach';

  /// Route name for coach.
  static const String coachName = 'coach';

  /// Skincare academy / articles.
  static const String learn = '/learn';

  /// Route name for learn.
  static const String learnName = 'learn';

  /// Video explainer detail: `/learn/video/:id`.
  static const String learnVideo = '/learn/video/:id';

  /// Route name for learn video.
  static const String learnVideoName = 'learn_video';

  /// Recommended products shop.
  static const String shop = '/shop';

  /// Route name for shop.
  static const String shopName = 'shop';

  /// Shop product detail: `/shop/product/:id`.
  static const String shopProduct = '/shop/product/:id';

  /// Route name for shop product.
  static const String shopProductName = 'shop_product';

  // 6. Profile & Settings
  /// User profile dashboard.
  static const String profile = '/profile';

  /// Route name for profile.
  static const String profileName = 'profile';

  /// Subscription management.
  static const String profileSubscription = '/profile/subscription';

  /// Route name for profile subscription.
  static const String profileSubscriptionName = 'profile_subscription';

  /// Privacy & data deletion.
  static const String profilePrivacy = '/profile/privacy';

  /// Route name for profile privacy.
  static const String profilePrivacyName = 'profile_privacy';

  /// Notification preferences.
  static const String profileNotifications = '/profile/notifications';

  /// Route name for profile notifications.
  static const String profileNotificationsName = 'profile_notifications';

  /// Support & FAQ.
  static const String profileHelp = '/profile/help';

  /// Route name for profile help.
  static const String profileHelpName = 'profile_help';

  // ===========================================================================
  // PARAMETER KEYS
  // ===========================================================================

  /// Parameter key for quiz step.
  static const String paramStep = 'step';

  /// Parameter key for generic resource ID.
  static const String paramId = 'id';

  /// Parameter key for concern type.
  static const String paramType = 'type';

  /// Parameter key for comparison first scan ID.
  static const String paramCompareA = 'a';

  /// Parameter key for comparison second scan ID.
  static const String paramCompareB = 'b';

  // ===========================================================================
  // TYPE-SAFE PATH BUILDERS
  // ===========================================================================

  /// Builds a quiz step path: `/onboarding/quiz/$step`.
  static String buildQuizPath(int step) => '/onboarding/quiz/$step';

  /// Builds a scan result path: `/scan/result/$id`.
  static String buildScanResultPath(String id) => '/scan/result/$id';

  /// Builds a progress concern path: `/progress/concern/$type`.
  static String buildProgressConcernPath(String type) =>
      '/progress/concern/$type';

  /// Builds a comparison path: `/compare/$a/$b`.
  static String buildComparePath(String a, String b) => '/compare/$a/$b';

  /// Builds a routine ingredient breakdown path: `/routine/ingredients/$id`.
  static String buildRoutineIngredientsPath(String id) =>
      '/routine/ingredients/$id';

  /// Builds an experiment detail path: `/experiment/$id`.
  static String buildExperimentPath(String id) => '/experiment/$id';

  /// Builds an experiment verdict path: `/experiment/$id/verdict`.
  static String buildExperimentVerdictPath(String id) =>
      '/experiment/$id/verdict';

  /// Builds a learn video path: `/learn/video/$id`.
  static String buildLearnVideoPath(String id) => '/learn/video/$id';

  /// Builds a shop product path: `/shop/product/$id`.
  static String buildShopProductPath(String id) => '/shop/product/$id';
}
