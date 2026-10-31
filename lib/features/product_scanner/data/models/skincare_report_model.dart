// ignore_for_file: document_ignores, lines_longer_than_80_chars, public_member_api_docs

import 'package:kora/features/onboarding/domain/entities/user_skin_profile.dart';
import 'package:kora/features/product_scanner/domain/entities/skincare_report.dart';

/// Request payload model for `POST /api/scan-product`.
class ScanProductRequestModel {
  /// Creates a [ScanProductRequestModel].
  const ScanProductRequestModel({
    required this.rawInput,
    required this.userProfile,
  });

  /// Constructs a [ScanProductRequestModel] from raw OCR/barcode input and an
  /// optional [UserSkinProfile].
  factory ScanProductRequestModel.fromInput({
    required String rawInput,
    UserSkinProfile? profile,
    List<String> currentRoutineIngredients = const [],
    List<String> sensitivities = const [],
    bool isPregnantOrBreastfeeding = false,
    bool isFungalAcneProne = false,
  }) {
    final skinType = profile?.skinType?.code ?? 'combination';
    final concerns =
        profile?.primaryGoals.map((g) => g.code).toList() ??
        const ['pores', 'dehydration'];
    final resolvedSensitivities = <String>{
      ...sensitivities,
      if (profile?.demographics?.hasSensitiveSkin ?? false) 'fragrance',
    }.toList();

    return ScanProductRequestModel(
      rawInput: rawInput.trim(),
      userProfile: ScanProductUserProfilePayload(
        skinType: skinType,
        concerns: concerns,
        sensitivities: resolvedSensitivities,
        isPregnantOrBreastfeeding: isPregnantOrBreastfeeding,
        isFungalAcneProne: isFungalAcneProne,
        currentRoutineIngredients: currentRoutineIngredients,
      ),
    );
  }

  /// Barcode value (EAN/UPC) or full OCR text extracted from product packaging.
  final String rawInput;

  /// User profile context for personalized ingredient and routine matching.
  final ScanProductUserProfilePayload userProfile;

  /// Serializes to JSON map.
  Map<String, dynamic> toJson() => {
    'rawInput': rawInput,
    'userProfile': userProfile.toJson(),
  };
}

/// User profile sub-payload for `POST /api/scan-product`.
class ScanProductUserProfilePayload {
  /// Creates a [ScanProductUserProfilePayload].
  const ScanProductUserProfilePayload({
    required this.skinType,
    required this.concerns,
    required this.sensitivities,
    required this.isPregnantOrBreastfeeding,
    required this.isFungalAcneProne,
    required this.currentRoutineIngredients,
  });

  /// User skin type ('oily', 'dry', 'combination', 'normal').
  final String skinType;

  /// Target skin concerns.
  final List<String> concerns;

  /// Known sensitivities or allergens.
  final List<String> sensitivities;

  /// Pregnancy/breastfeeding status.
  final bool isPregnantOrBreastfeeding;

  /// Fungal acne susceptibility.
  final bool isFungalAcneProne;

  /// Active ingredients currently in the user's routine.
  final List<String> currentRoutineIngredients;

  /// Serializes to JSON map.
  Map<String, dynamic> toJson() => {
    'skinType': skinType,
    'concerns': concerns,
    'sensitivities': sensitivities,
    'isPregnantOrBreastfeeding': isPregnantOrBreastfeeding,
    'isFungalAcneProne': isFungalAcneProne,
    'currentRoutineIngredients': currentRoutineIngredients,
  };
}

/// Data model for [SkincareReport] returned by `POST /api/scan-product`.
class SkincareReportModel {
  /// Creates a [SkincareReportModel].
  const SkincareReportModel({
    required this.product,
    required this.personalizedVerdict,
    required this.applicationGuide,
    required this.purchaseOptions,
    required this.formulaStatic,
    this.pillars,
    this.aiAssistant,
    this.alternatives = const [],
    this.scientificSources = const [],
    this.medicalEndorsement,
    this.rawInciText,
  });

  /// Deserializes a [SkincareReportModel] from JSON.
  factory SkincareReportModel.fromJson(Map<String, dynamic> json) {
    final payload = json['report'] is Map<String, dynamic>
        ? json['report'] as Map<String, dynamic>
        : json;

    final productMap = payload['product'] is Map<String, dynamic>
        ? payload['product'] as Map<String, dynamic>
        : <String, dynamic>{
            'brand': payload['brand'],
            'name': payload['productName'] ?? payload['name'],
            'category': payload['category'] ?? payload['productType'],
            'imageUrl': payload['imageUrl'] ?? payload['image_url'],
          };

    final verdictMap = payload['personalizedVerdict'] is Map<String, dynamic>
        ? payload['personalizedVerdict'] as Map<String, dynamic>
        : payload;

    final guideMap = payload['applicationGuide'] is Map<String, dynamic>
        ? payload['applicationGuide'] as Map<String, dynamic>
        : const <String, dynamic>{};

    final purchaseMap = payload['purchaseOptions'] is Map<String, dynamic>
        ? payload['purchaseOptions'] as Map<String, dynamic>
        : const <String, dynamic>{};

    final rawFormula =
        payload['formulaStatic'] as List<dynamic>? ??
        (payload['formula'] is Map<String, dynamic>
                ? (payload['formula']
                      as Map<String, dynamic>)['detailedBreakdown']
                : null)
            as List<dynamic>? ??
        (payload['formula'] is Map<String, dynamic>
                ? (payload['formula']
                      as Map<String, dynamic>)['detailedBreakdown']
                : null)
            as List<dynamic>? ??
        (payload['inciAnalysis'] is Map<String, dynamic>
                ? (payload['inciAnalysis']
                      as Map<String, dynamic>)['detailedBreakdown']
                : null)
            as List<dynamic>? ??
        payload['detailedBreakdown'] as List<dynamic>? ??
        const [];

    final rawInci = payload['inciAnalysis'] is Map<String, dynamic>
        ? (payload['inciAnalysis'] as Map<String, dynamic>)['allIngredientsRaw']
              ?.toString()
        : payload['allIngredientsRaw']?.toString();

    final matchEval = payload['matchEvaluation'] is Map<String, dynamic>
        ? payload['matchEvaluation'] as Map<String, dynamic>
        : null;
    final rawPillars = matchEval?['pillars'] is Map<String, dynamic>
        ? matchEval!['pillars'] as Map<String, dynamic>
        : (payload['pillars'] is Map<String, dynamic>
              ? payload['pillars'] as Map<String, dynamic>
              : null);

    final rawAssistant = payload['aiAssistant'] is Map<String, dynamic>
        ? payload['aiAssistant'] as Map<String, dynamic>
        : null;

    final rawAlternatives =
        payload['alternatives'] as List<dynamic>? ??
        payload['marketAlternatives'] as List<dynamic>? ??
        const [];

    final rawSources =
        payload['scientificSources'] as List<dynamic>? ?? const [];

    final rawEndorsement = payload['medicalEndorsement'] is Map<String, dynamic>
        ? payload['medicalEndorsement'] as Map<String, dynamic>
        : null;

    return SkincareReportModel(
      product: ScannedProductInfoModel.fromJson(productMap),
      personalizedVerdict: PersonalizedProductVerdictModel.fromJson(verdictMap),
      applicationGuide: ProductApplicationGuideModel.fromJson(guideMap),
      purchaseOptions: ProductPurchaseOptionsModel.fromJson(purchaseMap),
      formulaStatic: rawFormula
          .whereType<Map<String, dynamic>>()
          .map(InciIngredientAnalysisModel.fromJson)
          .toList(),
      pillars: rawPillars != null
          ? ProductPillarsModel.fromJson(rawPillars)
          : null,
      aiAssistant: rawAssistant != null
          ? ProductAiAssistantModel.fromJson(rawAssistant)
          : null,
      alternatives: rawAlternatives
          .whereType<Map<String, dynamic>>()
          .map(ProductAlternativeModel.fromJson)
          .toList(),
      scientificSources: rawSources
          .whereType<Map<String, dynamic>>()
          .map(ScientificSourceModel.fromJson)
          .toList(),
      medicalEndorsement: rawEndorsement != null
          ? MedicalEndorsementModel.fromJson(rawEndorsement)
          : null,
      rawInciText: rawInci,
    );
  }

  /// Product metadata model.
  final ScannedProductInfoModel product;

  /// Personalized verdict model.
  final PersonalizedProductVerdictModel personalizedVerdict;

  /// Application guide model.
  final ProductApplicationGuideModel applicationGuide;

  /// Purchase options model.
  final ProductPurchaseOptionsModel purchaseOptions;

  /// INCI breakdown models.
  final List<InciIngredientAnalysisModel> formulaStatic;

  /// AI evaluation pillars model.
  final ProductPillarsModel? pillars;

  /// AI Assistant recommendations and questions model.
  final ProductAiAssistantModel? aiAssistant;

  /// Recommended alternatives.
  final List<ProductAlternativeModel> alternatives;

  /// Scientific literature citations.
  final List<ScientificSourceModel> scientificSources;

  /// Medical professional endorsement.
  final MedicalEndorsementModel? medicalEndorsement;

  /// Full raw INCI formula string.
  final String? rawInciText;

  /// Converts to pure domain [SkincareReport] entity.
  SkincareReport toEntity() => SkincareReport(
    product: product.toEntity(),
    personalizedVerdict: personalizedVerdict.toEntity(),
    applicationGuide: applicationGuide.toEntity(),
    purchaseOptions: purchaseOptions.toEntity(),
    formulaStatic: formulaStatic.map((f) => f.toEntity()).toList(),
    pillars: pillars?.toEntity(),
    aiAssistant: aiAssistant?.toEntity(),
    alternatives: alternatives.map((a) => a.toEntity()).toList(),
    scientificSources: scientificSources.map((s) => s.toEntity()).toList(),
    medicalEndorsement: medicalEndorsement?.toEntity(),
    rawInciText: rawInciText,
  );

  /// Serializes to JSON map.
  Map<String, dynamic> toJson() => {
    'product': product.toJson(),
    'personalizedVerdict': personalizedVerdict.toJson(),
    'applicationGuide': applicationGuide.toJson(),
    'purchaseOptions': purchaseOptions.toJson(),
    'formulaStatic': formulaStatic.map((f) => f.toJson()).toList(),
    if (pillars != null) 'pillars': pillars!.toJson(),
    if (aiAssistant != null) 'aiAssistant': aiAssistant!.toJson(),
    if (alternatives.isNotEmpty)
      'alternatives': alternatives.map((a) => a.toJson()).toList(),
    if (scientificSources.isNotEmpty)
      'scientificSources': scientificSources.map((s) => s.toJson()).toList(),
    if (medicalEndorsement != null)
      'medicalEndorsement': medicalEndorsement!.toJson(),
    if (rawInciText != null) 'rawInciText': rawInciText,
  };
}

/// Data model for [ScannedProductInfo].
class ScannedProductInfoModel {
  /// Creates a [ScannedProductInfoModel].
  const ScannedProductInfoModel({
    required this.brand,
    required this.name,
    required this.category,
    this.imageUrl,
  });

  /// Deserializes from JSON.
  factory ScannedProductInfoModel.fromJson(Map<String, dynamic> json) {
    return ScannedProductInfoModel(
      brand: json['brand']?.toString() ?? 'Skincare',
      name: json['name']?.toString() ?? 'Analyzed Formula',
      category: json['category']?.toString() ?? 'Care',
      imageUrl: json['imageUrl']?.toString(),
    );
  }

  final String brand;
  final String name;
  final String category;
  final String? imageUrl;

  /// Converts to domain entity.
  ScannedProductInfo toEntity() => ScannedProductInfo(
    brand: brand,
    name: name,
    category: category,
    imageUrl: imageUrl,
  );

  /// Serializes to JSON.
  Map<String, dynamic> toJson() => {
    'brand': brand,
    'name': name,
    'category': category,
    if (imageUrl != null) 'imageUrl': imageUrl,
  };
}

/// Data model for [PersonalizedProductVerdict].
class PersonalizedProductVerdictModel {
  /// Creates a [PersonalizedProductVerdictModel].
  const PersonalizedProductVerdictModel({
    required this.matchScore,
    required this.matchVerdict,
    required this.headlineReason,
    required this.explanation,
    required this.benefitsForUser,
    required this.concernsOrRisksForUser,
    required this.routineCompatibility,
  });

  /// Deserializes from JSON.
  factory PersonalizedProductVerdictModel.fromJson(Map<String, dynamic> json) {
    final matchEval = json['matchEvaluation'] is Map<String, dynamic>
        ? json['matchEvaluation'] as Map<String, dynamic>
        : null;
    final pillars = matchEval?['pillars'] is Map<String, dynamic>
        ? matchEval!['pillars'] as Map<String, dynamic>
        : null;
    final aiAssistant = json['aiAssistant'] is Map<String, dynamic>
        ? json['aiAssistant'] as Map<String, dynamic>
        : null;

    final rawScore =
        json['matchScore'] as num? ??
        matchEval?['overallFitPercentage'] as num? ??
        json['overallFitPercentage'] as num?;
    final score = rawScore != null
        ? (rawScore <= 10 && rawScore > 0
              ? (rawScore * 10).round()
              : rawScore.round())
        : 88;

    final skinFit = pillars?['skinFit'] is Map
        ? pillars!['skinFit'] as Map
        : null;
    final effectiveness = pillars?['effectiveness'] is Map
        ? pillars!['effectiveness'] as Map
        : null;
    final safety = pillars?['safety'] is Map ? pillars!['safety'] as Map : null;

    final rawBenefits = json['benefitsForUser'] ?? json['keyBenefits'];
    final List<String> benefits;
    if (rawBenefits is List) {
      benefits = rawBenefits.map((e) => e.toString()).toList();
    } else if (rawBenefits is String && rawBenefits.isNotEmpty) {
      benefits = <String>[rawBenefits];
    } else if (pillars != null) {
      benefits = <String>[
        if (skinFit?['explanation'] != null) skinFit!['explanation'].toString(),
        if (effectiveness?['explanation'] != null)
          effectiveness!['explanation'].toString(),
      ];
    } else {
      benefits = const <String>[];
    }

    final rawRisks = json['concernsOrRisksForUser'];
    final List<String> risks;
    if (rawRisks is List) {
      risks = rawRisks.map((e) => e.toString()).toList();
    } else if (rawRisks is String && rawRisks.isNotEmpty) {
      risks = <String>[rawRisks];
    } else if (safety?['explanation'] != null) {
      risks = <String>[safety!['explanation'].toString()];
    } else {
      risks = const <String>[];
    }

    final conflictWarning = aiAssistant?['routineConflictWarning']?.toString();
    final compatMap = json['routineCompatibility'] is Map<String, dynamic>
        ? json['routineCompatibility'] as Map<String, dynamic>
        : <String, dynamic>{
            'isCompatibleWithCurrentRoutine': conflictWarning == null,
            'conflictingIngredients': conflictWarning != null
                ? <String>[conflictWarning]
                : const <String>[],
            'integrationAdvice':
                aiAssistant?['shortExplanation']?.toString() ??
                'Apply after cleansing and before heavier moisturizers or SPF.',
          };

    final rawHeadline =
        json['headlineReason']?.toString() ??
        matchEval?['executiveSummary']?.toString() ??
        aiAssistant?['shortExplanation']?.toString() ??
        'Well-suited to support your skin barrier and goals.';

    final rawExplanation =
        json['explanation']?.toString() ??
        matchEval?['executiveSummary']?.toString() ??
        aiAssistant?['shortExplanation']?.toString() ??
        'Formulated with barrier-friendly actives aligned with your profile.';

    return PersonalizedProductVerdictModel(
      matchScore: score.clamp(0, 100),
      matchVerdict:
          json['matchVerdict']?.toString() ??
          (score >= 85 ? '$score% Match · High Fit' : '$score% Match'),
      headlineReason: rawHeadline,
      explanation: rawExplanation,
      benefitsForUser: benefits,
      concernsOrRisksForUser: risks,
      routineCompatibility: RoutineCompatibilityModel.fromJson(compatMap),
    );
  }

  final int matchScore;
  final String matchVerdict;
  final String headlineReason;
  final String explanation;
  final List<String> benefitsForUser;
  final List<String> concernsOrRisksForUser;
  final RoutineCompatibilityModel routineCompatibility;

  /// Converts to domain entity.
  PersonalizedProductVerdict toEntity() => PersonalizedProductVerdict(
    matchScore: matchScore,
    matchVerdict: matchVerdict,
    headlineReason: headlineReason,
    explanation: explanation,
    benefitsForUser: benefitsForUser,
    concernsOrRisksForUser: concernsOrRisksForUser,
    routineCompatibility: routineCompatibility.toEntity(),
  );

  /// Serializes to JSON.
  Map<String, dynamic> toJson() => {
    'matchScore': matchScore,
    'matchVerdict': matchVerdict,
    'headlineReason': headlineReason,
    'explanation': explanation,
    'benefitsForUser': benefitsForUser,
    'concernsOrRisksForUser': concernsOrRisksForUser,
    'routineCompatibility': routineCompatibility.toJson(),
  };
}

/// Data model for [RoutineCompatibility].
class RoutineCompatibilityModel {
  /// Creates a [RoutineCompatibilityModel].
  const RoutineCompatibilityModel({
    required this.isCompatibleWithCurrentRoutine,
    required this.conflictingIngredients,
    required this.integrationAdvice,
  });

  /// Deserializes from JSON.
  factory RoutineCompatibilityModel.fromJson(Map<String, dynamic> json) {
    final rawConflicts =
        json['conflictingIngredients'] as List<dynamic>? ?? const [];
    return RoutineCompatibilityModel(
      isCompatibleWithCurrentRoutine:
          json['isCompatibleWithCurrentRoutine'] as bool? ?? true,
      conflictingIngredients: rawConflicts.map((e) => e.toString()).toList(),
      integrationAdvice:
          json['integrationAdvice']?.toString() ??
          'Apply after cleansing and before heavier moisturizers or SPF.',
    );
  }

  final bool isCompatibleWithCurrentRoutine;
  final List<String> conflictingIngredients;
  final String integrationAdvice;

  /// Converts to domain entity.
  RoutineCompatibility toEntity() => RoutineCompatibility(
    isCompatibleWithCurrentRoutine: isCompatibleWithCurrentRoutine,
    conflictingIngredients: conflictingIngredients,
    integrationAdvice: integrationAdvice,
  );

  /// Serializes to JSON.
  Map<String, dynamic> toJson() => {
    'isCompatibleWithCurrentRoutine': isCompatibleWithCurrentRoutine,
    'conflictingIngredients': conflictingIngredients,
    'integrationAdvice': integrationAdvice,
  };
}

/// Data model for [ProductApplicationGuide].
class ProductApplicationGuideModel {
  /// Creates a [ProductApplicationGuideModel].
  const ProductApplicationGuideModel({
    required this.steps,
    this.videoUrl,
    this.thumbnailUrl,
    this.durationText,
  });

  /// Deserializes from JSON.
  factory ProductApplicationGuideModel.fromJson(Map<String, dynamic> json) {
    final rawSteps = json['steps'] ?? json['instructions'];
    final steps = rawSteps is List
        ? rawSteps.map((e) => e.toString()).toList()
        : (rawSteps is String && rawSteps.isNotEmpty)
        ? <String>[rawSteps]
        : const <String>[
            'Apply a pea-sized amount to clean, slightly damp skin.',
            'Follow with moisturizer and broad-spectrum SPF 50 in the morning.',
          ];

    final videoObj = json['videoTutorial'] is Map<String, dynamic>
        ? json['videoTutorial'] as Map<String, dynamic>
        : null;
    final videoUrl =
        json['videoUrl']?.toString() ?? videoObj?['videoUrl']?.toString();
    final thumbnailUrl =
        json['thumbnailUrl']?.toString() ??
        videoObj?['thumbnailUrl']?.toString();
    final durationText =
        json['durationText']?.toString() ??
        videoObj?['durationText']?.toString();

    return ProductApplicationGuideModel(
      steps: steps,
      videoUrl: videoUrl,
      thumbnailUrl: thumbnailUrl,
      durationText: durationText,
    );
  }

  final List<String> steps;
  final String? videoUrl;
  final String? thumbnailUrl;
  final String? durationText;

  /// Converts to domain entity.
  ProductApplicationGuide toEntity() => ProductApplicationGuide(
    steps: steps,
    videoUrl: videoUrl,
    thumbnailUrl: thumbnailUrl,
    durationText: durationText,
  );

  /// Serializes to JSON.
  Map<String, dynamic> toJson() => {
    'steps': steps,
    if (videoUrl != null) 'videoUrl': videoUrl,
    if (thumbnailUrl != null) 'thumbnailUrl': thumbnailUrl,
    if (durationText != null) 'durationText': durationText,
  };
}

/// Data model for [ProductPurchaseOptions].
class ProductPurchaseOptionsModel {
  /// Creates a [ProductPurchaseOptionsModel].
  const ProductPurchaseOptionsModel({
    required this.available,
    this.retailerName,
    this.price,
    this.currency,
    this.productUrl,
  });

  /// Deserializes from JSON.
  factory ProductPurchaseOptionsModel.fromJson(Map<String, dynamic> json) {
    return ProductPurchaseOptionsModel(
      available: json['available'] as bool? ?? false,
      retailerName: json['retailerName']?.toString(),
      price: (json['price'] as num?)?.toDouble(),
      currency: json['currency']?.toString(),
      productUrl: json['productUrl']?.toString(),
    );
  }

  final bool available;
  final String? retailerName;
  final double? price;
  final String? currency;
  final String? productUrl;

  /// Converts to domain entity.
  ProductPurchaseOptions toEntity() => ProductPurchaseOptions(
    available: available,
    retailerName: retailerName,
    price: price,
    currency: currency,
    productUrl: productUrl,
  );

  /// Serializes to JSON.
  Map<String, dynamic> toJson() => {
    'available': available,
    if (retailerName != null) 'retailerName': retailerName,
    if (price != null) 'price': price,
    if (currency != null) 'currency': currency,
    if (productUrl != null) 'productUrl': productUrl,
  };
}

/// Data model for [InciIngredientAnalysis].
class InciIngredientAnalysisModel {
  /// Creates an [InciIngredientAnalysisModel].
  const InciIngredientAnalysisModel({
    required this.inciName,
    required this.function,
    required this.safetyRating,
    required this.comedogenicityIndex,
    required this.isPregnancySafe,
    this.commonName,
    this.irritancyIndex = 0,
    this.isFungalAcneTrigger = false,
  });

  /// Deserializes from JSON.
  factory InciIngredientAnalysisModel.fromJson(Map<String, dynamic> json) {
    final rawComedogenic =
        json['comedogenicityIndex'] ?? json['comedogenicity'];
    final rawPregnancy = json['isPregnancySafe'] ?? json['pregnancySafe'];
    final rawIrritancy =
        json['irritancy'] as num? ?? json['irritancyIndex'] as num?;
    final derivedSafety = rawIrritancy != null
        ? (rawIrritancy >= 3
              ? 'caution'
              : (rawIrritancy >= 2 ? 'moderate' : 'safe'))
        : (json['safetyRating']?.toString() ?? 'safe');

    return InciIngredientAnalysisModel(
      inciName:
          json['inciName']?.toString() ??
          json['ingredientName']?.toString() ??
          'Unknown Ingredient',
      commonName: json['commonName']?.toString(),
      function:
          json['function']?.toString() ??
          json['commonName']?.toString() ??
          'Formulation base',
      safetyRating: derivedSafety,
      comedogenicityIndex: ((rawComedogenic as num?)?.round() ?? 0).clamp(0, 5),
      irritancyIndex: (rawIrritancy?.round() ?? 0).clamp(0, 5),
      isPregnancySafe: rawPregnancy as bool? ?? true,
      isFungalAcneTrigger:
          (json['isFungalAcneTrigger'] ?? json['fungalAcneTrigger']) as bool? ??
          false,
    );
  }

  final String inciName;
  final String? commonName;
  final String function;
  final String safetyRating;
  final int comedogenicityIndex;
  final int irritancyIndex;
  final bool isPregnancySafe;
  final bool isFungalAcneTrigger;

  /// Converts to domain entity.
  InciIngredientAnalysis toEntity() => InciIngredientAnalysis(
    inciName: inciName,
    commonName: commonName,
    function: function,
    safetyRating: safetyRating,
    comedogenicityIndex: comedogenicityIndex,
    irritancyIndex: irritancyIndex,
    isPregnancySafe: isPregnancySafe,
    isFungalAcneTrigger: isFungalAcneTrigger,
  );

  /// Serializes to JSON.
  Map<String, dynamic> toJson() => {
    'inciName': inciName,
    if (commonName != null) 'commonName': commonName,
    'function': function,
    'safetyRating': safetyRating,
    'comedogenicityIndex': comedogenicityIndex,
    'irritancyIndex': irritancyIndex,
    'isPregnancySafe': isPregnancySafe,
    'isFungalAcneTrigger': isFungalAcneTrigger,
  };
}

/// Data model for [ProductPillars].
class ProductPillarsModel {
  const ProductPillarsModel({
    this.skinFit,
    this.effectiveness,
    this.safety,
  });

  factory ProductPillarsModel.fromJson(Map<String, dynamic> json) {
    final rawSkin = json['skinFit'] as Map<String, dynamic>?;
    final rawEffect = json['effectiveness'] as Map<String, dynamic>?;
    final rawSafety = json['safety'] as Map<String, dynamic>?;

    return ProductPillarsModel(
      skinFit: rawSkin != null ? PillarDetailModel.fromJson(rawSkin) : null,
      effectiveness: rawEffect != null
          ? PillarDetailModel.fromJson(rawEffect)
          : null,
      safety: rawSafety != null
          ? SafetyPillarDetailModel.fromJson(rawSafety)
          : null,
    );
  }

  final PillarDetailModel? skinFit;
  final PillarDetailModel? effectiveness;
  final SafetyPillarDetailModel? safety;

  ProductPillars toEntity() => ProductPillars(
    skinFit: skinFit?.toEntity(),
    effectiveness: effectiveness?.toEntity(),
    safety: safety?.toEntity(),
  );

  Map<String, dynamic> toJson() => {
    if (skinFit != null) 'skinFit': skinFit!.toJson(),
    if (effectiveness != null) 'effectiveness': effectiveness!.toJson(),
    if (safety != null) 'safety': safety!.toJson(),
  };
}

/// Data model for [PillarDetail].
class PillarDetailModel {
  const PillarDetailModel({
    required this.level,
    required this.score,
    required this.title,
    required this.explanation,
  });

  factory PillarDetailModel.fromJson(Map<String, dynamic> json) {
    return PillarDetailModel(
      level: json['level']?.toString() ?? 'High',
      score: ((json['score'] as num?)?.round() ?? 85).clamp(0, 100),
      title: json['title']?.toString() ?? 'Pillar Fit',
      explanation: json['explanation']?.toString() ?? '',
    );
  }

  final String level;
  final int score;
  final String title;
  final String explanation;

  PillarDetail toEntity() => PillarDetail(
    level: level,
    score: score,
    title: title,
    explanation: explanation,
  );

  Map<String, dynamic> toJson() => {
    'level': level,
    'score': score,
    'title': title,
    'explanation': explanation,
  };
}

/// Data model for [SafetyPillarDetail].
class SafetyPillarDetailModel extends PillarDetailModel {
  const SafetyPillarDetailModel({
    required super.level,
    required super.score,
    required super.title,
    required super.explanation,
    this.pregnancySafe = true,
    this.fungalAcneSafe = true,
  });

  factory SafetyPillarDetailModel.fromJson(Map<String, dynamic> json) {
    return SafetyPillarDetailModel(
      level: json['level']?.toString() ?? 'High',
      score: ((json['score'] as num?)?.round() ?? 90).clamp(0, 100),
      title: json['title']?.toString() ?? 'Safety',
      explanation: json['explanation']?.toString() ?? '',
      pregnancySafe: json['pregnancySafe'] as bool? ?? true,
      fungalAcneSafe: json['fungalAcneSafe'] as bool? ?? true,
    );
  }

  final bool pregnancySafe;
  final bool fungalAcneSafe;

  @override
  SafetyPillarDetail toEntity() => SafetyPillarDetail(
    level: level,
    score: score,
    title: title,
    explanation: explanation,
    pregnancySafe: pregnancySafe,
    fungalAcneSafe: fungalAcneSafe,
  );

  @override
  Map<String, dynamic> toJson() => {
    ...super.toJson(),
    'pregnancySafe': pregnancySafe,
    'fungalAcneSafe': fungalAcneSafe,
  };
}

/// Data model for [ProductAiAssistant].
class ProductAiAssistantModel {
  const ProductAiAssistantModel({
    this.shortExplanation,
    this.suggestedQuestions = const [],
    this.routineConflictWarning,
    this.environmentalTip,
  });

  factory ProductAiAssistantModel.fromJson(Map<String, dynamic> json) {
    final rawQuestions =
        json['suggestedQuestions'] as List<dynamic>? ?? const [];
    return ProductAiAssistantModel(
      shortExplanation: json['shortExplanation']?.toString(),
      suggestedQuestions: rawQuestions
          .whereType<Map<String, dynamic>>()
          .map(SuggestedQuestionModel.fromJson)
          .toList(),
      routineConflictWarning: json['routineConflictWarning']?.toString(),
      environmentalTip: json['environmentalTip']?.toString(),
    );
  }

  final String? shortExplanation;
  final List<SuggestedQuestionModel> suggestedQuestions;
  final String? routineConflictWarning;
  final String? environmentalTip;

  ProductAiAssistant toEntity() => ProductAiAssistant(
    shortExplanation: shortExplanation,
    suggestedQuestions: suggestedQuestions.map((q) => q.toEntity()).toList(),
    routineConflictWarning: routineConflictWarning,
    environmentalTip: environmentalTip,
  );

  Map<String, dynamic> toJson() => {
    if (shortExplanation != null) 'shortExplanation': shortExplanation,
    'suggestedQuestions': suggestedQuestions.map((q) => q.toJson()).toList(),
    if (routineConflictWarning != null)
      'routineConflictWarning': routineConflictWarning,
    if (environmentalTip != null) 'environmentalTip': environmentalTip,
  };
}

/// Data model for [SuggestedQuestion].
class SuggestedQuestionModel {
  const SuggestedQuestionModel({
    required this.emoji,
    required this.question,
  });

  factory SuggestedQuestionModel.fromJson(Map<String, dynamic> json) {
    return SuggestedQuestionModel(
      emoji: json['emoji']?.toString() ?? '💬',
      question: json['question']?.toString() ?? '',
    );
  }

  final String emoji;
  final String question;

  SuggestedQuestion toEntity() => SuggestedQuestion(
    emoji: emoji,
    question: question,
  );

  Map<String, dynamic> toJson() => {
    'emoji': emoji,
    'question': question,
  };
}

/// Data model for [ProductAlternative].
class ProductAlternativeModel {
  const ProductAlternativeModel({
    required this.brand,
    required this.name,
    this.imageUrl,
    this.fitPercentage,
    this.estimatedPrice,
    this.currency,
    this.purchaseUrl,
    this.isBudgetDupe = false,
  });

  factory ProductAlternativeModel.fromJson(Map<String, dynamic> json) {
    return ProductAlternativeModel(
      brand: json['brand']?.toString() ?? '',
      name:
          json['name']?.toString() ?? json['alternativeName']?.toString() ?? '',
      imageUrl: json['imageUrl']?.toString(),
      fitPercentage: (json['fitPercentage'] as num?)?.round(),
      estimatedPrice: (json['estimatedPrice'] as num?)?.toDouble(),
      currency: json['currency']?.toString() ?? 'USD',
      purchaseUrl: json['purchaseUrl']?.toString(),
      isBudgetDupe: json['isBudgetDupe'] as bool? ?? false,
    );
  }

  final String brand;
  final String name;
  final String? imageUrl;
  final int? fitPercentage;
  final double? estimatedPrice;
  final String? currency;
  final String? purchaseUrl;
  final bool isBudgetDupe;

  ProductAlternative toEntity() => ProductAlternative(
    brand: brand,
    name: name,
    imageUrl: imageUrl,
    fitPercentage: fitPercentage,
    estimatedPrice: estimatedPrice,
    currency: currency,
    purchaseUrl: purchaseUrl,
    isBudgetDupe: isBudgetDupe,
  );

  Map<String, dynamic> toJson() => {
    'brand': brand,
    'name': name,
    if (imageUrl != null) 'imageUrl': imageUrl,
    if (fitPercentage != null) 'fitPercentage': fitPercentage,
    if (estimatedPrice != null) 'estimatedPrice': estimatedPrice,
    if (currency != null) 'currency': currency,
    if (purchaseUrl != null) 'purchaseUrl': purchaseUrl,
    'isBudgetDupe': isBudgetDupe,
  };
}

/// Data model for [ScientificSource].
class ScientificSourceModel {
  const ScientificSourceModel({
    required this.organizationName,
    this.url,
  });

  factory ScientificSourceModel.fromJson(Map<String, dynamic> json) {
    return ScientificSourceModel(
      organizationName:
          json['organizationName']?.toString() ?? 'Research Entity',
      url: json['url']?.toString(),
    );
  }

  final String organizationName;
  final String? url;

  ScientificSource toEntity() => ScientificSource(
    organizationName: organizationName,
    url: url,
  );

  Map<String, dynamic> toJson() => {
    'organizationName': organizationName,
    if (url != null) 'url': url,
  };
}

/// Data model for [MedicalEndorsement].
class MedicalEndorsementModel {
  const MedicalEndorsementModel({
    required this.doctorName,
    required this.credentials,
  });

  factory MedicalEndorsementModel.fromJson(Map<String, dynamic> json) {
    return MedicalEndorsementModel(
      doctorName: json['doctorName']?.toString() ?? 'Medical Professional',
      credentials: json['credentials']?.toString() ?? 'Dermatologist',
    );
  }

  final String doctorName;
  final String credentials;

  MedicalEndorsement toEntity() => MedicalEndorsement(
    doctorName: doctorName,
    credentials: credentials,
  );

  Map<String, dynamic> toJson() => {
    'doctorName': doctorName,
    'credentials': credentials,
  };
}
