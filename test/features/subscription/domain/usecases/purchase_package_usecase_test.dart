import 'dart:async';

import 'package:dartz/dartz.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:kora/core/error/failures.dart';
import 'package:kora/features/subscription/domain/entities/subscription_offering.dart';
import 'package:kora/features/subscription/domain/entities/subscription_package.dart';
import 'package:kora/features/subscription/domain/entities/subscription_status.dart';
import 'package:kora/features/subscription/domain/repositories/subscription_repository.dart';
import 'package:kora/features/subscription/domain/usecases/purchase_package_usecase.dart';

class _FakeSubscriptionRepository implements SubscriptionRepository {
  Either<Failure, SubscriptionStatus> purchaseResult = const Right(
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
  ) async => purchaseResult;

  @override
  Future<Either<Failure, SubscriptionStatus>> restorePurchases() async =>
      const Right(SubscriptionStatus(isPro: false));

  @override
  Stream<SubscriptionStatus> get subscriptionStatusStream =>
      const Stream.empty();
}

void main() {
  late _FakeSubscriptionRepository repository;
  late PurchasePackageUseCase useCase;

  setUp(() {
    repository = _FakeSubscriptionRepository();
    useCase = PurchasePackageUseCase(repository);
  });

  const samplePackage = SubscriptionPackage(
    identifier: r'$rc_annual',
    packageType: 'ANNUAL',
    productIdentifier: 'yearly',
    productTitle: 'Kora Pro Annual',
    productDescription: 'Yearly subscription',
    priceString: r'$49.99',
    rawPrice: 49.99,
    currencyCode: 'USD',
  );

  group('PurchasePackageUseCase', () {
    test('returns active SubscriptionStatus on successful purchase', () async {
      repository.purchaseResult = const Right(
        SubscriptionStatus(
          isPro: true,
          activeProductIdentifier: 'yearly',
          willRenew: true,
        ),
      );

      final result = await useCase(samplePackage);

      expect(result.isRight(), isTrue);
      result.fold(
        (_) => fail('Should be Right'),
        (status) {
          expect(status.isPro, isTrue);
          expect(status.activeProductIdentifier, equals('yearly'));
        },
      );
    });

    test('returns Failure when purchase fails', () async {
      repository.purchaseResult = const Left(
        SubscriptionFailure(message: 'User cancelled or payment failed'),
      );

      final result = await useCase(samplePackage);

      expect(result.isLeft(), isTrue);
      result.fold(
        (failure) {
          expect(failure.message, contains('payment failed'));
        },
        (_) => fail('Should be Left'),
      );
    });
  });
}
