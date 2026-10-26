import 'package:equatable/equatable.dart';
import 'package:kora/features/subscription/domain/entities/subscription_package.dart';
import 'package:kora/features/subscription/domain/entities/subscription_status.dart';

/// Base class for all subscription-related BLoC events.
sealed class SubscriptionEvent extends Equatable {
  /// Const constructor for base event.
  const SubscriptionEvent();

  @override
  List<Object?> get props => [];
}

/// Triggers verification of user's active entitlement status.
final class CheckSubscriptionRequested extends SubscriptionEvent {
  /// Creates a [CheckSubscriptionRequested] event.
  const CheckSubscriptionRequested();
}

/// Fetches the active offering containing available products.
final class FetchOfferingRequested extends SubscriptionEvent {
  /// Creates a [FetchOfferingRequested] event.
  const FetchOfferingRequested();
}

/// Initiates purchase for a specific [SubscriptionPackage].
final class PurchasePackageRequested extends SubscriptionEvent {
  /// Creates a [PurchasePackageRequested] event with target [package].
  const PurchasePackageRequested(this.package);

  /// Target subscription package to purchase.
  final SubscriptionPackage package;

  @override
  List<Object?> get props => [package];
}

/// Restores past purchases from the store account.
final class RestorePurchasesRequested extends SubscriptionEvent {
  /// Creates a [RestorePurchasesRequested] event.
  const RestorePurchasesRequested();
}

/// Emitted internally when real-time customer info changes occur.
final class SubscriptionStatusUpdated extends SubscriptionEvent {
  /// Creates a [SubscriptionStatusUpdated] event with new [status].
  const SubscriptionStatusUpdated(this.status);

  /// The updated subscription status.
  final SubscriptionStatus status;

  @override
  List<Object?> get props => [status];
}
