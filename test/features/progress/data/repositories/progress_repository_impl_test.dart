import 'package:flutter_test/flutter_test.dart';
import 'package:kora/features/progress/data/datasources/progress_sql_seed_datasource.dart';
import 'package:kora/features/progress/data/repositories/progress_repository_impl.dart';
import 'package:kora/features/progress/domain/usecases/progress_usecases.dart';

void main() {
  group('ProgressRepositoryImpl & EvaluateProgressMetricsUseCase', () {
    late ProgressRepositoryImpl repository;
    const metrics = EvaluateProgressMetricsUseCase();

    setUp(() {
      repository = ProgressRepositoryImpl();
    });

    test('returns 8 SQL-aligned weekly scans sorted newest first', () async {
      final result = await repository.getScans(
        userId: ProgressSqlSeedDataSource.defaultUserId,
      );

      expect(result.isRight(), isTrue);
      final scans = result.getOrElse(() => const []);
      expect(scans.length, 8);
      expect(scans.first.id, 'scan_8');
      expect(scans.last.id, 'scan_1');
      expect(
        scans.first.overallScore,
        greaterThan(scans.last.overallScore),
      );
      expect(scans.first.wholeFaceConcern('age_spot')?.rawScore, isNotNull);
      expect(scans.first.regionalConcerns('age_spot'), isNotEmpty);
    });

    test('returns 12 SQL concern_types (6 headline + 6 secondary)', () async {
      final result = await repository.getConcernTypes();
      expect(result.isRight(), isTrue);
      final types = result.getOrElse(() => const []);
      expect(types.length, 12);
      expect(types.where((t) => t.isHeadline).length, 6);
      expect(types.where((t) => !t.isHeadline).length, 6);
    });

    test(
      'returns calendar activity days, streak state, and milestones',
      () async {
        final getDashboard = GetProgressDashboardUseCase(repository);
        final result = await getDashboard(
          userId: ProgressSqlSeedDataSource.defaultUserId,
          month: DateTime(2026, 10),
        );

        expect(result.isRight(), isTrue);
        final bundle = result.getOrElse(() => throw StateError('Unexpected'));
        expect(bundle.activityDays, isNotEmpty);
        expect(bundle.streakState.currentStreak, 14);
        expect(bundle.streakState.weeklyScanStreak, 8);
        expect(bundle.milestones.length, 6);
        expect(bundle.experiments, isNotEmpty);
        expect(
          bundle.experiments.first.primaryVerdict?.verdict,
          'visible_effect',
        );
      },
    );

    test('computes smoothed trajectory and noise threshold accurately', () {
      const raw = [69.0, 71.0, 72.0, 75.0];
      final smoothed = metrics.computeTrajectorySeries(
        rawValues: raw,
        smooth: true,
      );
      expect(smoothed.length, 4);
      expect(metrics.isWithinNoise(1.5), isTrue);
      expect(metrics.isWithinNoise(6.0), isFalse);
    });
  });
}
