import 'package:kora/core/utils/typedefs.dart';
import 'package:kora/features/onboarding/domain/entities/user_demographics.dart';

/// Data model representing user demographics with JSON serialization.
class UserDemographicsModel extends UserDemographics {
  /// Creates a [UserDemographicsModel].
  const UserDemographicsModel({
    super.gender,
    super.ageRange,
    super.hasSensitiveSkin,
    super.isAnonymous = true,
    super.anonymousId,
    super.userId,
    super.createdAt,
    super.updatedAt,
  });

  /// Factory constructor to deserialize JSON into [UserDemographicsModel].
  factory UserDemographicsModel.fromJson(JsonMap json) {
    return UserDemographicsModel(
      gender: json['gender'] as String?,
      ageRange: json['age_range'] as String?,
      hasSensitiveSkin: json['has_sensitive_skin'] as bool?,
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

  /// Converts a pure domain [UserDemographics] entity to a
  /// [UserDemographicsModel].
  factory UserDemographicsModel.fromEntity(UserDemographics entity) {
    return UserDemographicsModel(
      gender: entity.gender,
      ageRange: entity.ageRange,
      hasSensitiveSkin: entity.hasSensitiveSkin,
      isAnonymous: entity.isAnonymous,
      anonymousId: entity.anonymousId,
      userId: entity.userId,
      createdAt: entity.createdAt,
      updatedAt: entity.updatedAt,
    );
  }

  /// Converts this model back to a pure domain [UserDemographics] entity.
  UserDemographics toEntity() {
    return UserDemographics(
      gender: gender,
      ageRange: ageRange,
      hasSensitiveSkin: hasSensitiveSkin,
      isAnonymous: isAnonymous,
      anonymousId: anonymousId,
      userId: userId,
      createdAt: createdAt,
      updatedAt: updatedAt,
    );
  }

  /// Serializes instance into a JSON-compatible map using canonical values.
  JsonMap toJson() {
    return {
      'gender': genderEnum?.code ?? gender,
      'age_range': ageBracketEnum?.code ?? ageRange,
      'has_sensitive_skin': hasSensitiveSkin,
      'is_anonymous': isAnonymous,
      'anonymous_id': anonymousId,
      'user_id': userId,
      'created_at': createdAt?.toIso8601String(),
      'updated_at': updatedAt?.toIso8601String(),
    };
  }
}
