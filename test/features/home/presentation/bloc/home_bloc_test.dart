import 'dart:async';

import 'package:dartz/dartz.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:kora/core/enums/status.dart';
import 'package:kora/core/error/failures.dart';
import 'package:kora/features/home/domain/entities/home_dashboard_data.dart';
import 'package:kora/features/home/domain/repositories/home_repository.dart';
import 'package:kora/features/home/domain/usecases/get_home_dashboard_usecase.dart';
import 'package:kora/features/home/presentation/bloc/home_bloc.dart';
import 'package:kora/features/home/presentation/bloc/home_event.dart';
import 'package:kora/features/home/presentation/bloc/home_state.dart';

class _FakeHomeRepository implements HomeRepository {
  bool shouldFail = false;
  int? lastFeel;

  static const testData = HomeDashboardData(
    userName: 'Amina',
    currentStreak: 3,
    longestStreak: 7,
    weeklyScanStreak: 1,
    streakDaysCompleted: [true, false, false, false, false, false, false],
    daysUntilNextScan: 4,
    isScanDueToday: false,
    hasBaselineScan: true,
    nextScanDateLabel: 'Sunday at 6 PM',
    morningRoutineDone: true,
    eveningRoutineDone: false,
    skinCheckinDone: false,
    dailyTipRead: false,
  );

  @override
  Future<Either<Failure, HomeDashboardData>> getDashboardData() async {
    if (shouldFail) {
      return const Left(CacheFailure(message: 'Error'));
    }
    return const Right(testData);
  }

  @override
  Future<Either<Failure, void>> submitSkinCheckin({required int feel}) async {
    lastFeel = feel;
    return const Right(null);
  }

  @override
  Future<Either<Failure, void>> toggleDailyTip({required bool read}) async {
    return const Right(null);
  }

  @override
  Stream<void> watchScans() => const Stream.empty();
}

void main() {
  late _FakeHomeRepository repository;
  late GetHomeDashboardUseCase getHomeDashboard;
  late HomeBloc bloc;

  setUp(() {
    repository = _FakeHomeRepository();
    getHomeDashboard = GetHomeDashboardUseCase(repository);
    bloc = HomeBloc(
      getHomeDashboard: getHomeDashboard,
      homeRepository: repository,
    );
  });

  tearDown(() async {
    await bloc.close();
  });

  group('HomeBloc', () {
    test('initial state has BaseStatus.initial', () {
      expect(bloc.state, const HomeState());
    });

    test('emits [loading, success] when HomeStarted succeeds', () async {
      final expected = [
        const HomeState(status: BaseStatus.loading),
        const HomeState(
          status: BaseStatus.success,
          data: _FakeHomeRepository.testData,
        ),
      ];

      unawaited(expectLater(bloc.stream, emitsInOrder(expected)));
      bloc.add(const HomeStarted());
    });

    test('emits [loading, failure] when HomeStarted fails', () async {
      repository.shouldFail = true;

      final expected = [
        const HomeState(status: BaseStatus.loading),
        const HomeState(
          status: BaseStatus.failure,
          errorMessage: 'Error',
        ),
      ];

      unawaited(expectLater(bloc.stream, emitsInOrder(expected)));
      bloc.add(const HomeStarted());
    });

    test('handles HomeSkinCheckinSubmitted and refreshes data', () async {
      final expected = [
        const HomeState(
          status: BaseStatus.success,
          data: _FakeHomeRepository.testData,
        ),
      ];

      unawaited(expectLater(bloc.stream, emitsInOrder(expected)));
      bloc.add(const HomeSkinCheckinSubmitted(3));
      await Future<void>.delayed(const Duration(milliseconds: 50));
      expect(repository.lastFeel, 3);
    });
  });
}
