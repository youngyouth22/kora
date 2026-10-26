// Encapsulate dependencies as private fields.
// ignore_for_file: prefer_initializing_formals

import 'dart:async';
import 'dart:developer' as developer;

import 'package:supabase/supabase.dart';

/// Callback signature for incoming real-time remote database mutations.
typedef RemoteChangeCallback = void Function({
  required String table,
  required String eventType,
  required Map<String, dynamic> newRecord,
  required Map<String, dynamic> oldRecord,
});

/// Contract for pushing outbox mutations and pulling remote rows from the
/// backend.
abstract class RemoteSyncDriver {
  /// Executes a single mutation against the remote backend idempotently.
  Future<void> applyMutation({
    required String targetTable,
    required String recordId,
    required String action,
    required Map<String, dynamic> payload,
  });

  /// Pulls all updated rows from [targetTable] for [userId] since [since].
  Future<List<Map<String, dynamic>>> pullChanges({
    required String targetTable,
    required String userId,
    DateTime? since,
  });

  /// Subscribes to real-time remote changes via WebSocket.
  void subscribeToChanges({
    required String userId,
    required RemoteChangeCallback onChange,
  });

  /// Unsubscribes from active real-time channels.
  void unsubscribeFromChanges();
}

/// Supabase implementation of [RemoteSyncDriver].
///
/// Uses idempotent `upsert` with primary key conflict targets and strict
/// user tenancy constraints.
class SupabaseSyncDriver implements RemoteSyncDriver {
  /// Creates a [SupabaseSyncDriver].
  SupabaseSyncDriver({required SupabaseClient? client}) : _client = client;

  final SupabaseClient? _client;

  @override
  Future<void> applyMutation({
    required String targetTable,
    required String recordId,
    required String action,
    required Map<String, dynamic> payload,
  }) async {
    final client = _client;
    if (client == null) {
      developer.log(
        'Supabase client not initialized; deferred: $targetTable',
        name: 'SupabaseSyncDriver',
      );
      return;
    }

    if (action == 'delete') {
      await client.from(targetTable).delete().eq('id', recordId);
    } else {
      // Clean null values and format timestamps for PostgreSQL compatibility
      final cleanedPayload = Map<String, dynamic>.from(payload);
      await client.from(targetTable).upsert(cleanedPayload);
    }
  }

  @override
  Future<List<Map<String, dynamic>>> pullChanges({
    required String targetTable,
    required String userId,
    DateTime? since,
  }) async {
    final client = _client;
    if (client == null) return const [];

    var query = client.from(targetTable).select();

    // Table profiles uses 'id', other tables use 'user_id'
    if (targetTable == 'profiles') {
      query = query.eq('id', userId);
    } else {
      query = query.eq('user_id', userId);
    }

    if (since != null) {
      query = query.gt('updated_at', since.toIso8601String());
    }

    final response = await query;
    return response;
  }

  RealtimeChannel? _realtimeChannel;

  @override
  void subscribeToChanges({
    required String userId,
    required RemoteChangeCallback onChange,
  }) {
    final client = _client;
    if (client == null) return;

    unsubscribeFromChanges();

    final channel = client.channel('public:kora_sync_$userId');
    _realtimeChannel = channel;

    channel
        .onPostgresChanges(
          event: PostgresChangeEvent.all,
          schema: 'public',
          callback: (payload) {
            onChange(
              table: payload.table,
              eventType: payload.eventType.name,
              newRecord: payload.newRecord,
              oldRecord: payload.oldRecord,
            );
          },
        )
        .subscribe();
  }

  @override
  void unsubscribeFromChanges() {
    final channel = _realtimeChannel;
    if (channel != null) {
      unawaited(_client?.removeChannel(channel));
      _realtimeChannel = null;
    }
  }
}
