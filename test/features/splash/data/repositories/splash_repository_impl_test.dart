import 'package:dartz/dartz.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:kora/core/error/failures.dart';
import 'package:kora/features/splash/data/datasources/splash_local_datasource.dart';
import 'package:kora/features/splash/data/models/app_bootstrap_model.dart';
import 'package:kora/features/splash/data/repositories/splash_repository_impl.dart';
import 'package:kora/features/splash/domain/entities/app_bootstrap_data.dart';

class FakeSplashLocalDataSource implements SplashLocalDataSource {
  bool shouldThrow = false;
  bool isCompleted = false;

  @override
  Future<AppBootstrapModel> getBootstrapData() async {
    if (shouldThrow) {
      throw Exception('Cache read error');
    }
    return AppBootstrapModel(
      isOnboardingCompleted: isCompleted,
    );
  }
}

void main() {
  late FakeSplashLocalDataSource localDataSource;
  late SplashRepositoryImpl repository;

  setUp(() {
    localDataSource = FakeSplashLocalDataSource();
    repository = SplashRepositoryImpl(localDataSource: localDataSource);
  });

  test('returns Right(AppBootstrapData) when datasource succeeds', () async {
    localDataSource.isCompleted = true;

    final result = await repository.bootstrap();

    expect(
      result,
      const Right<Failure, AppBootstrapData>(
        AppBootstrapData(
          isOnboardingCompleted: true,
        ),
      ),
    );
  });

  test('returns Left(CacheFailure) when datasource throws', () async {
    localDataSource.shouldThrow = true;

    final result = await repository.bootstrap();

    expect(result.isLeft(), isTrue);
    result.fold(
      (failure) => expect(failure, isA<CacheFailure>()),
      (_) => fail('Expected Left'),
    );
  });
}
