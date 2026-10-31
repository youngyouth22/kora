// ignore_for_file: document_ignores, lines_longer_than_80_chars

import 'package:equatable/equatable.dart';

/// Represents a single day's activity record (`public.activity_days` in SQL).
class ProgressActivityDay extends Equatable {
  /// Creates a [ProgressActivityDay].
  const ProgressActivityDay({
    required this.userId,
    required this.day,
    this.actions = 0,
    this.hadScan = false,
    this.hadRoutine = false,
    this.hadTask = false,
    this.hadCheckin = false,
    this.isFreeze = false,
    this.scanId,
    this.scanScore,
    this.summaryNote,
  });

  /// User UUID (`activity_days.user_id`).
  final String userId;

  /// Local calendar date (`activity_days.day`).
  final DateTime day;

  /// Total qualifying actions completed on [day] (`activity_days.actions`).
  final int actions;

  /// Whether a weekly scan was completed (`activity_days.had_scan`).
  final bool hadScan;

  /// Whether AM/PM routine steps were logged (`activity_days.had_routine`).
  final bool hadRoutine;

  /// Whether a daily plan task was completed (`activity_days.had_task`).
  final bool hadTask;

  /// Whether a daily skin feel check-in was logged
  /// (`activity_days.had_checkin`).
  final bool hadCheckin;

  /// Whether this day was protected by a streak freeze
  /// (`activity_days.is_freeze`).
  final bool isFreeze;

  /// Associated scan ID if [hadScan] is true.
  final String? scanId;

  /// Associated scan overall score if [hadScan] is true.
  final double? scanScore;

  /// Human-readable summary of the day's logs.
  final String? summaryNote;

  @override
  List<Object?> get props => [
    userId,
    day,
    actions,
    hadScan,
    hadRoutine,
    hadTask,
    hadCheckin,
    isFreeze,
    scanId,
    scanScore,
    summaryNote,
  ];
}

/// Represents the user's current and historical streak status
/// (`public.streak_state` in SQL).
class ProgressStreakState extends Equatable {
  /// Creates a [ProgressStreakState].
  const ProgressStreakState({
    required this.userId,
    required this.currentStreak,
    required this.longestStreak,
    required this.freezesAvailable,
    required this.freezesUsedTotal,
    required this.weeklyScanStreak,
    required this.longestWeeklyScanStreak,
    required this.weeklyJokerAvailable,
    this.lastActiveDate,
    this.lastScanWeek,
  });

  /// User UUID (`streak_state.user_id`).
  final String userId;

  /// Current consecutive daily streak (`streak_state.current_streak`).
  final int currentStreak;

  /// All-time longest daily streak (`streak_state.longest_streak`).
  final int longestStreak;

  /// Last active local date (`streak_state.last_active_date`).
  final DateTime? lastActiveDate;

  /// Banked streak freezes (`streak_state.freezes_available`, max 2).
  final int freezesAvailable;

  /// Total freezes used (`streak_state.freezes_used_total`).
  final int freezesUsedTotal;

  /// Consecutive weeks with at least 1 scan
  /// (`streak_state.weekly_scan_streak`).
  final int weeklyScanStreak;

  /// Longest weekly scan streak (`streak_state.longest_weekly_scan_streak`).
  final int longestWeeklyScanStreak;

  /// Monday of the last week with a scan (`streak_state.last_scan_week`).
  final DateTime? lastScanWeek;

  /// Whether the monthly weekly-scan joker is available
  /// (`streak_state.weekly_joker_available`).
  final bool weeklyJokerAvailable;

  @override
  List<Object?> get props => [
    userId,
    currentStreak,
    longestStreak,
    lastActiveDate,
    freezesAvailable,
    freezesUsedTotal,
    weeklyScanStreak,
    longestWeeklyScanStreak,
    lastScanWeek,
    weeklyJokerAvailable,
  ];
}

/// Represents an unlocked user achievement (`public.milestones` in SQL).
class ProgressMilestone extends Equatable {
  /// Creates a [ProgressMilestone].
  const ProgressMilestone({
    required this.userId,
    required this.type,
    required this.title,
    required this.subtitle,
    required this.reachedAt,
    this.seenAt,
    this.meta = const {},
  });

  /// User UUID (`milestones.user_id`).
  final String userId;

  /// Milestone key (`'first_scan'`, `'second_scan'`, `'streak_7'`,
  /// `'streak_14'`, `'streak_30'`, `'weekly_streak_4'`, `'first_verdict'`).
  final String type;

  /// Display title of the milestone.
  final String title;

  /// Concise description of how it was unlocked.
  final String subtitle;

  /// Timestamp when unlocked (`milestones.reached_at`).
  final DateTime reachedAt;

  /// Timestamp when acknowledged (`milestones.seen_at` from migration 3).
  final DateTime? seenAt;

  /// Metadata payload (`milestones.meta`).
  final Map<String, dynamic> meta;

  @override
  List<Object?> get props => [
    userId,
    type,
    title,
    subtitle,
    reachedAt,
    seenAt,
    meta,
  ];
}

/// Represents the per-target verdict computation inside an experiment
/// (`compute_experiment_verdict` in SQL).
class ProgressVerdictTarget extends Equatable {
  /// Creates a [ProgressVerdictTarget].
  const ProgressVerdictTarget({
    required this.concernKey,
    required this.concernLabel,
    required this.baseline,
    required this.post,
    required this.delta,
    required this.noise,
    required this.verdict,
    required this.confidence,
    required this.scansAfter,
    required this.adherence,
    required this.qualityRatio,
  });

  /// Target concern key (`'age_spot'`, `'redness'`, etc.).
  final String concernKey;

  /// Target concern display label.
  final String concernLabel;

  /// Average baseline raw score from `experiment_scans` where `role='baseline'`.
  final double baseline;

  /// Average follow-up raw score in the last 21 days of the experiment.
  final double post;

  /// Signed score delta (`post - baseline`).
  final double delta;

  /// Configured noise threshold (`app_config.noise_by_concern`, default `3.0`).
  final double noise;

  /// Computed verdict code:
  /// `'visible_effect'`, `'slight_effect'`, `'no_clear_signal'`,
  /// `'slight_decline'`, `'possible_irritation'`, or `'not_enough_data'`.
  final String verdict;

  /// Confidence level (`'high'`, `'medium'`, or `'low'`).
  final String confidence;

  /// Number of completed scans after `started_at`.
  final int scansAfter;

  /// Routine adherence ratio (`0.0` to `1.0`).
  final double adherence;

  /// Quality-OK scan ratio (`0.0` to `1.0`).
  final double qualityRatio;

  @override
  List<Object?> get props => [
    concernKey,
    concernLabel,
    baseline,
    post,
    delta,
    noise,
    verdict,
    confidence,
    scansAfter,
    adherence,
    qualityRatio,
  ];
}

/// Represents a controlled skincare product experiment (`public.experiments`).
class ProgressExperiment extends Equatable {
  /// Creates a [ProgressExperiment].
  const ProgressExperiment({
    required this.id,
    required this.userId,
    required this.title,
    required this.targets,
    required this.plannedDays,
    required this.startedAt,
    required this.startedOn,
    required this.status,
    required this.adherence,
    this.itemId,
    this.brand,
    this.endedAt,
    this.verdictTargets = const [],
    this.baselineScanIds = const [],
    this.followupScanIds = const [],
    this.notes = const [],
  });

  /// Experiment UUID (`experiments.id`).
  final String id;

  /// User UUID (`experiments.user_id`).
  final String userId;

  /// Linked routine product UUID (`experiments.item_id`).
  final String? itemId;

  /// Product name snapshot (`experiments.title`).
  final String title;

  /// Optional brand label.
  final String? brand;

  /// 1 to 2 target concern keys (`experiments.targets`).
  final List<String> targets;

  /// Planned duration in days (`14` to `180`, default `42`).
  final int plannedDays;

  /// Start timestamp (`experiments.started_at`).
  final DateTime startedAt;

  /// Start local date (`experiments.started_on`).
  final DateTime startedOn;

  /// End timestamp (`experiments.ended_at`).
  final DateTime? endedAt;

  /// Lifecycle status (`'active'`, `'paused'`, `'completed'`, `'stopped'`).
  final String status;

  /// Adherence ratio (`0.0` to `1.0`, `experiments.adherence`).
  final double adherence;

  /// Computed target outcomes (`experiments.verdict -> 'targets'`).
  final List<ProgressVerdictTarget> verdictTargets;

  /// Linked baseline scan IDs (`experiment_scans.role = 'baseline'`).
  final List<String> baselineScanIds;

  /// Linked follow-up scan IDs (`experiment_scans.role = 'followup'`).
  final List<String> followupScanIds;

  /// User notes (`public.notes`).
  final List<String> notes;

  /// Primary target verdict (`verdict -> 'primary'`).
  ProgressVerdictTarget? get primaryVerdict =>
      verdictTargets.isNotEmpty ? verdictTargets.first : null;

  /// Elapsed days in the experiment relative to [referenceDate].
  int elapsedDays([DateTime? referenceDate]) {
    final end = endedAt ?? referenceDate ?? DateTime.now();
    final diff = end.difference(startedOn).inDays + 1;
    return diff.clamp(1, plannedDays);
  }

  @override
  List<Object?> get props => [
    id,
    userId,
    itemId,
    title,
    brand,
    targets,
    plannedDays,
    startedAt,
    startedOn,
    endedAt,
    status,
    adherence,
    verdictTargets,
    baselineScanIds,
    followupScanIds,
    notes,
  ];
}
