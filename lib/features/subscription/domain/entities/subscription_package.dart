import 'package:equatable/equatable.dart';

/// Pure domain representation of a purchasable subscription package.
class SubscriptionPackage extends Equatable {
  /// Creates a [SubscriptionPackage].
  const SubscriptionPackage({
    required this.identifier,
    required this.packageType,
    required this.productIdentifier,
    required this.productTitle,
    required this.productDescription,
    required this.priceString,
    required this.rawPrice,
    required this.currencyCode,
  });

  /// RevenueCat package identifier (e.g. '$rc_annual', '$rc_monthly').
  final String identifier;

  /// Semantic package type (e.g. 'ANNUAL', 'MONTHLY', 'CUSTOM').
  final String packageType;

  /// Store product identifier (e.g. 'yearly', 'monthly').
  final String productIdentifier;

  /// Formatted localized title of the product.
  final String productTitle;

  /// Formatted localized description of the product.
  final String productDescription;

  /// Localized currency price string (e.g. '$39.99', '€39,99').
  final String priceString;

  /// Raw numeric price amount.
  final double rawPrice;

  /// ISO 4217 currency code (e.g. 'USD', 'EUR').
  final String currencyCode;

  @override
  List<Object?> get props => [
    identifier,
    packageType,
    productIdentifier,
    productTitle,
    productDescription,
    priceString,
    rawPrice,
    currencyCode,
  ];
}
