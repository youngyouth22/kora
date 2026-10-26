import 'package:equatable/equatable.dart';

/// Evaluation result from the business rules engine prior to dispatching
/// or scheduling any notification.
class NotificationRuleResult extends Equatable {
  /// Creates a [NotificationRuleResult].
  const NotificationRuleResult({
    required this.isAllowed,
    required this.scheduledTime,
    this.rejectionReason,
    this.isAdjustedForQuietHours = false,
  });

  /// Permitted result without schedule adjustment.
  factory NotificationRuleResult.allowed(DateTime scheduledTime) {
    return NotificationRuleResult(
      isAllowed: true,
      scheduledTime: scheduledTime,
    );
  }

  /// Permitted result where time was shifted outside of quiet hours.
  factory NotificationRuleResult.adjusted({
    required DateTime adjustedTime,
  }) {
    return NotificationRuleResult(
      isAllowed: true,
      scheduledTime: adjustedTime,
      isAdjustedForQuietHours: true,
    );
  }

  /// Rejected result when rules prohibit delivery (e.g. weekly cap exceeded).
  factory NotificationRuleResult.rejected({
    required String reason,
    required DateTime requestedTime,
  }) {
    return NotificationRuleResult(
      isAllowed: false,
      scheduledTime: requestedTime,
      rejectionReason: reason,
    );
  }

  /// Whether dispatch or scheduling is permitted by enterprise policy.
  final bool isAllowed;

  /// Effective delivery timestamp (adjusted if quiet hours were intercepted).
  final DateTime scheduledTime;

  /// Human-readable or programmatic reason if rejected.
  final String? rejectionReason;

  /// Whether quiet hours policy shifted the scheduled time.
  final bool isAdjustedForQuietHours;

  @override
  List<Object?> get props => [
    isAllowed,
    scheduledTime,
    rejectionReason,
    isAdjustedForQuietHours,
  ];
}
