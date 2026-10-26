import 'dart:async';

import 'package:dartz/dartz.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:kora/core/error/failures.dart';
import 'package:kora/core/usecase/usecase.dart';
import 'package:kora/features/subscription/domain/entities/subscription_offering.dart';
import 'package:kora/features/subscription/domain/entities/subscription_package.dart';
import 'package:kora/features/subscription/domain/entities/subscription_status.dart';
import 'package:kora/features/subscription/domain/repositories/subscription_repository.dart';
import 'package:kora/features/subscription/domain/usecases/get_current_offering_usecase.dart';

class _FakeSubscriptionRepository implements SubscriptionRepository {
  Either<Failure, SubscriptionOffering> getOfferingResult = const Left(
    SubscriptionFailure(message: 'Not set'),
  );

  @override
  Future<Either<Failure, SubscriptionStatus>> getSubscriptionStatus() async =>
      const Right(SubscriptionStatus(isPro: false));

  @override
  Future<Either<Failure, SubscriptionOffering>> getCurrentOffering() async =>
      getOfferingResult;

  @override
  Future<Either<Failure, SubscriptionStatus>> purchasePackage(
    SubscriptionPackage package,
  ) async => const Right(SubscriptionStatus(isPro: false));

  @override
  Future<Either<Failure, SubscriptionStatus>> restorePurchases() async =>
      const Right(SubscriptionStatus(isPro: false));

  @override
  Stream<SubscriptionStatus> get subscriptionStatusStream =>
      const Stream.empty();
}

void main() {
  late _FakeSubscriptionRepository repository;
  late GetCurrentOfferingUseCase useCase;

  setUp(() {
    repository = _FakeSubscriptionRepository();
    useCase = GetCurrentOfferingUseCase(repository);
  });

  const samplePackage = SubscriptionPackage(
    identifier: r'$rc_annual',
    packageType: 'ANNUAL',
    productIdentifier: 'yearly',
    productTitle: 'Kora Pro Annual',
    productDescription: 'Full access for a year',
    priceString: r'$49.99',
    rawPrice: 49.99,
    currencyCode: 'USD',
  );

  const sampleOffering = SubscriptionOffering(
    identifier: 'default',
    serverDescription: 'Default offering',
    availablePackages: [samplePackage],
    annual: samplePackage,
  );

  group('GetCurrentOfferingUseCase', () {
    test('returns SubscriptionOffering on success', () async {
      repository.getOfferingResult = const Right(sampleOffering);

      final result = await useCase(const NoParams());

      expect(result.isRight(), isTrue);
      result.fold(
        (_) => fail('Should be Right'),
        (offering) {
          expect(offering.identifier, equals('default'));
          expect(offering.annual?.productIdentifier, equals('yearly'));
          expect(offering.availablePackages.length, equals(1));
        },
      );
    });

    test('returns Failure when repository returns Left', () async {
      repository.getOfferingResult = const Left(
        SubscriptionFailure(message: 'No offerings found'),
      );

      final result = await useCase(const NoParams());

      expect(result.isLeft(), isTrue);
      result.fold(
        (failure) {
          expect(failure.message, equals('No offerings found'));
        },
        (_) => fail('Should be Left'),
      );
    });
  });
}
