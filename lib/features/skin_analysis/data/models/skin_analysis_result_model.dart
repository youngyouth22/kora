// ignore_for_file: document_ignores, lines_longer_than_80_chars

import 'package:kora/features/skin_analysis/data/models/skin_report_model.dart';
import 'package:kora/features/skin_analysis/domain/entities/skin_analysis_result.dart';
import 'package:kora/features/skin_analysis/domain/entities/skin_concern.dart';
import 'package:kora/features/skin_analysis/domain/entities/skin_type_info.dart';

/// Data model representing the skin analysis response from YouCam API.
class SkinAnalysisResultModel {
  /// Creates a [SkinAnalysisResultModel].
  const SkinAnalysisResultModel({
    required this.overallScore,
    required this.concerns,
    this.skinAge,
    this.skinTypeInfo,
    this.resizedImageUrl,
    this.report,
  });

  /// Deserializes JSON according to YouCam API format.
  factory SkinAnalysisResultModel.fromJson(Map<String, dynamic> json) {
    final data = json['data'] as Map<String, dynamic>? ?? json;
    final results = data['results'] as Map<String, dynamic>? ?? data;
    final outputList = (results['output'] as List<dynamic>?) ?? [];

    var overall = 75.0;
    int? age;
    String? resizedUrl;
    String? wholeSkinType;
    String? tZoneSkinType;
    String? uZoneSkinType;
    final skinTypeMasks = <String>[];
    final concernModels = <SkinConcernModel>[];

    for (final rawItem in outputList) {
      if (rawItem is! Map<String, dynamic>) continue;
      final type = rawItem['type']?.toString();

      if (type == 'all') {
        final rawScore = rawItem['score'];
        if (rawScore is num) {
          overall = rawScore.toDouble();
        }
      } else if (type == 'skin_age') {
        final rawAge = rawItem['score'];
        if (rawAge is num) {
          age = rawAge.round();
        }
      } else if (type == 'resize_image') {
        final maskUrls = rawItem['mask_urls'];
        if (maskUrls is List && maskUrls.isNotEmpty) {
          resizedUrl = maskUrls.first?.toString();
        }
      } else if (type == 'skin_type') {
        final region = rawItem['region']?.toString();
        final st = rawItem['skin_type']?.toString() ?? 'Normal';
        if (region == 'whole' || region == null) {
          wholeSkinType = st;
        } else if (region == 't_zone') {
          tZoneSkinType = st;
        } else if (region == 'u_zone') {
          uZoneSkinType = st;
        }
        final maskUrls = rawItem['mask_urls'];
        if (maskUrls is List) {
          for (final m in maskUrls) {
            if (m != null) skinTypeMasks.add(m.toString());
          }
        }
      } else if (type != null) {
        // It's a concern item (pore, wrinkle, acne, etc.)
        concernModels.add(SkinConcernModel.fromJson(rawItem));
      }
    }

    SkinTypeInfoModel? skinTypeModel;
    if (wholeSkinType != null) {
      skinTypeModel = SkinTypeInfoModel(
        overallType: wholeSkinType,
        tZoneType: tZoneSkinType,
        uZoneType: uZoneSkinType,
        maskUrls: skinTypeMasks,
      );
    }

    // Parse AI Skin Analyst report if attached to payload
    SkinReportModel? skinReport;
    final rawReport = json['report'] ?? data['report'] ?? results['report'];
    if (rawReport is Map<String, dynamic>) {
      skinReport = SkinReportModel.fromJson(rawReport);
    } else {
      // Deterministic fallback synthesis when LLM report is not pre-packaged
      skinReport = _synthesizeFallbackReport(
        overallScore: overall,
        skinType: wholeSkinType ?? 'Combination',
        concerns: concernModels,
      );
    }

    return SkinAnalysisResultModel(
      overallScore: overall,
      skinAge: age,
      skinTypeInfo: skinTypeModel,
      resizedImageUrl: resizedUrl,
      concerns: concernModels,
      report: skinReport,
    );
  }

  /// Overall score (e.g. 75.1).
  final double overallScore;

  /// Estimated biological skin age.
  final int? skinAge;

  /// Skin type breakdown.
  final SkinTypeInfoModel? skinTypeInfo;

  /// Resized image URL.
  final String? resizedImageUrl;

  /// Detected concern items.
  final List<SkinConcernModel> concerns;

  /// AI Skin Analyst detailed report.
  final SkinReportModel? report;

  /// Converts this model to a pure domain [SkinAnalysisResult].
  SkinAnalysisResult toEntity() {
    return SkinAnalysisResult(
      overallScore: overallScore,
      skinAge: skinAge,
      skinType: skinTypeInfo?.toEntity(),
      resizedImageUrl: resizedImageUrl,
      allConcerns: concerns.map((c) => c.toEntity()).toList(),
      report: report?.toEntity(),
    );
  }

  static SkinReportModel _synthesizeFallbackReport({
    required double overallScore,
    required String skinType,
    required List<SkinConcernModel> concerns,
  }) {
    final sortedByWorst = List<SkinConcernModel>.from(concerns)
      ..sort((a, b) => a.uiScore.compareTo(b.uiScore));
    final sortedByBest = List<SkinConcernModel>.from(concerns)
      ..sort((a, b) => b.uiScore.compareTo(a.uiScore));

    final topStrengths = sortedByBest.take(2).map((c) {
      return StrengthItemModel(
        title: SkinConcernModel.displayNameFor(c.type),
        description:
            'Your skin demonstrates strong natural vitality and balance.',
        evidence: [
          EvidenceModel(concern: c.type, raw: c.rawScore),
        ],
      );
    }).toList();

    final attentionRegions = sortedByWorst.take(2).map((c) {
      return RegionItemModel(
        area: (c.type.contains('eye') || c.type.contains('tear'))
            ? 'eye_area'
            : 'whole_face',
        title: SkinConcernModel.displayNameFor(c.type),
        observation:
            'Measured score: ${c.uiScore}/100. Targeted hydration and barrier protection recommended.',
        whyItMatters: 'Optimizing gentle targeted care will support long-term skin resilience.',
        suggestedFocus:
            'Incorporate gentle, non-stripping active ingredients gradually.',
        confidence: 'measured',
        evidence: [
          EvidenceModel(concern: c.type, raw: c.rawScore),
        ],
      );
    }).toList();

    String band;
    if (overallScore >= 85) {
      band = 'strength';
    } else if (overallScore >= 70) {
      band = 'good';
    } else if (overallScore >= 55) {
      band = 'moderate';
    } else if (overallScore >= 40) {
      band = 'watch';
    } else {
      band = 'focus';
    }

    return SkinReportModel(
      headline: 'Balanced skin with a strong natural foundation',
      summary:
          'Overall ${overallScore.round()}/100 on your first scan. Starting point calibrated.',
      overall: OverallScoreModel(
        score: overallScore,
        band: band,
        caption: 'Your starting point, not a verdict.',
      ),
      profileChips: [
        ProfileChipModel(
          label: skinType,
          sublabel: 'Skin type',
          kind: 'skin_type',
        ),
        if (sortedByBest.isNotEmpty)
          ProfileChipModel(
            label: SkinConcernModel.displayNameFor(sortedByBest.first.type),
            sublabel: 'Strength',
            kind: 'concern',
          ),
        if (sortedByWorst.isNotEmpty)
          ProfileChipModel(
            label: SkinConcernModel.displayNameFor(sortedByWorst.first.type),
            sublabel: 'Focus area',
            kind: 'goal',
          ),
      ],
      strengths: topStrengths,
      regions: attentionRegions,
      goalValidation: const GoalValidationModel(
        goal: 'moisture',
        alignment: 'strong',
        value: 0.85,
        explanation: 'Your scan aligns with your goals: gentle hydration protocol active.',
      ),
      routinePreview: const [
        RoutineStepModel(
          step: 1,
          name: 'Gentle Hydrating Cleanser',
          timeOfDay: 'both',
          ingredientIds: ['glycerin'],
          instruction: 'Cleanse gently with lukewarm water morning and night.',
          why: 'Preserves your natural skin barrier without stripping oils.',
        ),
        RoutineStepModel(
          step: 2,
          name: 'Barrier Support Moisturizer',
          timeOfDay: 'both',
          ingredientIds: ['ceramides', 'hyaluronic_acid'],
          instruction: 'Apply to damp skin after cleansing.',
          why: 'Maintains optimal lipid barrier and moisture retention.',
        ),
        RoutineStepModel(
          step: 3,
          name: 'Broad-Spectrum SPF 30+',
          timeOfDay: 'am',
          ingredientIds: ['zinc_oxide'],
          instruction: 'Apply two finger lengths every morning.',
          why: 'Protects from UV radiation and preserves natural elasticity.',
        ),
      ],
      coachMessage: 'Start simple: hydrate, protect, and add only one new active at a time. I will track every change with you.',
      disclaimers: const ['Estimates from a photo, not medical advice.'],
      safety: const SafetyReportModel(
        needsProfessionalReview: false,
      ),
    );
  }
}

/// Model for skin type information.
class SkinTypeInfoModel {
  /// Creates a [SkinTypeInfoModel].
  const SkinTypeInfoModel({
    required this.overallType,
    this.tZoneType,
    this.uZoneType,
    this.maskUrls = const [],
  });

  /// Overall skin type.
  final String overallType;

  /// T-Zone skin type.
  final String? tZoneType;

  /// U-Zone skin type.
  final String? uZoneType;

  /// Mask URLs.
  final List<String> maskUrls;

  /// Converts to domain entity.
  SkinTypeInfo toEntity() {
    return SkinTypeInfo(
      overallType: overallType,
      tZoneType: tZoneType,
      uZoneType: uZoneType,
      maskUrls: maskUrls,
    );
  }
}

/// Model for a skin concern.
class SkinConcernModel {
  /// Creates a [SkinConcernModel].
  const SkinConcernModel({
    required this.type,
    required this.uiScore,
    required this.rawScore,
    this.maskUrls = const [],
  });

  /// Deserializes a concern item.
  factory SkinConcernModel.fromJson(Map<String, dynamic> json) {
    final type = json['type']?.toString() ?? 'unknown';
    final uiScore = (json['ui_score'] as num?)?.round() ?? 70;
    final rawScore = (json['raw_score'] as num?)?.toDouble() ?? 70.0;

    final maskUrls = <String>[];
    final rawMaskUrls = json['mask_urls'];
    if (rawMaskUrls is List) {
      for (final url in rawMaskUrls) {
        if (url != null) maskUrls.add(url.toString());
      }
    }

    return SkinConcernModel(
      type: type,
      uiScore: uiScore,
      rawScore: rawScore,
      maskUrls: maskUrls,
    );
  }

  /// Canonical identifier.
  final String type;

  /// UI score (0-100).
  final int uiScore;

  /// Raw score.
  final double rawScore;

  /// Mask image URLs.
  final List<String> maskUrls;

  /// Converts to domain entity with proper user-friendly display name.
  SkinConcern toEntity() {
    return SkinConcern(
      id: type,
      displayName: displayNameFor(type),
      uiScore: uiScore,
      rawScore: rawScore,
      maskUrls: maskUrls,
    );
  }

  /// Maps canonical concern [type] to user-friendly display name.
  static String displayNameFor(String type) {
    switch (type) {
      case 'pore':
        return 'Pores';
      case 'wrinkle':
        return 'Wrinkles & Fine Lines';
      case 'texture':
        return 'Skin Texture';
      case 'acne':
        return 'Blemishes & Acne';
      case 'redness':
        return 'Redness';
      case 'oiliness':
        return 'Oiliness';
      case 'moisture':
        return 'Hydration';
      case 'radiance':
        return 'Radiance';
      case 'firmness':
        return 'Firmness & Bounce';
      case 'dark_circle_v2':
      case 'dark_circle':
        return 'Dark Circles';
      case 'eye_bag':
        return 'Eye Bags';
      case 'tear_trough':
        return 'Tear Trough';
      case 'droopy_upper_eyelid':
        return 'Upper Eyelid';
      case 'droopy_lower_eyelid':
        return 'Lower Eyelid';
      case 'age_spot':
        return 'Dark Spots';
      default:
        return type.replaceAll('_', ' ').toUpperCase();
    }
  }
}
