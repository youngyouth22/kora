import 'dart:async';

import 'package:dartz/dartz.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:kora/core/error/failures.dart';
import 'package:kora/core/usecase/usecase.dart';
import 'package:kora/features/subscription/domain/entities/subscription_offering.dart';
import 'package:kora/features/subscription/domain/entities/subscription_package.dart';
import 'package:kora/features/subscription/domain/entities/subscription_status.dart';
import 'package:kora/features/subscription/domain/repositories/subscription_repository.dart';
import 'package:kora/features/subscription/domain/usecases/check_pro_entitlement_usecase.dart';

class _FakeSubscriptionRepository implements SubscriptionRepository {
  Either<Failure, SubscriptionStatus> getStatusResult = const Right(
    SubscriptionStatus(isPro: true),
  );

  @override
  Future<Either<Failure, SubscriptionStatus>> getSubscriptionStatus() async =>
      getStatusResult;

  @override
  Future<Either<Failure, SubscriptionOffering>> getCurrentOffering() async =>
      const Left(SubscriptionFailure(message: 'Unimplemented'));

  @override
  Future<Either<Failure, SubscriptionStatus>> purchasePackage(
    SubscriptionPackage package,
  ) async => getStatusResult;

  @override
  Future<Either<Failure, SubscriptionStatus>> restorePurchases() async =>
      getStatusResult;

  @override
  Stream<SubscriptionStatus> get subscriptionStatusStream =>
      const Stream.empty();
}

void main() {
  late _FakeSubscriptionRepository repository;
  late CheckProEntitlementUseCase useCase;

  setUp(() {
    repository = _FakeSubscriptionRepository();
    useCase = CheckProEntitlementUseCase(repository);
  });

  group('CheckProEntitlementUseCase', () {
    test('returns SubscriptionStatus with isPro true on success', () async {
      repository.getStatusResult = const Right(
        SubscriptionStatus(
          isPro: true,
          activeProductIdentifier: 'yearly',
          willRenew: true,
        ),
      );

      final result = await useCase(const NoParams());

      expect(result.isRight(), isTrue);
      result.fold(
        (_) => fail('Should be Right'),
        (status) {
          expect(status.isPro, isTrue);
          expect(status.activeProductIdentifier, equals('yearly'));
          expect(status.willRenew, isTrue);
        },
      );
    });

    test('returns Failure when repository fails', () async {
      repository.getStatusResult = const Left(
        SubscriptionFailure(message: 'Connection failed'),
      );

      final result = await useCase(const NoParams());

      expect(result.isLeft(), isTrue);
      result.fold(
        (failure) {
          expect(failure, isA<SubscriptionFailure>());
          expect(failure.message, equals('Connection failed'));
        },
        (_) => fail('Should be Left'),
      );
    });
  });
}
