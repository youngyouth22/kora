// ignore_for_file: document_ignores, prefer_initializing_formals

import 'dart:async';

import 'package:drift/drift.dart';
import 'package:kora/core/database/app_database.dart';
import 'package:kora/core/database/daos/profile_dao.dart';
import 'package:kora/core/database/daos/sync_mutation_dao.dart';
import 'package:kora/core/services/app_preferences_service.dart';
import 'package:kora/core/sync/sync_engine.dart';
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
  /// Creates an [OnboardingLocalDataSourceImpl] with optional dependencies.
  OnboardingLocalDataSourceImpl({
    ProfileDao? profileDao,
    AppPreferencesService? preferencesService,
    AppDatabase? appDatabase,
    SyncEngine? syncEngine,
    SyncMutationDao? syncMutationDao,
  }) : _profileDao = profileDao,
       _preferencesService = preferencesService,
       _appDatabase = appDatabase,
       _syncEngine = syncEngine,
       _syncMutationDao = syncMutationDao;

  final ProfileDao? _profileDao;
  final AppPreferencesService? _preferencesService;
  final AppDatabase? _appDatabase;
  final SyncEngine? _syncEngine;
  final SyncMutationDao? _syncMutationDao;

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

    var oldId = _anonymousId;
    if (_profileDao != null) {
      final entry =
          (_anonymousId != null
              ? await _profileDao.getProfile(_anonymousId!)
              : null) ??
          await _profileDao.getLatestProfile();
      oldId ??= entry?.id;
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

    final db = _appDatabase;
    if (db != null) {
      await _migrateGuestRecordsToUser(
        db: db,
        oldGuestId: oldId,
        newUserId: userId,
      );
    }

    if (_syncEngine != null) {
      unawaited(_syncEngine.sync(userId: userId));
    }
  }

  Future<void> _migrateGuestRecordsToUser({
    required AppDatabase db,
    required String? oldGuestId,
    required String newUserId,
  }) async {
    // 1. Scans & Concerns
    await (db.update(db.scansTable)..where(
          (tbl) =>
              tbl.userId.equals('local-user') |
              tbl.userId.equals('00000000-0000-0000-0000-000000000001') |
              tbl.userId.like('kora_guest%') |
              (oldGuestId != null
                  ? tbl.userId.equals(oldGuestId)
                  : const Constant(false)),
        ))
        .write(ScansCompanion(userId: Value(newUserId)));

    await (db.update(db.scanConcernsTable)..where(
          (tbl) =>
              tbl.userId.equals('local-user') |
              tbl.userId.equals('00000000-0000-0000-0000-000000000001') |
              tbl.userId.like('kora_guest%') |
              (oldGuestId != null
                  ? tbl.userId.equals(oldGuestId)
                  : const Constant(false)),
        ))
        .write(ScanConcernsCompanion(userId: Value(newUserId)));

    // 2. Routine Items & Logs
    await (db.update(db.routineItemsTable)..where(
          (tbl) =>
              tbl.userId.equals('local-user') |
              tbl.userId.equals('00000000-0000-0000-0000-000000000001') |
              tbl.userId.like('kora_guest%') |
              (oldGuestId != null
                  ? tbl.userId.equals(oldGuestId)
                  : const Constant(false)),
        ))
        .write(RoutineItemsCompanion(userId: Value(newUserId)));

    await (db.update(db.routineLogsTable)..where(
          (tbl) =>
              tbl.userId.equals('local-user') |
              tbl.userId.equals('00000000-0000-0000-0000-000000000001') |
              tbl.userId.like('kora_guest%') |
              (oldGuestId != null
                  ? tbl.userId.equals(oldGuestId)
                  : const Constant(false)),
        ))
        .write(RoutineLogsCompanion(userId: Value(newUserId)));

    // 3. Experiments
    await (db.update(db.experimentsTable)..where(
          (tbl) =>
              tbl.userId.equals('local-user') |
              tbl.userId.equals('00000000-0000-0000-0000-000000000001') |
              tbl.userId.like('kora_guest%') |
              (oldGuestId != null
                  ? tbl.userId.equals(oldGuestId)
                  : const Constant(false)),
        ))
        .write(ExperimentsCompanion(userId: Value(newUserId)));

    // 4. Enqueue Sync Mutations for newly assigned records so they replicate
    final mutationDao = _syncMutationDao;
    if (mutationDao != null) {
      try {
        final scans = await (db.select(
          db.scansTable,
        )..where((tbl) => tbl.userId.equals(newUserId))).get();
        for (final scan in scans) {
          await mutationDao.enqueue(
            id: 'migrated_scan_${scan.id}',
            targetTable: 'scans',
            recordId: scan.id,
            action: 'upsert',
            payload: {
              'id': scan.id,
              'user_id': newUserId,
              'status': scan.status,
              'mode': scan.mode,
              'overall_score': scan.overallScore,
              'skin_age': scan.skinAge,
              'quality_ok': scan.qualityOk,
              'created_at': scan.createdAt.toIso8601String(),
              'completed_at': scan.completedAt?.toIso8601String(),
            },
          );
        }

        final items = await (db.select(
          db.routineItemsTable,
        )..where((tbl) => tbl.userId.equals(newUserId))).get();
        for (final item in items) {
          await mutationDao.enqueue(
            id: 'migrated_routine_${item.id}',
            targetTable: 'routine_items',
            recordId: item.id,
            action: 'upsert',
            payload: {
              'id': item.id,
              'user_id': newUserId,
              'name': item.name,
              'brand': item.brand,
              'step_type': item.stepType,
              'period': item.period,
              'active': item.active,
              'sort_order': item.sortOrder,
            },
          );
        }

        final logs = await (db.select(
          db.routineLogsTable,
        )..where((tbl) => tbl.userId.equals(newUserId))).get();
        for (final log in logs) {
          await mutationDao.enqueue(
            id: 'migrated_log_${log.id}',
            targetTable: 'routine_logs',
            recordId: log.id,
            action: 'upsert',
            payload: {
              'id': log.id,
              'user_id': newUserId,
              'item_id': log.itemId,
              'log_date': log.logDate,
              'period': log.period,
              'done': log.done,
            },
          );
        }
      } on Object catch (_) {}
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
