import 'package:kora/features/onboarding/data/models/user_demographics_model.dart';
import 'package:kora/features/onboarding/domain/entities/user_demographics.dart';
import 'package:kora/features/onboarding/domain/entities/user_skin_profile.dart';

/// Data model representing [UserSkinProfile] with JSON serialization.
///
/// Converts between normalized persistence formats and domain entities.
class UserSkinProfileModel extends UserSkinProfile {
  /// Creates a [UserSkinProfileModel].
  const UserSkinProfileModel({
    super.demographics,
    super.skinTone,
    super.skinType,
    super.primaryGoals = const [],
    super.routineLevel,
    super.testingProductStatus,
    super.assistancePreference,
    super.isAnonymous = true,
    super.anonymousId,
    super.userId,
    super.createdAt,
    super.updatedAt,
  });

  /// Creates a [UserSkinProfileModel] from a domain [UserSkinProfile] entity.
  factory UserSkinProfileModel.fromEntity(UserSkinProfile entity) {
    return UserSkinProfileModel(
      demographics: entity.demographics,
      skinTone: entity.skinTone,
      skinType: entity.skinType,
      primaryGoals: entity.primaryGoals,
      routineLevel: entity.routineLevel,
      testingProductStatus: entity.testingProductStatus,
      assistancePreference: entity.assistancePreference,
      isAnonymous: entity.isAnonymous,
      anonymousId: entity.anonymousId,
      userId: entity.userId,
      createdAt: entity.createdAt,
      updatedAt: entity.updatedAt,
    );
  }

  /// Deserializes a [UserSkinProfileModel] from a JSON map.
  factory UserSkinProfileModel.fromJson(Map<String, dynamic> json) {
    final rawGoals = json['primary_goals'];
    final goals = <SkinGoal>[];
    if (rawGoals is List) {
      goals.addAll(
        rawGoals
            .map((e) => SkinGoal.fromCode(e?.toString()))
            .whereType<SkinGoal>(),
      );
    }

    final rawDemographics = json['demographics'];
    UserDemographicsModel? demographicsModel;
    if (rawDemographics is Map<String, dynamic>) {
      demographicsModel = UserDemographicsModel.fromJson(rawDemographics);
    }

    return UserSkinProfileModel(
      demographics: demographicsModel,
      skinTone: SkinTone.fromCode(json['skin_tone'] as String?),
      skinType: SkinType.fromCode(json['skin_type'] as String?),
      primaryGoals: goals,
      routineLevel: RoutineLevel.fromCode(json['routine_level'] as String?),
      testingProductStatus: TestingProductStatus.fromCode(
        json['testing_product_status'] as String?,
      ),
      assistancePreference: AssistancePreference.fromCode(
        json['assistance_preference'] as String?,
      ),
      isAnonymous: json['is_anonymous'] as bool? ?? true,
      anonymousId: json['anonymous_id'] as String?,
      userId: json['user_id'] as String?,
      createdAt: json['created_at'] != null
          ? DateTime.tryParse(json['created_at'] as String)
          : null,
      updatedAt: json['updated_at'] != null
          ? DateTime.tryParse(json['updated_at'] as String)
          : null,
    );
  }

  /// Constructs a [UserSkinProfileModel] from raw quiz answers map (0 to 5),
  /// optional [demographics], and IDs.
  factory UserSkinProfileModel.fromQuizAnswers({
    required Map<int, String> answers,
    UserDemographics? demographics,
    String? anonymousId,
    String? userId,
  }) {
    // Step 0: Skin tone
    final rawTone = answers[0];
    final tone = SkinTone.fromCode(rawTone);

    // Step 1: Skin type
    final rawType = answers[1];
    final type = SkinType.fromCode(rawType);

    // Step 2: Primary skin goals (multi-select, comma separated)
    final rawGoals = answers[2] ?? '';
    final goals = rawGoals
        .split(',')
        .map((e) => e.trim())
        .where((e) => e.isNotEmpty)
        .map(SkinGoal.fromCode)
        .whereType<SkinGoal>()
        .toList();

    // Step 3: Current routine level
    final rawRoutine = answers[3];
    final routine = RoutineLevel.fromCode(rawRoutine);

    // Step 4: Testing new product
    final rawTesting = answers[4];
    final testing = TestingProductStatus.fromCode(rawTesting);

    // Step 5: Tailored skincare assistance preference
    final rawAssistance = answers[5];
    final assistance = AssistancePreference.fromCode(rawAssistance);

    final now = DateTime.now();

    return UserSkinProfileModel(
      demographics: demographics,
      skinTone: tone,
      skinType: type,
      primaryGoals: goals,
      routineLevel: routine,
      testingProductStatus: testing,
      assistancePreference: assistance,
      isAnonymous: userId == null || userId.isEmpty,
      anonymousId: anonymousId,
      userId: userId,
      createdAt: now,
      updatedAt: now,
    );
  }

  /// Serializes this model into a JSON map.
  Map<String, dynamic> toJson() {
    return {
      'demographics': demographics != null
          ? UserDemographicsModel.fromEntity(demographics!).toJson()
          : null,
      'skin_tone': skinTone?.code,
      'skin_type': skinType?.code,
      'primary_goals': primaryGoals.map((g) => g.code).toList(),
      'routine_level': routineLevel?.code,
      'testing_product_status': testingProductStatus?.code,
      'assistance_preference': assistancePreference?.code,
      'is_anonymous': isAnonymous,
      'anonymous_id': anonymousId,
      'user_id': userId,
      'created_at': createdAt?.toIso8601String(),
      'updated_at': updatedAt?.toIso8601String(),
    };
  }

  /// Converts this model to a pure domain [UserSkinProfile] entity.
  UserSkinProfile toEntity() {
    return UserSkinProfile(
      demographics: demographics,
      skinTone: skinTone,
      skinType: skinType,
      primaryGoals: primaryGoals,
      routineLevel: routineLevel,
      testingProductStatus: testingProductStatus,
      assistancePreference: assistancePreference,
      isAnonymous: isAnonymous,
      anonymousId: anonymousId,
      userId: userId,
      createdAt: createdAt,
      updatedAt: updatedAt,
    );
  }
}
