import 'dart:async';

import 'package:dartz/dartz.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:kora/core/error/failures.dart';
import 'package:kora/core/usecase/usecase.dart';
import 'package:kora/features/subscription/domain/entities/subscription_offering.dart';
import 'package:kora/features/subscription/domain/entities/subscription_package.dart';
import 'package:kora/features/subscription/domain/entities/subscription_status.dart';
import 'package:kora/features/subscription/domain/repositories/subscription_repository.dart';
import 'package:kora/features/subscription/domain/usecases/restore_purchases_usecase.dart';

class _FakeSubscriptionRepository implements SubscriptionRepository {
  Either<Failure, SubscriptionStatus> restoreResult = const Right(
    SubscriptionStatus(isPro: true),
  );

  @override
  Future<Either<Failure, SubscriptionStatus>> getSubscriptionStatus() async =>
      const Right(SubscriptionStatus(isPro: false));

  @override
  Future<Either<Failure, SubscriptionOffering>> getCurrentOffering() async =>
      const Left(SubscriptionFailure(message: 'Unimplemented'));

  @override
  Future<Either<Failure, SubscriptionStatus>> purchasePackage(
    SubscriptionPackage package,
  ) async => const Right(SubscriptionStatus(isPro: false));

  @override
  Future<Either<Failure, SubscriptionStatus>> restorePurchases() async =>
      restoreResult;

  @override
  Stream<SubscriptionStatus> get subscriptionStatusStream =>
      const Stream.empty();
}

void main() {
  late _FakeSubscriptionRepository repository;
  late RestorePurchasesUseCase useCase;

  setUp(() {
    repository = _FakeSubscriptionRepository();
    useCase = RestorePurchasesUseCase(repository);
  });

  group('RestorePurchasesUseCase', () {
    test('returns restored SubscriptionStatus on success', () async {
      repository.restoreResult = const Right(
        SubscriptionStatus(
          isPro: true,
          activeProductIdentifier: 'monthly',
        ),
      );

      final result = await useCase(const NoParams());

      expect(result.isRight(), isTrue);
      result.fold(
        (_) => fail('Should be Right'),
        (status) {
          expect(status.isPro, isTrue);
          expect(status.activeProductIdentifier, equals('monthly'));
        },
      );
    });

    test('returns Failure when restore fails', () async {
      repository.restoreResult = const Left(
        SubscriptionFailure(message: 'Store account not reachable'),
      );

      final result = await useCase(const NoParams());

      expect(result.isLeft(), isTrue);
      result.fold(
        (failure) {
          expect(failure.message, contains('Store account not reachable'));
        },
        (_) => fail('Should be Left'),
      );
    });
  });
}
