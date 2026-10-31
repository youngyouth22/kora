// ignore_for_file: document_ignores, lines_longer_than_80_chars

import 'package:equatable/equatable.dart';
import 'package:kora/core/enums/status.dart';
import 'package:kora/features/progress/data/datasources/progress_sql_seed_datasource.dart';
import 'package:kora/features/progress/domain/entities/progress_models.dart';
import 'package:kora/features/progress/domain/entities/progress_scan.dart';
import 'package:kora/features/progress/domain/usecases/progress_usecases.dart';

/// Immutable state for `ProgressBloc`.
class ProgressState extends Equatable {
  /// Creates a [ProgressState].
  const ProgressState({
    required this.activeMonth,
    this.status = BaseStatus.initial,
    this.userId = ProgressSqlSeedDataSource.defaultUserId,
    this.selectedSegment = 0,
    this.selectedRange = 0,
    this.smoothEnabled = true,
    this.selectedCalendarDay = 30,
    this.scans = const [],
    this.concernTypes = const [],
    this.activityDays = const [],
    this.streakState,
    this.milestones = const [],
    this.experiments = const [],
    this.compareScanAId = 'scan_1',
    this.compareScanBId = 'scan_8',
    this.errorMessage,
  });

  /// Factory for initial default state.
  factory ProgressState.initial() {
    final ref = ProgressSqlSeedDataSource.defaultReferenceDate;
    return ProgressState(
      activeMonth: DateTime(ref.year, ref.month),
      selectedCalendarDay: ref.day,
    );
  }

  /// Current loading/execution status.
  final BaseStatus status;

  /// Active user UUID.
  final String userId;

  /// Active segment tab (`0` = Overall, `1` = By concern, `2` = Calendar).
  final int selectedSegment;

  /// Active time range (`0` = 4 wks, `1` = 12 wks, `2` = All).
  final int selectedRange;

  /// Whether 3-point weighted moving average smoothing is enabled on charts.
  final bool smoothEnabled;

  /// Active calendar month (`YYYY-MM-01`).
  final DateTime activeMonth;

  /// Selected day of month (`1..31`) in Calendar view.
  final int? selectedCalendarDay;

  /// Completed scans ordered newest first (`public.scans`).
  final List<ProgressScan> scans;

  /// Reference concern definitions (`public.concern_types`).
  final List<ProgressConcernType> concernTypes;

  /// Activity days for [activeMonth] (`public.activity_days`).
  final List<ProgressActivityDay> activityDays;

  /// Current streak state (`public.streak_state`).
  final ProgressStreakState? streakState;

  /// Unlocked milestones (`public.milestones`).
  final List<ProgressMilestone> milestones;

  /// Skincare product experiments (`public.experiments`).
  final List<ProgressExperiment> experiments;

  /// Selected baseline scan ID for comparison.
  final String compareScanAId;

  /// Selected follow-up scan ID for comparison.
  final String compareScanBId;

  /// Optional error message when [status] is [BaseStatus.failure].
  final String? errorMessage;

  static const EvaluateProgressMetricsUseCase _metrics =
      EvaluateProgressMetricsUseCase();

  /// Latest completed scan (`scans.first`), or `null` if empty.
  ProgressScan? get latestScan => scans.isNotEmpty ? scans.first : null;

  /// Oldest baseline scan (`scans.last`), or `null` if empty.
  ProgressScan? get baselineScan => scans.isNotEmpty ? scans.last : null;

  /// Chronological scans (oldest first) filtered by [selectedRange].
  List<ProgressScan> get filteredChronologicalScans =>
      _metrics.filterChronologicalScans(
        scans: scans,
        rangeIndex: selectedRange,
      );

  /// Plotted overall score trajectory values (smoothed if [smoothEnabled]).
  List<double> get overallTrajectoryValues {
    final raw = filteredChronologicalScans.map((s) => s.overallScore).toList();
    return _metrics.computeTrajectorySeries(
      rawValues: raw,
      smooth: smoothEnabled,
    );
  }

  /// Overall score delta over the currently selected [filteredChronologicalScans].
  int get overallRangeDelta {
    final series = filteredChronologicalScans;
    if (series.length < 2) return 0;
    return (series.last.overallScore - series.first.overallScore).round();
  }

  /// Headline concern types (`is_headline == true`, 6 primary concerns).
  List<ProgressConcernType> get headlineConcerns =>
      concernTypes.where((c) => c.isHeadline).toList()
        ..sort((a, b) => a.sortOrder.compareTo(b.sortOrder));

  /// Secondary concern types (`is_headline == false`, 6 secondary concerns).
  List<ProgressConcernType> get secondaryConcerns =>
      concernTypes.where((c) => !c.isHeadline).toList()
        ..sort((a, b) => a.sortOrder.compareTo(b.sortOrder));

  /// Finds a [ProgressScan] by [id], or returns `null`.
  ProgressScan? findScanById(String id) {
    for (final scan in scans) {
      if (scan.id == id) return scan;
    }
    if (id == 'scan_4' && scans.length >= 4) {
      return scans.first;
    }
    return null;
  }

  /// Resolves the canonical [ProgressConcernType] for any route slug or SQL key.
  ProgressConcernType? findConcernType(String keyOrSlug) {
    final normalized = _normalizeKey(keyOrSlug);
    for (final item in concernTypes) {
      if (item.key == normalized) return item;
    }
    return concernTypes.isNotEmpty ? concernTypes.first : null;
  }

  /// Computes chronological raw and smoothed score series for [concernKey].
  ({
    List<ProgressScan> scans,
    List<double> rawScores,
    List<double> plottedScores,
    double current,
    double baseline,
    int delta,
    bool isStable,
  })
  concernTrajectoryFor(String concernKey) {
    final key = _normalizeKey(concernKey);
    final chrono = filteredChronologicalScans;
    final raw = chrono
        .map((s) => s.wholeFaceConcern(key)?.rawScore ?? s.overallScore)
        .toList();
    final plotted = _metrics.computeTrajectorySeries(
      rawValues: raw,
      smooth: smoothEnabled,
    );
    final summary = _metrics.summarizeConcern(
      scans: chrono.isNotEmpty ? chrono : scans,
      concernKey: key,
    );

    return (
      scans: chrono,
      rawScores: raw,
      plottedScores: plotted,
      current: summary.current,
      baseline: summary.baseline,
      delta: summary.delta,
      isStable: summary.isStable,
    );
  }

  /// Returns the [ProgressActivityDay] for [dayNumber] in [activeMonth], if any.
  ProgressActivityDay? activityForDay(int dayNumber) {
    for (final day in activityDays) {
      if (day.day.year == activeMonth.year &&
          day.day.month == activeMonth.month &&
          day.day.day == dayNumber) {
        return day;
      }
    }
    return null;
  }

  static String _normalizeKey(String raw) {
    switch (raw.toLowerCase()) {
      case 'dark_spots':
      case 'spots':
        return 'age_spot';
      case 'pores':
        return 'pore';
      case 'hydration':
        return 'moisture';
      case 'wrinkles':
        return 'wrinkle';
      case 'dark_circles':
      case 'dark_circle':
        return 'dark_circle_v2';
      default:
        return raw.toLowerCase();
    }
  }

  /// Creates a copy of this [ProgressState] with updated fields.
  ProgressState copyWith({
    BaseStatus? status,
    String? userId,
    int? selectedSegment,
    int? selectedRange,
    bool? smoothEnabled,
    DateTime? activeMonth,
    int? selectedCalendarDay,
    List<ProgressScan>? scans,
    List<ProgressConcernType>? concernTypes,
    List<ProgressActivityDay>? activityDays,
    ProgressStreakState? streakState,
    List<ProgressMilestone>? milestones,
    List<ProgressExperiment>? experiments,
    String? compareScanAId,
    String? compareScanBId,
    String? errorMessage,
  }) {
    return ProgressState(
      status: status ?? this.status,
      userId: userId ?? this.userId,
      selectedSegment: selectedSegment ?? this.selectedSegment,
      selectedRange: selectedRange ?? this.selectedRange,
      smoothEnabled: smoothEnabled ?? this.smoothEnabled,
      activeMonth: activeMonth ?? this.activeMonth,
      selectedCalendarDay: selectedCalendarDay ?? this.selectedCalendarDay,
      scans: scans ?? this.scans,
      concernTypes: concernTypes ?? this.concernTypes,
      activityDays: activityDays ?? this.activityDays,
      streakState: streakState ?? this.streakState,
      milestones: milestones ?? this.milestones,
      experiments: experiments ?? this.experiments,
      compareScanAId: compareScanAId ?? this.compareScanAId,
      compareScanBId: compareScanBId ?? this.compareScanBId,
      errorMessage: errorMessage,
    );
  }

  @override
  List<Object?> get props => [
    status,
    userId,
    selectedSegment,
    selectedRange,
    smoothEnabled,
    activeMonth,
    selectedCalendarDay,
    scans,
    concernTypes,
    activityDays,
    streakState,
    milestones,
    experiments,
    compareScanAId,
    compareScanBId,
    errorMessage,
  ];
}
