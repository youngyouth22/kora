// Encapsulate dependencies as private fields.
// ignore_for_file: prefer_initializing_formals

import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:kora/core/enums/status.dart';
import 'package:kora/features/routine/data/datasources/routine_sql_seed_datasource.dart';
import 'package:kora/features/routine/domain/entities/routine_product.dart';
import 'package:kora/features/routine/domain/entities/skin_checkin.dart';
import 'package:kora/features/routine/domain/usecases/evaluate_routine_insights_usecase.dart';
import 'package:kora/features/routine/domain/usecases/routine_usecases.dart';
import 'package:kora/features/routine/presentation/bloc/routine_event.dart';
import 'package:kora/features/routine/presentation/bloc/routine_state.dart';

/// BLoC orchestrating all routine operations: AM/PM steps, daily completion
/// logs, compatibility warnings, catalog browsing, and daily skin check-ins.
class RoutineBloc extends Bloc<RoutineEvent, RoutineState> {
  /// Creates a [RoutineBloc].
  RoutineBloc({
    required GetRoutineProductsUseCase getRoutineProducts,
    required SaveRoutineProductUseCase saveRoutineProduct,
    required DeleteRoutineProductUseCase deleteRoutineProduct,
    required ToggleRoutineStepUseCase toggleRoutineStep,
    required GetRoutineLogsForDateUseCase getRoutineLogsForDate,
    required GetCatalogProductsUseCase getCatalogProducts,
    required ManageSkinCheckinUseCase manageSkinCheckin,
    EvaluateRoutineInsightsUseCase evaluateInsights =
        const EvaluateRoutineInsightsUseCase(),
  }) : _getRoutineProducts = getRoutineProducts,
       _saveRoutineProduct = saveRoutineProduct,
       _deleteRoutineProduct = deleteRoutineProduct,
       _toggleRoutineStep = toggleRoutineStep,
       _getRoutineLogsForDate = getRoutineLogsForDate,
       _getCatalogProducts = getCatalogProducts,
       _manageSkinCheckin = manageSkinCheckin,
       _evaluateInsights = evaluateInsights,
       super(const RoutineState()) {
    on<RoutineStarted>(_onStarted);
    on<RoutinePeriodChanged>(_onPeriodChanged);
    on<RoutineStepToggled>(_onStepToggled);
    on<RoutineProductSaved>(_onProductSaved);
    on<RoutineProductDeleted>(_onProductDeleted);
    on<RoutineCatalogFiltered>(_onCatalogFiltered);
    on<RoutineCheckinSubmitted>(_onCheckinSubmitted);
  }

  final GetRoutineProductsUseCase _getRoutineProducts;
  final SaveRoutineProductUseCase _saveRoutineProduct;
  final DeleteRoutineProductUseCase _deleteRoutineProduct;
  final ToggleRoutineStepUseCase _toggleRoutineStep;
  final GetRoutineLogsForDateUseCase _getRoutineLogsForDate;
  final GetCatalogProductsUseCase _getCatalogProducts;
  final ManageSkinCheckinUseCase _manageSkinCheckin;
  final EvaluateRoutineInsightsUseCase _evaluateInsights;

  Future<void> _onStarted(
    RoutineStarted event,
    Emitter<RoutineState> emit,
  ) async {
    emit(state.copyWith(status: BaseStatus.loading));

    final userId = event.userId ?? RoutineSqlSeedDataSource.defaultUserId;
    final logDate =
        event.logDate ?? RoutineSqlSeedDataSource.formatIsoDate(DateTime.now());

    final productsResult = await _getRoutineProducts(userId: userId);
    final logsResult = await _getRoutineLogsForDate(
      userId: userId,
      logDate: logDate,
    );
    final catalogResult = await _getCatalogProducts();
    final checkinResult = await _manageSkinCheckin.getForDate(
      userId: userId,
      date: logDate,
    );

    productsResult.fold(
      (failure) => emit(
        state.copyWith(
          status: BaseStatus.failure,
          userId: userId,
          currentDate: logDate,
          errorMessage: failure.message,
        ),
      ),
      (products) {
        final selectedPeriod = event.initialPeriod ?? state.selectedPeriod;
        final logs = logsResult.getOrElse(() => const []);
        final catalog = catalogResult.getOrElse(() => const []);
        final checkin = checkinResult.getOrElse(() => null);
        final notices = _evaluateInsights.evaluateCompatibility(
          items: products,
          period: selectedPeriod,
        );

        emit(
          state.copyWith(
            status: BaseStatus.success,
            userId: userId,
            selectedPeriod: selectedPeriod,
            currentDate: logDate,
            products: products,
            logsForDate: logs,
            catalogProducts: catalog,
            todayCheckin: checkin,
            compatibilityNotices: notices,
          ),
        );
      },
    );
  }

  void _onPeriodChanged(
    RoutinePeriodChanged event,
    Emitter<RoutineState> emit,
  ) {
    final notices = _evaluateInsights.evaluateCompatibility(
      items: state.products,
      period: event.period,
    );
    emit(
      state.copyWith(
        selectedPeriod: event.period,
        compatibilityNotices: notices,
      ),
    );
  }

  Future<void> _onStepToggled(
    RoutineStepToggled event,
    Emitter<RoutineState> emit,
  ) async {
    final period = event.period ?? state.selectedPeriod;
    final logDate = state.currentDate.isNotEmpty
        ? state.currentDate
        : RoutineSqlSeedDataSource.formatIsoDate(DateTime.now());

    final currentlyDone = state.isStepDone(event.itemId, period: period);
    final nextDone = !currentlyDone;
    final logId = 'log-$logDate-$period-${event.itemId}';

    final record = RoutineLogRecord(
      id: logId,
      userId: state.userId,
      itemId: event.itemId,
      logDate: logDate,
      period: period,
      done: nextDone,
      createdAt: DateTime.now(),
    );

    final result = await _toggleRoutineStep(record);
    await result.fold(
      (failure) async => emit(
        state.copyWith(
          status: BaseStatus.failure,
          errorMessage: failure.message,
        ),
      ),
      (_) async {
        final logsResult = await _getRoutineLogsForDate(
          userId: state.userId,
          logDate: logDate,
        );
        final updatedLogs = logsResult.getOrElse(() => state.logsForDate);
        emit(
          state.copyWith(
            status: BaseStatus.success,
            logsForDate: updatedLogs,
          ),
        );
      },
    );
  }

  Future<void> _onProductSaved(
    RoutineProductSaved event,
    Emitter<RoutineState> emit,
  ) async {
    final result = await _saveRoutineProduct(event.product);
    await result.fold(
      (failure) async => emit(
        state.copyWith(
          status: BaseStatus.failure,
          errorMessage: failure.message,
        ),
      ),
      (_) async {
        final productsResult = await _getRoutineProducts(userId: state.userId);
        final updatedProducts = productsResult.getOrElse(() => state.products);
        final notices = _evaluateInsights.evaluateCompatibility(
          items: updatedProducts,
          period: state.selectedPeriod,
        );
        emit(
          state.copyWith(
            status: BaseStatus.success,
            products: updatedProducts,
            compatibilityNotices: notices,
          ),
        );
      },
    );
  }

  Future<void> _onProductDeleted(
    RoutineProductDeleted event,
    Emitter<RoutineState> emit,
  ) async {
    final result = await _deleteRoutineProduct(
      id: event.productId,
      userId: state.userId,
    );
    await result.fold(
      (failure) async => emit(
        state.copyWith(
          status: BaseStatus.failure,
          errorMessage: failure.message,
        ),
      ),
      (_) async {
        final productsResult = await _getRoutineProducts(userId: state.userId);
        final updatedProducts = productsResult.getOrElse(() => state.products);
        final notices = _evaluateInsights.evaluateCompatibility(
          items: updatedProducts,
          period: state.selectedPeriod,
        );
        emit(
          state.copyWith(
            status: BaseStatus.success,
            products: updatedProducts,
            compatibilityNotices: notices,
          ),
        );
      },
    );
  }

  Future<void> _onCatalogFiltered(
    RoutineCatalogFiltered event,
    Emitter<RoutineState> emit,
  ) async {
    final nextCategory = event.category ?? state.selectedCatalogCategory;
    final nextQuery = event.query ?? state.catalogQuery;

    final result = await _getCatalogProducts(
      category: nextCategory,
      query: nextQuery,
    );
    result.fold(
      (failure) => emit(
        state.copyWith(
          status: BaseStatus.failure,
          errorMessage: failure.message,
        ),
      ),
      (catalog) => emit(
        state.copyWith(
          status: BaseStatus.success,
          catalogProducts: catalog,
          selectedCatalogCategory: nextCategory,
          catalogQuery: nextQuery,
        ),
      ),
    );
  }

  Future<void> _onCheckinSubmitted(
    RoutineCheckinSubmitted event,
    Emitter<RoutineState> emit,
  ) async {
    final date = state.currentDate.isNotEmpty
        ? state.currentDate
        : RoutineSqlSeedDataSource.formatIsoDate(DateTime.now());
    final checkin = SkinCheckin(
      id: 'checkin-$date',
      userId: state.userId,
      checkinDate: date,
      skinFeel: event.skinFeel,
      newProducts: event.newProducts,
      note: event.note,
      createdAt: DateTime.now(),
    );

    final result = await _manageSkinCheckin.save(checkin);
    result.fold(
      (failure) => emit(
        state.copyWith(
          status: BaseStatus.failure,
          errorMessage: failure.message,
        ),
      ),
      (saved) => emit(
        state.copyWith(
          status: BaseStatus.success,
          todayCheckin: saved,
        ),
      ),
    );
  }
}
