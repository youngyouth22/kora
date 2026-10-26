import 'package:drift/drift.dart';

/// Local outbox queue recording all pending mutations for remote
/// synchronization.
///
/// Designed on PowerSync write-outbox principles to ensure zero data loss,
/// idempotent remote upserts, and strict FIFO commit guarantees.
@DataClassName('SyncMutationEntry')
class SyncMutationsTable extends Table {
  @override
  String get tableName => 'sync_mutations';

  /// Unique mutation identifier (UUID).
  TextColumn get id => text()();

  /// Target PostgreSQL table name (e.g. 'profiles', 'scans', 'routine_items').
  TextColumn get targetTable => text()();

  /// Target record primary key ID.
  TextColumn get recordId => text()();

  /// Mutation action: 'upsert' or 'delete'.
  TextColumn get action => text().withDefault(const Constant('upsert'))();

  /// JSON payload representing the record state at mutation time.
  TextColumn get payload => text()();

  /// Local timestamp when mutation was enqueued.
  DateTimeColumn get createdAt => dateTime()();

  /// Number of sync delivery attempts.
  IntColumn get attempts => integer().withDefault(const Constant(0))();

  /// Timestamp of the last sync attempt.
  DateTimeColumn get lastAttempt => dateTime().nullable()();

  /// Diagnostic error message if last attempt failed.
  TextColumn get errorMessage => text().nullable()();

  @override
  Set<Column> get primaryKey => {id};
}
