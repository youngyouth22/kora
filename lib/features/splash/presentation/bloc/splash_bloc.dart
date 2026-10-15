// ignore_for_file: document_ignores
// ignore_for_file: prefer_initializing_formals

import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:kora/core/enums/status.dart';
import 'package:kora/core/usecase/usecase.dart';
import 'package:kora/features/splash/domain/usecases/bootstrap_app_usecase.dart';
import 'package:kora/features/splash/presentation/bloc/splash_event.dart';
import 'package:kora/features/splash/presentation/bloc/splash_state.dart';

/// Orchestrates app bootstrap state and notifies presentation layers.
class SplashBloc extends Bloc<SplashEvent, SplashState> {
  /// Creates [SplashBloc] with required [BootstrapAppUseCase].
  SplashBloc({
    required BootstrapAppUseCase bootstrapApp,
  }) : _bootstrapApp = bootstrapApp,
       super(const SplashState()) {
    on<SplashStartedEvent>(_onSplashStarted);
  }

  final BootstrapAppUseCase _bootstrapApp;

  Future<void> _onSplashStarted(
    SplashStartedEvent event,
    Emitter<SplashState> emit,
  ) async {
    emit(state.copyWith(status: BaseStatus.loading));

    final result = await _bootstrapApp(const NoParams());

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
          bootstrapData: data,
        ),
      ),
    );
  }
}
