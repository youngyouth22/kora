import 'package:drift/native.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:kora/core/database/app_database.dart';
import 'package:kora/core/database/daos/profile_dao.dart';
import 'package:kora/core/database/daos/sync_mutation_dao.dart';
import 'package:kora/core/network/network_info.dart';
import 'package:kora/core/sync/supabase_sync_driver.dart';
import 'package:kora/core/sync/sync_engine.dart';
import 'package:kora/features/onboarding/data/repositories/user_profile_repository_impl.dart';
import 'package:kora/features/onboarding/domain/entities/user_skin_profile.dart';

class _FakeNetworkInfo implements NetworkInfo {
  @override
  Future<bool> get isConnected async => true;
}

class _FakeSyncDriver implements RemoteSyncDriver {
  final List<String> upsertedRecords = [];

  @override
  Future<void> applyMutation({
    required String targetTable,
    required String recordId,
    required String action,
    required Map<String, dynamic> payload,
  }) async {
    upsertedRecords.add(recordId);
  }

  @override
  Future<List<Map<String, dynamic>>> pullChanges({
    required String targetTable,
    required String userId,
    DateTime? since,
  }) async => [];

  @override
  void subscribeToChanges({
    required String userId,
    required RemoteChangeCallback onChange,
  }) {}

  @override
  void unsubscribeFromChanges() {}
}

void main() {
  late AppDatabase db;
  late ProfileDao profileDao;
  late SyncMutationDao mutationDao;
  late SyncEngine syncEngine;
  late _FakeSyncDriver syncDriver;
  late UserProfileRepositoryImpl repository;

  setUp(() {
    db = AppDatabase.forTesting(NativeDatabase.memory());
    profileDao = ProfileDao(db);
    mutationDao = SyncMutationDao(db);
    syncDriver = _FakeSyncDriver();
    syncEngine = SyncEngine(
      database: db,
      mutationDao: mutationDao,
      remoteDriver: syncDriver,
      networkInfo: _FakeNetworkInfo(),
    );
    repository = UserProfileRepositoryImpl(
      profileDao: profileDao,
      mutationDao: mutationDao,
      syncEngine: syncEngine,
    );
  });

  tearDown(() async {
    await syncEngine.dispose();
    await db.close();
  });

  test(
    'saveProfile writes to Drift immediately and queues outbox mutation',
    () async {
      const profile = UserSkinProfile(
        userId: 'user_prof_1',
        skinType: SkinType.oily,
        skinTone: SkinTone.typeIII,
        primaryGoals: [SkinGoal.pores, SkinGoal.fineLines],
      );

      final saveResult = await repository.saveProfile(profile);
      expect(saveResult.isRight(), isTrue);

      // Immediate local read from Drift
      final readResult = await repository.getProfile(id: 'user_prof_1');
      expect(readResult.isRight(), isTrue);
      final fetched = readResult.getOrElse(() => null);
      expect(fetched, isNotNull);
      expect(fetched!.skinType, SkinType.oily);
      expect(fetched.primaryGoals.length, 2);

      // Outbox was notified and flushed
      await syncEngine.drainOutbox();
      expect(syncDriver.upsertedRecords, contains('user_prof_1'));
    },
  );
}
