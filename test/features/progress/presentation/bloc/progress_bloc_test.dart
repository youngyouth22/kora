import 'dart:async';

import 'package:flutter_test/flutter_test.dart';
import 'package:kora/core/enums/status.dart';
import 'package:kora/features/progress/data/repositories/progress_repository_impl.dart';
import 'package:kora/features/progress/domain/usecases/progress_usecases.dart';
import 'package:kora/features/progress/presentation/bloc/progress_bloc.dart';
import 'package:kora/features/progress/presentation/bloc/progress_event.dart';
import 'package:kora/features/progress/presentation/bloc/progress_state.dart';

void main() {
  group('ProgressBloc', () {
    late ProgressRepositoryImpl repository;
    late GetProgressDashboardUseCase getDashboard;
    late GetCalendarMonthUseCase getCalendarMonth;
    late ProgressBloc bloc;

    setUp(() {
      repository = ProgressRepositoryImpl();
      getDashboard = GetProgressDashboardUseCase(repository);
      getCalendarMonth = GetCalendarMonthUseCase(repository);
      bloc = ProgressBloc(
        getDashboard: getDashboard,
        getCalendarMonth: getCalendarMonth,
      );
    });

    tearDown(() async {
      await bloc.close();
    });

    test(
      'emits [loading, success] with 8 scans and 12 concerns '
      'on ProgressStarted',
      () async {
        unawaited(
          expectLater(
            bloc.stream,
            emitsInOrder([
              isA<ProgressState>().having(
                (s) => s.status,
                'status',
                BaseStatus.loading,
              ),
              isA<ProgressState>()
                  .having((s) => s.status, 'status', BaseStatus.success)
                  .having((s) => s.scans.length, 'scans.length', 8)
                  .having(
                    (s) => s.concernTypes.length,
                    'concernTypes.length',
                    12,
                  ),
            ]),
          ),
        );

        bloc.add(const ProgressStarted());
      },
    );

    test('switches segment, range, smoothing, and calendar day', () async {
      unawaited(
        expectLater(
          bloc.stream,
          emitsInOrder([
            isA<ProgressState>().having((s) => s.selectedSegment, 'segment', 1),
            isA<ProgressState>().having((s) => s.selectedRange, 'range', 2),
            isA<ProgressState>().having(
              (s) => s.smoothEnabled,
              'smooth',
              false,
            ),
            isA<ProgressState>().having(
              (s) => s.selectedCalendarDay,
              'day',
              16,
            ),
          ]),
        ),
      );

      bloc
        ..add(const ProgressSegmentChanged(1))
        ..add(const ProgressRangeChanged(2))
        ..add(const ProgressSmoothingToggled())
        ..add(const ProgressCalendarDaySelected(16));
    });
  });
}
