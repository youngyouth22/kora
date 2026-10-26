import 'package:drift/drift.dart';
import 'package:kora/core/database/converters/list_converters.dart';

/// Drift table mirroring PostgreSQL `public.experiments`.
@DataClassName('ExperimentEntry')
class ExperimentsTable extends Table {
  @override
  String get tableName => 'experiments';

  /// Primary key (UUID).
  TextColumn get id => text()();

  /// Foreign key referencing profiles(id).
  TextColumn get userId => text()();

  /// Optional foreign key referencing routine_items(id).
  TextColumn get itemId => text().nullable()();

  /// Experiment title (snapshot of tested product).
  TextColumn get title => text()();

  /// Target concern keys (1..2).
  TextColumn get targets => text()
      .map(const StringListConverter())
      .withDefault(const Constant('[]'))();

  /// Planned tracking days (14..180).
  IntColumn get plannedDays => integer().withDefault(const Constant(42))();

  /// Started timestamp.
  DateTimeColumn get startedAt => dateTime()();

  /// ISO date string when experiment started (YYYY-MM-DD).
  TextColumn get startedOn => text()();

  /// Ended timestamp if finished or stopped.
  DateTimeColumn get endedAt => dateTime().nullable()();

  /// Status: active, paused, completed, stopped.
  TextColumn get status => text().withDefault(const Constant('active'))();

  /// Statistical / AI verdict JSON snapshot.
  TextColumn get verdict => text().nullable()();

  /// Adherence rate (0.000 to 1.000).
  RealColumn get adherence => real().nullable()();

  /// Creation timestamp.
  DateTimeColumn get createdAt => dateTime()();

  /// Last updated timestamp.
  DateTimeColumn get updatedAt => dateTime()();

  /// Sync timestamp with remote.
  DateTimeColumn get syncedAt => dateTime().nullable()();

  @override
  Set<Column> get primaryKey => {id};
}
