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
}
