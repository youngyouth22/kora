import 'package:drift/drift.dart';
import 'package:kora/core/database/app_database.dart';

/// Data Access Object for user profiles in Drift SQLite.
class ProfileDao {
  /// Creates a [ProfileDao].
  ProfileDao(this._db);

  final AppDatabase _db;

  /// Retrieves a profile by [id].
  Future<ProfileEntry?> getProfile(String id) {
    return (_db.select(
      _db.profilesTable,
    )..where((tbl) => tbl.id.equals(id))).getSingleOrNull();
  }

  /// Watches a profile reactively by [id].
  Stream<ProfileEntry?> watchProfile(String id) {
    return (_db.select(
      _db.profilesTable,
    )..where((tbl) => tbl.id.equals(id))).watchSingleOrNull();
  }

  /// Inserts or updates a [ProfilesCompanion] entry.
  Future<void> upsertProfile(ProfilesCompanion companion) {
    return _db.into(_db.profilesTable).insertOnConflictUpdate(companion);
  }

  /// Retrieves the most recently updated or created profile.
  Future<ProfileEntry?> getLatestProfile() {
    return (_db.select(_db.profilesTable)
          ..orderBy([
            (tbl) => OrderingTerm(
              expression: tbl.updatedAt,
              mode: OrderingMode.desc,
            ),
          ])
          ..limit(1))
        .getSingleOrNull();
  }

  /// Deletes a profile entry by [id].
  Future<int> deleteProfile(String id) {
    return (_db.delete(
      _db.profilesTable,
    )..where((tbl) => tbl.id.equals(id))).go();
  }
}
