// Encapsulate dependencies as private fields.
// ignore_for_file: prefer_initializing_formals

import 'dart:async';
import 'dart:convert';
import 'dart:developer' as developer;
import 'dart:math';

import 'package:drift/drift.dart';
import 'package:kora/core/database/app_database.dart';
import 'package:kora/core/database/daos/sync_mutation_dao.dart';
import 'package:kora/core/network/network_info.dart';
import 'package:kora/core/sync/supabase_sync_driver.dart';
import 'package:kora/core/sync/sync_status.dart';

/// Enterprise synchronization engine for Kora.
///
/// Implements PowerSync-style write outbox queue draining, deterministic FIFO
/// ordering, conflict resolution (Local Pending Outbox Wins over remote pull),
/// and resilient exponential backoff with jitter.
class SyncEngine {
  /// Creates a [SyncEngine].
  SyncEngine({
    required AppDatabase database,
    required SyncMutationDao mutationDao,
    required RemoteSyncDriver remoteDriver,
    required NetworkInfo networkInfo,
    Duration Function(int attempts)? backoffStrategy,
  }) : _db = database,
       _mutationDao = mutationDao,
       _remoteDriver = remoteDriver,
       _networkInfo = networkInfo,
       _backoffStrategy =
           backoffStrategy ??
           ((attempts) => Duration(
             milliseconds: min(
               1000 * pow(2, min(attempts, 5)).toInt(),
               30000,
             ),
           ));

  final AppDatabase _db;
  final SyncMutationDao _mutationDao;
  final RemoteSyncDriver _remoteDriver;
  final NetworkInfo _networkInfo;
  final Duration Function(int attempts) _backoffStrategy;

  final _statusController = StreamController<SyncStatus>.broadcast();
  SyncStatus _currentStatus = SyncStatus.idle;
  Completer<void>? _outboxCompleter;

  /// Stream of engine operational states for UI banners or status pills.
  Stream<SyncStatus> get statusStream => _statusController.stream;

  /// Current engine status.
  SyncStatus get currentStatus => _currentStatus;

  void _setStatus(SyncStatus status) {
    if (_currentStatus != status) {
      _currentStatus = status;
      _statusController.add(status);
    }
  }

  /// Triggers a full synchronization cycle: drains the write outbox first,
  /// then pulls remote deltas if [userId] is specified.
  Future<void> sync({String? userId}) async {
    final connected = await _networkInfo.isConnected;
    if (!connected) {
      _setStatus(SyncStatus.offline);
      return;
    }

    _setStatus(SyncStatus.syncing);

    try {
      await drainOutbox();
      if (userId != null && userId.isNotEmpty) {
        await pullAll(userId);
      }
      _setStatus(SyncStatus.idle);
    } on Object catch (e, stack) {
      developer.log(
        'Sync cycle failed: $e',
        name: 'SyncEngine',
        error: e,
        stackTrace: stack,
      );
      _setStatus(SyncStatus.error);
    }
  }

  /// Called whenever a repository enqueues a new mutation.
  ///
  /// Immediately schedules outbox processing without blocking the caller.
  void notifyMutationEnqueued() {
    unawaited(_drainOutboxSafe());
  }

  Future<void> _drainOutboxSafe() async {
    try {
      final connected = await _networkInfo.isConnected;
      if (!connected) {
        _setStatus(SyncStatus.offline);
        return;
      }
      await drainOutbox();
    } on Object catch (e) {
      developer.log(
        'Outbox background flush encountered error: $e',
        name: 'SyncEngine',
      );
    }
  }

  /// Sequentially executes pending mutations in strict FIFO order.
  Future<void> drainOutbox() async {
    if (_outboxCompleter != null) {
      return _outboxCompleter!.future;
    }
    final completer = Completer<void>();
    completer.future.ignore();
    _outboxCompleter = completer;

    try {
      while (true) {
        final pending = await _mutationDao.getPending(limit: 20);
        if (pending.isEmpty) break;

        final isOnline = await _networkInfo.isConnected;
        if (!isOnline) {
          _setStatus(SyncStatus.offline);
          break;
        }

        for (final mutation in pending) {
          try {
            final payload =
                json.decode(mutation.payload) as Map<String, dynamic>;

            await _remoteDriver.applyMutation(
              targetTable: mutation.targetTable,
              recordId: mutation.recordId,
              action: mutation.action,
              payload: payload,
            );

            // Mutation successfully acknowledged by remote backend
            await _mutationDao.remove(mutation.id);
          } on Object catch (e) {
            final nextAttempts = mutation.attempts + 1;
            await _mutationDao.recordFailure(
              id: mutation.id,
              errorMessage: e.toString(),
              nextAttemptCount: nextAttempts,
            );

            // Backoff on transient error
            final delay = _backoffStrategy(nextAttempts);
            if (delay > Duration.zero) {
              await Future<void>.delayed(delay);
            }
            rethrow;
          }
        }
      }
      completer.complete();
    } on Object catch (e, st) {
      completer.completeError(e, st);
      rethrow;
    } finally {
      _outboxCompleter = null;
    }
  }

  /// Pulls remote changes for all mirrored tables and reconciles with Drift.
  ///
  /// Follows the Outbox Wins principle: local records with active pending
  /// mutations are protected against remote overwrite until local writes are
  /// flushed.
  Future<void> pullAll(String userId) async {
    // 1. Fetch pending outbox record IDs to prevent clobbering writes
    final pendingMutations = await _mutationDao.getPending(limit: 500);
    final pendingRecordIds = pendingMutations.map((m) => m.recordId).toSet();

    // 2. Pull profiles
    try {
      final profileRows = await _remoteDriver.pullChanges(
        targetTable: 'profiles',
        userId: userId,
      );
      for (final row in profileRows) {
        final id = row['id']?.toString();
        if (id == null || pendingRecordIds.contains(id)) continue;
        await _db
            .into(_db.profilesTable)
            .insertOnConflictUpdate(
              ProfilesCompanion(
                id: Value(id),
                displayName: Value(row['display_name'] as String?),
                skinType: Value(row['skin_type'] as String?),
                skinToneSelf: Value(row['skin_tone_self'] as int?),
                sunHabit: Value(row['sun_habit'] as String?),
                activesStarted: Value(row['actives_started'] as String?),
                timezone: Value(row['timezone'] as String? ?? 'UTC'),
                locale: Value(row['locale'] as String? ?? 'en'),
                scanWeekday: Value(row['scan_weekday'] as int? ?? 7),
                scanTime: Value(row['scan_time'] as String? ?? '18:00'),
                ageConfirmed: Value(row['age_confirmed'] as bool? ?? false),
                keepPhotos: Value(row['keep_photos'] as bool? ?? true),
                onboardingStep: Value(row['onboarding_step'] as int? ?? 0),
                createdAt: Value(
                  DateTime.tryParse(row['created_at']?.toString() ?? '') ??
                      DateTime.now(),
                ),
                updatedAt: Value(
                  DateTime.tryParse(row['updated_at']?.toString() ?? '') ??
                      DateTime.now(),
                ),
                syncedAt: Value(DateTime.now()),
              ),
            );
      }
    } on Object catch (e) {
      developer.log('Pull profiles warning: $e', name: 'SyncEngine');
    }

    // 3. Pull routine items
    try {
      final routineRows = await _remoteDriver.pullChanges(
        targetTable: 'routine_items',
        userId: userId,
      );
      for (final row in routineRows) {
        final id = row['id']?.toString();
        if (id == null || pendingRecordIds.contains(id)) continue;
        await _db
            .into(_db.routineItemsTable)
            .insertOnConflictUpdate(
              RoutineItemsCompanion(
                id: Value(id),
                userId: Value(userId),
                name: Value(row['name'] as String? ?? ''),
                brand: Value(row['brand'] as String?),
                stepType: Value(row['step_type'] as String? ?? 'other'),
                period: Value(row['period'] as String? ?? 'both'),
                active: Value(row['active'] as bool? ?? true),
                sortOrder: Value(row['sort_order'] as int? ?? 100),
                ingredientsRaw: Value(row['ingredients_raw'] as String?),
                createdAt: Value(
                  DateTime.tryParse(row['created_at']?.toString() ?? '') ??
                      DateTime.now(),
                ),
                updatedAt: Value(
                  DateTime.tryParse(row['updated_at']?.toString() ?? '') ??
                      DateTime.now(),
                ),
                syncedAt: Value(DateTime.now()),
              ),
            );
      }
    } on Object catch (e) {
      developer.log('Pull routine items warning: $e', name: 'SyncEngine');
    }

    // 4. Pull experiments
    try {
      final expRows = await _remoteDriver.pullChanges(
        targetTable: 'experiments',
        userId: userId,
      );
      for (final row in expRows) {
        final id = row['id']?.toString();
        if (id == null || pendingRecordIds.contains(id)) continue;
        await _db
            .into(_db.experimentsTable)
            .insertOnConflictUpdate(
              ExperimentsCompanion(
                id: Value(id),
                userId: Value(userId),
                itemId: Value(row['item_id'] as String?),
                title: Value(row['title'] as String? ?? ''),
                plannedDays: Value(row['planned_days'] as int? ?? 42),
                startedAt: Value(
                  DateTime.tryParse(row['started_at']?.toString() ?? '') ??
                      DateTime.now(),
                ),
                startedOn: Value(row['started_on'] as String? ?? ''),
                status: Value(row['status'] as String? ?? 'active'),
                adherence: Value(
                  row['adherence'] != null
                      ? double.tryParse(row['adherence'].toString())
                      : null,
                ),
                createdAt: Value(
                  DateTime.tryParse(row['created_at']?.toString() ?? '') ??
                      DateTime.now(),
                ),
                updatedAt: Value(
                  DateTime.tryParse(row['updated_at']?.toString() ?? '') ??
                      DateTime.now(),
                ),
                syncedAt: Value(DateTime.now()),
              ),
            );
      }
    } on Object catch (e) {
      developer.log('Pull experiments warning: $e', name: 'SyncEngine');
    }
  }

  /// Subscribes to real-time changes via Supabase WebSocket channel.
  void startRealtimeSync(String userId) {
    _remoteDriver.subscribeToChanges(
      userId: userId,
      onChange:
          ({
            required String table,
            required String eventType,
            required Map<String, dynamic> newRecord,
            required Map<String, dynamic> oldRecord,
          }) {
            unawaited(
              _handleRemoteChange(
                table: table,
                eventType: eventType,
                newRecord: newRecord,
                oldRecord: oldRecord,
                userId: userId,
              ),
            );
          },
    );
  }

  /// Unsubscribes from active real-time channels.
  void stopRealtimeSync() {
    _remoteDriver.unsubscribeFromChanges();
  }

  Future<void> _handleRemoteChange({
    required String table,
    required String eventType,
    required Map<String, dynamic> newRecord,
    required Map<String, dynamic> oldRecord,
    required String userId,
  }) async {
    final recordId = (newRecord['id'] ?? oldRecord['id'])?.toString();
    if (recordId == null) return;

    // Outbox Wins: protect pending local mutations from remote overwrite
    final pending = await _mutationDao.getPending(limit: 500);
    if (pending.any((m) => m.recordId == recordId)) {
      developer.log(
        'Realtime change skipped for pending outbox mutation: $recordId',
        name: 'SyncEngine',
      );
      return;
    }

    if (eventType.toLowerCase() == 'delete') {
      await _deleteLocalRecord(table, recordId);
    } else {
      await _upsertLocalRecord(table, newRecord, userId);
    }
  }

  Future<void> _deleteLocalRecord(String table, String id) async {
    switch (table) {
      case 'profiles':
        await (_db.delete(
          _db.profilesTable,
        )..where((tbl) => tbl.id.equals(id))).go();
      case 'routine_items':
        await (_db.delete(
          _db.routineItemsTable,
        )..where((tbl) => tbl.id.equals(id))).go();
      case 'routine_logs':
        await (_db.delete(
          _db.routineLogsTable,
        )..where((tbl) => tbl.id.equals(id))).go();
      case 'experiments':
        await (_db.delete(
          _db.experimentsTable,
        )..where((tbl) => tbl.id.equals(id))).go();
      case 'scans':
        await (_db.delete(
          _db.scansTable,
        )..where((tbl) => tbl.id.equals(id))).go();
    }
  }

  Future<void> _upsertLocalRecord(
    String table,
    Map<String, dynamic> row,
    String userId,
  ) async {
    final id = row['id']?.toString();
    if (id == null) return;

    switch (table) {
      case 'profiles':
        await _db
            .into(_db.profilesTable)
            .insertOnConflictUpdate(
              ProfilesCompanion(
                id: Value(id),
                displayName: Value(row['display_name'] as String?),
                skinType: Value(row['skin_type'] as String?),
                skinToneSelf: Value(row['skin_tone_self'] as int?),
                sunHabit: Value(row['sun_habit'] as String?),
                activesStarted: Value(row['actives_started'] as String?),
                timezone: Value(row['timezone'] as String? ?? 'UTC'),
                locale: Value(row['locale'] as String? ?? 'en'),
                scanWeekday: Value(row['scan_weekday'] as int? ?? 7),
                scanTime: Value(row['scan_time'] as String? ?? '18:00'),
                ageConfirmed: Value(row['age_confirmed'] as bool? ?? false),
                keepPhotos: Value(row['keep_photos'] as bool? ?? true),
                onboardingStep: Value(row['onboarding_step'] as int? ?? 0),
                createdAt: Value(
                  DateTime.tryParse(row['created_at']?.toString() ?? '') ??
                      DateTime.now(),
                ),
                updatedAt: Value(
                  DateTime.tryParse(row['updated_at']?.toString() ?? '') ??
                      DateTime.now(),
                ),
                syncedAt: Value(DateTime.now()),
              ),
            );
      case 'routine_items':
        await _db
            .into(_db.routineItemsTable)
            .insertOnConflictUpdate(
              RoutineItemsCompanion(
                id: Value(id),
                userId: Value(row['user_id']?.toString() ?? userId),
                name: Value(row['name'] as String? ?? ''),
                brand: Value(row['brand'] as String?),
                stepType: Value(row['step_type'] as String? ?? 'other'),
                period: Value(row['period'] as String? ?? 'both'),
                active: Value(row['active'] as bool? ?? true),
                sortOrder: Value(row['sort_order'] as int? ?? 100),
                ingredientsRaw: Value(row['ingredients_raw'] as String?),
                createdAt: Value(
                  DateTime.tryParse(row['created_at']?.toString() ?? '') ??
                      DateTime.now(),
                ),
                updatedAt: Value(
                  DateTime.tryParse(row['updated_at']?.toString() ?? '') ??
                      DateTime.now(),
                ),
                syncedAt: Value(DateTime.now()),
              ),
            );
      case 'routine_logs':
        await _db
            .into(_db.routineLogsTable)
            .insertOnConflictUpdate(
              RoutineLogsCompanion(
                id: Value(id),
                userId: Value(row['user_id']?.toString() ?? userId),
                itemId: Value(row['item_id']?.toString() ?? ''),
                logDate: Value(row['log_date']?.toString() ?? ''),
                period: Value(row['period']?.toString() ?? 'am'),
                done: Value(row['done'] as bool? ?? true),
                createdAt: Value(
                  DateTime.tryParse(row['created_at']?.toString() ?? '') ??
                      DateTime.now(),
                ),
                syncedAt: Value(DateTime.now()),
              ),
            );
      case 'experiments':
        await _db
            .into(_db.experimentsTable)
            .insertOnConflictUpdate(
              ExperimentsCompanion(
                id: Value(id),
                userId: Value(row['user_id']?.toString() ?? userId),
                itemId: Value(row['item_id'] as String?),
                title: Value(row['title'] as String? ?? ''),
                plannedDays: Value(row['planned_days'] as int? ?? 42),
                startedAt: Value(
                  DateTime.tryParse(row['started_at']?.toString() ?? '') ??
                      DateTime.now(),
                ),
                startedOn: Value(row['started_on'] as String? ?? ''),
                status: Value(row['status'] as String? ?? 'active'),
                adherence: Value(
                  row['adherence'] != null
                      ? double.tryParse(row['adherence'].toString())
                      : null,
                ),
                createdAt: Value(
                  DateTime.tryParse(row['created_at']?.toString() ?? '') ??
                      DateTime.now(),
                ),
                updatedAt: Value(
                  DateTime.tryParse(row['updated_at']?.toString() ?? '') ??
                      DateTime.now(),
                ),
                syncedAt: Value(DateTime.now()),
              ),
            );
      default:
        await pullAll(userId);
    }
  }

  /// Closes active streams and cleans up resources.
  Future<void> dispose() async {
    stopRealtimeSync();
    await _statusController.close();
  }
}
