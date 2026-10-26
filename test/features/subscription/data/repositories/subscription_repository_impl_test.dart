import 'dart:async';

import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:kora/core/error/failures.dart';
import 'package:kora/features/subscription/data/datasources/revenue_cat_datasource.dart';
import 'package:kora/features/subscription/data/repositories/subscription_repository_impl.dart';
import 'package:purchases_flutter/purchases_flutter.dart';

class _FakeRevenueCatDataSource implements RevenueCatDataSource {
  final StreamController<CustomerInfo> _streamController =
      StreamController<CustomerInfo>.broadcast();

  CustomerInfo? customerInfoToReturn;
  Offerings? offeringsToReturn;
  Exception? errorToThrow;

  @override
  Stream<CustomerInfo> get customerInfoStream => _streamController.stream;

  @override
  Future<CustomerInfo> getCustomerInfo() async {
    if (errorToThrow != null) {
      throw errorToThrow!;
    }
    return customerInfoToReturn!;
  }

  @override
  Future<Offerings> getOfferings() async {
    if (errorToThrow != null) {
      throw errorToThrow!;
    }
    return offeringsToReturn!;
  }

  @override
  Future<CustomerInfo> purchasePackage(String packageIdentifier) async {
    if (errorToThrow != null) {
      throw errorToThrow!;
    }
    return customerInfoToReturn!;
  }

  @override
  Future<CustomerInfo> restorePurchases() async {
    if (errorToThrow != null) {
      throw errorToThrow!;
    }
    return customerInfoToReturn!;
  }
}

void main() {
  late _FakeRevenueCatDataSource dataSource;
  late SubscriptionRepositoryImpl repository;

  setUp(() {
    dataSource = _FakeRevenueCatDataSource();
    repository = SubscriptionRepositoryImpl(dataSource);
  });

  group('SubscriptionRepositoryImpl', () {
    test(
      'returns SubscriptionFailure on getCustomerInfo error',
      () async {
        dataSource.errorToThrow = PlatformException(
          code: '1',
          message: 'Network error checking entitlement',
        );

        final result = await repository.getSubscriptionStatus();

        expect(result.isLeft(), isTrue);
        result.fold(
          (failure) {
            expect(failure, isA<SubscriptionFailure>());
            expect(failure.message, contains('Network error'));
          },
          (_) => fail('Should be Left'),
        );
      },
    );

    test(
      'returns SubscriptionFailure on getCurrentOffering error',
      () async {
        dataSource.errorToThrow = PlatformException(
          code: '7',
          message: 'Could not fetch offerings',
        );

        final result = await repository.getCurrentOffering();

        expect(result.isLeft(), isTrue);
        result.fold(
          (failure) {
            expect(failure, isA<SubscriptionFailure>());
            expect(failure.message, contains('Could not fetch offerings'));
          },
          (_) => fail('Should be Left'),
        );
      },
    );

    test(
      'returns SubscriptionFailure on restorePurchases error',
      () async {
        dataSource.errorToThrow = PlatformException(
          code: '2',
          message: 'Store account unavailable',
        );

        final result = await repository.restorePurchases();

        expect(result.isLeft(), isTrue);
        result.fold(
          (failure) {
            expect(failure, isA<SubscriptionFailure>());
            expect(failure.message, contains('Store account unavailable'));
          },
          (_) => fail('Should be Left'),
        );
      },
    );
  });
}
