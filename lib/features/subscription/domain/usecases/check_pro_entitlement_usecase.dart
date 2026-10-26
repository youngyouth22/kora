import 'package:dartz/dartz.dart';
import 'package:kora/core/error/failures.dart';
import 'package:kora/core/usecase/usecase.dart';
import 'package:kora/features/subscription/domain/entities/subscription_status.dart';
import 'package:kora/features/subscription/domain/repositories/subscription_repository.dart';

/// Usecase to evaluate whether the active user holds the Kora Pro entitlement.
class CheckProEntitlementUseCase
    implements UseCase<SubscriptionStatus, NoParams> {
  /// Creates a [CheckProEntitlementUseCase].
  const CheckProEntitlementUseCase(this._repository);

  final SubscriptionRepository _repository;

  @override
  Future<Either<Failure, SubscriptionStatus>> call(NoParams params) {
    return _repository.getSubscriptionStatus();
  }
}
