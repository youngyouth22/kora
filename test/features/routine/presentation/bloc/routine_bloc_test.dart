import 'dart:async';

import 'package:dartz/dartz.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:kora/core/enums/status.dart';
import 'package:kora/core/error/failures.dart';
import 'package:kora/features/routine/data/datasources/routine_sql_seed_datasource.dart';
import 'package:kora/features/routine/domain/entities/catalog_product.dart';
import 'package:kora/features/routine/domain/entities/routine_product.dart';
import 'package:kora/features/routine/domain/entities/skin_checkin.dart';
import 'package:kora/features/routine/domain/repositories/routine_repository.dart';
import 'package:kora/features/routine/domain/usecases/routine_usecases.dart';
import 'package:kora/features/routine/presentation/bloc/routine_bloc.dart';
import 'package:kora/features/routine/presentation/bloc/routine_event.dart';
import 'package:kora/features/routine/presentation/bloc/routine_state.dart';

class _FakeRoutineRepository implements RoutineRepository {
  _FakeRoutineRepository({
    required this.items,
    required this.logs,
    required this.catalog,
    required this.checkin,
  });

  List<RoutineProduct> items;
  List<RoutineLogRecord> logs;
  List<CatalogProduct> catalog;
  SkinCheckin? checkin;

  @override
  Future<Either<Failure, List<RoutineProduct>>> getRoutineProducts({
    required String userId,
  }) async => Right(items);

  @override
  Stream<List<RoutineProduct>> watchRoutineProducts({
    required String userId,
  }) => Stream.value(items);

  @override
  Future<Either<Failure, RoutineProduct?>> getRoutineProductById({
    required String id,
    required String userId,
  }) async {
    for (final item in items) {
      if (item.id == id) return Right(item);
    }
    return const Right(null);
  }

  @override
  Future<Either<Failure, void>> saveRoutineProduct(
    RoutineProduct product,
  ) async {
    items = [...items.where((i) => i.id != product.id), product];
    return const Right(null);
  }

  @override
  Future<Either<Failure, void>> deleteRoutineProduct({
    required String id,
    required String userId,
  }) async {
    items = items.where((i) => i.id != id).toList();
    return const Right(null);
  }

  @override
  Future<Either<Failure, List<RoutineLogRecord>>> getLogsForDate({
    required String userId,
    required String logDate,
  }) async => Right(logs);

  @override
  Stream<List<RoutineLogRecord>> watchLogsForDate({
    required String userId,
    required String logDate,
  }) => Stream.value(logs);

  @override
  Future<Either<Failure, void>> logRoutineStep(RoutineLogRecord log) async {
    logs = [
      ...logs.where(
        (l) => !(l.itemId == log.itemId && l.period == log.period),
      ),
      log,
    ];
    return const Right(null);
  }

  @override
  Future<Either<Failure, List<CatalogProduct>>> getCatalogProducts({
    String? category,
    String? query,
  }) async => Right(catalog);

  @override
  Future<Either<Failure, SkinCheckin?>> getCheckinForDate({
    required String userId,
    required String date,
  }) async => Right(checkin);

  @override
  Future<Either<Failure, SkinCheckin>> saveCheckin(SkinCheckin value) async {
    checkin = value;
    return Right(value);
  }

  @override
  Future<Either<Failure, void>> syncRoutine({required String userId}) async =>
      const Right(null);
}

void main() {
  late _FakeRoutineRepository repository;
  late RoutineBloc bloc;
  final now = DateTime(2026, 10, 30);

  setUp(() {
    repository = _FakeRoutineRepository(
      items: RoutineSqlSeedDataSource.buildSeedRoutineItems(
        userId: 'u1',
        referenceDate: now,
      ),
      logs: RoutineSqlSeedDataSource.buildSeedLogsForDate(
        userId: 'u1',
        logDate: '2026-10-30',
        referenceDate: now,
      ),
      catalog: RoutineSqlSeedDataSource.buildCatalogProducts(),
      checkin: RoutineSqlSeedDataSource.buildDefaultCheckin(
        userId: 'u1',
        date: '2026-10-30',
        referenceDate: now,
      ),
    );
    bloc = RoutineBloc(
      getRoutineProducts: GetRoutineProductsUseCase(repository),
      saveRoutineProduct: SaveRoutineProductUseCase(repository),
      deleteRoutineProduct: DeleteRoutineProductUseCase(repository),
      toggleRoutineStep: ToggleRoutineStepUseCase(repository),
      getRoutineLogsForDate: GetRoutineLogsForDateUseCase(repository),
      getCatalogProducts: GetCatalogProductsUseCase(repository),
      manageSkinCheckin: ManageSkinCheckinUseCase(repository),
    );
  });

  tearDown(() async {
    await bloc.close();
  });

  group('RoutineBloc', () {
    test(
      'emits [loading, success] with SQL seed products, logs, catalog, '
      'and check-in on RoutineStarted',
      () async {
        unawaited(
          expectLater(
            bloc.stream,
            emitsInOrder([
              isA<RoutineState>().having(
                (s) => s.status,
                'status',
                BaseStatus.loading,
              ),
              isA<RoutineState>()
                  .having((s) => s.status, 'status', BaseStatus.success)
                  .having((s) => s.products.length, 'products.length', 6)
                  .having((s) => s.catalogProducts.length, 'catalog.length', 9)
                  .having((s) => s.todayCheckin?.skinFeel, 'skinFeel', 3),
            ]),
          ),
        );

        bloc.add(
          const RoutineStarted(
            userId: 'u1',
            logDate: '2026-10-30',
          ),
        );
      },
    );

    test(
      'switches period on RoutinePeriodChanged and recomputes compatibility '
      'notices',
      () async {
        bloc.add(
          const RoutineStarted(
            userId: 'u1',
            logDate: '2026-10-30',
          ),
        );
        await Future<void>.delayed(Duration.zero);

        unawaited(
          expectLater(
            bloc.stream,
            emitsThrough(
              isA<RoutineState>()
                  .having(
                    (s) => s.selectedPeriod,
                    'selectedPeriod',
                    RoutinePeriod.pm,
                  )
                  .having(
                    (s) => s.compatibilityNotices,
                    'compatibilityNotices',
                    isNotEmpty,
                  ),
            ),
          ),
        );

        bloc.add(const RoutinePeriodChanged(RoutinePeriod.pm));
      },
    );

    test('toggles step completion on RoutineStepToggled', () async {
      bloc.add(
        const RoutineStarted(
          userId: 'u1',
          logDate: '2026-10-30',
        ),
      );
      await Future<void>.delayed(Duration.zero);

      expect(bloc.state.isStepDone('item-cerave-cleanser'), isTrue);

      bloc.add(const RoutineStepToggled(itemId: 'item-cerave-cleanser'));
      await Future<void>.delayed(Duration.zero);

      expect(bloc.state.isStepDone('item-cerave-cleanser'), isFalse);
    });
  });
}
