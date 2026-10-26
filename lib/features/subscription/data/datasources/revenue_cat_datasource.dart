import 'dart:async';

import 'package:flutter/services.dart';
import 'package:purchases_flutter/purchases_flutter.dart';

/// Contract for communicating directly with RevenueCat platform SDK.
abstract class RevenueCatDataSource {
  /// Fetches the latest customer information from the RevenueCat backend/cache.
  Future<CustomerInfo> getCustomerInfo();

  /// Fetches current offerings containing packages configured on the dashboard.
  Future<Offerings> getOfferings();

  /// Executes purchase for a package identified by its unique identifier.
  Future<CustomerInfo> purchasePackage(String packageIdentifier);

  /// Restores previous purchases for the active store account.
  Future<CustomerInfo> restorePurchases();

  /// Broadcast stream emitting updated [CustomerInfo] on transactions.
  Stream<CustomerInfo> get customerInfoStream;
}

/// Concrete implementation delegating to [Purchases] API.
class RevenueCatDataSourceImpl implements RevenueCatDataSource {
  /// Creates a [RevenueCatDataSourceImpl] and registers update listener.
  RevenueCatDataSourceImpl() {
    Purchases.addCustomerInfoUpdateListener(_customerInfoController.add);
  }

  final StreamController<CustomerInfo> _customerInfoController =
      StreamController<CustomerInfo>.broadcast();

  @override
  Stream<CustomerInfo> get customerInfoStream => _customerInfoController.stream;

  @override
  Future<CustomerInfo> getCustomerInfo() {
    return Purchases.getCustomerInfo();
  }

  @override
  Future<Offerings> getOfferings() {
    return Purchases.getOfferings();
  }

  @override
  Future<CustomerInfo> purchasePackage(String packageIdentifier) async {
    final offerings = await Purchases.getOfferings();
    Package? targetPackage;

    for (final offering in offerings.all.values) {
      for (final package in offering.availablePackages) {
        if (package.identifier == packageIdentifier) {
          targetPackage = package;
          break;
        }
      }
      if (targetPackage != null) {
        break;
      }
    }

    if (targetPackage == null) {
      throw PlatformException(
        code: 'PACKAGE_NOT_FOUND',
        message:
            'Subscription package "$packageIdentifier" was not found in '
            'active offerings.',
      );
    }

    final purchaseResult = await Purchases.purchase(
      PurchaseParams.package(targetPackage),
    );
    return purchaseResult.customerInfo;
  }

  @override
  Future<CustomerInfo> restorePurchases() {
    return Purchases.restorePurchases();
  }
}
