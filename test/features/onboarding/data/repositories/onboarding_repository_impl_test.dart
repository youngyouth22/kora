import 'package:flutter_test/flutter_test.dart';
import 'package:kora/features/onboarding/data/datasources/onboarding_local_datasource.dart';
import 'package:kora/features/onboarding/data/datasources/onboarding_remote_datasource.dart';
import 'package:kora/features/onboarding/data/models/user_demographics_model.dart';
import 'package:kora/features/onboarding/data/models/user_skin_profile_model.dart';
import 'package:kora/features/onboarding/data/repositories/onboarding_repository_impl.dart';
import 'package:kora/features/onboarding/domain/entities/user_demographics.dart';
import 'package:kora/features/onboarding/domain/entities/user_skin_profile.dart';

class FailingLocalDataSource implements OnboardingLocalDataSource {
  @override
  Future<void> cacheDemographics(UserDemographicsModel demographics) =>
      throw Exception('DB error');

  @override
  Future<void> cacheQuizAnswers(Map<int, String> answers) =>
      throw Exception('DB error');

  @override
  Future<UserDemographicsModel?> getLastDemographics() =>
      throw Exception('DB error');

  @override
  Future<Map<int, String>> getQuizAnswers() => throw Exception('DB error');

  @override
  Future<bool> isOnboardingCompleted() => throw Exception('DB error');

  @override
  Future<void> setOnboardingCompleted({required bool completed}) =>
      throw Exception('DB error');

  @override
  Future<void> cacheSkinProfile(UserSkinProfileModel profile) =>
      throw Exception('DB error');

  @override
  Future<UserSkinProfileModel?> getLastSkinProfile() =>
      throw Exception('DB error');

  @override
  Future<String> getOrCreateAnonymousId() => throw Exception('DB error');

  @override
  Future<void> linkProfileToUser({required String userId}) =>
      throw Exception('DB error');
}

class FailingRemoteDataSource implements OnboardingRemoteDataSource {
  @override
  Future<void> trackEvent({
    required String eventName,
    required Map<String, dynamic> properties,
  }) => throw Exception('Network tracking error');

  @override
  Future<void> syncProfile(UserSkinProfileModel profile) =>
      throw Exception('Network tracking error');
}

void main() {
  late OnboardingLocalDataSource localDataSource;
  late OnboardingRemoteDataSource remoteDataSource;
  late OnboardingRepositoryImpl repository;

  setUp(() {
    localDataSource = OnboardingLocalDataSourceImpl();
    remoteDataSource = OnboardingRemoteDataSourceImpl();
    repository = OnboardingRepositoryImpl(
      localDataSource: localDataSource,
      remoteDataSource: remoteDataSource,
    );
  });

  group('OnboardingRepositoryImpl Happy Paths', () {
    test('trackOnboardingStarted succeeds', () async {
      final result = await repository.trackOnboardingStarted(
        source: 'app_store',
        metadata: {'utm_medium': 'cpc'},
      );

      expect(result.isRight(), isTrue);
    });

    test('saveDemographics and getDemographics round-trip', () async {
      const demographics = UserDemographics(
        gender: 'Female',
        ageRange: '25–34',
        hasSensitiveSkin: true,
      );

      final saveResult = await repository.saveDemographics(demographics);
      expect(saveResult.isRight(), isTrue);

      final getResult = await repository.getDemographics();
      expect(getResult.isRight(), isTrue);
      getResult.fold(
        (_) => fail('Should be right'),
        (data) {
          expect(data?.gender, demographics.gender);
          expect(data?.ageRange, demographics.ageRange);
          expect(data?.hasSensitiveSkin, demographics.hasSensitiveSkin);
          expect(data?.isAnonymous, isTrue);
          expect(data?.anonymousId, isNotNull);
        },
      );
    });

    test('saveQuizAnswers and getQuizAnswers round-trip', () async {
      final answers = {0: 'Option A', 1: 'Option B'};

      final saveResult = await repository.saveQuizAnswers(answers);
      expect(saveResult.isRight(), isTrue);

      final getResult = await repository.getQuizAnswers();
      expect(getResult.isRight(), isTrue);
      getResult.fold(
        (_) => fail('Should be right'),
        (saved) => expect(saved, answers),
      );
    });

    test('completeOnboarding sets completed flag', () async {
      expect(
        (await repository.isOnboardingCompleted()).getOrElse(() => false),
        isFalse,
      );

      final completeResult = await repository.completeOnboarding();
      expect(completeResult.isRight(), isTrue);

      expect(
        (await repository.isOnboardingCompleted()).getOrElse(() => false),
        isTrue,
      );
    });

    test(
      'saveSkinProfile, getSkinProfile and linkProfileToUser round-trip',
      () async {
        const profile = UserSkinProfile(
          skinTone: SkinTone.typeI,
          skinType: SkinType.oily,
          primaryGoals: [SkinGoal.acne, SkinGoal.pores],
          routineLevel: RoutineLevel.minimalist,
          testingProductStatus: TestingProductStatus.startedRecently,
          assistancePreference: AssistancePreference.tailoredBoosters,
        );

        final saveResult = await repository.saveSkinProfile(profile);
        expect(saveResult.isRight(), isTrue);

        final getResult = await repository.getSkinProfile();
        expect(getResult.isRight(), isTrue);
        getResult.fold(
          (_) => fail('Should be right'),
          (saved) {
            expect(saved, isNotNull);
            expect(saved!.skinTone, SkinTone.typeI);
            expect(saved.skinType, SkinType.oily);
            expect(saved.primaryGoals, [SkinGoal.acne, SkinGoal.pores]);
            expect(saved.isAnonymous, isTrue);
            expect(saved.anonymousId, isNotNull);
          },
        );

        final linkResult = await repository.linkProfileToUser(
          userId: 'auth_usr_999',
        );
        expect(linkResult.isRight(), isTrue);

        final getLinkedResult = await repository.getSkinProfile();
        expect(getLinkedResult.isRight(), isTrue);
        getLinkedResult.fold(
          (_) => fail('Should be right'),
          (linked) {
            expect(linked, isNotNull);
            expect(linked!.isAnonymous, isFalse);
            expect(linked.userId, 'auth_usr_999');
          },
        );
      },
    );
  });

  group('OnboardingRepositoryImpl Error Handling', () {
    test(
      'trackOnboardingStarted returns ServerFailure when remote fails',
      () async {
        final failingRepo = OnboardingRepositoryImpl(
          localDataSource: localDataSource,
          remoteDataSource: FailingRemoteDataSource(),
        );

        final result = await failingRepo.trackOnboardingStarted(
          source: 'error',
        );
        expect(result.isLeft(), isTrue);
      },
    );

    test(
      'saveDemographics returns CacheFailure when local source fails',
      () async {
        final failingRepo = OnboardingRepositoryImpl(
          localDataSource: FailingLocalDataSource(),
          remoteDataSource: remoteDataSource,
        );

        final result = await failingRepo.saveDemographics(
          const UserDemographics(gender: 'Female'),
        );
        expect(result.isLeft(), isTrue);
      },
    );
  });
}
