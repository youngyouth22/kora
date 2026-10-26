import 'package:drift/drift.dart' hide isNotNull, isNull;
import 'package:drift/native.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:kora/core/database/app_database.dart';
import 'package:kora/core/database/daos/profile_dao.dart';
import 'package:kora/core/database/daos/sync_mutation_dao.dart';
import 'package:kora/core/network/network_info.dart';
import 'package:kora/core/sync/supabase_sync_driver.dart';
import 'package:kora/core/sync/sync_engine.dart';
import 'package:kora/core/sync/sync_status.dart';

class _FakeNetworkInfo implements NetworkInfo {
  bool connected = true;

  @override
  Future<bool> get isConnected async => connected;
}

class _MockRemoteSyncDriver implements RemoteSyncDriver {
  final List<Map<String, dynamic>> appliedMutations = [];
  final Map<String, List<Map<String, dynamic>>> pullResponses = {};
  bool shouldThrowOnApply = false;

  @override
  Future<void> applyMutation({
    required String targetTable,
    required String recordId,
    required String action,
    required Map<String, dynamic> payload,
  }) async {
    if (shouldThrowOnApply) {
      throw Exception('Remote server 500 error');
    }
    appliedMutations.add({
      'table': targetTable,
      'recordId': recordId,
      'action': action,
      'payload': payload,
    });
  }

  @override
  Future<List<Map<String, dynamic>>> pullChanges({
    required String targetTable,
    required String userId,
    DateTime? since,
  }) async {
    return pullResponses[targetTable] ?? [];
  }

  RemoteChangeCallback? registeredCallback;

  @override
  void subscribeToChanges({
    required String userId,
    required RemoteChangeCallback onChange,
  }) {
    registeredCallback = onChange;
  }

  @override
  void unsubscribeFromChanges() {
    registeredCallback = null;
  }
}

void main() {
  late AppDatabase db;
  late SyncMutationDao mutationDao;
  late ProfileDao profileDao;
  late _FakeNetworkInfo networkInfo;
  late _MockRemoteSyncDriver remoteDriver;
  late SyncEngine engine;

  setUp(() {
    db = AppDatabase.forTesting(NativeDatabase.memory());
    mutationDao = SyncMutationDao(db);
    profileDao = ProfileDao(db);
    networkInfo = _FakeNetworkInfo();
    remoteDriver = _MockRemoteSyncDriver();
    engine = SyncEngine(
      database: db,
      mutationDao: mutationDao,
      remoteDriver: remoteDriver,
      networkInfo: networkInfo,
      backoffStrategy: (_) => Duration.zero,
    );
  });

  tearDown(() async {
    await engine.dispose();
    await db.close();
  });

  test('drains outbox in FIFO order and acknowledges mutations', () async {
    await mutationDao.enqueue(
      id: 'mut_1',
      targetTable: 'profiles',
      recordId: 'user_a',
      action: 'upsert',
      payload: {'id': 'user_a', 'display_name': 'First'},
    );

    await Future<void>.delayed(const Duration(milliseconds: 5));

    await mutationDao.enqueue(
      id: 'mut_2',
      targetTable: 'profiles',
      recordId: 'user_a',
      action: 'upsert',
      payload: {'id': 'user_a', 'display_name': 'Second'},
    );

    await engine.drainOutbox();

    expect(remoteDriver.appliedMutations.length, 2);
    final payload0 =
        remoteDriver.appliedMutations[0]['payload'] as Map<String, dynamic>;
    final payload1 =
        remoteDriver.appliedMutations[1]['payload'] as Map<String, dynamic>;
    expect(
      payload0['display_name'],
      'First',
    );
    expect(
      payload1['display_name'],
      'Second',
    );
    expect(await mutationDao.countPending(), 0);
  });

  test('sets offline status and skips outbox when disconnected', () async {
    networkInfo.connected = false;

    await mutationDao.enqueue(
      id: 'mut_offline',
      targetTable: 'profiles',
      recordId: 'user_offline',
      action: 'upsert',
      payload: {'id': 'user_offline'},
    );

    await engine.sync(userId: 'user_offline');

    expect(engine.currentStatus, SyncStatus.offline);
    expect(remoteDriver.appliedMutations, isEmpty);
    expect(await mutationDao.countPending(), 1);
  });

  test('records failure attempt when remote mutation throws', () async {
    remoteDriver.shouldThrowOnApply = true;

    await mutationDao.enqueue(
      id: 'mut_err',
      targetTable: 'profiles',
      recordId: 'user_err',
      action: 'upsert',
      payload: {'id': 'user_err'},
    );

    await expectLater(engine.drainOutbox(), throwsA(isA<Exception>()));

    final pending = await mutationDao.getPending();
    expect(pending.first.attempts, 1);
    expect(pending.first.errorMessage, contains('Remote server 500'));
  });

  test(
    'protects local pending writes from remote overwrite (Outbox Wins)',
    () async {
      // 1. User updated profile locally while offline
      final now = DateTime.now();
      await profileDao.upsertProfile(
        ProfilesCompanion(
          id: const Value('user_local'),
          displayName: const Value('Optimistic Local Name'),
          createdAt: Value(now),
          updatedAt: Value(now),
        ),
      );
      await mutationDao.enqueue(
        id: 'mut_optimistic',
        targetTable: 'profiles',
        recordId: 'user_local',
        action: 'upsert',
        payload: {'id': 'user_local', 'display_name': 'Optimistic Local Name'},
      );

      // 2. Remote backend returns an older stale name
      remoteDriver.pullResponses['profiles'] = [
        {
          'id': 'user_local',
          'display_name': 'Old Remote Name',
          'created_at': now.toIso8601String(),
          'updated_at': now
              .subtract(const Duration(hours: 1))
              .toIso8601String(),
        },
      ];

      await engine.pullAll('user_local');

      // 3. Local profile MUST retain the optimistic local update
      final profile = await profileDao.getProfile('user_local');
      expect(profile!.displayName, 'Optimistic Local Name');
    },
  );

  group('Realtime sync', () {
    test(
      'updates Drift SQLite immediately when a realtime change is received',
      () async {
        engine.startRealtimeSync('user_rt');
        expect(remoteDriver.registeredCallback, isNotNull);

        final now = DateTime.now();
        remoteDriver.registeredCallback!(
          table: 'profiles',
          eventType: 'UPDATE',
          newRecord: {
            'id': 'user_rt',
            'display_name': 'Realtime Name From Supabase',
            'created_at': now.toIso8601String(),
            'updated_at': now.toIso8601String(),
          },
          oldRecord: {},
        );

        // Allow microtasks/async DB write to complete
        await Future<void>.delayed(Duration.zero);

        final profile = await profileDao.getProfile('user_rt');
        expect(profile, isNotNull);
        expect(profile!.displayName, 'Realtime Name From Supabase');

        engine.stopRealtimeSync();
        expect(remoteDriver.registeredCallback, isNull);
      },
    );

    test(
      'ignores realtime update if target record has uncommitted local outbox '
      'mutation (Outbox Wins)',
      () async {
        engine.startRealtimeSync('user_pending');

        final now = DateTime.now();
        await profileDao.upsertProfile(
          ProfilesCompanion(
            id: const Value('user_pending'),
            displayName: const Value('Local User Edit'),
            createdAt: Value(now),
            updatedAt: Value(now),
          ),
        );
        await mutationDao.enqueue(
          id: 'mut_pending',
          targetTable: 'profiles',
          recordId: 'user_pending',
          action: 'upsert',
          payload: {'id': 'user_pending', 'display_name': 'Local User Edit'},
        );

        remoteDriver.registeredCallback!(
          table: 'profiles',
          eventType: 'UPDATE',
          newRecord: {
            'id': 'user_pending',
            'display_name': 'Remote Override Attempt',
            'created_at': DateTime.now().toIso8601String(),
          },
          oldRecord: {},
        );

        await Future<void>.delayed(Duration.zero);

        final profile = await profileDao.getProfile('user_pending');
        expect(profile!.displayName, 'Local User Edit');

        engine.stopRealtimeSync();
      },
    );
  });
}
