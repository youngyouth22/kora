// ignore_for_file: document_ignores, lines_longer_than_80_chars

import 'package:kora/features/onboarding/domain/entities/user_skin_profile.dart';
import 'package:kora/features/skin_analysis/data/models/skin_analysis_result_model.dart';

/// Request payload model for `POST /api/skin-report` on the Kora AI Backend.
///
/// Strictly enforces Article 5: `ui_score` is NEVER transmitted; only `raw_score`
/// values and their arithmetic mean (`overall`) are used.
class SkinReportRequestModel {
  /// Creates a [SkinReportRequestModel].
  const SkinReportRequestModel({
    required this.scan,
    required this.profile,
  });

  /// Constructs a normalized [SkinReportRequestModel] from a YouCam
  /// [SkinAnalysisResultModel] and optional [UserSkinProfile].
  factory SkinReportRequestModel.fromAnalysis({
    required SkinAnalysisResultModel analysis,
    UserSkinProfile? userProfile,
    String fallbackUserId = 'anonymous-user',
    List<String> currentRoutineIngredients = const [],
    List<String> sensitivities = const [],
    bool isPregnantOrBreastfeeding = false,
    bool isFungalAcneProne = false,
  }) {
    final scanPayload = NormalizedScanPayloadModel.fromResultModel(analysis);
    final profilePayload = SkinReportProfilePayloadModel.fromUserProfile(
      profile: userProfile,
      fallbackUserId: fallbackUserId,
      fallbackSkinType: scanPayload.skinTypeWhole,
      currentRoutineIngredients: currentRoutineIngredients,
      sensitivities: sensitivities,
      isPregnantOrBreastfeeding: isPregnantOrBreastfeeding,
      isFungalAcneProne: isFungalAcneProne,
    );

    return SkinReportRequestModel(
      scan: scanPayload,
      profile: profilePayload,
    );
  }

  /// Normalized scan telemetry strictly based on `raw_score`.
  final NormalizedScanPayloadModel scan;

  /// User profile context for personalized report generation.
  final SkinReportProfilePayloadModel profile;

  /// Serializes to JSON map for `POST /api/skin-report`.
  Map<String, dynamic> toJson() => {
    'scan': scan.toJson(),
    'profile': profile.toJson(),
  };
}

/// Normalized scan payload sent to `POST /api/skin-report`.
class NormalizedScanPayloadModel {
  /// Creates a [NormalizedScanPayloadModel].
  const NormalizedScanPayloadModel({
    required this.overall,
    required this.overallBand,
    required this.providerOverallIgnored,
    required this.skinTypeWhole,
    required this.skinTypeZones,
    required this.concerns,
    required this.strengths,
    required this.focus,
    required this.patterns,
    required this.evidence,
    this.skinAge,
  });

  /// Builds a [NormalizedScanPayloadModel] from [SkinAnalysisResultModel]
  /// using only `rawScore` values.
  factory NormalizedScanPayloadModel.fromResultModel(
    SkinAnalysisResultModel model,
  ) {
    final rawConcerns = model.concerns;

    // Calculate arithmetic mean of raw_score values (never ui_score).
    var computedOverall = model.overallScore;
    if (rawConcerns.isNotEmpty) {
      final sum = rawConcerns.fold<double>(
        0,
        (acc, item) => acc + item.rawScore,
      );
      computedOverall = double.parse(
        (sum / rawConcerns.length).toStringAsFixed(1),
      );
    }

    // Sort by lowest raw_score first (priority rank 1..N for focus areas,
    // or rank across all measured concerns).
    final sorted = List<SkinConcernModel>.from(rawConcerns)
      ..sort((a, b) => b.rawScore.compareTo(a.rawScore));

    final concernPayloads = <ScanConcernPayloadModel>[];
    final evidenceMap = <String, double>{};

    for (var i = 0; i < sorted.length; i++) {
      final item = sorted[i];
      final key = _canonicalKeyFor(item.type);
      final roundedRaw = double.parse(item.rawScore.toStringAsFixed(1));
      evidenceMap[key] = roundedRaw;

      concernPayloads.add(
        ScanConcernPayloadModel(
          key: key,
          label: SkinConcernModel.displayNameFor(item.type),
          raw: roundedRaw,
          band: bandForScore(roundedRaw),
          area: _areaForType(item.type),
          lever: _leverForType(item.type),
          category: _categoryForType(item.type),
          rank: i + 1,
        ),
      );
    }

    final strengths = concernPayloads
        .where((c) => c.raw >= 75.0)
        .take(3)
        .map((c) => c.key)
        .toList();

    final ascendingConcerns = List<ScanConcernPayloadModel>.from(
      concernPayloads,
    )..sort((a, b) => a.raw.compareTo(b.raw));
    final focus = ascendingConcerns
        .where((c) => c.raw < 75.0)
        .take(3)
        .map((c) => c.key)
        .toList();

    final patterns = <String>[];
    final moistureScore = evidenceMap['moisture'];
    final oilinessScore = evidenceMap['oiliness'];
    final wholeType = (model.skinTypeInfo?.overallType ?? 'combination')
        .toLowerCase();

    if (moistureScore != null &&
        moistureScore < 60.0 &&
        (wholeType == 'oily' ||
            wholeType == 'combination' ||
            (oilinessScore != null && oilinessScore < 60.0))) {
      patterns.add('oily_dehydrated');
    }
    final rednessScore = evidenceMap['redness'];
    if (rednessScore != null && rednessScore < 60.0) {
      patterns.add('reactive_barrier');
    }

    final tZone = (model.skinTypeInfo?.tZoneType ?? wholeType).toLowerCase();
    final uZone = (model.skinTypeInfo?.uZoneType ?? 'normal').toLowerCase();

    return NormalizedScanPayloadModel(
      overall: computedOverall,
      overallBand: bandForScore(computedOverall),
      providerOverallIgnored: double.parse(
        model.overallScore.toStringAsFixed(1),
      ),
      skinAge: model.skinAge,
      skinTypeWhole: wholeType,
      skinTypeZones: {
        't_zone': tZone,
        'u_zone': uZone,
      },
      concerns: concernPayloads,
      strengths: strengths,
      focus: focus,
      patterns: patterns,
      evidence: evidenceMap,
    );
  }

  /// Arithmetic average of `raw_score` across all measured concerns.
  final double overall;

  /// Qualitative band for [overall]: 'strength' | 'good' | 'moderate' | 'watch' | 'focus'.
  final String overallBand;

  /// Original provider composite score (kept only for telemetry reference).
  final double providerOverallIgnored;

  /// Estimated skin age, if provided.
  final int? skinAge;

  /// Whole-face skin type ('oily', 'dry', 'combination', 'normal').
  final String skinTypeWhole;

  /// Zone breakdown (`t_zone`, `u_zone`).
  final Map<String, String> skinTypeZones;

  /// Normalized list of measured concerns (using `raw_score` only).
  final List<ScanConcernPayloadModel> concerns;

  /// Keys of top skin strengths.
  final List<String> strengths;

  /// Keys of primary focus areas.
  final List<String> focus;

  /// Detected composite skin patterns (e.g. `oily_dehydrated`).
  final List<String> patterns;

  /// Map of canonical concern key to `raw_score`.
  final Map<String, double> evidence;

  /// Maps a raw score (0..100) to its qualitative band.
  static String bandForScore(double score) {
    if (score >= 80) return 'strength';
    if (score >= 70) return 'good';
    if (score >= 55) return 'moderate';
    if (score >= 40) return 'watch';
    return 'focus';
  }

  /// Canonical mapping ensuring keys match the backend Mastra CONCERNS schema.
  static String canonicalKeyFor(String type) {
    final lower = type.toLowerCase().trim();
    switch (lower) {
      case 'pores':
      case 'pore':
        return 'pore';
      case 'spots':
      case 'age_spot':
      case 'age_spots':
      case 'dark_spots':
        return 'age_spot';
      case 'wrinkles':
      case 'wrinkle':
      case 'fine_lines':
      case 'crow_feet':
        return 'wrinkle';
      case 'dark_circles':
      case 'dark_circle':
      case 'dark_circle_v2':
        return 'dark_circle_v2';
      case 'hydration':
      case 'dehydration':
      case 'moisture':
        return 'moisture';
      case 'uneven_texture':
      case 'texture':
        return 'texture';
      case 'acne':
        return 'acne';
      case 'redness':
        return 'redness';
      case 'oiliness':
        return 'oiliness';
      case 'radiance':
        return 'radiance';
      case 'firmness':
        return 'firmness';
      case 'eye_bag':
      case 'eye_bags':
        return 'eye_bag';
      case 'tear_trough':
        return 'tear_trough';
      case 'droopy_upper_eyelid':
        return 'droopy_upper_eyelid';
      case 'droopy_lower_eyelid':
        return 'droopy_lower_eyelid';
      default:
        return lower;
    }
  }

  static String _canonicalKeyFor(String type) => canonicalKeyFor(type);

  static String _areaForType(String type) {
    if (type.contains('eye') ||
        type.contains('tear') ||
        type.contains('dark_circle')) {
      return 'eye_area';
    }
    return 'whole_face';
  }

  static String _leverForType(String type) {
    if (type == 'tear_trough' ||
        type == 'eye_bag' ||
        type == 'droopy_upper_eyelid' ||
        type == 'droopy_lower_eyelid') {
      return 'structural';
    }
    return 'topical';
  }

  static String _categoryForType(String type) {
    switch (type) {
      case 'pore':
      case 'texture':
        return 'texture';
      case 'age_spot':
      case 'radiance':
      case 'redness':
        return 'pigment';
      case 'wrinkle':
      case 'firmness':
        return 'aging';
      case 'moisture':
      case 'oiliness':
        return 'barrier';
      case 'acne':
        return 'blemish';
      default:
        return 'orbital';
    }
  }

  /// Serializes to JSON map.
  Map<String, dynamic> toJson() => {
    'overall': overall,
    'overallBand': overallBand,
    'providerOverallIgnored': providerOverallIgnored,
    if (skinAge != null) 'skinAge': skinAge,
    'skinType': {
      'whole': skinTypeWhole,
      'zones': skinTypeZones,
    },
    'concerns': concerns.map((c) => c.toJson()).toList(),
    'strengths': strengths,
    'focus': focus,
    'patterns': patterns,
    'evidence': evidence,
  };
}

/// Individual concern item inside [NormalizedScanPayloadModel].
class ScanConcernPayloadModel {
  /// Creates a [ScanConcernPayloadModel].
  const ScanConcernPayloadModel({
    required this.key,
    required this.label,
    required this.raw,
    required this.band,
    required this.area,
    required this.lever,
    required this.category,
    required this.rank,
  });

  /// Canonical key (e.g. 'pores', 'spots').
  final String key;

  /// Human-readable label.
  final String label;

  /// Honest `raw_score` from YouCam (never `ui_score`).
  final double raw;

  /// Qualitative score band.
  final String band;

  /// Anatomical region ('whole_face' | 'eye_area').
  final String area;

  /// Actionability lever ('topical' | 'structural').
  final String lever;

  /// Dermatological category ('texture', 'pigment', 'barrier', etc.).
  final String category;

  /// Rank in the scan evaluation.
  final int rank;

  /// Serializes to JSON map.
  Map<String, dynamic> toJson() => {
    'key': key,
    'label': label,
    'raw': raw,
    'band': band,
    'area': area,
    'lever': lever,
    'category': category,
    'rank': rank,
  };
}

/// User profile payload sent alongside the scan in `POST /api/skin-report`.
class SkinReportProfilePayloadModel {
  /// Creates a [SkinReportProfilePayloadModel].
  const SkinReportProfilePayloadModel({
    required this.userId,
    required this.skinType,
    required this.concerns,
    required this.goals,
    required this.sensitivities,
    required this.isPregnantOrBreastfeeding,
    required this.isFungalAcneProne,
    required this.currentRoutineIngredients,
  });

  /// Builds a [SkinReportProfilePayloadModel] from an optional [UserSkinProfile].
  factory SkinReportProfilePayloadModel.fromUserProfile({
    required UserSkinProfile? profile,
    String fallbackUserId = 'anonymous-user',
    String fallbackSkinType = 'combination',
    List<String> currentRoutineIngredients = const [],
    List<String> sensitivities = const [],
    bool isPregnantOrBreastfeeding = false,
    bool isFungalAcneProne = false,
  }) {
    final resolvedUserId =
        profile?.userId ?? profile?.anonymousId ?? fallbackUserId;
    final resolvedSkinType = (profile?.skinType?.code ?? fallbackSkinType)
        .toLowerCase();
    final goalCodes =
        profile?.primaryGoals
            .map((g) => NormalizedScanPayloadModel.canonicalKeyFor(g.code))
            .toList() ??
        const ['moisture'];
    final resolvedSensitivities = <String>{
      ...sensitivities,
      if (profile?.demographics?.hasSensitiveSkin ?? false) 'sensitive_skin',
    }.toList();

    return SkinReportProfilePayloadModel(
      userId: resolvedUserId,
      skinType: resolvedSkinType,
      concerns: goalCodes,
      goals: goalCodes,
      sensitivities: resolvedSensitivities,
      isPregnantOrBreastfeeding: isPregnantOrBreastfeeding,
      isFungalAcneProne: isFungalAcneProne,
      currentRoutineIngredients: currentRoutineIngredients,
    );
  }

  /// User identifier (Supabase UUID or guest UUID).
  final String userId;

  /// Skin type code ('oily', 'dry', 'combination', 'normal').
  final String skinType;

  /// Target concerns.
  final List<String> concerns;

  /// User skincare goals.
  final List<String> goals;

  /// Known ingredient sensitivities.
  final List<String> sensitivities;

  /// Pregnancy/breastfeeding safety flag.
  final bool isPregnantOrBreastfeeding;

  /// Fungal acne susceptibility flag.
  final bool isFungalAcneProne;

  /// Active ingredients currently in the user's routine.
  final List<String> currentRoutineIngredients;

  /// Serializes to JSON map.
  Map<String, dynamic> toJson() => {
    'userId': userId,
    'skinType': skinType,
    'concerns': concerns,
    'goals': goals,
    'sensitivities': sensitivities,
    'isPregnantOrBreastfeeding': isPregnantOrBreastfeeding,
    'isFungalAcneProne': isFungalAcneProne,
    'currentRoutineIngredients': currentRoutineIngredients,
  };
}
