import 'package:flutter_test/flutter_test.dart';
import 'package:kora/features/onboarding/data/models/user_skin_profile_model.dart';
import 'package:kora/features/onboarding/domain/entities/user_demographics.dart';
import 'package:kora/features/onboarding/domain/entities/user_skin_profile.dart';

void main() {
  group('UserSkinProfileModel', () {
    const testProfile = UserSkinProfileModel(
      demographics: UserDemographics(
        gender: 'female',
        ageRange: '25_34',
        hasSensitiveSkin: true,
      ),
      skinTone: SkinTone.typeI,
      skinType: SkinType.oily,
      primaryGoals: [SkinGoal.acne, SkinGoal.darkSpots],
      routineLevel: RoutineLevel.minimalist,
      testingProductStatus: TestingProductStatus.startedRecently,
      assistancePreference: AssistancePreference.tailoredBoosters,
      anonymousId: 'kora_guest_123',
    );

    test('is a subtype of UserSkinProfile entity', () {
      expect(testProfile, isA<UserSkinProfile>());
    });

    test('serializes to JSON using canonical code values', () {
      final json = testProfile.toJson();

      expect(json['demographics'], isNotNull);
      expect(json['skin_tone'], 'type_1');
      expect(json['skin_type'], 'oily');
      expect(json['primary_goals'], ['acne', 'dark_spots']);
      expect(json['routine_level'], 'minimalist');
      expect(json['testing_product_status'], 'started_recently');
      expect(json['assistance_preference'], 'tailored_boosters');
      expect(json['is_anonymous'], isTrue);
      expect(json['anonymous_id'], 'kora_guest_123');
      expect(json['user_id'], isNull);
    });

    test('deserializes from JSON accurately', () {
      final json = {
        'demographics': {
          'gender': 'male',
          'age_range': '35_44',
          'has_sensitive_skin': false,
        },
        'skin_tone': 'type_3',
        'skin_type': 'combination',
        'primary_goals': ['redness', 'fine_lines'],
        'routine_level': 'moderate',
        'testing_product_status': 'planning_soon',
        'assistance_preference': 'alert_on_decline',
        'is_anonymous': false,
        'anonymous_id': 'kora_guest_999',
        'user_id': 'auth_user_456',
        'created_at': '2026-10-15T12:00:00.000Z',
        'updated_at': '2026-10-15T12:00:00.000Z',
      };

      final model = UserSkinProfileModel.fromJson(json);

      expect(model.demographics, isNotNull);
      expect(model.demographics?.gender, 'male');
      expect(model.demographics?.genderEnum, Gender.male);
      expect(model.demographics?.ageBracketEnum, AgeBracket.age35To44);
      expect(model.skinTone, SkinTone.typeIII);
      expect(model.skinType, SkinType.combination);
      expect(model.primaryGoals, [SkinGoal.redness, SkinGoal.fineLines]);
      expect(model.routineLevel, RoutineLevel.moderate);
      expect(model.testingProductStatus, TestingProductStatus.planningSoon);
      expect(model.assistancePreference, AssistancePreference.alertOnDecline);
      expect(model.isAnonymous, isFalse);
      expect(model.anonymousId, 'kora_guest_999');
      expect(model.userId, 'auth_user_456');
    });

    test(
      'fromQuizAnswers maps human UI display labels to normalized domain enums',
      () {
        final quizAnswers = {
          0: 'Very Fair',
          1: 'Dry',
          2: 'Acne & blemishes, Uneven skin texture',
          3: 'Advanced (5+ products)',
          4: 'No, testing routine stability',
          5: 'No, track my current routine only',
        };

        final profile = UserSkinProfileModel.fromQuizAnswers(
          answers: quizAnswers,
          anonymousId: 'kora_guest_abc',
        );

        expect(profile.skinTone, SkinTone.typeI);
        expect(profile.skinType, SkinType.dry);
        expect(profile.primaryGoals, [SkinGoal.acne, SkinGoal.unevenTexture]);
        expect(profile.routineLevel, RoutineLevel.advanced);
        expect(
          profile.testingProductStatus,
          TestingProductStatus.routineStability,
        );
        expect(
          profile.assistancePreference,
          AssistancePreference.trackRoutineOnly,
        );
        expect(profile.isAnonymous, isTrue);
        expect(profile.anonymousId, 'kora_guest_abc');
      },
    );

    test('toEntity and fromEntity convert losslessly', () {
      final entity = testProfile.toEntity();
      final reconverted = UserSkinProfileModel.fromEntity(entity);

      expect(reconverted.skinTone, testProfile.skinTone);
      expect(reconverted.skinType, testProfile.skinType);
      expect(reconverted.primaryGoals, testProfile.primaryGoals);
      expect(reconverted.routineLevel, testProfile.routineLevel);
      expect(reconverted.isAnonymous, testProfile.isAnonymous);
      expect(reconverted.anonymousId, testProfile.anonymousId);
    });
  });
}
