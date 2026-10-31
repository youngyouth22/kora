import 'package:flutter_test/flutter_test.dart';
import 'package:kora/features/routine/domain/entities/routine_compatibility_notice.dart';
import 'package:kora/features/routine/domain/entities/routine_product.dart';
import 'package:kora/features/routine/domain/usecases/evaluate_routine_insights_usecase.dart';

void main() {
  const useCase = EvaluateRoutineInsightsUseCase();
  final now = DateTime(2026, 10, 30);

  group('EvaluateRoutineInsightsUseCase', () {
    test(
      'detects caution when retinol and exfoliant acid are layered in PM',
      () {
        final items = [
          RoutineProduct(
            id: 'p1',
            userId: 'u1',
            name: 'Retinol 0.3%',
            stepType: RoutineStepType.treatment,
            period: RoutinePeriod.pm,
            actives: const ['Retinol 0.3%'],
            createdAt: now,
            updatedAt: now,
          ),
          RoutineProduct(
            id: 'p2',
            userId: 'u1',
            name: 'BHA 2% Liquid',
            stepType: RoutineStepType.toner,
            period: RoutinePeriod.pm,
            actives: const ['Salicylic Acid 2%'],
            createdAt: now,
            updatedAt: now,
          ),
        ];

        final notices = useCase.evaluateCompatibility(
          items: items,
          period: RoutinePeriod.pm,
        );

        expect(notices, isNotEmpty);
        expect(notices.first.severity, CompatibilitySeverity.caution);
        expect(notices.first.title, contains('Active layering caution'));
      },
    );

    test('detects Vitamin C + SPF synergy in AM and missing SPF caution', () {
      final itemsWithSpf = [
        RoutineProduct(
          id: 'p1',
          userId: 'u1',
          name: 'C-Glow 15%',
          stepType: RoutineStepType.serum,
          period: RoutinePeriod.am,
          actives: const ['L-Ascorbic Acid'],
          createdAt: now,
          updatedAt: now,
        ),
        RoutineProduct(
          id: 'p2',
          userId: 'u1',
          name: 'Mineral SPF 50',
          stepType: RoutineStepType.spf,
          period: RoutinePeriod.am,
          actives: const ['Zinc Oxide'],
          createdAt: now,
          updatedAt: now,
        ),
      ];

      final synergy = useCase.evaluateCompatibility(
        items: itemsWithSpf,
        period: RoutinePeriod.am,
      );
      expect(synergy, isNotEmpty);
      expect(synergy.first.severity, CompatibilitySeverity.advisory);
      expect(synergy.first.title, contains('Antioxidant + UV synergy'));

      final itemsWithoutSpf = [itemsWithSpf.first];
      final missingSpf = useCase.evaluateCompatibility(
        items: itemsWithoutSpf,
        period: RoutinePeriod.am,
      );
      expect(missingSpf, isNotEmpty);
      expect(missingSpf.first.severity, CompatibilitySeverity.caution);
      expect(missingSpf.first.title, contains('Missing morning UV protection'));
    });

    test('computes period completion progress accurately', () {
      final items = [
        RoutineProduct(
          id: 'p1',
          userId: 'u1',
          name: 'Cleanser',
          stepType: RoutineStepType.cleanser,
          createdAt: now,
          updatedAt: now,
        ),
        RoutineProduct(
          id: 'p2',
          userId: 'u1',
          name: 'SPF 50',
          stepType: RoutineStepType.spf,
          period: RoutinePeriod.am,
          createdAt: now,
          updatedAt: now,
        ),
      ];
      final logs = [
        RoutineLogRecord(
          id: 'l1',
          userId: 'u1',
          itemId: 'p1',
          logDate: '2026-10-30',
          createdAt: now,
        ),
      ];

      final progress = useCase.computePeriodProgress(
        items: items,
        logsForDate: logs,
        period: RoutinePeriod.am,
      );

      expect(progress.completed, 1);
      expect(progress.total, 2);
      expect(progress.ratio, 0.5);
    });
  });
}
