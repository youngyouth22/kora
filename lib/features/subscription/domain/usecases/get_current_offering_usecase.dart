import 'package:dartz/dartz.dart';
import 'package:kora/core/error/failures.dart';
import 'package:kora/core/usecase/usecase.dart';
import 'package:kora/features/subscription/domain/entities/subscription_offering.dart';
import 'package:kora/features/subscription/domain/repositories/subscription_repository.dart';

/// Usecase to retrieve the current subscription offering with
/// configured packages.
class GetCurrentOfferingUseCase
    implements UseCase<SubscriptionOffering, NoParams> {
  /// Creates a [GetCurrentOfferingUseCase].
  const GetCurrentOfferingUseCase(this._repository);

  final SubscriptionRepository _repository;

  @override
  Future<Either<Failure, SubscriptionOffering>> call(NoParams params) {
    return _repository.getCurrentOffering();
  }
}
