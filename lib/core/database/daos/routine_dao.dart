import 'package:drift/drift.dart';
import 'package:kora/core/database/app_database.dart';

/// Data Access Object for routine items and routine logs in Drift SQLite.
class RoutineDao {
  /// Creates a [RoutineDao].
  RoutineDao(this._db);

  final AppDatabase _db;

  /// Retrieves all routine items for [userId] ordered by sortOrder.
  Future<List<RoutineItemEntry>> getRoutineItems(String userId) {
    return (_db.select(_db.routineItemsTable)
          ..where((tbl) => tbl.userId.equals(userId))
          ..orderBy([(tbl) => OrderingTerm.asc(tbl.sortOrder)]))
        .get();
  }

  /// Watches all active routine items for [userId] reactively.
  Stream<List<RoutineItemEntry>> watchRoutineItems(String userId) {
    return (_db.select(_db.routineItemsTable)
          ..where((tbl) => tbl.userId.equals(userId) & tbl.active.equals(true))
          ..orderBy([(tbl) => OrderingTerm.asc(tbl.sortOrder)]))
        .watch();
  }

  /// Inserts or updates a [RoutineItemsCompanion] entry.
  Future<void> upsertRoutineItem(RoutineItemsCompanion companion) {
    return _db.into(_db.routineItemsTable).insertOnConflictUpdate(companion);
  }

  /// Deletes a routine item by [id].
  Future<int> deleteRoutineItem(String id) {
    return (_db.delete(
      _db.routineItemsTable,
    )..where((tbl) => tbl.id.equals(id))).go();
  }

  /// Retrieves routine completion logs for [userId] on a specific [logDate]
  /// (YYYY-MM-DD).
  Future<List<RoutineLogEntry>> getRoutineLogsForDate({
    required String userId,
    required String logDate,
  }) {
    return (_db.select(_db.routineLogsTable)..where(
          (tbl) => tbl.userId.equals(userId) & tbl.logDate.equals(logDate),
        ))
        .get();
  }

  /// Retrieves all routine completion logs for [userId].
  Future<List<RoutineLogEntry>> getAllRoutineLogs(String userId) {
    return (_db.select(_db.routineLogsTable)
          ..where((tbl) => tbl.userId.equals(userId))
          ..orderBy([(tbl) => OrderingTerm.desc(tbl.logDate)]))
        .get();
  }

  /// Watches routine completion logs for [userId] on a specific [logDate].
  Stream<List<RoutineLogEntry>> watchRoutineLogsForDate({
    required String userId,
    required String logDate,
  }) {
    return (_db.select(_db.routineLogsTable)..where(
          (tbl) => tbl.userId.equals(userId) & tbl.logDate.equals(logDate),
        ))
        .watch();
  }

  /// Inserts or updates a routine completion log.
  Future<void> upsertRoutineLog(RoutineLogsCompanion companion) {
    return _db.into(_db.routineLogsTable).insertOnConflictUpdate(companion);
  }

  /// Deletes legacy auto-seeded demo routine logs.
  Future<int> deleteDemoSeedLogs(String userId) {
    return (_db.delete(_db.routineLogsTable)..where(
          (tbl) =>
              tbl.userId.equals(userId) &
              (tbl.id.like('%-am-cleanser') |
                  tbl.id.like('%-am-toner') |
                  tbl.id.like('%-am-vitc') |
                  tbl.id.like('%-pm-cleanser')),
        ))
        .go();
  }

  /// Deletes all routine items and logs for [userId] (used on account reset).
  Future<void> deleteAllRoutineForUser(String userId) {
    return _db.transaction(() async {
      await (_db.delete(
        _db.routineLogsTable,
      )..where((tbl) => tbl.userId.equals(userId))).go();
      await (_db.delete(
        _db.routineItemsTable,
      )..where((tbl) => tbl.userId.equals(userId))).go();
    });
  }
}
