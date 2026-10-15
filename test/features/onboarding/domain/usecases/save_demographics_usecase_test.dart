import 'package:dartz/dartz.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:kora/core/error/failures.dart';
import 'package:kora/core/utils/typedefs.dart';
import 'package:kora/features/onboarding/domain/entities/user_demographics.dart';
import 'package:kora/features/onboarding/domain/entities/user_skin_profile.dart';
import 'package:kora/features/onboarding/domain/repositories/onboarding_repository.dart';
import 'package:kora/features/onboarding/domain/usecases/save_demographics_usecase.dart';

class FakeOnboardingRepository implements OnboardingRepository {
  UserDemographics? savedDemographics;
  bool shouldFail = false;

  @override
  ResultFuture<void> saveDemographics(UserDemographics demographics) async {
    if (shouldFail) {
      return const Left(CacheFailure(message: 'Cache write failed'));
    }
    savedDemographics = demographics;
    return const Right(null);
  }

  @override
  ResultFuture<void> completeOnboarding() async => const Right(null);

  @override
  ResultFuture<UserDemographics?> getDemographics() async =>
      Right(savedDemographics);

  @override
  ResultFuture<Map<int, String>> getQuizAnswers() async => const Right({});

  @override
  ResultFuture<bool> isOnboardingCompleted() async => const Right(false);

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
  late SaveDemographicsUseCase useCase;

  setUp(() {
    repository = FakeOnboardingRepository();
    useCase = SaveDemographicsUseCase(repository);
  });

  test('successfully forwards demographics to repository', () async {
    const demographics = UserDemographics(
      gender: 'Female',
      ageRange: '25–34',
      hasSensitiveSkin: true,
    );

    final result = await useCase(demographics);

    expect(result, const Right<Failure, void>(null));
    expect(repository.savedDemographics, demographics);
  });

  test('returns CacheFailure when repository fails', () async {
    repository.shouldFail = true;
    const demographics = UserDemographics(gender: 'Male');

    final result = await useCase(demographics);

    expect(result.isLeft(), isTrue);
    result.fold(
      (failure) => expect(failure.message, 'Cache write failed'),
      (_) => fail('Should have failed'),
    );
  });
}
