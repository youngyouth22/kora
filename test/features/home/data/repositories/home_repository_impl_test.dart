import 'package:drift/drift.dart';
import 'package:drift/native.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:kora/core/database/app_database.dart';
import 'package:kora/core/database/daos/routine_dao.dart';
import 'package:kora/core/database/daos/scan_dao.dart';
import 'package:kora/core/utils/active_user_resolver.dart';
import 'package:kora/features/home/data/repositories/home_repository_impl.dart';

void main() {
  late AppDatabase db;
  late RoutineDao routineDao;
  late ScanDao scanDao;
  late HomeRepositoryImpl repository;

  const testUserId = ActiveUserResolver.defaultFallbackUserId;

  setUp(() {
    db = AppDatabase.forTesting(NativeDatabase.memory());
    routineDao = RoutineDao(db);
    scanDao = ScanDao(db);
    repository = HomeRepositoryImpl(
      routineDao: routineDao,
      scanDao: scanDao,
    );
  });

  tearDown(() async {
    await db.close();
  });

  group('HomeRepositoryImpl streak calculation tests', () {
    test(
      'returns all false in streakDaysCompleted when user did nothing',
      () async {
        final result = await repository.getDashboardData();

        expect(result.isRight(), isTrue);
        result.fold(
          (_) => fail('Should succeed'),
          (data) {
            expect(data.streakDaysCompleted.length, 7);
            // All 7 days (Monday..Sunday) should be false when nothing was done
            expect(data.streakDaysCompleted.every((c) => !c), isTrue);
            expect(data.morningRoutineDone, isFalse);
            expect(data.eveningRoutineDone, isFalse);
          },
        );
      },
    );

    test(
      'ignores and purges legacy auto-seeded demo logs '
      'so Saturday and Sunday are not checked',
      () async {
        final now = DateTime.now();
        final weekday = now.weekday;
        final today = DateTime(now.year, now.month, now.day);
        final monday = today.subtract(Duration(days: weekday - 1));

        // Insert legacy fake seed logs for Saturday (index 5)
        // and Sunday (index 6)
        final saturday = DateTime(monday.year, monday.month, monday.day + 5);
        final saturdayIso =
            '${saturday.year.toString().padLeft(4, '0')}-'
            '${saturday.month.toString().padLeft(2, '0')}-'
            '${saturday.day.toString().padLeft(2, '0')}';

        final sunday = DateTime(monday.year, monday.month, monday.day + 6);
        final sundayIso =
            '${sunday.year.toString().padLeft(4, '0')}-'
            '${sunday.month.toString().padLeft(2, '0')}-'
            '${sunday.day.toString().padLeft(2, '0')}';

        // Seed logs with IDs ending in -am-cleanser, -pm-cleanser
        await routineDao.upsertRoutineLog(
          RoutineLogsCompanion.insert(
            id: 'log-$saturdayIso-am-cleanser',
            userId: testUserId,
            itemId: 'item-cerave-cleanser',
            logDate: saturdayIso,
            done: const Value(true),
            createdAt: saturday,
          ),
        );
        await routineDao.upsertRoutineLog(
          RoutineLogsCompanion.insert(
            id: 'log-$sundayIso-pm-cleanser',
            userId: testUserId,
            itemId: 'item-cerave-cleanser',
            logDate: sundayIso,
            done: const Value(true),
            createdAt: sunday,
          ),
        );

        final result = await repository.getDashboardData();

        expect(result.isRight(), isTrue);
        result.fold(
          (_) => fail('Should succeed'),
          (data) {
            // Saturday and Sunday must NOT be completed from demo seed logs
            expect(data.streakDaysCompleted[5], isFalse);
            expect(data.streakDaysCompleted[6], isFalse);
            expect(data.morningRoutineDone, isFalse);
            expect(data.eveningRoutineDone, isFalse);
          },
        );
      },
    );

    test(
      'marks a day as completed when user genuinely logs a routine step',
      () async {
        final now = DateTime.now();
        final todayIso =
            '${now.year.toString().padLeft(4, '0')}-'
            '${now.month.toString().padLeft(2, '0')}-'
            '${now.day.toString().padLeft(2, '0')}';

        // Legitimate user log with user action ID
        await routineDao.upsertRoutineLog(
          RoutineLogsCompanion.insert(
            id: 'log-$todayIso-am-item-cerave-cleanser',
            userId: testUserId,
            itemId: 'item-cerave-cleanser',
            logDate: todayIso,
            done: const Value(true),
            createdAt: now,
          ),
        );

        final result = await repository.getDashboardData();

        expect(result.isRight(), isTrue);
        result.fold(
          (_) => fail('Should succeed'),
          (data) {
            final todayIndex = now.weekday - 1;
            expect(data.streakDaysCompleted[todayIndex], isTrue);
            expect(data.morningRoutineDone, isTrue);
          },
        );
      },
    );
  });
}
