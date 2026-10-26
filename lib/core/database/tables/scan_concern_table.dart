import 'package:drift/drift.dart';

/// Drift table mirroring PostgreSQL `public.scan_concerns`.
@DataClassName('ScanConcernEntry')
class ScanConcernsTable extends Table {
  @override
  String get tableName => 'scan_concerns';

  /// Primary key (UUID).
  TextColumn get id => text()();

  /// Foreign key referencing scans(id).
  TextColumn get scanId => text()();

  /// Foreign key referencing profiles(id).
  TextColumn get userId => text()();

  /// Concern metric key (e.g. spots, wrinkles, pores, texture).
  TextColumn get concern => text()();

  /// Facial zone (forehead, left_cheek, etc.).
  TextColumn get zone => text().nullable()();

  /// Normalized raw score (0..100) used for trends and clinical verdicts.
  RealColumn get rawScore => real()();

  /// Provider cosmetic display score.
  RealColumn get uiScore => real().nullable()();

  /// Path to mask overlay image.
  TextColumn get maskPath => text().nullable()();

  /// Sync timestamp with remote.
  DateTimeColumn get syncedAt => dateTime().nullable()();

  @override
  Set<Column> get primaryKey => {id};
}
