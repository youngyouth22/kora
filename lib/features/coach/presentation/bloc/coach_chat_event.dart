import 'package:equatable/equatable.dart';
import 'package:kora/features/coach/domain/entities/coach_chat_entities.dart';

/// Base event class for Kora AI Skin Coach conversation flows.
sealed class CoachChatEvent extends Equatable {
  const CoachChatEvent();

  @override
  List<Object?> get props => [];
}

/// Triggers initialisation of the conversation and loads past conversation
/// threads.
final class CoachChatStartedEvent extends CoachChatEvent {
  /// Creates a [CoachChatStartedEvent].
  const CoachChatStartedEvent({
    this.initialQuestion,
    this.threadId,
    this.forceNewThread = false,
  });

  /// Optional initial user question to send automatically.
  final String? initialQuestion;

  /// Optional specific thread ID to open.
  final String? threadId;

  /// Whether to force the creation of a brand new thread.
  final bool forceNewThread;

  @override
  List<Object?> get props => [initialQuestion, threadId, forceNewThread];
}

/// Dispatches an event to reload the list of saved conversation threads.
final class CoachThreadsLoadedEvent extends CoachChatEvent {
  /// Creates a [CoachThreadsLoadedEvent].
  const CoachThreadsLoadedEvent();
}

/// Selects an existing conversation thread from history.
final class CoachThreadSelectedEvent extends CoachChatEvent {
  /// Creates a [CoachThreadSelectedEvent].
  const CoachThreadSelectedEvent(this.threadId);

  /// ID of the thread to open.
  final String threadId;

  @override
  List<Object?> get props => [threadId];
}

/// Deletes an existing conversation thread from history.
final class CoachThreadDeletedEvent extends CoachChatEvent {
  /// Creates a [CoachThreadDeletedEvent].
  const CoachThreadDeletedEvent(this.threadId);

  /// ID of the thread to delete.
  final String threadId;

  @override
  List<Object?> get props => [threadId];
}

/// Starts a new blank conversation session.
final class CoachNewChatStartedEvent extends CoachChatEvent {
  /// Creates a [CoachNewChatStartedEvent].
  const CoachNewChatStartedEvent({this.initialQuestion});

  /// Optional prompt to immediately ask in the new conversation.
  final String? initialQuestion;

  @override
  List<Object?> get props => [initialQuestion];
}

/// Dispatches a user query to the AI Coach.
final class CoachMessageSentEvent extends CoachChatEvent {
  /// Creates a [CoachMessageSentEvent].
  const CoachMessageSentEvent(this.text, {this.coachContext});

  /// The text content of the message.
  final String text;

  /// Optional contextual skin telemetry.
  final CoachContext? coachContext;

  @override
  List<Object?> get props => [text, coachContext];
}

/// Toggles user bookmark on the current conversation.
final class CoachBookmarkToggledEvent extends CoachChatEvent {
  /// Creates a [CoachBookmarkToggledEvent].
  const CoachBookmarkToggledEvent();
}
