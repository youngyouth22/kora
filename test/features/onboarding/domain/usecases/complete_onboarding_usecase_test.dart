import 'package:dartz/dartz.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:kora/core/error/failures.dart';
import 'package:kora/core/usecase/usecase.dart';
import 'package:kora/core/utils/typedefs.dart';
import 'package:kora/features/onboarding/domain/entities/user_demographics.dart';
import 'package:kora/features/onboarding/domain/entities/user_skin_profile.dart';
import 'package:kora/features/onboarding/domain/repositories/onboarding_repository.dart';
import 'package:kora/features/onboarding/domain/usecases/complete_onboarding_usecase.dart';

class FakeOnboardingRepository implements OnboardingRepository {
  bool isCompleted = false;
  bool shouldFail = false;

  @override
  ResultFuture<void> completeOnboarding() async {
    if (shouldFail) {
      return const Left(CacheFailure(message: 'Completion save error'));
    }
    isCompleted = true;
    return const Right(null);
  }

  @override
  ResultFuture<bool> isOnboardingCompleted() async => Right(isCompleted);

  @override
  ResultFuture<UserDemographics?> getDemographics() async => const Right(null);

  @override
  ResultFuture<Map<int, String>> getQuizAnswers() async => const Right({});

  @override
  ResultFuture<void> saveDemographics(UserDemographics demographics) async =>
      const Right(null);

  @override
  ResultFuture<void> saveQuizAnswers(Map<int, String> answers) async =>
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
  late CompleteOnboardingUseCase useCase;

  setUp(() {
    repository = FakeOnboardingRepository();
    useCase = CompleteOnboardingUseCase(repository);
  });

  test('successfully triggers completion on repository', () async {
    final result = await useCase(const NoParams());

    expect(result, const Right<Failure, void>(null));
    expect(repository.isCompleted, isTrue);
  });

  test('returns CacheFailure when completion fails', () async {
    repository.shouldFail = true;

    final result = await useCase(const NoParams());

    expect(result.isLeft(), isTrue);
    result.fold(
      (failure) => expect(failure.message, 'Completion save error'),
      (_) => fail('Should have failed'),
    );
  });
}
