// ignore_for_file: document_ignores
// ignore_for_file: prefer_initializing_formals

import 'package:dartz/dartz.dart';
import 'package:kora/core/error/failures.dart';
import 'package:kora/core/utils/typedefs.dart';
import 'package:kora/features/splash/data/datasources/splash_local_datasource.dart';
import 'package:kora/features/splash/domain/entities/app_bootstrap_data.dart';
import 'package:kora/features/splash/domain/repositories/splash_repository.dart';

/// Repository implementation for bootstrapping the application.
class SplashRepositoryImpl implements SplashRepository {
  /// Creates [SplashRepositoryImpl] with required local datasource.
  const SplashRepositoryImpl({
    required SplashLocalDataSource localDataSource,
  }) : _localDataSource = localDataSource;

  final SplashLocalDataSource _localDataSource;

  @override
  ResultFuture<AppBootstrapData> bootstrap() async {
    try {
      final model = await _localDataSource.getBootstrapData();
      return Right(model.toEntity());
    } on Exception catch (e) {
      return Left(CacheFailure(message: 'Failed to bootstrap app state: $e'));
    }
  }
}
