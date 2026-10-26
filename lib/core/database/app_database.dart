import 'dart:io';

import 'package:drift/drift.dart';
import 'package:drift/native.dart';
import 'package:kora/core/database/converters/list_converters.dart';
import 'package:kora/core/database/tables/experiment_scan_table.dart';
import 'package:kora/core/database/tables/experiment_table.dart';
import 'package:kora/core/database/tables/profile_table.dart';
import 'package:kora/core/database/tables/routine_item_table.dart';
import 'package:kora/core/database/tables/routine_log_table.dart';
import 'package:kora/core/database/tables/scan_concern_table.dart';
import 'package:kora/core/database/tables/scan_table.dart';
import 'package:kora/core/database/tables/sync_mutation_table.dart';
import 'package:path/path.dart' as p;
import 'package:path_provider/path_provider.dart';

part 'app_database.g.dart';

/// Central Drift SQLite database for Kora offline-first storage.
///
/// Mirrors the PostgreSQL schema for client data and implements an outbox queue
/// for optimistic writes and asynchronous remote replication.
@DriftDatabase(
  tables: [
    ProfilesTable,
    ScansTable,
    ScanConcernsTable,
    RoutineItemsTable,
    RoutineLogsTable,
    ExperimentsTable,
    ExperimentScansTable,
    SyncMutationsTable,
  ],
)
class AppDatabase extends _$AppDatabase {
  /// Production constructor opening persistent SQLite database on device.
  AppDatabase() : super(_openConnection());

  /// Constructor for testing with in-memory or custom [QueryExecutor].
  AppDatabase.forTesting(super.e);

  @override
  int get schemaVersion => 1;

  @override
  MigrationStrategy get migration => MigrationStrategy(
    onCreate: (m) async {
      await m.createAll();
    },
    beforeOpen: (details) async {
      // Enable SQLite foreign keys and WAL mode for high performance.
      await customStatement('PRAGMA foreign_keys = ON;');
      await customStatement('PRAGMA journal_mode = WAL;');
    },
  );
}

LazyDatabase _openConnection() {
  return LazyDatabase(() async {
    final dbFolder = await getApplicationDocumentsDirectory();
    final file = File(p.join(dbFolder.path, 'kora_app.sqlite'));
    return NativeDatabase.createInBackground(file);
  });
}

/// Typedef alias for [ProfilesTableCompanion].
typedef ProfilesCompanion = ProfilesTableCompanion;

/// Typedef alias for [ScansTableCompanion].
typedef ScansCompanion = ScansTableCompanion;

/// Typedef alias for [ScanConcernsTableCompanion].
typedef ScanConcernsCompanion = ScanConcernsTableCompanion;

/// Typedef alias for [RoutineItemsTableCompanion].
typedef RoutineItemsCompanion = RoutineItemsTableCompanion;

/// Typedef alias for [RoutineLogsTableCompanion].
typedef RoutineLogsCompanion = RoutineLogsTableCompanion;

/// Typedef alias for [ExperimentsTableCompanion].
typedef ExperimentsCompanion = ExperimentsTableCompanion;

/// Typedef alias for [ExperimentScansTableCompanion].
typedef ExperimentScansCompanion = ExperimentScansTableCompanion;

/// Typedef alias for [SyncMutationsTableCompanion].
typedef SyncMutationsCompanion = SyncMutationsTableCompanion;
