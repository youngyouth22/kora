import 'package:equatable/equatable.dart';
import 'package:kora/core/enums/status.dart';
import 'package:kora/features/routine/domain/entities/catalog_product.dart';
import 'package:kora/features/routine/domain/entities/routine_compatibility_notice.dart';
import 'package:kora/features/routine/domain/entities/routine_product.dart';
import 'package:kora/features/routine/domain/entities/skin_checkin.dart';

/// Immutable state for `RoutineBloc`.
class RoutineState extends Equatable {
  /// Creates a [RoutineState].
  const RoutineState({
    this.status = BaseStatus.initial,
    this.userId = 'demo-user-amina',
    this.selectedPeriod = RoutinePeriod.am,
    this.currentDate = '',
    this.products = const [],
    this.logsForDate = const [],
    this.catalogProducts = const [],
    this.selectedCatalogCategory = 'all',
    this.catalogQuery = '',
    this.todayCheckin,
    this.compatibilityNotices = const [],
    this.weeklyAdherenceDays = 6,
    this.experimentProductId = 'item-ordinary-retinol',
    this.errorMessage,
  });

  /// Current loading/execution status.
  final BaseStatus status;

  /// Active user ID.
  final String userId;

  /// Selected routine period tab (`'am'` or `'pm'`).
  final String selectedPeriod;

  /// Current ISO date (`YYYY-MM-DD`).
  final String currentDate;

  /// All routine products for the user.
  final List<RoutineProduct> products;

  /// Today's completion logs (`public.routine_logs`).
  final List<RoutineLogRecord> logsForDate;

  /// Curated catalog products (`public.catalog_products`).
  final List<CatalogProduct> catalogProducts;

  /// Active category filter in the catalog browser.
  final String selectedCatalogCategory;

  /// Active search query in the catalog browser.
  final String catalogQuery;

  /// Today's skin check-in (`public.checkins`), if completed.
  final SkinCheckin? todayCheckin;

  /// Computed active ingredient compatibility notices for [selectedPeriod].
  final List<RoutineCompatibilityNotice> compatibilityNotices;

  /// Number of adherent days in the rolling 7-day window.
  final int weeklyAdherenceDays;

  /// Routine item ID currently linked to an active experiment
  /// (`experiments.item_id`).
  final String? experimentProductId;

  /// Optional error message when [status] is [BaseStatus.failure].
  final String? errorMessage;

  /// Filtered list of active products for [selectedPeriod], sorted by
  /// `sortOrder`.
  List<RoutineProduct> get activePeriodProducts {
    final filtered =
        products
            .where((p) => p.active && p.appliesToPeriod(selectedPeriod))
            .toList()
          ..sort((a, b) => a.sortOrder.compareTo(b.sortOrder));
    return filtered;
  }

  /// Morning routine products count & completion.
  ({int completed, int total}) get amSummary => _summaryFor(RoutinePeriod.am);

  /// Evening routine products count & completion.
  ({int completed, int total}) get pmSummary => _summaryFor(RoutinePeriod.pm);

  ({int completed, int total}) _summaryFor(String period) {
    final periodItems = products
        .where((p) => p.active && p.appliesToPeriod(period))
        .toList();
    final doneIds = logsForDate
        .where((l) => l.period == period && l.done)
        .map((l) => l.itemId)
        .toSet();
    final doneCount = periodItems.where((p) => doneIds.contains(p.id)).length;
    return (completed: doneCount, total: periodItems.length);
  }

  /// Checks whether [itemId] is marked done for [period]
  /// (defaults to [selectedPeriod]).
  bool isStepDone(String itemId, {String? period}) {
    final targetPeriod = period ?? selectedPeriod;
    return logsForDate.any(
      (log) => log.itemId == itemId && log.period == targetPeriod && log.done,
    );
  }

  /// Finds a [RoutineProduct] by its [id], or `null` if not found.
  RoutineProduct? findProductById(String id) {
    for (final product in products) {
      if (product.id == id) return product;
    }
    return null;
  }

  /// Finds a [CatalogProduct] by its `id` or `slug`, or `null` if not found.
  CatalogProduct? findCatalogProduct(String idOrSlug) {
    for (final item in catalogProducts) {
      if (item.id == idOrSlug || item.slug == idOrSlug) return item;
    }
    return null;
  }

  /// Creates a copy of this [RoutineState] with updated fields.
  RoutineState copyWith({
    BaseStatus? status,
    String? userId,
    String? selectedPeriod,
    String? currentDate,
    List<RoutineProduct>? products,
    List<RoutineLogRecord>? logsForDate,
    List<CatalogProduct>? catalogProducts,
    String? selectedCatalogCategory,
    String? catalogQuery,
    SkinCheckin? todayCheckin,
    List<RoutineCompatibilityNotice>? compatibilityNotices,
    int? weeklyAdherenceDays,
    String? experimentProductId,
    String? errorMessage,
  }) {
    return RoutineState(
      status: status ?? this.status,
      userId: userId ?? this.userId,
      selectedPeriod: selectedPeriod ?? this.selectedPeriod,
      currentDate: currentDate ?? this.currentDate,
      products: products ?? this.products,
      logsForDate: logsForDate ?? this.logsForDate,
      catalogProducts: catalogProducts ?? this.catalogProducts,
      selectedCatalogCategory:
          selectedCatalogCategory ?? this.selectedCatalogCategory,
      catalogQuery: catalogQuery ?? this.catalogQuery,
      todayCheckin: todayCheckin ?? this.todayCheckin,
      compatibilityNotices: compatibilityNotices ?? this.compatibilityNotices,
      weeklyAdherenceDays: weeklyAdherenceDays ?? this.weeklyAdherenceDays,
      experimentProductId: experimentProductId ?? this.experimentProductId,
      errorMessage: errorMessage,
    );
  }

  @override
  List<Object?> get props => [
    status,
    userId,
    selectedPeriod,
    currentDate,
    products,
    logsForDate,
    catalogProducts,
    selectedCatalogCategory,
    catalogQuery,
    todayCheckin,
    compatibilityNotices,
    weeklyAdherenceDays,
    experimentProductId,
    errorMessage,
  ];
}
