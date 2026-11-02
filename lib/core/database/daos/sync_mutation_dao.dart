import 'dart:convert';

import 'package:drift/drift.dart';
import 'package:kora/core/database/app_database.dart';

/// Data Access Object managing the offline outbox write queue in Drift SQLite.
///
/// Implements deterministic FIFO queuing with retry tracking and atomic
/// removals.
class SyncMutationDao {
  /// Creates a [SyncMutationDao].
  SyncMutationDao(this._db);

  final AppDatabase _db;

  /// Enqueues a new mutation to be synced to the remote Supabase database.
  Future<void> enqueue({
    required String id,
    required String targetTable,
    required String recordId,
    required String action,
    required Map<String, dynamic> payload,
  }) {
    return _db
        .into(_db.syncMutationsTable)
        .insertOnConflictUpdate(
          SyncMutationsCompanion(
            id: Value(id),
            targetTable: Value(targetTable),
            recordId: Value(recordId),
            action: Value(action),
            payload: Value(json.encode(payload)),
            createdAt: Value(DateTime.now()),
            attempts: const Value(0),
          ),
        );
  }

  /// Retrieves up to [limit] pending mutations ordered strictly by creation
  /// timestamp ascending (FIFO).
  Future<List<SyncMutationEntry>> getPending({int limit = 50}) {
    return (_db.select(_db.syncMutationsTable)
          ..orderBy([(tbl) => OrderingTerm.asc(tbl.createdAt)])
          ..limit(limit))
        .get();
  }

  /// Records an execution failure for mutation [id] with [errorMessage].
  Future<void> recordFailure({
    required String id,
    required String errorMessage,
    required int nextAttemptCount,
  }) {
    return (_db.update(
      _db.syncMutationsTable,
    )..where((tbl) => tbl.id.equals(id))).write(
      SyncMutationsCompanion(
        attempts: Value(nextAttemptCount),
        lastAttempt: Value(DateTime.now()),
        errorMessage: Value(errorMessage),
      ),
    );
  }

  /// Deletes a successfully synced mutation from the queue.
  Future<int> remove(String id) {
    return (_db.delete(
      _db.syncMutationsTable,
    )..where((tbl) => tbl.id.equals(id))).go();
  }

  /// Returns the current count of pending unsynced mutations.
  Future<int> countPending() async {
    final countExp = _db.syncMutationsTable.id.count();
    final query = _db.selectOnly(_db.syncMutationsTable)
      ..addColumns([countExp]);
    final result = await query.getSingle();
    return result.read(countExp) ?? 0;
  }

  /// Watches the number of pending mutations reactively.
  Stream<int> watchPendingCount() {
    final countExp = _db.syncMutationsTable.id.count();
    final query = _db.selectOnly(_db.syncMutationsTable)
      ..addColumns([countExp]);
    return query.watchSingle().map((row) => row.read(countExp) ?? 0);
  }

  /// Clears all pending mutations from the outbox (used on account reset).
  Future<int> clearAll() {
    return _db.delete(_db.syncMutationsTable).go();
  }
}
