import 'package:equatable/equatable.dart';

/// Base class for all events dispatched to `ProgressBloc`.
sealed class ProgressEvent extends Equatable {
  /// Creates a [ProgressEvent].
  const ProgressEvent();

  @override
  List<Object?> get props => [];
}

/// Initializes and loads the complete Progress dashboard bundle.
final class ProgressStarted extends ProgressEvent {
  /// Creates a [ProgressStarted] event.
  const ProgressStarted({
    this.userId,
    this.initialSegment,
    this.month,
  });

  /// User ID to load data for.
  final String? userId;

  /// Optional initial segment tab (`0` = Overall, `1` = By concern,
  /// `2` = Calendar).
  final int? initialSegment;

  /// Optional calendar month (`YYYY-MM-01`).
  final DateTime? month;

  @override
  List<Object?> get props => [userId, initialSegment, month];
}

/// Switches the active segment on the Progress dashboard.
final class ProgressSegmentChanged extends ProgressEvent {
  /// Creates a [ProgressSegmentChanged] event.
  const ProgressSegmentChanged(this.segmentIndex);

  /// Selected segment index (`0` = Overall, `1` = By concern, `2` = Calendar).
  final int segmentIndex;

  @override
  List<Object?> get props => [segmentIndex];
}

/// Switches the time range filter (`0` = 4 wks, `1` = 12 wks, `2` = All).
final class ProgressRangeChanged extends ProgressEvent {
  /// Creates a [ProgressRangeChanged] event.
  const ProgressRangeChanged(this.rangeIndex);

  /// Selected range index (`0`, `1`, or `2`).
  final int rangeIndex;

  @override
  List<Object?> get props => [rangeIndex];
}

/// Toggles moving-average smoothing on trajectory charts.
final class ProgressSmoothingToggled extends ProgressEvent {
  /// Creates a [ProgressSmoothingToggled] event.
  const ProgressSmoothingToggled();
}

/// Navigates the calendar month forward or backward.
final class ProgressMonthChanged extends ProgressEvent {
  /// Creates a [ProgressMonthChanged] event.
  const ProgressMonthChanged(this.month);

  /// First day of the target calendar month (`YYYY-MM-01`).
  final DateTime month;

  @override
  List<Object?> get props => [month];
}

/// Selects a specific day number (`1..31`) inside the Calendar view.
final class ProgressCalendarDaySelected extends ProgressEvent {
  /// Creates a [ProgressCalendarDaySelected] event.
  const ProgressCalendarDaySelected(this.dayNumber);

  /// Selected day of the active month (`1..31`).
  final int dayNumber;

  @override
  List<Object?> get props => [dayNumber];
}

/// Updates the pair of scan IDs being compared in `CompareScansPage`.
final class ProgressComparisonScansChanged extends ProgressEvent {
  /// Creates a [ProgressComparisonScansChanged] event.
  const ProgressComparisonScansChanged({
    this.scanAId,
    this.scanBId,
  });

  /// Baseline / earlier scan ID.
  final String? scanAId;

  /// Follow-up / later scan ID.
  final String? scanBId;

  @override
  List<Object?> get props => [scanAId, scanBId];
}
