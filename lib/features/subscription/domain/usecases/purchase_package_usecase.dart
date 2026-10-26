import 'package:dartz/dartz.dart';
import 'package:kora/core/error/failures.dart';
import 'package:kora/core/usecase/usecase.dart';
import 'package:kora/features/subscription/domain/entities/subscription_package.dart';
import 'package:kora/features/subscription/domain/entities/subscription_status.dart';
import 'package:kora/features/subscription/domain/repositories/subscription_repository.dart';

/// Usecase to execute the purchase flow for a specific [SubscriptionPackage].
class PurchasePackageUseCase
    implements UseCase<SubscriptionStatus, SubscriptionPackage> {
  /// Creates a [PurchasePackageUseCase].
  const PurchasePackageUseCase(this._repository);

  final SubscriptionRepository _repository;

  @override
  Future<Either<Failure, SubscriptionStatus>> call(
    SubscriptionPackage package,
  ) {
    return _repository.purchasePackage(package);
  }
}
