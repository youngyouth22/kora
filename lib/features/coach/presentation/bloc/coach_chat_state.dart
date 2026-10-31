import 'package:equatable/equatable.dart';
import 'package:kora/core/enums/status.dart';
import 'package:kora/features/coach/domain/entities/coach_chat_entities.dart';

/// State representation for the Kora AI Coach conversation.
class CoachChatState extends Equatable {
  /// Creates a [CoachChatState].
  const CoachChatState({
    this.status = BaseStatus.initial,
    this.messages = const [],
    this.threads = const [],
    this.threadId,
    this.isBookmarked = false,
    this.hasActiveRedFlag = false,
    this.errorMessage,
  });

  /// Request lifecycle status.
  final BaseStatus status;

  /// Chronological list of messages in the active conversation.
  final List<CoachChatMessage> messages;

  /// Saved conversation history threads.
  final List<CoachThread> threads;

  /// Active conversation thread identifier.
  final String? threadId;

  /// Whether the conversation has been bookmarked by the user.
  final bool isBookmarked;

  /// Whether a high-priority red flag (medical alert) was detected.
  final bool hasActiveRedFlag;

  /// Human-readable error message upon failure.
  final String? errorMessage;

  /// Creates a modified copy of this state.
  CoachChatState copyWith({
    BaseStatus? status,
    List<CoachChatMessage>? messages,
    List<CoachThread>? threads,
    String? threadId,
    bool? isBookmarked,
    bool? hasActiveRedFlag,
    String? errorMessage,
    bool clearError = false,
  }) {
    return CoachChatState(
      status: status ?? this.status,
      messages: messages ?? this.messages,
      threads: threads ?? this.threads,
      threadId: threadId ?? this.threadId,
      isBookmarked: isBookmarked ?? this.isBookmarked,
      hasActiveRedFlag: hasActiveRedFlag ?? this.hasActiveRedFlag,
      errorMessage: clearError ? null : (errorMessage ?? this.errorMessage),
    );
  }

  @override
  List<Object?> get props => [
    status,
    messages,
    threads,
    threadId,
    isBookmarked,
    hasActiveRedFlag,
    errorMessage,
  ];
}
