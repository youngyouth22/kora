import 'package:drift/drift.dart' hide isNotNull, isNull;
import 'package:drift/native.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:kora/core/database/app_database.dart';
import 'package:kora/core/database/daos/profile_dao.dart';
import 'package:kora/core/database/daos/sync_mutation_dao.dart';
import 'package:kora/features/onboarding/data/datasources/onboarding_local_datasource.dart';

void main() {
  late AppDatabase db;
  late ProfileDao profileDao;
  late SyncMutationDao syncMutationDao;
  late OnboardingLocalDataSourceImpl dataSource;

  setUp(() {
    db = AppDatabase.forTesting(NativeDatabase.memory());
    profileDao = ProfileDao(db);
    syncMutationDao = SyncMutationDao(db);
    dataSource = OnboardingLocalDataSourceImpl(
      profileDao: profileDao,
      appDatabase: db,
      syncMutationDao: syncMutationDao,
    );
  });

  tearDown(() async {
    await db.close();
  });

  group('OnboardingLocalDataSource guest migration', () {
    test(
      'migrates guest scans, routine items, logs, and experiments to new user',
      () async {
        const guestId = 'kora_guest_99999_abcd';
        const newUserId = 'authenticated_user_uuid';
        final now = DateTime.now();

        // 1. Seed guest profile
        await profileDao.upsertProfile(
          ProfilesCompanion(
            id: const Value(guestId),
            displayName: const Value('Guest User'),
            skinType: const Value('oily'),
            goals: const Value(['acne', 'pores']),
            createdAt: Value(now),
            updatedAt: Value(now),
          ),
        );

        // 2. Seed guest scan & concern
        await db
            .into(db.scansTable)
            .insert(
              ScansCompanion(
                id: const Value('scan_guest_1'),
                userId: const Value(guestId),
                status: const Value('done'),
                overallScore: const Value(82.5),
                skinAge: const Value(24),
                createdAt: Value(now),
              ),
            );

        await db
            .into(db.scanConcernsTable)
            .insert(
              const ScanConcernsCompanion(
                id: Value('concern_guest_1'),
                scanId: Value('scan_guest_1'),
                userId: Value(guestId),
                concern: Value('pores'),
                rawScore: Value(75),
              ),
            );

        // 3. Seed guest routine item & log
        await db
            .into(db.routineItemsTable)
            .insert(
              RoutineItemsCompanion(
                id: const Value('routine_item_1'),
                userId: const Value(guestId),
                name: const Value('Hydrating Cleanser'),
                period: const Value('am'),
                active: const Value(true),
                createdAt: Value(now),
                updatedAt: Value(now),
              ),
            );

        await db
            .into(db.routineLogsTable)
            .insert(
              RoutineLogsCompanion(
                id: const Value('routine_log_1'),
                userId: const Value(guestId),
                itemId: const Value('routine_item_1'),
                logDate: const Value('2026-11-02'),
                done: const Value(true),
                createdAt: Value(now),
              ),
            );

        // 4. Seed guest experiment
        await db
            .into(db.experimentsTable)
            .insert(
              ExperimentsCompanion(
                id: const Value('experiment_1'),
                userId: const Value(guestId),
                title: const Value('Vitamin C Trial'),
                status: const Value('active'),
                targets: const Value(['radiance']),
                startedOn: const Value('2026-11-02'),
                startedAt: Value(now),
                createdAt: Value(now),
                updatedAt: Value(now),
              ),
            );

        // Execute linking & migration
        await dataSource.linkProfileToUser(userId: newUserId);

        // Verify profile was migrated
        final newProfile = await profileDao.getProfile(newUserId);
        expect(newProfile, isNotNull);
        expect(newProfile!.id, newUserId);
        expect(newProfile.skinType, 'oily');

        final oldProfile = await profileDao.getProfile(guestId);
        expect(oldProfile, isNull);

        // Verify scan was migrated
        final scans = await (db.select(
          db.scansTable,
        )..where((tbl) => tbl.userId.equals(newUserId))).get();
        expect(scans.length, 1);
        expect(scans.first.id, 'scan_guest_1');

        final oldScans = await (db.select(
          db.scansTable,
        )..where((tbl) => tbl.userId.equals(guestId))).get();
        expect(oldScans, isEmpty);

        // Verify concern was migrated
        final concerns = await (db.select(
          db.scanConcernsTable,
        )..where((tbl) => tbl.userId.equals(newUserId))).get();
        expect(concerns.length, 1);
        expect(concerns.first.id, 'concern_guest_1');

        // Verify routine item & log were migrated
        final routineItems = await (db.select(
          db.routineItemsTable,
        )..where((tbl) => tbl.userId.equals(newUserId))).get();
        expect(routineItems.length, 1);
        expect(routineItems.first.name, 'Hydrating Cleanser');

        final routineLogs = await (db.select(
          db.routineLogsTable,
        )..where((tbl) => tbl.userId.equals(newUserId))).get();
        expect(routineLogs.length, 1);
        expect(routineLogs.first.logDate, '2026-11-02');

        // Verify experiment was migrated
        final experiments = await (db.select(
          db.experimentsTable,
        )..where((tbl) => tbl.userId.equals(newUserId))).get();
        expect(experiments.length, 1);
        expect(experiments.first.title, 'Vitamin C Trial');

        // Verify sync mutations were enqueued for remote replication
        final mutations = await syncMutationDao.getPending();
        expect(mutations, isNotEmpty);
        expect(
          mutations.any((m) => m.targetTable == 'scans'),
          isTrue,
        );
        expect(
          mutations.any((m) => m.targetTable == 'routine_items'),
          isTrue,
        );
        expect(
          mutations.any((m) => m.targetTable == 'routine_logs'),
          isTrue,
        );
      },
    );
  });
}
