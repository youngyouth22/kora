// ignore_for_file: document_ignores, lines_longer_than_80_chars, public_member_api_docs

import 'package:equatable/equatable.dart';

/// Pure domain entity representing the personalized skincare product report
/// returned by `POST /api/scan-product` on the Kora AI Backend.
class SkincareReport extends Equatable {
  /// Creates a [SkincareReport].
  const SkincareReport({
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

  /// Normalized product identity (brand, name, category, image).
  final ScannedProductInfo product;

  /// Personalized compatibility verdict for the user's skin profile.
  final PersonalizedProductVerdict personalizedVerdict;

  /// Step-by-step application instructions and optional YouTube tutorial.
  final ProductApplicationGuide applicationGuide;

  /// External retail purchase availability and pricing.
  final ProductPurchaseOptions purchaseOptions;

  /// Detailed INCI formula breakdown with safety and comedogenicity ratings.
  final List<InciIngredientAnalysis> formulaStatic;

  /// Three core AI evaluation pillars (Skin Fit, Effectiveness, Safety).
  final ProductPillars? pillars;

  /// AI Assistant recommendations, suggested questions, and environmental tips.
  final ProductAiAssistant? aiAssistant;

  /// Similar or budget dupe product alternatives.
  final List<ProductAlternative> alternatives;

  /// Scientific literature and institutional citations (NIH, AAD, FDA).
  final List<ScientificSource> scientificSources;

  /// Dermatological credentials endorsement.
  final MedicalEndorsement? medicalEndorsement;

  /// Full raw comma-separated INCI formula text.
  final String? rawInciText;

  @override
  List<Object?> get props => [
    product,
    personalizedVerdict,
    applicationGuide,
    purchaseOptions,
    formulaStatic,
    pillars,
    aiAssistant,
    alternatives,
    scientificSources,
    medicalEndorsement,
    rawInciText,
  ];
}

/// Normalized product metadata.
class ScannedProductInfo extends Equatable {
  /// Creates a [ScannedProductInfo].
  const ScannedProductInfo({
    required this.brand,
    required this.name,
    required this.category,
    this.imageUrl,
  });

  /// Brand name (e.g. 'La Roche-Posay', 'CeraVe').
  final String brand;

  /// Normalized product name.
  final String name;

  /// Product category (e.g. 'Serum', 'Cleanser', 'Moisturizer').
  final String category;

  /// Optional product image URL.
  final String? imageUrl;

  @override
  List<Object?> get props => [brand, name, category, imageUrl];
}

/// Personalized compatibility evaluation tailored to the user's skin profile.
class PersonalizedProductVerdict extends Equatable {
  /// Creates a [PersonalizedProductVerdict].
  const PersonalizedProductVerdict({
    required this.matchScore,
    required this.matchVerdict,
    required this.headlineReason,
    required this.explanation,
    required this.benefitsForUser,
    required this.concernsOrRisksForUser,
    required this.routineCompatibility,
  });

  /// Compatibility score from 0 to 100.
  final int matchScore;

  /// Qualitative verdict label (e.g. 'Excellent match', 'Use with caution').
  final String matchVerdict;

  /// Concise one-line summary of the verdict.
  final String headlineReason;

  /// Detailed pedagogical explanation of the verdict.
  final String explanation;

  /// Specific benefits targeting the user's concerns and skin type.
  final List<String> benefitsForUser;

  /// Potential risks, irritants, or precautions for the user.
  final List<String> concernsOrRisksForUser;

  /// Compatibility with the user's existing routine ingredients.
  final RoutineCompatibility routineCompatibility;

  @override
  List<Object?> get props => [
    matchScore,
    matchVerdict,
    headlineReason,
    explanation,
    benefitsForUser,
    concernsOrRisksForUser,
    routineCompatibility,
  ];
}

/// Routine layering and active conflict evaluation.
class RoutineCompatibility extends Equatable {
  /// Creates a [RoutineCompatibility].
  const RoutineCompatibility({
    required this.isCompatibleWithCurrentRoutine,
    required this.conflictingIngredients,
    required this.integrationAdvice,
  });

  /// Whether the product can be safely integrated into the current routine.
  final bool isCompatibleWithCurrentRoutine;

  /// List of active ingredients in the user's routine that may conflict.
  final List<String> conflictingIngredients;

  /// Practical layering and scheduling advice (AM/PM, frequency).
  final String integrationAdvice;

  @override
  List<Object?> get props => [
    isCompatibleWithCurrentRoutine,
    conflictingIngredients,
    integrationAdvice,
  ];
}

/// Application guide and video tutorial metadata.
class ProductApplicationGuide extends Equatable {
  /// Creates a [ProductApplicationGuide].
  const ProductApplicationGuide({
    required this.steps,
    this.videoUrl,
    this.thumbnailUrl,
    this.durationText,
  });

  /// Ordered step-by-step application instructions.
  final List<String> steps;

  /// Optional YouTube video tutorial URL.
  final String? videoUrl;

  /// Optional video thumbnail image URL.
  final String? thumbnailUrl;

  /// Optional human-readable video duration (e.g. '2:15').
  final String? durationText;

  @override
  List<Object?> get props => [steps, videoUrl, thumbnailUrl, durationText];
}

/// Retail availability and pricing information.
class ProductPurchaseOptions extends Equatable {
  /// Creates a [ProductPurchaseOptions].
  const ProductPurchaseOptions({
    required this.available,
    this.retailerName,
    this.price,
    this.currency,
    this.productUrl,
  });

  /// Whether a purchase link was found.
  final bool available;

  /// Retailer name (e.g. 'Sephora', 'Dermstore').
  final String? retailerName;

  /// Listed product price.
  final double? price;

  /// Currency code or symbol (e.g. 'EUR', 'USD').
  final String? currency;

  /// External URL to view or purchase the product.
  final String? productUrl;

  @override
  List<Object?> get props => [
    available,
    retailerName,
    price,
    currency,
    productUrl,
  ];
}

/// Individual INCI ingredient safety and comedogenicity profile.
class InciIngredientAnalysis extends Equatable {
  /// Creates an [InciIngredientAnalysis].
  const InciIngredientAnalysis({
    required this.inciName,
    required this.function,
    required this.safetyRating,
    required this.comedogenicityIndex,
    required this.isPregnancySafe,
    this.commonName,
    this.irritancyIndex = 0,
    this.isFungalAcneTrigger = false,
  });

  /// Standardized INCI ingredient name (e.g. 'Niacinamide').
  final String inciName;

  /// Optional common consumer name (e.g. 'Vitamin B3').
  final String? commonName;

  /// Functional role in the formula (e.g. 'Barrier support & pore refining').
  final String function;

  /// Safety rating label (e.g. 'low_risk', 'moderate_risk', 'high_risk', 'safe').
  final String safetyRating;

  /// Comedogenicity scale from 0 (non-comedogenic) to 5 (high pore-clogging risk).
  final int comedogenicityIndex;

  /// Irritancy scale from 0 to 5.
  final int irritancyIndex;

  /// Whether the ingredient is considered safe during pregnancy/nursing.
  final bool isPregnancySafe;

  /// Whether this ingredient is a known trigger for fungal acne (Malassezia).
  final bool isFungalAcneTrigger;

  @override
  List<Object?> get props => [
    inciName,
    commonName,
    function,
    safetyRating,
    comedogenicityIndex,
    irritancyIndex,
    isPregnancySafe,
    isFungalAcneTrigger,
  ];
}

/// Three core evaluation pillars generated by the AI agent.
class ProductPillars extends Equatable {
  /// Creates a [ProductPillars].
  const ProductPillars({
    this.skinFit,
    this.effectiveness,
    this.safety,
  });

  final PillarDetail? skinFit;
  final PillarDetail? effectiveness;
  final SafetyPillarDetail? safety;

  @override
  List<Object?> get props => [skinFit, effectiveness, safety];
}

/// Single analytical pillar detail.
class PillarDetail extends Equatable {
  /// Creates a [PillarDetail].
  const PillarDetail({
    required this.level,
    required this.score,
    required this.title,
    required this.explanation,
  });

  final String level;
  final int score;
  final String title;
  final String explanation;

  @override
  List<Object?> get props => [level, score, title, explanation];
}

/// Safety pillar with pregnancy and fungal acne indicators.
class SafetyPillarDetail extends PillarDetail {
  /// Creates a [SafetyPillarDetail].
  const SafetyPillarDetail({
    required super.level,
    required super.score,
    required super.title,
    required super.explanation,
    this.pregnancySafe = true,
    this.fungalAcneSafe = true,
  });

  final bool pregnancySafe;
  final bool fungalAcneSafe;

  @override
  List<Object?> get props => [...super.props, pregnancySafe, fungalAcneSafe];
}

/// AI Assistant recommendation metadata.
class ProductAiAssistant extends Equatable {
  /// Creates a [ProductAiAssistant].
  const ProductAiAssistant({
    this.shortExplanation,
    this.suggestedQuestions = const [],
    this.routineConflictWarning,
    this.environmentalTip,
  });

  final String? shortExplanation;
  final List<SuggestedQuestion> suggestedQuestions;
  final String? routineConflictWarning;
  final String? environmentalTip;

  @override
  List<Object?> get props => [
    shortExplanation,
    suggestedQuestions,
    routineConflictWarning,
    environmentalTip,
  ];
}

/// Interactive suggested question for the AI coach.
class SuggestedQuestion extends Equatable {
  /// Creates a [SuggestedQuestion].
  const SuggestedQuestion({
    required this.emoji,
    required this.question,
  });

  final String emoji;
  final String question;

  @override
  List<Object?> get props => [emoji, question];
}

/// Recommended market alternative or budget dupe.
class ProductAlternative extends Equatable {
  /// Creates a [ProductAlternative].
  const ProductAlternative({
    required this.brand,
    required this.name,
    this.imageUrl,
    this.fitPercentage,
    this.estimatedPrice,
    this.currency,
    this.purchaseUrl,
    this.isBudgetDupe = false,
  });

  final String brand;
  final String name;
  final String? imageUrl;
  final int? fitPercentage;
  final double? estimatedPrice;
  final String? currency;
  final String? purchaseUrl;
  final bool isBudgetDupe;

  @override
  List<Object?> get props => [
    brand,
    name,
    imageUrl,
    fitPercentage,
    estimatedPrice,
    currency,
    purchaseUrl,
    isBudgetDupe,
  ];
}

/// Scientific citation supporting the product verdict.
class ScientificSource extends Equatable {
  /// Creates a [ScientificSource].
  const ScientificSource({
    required this.organizationName,
    this.url,
  });

  final String organizationName;
  final String? url;

  @override
  List<Object?> get props => [organizationName, url];
}

/// Medical professional endorsement.
class MedicalEndorsement extends Equatable {
  /// Creates a [MedicalEndorsement].
  const MedicalEndorsement({
    required this.doctorName,
    required this.credentials,
  });

  final String doctorName;
  final String credentials;

  @override
  List<Object?> get props => [doctorName, credentials];
}
