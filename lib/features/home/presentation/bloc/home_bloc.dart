// Ignore preference initializing formals for explicit dependency orchestration.
// ignore_for_file: prefer_initializing_formals

import 'dart:async';

import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:kora/core/enums/status.dart';
import 'package:kora/core/usecase/usecase.dart';
import 'package:kora/features/home/domain/repositories/home_repository.dart';
import 'package:kora/features/home/domain/usecases/get_home_dashboard_usecase.dart';
import 'package:kora/features/home/presentation/bloc/home_event.dart';
import 'package:kora/features/home/presentation/bloc/home_state.dart';

/// Orchestrates live dashboard data retrieval and user actions.
class HomeBloc extends Bloc<HomeEvent, HomeState> {
  /// Creates a [HomeBloc].
  HomeBloc({
    required GetHomeDashboardUseCase getHomeDashboard,
    required HomeRepository homeRepository,
  }) : _getHomeDashboard = getHomeDashboard,
       _homeRepository = homeRepository,
       super(const HomeState()) {
    on<HomeStarted>(_onStarted);
    on<HomeRefreshed>(_onRefreshed);
    on<HomeSkinCheckinSubmitted>(_onSkinCheckinSubmitted);
    on<HomeDailyTipToggled>(_onDailyTipToggled);
  }

  final GetHomeDashboardUseCase _getHomeDashboard;
  final HomeRepository _homeRepository;
  StreamSubscription<void>? _scansSubscription;

  Future<void> _onStarted(
    HomeStarted event,
    Emitter<HomeState> emit,
  ) async {
    await _scansSubscription?.cancel();
    _scansSubscription = _homeRepository.watchScans().skip(1).listen((_) {
      if (!isClosed) {
        add(const HomeRefreshed());
      }
    });

    emit(state.copyWith(status: BaseStatus.loading));
    try {
      final result = await _getHomeDashboard(const NoParams());
      result.fold(
        (failure) => emit(
          state.copyWith(
            status: BaseStatus.failure,
            errorMessage: failure.message,
          ),
        ),
        (data) => emit(
          state.copyWith(
            status: BaseStatus.success,
            data: data,
          ),
        ),
      );
    } on Object catch (e) {
      emit(
        state.copyWith(
          status: BaseStatus.failure,
          errorMessage: e.toString(),
        ),
      );
    }
  }

  Future<void> _onRefreshed(
    HomeRefreshed event,
    Emitter<HomeState> emit,
  ) async {
    final result = await _getHomeDashboard(const NoParams());
    result.fold(
      (failure) => emit(
        state.copyWith(errorMessage: failure.message),
      ),
      (data) => emit(
        state.copyWith(
          status: BaseStatus.success,
          data: data,
        ),
      ),
    );
  }

  Future<void> _onSkinCheckinSubmitted(
    HomeSkinCheckinSubmitted event,
    Emitter<HomeState> emit,
  ) async {
    await _homeRepository.submitSkinCheckin(feel: event.feel);
    final result = await _getHomeDashboard(const NoParams());
    result.fold(
      (_) {},
      (data) => emit(
        state.copyWith(
          status: BaseStatus.success,
          data: data,
        ),
      ),
    );
  }

  Future<void> _onDailyTipToggled(
    HomeDailyTipToggled event,
    Emitter<HomeState> emit,
  ) async {
    await _homeRepository.toggleDailyTip(read: event.read);
    final result = await _getHomeDashboard(const NoParams());
    result.fold(
      (_) {},
      (data) => emit(
        state.copyWith(
          status: BaseStatus.success,
          data: data,
        ),
      ),
    );
  }

  @override
  Future<void> close() async {
    await _scansSubscription?.cancel();
    return super.close();
  }
}
