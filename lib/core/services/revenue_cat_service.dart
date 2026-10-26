import 'dart:developer' as developer;

import 'package:flutter/foundation.dart';
import 'package:kora/core/constants/subscription_constants.dart';
import 'package:purchases_flutter/purchases_flutter.dart';
import 'package:purchases_ui_flutter/purchases_ui_flutter.dart';

/// Facade service orchestrating RevenueCat SDK initialization,
/// user identity management, and UI modal triggers.
abstract final class RevenueCatService {
  /// Initializes the RevenueCat SDK with the application configuration.
  ///
  /// Can optionally bind to an existing authenticated [appUserId]
  /// (e.g. Supabase UID).
  static Future<void> initialize({String? appUserId}) async {
    try {
      if (kDebugMode) {
        await Purchases.setLogLevel(LogLevel.debug);
      }

      final configuration = PurchasesConfiguration(SubscriptionConstants.apiKey)
        ..appUserID = appUserId;

      await Purchases.configure(configuration);
      developer.log(
        'RevenueCat SDK configured successfully',
        name: 'RevenueCatService',
      );
    } on Object catch (e, stackTrace) {
      developer.log(
        'Failed to initialize RevenueCat SDK: $e',
        name: 'RevenueCatService',
        error: e,
        stackTrace: stackTrace,
      );
      rethrow;
    }
  }

  /// Synchronizes identity when a user logs in to Kora.
  static Future<CustomerInfo> logIn(String userId) async {
    final result = await Purchases.logIn(userId);
    return result.customerInfo;
  }

  /// Resets customer identity upon user log out.
  static Future<CustomerInfo> logOut() async {
    return Purchases.logOut();
  }

  /// Quick check whether the user holds active
  /// [SubscriptionConstants.entitlementKoraPro].
  static Future<bool> isKoraProActive() async {
    try {
      final customerInfo = await Purchases.getCustomerInfo();
      final entitlement = customerInfo
          .entitlements
          .all[SubscriptionConstants.entitlementKoraPro];
      return entitlement?.isActive ?? false;
    } on Object {
      return false;
    }
  }

  /// Displays the remotely configured RevenueCat paywall modally.
  static Future<PaywallResult> presentPaywall({
    Offering? offering,
  }) async {
    return RevenueCatUI.presentPaywall(
      offering: offering,
    );
  }

  /// Displays the RevenueCat paywall only if the user does NOT possess
  /// the active [SubscriptionConstants.entitlementKoraPro] entitlement.
  static Future<PaywallResult> presentPaywallIfNeeded({
    Offering? offering,
  }) async {
    return RevenueCatUI.presentPaywallIfNeeded(
      SubscriptionConstants.entitlementKoraPro,
      offering: offering,
    );
  }

  /// Displays RevenueCat's native Customer Center modal.
  ///
  /// Enables users to view subscriptions, restore purchases,
  /// request refunds (iOS), or initiate cancellations.
  static Future<void> presentCustomerCenter() async {
    await RevenueCatUI.presentCustomerCenter();
  }
}
