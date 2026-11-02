import 'package:dartz/dartz.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:get_it/get_it.dart';
import 'package:kora/core/error/failures.dart';
import 'package:kora/features/home/domain/entities/home_dashboard_data.dart';
import 'package:kora/features/home/domain/repositories/home_repository.dart';
import 'package:kora/features/home/domain/usecases/get_home_dashboard_usecase.dart';
import 'package:kora/features/home/presentation/bloc/home_bloc.dart';
import 'package:kora/features/home/presentation/pages/home_page.dart';

class _FakeHomeRepository implements HomeRepository {
  static const testData = HomeDashboardData(
    userName: 'Amina',
    currentStreak: 4,
    longestStreak: 12,
    weeklyScanStreak: 2,
    streakDaysCompleted: [true, false, false, false, false, false, false],
    daysUntilNextScan: 3,
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
  late _FakeHomeRepository fakeRepository;

  setUp(() async {
    await GetIt.instance.reset();
    fakeRepository = _FakeHomeRepository();

    final getHomeDashboard = GetHomeDashboardUseCase(fakeRepository);
    GetIt.instance.registerLazySingleton<HomeRepository>(() => fakeRepository);
    GetIt.instance.registerLazySingleton<GetHomeDashboardUseCase>(
      () => getHomeDashboard,
    );
    GetIt.instance.registerFactory<HomeBloc>(
      () => HomeBloc(
        getHomeDashboard: getHomeDashboard,
        homeRepository: fakeRepository,
      ),
    );
  });

  tearDown(() async {
    await GetIt.instance.reset();
  });

  testWidgets(
    'HomePage renders live dashboard and DOES NOT render Skin Academy',
    (tester) async {
      tester.view.physicalSize = const Size(1080, 2800);
      tester.view.devicePixelRatio = 2.0;
      addTearDown(tester.view.resetPhysicalSize);
      addTearDown(tester.view.resetDevicePixelRatio);

      await tester.pumpWidget(
        const MaterialApp(home: HomePage()),
      );
      await tester.pumpAndSettle();

      // Greeting with resolved user name
      expect(find.textContaining('Amina'), findsOneWidget);

      // Daily plan section
      expect(find.text('Daily Plan'), findsOneWidget);
      expect(find.text('Morning routine'), findsOneWidget);
      expect(find.text('Evening routine'), findsOneWidget);

      // Next best action card
      expect(find.text('UPCOMING SCAN'), findsOneWidget);
      expect(find.text('Next scan in 3 days'), findsOneWidget);

      // VERIFY: Skin Academy is completely deleted and not found anywhere
      expect(find.text('Skin Academy'), findsNothing);
      expect(find.text('From Skin Academy'), findsNothing);
      expect(find.textContaining('Dr. Sam Ellis'), findsNothing);
    },
  );
}
