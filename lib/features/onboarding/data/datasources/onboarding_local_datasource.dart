import 'package:kora/features/onboarding/data/models/user_demographics_model.dart';
import 'package:kora/features/onboarding/data/models/user_skin_profile_model.dart';

/// Contract for local caching of onboarding data and flags.
abstract class OnboardingLocalDataSource {
  /// Caches demographic choices.
  Future<void> cacheDemographics(UserDemographicsModel demographics);

  /// Retrieves the latest cached demographics.
  Future<UserDemographicsModel?> getLastDemographics();

  /// Caches quiz answers.
  Future<void> cacheQuizAnswers(Map<int, String> answers);

  /// Retrieves cached quiz answers.
  Future<Map<int, String>> getQuizAnswers();

  /// Caches the structured user skin profile.
  Future<void> cacheSkinProfile(UserSkinProfileModel profile);

  /// Retrieves the cached skin profile.
  Future<UserSkinProfileModel?> getLastSkinProfile();

  /// Returns existing anonymous guest ID or creates a fresh one.
  Future<String> getOrCreateAnonymousId();

  /// Links cached guest profile to an authenticated user ID.
  Future<void> linkProfileToUser({required String userId});

  /// Sets whether onboarding is completed.
  Future<void> setOnboardingCompleted({required bool completed});

  /// Checks if onboarding was previously marked completed.
  Future<bool> isOnboardingCompleted();
}

/// In-memory and local cache implementation for onboarding.
class OnboardingLocalDataSourceImpl implements OnboardingLocalDataSource {
  UserDemographicsModel? _demographics;
  final Map<int, String> _quizAnswers = {};
  UserSkinProfileModel? _skinProfile;
  String? _anonymousId;
  bool _isCompleted = false;

  @override
  Future<void> cacheDemographics(UserDemographicsModel demographics) async {
    _demographics = demographics;
  }

  @override
  Future<UserDemographicsModel?> getLastDemographics() async {
    return _demographics;
  }

  @override
  Future<void> cacheQuizAnswers(Map<int, String> answers) async {
    _quizAnswers
      ..clear()
      ..addAll(answers);

    final anonId = await getOrCreateAnonymousId();
    _skinProfile = UserSkinProfileModel.fromQuizAnswers(
      answers: answers,
      anonymousId: anonId,
      userId: _skinProfile?.userId,
    );
  }

  @override
  Future<Map<int, String>> getQuizAnswers() async {
    return Map<int, String>.unmodifiable(_quizAnswers);
  }

  @override
  Future<void> cacheSkinProfile(UserSkinProfileModel profile) async {
    _skinProfile = profile;
  }

  @override
  Future<UserSkinProfileModel?> getLastSkinProfile() async {
    return _skinProfile;
  }

  @override
  Future<String> getOrCreateAnonymousId() async {
    if (_anonymousId != null) return _anonymousId!;
    final timestamp = DateTime.now().millisecondsSinceEpoch;
    final randomHex = (timestamp % 0xFFFF).toRadixString(16).padLeft(4, '0');
    _anonymousId = 'kora_guest_${timestamp}_$randomHex';
    return _anonymousId!;
  }

  @override
  Future<void> linkProfileToUser({required String userId}) async {
    final now = DateTime.now();
    if (_skinProfile != null) {
      _skinProfile = UserSkinProfileModel.fromEntity(
        _skinProfile!.copyWith(
          userId: userId,
          isAnonymous: false,
          updatedAt: now,
        ),
      );
    }
    if (_demographics != null) {
      _demographics = UserDemographicsModel.fromEntity(
        _demographics!.copyWith(
          userId: userId,
          isAnonymous: false,
          updatedAt: now,
        ),
      );
    }
  }

  @override
  Future<void> setOnboardingCompleted({required bool completed}) async {
    _isCompleted = completed;
  }

  @override
  Future<bool> isOnboardingCompleted() async {
    return _isCompleted;
  }
}
