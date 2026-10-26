/// Constants for RevenueCat in-app subscriptions and entitlements.
abstract final class SubscriptionConstants {
  /// Test RevenueCat API key provided for development.
  static const String apiKey = 'test_ciJAnKfoFFXUyJuKnkzaESNTQyj';

  /// Primary entitlement identifier for unlocking Kora Pro features.
  static const String entitlementKoraPro = 'kora_pro';

  /// In-app purchase product identifier for the annual subscription.
  static const String productYearly = 'yearly';

  /// In-app purchase product identifier for the monthly subscription.
  static const String productMonthly = 'monthly';

  /// Identifier for the default offering configured in RevenueCat dashboard.
  static const String defaultOfferingId = 'default';
}
