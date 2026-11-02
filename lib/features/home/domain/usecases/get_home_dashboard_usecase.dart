import 'package:dartz/dartz.dart';
import 'package:kora/core/error/failures.dart';
import 'package:kora/core/usecase/usecase.dart';
import 'package:kora/features/home/domain/entities/home_dashboard_data.dart';
import 'package:kora/features/home/domain/repositories/home_repository.dart';

/// Use case that orchestrates retrieval of the live dashboard data.
class GetHomeDashboardUseCase implements UseCase<HomeDashboardData, NoParams> {
  /// Creates a [GetHomeDashboardUseCase].
  const GetHomeDashboardUseCase(this._repository);

  final HomeRepository _repository;

  @override
  Future<Either<Failure, HomeDashboardData>> call(NoParams params) {
    return _repository.getDashboardData();
  }
}
