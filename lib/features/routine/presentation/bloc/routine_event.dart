import 'package:equatable/equatable.dart';
import 'package:kora/features/routine/domain/entities/routine_product.dart';

/// Base class for all events dispatched to `RoutineBloc`.
sealed class RoutineEvent extends Equatable {
  /// Creates a [RoutineEvent].
  const RoutineEvent();

  @override
  List<Object?> get props => [];
}

/// Initializes and loads the user's routine items, today's logs, catalog, and
/// daily check-in.
final class RoutineStarted extends RoutineEvent {
  /// Creates a [RoutineStarted] event.
  const RoutineStarted({
    this.userId,
    this.initialPeriod,
    this.logDate,
  });

  /// User ID to load routine for.
  final String? userId;

  /// Optional initial period ('am' or 'pm').
  final String? initialPeriod;

  /// Optional ISO date (`YYYY-MM-DD`). Defaults to today.
  final String? logDate;

  @override
  List<Object?> get props => [userId, initialPeriod, logDate];
}

/// Switches the active routine period tab between `'am'` and `'pm'`.
final class RoutinePeriodChanged extends RoutineEvent {
  /// Creates a [RoutinePeriodChanged] event.
  const RoutinePeriodChanged(this.period);

  /// Target period (`'am'` or `'pm'`).
  final String period;

  @override
  List<Object?> get props => [period];
}

/// Toggles completion of a [RoutineProduct] step for the active period and day.
final class RoutineStepToggled extends RoutineEvent {
  /// Creates a [RoutineStepToggled] event.
  const RoutineStepToggled({
    required this.itemId,
    this.period,
  });

  /// Routine item UUID (`routine_items.id`).
  final String itemId;

  /// Optional override period ('am' or 'pm').
  final String? period;

  @override
  List<Object?> get props => [itemId, period];
}

/// Adds or updates a [RoutineProduct] in the user's routine.
final class RoutineProductSaved extends RoutineEvent {
  /// Creates a [RoutineProductSaved] event.
  const RoutineProductSaved(this.product);

  /// Product entity to persist.
  final RoutineProduct product;

  @override
  List<Object?> get props => [product];
}

/// Deletes a [RoutineProduct] from the user's routine.
final class RoutineProductDeleted extends RoutineEvent {
  /// Creates a [RoutineProductDeleted] event.
  const RoutineProductDeleted(this.productId);

  /// Product UUID to remove.
  final String productId;

  @override
  List<Object?> get props => [productId];
}

/// Filters or searches the curated product catalog (`public.catalog_products`).
final class RoutineCatalogFiltered extends RoutineEvent {
  /// Creates a [RoutineCatalogFiltered] event.
  const RoutineCatalogFiltered({
    this.category,
    this.query,
  });

  /// Selected category filter (`all`, `cleanser`, `serum`, etc.).
  final String? category;

  /// Search query text.
  final String? query;

  @override
  List<Object?> get props => [category, query];
}

/// Submits a daily skin check-in (`public.checkins`).
final class RoutineCheckinSubmitted extends RoutineEvent {
  /// Creates a [RoutineCheckinSubmitted] event.
  const RoutineCheckinSubmitted({
    required this.skinFeel,
    this.newProducts = false,
    this.note,
  });

  /// Skin feel rating (`1` = worse, `2` = same, `3` = better).
  final int skinFeel;

  /// Whether new products were introduced today.
  final bool newProducts;

  /// Optional user note.
  final String? note;

  @override
  List<Object?> get props => [skinFeel, newProducts, note];
}
