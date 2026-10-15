import 'package:equatable/equatable.dart';
import 'package:kora/features/onboarding/domain/entities/user_demographics.dart';

/// Fitzpatrick phototypes for skin tone classification.
///
/// Language-agnostic canonical representation used for AI algorithms and image
/// analysis.
enum SkinTone {
  /// Type I: Very fair, always burns easily, never tans.
  typeI('type_1'),

  /// Type II: Fair, burns easily, tans minimally.
  typeII('type_2'),

  /// Type III: Medium, burns moderately, tans gradually.
  typeIII('type_3'),

  /// Type IV: Olive, burns minimally, tans easily.
  typeIV('type_4'),

  /// Type V: Brown, rarely burns, tans profusely.
  typeV('type_5'),

  /// Type VI: Dark brown / deeply pigmented, almost never burns.
  typeVI('type_6');

  const SkinTone(this.code);

  /// Normalized storage code.
  final String code;

  /// Resolves [SkinTone] from stored code or returns null.
  static SkinTone? fromCode(String? code) {
    if (code == null) return null;
    final normalized = code.trim().toLowerCase();
    return SkinTone.values.cast<SkinTone?>().firstWhere(
      (element) {
        if (element == null) return false;
        if (element.code == code || element.name.toLowerCase() == normalized) {
          return true;
        }
        // Match display names
        switch (element) {
          case SkinTone.typeI:
            return normalized.contains('very fair') ||
                normalized.contains('type i');
          case SkinTone.typeII:
            return (normalized.contains('fair') &&
                    !normalized.contains('very')) ||
                normalized.contains('type ii');
          case SkinTone.typeIII:
            return normalized.contains('medium') ||
                normalized.contains('type iii');
          case SkinTone.typeIV:
            return normalized.contains('olive') ||
                normalized.contains('type iv');
          case SkinTone.typeV:
            return (normalized.contains('brown') &&
                    !normalized.contains('dark')) ||
                normalized.contains('type v');
          case SkinTone.typeVI:
            return normalized.contains('dark brown') ||
                normalized.contains('deep') ||
                normalized.contains('type vi');
        }
      },
      orElse: () => null,
    );
  }
}

/// Baseline skin type categories based on sebum and hydration balance.
enum SkinType {
  /// Excess sebum production throughout face.
  oily('oily'),

  /// Low sebum, lacks moisture, flaky or tight.
  dry('dry'),

  /// Oily T-zone with balanced or dry cheeks.
  combination('combination'),

  /// Well balanced moisture and oil.
  normal('normal'),

  /// Unsure, to be calibrated via scan imagery baseline.
  unknown('unknown');

  const SkinType(this.code);

  /// Normalized storage code.
  final String code;

  /// Resolves [SkinType] from stored code or returns null.
  static SkinType? fromCode(String? code) {
    if (code == null) return null;
    final normalized = code.trim().toLowerCase();
    return SkinType.values.cast<SkinType?>().firstWhere(
      (element) {
        if (element == null) return false;
        if (element.code == code || element.name.toLowerCase() == normalized) {
          return true;
        }
        switch (element) {
          case SkinType.oily:
            return normalized.contains('oily');
          case SkinType.dry:
            return normalized.contains('dry');
          case SkinType.combination:
            return normalized.contains('combination');
          case SkinType.normal:
            return normalized.contains('normal');
          case SkinType.unknown:
            return normalized.contains('sure') ||
                normalized.contains('calibrate');
        }
      },
      orElse: () => null,
    );
  }
}

/// Target concerns and primary goals for routines and skin scans.
enum SkinGoal {
  /// Acne and active blemishes.
  acne('acne'),

  /// Hyperpigmentation, melasma, or dark spots.
  darkSpots('dark_spots'),

  /// Redness, flushing, or sensitivity.
  redness('redness'),

  /// Enlarged pores and blackheads.
  pores('pores'),

  /// Fine lines and loss of elasticity.
  fineLines('fine_lines'),

  /// Crow's feet and peri-orbital concern.
  crowFeet('crow_feet'),

  /// Dehydration, dull complexion, lack of glow.
  dehydration('dehydration'),

  /// Rough or uneven skin surface.
  unevenTexture('uneven_texture');

  const SkinGoal(this.code);

  /// Normalized storage code.
  final String code;

  /// Resolves [SkinGoal] from stored code or returns null.
  static SkinGoal? fromCode(String? code) {
    if (code == null) return null;
    final normalized = code.trim().toLowerCase();
    return SkinGoal.values.cast<SkinGoal?>().firstWhere(
      (element) {
        if (element == null) return false;
        if (element.code == code || element.name.toLowerCase() == normalized) {
          return true;
        }
        switch (element) {
          case SkinGoal.acne:
            return normalized.contains('acne') ||
                normalized.contains('blemish');
          case SkinGoal.darkSpots:
            return normalized.contains('dark') ||
                normalized.contains('spot') ||
                normalized.contains('pigment');
          case SkinGoal.redness:
            return normalized.contains('redness') ||
                normalized.contains('sensitiv');
          case SkinGoal.pores:
            return normalized.contains('pore');
          case SkinGoal.fineLines:
            return normalized.contains('wrinkle') ||
                normalized.contains('fine line');
          case SkinGoal.crowFeet:
            return normalized.contains('crow') || normalized.contains('eye');
          case SkinGoal.dehydration:
            return normalized.contains('hydrat') || normalized.contains('dull');
          case SkinGoal.unevenTexture:
            return normalized.contains('texture');
        }
      },
      orElse: () => null,
    );
  }
}

/// Self-reported routine complexity level.
enum RoutineLevel {
  /// Minimalist: 1–2 products (cleanser, moisturizer, SPF).
  minimalist('minimalist'),

  /// Moderate: 3–4 products (cleanser, toner, serum, cream).
  moderate('moderate'),

  /// Advanced: 5+ products with layered actives.
  advanced('advanced'),

  /// Irregular or starting from zero.
  irregular('irregular');

  const RoutineLevel(this.code);

  /// Normalized storage code.
  final String code;

  /// Resolves [RoutineLevel] from stored code or returns null.
  static RoutineLevel? fromCode(String? code) {
    if (code == null) return null;
    final normalized = code.trim().toLowerCase();
    return RoutineLevel.values.cast<RoutineLevel?>().firstWhere(
      (element) {
        if (element == null) return false;
        if (element.code == code || element.name.toLowerCase() == normalized) {
          return true;
        }
        switch (element) {
          case RoutineLevel.minimalist:
            return normalized.contains('minimalist') ||
                normalized.contains('1–2');
          case RoutineLevel.moderate:
            return normalized.contains('moderate') ||
                normalized.contains('3–4');
          case RoutineLevel.advanced:
            return normalized.contains('advanced') || normalized.contains('5+');
          case RoutineLevel.irregular:
            return normalized.contains('irregular') ||
                normalized.contains('none') ||
                normalized.contains('fresh');
        }
      },
      orElse: () => null,
    );
  }
}

/// Status of new product introduction for Kora Experiments.
enum TestingProductStatus {
  /// Product introduced in the last 2 weeks, ready for experiment tracking.
  startedRecently('started_recently'),

  /// Intends to add an active soon, setup baseline experiment first.
  planningSoon('planning_soon'),

  /// No new item, focus on tracking routine stability.
  routineStability('routine_stability');

  const TestingProductStatus(this.code);

  /// Normalized storage code.
  final String code;

  /// Resolves [TestingProductStatus] from stored code or returns null.
  static TestingProductStatus? fromCode(String? code) {
    if (code == null) return null;
    final normalized = code.trim().toLowerCase();
    return TestingProductStatus.values.cast<TestingProductStatus?>().firstWhere(
      (element) {
        if (element == null) return false;
        if (element.code == code || element.name.toLowerCase() == normalized) {
          return true;
        }
        switch (element) {
          case TestingProductStatus.startedRecently:
            return normalized.contains('started') ||
                normalized.contains('last 2 weeks');
          case TestingProductStatus.planningSoon:
            return normalized.contains('planning') ||
                normalized.contains('soon');
          case TestingProductStatus.routineStability:
            return normalized.contains('stability') ||
                normalized.contains('confirm');
        }
      },
      orElse: () => null,
    );
  }
}

/// User preference regarding AI recommendations and proactive product boosters.
enum AssistancePreference {
  /// Propose proactive booster ingredients and formula suggestions.
  tailoredBoosters('tailored_boosters'),

  /// Alert only when skin metrics show irritation or barrier decline.
  alertOnDecline('alert_on_decline'),

  /// Strictly track existing routine without external suggestions.
  trackRoutineOnly('track_routine_only');

  const AssistancePreference(this.code);

  /// Normalized storage code.
  final String code;

  /// Resolves [AssistancePreference] from stored code or returns null.
  static AssistancePreference? fromCode(String? code) {
    if (code == null) return null;
    final normalized = code.trim().toLowerCase();
    return AssistancePreference.values.cast<AssistancePreference?>().firstWhere(
      (element) {
        if (element == null) return false;
        if (element.code == code || element.name.toLowerCase() == normalized) {
          return true;
        }
        switch (element) {
          case AssistancePreference.tailoredBoosters:
            return normalized.contains('booster') ||
                normalized.contains('tailored');
          case AssistancePreference.alertOnDecline:
            return normalized.contains('decline') ||
                normalized.contains('alert');
          case AssistancePreference.trackRoutineOnly:
            return normalized.contains('only') ||
                normalized.contains('current routine');
        }
      },
      orElse: () => null,
    );
  }
}

/// Pure domain entity representing the complete user skin profile
/// and preferences.
///
/// Designed to be language-independent and suitable for offline guest usage
/// before connecting an authenticated account.
class UserSkinProfile extends Equatable {
  /// Creates a [UserSkinProfile].
  const UserSkinProfile({
    this.demographics,
    this.skinTone,
    this.skinType,
    this.primaryGoals = const [],
    this.routineLevel,
    this.testingProductStatus,
    this.assistancePreference,
    this.isAnonymous = true,
    this.anonymousId,
    this.userId,
    this.createdAt,
    this.updatedAt,
  });

  /// User demographic baseline (gender, age bracket, sensitive skin).
  final UserDemographics? demographics;

  /// Fitzpatrick skin phototype.
  final SkinTone? skinTone;

  /// Baseline self-assessed skin type.
  final SkinType? skinType;

  /// Primary skin targets for monitoring and recommendation algorithms.
  final List<SkinGoal> primaryGoals;

  /// Routine complexity category.
  final RoutineLevel? routineLevel;

  /// Whether a new product is currently undergoing or planned for experiment.
  final TestingProductStatus? testingProductStatus;

  /// Assistant and recommendation mode preference.
  final AssistancePreference? assistancePreference;

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

  /// Whether all essential quiz attributes have been answered.
  bool get isComplete =>
      skinTone != null &&
      skinType != null &&
      primaryGoals.isNotEmpty &&
      routineLevel != null &&
      testingProductStatus != null &&
      assistancePreference != null;

  /// Creates a copy with updated parameters.
  UserSkinProfile copyWith({
    UserDemographics? demographics,
    SkinTone? skinTone,
    SkinType? skinType,
    List<SkinGoal>? primaryGoals,
    RoutineLevel? routineLevel,
    TestingProductStatus? testingProductStatus,
    AssistancePreference? assistancePreference,
    bool? isAnonymous,
    String? anonymousId,
    String? userId,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return UserSkinProfile(
      demographics: demographics ?? this.demographics,
      skinTone: skinTone ?? this.skinTone,
      skinType: skinType ?? this.skinType,
      primaryGoals: primaryGoals ?? this.primaryGoals,
      routineLevel: routineLevel ?? this.routineLevel,
      testingProductStatus: testingProductStatus ?? this.testingProductStatus,
      assistancePreference: assistancePreference ?? this.assistancePreference,
      isAnonymous: isAnonymous ?? this.isAnonymous,
      anonymousId: anonymousId ?? this.anonymousId,
      userId: userId ?? this.userId,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }

  @override
  List<Object?> get props => [
    demographics,
    skinTone,
    skinType,
    primaryGoals,
    routineLevel,
    testingProductStatus,
    assistancePreference,
    isAnonymous,
    anonymousId,
    userId,
    createdAt,
    updatedAt,
  ];
}
