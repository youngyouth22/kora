import 'package:dartz/dartz.dart';
import 'package:kora/core/error/failures.dart';
import 'package:kora/core/usecase/usecase.dart';
import 'package:kora/features/coach/domain/entities/coach_chat_entities.dart';
import 'package:kora/features/coach/domain/repositories/coach_repository.dart';

/// Use case to save or update a conversation thread.
class SaveCoachThreadUseCase implements UseCase<void, CoachThread> {
  /// Creates a [SaveCoachThreadUseCase].
  const SaveCoachThreadUseCase(this._repository);

  final CoachRepository _repository;

  @override
  Future<Either<Failure, void>> call(CoachThread thread) {
    return _repository.saveThread(thread);
  }
}
