import 'package:drift/drift.dart' hide isNotNull, isNull;
import 'package:drift/native.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:kora/core/database/app_database.dart';
import 'package:kora/core/database/daos/experiment_dao.dart';
import 'package:kora/core/database/daos/profile_dao.dart';
import 'package:kora/core/database/daos/routine_dao.dart';
import 'package:kora/core/database/daos/scan_dao.dart';
import 'package:kora/core/database/daos/sync_mutation_dao.dart';

void main() {
  late AppDatabase db;
  late ProfileDao profileDao;
  late ScanDao scanDao;
  late RoutineDao routineDao;
  late ExperimentDao experimentDao;
  late SyncMutationDao syncMutationDao;

  setUp(() {
    db = AppDatabase.forTesting(NativeDatabase.memory());
    profileDao = ProfileDao(db);
    scanDao = ScanDao(db);
    routineDao = RoutineDao(db);
    experimentDao = ExperimentDao(db);
    syncMutationDao = SyncMutationDao(db);
  });

  tearDown(() async {
    await db.close();
  });

  group('ProfileDao', () {
    test('upserts, reads, watches, and deletes a profile', () async {
      final now = DateTime.now();
      await profileDao.upsertProfile(
        ProfilesCompanion(
          id: const Value('user_123'),
          displayName: const Value('Jane Doe'),
          skinType: const Value('combination'),
          skinToneSelf: const Value(3),
          goals: const Value(['pores', 'wrinkles']),
          createdAt: Value(now),
          updatedAt: Value(now),
        ),
      );

      final profile = await profileDao.getProfile('user_123');
      expect(profile, isNotNull);
      expect(profile!.id, 'user_123');
      expect(profile.displayName, 'Jane Doe');
      expect(profile.goals, ['pores', 'wrinkles']);

      // Reactive watch stream
      expect(
        profileDao.watchProfile('user_123'),
        emits(isNotNull),
      );

      // Delete
      final deletedCount = await profileDao.deleteProfile('user_123');
      expect(deletedCount, 1);
      expect(await profileDao.getProfile('user_123'), isNull);
    });
  });

  group('ScanDao', () {
    test('upserts scan with concerns, reads and watches scans', () async {
      final now = DateTime.now();
      await profileDao.upsertProfile(
        ProfilesCompanion(
          id: const Value('user_scan'),
          createdAt: Value(now),
          updatedAt: Value(now),
        ),
      );

      await scanDao.upsertScan(
        scan: ScansCompanion(
          id: const Value('scan_1'),
          userId: const Value('user_scan'),
          status: const Value('done'),
          overallScore: const Value(82.5),
          skinAge: const Value(26),
          createdAt: Value(now),
        ),
        concerns: const [
          ScanConcernsCompanion(
            id: Value('c_1'),
            scanId: Value('scan_1'),
            userId: Value('user_scan'),
            concern: Value('pores'),
            rawScore: Value(78),
          ),
          ScanConcernsCompanion(
            id: Value('c_2'),
            scanId: Value('scan_1'),
            userId: Value('user_scan'),
            concern: Value('wrinkles'),
            rawScore: Value(88),
          ),
        ],
      );

      final scan = await scanDao.getScan('scan_1');
      expect(scan, isNotNull);
      expect(scan!.overallScore, 82.5);

      final concerns = await scanDao.getScanConcerns('scan_1');
      expect(concerns.length, 2);

      final userScans = await scanDao.getScansForUser('user_scan');
      expect(userScans.length, 1);

      await scanDao.deleteScan('scan_1');
      expect(await scanDao.getScan('scan_1'), isNull);
      expect(await scanDao.getScanConcerns('scan_1'), isEmpty);
    });
  });

  group('RoutineDao', () {
    test('manages routine items and daily logs', () async {
      final now = DateTime.now();
      await profileDao.upsertProfile(
        ProfilesCompanion(
          id: const Value('user_routine'),
          createdAt: Value(now),
          updatedAt: Value(now),
        ),
      );

      await routineDao.upsertRoutineItem(
        RoutineItemsCompanion(
          id: const Value('item_1'),
          userId: const Value('user_routine'),
          name: const Value('Retinol Serum'),
          stepType: const Value('serum'),
          period: const Value('pm'),
          sortOrder: const Value(1),
          createdAt: Value(now),
          updatedAt: Value(now),
        ),
      );

      final items = await routineDao.getRoutineItems('user_routine');
      expect(items.length, 1);
      expect(items.first.name, 'Retinol Serum');

      // Add log
      await routineDao.upsertRoutineLog(
        RoutineLogsCompanion(
          id: const Value('log_1'),
          userId: const Value('user_routine'),
          itemId: const Value('item_1'),
          logDate: const Value('2026-10-19'),
          period: const Value('pm'),
          done: const Value(true),
          createdAt: Value(now),
        ),
      );

      final logs = await routineDao.getRoutineLogsForDate(
        userId: 'user_routine',
        logDate: '2026-10-19',
      );
      expect(logs.length, 1);
      expect(logs.first.done, isTrue);

      await routineDao.deleteRoutineItem('item_1');
      expect(await routineDao.getRoutineItems('user_routine'), isEmpty);
    });
  });

  group('ExperimentDao', () {
    test('manages experiments and linked scans', () async {
      final now = DateTime.now();
      await profileDao.upsertProfile(
        ProfilesCompanion(
          id: const Value('user_exp'),
          createdAt: Value(now),
          updatedAt: Value(now),
        ),
      );
      await scanDao.upsertScan(
        scan: ScansCompanion(
          id: const Value('baseline_scan'),
          userId: const Value('user_exp'),
          createdAt: Value(now),
        ),
      );

      await experimentDao.upsertExperiment(
        experiment: ExperimentsCompanion(
          id: const Value('exp_1'),
          userId: const Value('user_exp'),
          title: const Value('Testing Niacinamide 10%'),
          targets: const Value(['pores', 'texture']),
          plannedDays: const Value(42),
          startedAt: Value(now),
          startedOn: const Value('2026-10-19'),
          createdAt: Value(now),
          updatedAt: Value(now),
        ),
        linkedScans: const [
          ExperimentScansCompanion(
            experimentId: Value('exp_1'),
            scanId: Value('baseline_scan'),
            role: Value('baseline'),
          ),
        ],
      );

      final exp = await experimentDao.getExperiment('exp_1');
      expect(exp, isNotNull);
      expect(exp!.title, 'Testing Niacinamide 10%');
      expect(exp.targets, ['pores', 'texture']);

      final links = await experimentDao.getScansForExperiment('exp_1');
      expect(links.length, 1);
      expect(links.first.role, 'baseline');

      await experimentDao.deleteExperiment('exp_1');
      expect(await experimentDao.getExperiment('exp_1'), isNull);
      expect(await experimentDao.getScansForExperiment('exp_1'), isEmpty);
    });
  });

  group('SyncMutationDao', () {
    test('enqueues mutations and preserves FIFO order', () async {
      await syncMutationDao.enqueue(
        id: 'mut_1',
        targetTable: 'profiles',
        recordId: 'user_1',
        action: 'upsert',
        payload: {'name': 'Step 1'},
      );

      await Future<void>.delayed(const Duration(milliseconds: 10));

      await syncMutationDao.enqueue(
        id: 'mut_2',
        targetTable: 'routine_items',
        recordId: 'item_1',
        action: 'upsert',
        payload: {'name': 'Step 2'},
      );

      expect(await syncMutationDao.countPending(), 2);

      final pending = await syncMutationDao.getPending(limit: 10);
      expect(pending.length, 2);
      expect(pending.first.id, 'mut_1');
      expect(pending.last.id, 'mut_2');

      // Mark failure with attempt count
      await syncMutationDao.recordFailure(
        id: 'mut_1',
        errorMessage: 'Network timeout',
        nextAttemptCount: 1,
      );

      final updated = await syncMutationDao.getPending();
      expect(updated.first.attempts, 1);
      expect(updated.first.errorMessage, 'Network timeout');

      // Remove
      await syncMutationDao.remove('mut_1');
      expect(await syncMutationDao.countPending(), 1);
    });
  });
}
