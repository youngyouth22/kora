import 'package:equatable/equatable.dart';
import 'package:kora/features/subscription/domain/entities/subscription_offering.dart';
import 'package:kora/features/subscription/domain/entities/subscription_package.dart';
import 'package:kora/features/subscription/domain/entities/subscription_status.dart';

/// Status enum representing the discrete lifecycle states of
/// subscription flows.
enum SubscriptionStepStatus {
  /// Initial idle state.
  initial,

  /// In-progress asynchronous operation.
  loading,

  /// Operation finished successfully.
  success,

  /// Operation failed with error.
  failure,
}

/// State representation for the subscription and entitlement flow.
class SubscriptionState extends Equatable {
  /// Creates a [SubscriptionState].
  const SubscriptionState({
    this.status = SubscriptionStepStatus.initial,
    this.isPro = false,
    this.subscriptionStatus,
    this.currentOffering,
    this.selectedPackage,
    this.errorMessage,
  });

  /// Current loading status.
  final SubscriptionStepStatus status;

  /// Whether the user has verified Kora Pro access.
  final bool isPro;

  /// Full subscription details (expiration, renew status, product id).
  final SubscriptionStatus? subscriptionStatus;

  /// Active offering containing the available subscription packages.
  final SubscriptionOffering? currentOffering;

  /// The currently selected package on paywall interfaces.
  final SubscriptionPackage? selectedPackage;

  /// Error message when status is [SubscriptionStepStatus.failure].
  final String? errorMessage;

  /// Returns a copy of [SubscriptionState] with updated fields.
  SubscriptionState copyWith({
    SubscriptionStepStatus? status,
    bool? isPro,
    SubscriptionStatus? subscriptionStatus,
    SubscriptionOffering? currentOffering,
    SubscriptionPackage? selectedPackage,
    String? errorMessage,
  }) {
    return SubscriptionState(
      status: status ?? this.status,
      isPro: isPro ?? this.isPro,
      subscriptionStatus: subscriptionStatus ?? this.subscriptionStatus,
      currentOffering: currentOffering ?? this.currentOffering,
      selectedPackage: selectedPackage ?? this.selectedPackage,
      errorMessage: errorMessage ?? this.errorMessage,
    );
  }

  @override
  List<Object?> get props => [
    status,
    isPro,
    subscriptionStatus,
    currentOffering,
    selectedPackage,
    errorMessage,
  ];
}
