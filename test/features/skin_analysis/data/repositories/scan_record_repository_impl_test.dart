import 'package:drift/native.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:kora/core/database/app_database.dart';
import 'package:kora/core/database/daos/scan_dao.dart';
import 'package:kora/core/database/daos/sync_mutation_dao.dart';
import 'package:kora/core/network/network_info.dart';
import 'package:kora/core/sync/supabase_sync_driver.dart';
import 'package:kora/core/sync/sync_engine.dart';
import 'package:kora/features/skin_analysis/data/repositories/scan_record_repository_impl.dart';
import 'package:kora/features/skin_analysis/domain/entities/scan_record.dart';

class _FakeNetworkInfo implements NetworkInfo {
  @override
  Future<bool> get isConnected async => true;
}

class _FakeSyncDriver implements RemoteSyncDriver {
  final List<String> appliedTables = [];

  @override
  Future<void> applyMutation({
    required String targetTable,
    required String recordId,
    required String action,
    required Map<String, dynamic> payload,
  }) async {
    appliedTables.add(targetTable);
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
  late ScanDao scanDao;
  late SyncMutationDao mutationDao;
  late SyncEngine syncEngine;
  late _FakeSyncDriver syncDriver;
  late ScanRecordRepositoryImpl repository;

  setUp(() {
    db = AppDatabase.forTesting(NativeDatabase.memory());
    scanDao = ScanDao(db);
    mutationDao = SyncMutationDao(db);
    syncDriver = _FakeSyncDriver();
    syncEngine = SyncEngine(
      database: db,
      mutationDao: mutationDao,
      remoteDriver: syncDriver,
      networkInfo: _FakeNetworkInfo(),
    );
    repository = ScanRecordRepositoryImpl(
      scanDao: scanDao,
      mutationDao: mutationDao,
      syncEngine: syncEngine,
    );
  });

  tearDown(() async {
    await syncEngine.dispose();
    await db.close();
  });

  test('saveScan saves locally with concerns and enqueues mutations', () async {
    final now = DateTime.now();
    final scan = ScanRecord(
      id: 'scan_100',
      userId: 'user_scan_1',
      overallScore: 84,
      skinAge: 25,
      createdAt: now,
      concerns: const [
        ScanConcernRecord(
          id: 'concern_100',
          scanId: 'scan_100',
          userId: 'user_scan_1',
          concern: 'pores',
          rawScore: 75,
        ),
      ],
    );

    final saveResult = await repository.saveScan(scan);
    expect(saveResult.isRight(), isTrue);

    // Read back locally
    final getResult = await repository.getScan(id: 'scan_100');
    expect(getResult.isRight(), isTrue);
    final fetched = getResult.getOrElse(() => null);
    expect(fetched, isNotNull);
    expect(fetched!.overallScore, 84.0);
    expect(fetched.concerns.length, 1);
    expect(fetched.concerns.first.concern, 'pores');

    // Outbox was notified and flushed
    await syncEngine.drainOutbox();
    expect(syncDriver.appliedTables, contains('scans'));
    expect(syncDriver.appliedTables, contains('scan_concerns'));
  });
}
