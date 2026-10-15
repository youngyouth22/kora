import 'dart:async';

import 'package:dartz/dartz.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:kora/core/enums/status.dart';
import 'package:kora/core/error/failures.dart';
import 'package:kora/core/utils/typedefs.dart';
import 'package:kora/features/splash/domain/entities/app_bootstrap_data.dart';
import 'package:kora/features/splash/domain/repositories/splash_repository.dart';
import 'package:kora/features/splash/domain/usecases/bootstrap_app_usecase.dart';
import 'package:kora/features/splash/presentation/bloc/splash_bloc.dart';
import 'package:kora/features/splash/presentation/bloc/splash_event.dart';
import 'package:kora/features/splash/presentation/bloc/splash_state.dart';

class FakeSplashRepository implements SplashRepository {
  bool shouldFail = false;
  bool isCompleted = false;

  @override
  ResultFuture<AppBootstrapData> bootstrap() async {
    if (shouldFail) {
      return const Left(CacheFailure(message: 'Bootstrap error occurred'));
    }
    return Right(
      AppBootstrapData(
        isOnboardingCompleted: isCompleted,
      ),
    );
  }
}

void main() {
  late FakeSplashRepository repository;
  late BootstrapAppUseCase useCase;
  late SplashBloc bloc;

  setUp(() {
    repository = FakeSplashRepository();
    useCase = BootstrapAppUseCase(repository);
    bloc = SplashBloc(bootstrapApp: useCase);
  });

  tearDown(() async {
    await bloc.close();
  });

  test('initial state has BaseStatus.initial', () {
    expect(bloc.state.status, BaseStatus.initial);
    expect(bloc.state.bootstrapData, isNull);
    expect(bloc.state.errorMessage, isNull);
  });

  test('SplashStartedEvent emits [loading, success] when usecase succeeds', () {
    repository.isCompleted = true;

    final expectedStates = [
      const SplashState(status: BaseStatus.loading),
      const SplashState(
        status: BaseStatus.success,
        bootstrapData: AppBootstrapData(
          isOnboardingCompleted: true,
        ),
      ),
    ];

    unawaited(expectLater(bloc.stream, emitsInOrder(expectedStates)));

    bloc.add(const SplashStartedEvent());
  });

  test('SplashStartedEvent emits [loading, failure] when usecase fails', () {
    repository.shouldFail = true;

    final expectedStates = [
      const SplashState(status: BaseStatus.loading),
      const SplashState(
        status: BaseStatus.failure,
        errorMessage: 'Bootstrap error occurred',
      ),
    ];

    unawaited(expectLater(bloc.stream, emitsInOrder(expectedStates)));

    bloc.add(const SplashStartedEvent());
  });
}
