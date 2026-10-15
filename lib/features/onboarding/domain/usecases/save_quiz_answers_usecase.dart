import 'package:kora/core/usecase/usecase.dart';
import 'package:kora/core/utils/typedefs.dart';
import 'package:kora/features/onboarding/domain/repositories/onboarding_repository.dart';

/// Use case that persists questionnaire answers.
class SaveQuizAnswersUseCase implements UseCase<void, Map<int, String>> {
  /// Creates the use case.
  const SaveQuizAnswersUseCase(this._repository);

  final OnboardingRepository _repository;

  @override
  ResultFuture<void> call(Map<int, String> params) {
    return _repository.saveQuizAnswers(params);
  }
}
