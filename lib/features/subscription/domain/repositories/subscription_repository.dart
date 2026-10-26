import 'dart:async';

import 'package:dartz/dartz.dart';
import 'package:kora/core/error/failures.dart';
import 'package:kora/features/subscription/domain/entities/subscription_offering.dart';
import 'package:kora/features/subscription/domain/entities/subscription_package.dart';
import 'package:kora/features/subscription/domain/entities/subscription_status.dart';

/// Abstract contract for managing in-app purchases, offerings,
/// and entitlements.
abstract class SubscriptionRepository {
  /// Fetches the user's latest entitlement and subscription state.
  Future<Either<Failure, SubscriptionStatus>> getSubscriptionStatus();

  /// Fetches the active subscription offerings and product packages.
  Future<Either<Failure, SubscriptionOffering>> getCurrentOffering();

  /// Purchases a specific subscription package.
  Future<Either<Failure, SubscriptionStatus>> purchasePackage(
    SubscriptionPackage package,
  );

  /// Restores existing purchases for the active store account.
  Future<Either<Failure, SubscriptionStatus>> restorePurchases();

  /// Real-time stream emitting status whenever customer info changes.
  Stream<SubscriptionStatus> get subscriptionStatusStream;
}
