import 'package:equatable/equatable.dart';

/// Pure domain entity describing the user's current subscription
/// and entitlement status.
class SubscriptionStatus extends Equatable {
  /// Creates a [SubscriptionStatus].
  const SubscriptionStatus({
    required this.isPro,
    this.expirationDate,
    this.activeProductIdentifier,
    this.willRenew = false,
    this.originalPurchaseDate,
  });

  /// Factory representing an inactive / free subscription.
  factory SubscriptionStatus.free() => const SubscriptionStatus(isPro: false);

  /// Whether the user currently has an active Kora Pro entitlement.
  final bool isPro;

  /// Expiration or renewal date of the active subscription, if any.
  final DateTime? expirationDate;

  /// Store product identifier of the active subscription
  /// (e.g. 'yearly', 'monthly').
  final String? activeProductIdentifier;

  /// Whether the subscription will automatically renew at expiration.
  final bool willRenew;

  /// Original transaction timestamp when the subscription was first initiated.
  final DateTime? originalPurchaseDate;

  @override
  List<Object?> get props => [
    isPro,
    expirationDate,
    activeProductIdentifier,
    willRenew,
    originalPurchaseDate,
  ];
}
