import 'package:drift/drift.dart';
import 'package:kora/core/database/app_database.dart';

/// Data Access Object for skin scans and concern scores in Drift SQLite.
class ScanDao {
  /// Creates a [ScanDao].
  ScanDao(this._db);

  final AppDatabase _db;

  /// Retrieves a scan by [id].
  Future<ScanEntry?> getScan(String id) {
    return (_db.select(
      _db.scansTable,
    )..where((tbl) => tbl.id.equals(id))).getSingleOrNull();
  }

  /// Retrieves all scans for [userId] sorted by createdAt descending.
  Future<List<ScanEntry>> getScansForUser(String userId) {
    return (_db.select(_db.scansTable)
          ..where(
            (tbl) =>
                tbl.userId.equals(userId) | tbl.userId.equals('local-user'),
          )
          ..orderBy([(tbl) => OrderingTerm.desc(tbl.createdAt)]))
        .get();
  }

  /// Migrates any orphaned scans from 'local-user' to [userId].
  Future<void> migrateLocalUserScans(String userId) async {
    if (userId.isEmpty || userId == 'local-user') return;
    final orphaned =
        await (_db.select(_db.scansTable)
              ..where((tbl) => tbl.userId.equals('local-user'))
              ..limit(1))
            .get();
    if (orphaned.isNotEmpty) {
      await (_db.update(_db.scansTable)
            ..where((tbl) => tbl.userId.equals('local-user')))
          .write(ScansCompanion(userId: Value(userId)));
      await (_db.update(_db.scanConcernsTable)
            ..where((tbl) => tbl.userId.equals('local-user')))
          .write(ScanConcernsCompanion(userId: Value(userId)));
    }
  }

  /// Watches all scans for [userId] reactively.
  Stream<List<ScanEntry>> watchScansForUser(String userId) {
    return (_db.select(_db.scansTable)
          ..where(
            (tbl) =>
                tbl.userId.equals(userId) | tbl.userId.equals('local-user'),
          )
          ..orderBy([(tbl) => OrderingTerm.desc(tbl.createdAt)]))
        .watch();
  }

  /// Retrieves all concern metrics for a specific [scanId].
  Future<List<ScanConcernEntry>> getScanConcerns(String scanId) {
    return (_db.select(
      _db.scanConcernsTable,
    )..where((tbl) => tbl.scanId.equals(scanId))).get();
  }

  /// Inserts or updates a scan and its associated concern rows atomically.
  Future<void> upsertScan({
    required ScansCompanion scan,
    List<ScanConcernsCompanion> concerns = const [],
  }) {
    return _db.transaction(() async {
      await _db.into(_db.scansTable).insertOnConflictUpdate(scan);
      for (final concern in concerns) {
        await _db.into(_db.scanConcernsTable).insertOnConflictUpdate(concern);
      }
    });
  }

  /// Deletes a scan and its associated concerns.
  Future<void> deleteScan(String id) {
    return _db.transaction(() async {
      await (_db.delete(
        _db.scanConcernsTable,
      )..where((tbl) => tbl.scanId.equals(id))).go();
      await (_db.delete(
        _db.scansTable,
      )..where((tbl) => tbl.id.equals(id))).go();
    });
  }

  /// Deletes all scans and associated concerns for [userId]
  /// (used on account reset).
  Future<void> deleteAllScansForUser(String userId) {
    return _db.transaction(() async {
      await (_db.delete(
        _db.scanConcernsTable,
      )..where((tbl) => tbl.userId.equals(userId))).go();
      await (_db.delete(
        _db.scansTable,
      )..where((tbl) => tbl.userId.equals(userId))).go();
    });
  }

  /// Clears photo references from scans and masks while preserving
  /// numerical scores.
  Future<void> clearAllPhotosForUser(String userId) {
    return _db.transaction(() async {
      await (_db.update(_db.scansTable)
            ..where((tbl) => tbl.userId.equals(userId)))
          .write(const ScansCompanion(photoPath: Value(null)));
      await (_db.update(_db.scanConcernsTable)
            ..where((tbl) => tbl.userId.equals(userId)))
          .write(const ScanConcernsCompanion(maskPath: Value(null)));
    });
  }
}
