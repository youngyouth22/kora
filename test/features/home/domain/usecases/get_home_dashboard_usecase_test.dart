import 'package:dartz/dartz.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:kora/core/error/failures.dart';
import 'package:kora/core/usecase/usecase.dart';
import 'package:kora/features/home/domain/entities/home_dashboard_data.dart';
import 'package:kora/features/home/domain/repositories/home_repository.dart';
import 'package:kora/features/home/domain/usecases/get_home_dashboard_usecase.dart';

class _FakeHomeRepository implements HomeRepository {
  bool getDashboardCalled = false;
  bool shouldFail = false;

  static const testData = HomeDashboardData(
    userName: 'Amina',
    currentStreak: 5,
    longestStreak: 10,
    weeklyScanStreak: 2,
    streakDaysCompleted: [true, true, false, false, false, false, false],
    daysUntilNextScan: 3,
    isScanDueToday: false,
    hasBaselineScan: true,
    nextScanDateLabel: 'Sunday at 6 PM',
    morningRoutineDone: true,
    eveningRoutineDone: false,
    skinCheckinDone: false,
    dailyTipRead: true,
  );

  @override
  Future<Either<Failure, HomeDashboardData>> getDashboardData() async {
    getDashboardCalled = true;
    if (shouldFail) {
      return const Left(CacheFailure(message: 'Disk error'));
    }
    return const Right(testData);
  }

  @override
  Future<Either<Failure, void>> submitSkinCheckin({required int feel}) async {
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
  late GetHomeDashboardUseCase useCase;

  setUp(() {
    repository = _FakeHomeRepository();
    useCase = GetHomeDashboardUseCase(repository);
  });

  test(
    'should return HomeDashboardData when repository call succeeds',
    () async {
      final result = await useCase(const NoParams());

      expect(
        result,
        const Right<Failure, HomeDashboardData>(_FakeHomeRepository.testData),
      );
      expect(repository.getDashboardCalled, isTrue);
    },
  );

  test('should return Failure when repository call fails', () async {
    repository.shouldFail = true;

    final result = await useCase(const NoParams());

    expect(
      result,
      const Left<Failure, HomeDashboardData>(
        CacheFailure(message: 'Disk error'),
      ),
    );
  });
}
