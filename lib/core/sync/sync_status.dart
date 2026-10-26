/// Current operational state of the offline synchronization engine.
enum SyncStatus {
  /// Engine is idle, waiting for mutations or scheduled poll.
  idle,

  /// Active sync in progress (draining outbox or pulling remote updates).
  syncing,

  /// Device is offline; writes are queued locally.
  offline,

  /// Sync cycle encountered an error; will retry with backoff.
  error,
}
