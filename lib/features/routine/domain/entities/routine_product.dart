import 'package:equatable/equatable.dart';

/// Valid step categories matching PostgreSQL `routine_items.step_type`
/// and `catalog_products.category` check constraint:
/// `('cleanser','toner','serum','treatment','moisturizer','spf','mask',`
/// `'other')`.
abstract final class RoutineStepType {
  /// Cleanser step.
  static const String cleanser = 'cleanser';

  /// Toner step.
  static const String toner = 'toner';

  /// Serum step.
  static const String serum = 'serum';

  /// Targeted treatment step (retinoids, exfoliants, etc.).
  static const String treatment = 'treatment';

  /// Moisturizer / barrier cream step.
  static const String moisturizer = 'moisturizer';

  /// Sunscreen (SPF) step.
  static const String spf = 'spf';

  /// Face mask step.
  static const String mask = 'mask';

  /// Other step category.
  static const String other = 'other';

  /// Ordered list of all valid SQL step types.
  static const List<String> values = [
    cleanser,
    toner,
    serum,
    treatment,
    moisturizer,
    spf,
    mask,
    other,
  ];

  /// Human-readable display label for a SQL [stepType].
  static String displayLabel(String stepType) {
    switch (stepType.toLowerCase()) {
      case cleanser:
        return 'Cleanser';
      case toner:
        return 'Toner';
      case serum:
        return 'Serum';
      case treatment:
        return 'Treatment';
      case moisturizer:
        return 'Moisturizer';
      case spf:
        return 'SPF';
      case mask:
        return 'Mask';
      default:
        return 'Other';
    }
  }

  /// Step sequence order number in a standard routine.
  static int defaultOrder(String stepType) {
    switch (stepType.toLowerCase()) {
      case cleanser:
        return 10;
      case toner:
        return 20;
      case serum:
        return 30;
      case treatment:
        return 40;
      case mask:
        return 50;
      case moisturizer:
        return 60;
      case spf:
        return 70;
      default:
        return 80;
    }
  }
}

/// Valid routine application periods matching SQL `('am','pm','both')`.
abstract final class RoutinePeriod {
  /// Morning routine only.
  static const String am = 'am';

  /// Evening routine only.
  static const String pm = 'pm';

  /// Both morning and evening routines.
  static const String both = 'both';

  /// Human-readable label for [period].
  static String displayLabel(String period) {
    switch (period.toLowerCase()) {
      case am:
        return 'Morning (AM)';
      case pm:
        return 'Evening (PM)';
      case both:
      default:
        return 'Morning & Evening';
    }
  }
}

/// Pure domain entity representing a product in a user's skincare routine
/// (`public.routine_items` in Supabase).
class RoutineProduct extends Equatable {
  /// Creates a [RoutineProduct].
  const RoutineProduct({
    required this.id,
    required this.userId,
    required this.name,
    required this.createdAt,
    required this.updatedAt,
    this.brand,
    this.stepType = RoutineStepType.other,
    this.actives = const [],
    this.period = RoutinePeriod.both,
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

  /// Active ingredients (e.g. `['retinol', 'niacinamide']`).
  final List<String> actives;

  /// Routine application period: 'am', 'pm', or 'both'.
  final String period;

  /// ISO weekdays 1..7 (`null` = every day).
  final List<int>? days;

  /// Date started using this product.
  final DateTime? startedOn;

  /// Whether product is currently active in the routine.
  final bool active;

  /// Sorting order index.
  final int sortOrder;

  /// Reference to `public.catalog_products(id)` if linked.
  final String? catalogProductId;

  /// Raw ingredient list text (`ingredients_raw` OCR text).
  final String? ingredientsRaw;

  /// Creation timestamp.
  final DateTime createdAt;

  /// Last updated timestamp.
  final DateTime updatedAt;

  /// Number of days since [startedOn] relative to [referenceDate].
  int daysUsed({DateTime? referenceDate}) {
    if (startedOn == null) return 1;
    final now = referenceDate ?? DateTime.now();
    final diff = now.difference(startedOn!).inDays;
    return diff < 1 ? 1 : diff;
  }

  /// Whether this item applies to the given [targetPeriod] ('am' or 'pm').
  bool appliesToPeriod(String targetPeriod) {
    return period == RoutinePeriod.both || period == targetPeriod;
  }

  /// Returns a copy of this [RoutineProduct] with updated fields.
  RoutineProduct copyWith({
    String? id,
    String? userId,
    String? name,
    String? brand,
    String? stepType,
    List<String>? actives,
    String? period,
    List<int>? days,
    bool clearDays = false,
    DateTime? startedOn,
    bool? active,
    int? sortOrder,
    String? catalogProductId,
    String? ingredientsRaw,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return RoutineProduct(
      id: id ?? this.id,
      userId: userId ?? this.userId,
      name: name ?? this.name,
      brand: brand ?? this.brand,
      stepType: stepType ?? this.stepType,
      actives: actives ?? this.actives,
      period: period ?? this.period,
      days: clearDays ? null : (days ?? this.days),
      startedOn: startedOn ?? this.startedOn,
      active: active ?? this.active,
      sortOrder: sortOrder ?? this.sortOrder,
      catalogProductId: catalogProductId ?? this.catalogProductId,
      ingredientsRaw: ingredientsRaw ?? this.ingredientsRaw,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }

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

/// Pure domain entity representing a daily routine completion checkmark
/// (`public.routine_logs` in Supabase).
class RoutineLogRecord extends Equatable {
  /// Creates a [RoutineLogRecord].
  const RoutineLogRecord({
    required this.id,
    required this.userId,
    required this.itemId,
    required this.logDate,
    required this.createdAt,
    this.period = RoutinePeriod.am,
    this.done = true,
  });

  /// Unique identifier (UUID).
  final String id;

  /// User identifier.
  final String userId;

  /// Routine product identifier (`routine_items.id`).
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
