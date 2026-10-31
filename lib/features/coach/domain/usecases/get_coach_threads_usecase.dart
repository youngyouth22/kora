import 'package:dartz/dartz.dart';
import 'package:kora/core/error/failures.dart';
import 'package:kora/core/usecase/usecase.dart';
import 'package:kora/features/coach/domain/entities/coach_chat_entities.dart';
import 'package:kora/features/coach/domain/repositories/coach_repository.dart';

/// Use case to load all saved conversation threads.
class GetCoachThreadsUseCase implements UseCase<List<CoachThread>, NoParams> {
  /// Creates a [GetCoachThreadsUseCase].
  const GetCoachThreadsUseCase(this._repository);

  final CoachRepository _repository;

  @override
  Future<Either<Failure, List<CoachThread>>> call(NoParams params) {
    return _repository.getThreads();
  }
}
