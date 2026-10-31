// ignore_for_file: document_ignores, lines_longer_than_80_chars

import 'package:equatable/equatable.dart';

/// Represents a single message in the Kora AI Coach conversation.
class CoachChatMessage extends Equatable {
  /// Creates a [CoachChatMessage].
  const CoachChatMessage({
    required this.id,
    required this.text,
    required this.isUser,
    required this.createdAt,
    this.isRedFlag = false,
    this.suggestedAction,
  });

  /// Unique message identifier.
  final String id;

  /// Message body text (supports Markdown formatting).
  final String text;

  /// Whether this message was authored by the user (`true`) or Kora (`false`).
  final bool isUser;

  /// Timestamp when the message was created.
  final DateTime createdAt;

  /// Whether the backend safety gate flagged an urgent medical red flag.
  final bool isRedFlag;

  /// Optional concrete action pill suggested by the AI Coach.
  final CoachSuggestedAction? suggestedAction;

  @override
  List<Object?> get props => [
    id,
    text,
    isUser,
    createdAt,
    isRedFlag,
    suggestedAction,
  ];
}

/// Concrete CTA action suggested by the Kora AI Coach.
class CoachSuggestedAction extends Equatable {
  /// Creates a [CoachSuggestedAction].
  const CoachSuggestedAction({
    required this.type,
    required this.label,
    this.payload = const {},
  });

  /// Action type identifier (e.g. `'log_scan'`, `'view_experiment'`, `'routine'`).
  final String type;

  /// Button label displayed in the chat bubble.
  final String label;

  /// Optional structured parameters for executing the action.
  final Map<String, dynamic> payload;

  @override
  List<Object?> get props => [type, label, payload];
}

/// Contextual skin & experiment telemetry sent alongside a user chat message.
class CoachContext extends Equatable {
  /// Creates a [CoachContext].
  const CoachContext({
    this.lastScanDate,
    this.activeExperiment,
    this.currentConcern,
  });

  /// ISO-8601 date string of the user's most recent scan.
  final String? lastScanDate;

  /// Summary of the currently active skincare experiment, if any.
  final String? activeExperiment;

  /// Primary skin concern currently tracked.
  final String? currentConcern;

  /// Serializes to JSON map.
  Map<String, dynamic> toJson() => {
    if (lastScanDate != null) 'lastScanDate': lastScanDate,
    if (activeExperiment != null) 'activeExperiment': activeExperiment,
    if (currentConcern != null) 'currentConcern': currentConcern,
  };

  @override
  List<Object?> get props => [lastScanDate, activeExperiment, currentConcern];
}

/// Pure domain entity representing the AI Coach response from `POST /api/coach/chat`.
class CoachReply extends Equatable {
  /// Creates a [CoachReply].
  const CoachReply({
    required this.text,
    this.isRedFlag = false,
    this.suggestedAction,
  });

  /// Assistant reply text.
  final String text;

  /// True when an urgent medical symptom was detected and short-circuited.
  final bool isRedFlag;

  /// Optional follow-up action button.
  final CoachSuggestedAction? suggestedAction;

  @override
  List<Object?> get props => [text, isRedFlag, suggestedAction];
}

/// Represents a persistent conversation thread with the Kora AI Coach.
class CoachThread extends Equatable {
  /// Creates a [CoachThread].
  const CoachThread({
    required this.id,
    required this.title,
    required this.updatedAt,
    this.messages = const [],
  });

  /// Unique thread identifier.
  final String id;

  /// Human-readable title of the conversation.
  final String title;

  /// Timestamp when the conversation was last updated.
  final DateTime updatedAt;

  /// Messages exchanged in this thread.
  final List<CoachChatMessage> messages;

  /// Creates a copy of this thread with optional modifications.
  CoachThread copyWith({
    String? id,
    String? title,
    DateTime? updatedAt,
    List<CoachChatMessage>? messages,
  }) {
    return CoachThread(
      id: id ?? this.id,
      title: title ?? this.title,
      updatedAt: updatedAt ?? this.updatedAt,
      messages: messages ?? this.messages,
    );
  }

  @override
  List<Object?> get props => [id, title, updatedAt, messages];
}
