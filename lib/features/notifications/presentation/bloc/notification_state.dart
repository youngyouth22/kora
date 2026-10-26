import 'package:equatable/equatable.dart';
import 'package:kora/core/enums/status.dart';
import 'package:kora/features/notifications/domain/entities/notification_payload.dart';
import 'package:kora/features/notifications/domain/entities/notification_preferences.dart';

/// Immutable state representation for the notification feature.
class NotificationState extends Equatable {
  /// Creates a [NotificationState] instance.
  const NotificationState({
    this.status = BaseStatus.initial,
    this.preferences = const NotificationPreferences(),
    this.isPermissionGranted = false,
    this.isPermanentlyDenied = false,
    this.lastOpenedPayload,
    this.errorMessage,
  });

  /// Current async status of the bloc.
  final BaseStatus status;

  /// Active user preferences, quiet hours settings, and cadence metrics.
  final NotificationPreferences preferences;

  /// Whether notification permission is currently active in the OS.
  final bool isPermissionGranted;

  /// Whether notification permission has been permanently denied.
  final bool isPermanentlyDenied;

  /// Last payload received from a notification response tap.
  final NotificationPayload? lastOpenedPayload;

  /// Error message when status is [BaseStatus.failure].
  final String? errorMessage;

  /// Helper indicating if the state is loading.
  bool get isLoading => status.isLoading;

  /// Helper indicating if the state is success.
  bool get isSuccess => status.isSuccess;

  /// Helper indicating if the state is failure.
  bool get isFailure => status.isFailure;

  /// Copies state with optional updated parameters.
  NotificationState copyWith({
    BaseStatus? status,
    NotificationPreferences? preferences,
    bool? isPermissionGranted,
    bool? isPermanentlyDenied,
    NotificationPayload? lastOpenedPayload,
    bool clearLastOpenedPayload = false,
    String? errorMessage,
  }) {
    return NotificationState(
      status: status ?? this.status,
      preferences: preferences ?? this.preferences,
      isPermissionGranted: isPermissionGranted ?? this.isPermissionGranted,
      isPermanentlyDenied: isPermanentlyDenied ?? this.isPermanentlyDenied,
      lastOpenedPayload: clearLastOpenedPayload
          ? null
          : (lastOpenedPayload ?? this.lastOpenedPayload),
      errorMessage: errorMessage ?? this.errorMessage,
    );
  }

  @override
  List<Object?> get props => [
    status,
    preferences,
    isPermissionGranted,
    isPermanentlyDenied,
    lastOpenedPayload,
    errorMessage,
  ];
}
