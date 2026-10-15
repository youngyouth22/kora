import 'package:equatable/equatable.dart';

/// Canonical gender categories for dermatological and hormonal calibration.
enum Gender {
  /// Female hormonal baseline.
  female('female'),

  /// Male hormonal baseline (higher sebum, thicker stratum corneum).
  male('male'),

  /// Other / non-binary or unstated identity.
  other('other');

  const Gender(this.code);

  /// Normalized storage code.
  final String code;

  /// Resolves [Gender] from code or display label.
  static Gender? fromCode(String? code) {
    if (code == null) return null;
    final normalized = code.trim().toLowerCase();
    return Gender.values.cast<Gender?>().firstWhere(
      (element) {
        if (element == null) return false;
        if (element.code == code || element.name.toLowerCase() == normalized) {
          return true;
        }
        switch (element) {
          case Gender.female:
            return normalized.contains('female') ||
                normalized.contains('femme') ||
                normalized.contains('mujer');
          case Gender.male:
            return normalized.contains('male') ||
                normalized.contains('homme') ||
                normalized.contains('hombre');
          case Gender.other:
            return normalized.contains('other') ||
                normalized.contains('autre') ||
                normalized.contains('otro') ||
                normalized.contains('non-binary');
        }
      },
      orElse: () => null,
    );
  }
}

/// Normalized age brackets for cellular turnover and elasticity baselines.
enum AgeBracket {
  /// Under 25 years old.
  under25('under_25'),

  /// 25 to 34 years old.
  age25To34('25_34'),

  /// 35 to 44 years old.
  age35To44('35_44'),

  /// 45 to 54 years old.
  age45To54('45_54'),

  /// 55 years old or older.
  age55Plus('55_plus');

  const AgeBracket(this.code);

  /// Normalized storage code.
  final String code;

  /// Resolves [AgeBracket] from code or display label.
  static AgeBracket? fromCode(String? code) {
    if (code == null) return null;
    final normalized = code.trim().toLowerCase();
    return AgeBracket.values.cast<AgeBracket?>().firstWhere(
      (element) {
        if (element == null) return false;
        if (element.code == code || element.name.toLowerCase() == normalized) {
          return true;
        }
        switch (element) {
          case AgeBracket.under25:
            return normalized.contains('under 25') ||
                normalized.contains('moins de 25') ||
                normalized.contains('under_25') ||
                normalized.contains('< 25');
          case AgeBracket.age25To34:
            return normalized.contains('25') && normalized.contains('34');
          case AgeBracket.age35To44:
            return normalized.contains('35') && normalized.contains('44');
          case AgeBracket.age45To54:
            return normalized.contains('45') && normalized.contains('54');
          case AgeBracket.age55Plus:
            return normalized.contains('55') ||
                normalized.contains('older') ||
                normalized.contains('plus');
        }
      },
      orElse: () => null,
    );
  }
}

/// Pure domain entity representing user demographic responses.
///
/// Contains zero framework dependencies (Flutter, Drift, Supabase, Dio)
/// strictly adhering to Clean Architecture Article 1.
class UserDemographics extends Equatable {
  /// Creates a [UserDemographics] instance.
  const UserDemographics({
    this.gender,
    this.ageRange,
    this.hasSensitiveSkin,
    this.isAnonymous = true,
    this.anonymousId,
    this.userId,
    this.createdAt,
    this.updatedAt,
  });

  /// Selected gender identifier or label.
  final String? gender;

  /// Selected age range bucket (e.g., '18-24', '25-34', '25_34').
  final String? ageRange;

  /// Whether the user self-identifies as having sensitive skin.
  final bool? hasSensitiveSkin;

  /// Whether this profile was captured anonymously before account creation.
  final bool isAnonymous;

  /// Locally generated guest UUID for anonymous tracking.
  final String? anonymousId;

  /// Authenticated user identifier (e.g. Supabase user UUID) once linked.
  final String? userId;

  /// Creation timestamp.
  final DateTime? createdAt;

  /// Last update timestamp.
  final DateTime? updatedAt;

  /// Canonical gender enum for algorithmic recommendation scoring.
  Gender? get genderEnum => Gender.fromCode(gender);

  /// Canonical age bracket enum for cellular turnover baselines.
  AgeBracket? get ageBracketEnum => AgeBracket.fromCode(ageRange);

  /// Returns true when all 3 initial demographic questions are answered.
  bool get isComplete =>
      gender != null && ageRange != null && hasSensitiveSkin != null;

  /// Creates a copy of this entity with updated fields.
  UserDemographics copyWith({
    String? gender,
    String? ageRange,
    bool? hasSensitiveSkin,
    bool? isAnonymous,
    String? anonymousId,
    String? userId,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return UserDemographics(
      gender: gender ?? this.gender,
      ageRange: ageRange ?? this.ageRange,
      hasSensitiveSkin: hasSensitiveSkin ?? this.hasSensitiveSkin,
      isAnonymous: isAnonymous ?? this.isAnonymous,
      anonymousId: anonymousId ?? this.anonymousId,
      userId: userId ?? this.userId,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }

  @override
  List<Object?> get props => [
    gender,
    ageRange,
    hasSensitiveSkin,
    isAnonymous,
    anonymousId,
    userId,
    createdAt,
    updatedAt,
  ];
}
