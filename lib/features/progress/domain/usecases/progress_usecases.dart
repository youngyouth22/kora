import 'package:dartz/dartz.dart';
import 'package:equatable/equatable.dart';
import 'package:kora/core/error/failures.dart';
import 'package:kora/features/progress/domain/entities/progress_models.dart';
import 'package:kora/features/progress/domain/entities/progress_scan.dart';
import 'package:kora/features/progress/domain/repositories/progress_repository.dart';

/// Aggregated payload for the Progress & Comparison shell tab.
class ProgressDashboardBundle extends Equatable {
  /// Creates a [ProgressDashboardBundle].
  const ProgressDashboardBundle({
    required this.scans,
    required this.concernTypes,
    required this.activityDays,
    required this.streakState,
    required this.milestones,
    required this.experiments,
  });

  /// Completed scans sorted newest first.
  final List<ProgressScan> scans;

  /// Reference concern definitions (`public.concern_types`).
  final List<ProgressConcernType> concernTypes;

  /// Activity days for the selected calendar month (`public.activity_days`).
  final List<ProgressActivityDay> activityDays;

  /// Current streak state (`public.streak_state`).
  final ProgressStreakState streakState;

  /// Unlocked milestones (`public.milestones`).
  final List<ProgressMilestone> milestones;

  /// Active and completed product experiments (`public.experiments`).
  final List<ProgressExperiment> experiments;

  @override
  List<Object?> get props => [
    scans,
    concernTypes,
    activityDays,
    streakState,
    milestones,
    experiments,
  ];
}

/// Usecase to load the complete Progress dashboard bundle.
class GetProgressDashboardUseCase {
  /// Creates a [GetProgressDashboardUseCase].
  const GetProgressDashboardUseCase(this._repository);

  final ProgressRepository _repository;

  /// Executes the usecase for [userId] and [month].
  Future<Either<Failure, ProgressDashboardBundle>> call({
    required String userId,
    required DateTime month,
  }) async {
    final scansResult = await _repository.getScans(userId: userId);
    final concernsResult = await _repository.getConcernTypes();
    final calendarResult = await _repository.getCalendarMonth(
      userId: userId,
      month: month,
    );
    final streakResult = await _repository.getStreakState(userId: userId);
    final milestonesResult = await _repository.getMilestones(userId: userId);
    final experimentsResult = await _repository.getExperiments(userId: userId);

    return scansResult.fold(
      Left.new,
      (scans) {
        final concernTypes = concernsResult.getOrElse(() => const []);
        final activityDays = calendarResult.getOrElse(() => const []);
        final streak = streakResult.getOrElse(
          () => ProgressStreakState(
            userId: userId,
            currentStreak: 0,
            longestStreak: 0,
            freezesAvailable: 1,
            freezesUsedTotal: 0,
            weeklyScanStreak: 0,
            longestWeeklyScanStreak: 0,
            weeklyJokerAvailable: true,
          ),
        );
        final milestones = milestonesResult.getOrElse(() => const []);
        final experiments = experimentsResult.getOrElse(() => const []);

        return Right(
          ProgressDashboardBundle(
            scans: scans,
            concernTypes: concernTypes,
            activityDays: activityDays,
            streakState: streak,
            milestones: milestones,
            experiments: experiments,
          ),
        );
      },
    );
  }
}

/// Usecase to load calendar activity days for a specific month.
class GetCalendarMonthUseCase {
  /// Creates a [GetCalendarMonthUseCase].
  const GetCalendarMonthUseCase(this._repository);

  final ProgressRepository _repository;

  /// Executes the usecase.
  Future<Either<Failure, List<ProgressActivityDay>>> call({
    required String userId,
    required DateTime month,
  }) {
    return _repository.getCalendarMonth(userId: userId, month: month);
  }
}

/// Pure, testable statistical and trend computation service for Kora Progress.
///
/// Mirrors `app_config.noise_by_concern` (`default: 3`) and
/// `compute_experiment_verdict()` in `20261012000000_skinproof_init.sql`.
class EvaluateProgressMetricsUseCase {
  /// Creates an [EvaluateProgressMetricsUseCase].
  const EvaluateProgressMetricsUseCase();

  /// Default noise threshold in points (`app_config.noise_by_concern`).
  static const double defaultNoiseThreshold = 3;

  /// Filters [scans] (expected newest-first or any order) to the requested
  /// time range (`0` = 4 weeks, `1` = 12 weeks, `2` = All) and returns them
  /// in chronological order (oldest first) for chart plotting.
  List<ProgressScan> filterChronologicalScans({
    required List<ProgressScan> scans,
    required int rangeIndex,
    DateTime? referenceDate,
  }) {
    if (scans.isEmpty) return const [];
    final sorted = List<ProgressScan>.from(scans)
      ..sort((a, b) => a.createdAt.compareTo(b.createdAt));

    if (rangeIndex == 0) {
      // Last 4 weeks (~5 weekly scans max)
      final count = sorted.length > 5 ? 5 : sorted.length;
      return sorted.sublist(sorted.length - count);
    }
    if (rangeIndex == 1) {
      // Last 12 weeks (~12 weekly scans max)
      final count = sorted.length > 12 ? 12 : sorted.length;
      return sorted.sublist(sorted.length - count);
    }
    return sorted;
  }

  /// Applies a 3-point weighted moving average (`0.25, 0.50, 0.25` interior;
  /// `0.6, 0.4` endpoints) when [smooth] is enabled to filter out single-day
  /// lighting noise while preserving baseline and final trajectories.
  List<double> computeTrajectorySeries({
    required List<double> rawValues,
    required bool smooth,
  }) {
    if (!smooth || rawValues.length < 3) {
      return List<double>.from(rawValues);
    }
    final result = <double>[];
    for (var i = 0; i < rawValues.length; i++) {
      if (i == 0) {
        final v = rawValues[0] * 0.7 + rawValues[1] * 0.3;
        result.add(double.parse(v.toStringAsFixed(1)));
      } else if (i == rawValues.length - 1) {
        final v = rawValues[i - 1] * 0.3 + rawValues[i] * 0.7;
        result.add(double.parse(v.toStringAsFixed(1)));
      } else {
        final v =
            rawValues[i - 1] * 0.25 +
            rawValues[i] * 0.50 +
            rawValues[i + 1] * 0.25;
        result.add(double.parse(v.toStringAsFixed(1)));
      }
    }
    return result;
  }

  /// Evaluates whether a score change [delta] is within the noise threshold
  /// (`abs(delta) < noise`).
  bool isWithinNoise(
    num delta, {
    double noise = defaultNoiseThreshold,
  }) {
    return delta.abs() < noise;
  }

  /// Computes the latest score, baseline score, and signed delta for a specific
  /// [concernKey] across [scans].
  ({double current, double baseline, int delta, bool isStable})
  summarizeConcern({
    required List<ProgressScan> scans,
    required String concernKey,
    double noise = defaultNoiseThreshold,
  }) {
    if (scans.isEmpty) {
      return (current: 0, baseline: 0, delta: 0, isStable: true);
    }
    final chronological = List<ProgressScan>.from(scans)
      ..sort((a, b) => a.createdAt.compareTo(b.createdAt));

    final firstScore =
        chronological.first.wholeFaceConcern(concernKey)?.rawScore ?? 0;
    final lastScore =
        chronological.last.wholeFaceConcern(concernKey)?.rawScore ?? firstScore;
    final rawDelta = lastScore - firstScore;
    final roundedDelta = rawDelta.round();
    final stable = isWithinNoise(rawDelta, noise: noise);

    return (
      current: lastScore,
      baseline: firstScore,
      delta: roundedDelta,
      isStable: stable,
    );
  }
}
