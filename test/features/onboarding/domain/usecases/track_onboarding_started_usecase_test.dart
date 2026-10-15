import 'package:dartz/dartz.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:kora/core/error/failures.dart';
import 'package:kora/core/utils/typedefs.dart';
import 'package:kora/features/onboarding/domain/entities/user_demographics.dart';
import 'package:kora/features/onboarding/domain/entities/user_skin_profile.dart';
import 'package:kora/features/onboarding/domain/repositories/onboarding_repository.dart';
import 'package:kora/features/onboarding/domain/usecases/track_onboarding_started_usecase.dart';

class FakeOnboardingRepository implements OnboardingRepository {
  String? trackedSource;
  Map<String, dynamic>? trackedMetadata;
  bool shouldFail = false;

  @override
  ResultFuture<void> trackOnboardingStarted({
    required String source,
    Map<String, dynamic>? metadata,
  }) async {
    if (shouldFail) {
      return const Left(ServerFailure(message: 'Tracking error'));
    }
    trackedSource = source;
    trackedMetadata = metadata;
    return const Right(null);
  }

  @override
  ResultFuture<void> completeOnboarding() async => const Right(null);

  @override
  ResultFuture<UserDemographics?> getDemographics() async => const Right(null);

  @override
  ResultFuture<Map<int, String>> getQuizAnswers() async => const Right({});

  @override
  ResultFuture<bool> isOnboardingCompleted() async => const Right(false);

  @override
  ResultFuture<void> saveDemographics(UserDemographics demographics) async =>
      const Right(null);

  @override
  ResultFuture<void> saveQuizAnswers(Map<int, String> answers) async =>
      const Right(null);

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
  late TrackOnboardingStartedUseCase useCase;

  setUp(() {
    repository = FakeOnboardingRepository();
    useCase = TrackOnboardingStartedUseCase(repository);
  });

  test('successfully forwards tracking parameters to repository', () async {
    const params = TrackOnboardingStartedParams(
      source: 'utm_instagram',
      metadata: {'campaign': 'spring_launch'},
    );

    final result = await useCase(params);

    expect(result, const Right<Failure, void>(null));
    expect(repository.trackedSource, 'utm_instagram');
    expect(repository.trackedMetadata, {'campaign': 'spring_launch'});
  });

  test('returns ServerFailure when repository fails', () async {
    repository.shouldFail = true;
    const params = TrackOnboardingStartedParams(source: 'app_store');

    final result = await useCase(params);

    expect(result.isLeft(), isTrue);
    result.fold(
      (failure) => expect(failure.message, 'Tracking error'),
      (_) => fail('Should have failed'),
    );
  });
}
