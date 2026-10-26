import 'package:drift/drift.dart';
import 'package:kora/core/database/converters/list_converters.dart';

/// Drift table mirroring PostgreSQL `public.profiles`.
@DataClassName('ProfileEntry')
class ProfilesTable extends Table {
  @override
  String get tableName => 'profiles';

  /// Primary key matching auth.users(id) or guest UUID.
  TextColumn get id => text()();

  /// User display name.
  TextColumn get displayName => text().nullable()();

  /// Skin goals (up to 3 concern keys).
  TextColumn get goals => text()
      .map(const StringListConverter())
      .withDefault(const Constant('[]'))();

  /// Skin type: oily, dry, combination, normal, unknown.
  TextColumn get skinType => text().nullable()();

  /// Skin sensitivities tags.
  TextColumn get sensitivities => text()
      .map(const StringListConverter())
      .withDefault(const Constant('[]'))();

  /// Fitzpatrick skin tone (1 to 6).
  IntColumn get skinToneSelf => integer().nullable()();

  /// Sun exposure habit: never, sometimes, daily.
  TextColumn get sunHabit => text().nullable()();

  /// Current active ingredients in use.
  TextColumn get currentActives => text()
      .map(const StringListConverter())
      .withDefault(const Constant('[]'))();

  /// When actives were started: lt_2w, 2_8w, gt_2m.
  TextColumn get activesStarted => text().nullable()();

  /// User timezone (e.g. UTC, America/New_York).
  TextColumn get timezone => text().withDefault(const Constant('UTC'))();

  /// User locale.
  TextColumn get locale => text().withDefault(const Constant('en'))();

  /// Weekly scan day (ISO weekday 1..7, 7 = Sunday).
  IntColumn get scanWeekday => integer().withDefault(const Constant(7))();

  /// Scan reminder time (e.g. '18:00').
  TextColumn get scanTime => text().withDefault(const Constant('18:00'))();

  /// Confirmation of adult age.
  BoolColumn get ageConfirmed => boolean().withDefault(const Constant(false))();

  /// Whether user keeps scan photos on remote storage.
  BoolColumn get keepPhotos => boolean().withDefault(const Constant(true))();

  /// Onboarding step completed.
  IntColumn get onboardingStep => integer().withDefault(const Constant(0))();

  /// When onboarding was finished.
  DateTimeColumn get onboardingCompletedAt => dateTime().nullable()();

  /// Whether this profile is a demo profile.
  BoolColumn get isDemo => boolean().withDefault(const Constant(false))();

  /// Creation timestamp.
  DateTimeColumn get createdAt => dateTime()();

  /// Last updated timestamp.
  DateTimeColumn get updatedAt => dateTime()();

  /// Local sync timestamp with Supabase.
  DateTimeColumn get syncedAt => dateTime().nullable()();

  @override
  Set<Column> get primaryKey => {id};
}
