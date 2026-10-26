import 'package:drift/drift.dart';

/// Drift table mirroring PostgreSQL `public.scans`.
@DataClassName('ScanEntry')
class ScansTable extends Table {
  @override
  String get tableName => 'scans';

  /// Primary key (UUID).
  TextColumn get id => text()();

  /// Foreign key referencing profiles(id).
  TextColumn get userId => text()();

  /// Scan status: created, uploading, processing, done, failed, canceled.
  TextColumn get status => text().withDefault(const Constant('created'))();

  /// Scan mode: SD or HD.
  TextColumn get mode => text().withDefault(const Constant('SD'))();

  /// Remote API file ID from YouCam / Supabase.
  TextColumn get apiFileId => text().nullable()();

  /// Remote API task ID for asynchronous polling.
  TextColumn get apiTaskId => text().nullable()();

  /// Error code if analysis failed.
  TextColumn get errorCode => text().nullable()();

  /// Overall skin score (0..100).
  RealColumn get overallScore => real().nullable()();

  /// Estimated skin age.
  IntColumn get skinAge => integer().nullable()();

  /// Whether lighting and quality checks passed.
  BoolColumn get qualityOk => boolean().withDefault(const Constant(true))();

  /// Quality diagnostic flags JSON.
  TextColumn get qualityFlags => text().withDefault(const Constant('{}'))();

  /// Local or remote storage path for scan photo.
  TextColumn get photoPath => text().nullable()();

  /// Raw analysis provider result JSON.
  TextColumn get resultJson => text().nullable()();

  /// Whether this is a mock or demo scan.
  BoolColumn get isDemo => boolean().withDefault(const Constant(false))();

  /// Creation timestamp.
  DateTimeColumn get createdAt => dateTime()();

  /// Completion timestamp.
  DateTimeColumn get completedAt => dateTime().nullable()();

  /// Sync timestamp with remote.
  DateTimeColumn get syncedAt => dateTime().nullable()();

  @override
  Set<Column> get primaryKey => {id};
}
