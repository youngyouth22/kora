import 'package:drift/drift.dart';

/// Drift table mirroring PostgreSQL `public.experiment_scans`.
@DataClassName('ExperimentScanEntry')
class ExperimentScansTable extends Table {
  @override
  String get tableName => 'experiment_scans';

  /// Foreign key referencing experiments(id).
  TextColumn get experimentId => text()();

  /// Foreign key referencing scans(id).
  TextColumn get scanId => text()();

  /// Role in experiment: 'baseline' or 'followup'.
  TextColumn get role => text()();

  /// Sync timestamp with remote.
  DateTimeColumn get syncedAt => dateTime().nullable()();

  @override
  Set<Column> get primaryKey => {experimentId, scanId};
}
