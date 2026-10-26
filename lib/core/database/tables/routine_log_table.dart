import 'package:drift/drift.dart';

/// Drift table mirroring PostgreSQL `public.routine_logs`.
@DataClassName('RoutineLogEntry')
class RoutineLogsTable extends Table {
  @override
  String get tableName => 'routine_logs';

  /// Primary key (UUID).
  TextColumn get id => text()();

  /// Foreign key referencing profiles(id).
  TextColumn get userId => text()();

  /// Foreign key referencing routine_items(id).
  TextColumn get itemId => text()();

  /// ISO date string (YYYY-MM-DD).
  TextColumn get logDate => text()();

  /// Period: am or pm.
  TextColumn get period => text().withDefault(const Constant('am'))();

  /// Whether step was completed.
  BoolColumn get done => boolean().withDefault(const Constant(true))();

  /// Log creation timestamp.
  DateTimeColumn get createdAt => dateTime()();

  /// Sync timestamp with remote.
  DateTimeColumn get syncedAt => dateTime().nullable()();

  @override
  Set<Column> get primaryKey => {id};
}
