import 'package:equatable/equatable.dart';

/// Pure domain entity representing a product in a user's skincare routine.
class RoutineProduct extends Equatable {
  /// Creates a [RoutineProduct].
  const RoutineProduct({
    required this.id,
    required this.userId,
    required this.name,
    required this.createdAt,
    required this.updatedAt,
    this.brand,
    this.stepType = 'other',
    this.actives = const [],
    this.period = 'both',
    this.days,
    this.startedOn,
    this.active = true,
    this.sortOrder = 100,
    this.catalogProductId,
    this.ingredientsRaw,
  });

  /// Unique identifier (UUID).
  final String id;

  /// User identifier.
  final String userId;

  /// Product name.
  final String name;

  /// Brand name.
  final String? brand;

  /// Step type: cleanser, toner, serum, treatment,
  /// moisturizer, spf, mask, other.
  final String stepType;

  /// Active ingredients (e.g. ['retinol', 'niacinamide']).
  final List<String> actives;

  /// Routine application period: 'am', 'pm', or 'both'.
  final String period;

  /// ISO weekdays 1..7 (null = daily).
  final List<int>? days;

  /// Date started using this product.
  final DateTime? startedOn;

  /// Whether product is currently used.
  final bool active;

  /// Sorting order index.
  final int sortOrder;

  /// Reference to catalog product if linked.
  final String? catalogProductId;

  /// Raw ingredient list text.
  final String? ingredientsRaw;

  /// Creation timestamp.
  final DateTime createdAt;

  /// Last updated timestamp.
  final DateTime updatedAt;

  @override
  List<Object?> get props => [
    id,
    userId,
    name,
    brand,
    stepType,
    actives,
    period,
    days,
    startedOn,
    active,
    sortOrder,
    catalogProductId,
    ingredientsRaw,
    createdAt,
    updatedAt,
  ];
}

/// Pure domain entity representing a daily routine completion checkmark.
class RoutineLogRecord extends Equatable {
  /// Creates a [RoutineLogRecord].
  const RoutineLogRecord({
    required this.id,
    required this.userId,
    required this.itemId,
    required this.logDate,
    required this.createdAt,
    this.period = 'am',
    this.done = true,
  });

  /// Unique identifier (UUID).
  final String id;

  /// User identifier.
  final String userId;

  /// Routine product identifier.
  final String itemId;

  /// ISO date string (YYYY-MM-DD).
  final String logDate;

  /// 'am' or 'pm'.
  final String period;

  /// Whether step was completed.
  final bool done;

  /// Creation timestamp.
  final DateTime createdAt;

  @override
  List<Object?> get props => [
    id,
    userId,
    itemId,
    logDate,
    period,
    done,
    createdAt,
  ];
}
