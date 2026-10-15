import 'package:flutter_test/flutter_test.dart';
import 'package:kora/features/onboarding/data/models/user_demographics_model.dart';
import 'package:kora/features/onboarding/domain/entities/user_demographics.dart';

void main() {
  const model = UserDemographicsModel(
    gender: 'Female',
    ageRange: '25–34',
    hasSensitiveSkin: true,
    anonymousId: 'kora_guest_111',
  );

  test('is a subtype of UserDemographics entity', () {
    expect(model, isA<UserDemographics>());
  });

  test('serializes to JSON accurately with canonical codes', () {
    final json = model.toJson();

    expect(json['gender'], 'female');
    expect(json['age_range'], '25_34');
    expect(json['has_sensitive_skin'], isTrue);
    expect(json['is_anonymous'], isTrue);
    expect(json['anonymous_id'], 'kora_guest_111');
  });

  test('deserializes from JSON accurately', () {
    final json = {
      'gender': 'male',
      'age_range': '35_44',
      'has_sensitive_skin': false,
      'is_anonymous': false,
      'anonymous_id': 'kora_guest_222',
      'user_id': 'usr_supabase_333',
    };

    final result = UserDemographicsModel.fromJson(json);

    expect(result.gender, 'male');
    expect(result.ageRange, '35_44');
    expect(result.genderEnum, Gender.male);
    expect(result.ageBracketEnum, AgeBracket.age35To44);
    expect(result.hasSensitiveSkin, isFalse);
    expect(result.isAnonymous, isFalse);
    expect(result.anonymousId, 'kora_guest_222');
    expect(result.userId, 'usr_supabase_333');
    expect(result.isComplete, isTrue);
  });

  test('converts fromEntity and toEntity seamlessly', () {
    const entity = UserDemographics(
      gender: 'other',
      ageRange: 'under_25',
      hasSensitiveSkin: true,
      anonymousId: 'kora_guest_444',
    );

    final resultModel = UserDemographicsModel.fromEntity(entity);
    expect(resultModel.gender, entity.gender);
    expect(resultModel.ageRange, entity.ageRange);
    expect(resultModel.hasSensitiveSkin, entity.hasSensitiveSkin);
    expect(resultModel.isAnonymous, entity.isAnonymous);
    expect(resultModel.anonymousId, entity.anonymousId);
  });

  test(
    'Gender and AgeBracket enums parse localized and raw display labels',
    () {
      expect(Gender.fromCode('Female'), Gender.female);
      expect(Gender.fromCode('female'), Gender.female);
      expect(Gender.fromCode('Femme'), Gender.female);
      expect(Gender.fromCode('Male'), Gender.male);
      expect(Gender.fromCode('homme'), Gender.male);

      expect(AgeBracket.fromCode('Under 25'), AgeBracket.under25);
      expect(AgeBracket.fromCode('25–34'), AgeBracket.age25To34);
      expect(AgeBracket.fromCode('35–44'), AgeBracket.age35To44);
      expect(AgeBracket.fromCode('45–54'), AgeBracket.age45To54);
      expect(AgeBracket.fromCode('55 or older'), AgeBracket.age55Plus);
    },
  );
}
