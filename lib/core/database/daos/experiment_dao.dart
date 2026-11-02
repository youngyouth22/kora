import 'package:drift/drift.dart';
import 'package:kora/core/database/app_database.dart';

/// Data Access Object for skincare product experiments in Drift SQLite.
class ExperimentDao {
  /// Creates an [ExperimentDao].
  ExperimentDao(this._db);

  final AppDatabase _db;

  /// Retrieves an experiment by [id].
  Future<ExperimentEntry?> getExperiment(String id) {
    return (_db.select(
      _db.experimentsTable,
    )..where((tbl) => tbl.id.equals(id))).getSingleOrNull();
  }

  /// Retrieves all experiments for [userId] sorted by startedAt descending.
  Future<List<ExperimentEntry>> getExperimentsForUser(String userId) {
    return (_db.select(_db.experimentsTable)
          ..where((tbl) => tbl.userId.equals(userId))
          ..orderBy([(tbl) => OrderingTerm.desc(tbl.startedAt)]))
        .get();
  }

  /// Watches all experiments for [userId] reactively.
  Stream<List<ExperimentEntry>> watchExperimentsForUser(String userId) {
    return (_db.select(_db.experimentsTable)
          ..where((tbl) => tbl.userId.equals(userId))
          ..orderBy([(tbl) => OrderingTerm.desc(tbl.startedAt)]))
        .watch();
  }

  /// Retrieves all scan links for [experimentId].
  Future<List<ExperimentScanEntry>> getScansForExperiment(String experimentId) {
    return (_db.select(
      _db.experimentScansTable,
    )..where((tbl) => tbl.experimentId.equals(experimentId))).get();
  }

  /// Inserts or updates an experiment and its linked scan associations
  /// atomically.
  Future<void> upsertExperiment({
    required ExperimentsCompanion experiment,
    List<ExperimentScansCompanion> linkedScans = const [],
  }) {
    return _db.transaction(() async {
      await _db.into(_db.experimentsTable).insertOnConflictUpdate(experiment);
      for (final scan in linkedScans) {
        await _db.into(_db.experimentScansTable).insertOnConflictUpdate(scan);
      }
    });
  }

  /// Deletes an experiment and its scan links.
  Future<void> deleteExperiment(String id) {
    return _db.transaction(() async {
      await (_db.delete(
        _db.experimentScansTable,
      )..where((tbl) => tbl.experimentId.equals(id))).go();
      await (_db.delete(
        _db.experimentsTable,
      )..where((tbl) => tbl.id.equals(id))).go();
    });
  }

  /// Deletes all experiments and associated scan joins for [userId].
  Future<void> deleteAllExperimentsForUser(String userId) {
    return _db.transaction(() async {
      final userExpIds = await (_db.select(_db.experimentsTable)
            ..where((tbl) => tbl.userId.equals(userId)))
          .map((e) => e.id)
          .get();
      if (userExpIds.isNotEmpty) {
        await (_db.delete(_db.experimentScansTable)
              ..where((tbl) => tbl.experimentId.isIn(userExpIds)))
            .go();
      }
      await (_db.delete(_db.experimentsTable)
            ..where((tbl) => tbl.userId.equals(userId)))
          .go();
    });
  }
}
