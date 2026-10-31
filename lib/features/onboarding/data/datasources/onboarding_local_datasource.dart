// ignore_for_file: document_ignores, prefer_initializing_formals

import 'package:drift/drift.dart';
import 'package:kora/core/database/app_database.dart';
import 'package:kora/core/database/daos/profile_dao.dart';
import 'package:kora/core/services/app_preferences_service.dart';
import 'package:kora/features/onboarding/data/models/user_demographics_model.dart';
import 'package:kora/features/onboarding/data/models/user_skin_profile_model.dart';
import 'package:kora/features/onboarding/domain/entities/user_skin_profile.dart';

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

/// Drift SQLite backed and in-memory local cache implementation for onboarding.
class OnboardingLocalDataSourceImpl implements OnboardingLocalDataSource {
  /// Creates an [OnboardingLocalDataSourceImpl] with optional [ProfileDao]
  /// and [AppPreferencesService].
  OnboardingLocalDataSourceImpl({
    ProfileDao? profileDao,
    AppPreferencesService? preferencesService,
  }) : _profileDao = profileDao,
       _preferencesService = preferencesService;

  final ProfileDao? _profileDao;
  final AppPreferencesService? _preferencesService;

  UserDemographicsModel? _demographics;
  final Map<int, String> _quizAnswers = {};
  UserSkinProfileModel? _skinProfile;
  String? _anonymousId;
  bool _isCompleted = false;

  @override
  Future<void> cacheDemographics(UserDemographicsModel demographics) async {
    _demographics = demographics;
    final anonId = await getOrCreateAnonymousId();

    if (_profileDao != null) {
      final now = DateTime.now();
      await _profileDao.upsertProfile(
        ProfilesCompanion(
          id: Value(anonId),
          sensitivities: Value(
            (demographics.hasSensitiveSkin ?? false)
                ? const ['sensitive']
                : const [],
          ),
          ageConfirmed: Value(demographics.ageRange != null),
          onboardingStep: const Value(1),
          createdAt: Value(now),
          updatedAt: Value(now),
        ),
      );
    }
  }

  @override
  Future<UserDemographicsModel?> getLastDemographics() async {
    if (_demographics != null) return _demographics;
    if (_profileDao != null) {
      final entry = await _profileDao.getLatestProfile();
      if (entry != null) {
        return UserDemographicsModel(
          hasSensitiveSkin: entry.sensitivities.contains('sensitive'),
          isAnonymous: entry.id.startsWith('kora_guest'),
          anonymousId: entry.id.startsWith('kora_guest') ? entry.id : null,
          userId: entry.id.startsWith('kora_guest') ? null : entry.id,
        );
      }
    }
    return null;
  }

  @override
  Future<void> cacheQuizAnswers(Map<int, String> answers) async {
    _quizAnswers
      ..clear()
      ..addAll(answers);

    final anonId = await getOrCreateAnonymousId();
    final profile = UserSkinProfileModel.fromQuizAnswers(
      answers: answers,
      anonymousId: anonId,
      userId: _skinProfile?.userId,
      demographics: _demographics,
    );
    _skinProfile = profile;

    if (_profileDao != null) {
      await cacheSkinProfile(profile);
    }
  }

  @override
  Future<Map<int, String>> getQuizAnswers() async {
    return Map<int, String>.unmodifiable(_quizAnswers);
  }

  @override
  Future<void> cacheSkinProfile(UserSkinProfileModel profile) async {
    _skinProfile = profile;
    final profileId =
        profile.userId ?? profile.anonymousId ?? await getOrCreateAnonymousId();
    final now = DateTime.now();

    if (_profileDao != null) {
      final companion = ProfilesCompanion(
        id: Value(profileId),
        skinType: Value(profile.skinType?.code),
        skinToneSelf: Value(
          profile.skinTone != null
              ? int.tryParse(profile.skinTone!.code.replaceAll('type_', ''))
              : null,
        ),
        goals: Value(profile.primaryGoals.map((g) => g.code).toList()),
        onboardingStep: const Value(5),
        createdAt: Value(profile.createdAt ?? now),
        updatedAt: Value(now),
      );
      await _profileDao.upsertProfile(companion);
    }
  }

  @override
  Future<UserSkinProfileModel?> getLastSkinProfile() async {
    if (_skinProfile != null) return _skinProfile;
    if (_profileDao != null) {
      final entry = await _profileDao.getLatestProfile();
      if (entry != null) {
        final profile = UserSkinProfileModel(
          userId: entry.id.startsWith('kora_guest') ? null : entry.id,
          anonymousId: entry.id.startsWith('kora_guest') ? entry.id : null,
          isAnonymous: entry.id.startsWith('kora_guest'),
          skinType: SkinType.fromCode(entry.skinType),
          skinTone: entry.skinToneSelf != null
              ? SkinTone.fromCode('type_${entry.skinToneSelf}')
              : null,
          primaryGoals: entry.goals
              .map(SkinGoal.fromCode)
              .whereType<SkinGoal>()
              .toList(),
          createdAt: entry.createdAt,
          updatedAt: entry.updatedAt,
        );
        _skinProfile = profile;
        return profile;
      }
    }
    return null;
  }

  @override
  Future<String> getOrCreateAnonymousId() async {
    if (_anonymousId != null) return _anonymousId!;
    if (_profileDao != null) {
      final entry = await _profileDao.getLatestProfile();
      if (entry != null && entry.id.startsWith('kora_guest')) {
        _anonymousId = entry.id;
        return _anonymousId!;
      }
    }
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

    if (_profileDao != null) {
      final entry =
          (_anonymousId != null
              ? await _profileDao.getProfile(_anonymousId!)
              : null) ??
          await _profileDao.getLatestProfile();
      final oldId = _anonymousId ?? entry?.id;
      final companion = ProfilesCompanion(
        id: Value(userId),
        skinType: Value(entry?.skinType ?? _skinProfile?.skinType?.code),
        skinToneSelf: Value(
          entry?.skinToneSelf ??
              (_skinProfile?.skinTone != null
                  ? int.tryParse(
                      _skinProfile!.skinTone!.code.replaceAll('type_', ''),
                    )
                  : null),
        ),
        goals: Value(
          entry?.goals ??
              _skinProfile?.primaryGoals.map((g) => g.code).toList() ??
              const [],
        ),
        sensitivities: Value(entry?.sensitivities ?? const []),
        ageConfirmed: Value(entry?.ageConfirmed ?? false),
        scanWeekday: Value(entry?.scanWeekday ?? 7),
        scanTime: Value(entry?.scanTime ?? '18:00'),
        onboardingStep: Value(entry?.onboardingStep ?? 10),
        onboardingCompletedAt: Value(entry?.onboardingCompletedAt ?? now),
        createdAt: Value(entry?.createdAt ?? now),
        updatedAt: Value(now),
      );
      await _profileDao.upsertProfile(companion);
      if (oldId != null && oldId != userId) {
        await _profileDao.deleteProfile(oldId);
      }
    }
  }

  @override
  Future<void> setOnboardingCompleted({required bool completed}) async {
    _isCompleted = completed;
    if (_preferencesService != null) {
      await _preferencesService.setOnboardingCompleted(completed: completed);
    }
    if (_profileDao != null) {
      final entry = await _profileDao.getLatestProfile();
      final id = entry?.id ?? await getOrCreateAnonymousId();
      final now = DateTime.now();
      await _profileDao.upsertProfile(
        ProfilesCompanion(
          id: Value(id),
          onboardingStep: Value(completed ? 10 : 0),
          onboardingCompletedAt: Value(
            completed ? (entry?.onboardingCompletedAt ?? now) : null,
          ),
          createdAt: Value(entry?.createdAt ?? now),
          updatedAt: Value(now),
        ),
      );
    }
  }

  @override
  Future<bool> isOnboardingCompleted() async {
    if (_preferencesService?.isOnboardingCompleted ?? false) {
      _isCompleted = true;
      return true;
    }
    if (_profileDao != null) {
      final entry = await _profileDao.getLatestProfile();
      if (entry != null && entry.onboardingCompletedAt != null) {
        _isCompleted = true;
        return true;
      }
    }
    return _isCompleted;
  }
}
