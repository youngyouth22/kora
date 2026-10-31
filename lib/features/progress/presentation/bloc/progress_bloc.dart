// Encapsulate dependencies as private fields.
// ignore_for_file: prefer_initializing_formals

import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:kora/core/enums/status.dart';
import 'package:kora/features/progress/data/datasources/progress_sql_seed_datasource.dart';
import 'package:kora/features/progress/domain/usecases/progress_usecases.dart';
import 'package:kora/features/progress/presentation/bloc/progress_event.dart';
import 'package:kora/features/progress/presentation/bloc/progress_state.dart';

/// BLoC orchestrating all Progress & Comparison workflows:
/// - Overall trajectory & weekly scan history
/// - 12 YouCam concern progressions (headline + secondary)
/// - Activity calendar (`public.activity_days`), streak freezes, milestones
/// - Side-by-side scan comparison (`CompareScansPage`)
class ProgressBloc extends Bloc<ProgressEvent, ProgressState> {
  /// Creates a [ProgressBloc].
  ProgressBloc({
    required GetProgressDashboardUseCase getDashboard,
    required GetCalendarMonthUseCase getCalendarMonth,
  }) : _getDashboard = getDashboard,
       _getCalendarMonth = getCalendarMonth,
       super(ProgressState.initial()) {
    on<ProgressStarted>(_onStarted);
    on<ProgressSegmentChanged>(_onSegmentChanged);
    on<ProgressRangeChanged>(_onRangeChanged);
    on<ProgressSmoothingToggled>(_onSmoothingToggled);
    on<ProgressMonthChanged>(_onMonthChanged);
    on<ProgressCalendarDaySelected>(_onCalendarDaySelected);
    on<ProgressComparisonScansChanged>(_onComparisonScansChanged);
  }

  final GetProgressDashboardUseCase _getDashboard;
  final GetCalendarMonthUseCase _getCalendarMonth;

  Future<void> _onStarted(
    ProgressStarted event,
    Emitter<ProgressState> emit,
  ) async {
    emit(state.copyWith(status: BaseStatus.loading));

    final userId = event.userId ?? ProgressSqlSeedDataSource.defaultUserId;
    final targetMonth = event.month ?? state.activeMonth;

    final result = await _getDashboard(
      userId: userId,
      month: targetMonth,
    );

    result.fold(
      (failure) => emit(
        state.copyWith(
          status: BaseStatus.failure,
          userId: userId,
          errorMessage: failure.message,
        ),
      ),
      (bundle) {
        final scans = bundle.scans;
        final defaultA = scans.isNotEmpty ? scans.last.id : 'scan_1';
        final defaultB = scans.isNotEmpty ? scans.first.id : 'scan_8';

        emit(
          state.copyWith(
            status: BaseStatus.success,
            userId: userId,
            selectedSegment: event.initialSegment ?? state.selectedSegment,
            activeMonth: DateTime(targetMonth.year, targetMonth.month),
            scans: scans,
            concernTypes: bundle.concernTypes,
            activityDays: bundle.activityDays,
            streakState: bundle.streakState,
            milestones: bundle.milestones,
            experiments: bundle.experiments,
            compareScanAId: defaultA,
            compareScanBId: defaultB,
          ),
        );
      },
    );
  }

  void _onSegmentChanged(
    ProgressSegmentChanged event,
    Emitter<ProgressState> emit,
  ) {
    emit(state.copyWith(selectedSegment: event.segmentIndex.clamp(0, 2)));
  }

  void _onRangeChanged(
    ProgressRangeChanged event,
    Emitter<ProgressState> emit,
  ) {
    emit(state.copyWith(selectedRange: event.rangeIndex.clamp(0, 2)));
  }

  void _onSmoothingToggled(
    ProgressSmoothingToggled event,
    Emitter<ProgressState> emit,
  ) {
    emit(state.copyWith(smoothEnabled: !state.smoothEnabled));
  }

  Future<void> _onMonthChanged(
    ProgressMonthChanged event,
    Emitter<ProgressState> emit,
  ) async {
    final normalizedMonth = DateTime(event.month.year, event.month.month);
    final result = await _getCalendarMonth(
      userId: state.userId,
      month: normalizedMonth,
    );

    result.fold(
      (failure) => emit(
        state.copyWith(
          status: BaseStatus.failure,
          errorMessage: failure.message,
        ),
      ),
      (days) {
        final defaultDay = days.isNotEmpty ? days.last.day.day : 1;
        emit(
          state.copyWith(
            status: BaseStatus.success,
            activeMonth: normalizedMonth,
            activityDays: days,
            selectedCalendarDay: defaultDay,
          ),
        );
      },
    );
  }

  void _onCalendarDaySelected(
    ProgressCalendarDaySelected event,
    Emitter<ProgressState> emit,
  ) {
    emit(state.copyWith(selectedCalendarDay: event.dayNumber));
  }

  void _onComparisonScansChanged(
    ProgressComparisonScansChanged event,
    Emitter<ProgressState> emit,
  ) {
    emit(
      state.copyWith(
        compareScanAId: event.scanAId ?? state.compareScanAId,
        compareScanBId: event.scanBId ?? state.compareScanBId,
      ),
    );
  }
}
