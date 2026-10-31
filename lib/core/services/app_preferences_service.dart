// ignore_for_file: document_ignores

import 'package:shared_preferences/shared_preferences.dart';

/// Contract for persistent application preferences and tutorial flags.
abstract class AppPreferencesService {
  /// Whether the user has completed the full initial onboarding journey.
  bool get isOnboardingCompleted;

  /// Sets whether onboarding is completed.
  Future<void> setOnboardingCompleted({required bool completed});

  /// Whether the user has viewed the scan preparation guide.
  bool get hasSeenScanGuide;

  /// Sets whether the scan preparation guide has been viewed.
  Future<void> setHasSeenScanGuide({required bool seen});

  /// Whether the user has viewed the live capture guidance tips.
  bool get hasSeenCaptureTips;

  /// Sets whether the live capture guidance tips have been viewed.
  Future<void> setHasSeenCaptureTips({required bool seen});

  /// Whether the user has viewed the product scan tutorial.
  bool get hasSeenProductScanTutorial;

  /// Sets whether the product scan tutorial has been viewed.
  Future<void> setHasSeenProductScanTutorial({required bool seen});

  /// Active conversation thread identifier for Kora AI Coach.
  String? get coachThreadId;

  /// Persists the active conversation thread identifier for Kora AI Coach.
  Future<void> setCoachThreadId(String threadId);

  /// Persisted JSON serialized list of Kora AI Coach conversation threads.
  String? get coachThreadsJson;

  /// Persists the JSON serialized list of Kora AI Coach conversation threads.
  Future<void> setCoachThreadsJson(String jsonString);

  /// Clears all stored preference values (e.g. on account reset).
  Future<void> clear();
}

/// SharedPreferences-backed implementation of [AppPreferencesService].
class SharedPreferencesService implements AppPreferencesService {
  /// Creates a [SharedPreferencesService] with an optional pre-loaded
  /// [SharedPreferences] instance.
  SharedPreferencesService({this.preferences});

  static const String _keyOnboardingCompleted = 'kora_onboarding_completed';
  static const String _keyHasSeenScanGuide = 'kora_has_seen_scan_guide';
  static const String _keyHasSeenCaptureTips = 'kora_has_seen_capture_tips';
  static const String _keyHasSeenProductScanTutorial =
      'kora_has_seen_product_scan_tutorial';
  static const String _keyCoachThreadId = 'kora_coach_thread_id';
  static const String _keyCoachThreads = 'kora_coach_threads';

  /// The underlying [SharedPreferences] instance.
  SharedPreferences? preferences;

  @override
  bool get isOnboardingCompleted =>
      preferences?.getBool(_keyOnboardingCompleted) ?? false;

  @override
  Future<void> setOnboardingCompleted({required bool completed}) async {
    final prefs = preferences ??= await SharedPreferences.getInstance();
    await prefs.setBool(_keyOnboardingCompleted, completed);
  }

  @override
  bool get hasSeenScanGuide =>
      preferences?.getBool(_keyHasSeenScanGuide) ?? false;

  @override
  Future<void> setHasSeenScanGuide({required bool seen}) async {
    final prefs = preferences ??= await SharedPreferences.getInstance();
    await prefs.setBool(_keyHasSeenScanGuide, seen);
  }

  @override
  bool get hasSeenCaptureTips =>
      preferences?.getBool(_keyHasSeenCaptureTips) ?? false;

  @override
  Future<void> setHasSeenCaptureTips({required bool seen}) async {
    final prefs = preferences ??= await SharedPreferences.getInstance();
    await prefs.setBool(_keyHasSeenCaptureTips, seen);
  }

  @override
  bool get hasSeenProductScanTutorial =>
      preferences?.getBool(_keyHasSeenProductScanTutorial) ?? false;

  @override
  Future<void> setHasSeenProductScanTutorial({required bool seen}) async {
    final prefs = preferences ??= await SharedPreferences.getInstance();
    await prefs.setBool(_keyHasSeenProductScanTutorial, seen);
  }

  @override
  String? get coachThreadId => preferences?.getString(_keyCoachThreadId);

  @override
  Future<void> setCoachThreadId(String threadId) async {
    final prefs = preferences ??= await SharedPreferences.getInstance();
    await prefs.setString(_keyCoachThreadId, threadId);
  }

  @override
  String? get coachThreadsJson => preferences?.getString(_keyCoachThreads);

  @override
  Future<void> setCoachThreadsJson(String jsonString) async {
    final prefs = preferences ??= await SharedPreferences.getInstance();
    await prefs.setString(_keyCoachThreads, jsonString);
  }

  @override
  Future<void> clear() async {
    final prefs = preferences ??= await SharedPreferences.getInstance();
    await prefs.remove(_keyOnboardingCompleted);
    await prefs.remove(_keyHasSeenScanGuide);
    await prefs.remove(_keyHasSeenCaptureTips);
    await prefs.remove(_keyHasSeenProductScanTutorial);
    await prefs.remove(_keyCoachThreadId);
    await prefs.remove(_keyCoachThreads);
  }
}
