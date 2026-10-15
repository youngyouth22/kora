import 'package:dartz/dartz.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:kora/core/error/failures.dart';
import 'package:kora/core/usecase/usecase.dart';
import 'package:kora/core/utils/typedefs.dart';
import 'package:kora/features/splash/domain/entities/app_bootstrap_data.dart';
import 'package:kora/features/splash/domain/repositories/splash_repository.dart';
import 'package:kora/features/splash/domain/usecases/bootstrap_app_usecase.dart';

class FakeSplashRepository implements SplashRepository {
  bool shouldFail = false;
  bool isOnboardingCompleted = false;

  @override
  ResultFuture<AppBootstrapData> bootstrap() async {
    if (shouldFail) {
      return const Left(CacheFailure(message: 'Bootstrap read error'));
    }
    return Right(
      AppBootstrapData(
        isOnboardingCompleted: isOnboardingCompleted,
      ),
    );
  }
}

void main() {
  late FakeSplashRepository repository;
  late BootstrapAppUseCase useCase;

  setUp(() {
    repository = FakeSplashRepository();
    useCase = BootstrapAppUseCase(repository);
  });

  test('successfully returns AppBootstrapData on happy path', () async {
    repository.isOnboardingCompleted = true;

    final result = await useCase(const NoParams());

    expect(
      result,
      const Right<Failure, AppBootstrapData>(
        AppBootstrapData(
          isOnboardingCompleted: true,
        ),
      ),
    );
  });

  test('returns CacheFailure when repository fails', () async {
    repository.shouldFail = true;

    final result = await useCase(const NoParams());

    expect(
      result,
      const Left<Failure, AppBootstrapData>(
        CacheFailure(message: 'Bootstrap read error'),
      ),
    );
  });
}
