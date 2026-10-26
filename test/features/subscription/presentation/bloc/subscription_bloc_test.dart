import 'dart:async';

import 'package:dartz/dartz.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:kora/core/error/failures.dart';
import 'package:kora/features/subscription/domain/entities/subscription_offering.dart';
import 'package:kora/features/subscription/domain/entities/subscription_package.dart';
import 'package:kora/features/subscription/domain/entities/subscription_status.dart';
import 'package:kora/features/subscription/domain/repositories/subscription_repository.dart';
import 'package:kora/features/subscription/domain/usecases/check_pro_entitlement_usecase.dart';
import 'package:kora/features/subscription/domain/usecases/get_current_offering_usecase.dart';
import 'package:kora/features/subscription/domain/usecases/purchase_package_usecase.dart';
import 'package:kora/features/subscription/domain/usecases/restore_purchases_usecase.dart';
import 'package:kora/features/subscription/presentation/bloc/subscription_bloc.dart';
import 'package:kora/features/subscription/presentation/bloc/subscription_event.dart';
import 'package:kora/features/subscription/presentation/bloc/subscription_state.dart';

class _FakeSubscriptionRepository implements SubscriptionRepository {
  final StreamController<SubscriptionStatus> _controller =
      StreamController<SubscriptionStatus>.broadcast();

  Either<Failure, SubscriptionStatus> statusResult = const Right(
    SubscriptionStatus(isPro: false),
  );
  Either<Failure, SubscriptionOffering> offeringResult = const Left(
    SubscriptionFailure(message: 'No offering'),
  );
  Either<Failure, SubscriptionStatus> purchaseResult = const Right(
    SubscriptionStatus(isPro: true),
  );
  Either<Failure, SubscriptionStatus> restoreResult = const Right(
    SubscriptionStatus(isPro: true),
  );

  void emitStatus(SubscriptionStatus status) {
    _controller.add(status);
  }

  @override
  Future<Either<Failure, SubscriptionStatus>> getSubscriptionStatus() async =>
      statusResult;

  @override
  Future<Either<Failure, SubscriptionOffering>> getCurrentOffering() async =>
      offeringResult;

  @override
  Future<Either<Failure, SubscriptionStatus>> purchasePackage(
    SubscriptionPackage package,
  ) async => purchaseResult;

  @override
  Future<Either<Failure, SubscriptionStatus>> restorePurchases() async =>
      restoreResult;

  @override
  Stream<SubscriptionStatus> get subscriptionStatusStream => _controller.stream;
}

void main() {
  late _FakeSubscriptionRepository repository;
  late CheckProEntitlementUseCase checkProEntitlement;
  late GetCurrentOfferingUseCase getCurrentOffering;
  late PurchasePackageUseCase purchasePackage;
  late RestorePurchasesUseCase restorePurchases;
  late SubscriptionBloc bloc;

  setUp(() {
    repository = _FakeSubscriptionRepository();
    checkProEntitlement = CheckProEntitlementUseCase(repository);
    getCurrentOffering = GetCurrentOfferingUseCase(repository);
    purchasePackage = PurchasePackageUseCase(repository);
    restorePurchases = RestorePurchasesUseCase(repository);

    bloc = SubscriptionBloc(
      checkProEntitlement: checkProEntitlement,
      getCurrentOffering: getCurrentOffering,
      purchasePackage: purchasePackage,
      restorePurchases: restorePurchases,
      repository: repository,
    );
  });

  tearDown(() async {
    await bloc.close();
  });

  const samplePackage = SubscriptionPackage(
    identifier: r'$rc_annual',
    packageType: 'ANNUAL',
    productIdentifier: 'yearly',
    productTitle: 'Yearly Plan',
    productDescription: 'Save 30%',
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

  group('SubscriptionBloc', () {
    test(
      'initial state has SubscriptionStepStatus.initial and isPro false',
      () {
        expect(bloc.state.status, equals(SubscriptionStepStatus.initial));
        expect(bloc.state.isPro, isFalse);
      },
    );

    test(
      'emits [loading, success] with isPro true when entitlement is verified',
      () async {
        repository.statusResult = const Right(
          SubscriptionStatus(isPro: true, activeProductIdentifier: 'yearly'),
        );

        final expectedStates = [
          const SubscriptionState(status: SubscriptionStepStatus.loading),
          const SubscriptionState(
            status: SubscriptionStepStatus.success,
            isPro: true,
            subscriptionStatus: SubscriptionStatus(
              isPro: true,
              activeProductIdentifier: 'yearly',
            ),
          ),
        ];

        final futureExpect = expectLater(
          bloc.stream,
          emitsInOrder(expectedStates),
        );

        bloc.add(const CheckSubscriptionRequested());
        await futureExpect;
      },
    );

    test('emits [loading, failure] when checking entitlement fails', () async {
      repository.statusResult = const Left(
        SubscriptionFailure(message: 'Network error occurred'),
      );

      final expectedStates = [
        const SubscriptionState(status: SubscriptionStepStatus.loading),
        const SubscriptionState(
          status: SubscriptionStepStatus.failure,
          errorMessage: 'Network error occurred',
        ),
      ];

      final futureExpect = expectLater(
        bloc.stream,
        emitsInOrder(expectedStates),
      );

      bloc.add(const CheckSubscriptionRequested());
      await futureExpect;
    });

    test(
      'emits [loading, success] with offering on FetchOfferingRequested',
      () async {
        repository.offeringResult = const Right(sampleOffering);

        final expectedStates = [
          const SubscriptionState(status: SubscriptionStepStatus.loading),
          const SubscriptionState(
            status: SubscriptionStepStatus.success,
            currentOffering: sampleOffering,
            selectedPackage: samplePackage,
          ),
        ];

        final futureExpect = expectLater(
          bloc.stream,
          emitsInOrder(expectedStates),
        );

        bloc.add(const FetchOfferingRequested());
        await futureExpect;
      },
    );

    test(
      'emits [loading, success] with isPro true on PurchasePackageRequested',
      () async {
        repository.purchaseResult = const Right(
          SubscriptionStatus(isPro: true, activeProductIdentifier: 'yearly'),
        );

        final expectedStates = [
          const SubscriptionState(status: SubscriptionStepStatus.loading),
          const SubscriptionState(
            status: SubscriptionStepStatus.success,
            isPro: true,
            subscriptionStatus: SubscriptionStatus(
              isPro: true,
              activeProductIdentifier: 'yearly',
            ),
          ),
        ];

        final futureExpect = expectLater(
          bloc.stream,
          emitsInOrder(expectedStates),
        );

        bloc.add(const PurchasePackageRequested(samplePackage));
        await futureExpect;
      },
    );

    test('emits [loading, success] on RestorePurchasesRequested', () async {
      repository.restoreResult = const Right(
        SubscriptionStatus(isPro: true, activeProductIdentifier: 'monthly'),
      );

      final expectedStates = [
        const SubscriptionState(status: SubscriptionStepStatus.loading),
        const SubscriptionState(
          status: SubscriptionStepStatus.success,
          isPro: true,
          subscriptionStatus: SubscriptionStatus(
            isPro: true,
            activeProductIdentifier: 'monthly',
          ),
        ),
      ];

      final futureExpect = expectLater(
        bloc.stream,
        emitsInOrder(expectedStates),
      );

      bloc.add(const RestorePurchasesRequested());
      await futureExpect;
    });

    test(
      'updates state reactively when status stream emits new status',
      () async {
        final expectedStates = [
          const SubscriptionState(
            isPro: true,
            subscriptionStatus: SubscriptionStatus(
              isPro: true,
              activeProductIdentifier: 'yearly',
            ),
          ),
        ];

        final futureExpect = expectLater(
          bloc.stream,
          emitsInOrder(expectedStates),
        );

        repository.emitStatus(
          const SubscriptionStatus(
            isPro: true,
            activeProductIdentifier: 'yearly',
          ),
        );
        await futureExpect;
      },
    );
  });
}
