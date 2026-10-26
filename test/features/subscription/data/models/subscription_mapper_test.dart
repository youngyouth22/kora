import 'package:flutter_test/flutter_test.dart';
import 'package:kora/features/subscription/domain/entities/subscription_offering.dart';
import 'package:kora/features/subscription/domain/entities/subscription_package.dart';
import 'package:kora/features/subscription/domain/entities/subscription_status.dart';

void main() {
  group('Subscription Entities', () {
    test('SubscriptionStatus.free has isPro false', () {
      final freeStatus = SubscriptionStatus.free();
      expect(freeStatus.isPro, isFalse);
      expect(freeStatus.expirationDate, isNull);
      expect(freeStatus.activeProductIdentifier, isNull);
      expect(freeStatus.willRenew, isFalse);
    });

    test('SubscriptionPackage props comparison works correctly', () {
      const pkg1 = SubscriptionPackage(
        identifier: r'$rc_annual',
        packageType: 'ANNUAL',
        productIdentifier: 'yearly',
        productTitle: 'Pro Annual',
        productDescription: 'Save 30%',
        priceString: r'$49.99',
        rawPrice: 49.99,
        currencyCode: 'USD',
      );

      const pkg2 = SubscriptionPackage(
        identifier: r'$rc_annual',
        packageType: 'ANNUAL',
        productIdentifier: 'yearly',
        productTitle: 'Pro Annual',
        productDescription: 'Save 30%',
        priceString: r'$49.99',
        rawPrice: 49.99,
        currencyCode: 'USD',
      );

      expect(pkg1, equals(pkg2));
    });

    test('SubscriptionOffering holds packages and convenience accessors', () {
      const annualPkg = SubscriptionPackage(
        identifier: r'$rc_annual',
        packageType: 'ANNUAL',
        productIdentifier: 'yearly',
        productTitle: 'Pro Annual',
        productDescription: 'Save 30%',
        priceString: r'$49.99',
        rawPrice: 49.99,
        currencyCode: 'USD',
      );

      const monthlyPkg = SubscriptionPackage(
        identifier: r'$rc_monthly',
        packageType: 'MONTHLY',
        productIdentifier: 'monthly',
        productTitle: 'Pro Monthly',
        productDescription: 'Monthly billed',
        priceString: r'$5.99',
        rawPrice: 5.99,
        currencyCode: 'USD',
      );

      const offering = SubscriptionOffering(
        identifier: 'default',
        serverDescription: 'Default offering',
        availablePackages: [annualPkg, monthlyPkg],
        annual: annualPkg,
        monthly: monthlyPkg,
      );

      expect(offering.identifier, equals('default'));
      expect(offering.availablePackages.length, equals(2));
      expect(offering.annual, equals(annualPkg));
      expect(offering.monthly, equals(monthlyPkg));
    });
  });
}
