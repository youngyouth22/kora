import 'package:drift/native.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:kora/core/database/app_database.dart';
import 'package:kora/core/database/daos/routine_dao.dart';
import 'package:kora/core/database/daos/sync_mutation_dao.dart';
import 'package:kora/core/network/network_info.dart';
import 'package:kora/core/sync/supabase_sync_driver.dart';
import 'package:kora/core/sync/sync_engine.dart';
import 'package:kora/features/routine/data/repositories/routine_repository_impl.dart';
import 'package:kora/features/routine/domain/entities/routine_product.dart';

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
  late RoutineDao routineDao;
  late SyncMutationDao mutationDao;
  late SyncEngine syncEngine;
  late _FakeSyncDriver syncDriver;
  late RoutineRepositoryImpl repository;

  setUp(() {
    db = AppDatabase.forTesting(NativeDatabase.memory());
    routineDao = RoutineDao(db);
    mutationDao = SyncMutationDao(db);
    syncDriver = _FakeSyncDriver();
    syncEngine = SyncEngine(
      database: db,
      mutationDao: mutationDao,
      remoteDriver: syncDriver,
      networkInfo: _FakeNetworkInfo(),
    );
    repository = RoutineRepositoryImpl(
      routineDao: routineDao,
      mutationDao: mutationDao,
      syncEngine: syncEngine,
    );
  });

  tearDown(() async {
    await syncEngine.dispose();
    await db.close();
  });

  test(
    'saves product, reads products, logs daily check and deletes item',
    () async {
      final now = DateTime.now();
      final product = RoutineProduct(
        id: 'prod_1',
        userId: 'user_rt_1',
        name: 'Salicylic Acid Cleanser',
        stepType: 'cleanser',
        period: 'am',
        createdAt: now,
        updatedAt: now,
      );

      // Save product
      final saveResult = await repository.saveRoutineProduct(product);
      expect(saveResult.isRight(), isTrue);

      // Read products
      final productsResult = await repository.getRoutineProducts(
        userId: 'user_rt_1',
      );
      expect(productsResult.isRight(), isTrue);
      final products = productsResult.getOrElse(() => []);
      expect(products.length, 1);
      expect(products.first.name, 'Salicylic Acid Cleanser');

      // Log routine step
      final log = RoutineLogRecord(
        id: 'log_1',
        userId: 'user_rt_1',
        itemId: 'prod_1',
        logDate: '2026-10-19',
        createdAt: now,
      );
      final logResult = await repository.logRoutineStep(log);
      expect(logResult.isRight(), isTrue);

      final logsResult = await repository.getLogsForDate(
        userId: 'user_rt_1',
        logDate: '2026-10-19',
      );
      expect(logsResult.isRight(), isTrue);
      expect(logsResult.getOrElse(() => []).length, 1);

      // Delete product
      final delResult = await repository.deleteRoutineProduct(
        id: 'prod_1',
        userId: 'user_rt_1',
      );
      expect(delResult.isRight(), isTrue);

      final emptyProducts = await repository.getRoutineProducts(
        userId: 'user_rt_1',
      );
      expect(emptyProducts.getOrElse(() => []), isEmpty);

      // Drain outbox
      await syncEngine.drainOutbox();
      expect(syncDriver.appliedTables, contains('routine_items'));
      expect(syncDriver.appliedTables, contains('routine_logs'));
    },
  );
}
