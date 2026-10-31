import 'package:dartz/dartz.dart';
import 'package:kora/core/error/failures.dart';
import 'package:kora/core/usecase/usecase.dart';
import 'package:kora/features/coach/domain/repositories/coach_repository.dart';

/// Use case to delete a conversation thread by ID.
class DeleteCoachThreadUseCase implements UseCase<void, String> {
  /// Creates a [DeleteCoachThreadUseCase].
  const DeleteCoachThreadUseCase(this._repository);

  final CoachRepository _repository;

  @override
  Future<Either<Failure, void>> call(String threadId) {
    return _repository.deleteThread(threadId);
  }
}
