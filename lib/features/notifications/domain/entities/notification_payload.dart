import 'package:equatable/equatable.dart';
import 'package:kora/features/notifications/domain/entities/notification_type.dart';

/// Pure domain entity describing the structured payload attached to every
/// local notification for exact deep-link navigation and analytics tracking.
class NotificationPayload extends Equatable {
  /// Creates a [NotificationPayload].
  const NotificationPayload({
    required this.type,
    required this.targetRoute,
    required this.title,
    required this.body,
    required this.createdAt,
    this.metadata = const {},
  });

  /// Factory creating payload with defaults from [NotificationType].
  factory NotificationPayload.fromType({
    required NotificationType type,
    String? customTitle,
    String? customBody,
    String? customTargetRoute,
    Map<String, dynamic> metadata = const {},
    DateTime? createdAt,
  }) {
    return NotificationPayload(
      type: type,
      targetRoute: customTargetRoute ?? type.defaultTargetRoute,
      title: customTitle ?? type.defaultTitle,
      body: customBody ?? type.defaultBody,
      createdAt: createdAt ?? DateTime.now(),
      metadata: metadata,
    );
  }

  /// Specific notification type.
  final NotificationType type;

  /// Exact application path to navigate upon user interaction.
  final String targetRoute;

  /// User-facing notification title.
  final String title;

  /// User-facing notification content body.
  final String body;

  /// Timestamp when the notification payload was generated.
  final DateTime createdAt;

  /// Optional contextual metadata (e.g. experimentId, planType).
  final Map<String, dynamic> metadata;

  @override
  List<Object?> get props => [
    type,
    targetRoute,
    title,
    body,
    createdAt,
    metadata,
  ];
}
