// Encapsulate dependencies as private fields.
// ignore_for_file: prefer_initializing_formals

import 'package:dartz/dartz.dart';
import 'package:drift/drift.dart';
import 'package:kora/core/database/app_database.dart';
import 'package:kora/core/database/daos/profile_dao.dart';
import 'package:kora/core/database/daos/sync_mutation_dao.dart';
import 'package:kora/core/error/failures.dart';
import 'package:kora/core/sync/sync_engine.dart';
import 'package:kora/features/onboarding/domain/entities/user_skin_profile.dart';
import 'package:kora/features/onboarding/domain/repositories/user_profile_repository.dart';

/// Offline-first implementation of [UserProfileRepository].
///
/// Always reads from local Drift SQLite first for immediate UI rendering,
/// performs optimistic local writes, and queues mutations for asynchronous
/// remote synchronization.
class UserProfileRepositoryImpl implements UserProfileRepository {
  /// Creates a [UserProfileRepositoryImpl].
  UserProfileRepositoryImpl({
    required ProfileDao profileDao,
    required SyncMutationDao mutationDao,
    required SyncEngine syncEngine,
  }) : _profileDao = profileDao,
       _mutationDao = mutationDao,
       _syncEngine = syncEngine;

  final ProfileDao _profileDao;
  final SyncMutationDao _mutationDao;
  final SyncEngine _syncEngine;

  @override
  Future<Either<Failure, UserSkinProfile?>> getProfile({
    required String id,
  }) async {
    try {
      final entry = await _profileDao.getProfile(id);
      if (entry != null) {
        return Right(_mapToEntity(entry));
      }
      return const Right(null);
    } on Object catch (e) {
      return Left(CacheFailure(message: 'Failed to read profile: $e'));
    }
  }

  @override
  Stream<UserSkinProfile?> watchProfile({required String id}) {
    return _profileDao.watchProfile(id).map((entry) {
      return entry != null ? _mapToEntity(entry) : null;
    });
  }

  @override
  Future<Either<Failure, void>> saveProfile(UserSkinProfile profile) async {
    try {
      final profileId =
          profile.userId ?? profile.anonymousId ?? 'guest_profile';
      final now = DateTime.now();

      final companion = ProfilesCompanion(
        id: Value(profileId),
        skinType: Value(profile.skinType?.code),
        skinToneSelf: Value(
          profile.skinTone != null
              ? int.tryParse(profile.skinTone!.code.replaceAll('type_', ''))
              : null,
        ),
        goals: Value(profile.primaryGoals.map((g) => g.code).toList()),
        createdAt: Value(profile.createdAt ?? now),
        updatedAt: Value(now),
      );

      // 1. Optimistic write into local Drift database
      await _profileDao.upsertProfile(companion);

      // 2. Queue write mutation in outbox for background remote sync
      final payload = <String, dynamic>{
        'id': profileId,
        'skin_type': profile.skinType?.code,
        'skin_tone_self': profile.skinTone != null
            ? int.tryParse(profile.skinTone!.code.replaceAll('type_', ''))
            : null,
        'goals': profile.primaryGoals.map((g) => g.code).toList(),
        'updated_at': now.toIso8601String(),
      };

      await _mutationDao.enqueue(
        id: 'mut_profile_${profileId}_${now.millisecondsSinceEpoch}',
        targetTable: 'profiles',
        recordId: profileId,
        action: 'upsert',
        payload: payload,
      );

      // 3. Notify sync engine to flush outbox if online
      _syncEngine.notifyMutationEnqueued();

      return const Right(null);
    } on Object catch (e) {
      return Left(CacheFailure(message: 'Failed to save profile locally: $e'));
    }
  }

  @override
  Future<Either<Failure, void>> syncProfile({required String id}) async {
    try {
      await _syncEngine.sync(userId: id);
      return const Right(null);
    } on Object catch (e) {
      return Left(NetworkFailure(message: 'Failed to sync profile: $e'));
    }
  }

  UserSkinProfile _mapToEntity(ProfileEntry entry) {
    return UserSkinProfile(
      userId: entry.id,
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
  }
}
