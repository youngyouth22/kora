import 'package:kora/core/constants/subscription_constants.dart';
import 'package:kora/features/subscription/domain/entities/subscription_offering.dart';
import 'package:kora/features/subscription/domain/entities/subscription_package.dart';
import 'package:kora/features/subscription/domain/entities/subscription_status.dart';
import 'package:purchases_flutter/purchases_flutter.dart';

/// Bidirectional data mappers converting RevenueCat DTOs into
/// pure domain entities.
abstract final class SubscriptionMapper {
  /// Converts [CustomerInfo] into domain [SubscriptionStatus].
  static SubscriptionStatus fromCustomerInfo(CustomerInfo info) {
    final entitlement =
        info.entitlements.all[SubscriptionConstants.entitlementKoraPro];
    final isPro = entitlement?.isActive ?? false;

    DateTime? expirationDate;
    final expirationStr = entitlement?.expirationDate;
    if (expirationStr != null) {
      expirationDate = DateTime.tryParse(expirationStr);
    }

    DateTime? originalPurchaseDate;
    final purchaseDateStr = entitlement?.originalPurchaseDate;
    if (purchaseDateStr != null) {
      originalPurchaseDate = DateTime.tryParse(purchaseDateStr);
    }

    return SubscriptionStatus(
      isPro: isPro,
      expirationDate: expirationDate,
      activeProductIdentifier: entitlement?.productIdentifier,
      willRenew: entitlement?.willRenew ?? false,
      originalPurchaseDate: originalPurchaseDate,
    );
  }

  /// Converts a RevenueCat [Package] into domain [SubscriptionPackage].
  static SubscriptionPackage fromPackage(Package package) {
    return SubscriptionPackage(
      identifier: package.identifier,
      packageType: package.packageType.name,
      productIdentifier: package.storeProduct.identifier,
      productTitle: package.storeProduct.title,
      productDescription: package.storeProduct.description,
      priceString: package.storeProduct.priceString,
      rawPrice: package.storeProduct.price,
      currencyCode: package.storeProduct.currencyCode,
    );
  }

  /// Converts a RevenueCat [Offering] into domain [SubscriptionOffering].
  static SubscriptionOffering fromOffering(Offering offering) {
    final packages = offering.availablePackages
        .map(fromPackage)
        .toList(growable: false);

    SubscriptionPackage? annualPkg;
    if (offering.annual != null) {
      annualPkg = fromPackage(offering.annual!);
    }

    SubscriptionPackage? monthlyPkg;
    if (offering.monthly != null) {
      monthlyPkg = fromPackage(offering.monthly!);
    }

    return SubscriptionOffering(
      identifier: offering.identifier,
      serverDescription: offering.serverDescription,
      availablePackages: packages,
      annual: annualPkg,
      monthly: monthlyPkg,
    );
  }
}
