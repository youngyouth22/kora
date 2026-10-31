// ignore_for_file: document_ignores

import 'package:dartz/dartz.dart';
import 'package:kora/core/error/failures.dart';
import 'package:kora/features/coach/domain/entities/coach_chat_entities.dart';

/// Repository contract for interactive Kora AI Coach conversations and threads.
abstract class CoachRepository {
  /// Sends a user [message] in the given conversation [threadId] with optional
  /// [coachContext] and [history], returning the AI [CoachReply].
  Future<Either<Failure, CoachReply>> sendMessage({
    required String message,
    required String threadId,
    CoachContext? coachContext,
    List<CoachChatMessage>? history,
  });

  /// Retrieves the list of persisted conversation threads.
  Future<Either<Failure, List<CoachThread>>> getThreads();

  /// Persists or updates a conversation [thread].
  Future<Either<Failure, void>> saveThread(CoachThread thread);

  /// Deletes a conversation thread by its [threadId].
  Future<Either<Failure, void>> deleteThread(String threadId);
}
