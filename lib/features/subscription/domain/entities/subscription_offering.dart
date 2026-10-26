import 'package:equatable/equatable.dart';
import 'package:kora/features/subscription/domain/entities/subscription_package.dart';

/// Pure domain representation of a RevenueCat offering containing
/// subscription tiers.
class SubscriptionOffering extends Equatable {
  /// Creates a [SubscriptionOffering].
  const SubscriptionOffering({
    required this.identifier,
    required this.serverDescription,
    required this.availablePackages,
    this.annual,
    this.monthly,
  });

  /// Identifier of the offering (e.g. 'default').
  final String identifier;

  /// Server-configured offering description.
  final String serverDescription;

  /// List of all packages configured within this offering.
  final List<SubscriptionPackage> availablePackages;

  /// Convenience accessor for the annual package if present.
  final SubscriptionPackage? annual;

  /// Convenience accessor for the monthly package if present.
  final SubscriptionPackage? monthly;

  @override
  List<Object?> get props => [
    identifier,
    serverDescription,
    availablePackages,
    annual,
    monthly,
  ];
}
