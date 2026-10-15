import 'package:dartz/dartz.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:kora/core/error/failures.dart';
import 'package:kora/core/utils/typedefs.dart';
import 'package:kora/features/onboarding/domain/entities/user_demographics.dart';
import 'package:kora/features/onboarding/domain/entities/user_skin_profile.dart';
import 'package:kora/features/onboarding/domain/repositories/onboarding_repository.dart';
import 'package:kora/features/onboarding/domain/usecases/save_quiz_answers_usecase.dart';

class FakeOnboardingRepository implements OnboardingRepository {
  Map<int, String>? savedAnswers;
  bool shouldFail = false;

  @override
  ResultFuture<void> saveQuizAnswers(Map<int, String> answers) async {
    if (shouldFail) {
      return const Left(CacheFailure(message: 'Quiz save error'));
    }
    savedAnswers = answers;
    return const Right(null);
  }

  @override
  ResultFuture<void> completeOnboarding() async => const Right(null);

  @override
  ResultFuture<UserDemographics?> getDemographics() async => const Right(null);

  @override
  ResultFuture<Map<int, String>> getQuizAnswers() async =>
      Right(savedAnswers ?? {});

  @override
  ResultFuture<bool> isOnboardingCompleted() async => const Right(false);

  @override
  ResultFuture<void> saveDemographics(UserDemographics demographics) async =>
      const Right(null);

  @override
  ResultFuture<void> trackOnboardingStarted({
    required String source,
    Map<String, dynamic>? metadata,
  }) async => const Right(null);

  @override
  ResultFuture<void> saveSkinProfile(UserSkinProfile profile) async =>
      const Right(null);

  @override
  ResultFuture<UserSkinProfile?> getSkinProfile() async => const Right(null);

  @override
  ResultFuture<void> linkProfileToUser({required String userId}) async =>
      const Right(null);
}

void main() {
  late FakeOnboardingRepository repository;
  late SaveQuizAnswersUseCase useCase;

  setUp(() {
    repository = FakeOnboardingRepository();
    useCase = SaveQuizAnswersUseCase(repository);
  });

  test('successfully forwards quiz answers to repository', () async {
    final answers = {0: 'Clear blemishes', 1: 'Combination skin'};

    final result = await useCase(answers);

    expect(result, const Right<Failure, void>(null));
    expect(repository.savedAnswers, answers);
  });

  test('returns CacheFailure when repository fails', () async {
    repository.shouldFail = true;
    final answers = {0: 'Clear blemishes'};

    final result = await useCase(answers);

    expect(result.isLeft(), isTrue);
    result.fold(
      (failure) => expect(failure.message, 'Quiz save error'),
      (_) => fail('Should have failed'),
    );
  });
}
