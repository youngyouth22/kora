import 'package:drift/drift.dart';
import 'package:kora/core/database/converters/list_converters.dart';

/// Drift table mirroring PostgreSQL `public.routine_items`.
@DataClassName('RoutineItemEntry')
class RoutineItemsTable extends Table {
  @override
  String get tableName => 'routine_items';

  /// Primary key (UUID).
  TextColumn get id => text()();

  /// Foreign key referencing profiles(id).
  TextColumn get userId => text()();

  /// Product name.
  TextColumn get name => text()();

  /// Product brand name.
  TextColumn get brand => text().nullable()();

  /// Step type: cleanser, toner, serum, treatment,
  /// moisturizer, spf, mask, other.
  TextColumn get stepType => text().withDefault(const Constant('other'))();

  /// Active ingredients in product.
  TextColumn get actives => text()
      .map(const StringListConverter())
      .withDefault(const Constant('[]'))();

  /// Routine application period: am, pm, both.
  TextColumn get period => text().withDefault(const Constant('both'))();

  /// Days of application (ISO weekdays 1..7).
  TextColumn get days => text().map(const IntListConverter()).nullable()();

  /// Date started using this product.
  DateTimeColumn get startedOn => dateTime().nullable()();

  /// Whether product is actively in the routine.
  BoolColumn get active => boolean().withDefault(const Constant(true))();

  /// Display sort order index.
  IntColumn get sortOrder => integer().withDefault(const Constant(100))();

  /// Optional link to catalog product.
  TextColumn get catalogProductId => text().nullable()();

  /// Raw OCR ingredients text.
  TextColumn get ingredientsRaw => text().nullable()();

  /// Creation timestamp.
  DateTimeColumn get createdAt => dateTime()();

  /// Last update timestamp.
  DateTimeColumn get updatedAt => dateTime()();

  /// Sync timestamp with remote.
  DateTimeColumn get syncedAt => dateTime().nullable()();

  @override
  Set<Column> get primaryKey => {id};
}
