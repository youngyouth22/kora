// ignore_for_file: document_ignores, public_member_api_docs, lines_longer_than_80_chars

import 'package:kora/features/skin_analysis/domain/entities/skin_report.dart';

/// Data model representing the HTTP report result envelope.
class ReportResultModel {
  /// Creates a [ReportResultModel].
  const ReportResultModel({
    required this.report,
    this.source = 'llm',
    this.attempts = 1,
    this.errors = const [],
  });

  /// Deserializes from API envelope JSON.
  factory ReportResultModel.fromJson(Map<String, dynamic> json) {
    final rawReport = json['report'];
    final reportJson = rawReport is Map<String, dynamic> ? rawReport : json;

    return ReportResultModel(
      report: SkinReportModel.fromJson(reportJson),
      source: json['source']?.toString() ?? 'fallback',
      attempts: (json['attempts'] as num?)?.toInt() ?? 1,
      errors:
          (json['errors'] as List<dynamic>?)
              ?.map((e) => e.toString())
              .toList() ??
          const [],
    );
  }

  /// The parsed skin report model.
  final SkinReportModel report;

  /// Generation source ('llm' | 'fallback').
  final String source;

  /// Number of generation attempts.
  final int attempts;

  /// Encountered errors or notes.
  final List<String> errors;

  /// Serializes to JSON envelope.
  Map<String, dynamic> toJson() => {
    'report': report.toJson(),
    'source': source,
    'attempts': attempts,
    'errors': errors,
  };
}

/// Data model for [SkinReport].
class SkinReportModel {
  /// Creates a [SkinReportModel].
  const SkinReportModel({
    required this.headline,
    required this.summary,
    required this.overall,
    required this.profileChips,
    required this.strengths,
    required this.regions,
    required this.routinePreview,
    required this.coachMessage,
    required this.disclaimers,
    required this.safety,
    this.goalValidation,
  });

  /// Deserializes a [SkinReportModel] from JSON.
  factory SkinReportModel.fromJson(Map<String, dynamic> json) {
    final headline = json['headline']?.toString() ?? 'Your Skin Baseline';
    final summary = json['summary']?.toString() ?? '';

    final overallMap = json['overall'] as Map<String, dynamic>? ?? {};
    final overall = OverallScoreModel.fromJson(overallMap);

    final rawChips = json['profile_chips'] as List<dynamic>? ?? [];
    final profileChips = rawChips
        .whereType<Map<String, dynamic>>()
        .map(ProfileChipModel.fromJson)
        .toList();

    final rawStrengths = json['strengths'] as List<dynamic>? ?? [];
    final strengths = rawStrengths
        .whereType<Map<String, dynamic>>()
        .map(StrengthItemModel.fromJson)
        .toList();

    final rawRegions = json['regions'] as List<dynamic>? ?? [];
    final regions = rawRegions
        .whereType<Map<String, dynamic>>()
        .map(RegionItemModel.fromJson)
        .toList();

    GoalValidationModel? goalValidation;
    if (json['goal_validation'] is Map<String, dynamic>) {
      goalValidation = GoalValidationModel.fromJson(
        json['goal_validation'] as Map<String, dynamic>,
      );
    }

    final rawRoutine = json['routine_preview'] as List<dynamic>? ?? [];
    final routinePreview = rawRoutine
        .whereType<Map<String, dynamic>>()
        .map(RoutineStepModel.fromJson)
        .toList();

    final coachMessage =
        json['coach_message']?.toString() ??
        'Consistency and patience are key. Track every change step by step.';

    final rawDisclaimers = json['disclaimers'] as List<dynamic>? ?? [];
    final disclaimers = rawDisclaimers.map((e) => e.toString()).toList();

    final safetyMap = json['safety'] as Map<String, dynamic>? ?? {};
    final safety = SafetyReportModel.fromJson(safetyMap);

    return SkinReportModel(
      headline: headline,
      summary: summary,
      overall: overall,
      profileChips: profileChips,
      strengths: strengths,
      regions: regions,
      goalValidation: goalValidation,
      routinePreview: routinePreview,
      coachMessage: coachMessage,
      disclaimers: disclaimers.isNotEmpty
          ? disclaimers
          : const ['Estimates from a photo, not medical advice.'],
      safety: safety,
    );
  }

  final String headline;
  final String summary;
  final OverallScoreModel overall;
  final List<ProfileChipModel> profileChips;
  final List<StrengthItemModel> strengths;
  final List<RegionItemModel> regions;
  final GoalValidationModel? goalValidation;
  final List<RoutineStepModel> routinePreview;
  final String coachMessage;
  final List<String> disclaimers;
  final SafetyReportModel safety;

  /// Converts this model to a pure domain [SkinReport] entity.
  SkinReport toEntity() {
    return SkinReport(
      headline: headline,
      summary: summary,
      overall: overall.toEntity(),
      profileChips: profileChips.map((c) => c.toEntity()).toList(),
      strengths: strengths.map((s) => s.toEntity()).toList(),
      regions: regions.map((r) => r.toEntity()).toList(),
      goalValidation: goalValidation?.toEntity(),
      routinePreview: routinePreview.map((step) => step.toEntity()).toList(),
      coachMessage: coachMessage,
      disclaimers: disclaimers,
      safety: safety.toEntity(),
    );
  }

  /// Serializes to JSON.
  Map<String, dynamic> toJson() => {
    'headline': headline,
    'summary': summary,
    'overall': overall.toJson(),
    'profile_chips': profileChips.map((c) => c.toJson()).toList(),
    'strengths': strengths.map((s) => s.toJson()).toList(),
    'regions': regions.map((r) => r.toJson()).toList(),
    if (goalValidation != null) 'goal_validation': goalValidation!.toJson(),
    'routine_preview': routinePreview.map((s) => s.toJson()).toList(),
    'coach_message': coachMessage,
    'disclaimers': disclaimers,
    'safety': safety.toJson(),
  };
}

/// Data model for [OverallScore].
class OverallScoreModel {
  const OverallScoreModel({
    required this.score,
    required this.band,
    required this.caption,
  });

  factory OverallScoreModel.fromJson(Map<String, dynamic> json) {
    return OverallScoreModel(
      score: (json['score'] as num?)?.toDouble() ?? 70.0,
      band: json['band']?.toString() ?? 'good',
      caption:
          json['caption']?.toString() ?? 'Your starting point, not a verdict.',
    );
  }

  final double score;
  final String band;
  final String caption;

  OverallScore toEntity() => OverallScore(
    score: score,
    band: band,
    caption: caption,
  );

  Map<String, dynamic> toJson() => {
    'score': score,
    'band': band,
    'caption': caption,
  };
}

/// Data model for [ProfileChip].
class ProfileChipModel {
  const ProfileChipModel({
    required this.label,
    required this.sublabel,
    required this.kind,
  });

  factory ProfileChipModel.fromJson(Map<String, dynamic> json) {
    return ProfileChipModel(
      label: json['label']?.toString() ?? '',
      sublabel: json['sublabel']?.toString() ?? '',
      kind: json['kind']?.toString() ?? 'skin_type',
    );
  }

  final String label;
  final String sublabel;
  final String kind;

  ProfileChip toEntity() => ProfileChip(
    label: label,
    sublabel: sublabel,
    kind: kind,
  );

  Map<String, dynamic> toJson() => {
    'label': label,
    'sublabel': sublabel,
    'kind': kind,
  };
}

/// Data model for [StrengthItem].
class StrengthItemModel {
  const StrengthItemModel({
    required this.title,
    required this.description,
    required this.evidence,
  });

  factory StrengthItemModel.fromJson(Map<String, dynamic> json) {
    final rawEvidence = json['evidence'] as List<dynamic>? ?? [];
    final evidence = rawEvidence
        .whereType<Map<String, dynamic>>()
        .map(EvidenceModel.fromJson)
        .toList();

    return StrengthItemModel(
      title: json['title']?.toString() ?? '',
      description: json['description']?.toString() ?? '',
      evidence: evidence,
    );
  }

  final String title;
  final String description;
  final List<EvidenceModel> evidence;

  StrengthItem toEntity() => StrengthItem(
    title: title,
    description: description,
    evidence: evidence.map((e) => e.toEntity()).toList(),
  );

  Map<String, dynamic> toJson() => {
    'title': title,
    'description': description,
    'evidence': evidence.map((e) => e.toJson()).toList(),
  };
}

/// Data model for [RegionItem].
class RegionItemModel {
  const RegionItemModel({
    required this.area,
    required this.title,
    required this.observation,
    required this.whyItMatters,
    required this.suggestedFocus,
    required this.confidence,
    required this.evidence,
  });

  factory RegionItemModel.fromJson(Map<String, dynamic> json) {
    final rawEvidence = json['evidence'] as List<dynamic>? ?? [];
    final evidence = rawEvidence
        .whereType<Map<String, dynamic>>()
        .map(EvidenceModel.fromJson)
        .toList();

    return RegionItemModel(
      area: json['area']?.toString() ?? 'whole_face',
      title: json['title']?.toString() ?? '',
      observation: json['observation']?.toString() ?? '',
      whyItMatters: json['why_it_matters']?.toString() ?? '',
      suggestedFocus: json['suggested_focus']?.toString() ?? '',
      confidence: json['confidence']?.toString() ?? 'measured',
      evidence: evidence,
    );
  }

  final String area;
  final String title;
  final String observation;
  final String whyItMatters;
  final String suggestedFocus;
  final String confidence;
  final List<EvidenceModel> evidence;

  RegionItem toEntity() => RegionItem(
    area: area,
    title: title,
    observation: observation,
    whyItMatters: whyItMatters,
    suggestedFocus: suggestedFocus,
    confidence: confidence,
    evidence: evidence.map((e) => e.toEntity()).toList(),
  );

  Map<String, dynamic> toJson() => {
    'area': area,
    'title': title,
    'observation': observation,
    'why_it_matters': whyItMatters,
    'suggested_focus': suggestedFocus,
    'confidence': confidence,
    'evidence': evidence.map((e) => e.toJson()).toList(),
  };
}

/// Data model for [Evidence].
class EvidenceModel {
  const EvidenceModel({required this.concern, required this.raw});

  factory EvidenceModel.fromJson(Map<String, dynamic> json) {
    return EvidenceModel(
      concern: json['concern']?.toString() ?? '',
      raw: (json['raw'] as num?)?.toDouble() ?? 0.0,
    );
  }

  final String concern;
  final double raw;

  Evidence toEntity() => Evidence(concern: concern, raw: raw);

  Map<String, dynamic> toJson() => {'concern': concern, 'raw': raw};
}

/// Data model for [GoalValidation].
class GoalValidationModel {
  const GoalValidationModel({
    required this.goal,
    required this.alignment,
    required this.value,
    required this.explanation,
  });

  factory GoalValidationModel.fromJson(Map<String, dynamic> json) {
    return GoalValidationModel(
      goal: json['goal']?.toString() ?? '',
      alignment: json['alignment']?.toString() ?? 'strong',
      value: (json['value'] as num?)?.toDouble() ?? 1.0,
      explanation: json['explanation']?.toString() ?? '',
    );
  }

  final String goal;
  final String alignment;
  final double value;
  final String explanation;

  GoalValidation toEntity() => GoalValidation(
    goal: goal,
    alignment: alignment,
    value: value,
    explanation: explanation,
  );

  Map<String, dynamic> toJson() => {
    'goal': goal,
    'alignment': alignment,
    'value': value,
    'explanation': explanation,
  };
}

/// Data model for [RoutineStep].
class RoutineStepModel {
  const RoutineStepModel({
    required this.step,
    required this.name,
    required this.timeOfDay,
    required this.ingredientIds,
    required this.instruction,
    required this.why,
  });

  factory RoutineStepModel.fromJson(Map<String, dynamic> json) {
    final rawIngredients = json['ingredient_ids'] as List<dynamic>? ?? [];
    final ingredientIds = rawIngredients.map((e) => e.toString()).toList();

    return RoutineStepModel(
      step: (json['step'] as num?)?.toInt() ?? 1,
      name: json['name']?.toString() ?? '',
      timeOfDay: json['time_of_day']?.toString() ?? 'both',
      ingredientIds: ingredientIds,
      instruction: json['instruction']?.toString() ?? '',
      why: json['why']?.toString() ?? '',
    );
  }

  final int step;
  final String name;
  final String timeOfDay;
  final List<String> ingredientIds;
  final String instruction;
  final String why;

  RoutineStep toEntity() => RoutineStep(
    step: step,
    name: name,
    timeOfDay: timeOfDay,
    ingredientIds: ingredientIds,
    instruction: instruction,
    why: why,
  );

  Map<String, dynamic> toJson() => {
    'step': step,
    'name': name,
    'time_of_day': timeOfDay,
    'ingredient_ids': ingredientIds,
    'instruction': instruction,
    'why': why,
  };
}

/// Data model for [SafetyReport].
class SafetyReportModel {
  const SafetyReportModel({
    required this.needsProfessionalReview,
    this.reasons = const [],
  });

  factory SafetyReportModel.fromJson(Map<String, dynamic> json) {
    final rawReasons = json['reasons'] as List<dynamic>? ?? [];
    final reasons = rawReasons.map((e) => e.toString()).toList();

    return SafetyReportModel(
      needsProfessionalReview:
          json['needs_professional_review'] as bool? ?? false,
      reasons: reasons,
    );
  }

  final bool needsProfessionalReview;
  final List<String> reasons;

  SafetyReport toEntity() => SafetyReport(
    needsProfessionalReview: needsProfessionalReview,
    reasons: reasons,
  );

  Map<String, dynamic> toJson() => {
    'needs_professional_review': needsProfessionalReview,
    'reasons': reasons,
  };
}
