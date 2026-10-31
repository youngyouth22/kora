import 'package:kora/features/routine/domain/entities/routine_compatibility_notice.dart';
import 'package:kora/features/routine/domain/entities/routine_product.dart';

/// Pure domain usecase that evaluates active ingredient compatibility and
/// weekly adherence metrics without any UI or framework dependencies.
class EvaluateRoutineInsightsUseCase {
  /// Creates an [EvaluateRoutineInsightsUseCase].
  const EvaluateRoutineInsightsUseCase();

  /// Evaluates potential active ingredient interactions for [items] in
  /// [period] ('am' or 'pm').
  List<RoutineCompatibilityNotice> evaluateCompatibility({
    required List<RoutineProduct> items,
    required String period,
  }) {
    final periodItems = items
        .where((item) => item.active && item.appliesToPeriod(period))
        .toList();

    final allActives = <String>{};
    for (final item in periodItems) {
      for (final active in item.actives) {
        allActives.add(active.toLowerCase());
      }
    }

    final notices = <RoutineCompatibilityNotice>[];

    final hasRetinoid = allActives.any(
      (a) =>
          a.contains('retinol') ||
          a.contains('retinoid') ||
          a.contains('adapalene') ||
          a.contains('tretinoin'),
    );
    final hasExfoliantAcid = allActives.any(
      (a) =>
          a.contains('glycolic') ||
          a.contains('salicylic') ||
          a.contains('lactic') ||
          a.contains('aha') ||
          a.contains('bha'),
    );
    final hasVitaminC = allActives.any(
      (a) =>
          a.contains('ascorbic') ||
          a.contains('vitamin c') ||
          a.contains('vit c'),
    );
    final hasSpf = periodItems.any(
      (item) => item.stepType == RoutineStepType.spf,
    );

    if (hasRetinoid && hasExfoliantAcid) {
      notices.add(
        const RoutineCompatibilityNotice(
          title: 'Active layering caution',
          message:
              'Avoid layering AHA/BHA exfoliants and Retinoids on the same '
              'evening. Alternate nights to protect your skin barrier.',
          involvedActives: ['Retinol', 'AHA/BHA'],
          severity: CompatibilitySeverity.caution,
        ),
      );
    } else if (period == RoutinePeriod.pm && hasRetinoid) {
      notices.add(
        const RoutineCompatibilityNotice(
          title: 'Retinoid protocol active',
          message:
              'Apply on dry skin and seal with your ceramide moisturizer. '
              'Avoid combining with direct acids on the same evening.',
          involvedActives: ['Retinol'],
        ),
      );
    }

    if (period == RoutinePeriod.am && hasVitaminC && hasSpf) {
      notices.add(
        const RoutineCompatibilityNotice(
          title: 'Antioxidant + UV synergy',
          message:
              'Vitamin C paired under broad-spectrum SPF 50 boosts '
              'photoprotection against dark spots.',
          involvedActives: ['L-Ascorbic Acid', 'Zinc Oxide'],
        ),
      );
    } else if (period == RoutinePeriod.am &&
        !hasSpf &&
        periodItems.isNotEmpty) {
      notices.add(
        const RoutineCompatibilityNotice(
          title: 'Missing morning UV protection',
          message:
              'Adding a daily SPF 30+ step locks in active treatment gains '
              'and prevents UV-induced pigmentation.',
          involvedActives: ['SPF'],
          severity: CompatibilitySeverity.caution,
        ),
      );
    }

    return notices;
  }

  /// Computes the number of completed steps vs total scheduled steps for
  /// [period] ('am' or 'pm') on a given day.
  ({int completed, int total, double ratio}) computePeriodProgress({
    required List<RoutineProduct> items,
    required List<RoutineLogRecord> logsForDate,
    required String period,
  }) {
    final periodItems = items
        .where((item) => item.active && item.appliesToPeriod(period))
        .toList();
    if (periodItems.isEmpty) {
      return (completed: 0, total: 0, ratio: 0.0);
    }

    final doneItemIds = logsForDate
        .where((log) => log.period == period && log.done)
        .map((log) => log.itemId)
        .toSet();

    var completedCount = 0;
    for (final item in periodItems) {
      if (doneItemIds.contains(item.id)) {
        completedCount++;
      }
    }

    return (
      completed: completedCount,
      total: periodItems.length,
      ratio: completedCount / periodItems.length,
    );
  }
}
