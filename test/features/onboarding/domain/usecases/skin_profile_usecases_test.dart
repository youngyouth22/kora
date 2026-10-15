import 'package:dartz/dartz.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:kora/core/usecase/usecase.dart';
import 'package:kora/core/utils/typedefs.dart';
import 'package:kora/features/onboarding/domain/entities/user_demographics.dart';
import 'package:kora/features/onboarding/domain/entities/user_skin_profile.dart';
import 'package:kora/features/onboarding/domain/repositories/onboarding_repository.dart';
import 'package:kora/features/onboarding/domain/usecases/get_skin_profile_usecase.dart';
import 'package:kora/features/onboarding/domain/usecases/link_user_account_usecase.dart';
import 'package:kora/features/onboarding/domain/usecases/save_skin_profile_usecase.dart';

class MockSkinProfileRepository implements OnboardingRepository {
  UserSkinProfile? cachedProfile;
  String? linkedUserId;

  @override
  ResultFuture<void> saveSkinProfile(UserSkinProfile profile) async {
    cachedProfile = profile;
    return const Right(null);
  }

  @override
  ResultFuture<UserSkinProfile?> getSkinProfile() async {
    return Right(cachedProfile);
  }

  @override
  ResultFuture<void> linkProfileToUser({required String userId}) async {
    linkedUserId = userId;
    if (cachedProfile != null) {
      cachedProfile = UserSkinProfile(
        skinTone: cachedProfile!.skinTone,
        skinType: cachedProfile!.skinType,
        primaryGoals: cachedProfile!.primaryGoals,
        routineLevel: cachedProfile!.routineLevel,
        testingProductStatus: cachedProfile!.testingProductStatus,
        assistancePreference: cachedProfile!.assistancePreference,
        isAnonymous: false,
        anonymousId: cachedProfile!.anonymousId,
        userId: userId,
      );
    }
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
  ResultFuture<void> trackOnboardingStarted({
    required String source,
    Map<String, dynamic>? metadata,
  }) async => const Right(null);
}

void main() {
  late MockSkinProfileRepository repository;
  late SaveSkinProfileUseCase saveUseCase;
  late GetSkinProfileUseCase getUseCase;
  late LinkUserAccountUseCase linkUseCase;

  setUp(() {
    repository = MockSkinProfileRepository();
    saveUseCase = SaveSkinProfileUseCase(repository);
    getUseCase = GetSkinProfileUseCase(repository);
    linkUseCase = LinkUserAccountUseCase(repository);
  });

  const testProfile = UserSkinProfile(
    skinTone: SkinTone.typeII,
    skinType: SkinType.oily,
    primaryGoals: [SkinGoal.acne],
    routineLevel: RoutineLevel.moderate,
    testingProductStatus: TestingProductStatus.planningSoon,
    assistancePreference: AssistancePreference.tailoredBoosters,
    anonymousId: 'kora_guest_555',
  );

  test('SaveSkinProfileUseCase saves profile to repository', () async {
    final result = await saveUseCase(testProfile);

    expect(result.isRight(), isTrue);
    expect(repository.cachedProfile, testProfile);
  });

  test('GetSkinProfileUseCase returns saved profile from repository', () async {
    await saveUseCase(testProfile);
    final result = await getUseCase(const NoParams());

    expect(result.isRight(), isTrue);
    result.fold(
      (_) => fail('Should be right'),
      (profile) => expect(profile, testProfile),
    );
  });

  test(
    'LinkUserAccountUseCase links anonymous profile to authenticated user',
    () async {
      await saveUseCase(testProfile);
      final linkResult = await linkUseCase('usr_authenticated_777');

      expect(linkResult.isRight(), isTrue);
      expect(repository.linkedUserId, 'usr_authenticated_777');

      final updatedProfileResult = await getUseCase(const NoParams());
      updatedProfileResult.fold(
        (_) => fail('Should be right'),
        (profile) {
          expect(profile?.isAnonymous, isFalse);
          expect(profile?.userId, 'usr_authenticated_777');
          expect(profile?.anonymousId, 'kora_guest_555');
        },
      );
    },
  );
}
