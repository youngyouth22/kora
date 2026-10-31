// ignore_for_file: document_ignores, lines_longer_than_80_chars, public_member_api_docs

import 'package:kora/features/coach/domain/entities/coach_chat_entities.dart';

/// Request payload model for `POST /api/agents/skinCoach/generate`.
class CoachChatRequestModel {
  /// Creates a [CoachChatRequestModel].
  const CoachChatRequestModel({
    required this.message,
    required this.threadId,
    required this.userId,
    required this.userJwt,
    this.coachContext,
    this.history,
  });

  /// User message content.
  final String message;

  /// Persistent thread identifier for conversation memory.
  final String threadId;

  /// Supabase user ID (or anonymous ID).
  final String userId;

  /// Supabase session JWT token.
  final String userJwt;

  /// Optional context (last scan date, active experiment, current concern).
  final CoachContext? coachContext;

  /// Prior messages for multi-turn conversational context.
  final List<CoachChatMessage>? history;

  /// Serializes to Mastra agent generation JSON format.
  Map<String, dynamic> toJson() {
    final messagesList = <Map<String, String>>[
      if (history != null)
        for (final m in history!)
          {
            'role': m.isUser ? 'user' : 'assistant',
            'content': m.text,
          },
      {
        'role': 'user',
        'content': message,
      },
    ];

    return {
      'messages': messagesList,
      'threadId': threadId,
      'userId': userId,
      if (coachContext != null) 'coachContext': coachContext!.toJson(),
    };
  }
}

/// Data model for [CoachReply] returned by Mastra / Kora AI Coach.
class CoachReplyModel {
  /// Creates a [CoachReplyModel].
  const CoachReplyModel({
    required this.text,
    this.isRedFlag = false,
    this.suggestedAction,
  });

  /// Deserializes a [CoachReplyModel] from JSON.
  factory CoachReplyModel.fromJson(Map<String, dynamic> json) {
    CoachSuggestedActionModel? actionModel;

    // Check direct suggestedAction property
    if (json['suggestedAction'] is Map<String, dynamic>) {
      actionModel = CoachSuggestedActionModel.fromJson(
        json['suggestedAction'] as Map<String, dynamic>,
      );
    } else if (json['toolInvocations'] is List) {
      // Check Mastra agent toolInvocations list
      final invocations = json['toolInvocations'] as List;
      for (final invocation in invocations) {
        if (invocation is Map<String, dynamic> &&
            invocation['toolName'] == 'suggest_action') {
          final res = invocation['result'];
          final args = invocation['args'];
          if (res is Map<String, dynamic>) {
            actionModel = CoachSuggestedActionModel.fromJson(res);
            break;
          } else if (args is Map<String, dynamic>) {
            actionModel = CoachSuggestedActionModel.fromJson(args);
            break;
          }
        }
      }
    }

    final rawText = json['text']?.toString().trim();
    final cleanText = (rawText != null && rawText.isNotEmpty)
        ? rawText
        : 'Supporting your skin barrier with gentle hydration and daily SPF 50 helps maintain balance.';

    return CoachReplyModel(
      text: cleanText,
      isRedFlag: json['isRedFlag'] as bool? ?? false,
      suggestedAction: actionModel,
    );
  }

  /// Reply text.
  final String text;

  /// Urgent medical red-flag indicator.
  final bool isRedFlag;

  /// Optional suggested action model.
  final CoachSuggestedActionModel? suggestedAction;

  /// Converts to pure domain [CoachReply] entity.
  CoachReply toEntity() => CoachReply(
    text: text,
    isRedFlag: isRedFlag,
    suggestedAction: suggestedAction?.toEntity(),
  );

  /// Serializes to JSON map.
  Map<String, dynamic> toJson() => {
    'text': text,
    'isRedFlag': isRedFlag,
    if (suggestedAction != null) 'suggestedAction': suggestedAction!.toJson(),
  };
}

/// Data model for [CoachSuggestedAction].
class CoachSuggestedActionModel {
  /// Creates a [CoachSuggestedActionModel].
  const CoachSuggestedActionModel({
    required this.type,
    required this.label,
    this.payload = const {},
  });

  /// Deserializes from JSON.
  factory CoachSuggestedActionModel.fromJson(Map<String, dynamic> json) {
    final rawPayload = json['payload'];
    return CoachSuggestedActionModel(
      type: json['type']?.toString() ?? 'log_scan',
      label: json['label']?.toString() ?? 'Take a quick skin scan',
      payload: rawPayload is Map<String, dynamic>
          ? rawPayload
          : const <String, dynamic>{},
    );
  }

  final String type;
  final String label;
  final Map<String, dynamic> payload;

  /// Converts to domain entity.
  CoachSuggestedAction toEntity() => CoachSuggestedAction(
    type: type,
    label: label,
    payload: payload,
  );

  /// Serializes to JSON.
  Map<String, dynamic> toJson() => {
    'type': type,
    'label': label,
    'payload': payload,
  };
}

/// Model for serializing and deserializing a [CoachChatMessage].
class CoachChatMessageModel {
  const CoachChatMessageModel({
    required this.id,
    required this.text,
    required this.isUser,
    required this.createdAt,
    this.isRedFlag = false,
    this.suggestedAction,
  });

  factory CoachChatMessageModel.fromEntity(CoachChatMessage entity) {
    return CoachChatMessageModel(
      id: entity.id,
      text: entity.text,
      isUser: entity.isUser,
      createdAt: entity.createdAt,
      isRedFlag: entity.isRedFlag,
      suggestedAction: entity.suggestedAction != null
          ? CoachSuggestedActionModel(
              type: entity.suggestedAction!.type,
              label: entity.suggestedAction!.label,
              payload: entity.suggestedAction!.payload,
            )
          : null,
    );
  }

  factory CoachChatMessageModel.fromJson(Map<String, dynamic> json) {
    return CoachChatMessageModel(
      id:
          json['id'] as String? ??
          'msg-${DateTime.now().microsecondsSinceEpoch}',
      text: json['text'] as String? ?? '',
      isUser: json['isUser'] as bool? ?? false,
      createdAt: json['createdAt'] != null
          ? DateTime.tryParse(json['createdAt'] as String) ?? DateTime.now()
          : DateTime.now(),
      isRedFlag: json['isRedFlag'] as bool? ?? false,
      suggestedAction: json['suggestedAction'] is Map<String, dynamic>
          ? CoachSuggestedActionModel.fromJson(
              json['suggestedAction'] as Map<String, dynamic>,
            )
          : null,
    );
  }

  final String id;
  final String text;
  final bool isUser;
  final DateTime createdAt;
  final bool isRedFlag;
  final CoachSuggestedActionModel? suggestedAction;

  CoachChatMessage toEntity() {
    return CoachChatMessage(
      id: id,
      text: text,
      isUser: isUser,
      createdAt: createdAt,
      isRedFlag: isRedFlag,
      suggestedAction: suggestedAction?.toEntity(),
    );
  }

  Map<String, dynamic> toJson() => {
    'id': id,
    'text': text,
    'isUser': isUser,
    'createdAt': createdAt.toIso8601String(),
    'isRedFlag': isRedFlag,
    if (suggestedAction != null) 'suggestedAction': suggestedAction!.toJson(),
  };
}

/// Model for serializing and deserializing a [CoachThread].
class CoachThreadModel {
  const CoachThreadModel({
    required this.id,
    required this.title,
    required this.updatedAt,
    this.messages = const [],
  });

  factory CoachThreadModel.fromEntity(CoachThread entity) {
    return CoachThreadModel(
      id: entity.id,
      title: entity.title,
      updatedAt: entity.updatedAt,
      messages: entity.messages.map(CoachChatMessageModel.fromEntity).toList(),
    );
  }

  factory CoachThreadModel.fromJson(Map<String, dynamic> json) {
    final rawMessages = json['messages'];
    final parsedMessages = <CoachChatMessageModel>[];
    if (rawMessages is List) {
      for (final item in rawMessages) {
        if (item is Map<String, dynamic>) {
          parsedMessages.add(CoachChatMessageModel.fromJson(item));
        }
      }
    }
    return CoachThreadModel(
      id: json['id'] as String? ?? '',
      title: json['title'] as String? ?? 'Skincare conversation',
      updatedAt: json['updatedAt'] != null
          ? DateTime.tryParse(json['updatedAt'] as String) ?? DateTime.now()
          : DateTime.now(),
      messages: parsedMessages,
    );
  }

  final String id;
  final String title;
  final DateTime updatedAt;
  final List<CoachChatMessageModel> messages;

  CoachThread toEntity() {
    return CoachThread(
      id: id,
      title: title,
      updatedAt: updatedAt,
      messages: messages.map((m) => m.toEntity()).toList(),
    );
  }

  Map<String, dynamic> toJson() => {
    'id': id,
    'title': title,
    'updatedAt': updatedAt.toIso8601String(),
    'messages': messages.map((m) => m.toJson()).toList(),
  };
}
