import 'package:equatable/equatable.dart';

/// Pure domain entity representing the consolidated home dashboard data.
class HomeDashboardData extends Equatable {
  /// Creates a [HomeDashboardData].
  const HomeDashboardData({
    required this.userName,
    required this.currentStreak,
    required this.longestStreak,
    required this.weeklyScanStreak,
    required this.streakDaysCompleted,
    required this.daysUntilNextScan,
    required this.isScanDueToday,
    required this.hasBaselineScan,
    required this.nextScanDateLabel,
    required this.morningRoutineDone,
    required this.eveningRoutineDone,
    required this.skinCheckinDone,
    required this.dailyTipRead,
    this.activeExperimentTitle,
    this.activeExperimentId,
    this.activeExperimentDay,
    this.activeExperimentTotalDays,
    this.activeExperimentTargets,
    this.activeExperimentAdherence,
    this.overallScore,
    this.scoreDelta,
    this.scoreSubtitle,
  });

  /// User display name for the header greeting.
  final String userName;

  /// Current consecutive days streak.
  final int currentStreak;

  /// Longest historical days streak.
  final int longestStreak;

  /// Consecutive weekly scan streak.
  final int weeklyScanStreak;

  /// Boolean list representing Monday..Sunday completion for the current week.
  final List<bool> streakDaysCompleted;

  /// Days remaining until the next recommended weekly scan (0..7).
  final int daysUntilNextScan;

  /// Whether the weekly scan is recommended today.
  final bool isScanDueToday;

  /// Whether the user has at least one calibrated baseline scan.
  final bool hasBaselineScan;

  /// Human-readable target scan timing (e.g. 'Sunday at 6 PM').
  final String nextScanDateLabel;

  /// Whether morning routine was completed today.
  final bool morningRoutineDone;

  /// Whether evening routine was completed today.
  final bool eveningRoutineDone;

  /// Whether daily skin feel check-in was logged today.
  final bool skinCheckinDone;

  /// Whether today's skin tip was marked as read.
  final bool dailyTipRead;

  /// Title of the active product experiment, if any.
  final String? activeExperimentTitle;

  /// Unique ID of the active product experiment.
  final String? activeExperimentId;

  /// Elapsed days in the active experiment.
  final int? activeExperimentDay;

  /// Total planned days in the active experiment.
  final int? activeExperimentTotalDays;

  /// Target concerns formatted label for the experiment.
  final String? activeExperimentTargets;

  /// Adherence ratio (0.0 to 1.0) for the active experiment.
  final double? activeExperimentAdherence;

  /// Latest overall skin health score (0..100).
  final int? overallScore;

  /// Signed delta compared to the previous scan.
  final int? scoreDelta;

  /// Brief explanatory subtitle for the trajectory score.
  final String? scoreSubtitle;

  /// Total number of completed daily plan tasks (0..4).
  int get completedDailyTasks {
    var count = 0;
    if (morningRoutineDone) count++;
    if (eveningRoutineDone) count++;
    if (skinCheckinDone) count++;
    if (dailyTipRead) count++;
    return count;
  }

  @override
  List<Object?> get props => [
    userName,
    currentStreak,
    longestStreak,
    weeklyScanStreak,
    streakDaysCompleted,
    daysUntilNextScan,
    isScanDueToday,
    hasBaselineScan,
    nextScanDateLabel,
    morningRoutineDone,
    eveningRoutineDone,
    skinCheckinDone,
    dailyTipRead,
    activeExperimentTitle,
    activeExperimentId,
    activeExperimentDay,
    activeExperimentTotalDays,
    activeExperimentTargets,
    activeExperimentAdherence,
    overallScore,
    scoreDelta,
    scoreSubtitle,
  ];
}
