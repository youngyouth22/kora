import 'package:dartz/dartz.dart';
import 'package:equatable/equatable.dart';
import 'package:kora/core/error/failures.dart';
import 'package:kora/core/usecase/usecase.dart';
import 'package:kora/features/coach/domain/entities/coach_chat_entities.dart';
import 'package:kora/features/coach/domain/repositories/coach_repository.dart';

/// Use case for sending a message to the Kora AI Skin Coach.
class SendCoachMessageUseCase
    implements UseCase<CoachReply, SendCoachMessageParams> {
  /// Creates a [SendCoachMessageUseCase].
  const SendCoachMessageUseCase(this._repository);

  final CoachRepository _repository;

  @override
  Future<Either<Failure, CoachReply>> call(SendCoachMessageParams params) {
    return _repository.sendMessage(
      message: params.message,
      threadId: params.threadId,
      coachContext: params.coachContext,
      history: params.history,
    );
  }
}

/// Parameters for [SendCoachMessageUseCase].
class SendCoachMessageParams extends Equatable {
  /// Creates [SendCoachMessageParams].
  const SendCoachMessageParams({
    required this.message,
    required this.threadId,
    this.coachContext,
    this.history,
  });

  /// User question or message text.
  final String message;

  /// Persistent conversation thread identifier.
  final String threadId;

  /// Optional skin scan and experiment context.
  final CoachContext? coachContext;

  /// Optional prior chat conversation history.
  final List<CoachChatMessage>? history;

  @override
  List<Object?> get props => [message, threadId, coachContext, history];
}
