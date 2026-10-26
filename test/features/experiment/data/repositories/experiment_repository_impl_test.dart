import 'package:drift/native.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:kora/core/database/app_database.dart';
import 'package:kora/core/database/daos/experiment_dao.dart';
import 'package:kora/core/database/daos/sync_mutation_dao.dart';
import 'package:kora/core/network/network_info.dart';
import 'package:kora/core/sync/supabase_sync_driver.dart';
import 'package:kora/core/sync/sync_engine.dart';
import 'package:kora/features/experiment/data/repositories/experiment_repository_impl.dart';
import 'package:kora/features/experiment/domain/entities/skincare_experiment.dart';

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
  late ExperimentDao experimentDao;
  late SyncMutationDao mutationDao;
  late SyncEngine syncEngine;
  late _FakeSyncDriver syncDriver;
  late ExperimentRepositoryImpl repository;

  setUp(() {
    db = AppDatabase.forTesting(NativeDatabase.memory());
    experimentDao = ExperimentDao(db);
    mutationDao = SyncMutationDao(db);
    syncDriver = _FakeSyncDriver();
    syncEngine = SyncEngine(
      database: db,
      mutationDao: mutationDao,
      remoteDriver: syncDriver,
      networkInfo: _FakeNetworkInfo(),
    );
    repository = ExperimentRepositoryImpl(
      experimentDao: experimentDao,
      mutationDao: mutationDao,
      syncEngine: syncEngine,
    );
  });

  tearDown(() async {
    await syncEngine.dispose();
    await db.close();
  });

  test('saves experiment with baseline scan, reads and deletes', () async {
    final now = DateTime.now();
    final experiment = SkincareExperiment(
      id: 'exp_10',
      userId: 'user_exp_1',
      title: 'Testing Vitamin C Serum',
      targets: const ['spots'],
      plannedDays: 28,
      startedAt: now,
      startedOn: '2026-10-19',
      baselineScanId: 'scan_baseline_1',
      createdAt: now,
      updatedAt: now,
    );

    // Save
    final saveResult = await repository.saveExperiment(experiment);
    expect(saveResult.isRight(), isTrue);

    // Read by id
    final getResult = await repository.getExperiment(id: 'exp_10');
    expect(getResult.isRight(), isTrue);
    final fetched = getResult.getOrElse(() => null);
    expect(fetched, isNotNull);
    expect(fetched!.title, 'Testing Vitamin C Serum');
    expect(fetched.baselineScanId, 'scan_baseline_1');

    // List experiments
    final listResult = await repository.getExperiments(userId: 'user_exp_1');
    expect(listResult.isRight(), isTrue);
    expect(listResult.getOrElse(() => []).length, 1);

    // Delete
    final delResult = await repository.deleteExperiment(
      id: 'exp_10',
      userId: 'user_exp_1',
    );
    expect(delResult.isRight(), isTrue);

    final emptyList = await repository.getExperiments(userId: 'user_exp_1');
    expect(emptyList.getOrElse(() => []), isEmpty);

    // Drain outbox
    await syncEngine.drainOutbox();
    expect(syncDriver.appliedTables, contains('experiments'));
  });
}
