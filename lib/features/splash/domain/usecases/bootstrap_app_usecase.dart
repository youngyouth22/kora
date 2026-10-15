import 'package:kora/core/usecase/usecase.dart';
import 'package:kora/core/utils/typedefs.dart';
import 'package:kora/features/splash/domain/entities/app_bootstrap_data.dart';
import 'package:kora/features/splash/domain/repositories/splash_repository.dart';

/// Use case that orchestrates bootstrapping initialization state.
class BootstrapAppUseCase implements UseCase<AppBootstrapData, NoParams> {
  /// Creates the use case with injected [SplashRepository].
  const BootstrapAppUseCase(this._repository);

  final SplashRepository _repository;

  @override
  ResultFuture<AppBootstrapData> call(NoParams params) {
    return _repository.bootstrap();
  }
}
