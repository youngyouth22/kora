import 'dart:convert';

import 'package:kora/features/notifications/domain/entities/notification_payload.dart';
import 'package:kora/features/notifications/domain/entities/notification_type.dart';

/// Data model and serialization mapper for [NotificationPayload].
class NotificationPayloadModel extends NotificationPayload {
  /// Creates a [NotificationPayloadModel] instance.
  const NotificationPayloadModel({
    required super.type,
    required super.targetRoute,
    required super.title,
    required super.body,
    required super.createdAt,
    super.metadata = const {},
  });

  /// Creates a model from a domain entity.
  factory NotificationPayloadModel.fromEntity(NotificationPayload entity) {
    return NotificationPayloadModel(
      type: entity.type,
      targetRoute: entity.targetRoute,
      title: entity.title,
      body: entity.body,
      createdAt: entity.createdAt,
      metadata: entity.metadata,
    );
  }

  /// Deserializes a model from raw JSON map.
  factory NotificationPayloadModel.fromJson(Map<String, dynamic> json) {
    final typeStr = json['type'] as String?;
    final type = NotificationType.fromString(typeStr);

    return NotificationPayloadModel(
      type: type,
      targetRoute: (json['targetRoute'] as String?) ?? type.defaultTargetRoute,
      title: (json['title'] as String?) ?? type.defaultTitle,
      body: (json['body'] as String?) ?? type.defaultBody,
      createdAt: json['createdAt'] != null
          ? DateTime.tryParse(json['createdAt'] as String) ?? DateTime.now()
          : DateTime.now(),
      metadata: (json['metadata'] as Map<String, dynamic>?) ?? const {},
    );
  }

  /// Deserializes from string payload safely.
  static NotificationPayloadModel? tryParse(String? raw) {
    if (raw == null || raw.isEmpty) return null;
    try {
      final decoded = jsonDecode(raw);
      if (decoded is Map<String, dynamic>) {
        return NotificationPayloadModel.fromJson(decoded);
      }
    } on Object catch (_) {}
    return null;
  }

  /// Serializes to JSON map.
  Map<String, dynamic> toJson() {
    return {
      'type': type.name,
      'targetRoute': targetRoute,
      'title': title,
      'body': body,
      'createdAt': createdAt.toIso8601String(),
      'metadata': metadata,
    };
  }

  /// Serializes to JSON string for local notification payload storage.
  String toJsonString() => jsonEncode(toJson());
}
