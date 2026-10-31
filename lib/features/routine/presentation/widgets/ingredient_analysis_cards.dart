// ignore_for_file: document_ignores, lines_longer_than_80_chars, avoid_redundant_argument_values

import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:kora/common/app_colors.dart';
import 'package:kora/common/app_typography.dart';
import 'package:kora/common/widgets/kora_card.dart';
import 'package:kora/core/router/app_routes.dart';
import 'package:kora/features/product_scanner/domain/entities/skincare_report.dart';

/// Header card showing product name, brand, category, match gauge,
/// and personalized verdict explanation.
class IngredientProductHeaderCard extends StatelessWidget {
  /// Creates an [IngredientProductHeaderCard].
  const IngredientProductHeaderCard({
    required this.brand,
    required this.productName,
    required this.verdictLabel,
    required this.matchScore,
    required this.headlineReason,
    required this.explanation,
    this.category,
    this.imageUrl,
    super.key,
  });

  /// Brand name.
  final String brand;

  /// Product name.
  final String productName;

  /// Category name.
  final String? category;

  /// Product image URL.
  final String? imageUrl;

  /// Match verdict label.
  final String verdictLabel;

  /// Match score (0..100).
  final int matchScore;

  /// Headline summary reason.
  final String headlineReason;

  /// Detailed explanation text.
  final String explanation;

  @override
  Widget build(BuildContext context) {
    final isHighMatch = matchScore >= 75;

    return KoraCard(
      backgroundColor: AppColors.grey50,
      borderColor: AppColors.grey300,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              if (imageUrl != null && imageUrl!.trim().isNotEmpty) ...[
                Container(
                  width: 56,
                  height: 56,
                  decoration: BoxDecoration(
                    color: AppColors.grey100,
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: AppColors.grey300),
                  ),
                  clipBehavior: Clip.antiAlias,
                  child: Image.network(
                    imageUrl!,
                    fit: BoxFit.cover,
                    errorBuilder: (context, error, stackTrace) => const Icon(
                      Icons.spa_rounded,
                      color: AppColors.primary700,
                      size: 24,
                    ),
                  ),
                ),
                const SizedBox(width: 12),
              ],
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    if (brand.isNotEmpty)
                      Text(
                        brand.toUpperCase(),
                        style: AppTypography.bodyXsBold.copyWith(
                          color: AppColors.primary700,
                          letterSpacing: 1.1,
                        ),
                      ),
                    const SizedBox(height: 2),
                    Text(
                      productName,
                      style: AppTypography.h6Bold.copyWith(
                        color: AppColors.grey1050,
                      ),
                    ),
                    if (category != null && category!.trim().isNotEmpty) ...[
                      const SizedBox(height: 4),
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 8,
                          vertical: 2,
                        ),
                        decoration: BoxDecoration(
                          color: AppColors.grey100,
                          borderRadius: BorderRadius.circular(6),
                          border: Border.all(color: AppColors.grey300),
                        ),
                        child: Text(
                          category!,
                          style: AppTypography.bodyXsMedium.copyWith(
                            color: AppColors.grey800,
                          ),
                        ),
                      ),
                    ],
                  ],
                ),
              ),
              const SizedBox(width: 12),
              Semantics(
                label: 'Compatibility score $matchScore percent',
                child: Container(
                  width: 60,
                  height: 60,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: isHighMatch
                        ? AppColors.primary50
                        : AppColors.secondary50,
                    border: Border.all(
                      color: isHighMatch
                          ? AppColors.primary600
                          : AppColors.secondary600,
                      width: 2,
                    ),
                  ),
                  child: Center(
                    child: Text(
                      '$matchScore%',
                      style: AppTypography.bodyLBold.copyWith(
                        color: AppColors.grey1050,
                      ),
                    ),
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
            decoration: BoxDecoration(
              color: isHighMatch ? AppColors.primary50 : AppColors.secondary50,
              borderRadius: BorderRadius.circular(8),
              border: Border.all(
                color: isHighMatch
                    ? AppColors.primary200
                    : AppColors.secondary200,
              ),
            ),
            child: Row(
              children: [
                Icon(
                  isHighMatch
                      ? Icons.check_circle_rounded
                      : Icons.info_outline_rounded,
                  color: isHighMatch
                      ? AppColors.primary700
                      : AppColors.secondary700,
                  size: 16,
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    verdictLabel,
                    style: AppTypography.bodySSemiBold.copyWith(
                      color: isHighMatch
                          ? AppColors.primary900
                          : AppColors.secondary900,
                    ),
                  ),
                ),
              ],
            ),
          ),
          if (headlineReason.isNotEmpty) ...[
            const SizedBox(height: 12),
            Text(
              headlineReason,
              style: AppTypography.bodyMSemiBold.copyWith(
                color: AppColors.grey1050,
              ),
            ),
          ],
          if (explanation.isNotEmpty) ...[
            const SizedBox(height: 4),
            Text(
              explanation,
              style: AppTypography.bodySRegular.copyWith(
                color: AppColors.grey700,
                height: 1.45,
              ),
            ),
          ],
        ],
      ),
    );
  }
}

/// Three evaluation pillars (Skin Fit, Effectiveness, Safety).
class ProductPillarsCard extends StatelessWidget {
  /// Creates a [ProductPillarsCard].
  const ProductPillarsCard({
    required this.pillars,
    super.key,
  });

  /// The 3 pillars evaluated by AI.
  final ProductPillars pillars;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        if (pillars.skinFit != null) ...[
          _PillarItemCard(
            icon: Icons.face_retouching_natural_rounded,
            title: pillars.skinFit!.title,
            score: pillars.skinFit!.score,
            level: pillars.skinFit!.level,
            explanation: pillars.skinFit!.explanation,
          ),
          const SizedBox(height: 10),
        ],
        if (pillars.effectiveness != null) ...[
          _PillarItemCard(
            icon: Icons.bolt_rounded,
            title: pillars.effectiveness!.title,
            score: pillars.effectiveness!.score,
            level: pillars.effectiveness!.level,
            explanation: pillars.effectiveness!.explanation,
          ),
          const SizedBox(height: 10),
        ],
        if (pillars.safety != null) ...[
          _PillarItemCard(
            icon: Icons.shield_outlined,
            title: pillars.safety!.title,
            score: pillars.safety!.score,
            level: pillars.safety!.level,
            explanation: pillars.safety!.explanation,
            safetyBadges: [
              _RiskBadge(
                label: pillars.safety!.pregnancySafe
                    ? 'Pregnancy Safe'
                    : 'Pregnancy Caution',
                isSafe: pillars.safety!.pregnancySafe,
              ),
              _RiskBadge(
                label: pillars.safety!.fungalAcneSafe
                    ? 'Fungal Acne Safe'
                    : 'Fungal Acne Trigger',
                isSafe: pillars.safety!.fungalAcneSafe,
              ),
            ],
          ),
        ],
      ],
    );
  }
}

class _PillarItemCard extends StatelessWidget {
  const _PillarItemCard({
    required this.icon,
    required this.title,
    required this.score,
    required this.level,
    required this.explanation,
    this.safetyBadges = const [],
  });

  final IconData icon;
  final String title;
  final int score;
  final String level;
  final String explanation;
  final List<Widget> safetyBadges;

  @override
  Widget build(BuildContext context) {
    return KoraCard(
      backgroundColor: AppColors.grey50,
      borderColor: AppColors.grey300,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(icon, size: 20, color: AppColors.primary700),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  title,
                  style: AppTypography.bodyMSemiBold.copyWith(
                    color: AppColors.grey1050,
                  ),
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                decoration: BoxDecoration(
                  color: AppColors.primary50,
                  borderRadius: BorderRadius.circular(100),
                  border: Border.all(color: AppColors.primary300),
                ),
                child: Text(
                  '$score/100 · $level',
                  style: AppTypography.bodyXsBold.copyWith(
                    color: AppColors.primary800,
                  ),
                ),
              ),
            ],
          ),
          if (explanation.isNotEmpty) ...[
            const SizedBox(height: 8),
            Text(
              explanation,
              style: AppTypography.bodySRegular.copyWith(
                color: AppColors.grey800,
                height: 1.45,
              ),
            ),
          ],
          if (safetyBadges.isNotEmpty) ...[
            const SizedBox(height: 10),
            Wrap(
              spacing: 8,
              runSpacing: 6,
              children: safetyBadges,
            ),
          ],
        ],
      ),
    );
  }
}

/// Interactive AI Assistant Card offering questions that open a brand new chat.
class ProductAiAssistantCard extends StatelessWidget {
  /// Creates a [ProductAiAssistantCard].
  const ProductAiAssistantCard({
    required this.aiAssistant,
    required this.onQuestionTap,
    super.key,
  });

  /// The AI assistant metadata.
  final ProductAiAssistant aiAssistant;

  /// Callback when user taps a suggested question.
  final void Function(String question) onQuestionTap;

  @override
  Widget build(BuildContext context) {
    final hasQuestions = aiAssistant.suggestedQuestions.isNotEmpty;
    final hasExplanation =
        aiAssistant.shortExplanation != null &&
        aiAssistant.shortExplanation!.trim().isNotEmpty;
    final hasEnv =
        aiAssistant.environmentalTip != null &&
        aiAssistant.environmentalTip!.trim().isNotEmpty;

    return KoraCard(
      backgroundColor: AppColors.grey50,
      borderColor: AppColors.grey300,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Icon(
                Icons.auto_awesome_rounded,
                size: 20,
                color: AppColors.primary700,
              ),
              const SizedBox(width: 8),
              Text(
                'Kora AI Companion',
                style: AppTypography.bodyMSemiBold.copyWith(
                  color: AppColors.grey1050,
                ),
              ),
            ],
          ),
          if (hasExplanation) ...[
            const SizedBox(height: 8),
            Text(
              aiAssistant.shortExplanation!,
              style: AppTypography.bodySRegular.copyWith(
                color: AppColors.grey800,
                height: 1.45,
              ),
            ),
          ],
          if (hasEnv) ...[
            const SizedBox(height: 10),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
              decoration: BoxDecoration(
                color: AppColors.secondary50,
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: AppColors.secondary200),
              ),
              child: Row(
                children: [
                  const Icon(
                    Icons.wb_sunny_outlined,
                    size: 16,
                    color: AppColors.secondary800,
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      aiAssistant.environmentalTip!,
                      style: AppTypography.bodyXsRegular.copyWith(
                        color: AppColors.secondary900,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
          if (hasQuestions) ...[
            const SizedBox(height: 12),
            Text(
              'Questions you can ask your AI coach:',
              style: AppTypography.bodyXsSemiBold.copyWith(
                color: AppColors.grey700,
              ),
            ),
            const SizedBox(height: 8),
            for (final q in aiAssistant.suggestedQuestions)
              Padding(
                padding: const EdgeInsets.only(bottom: 8),
                child: Material(
                  color: AppColors.grey50,
                  borderRadius: BorderRadius.circular(10),
                  child: InkWell(
                    onTap: () => onQuestionTap(q.question),
                    borderRadius: BorderRadius.circular(10),
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 12,
                        vertical: 10,
                      ),
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(10),
                        border: Border.all(color: AppColors.grey300),
                      ),
                      child: Row(
                        children: [
                          Text(
                            q.emoji,
                            style: const TextStyle(fontSize: 16),
                          ),
                          const SizedBox(width: 10),
                          Expanded(
                            child: Text(
                              q.question,
                              style: AppTypography.bodySMedium.copyWith(
                                color: AppColors.grey1050,
                              ),
                            ),
                          ),
                          const Icon(
                            Icons.arrow_forward_ios_rounded,
                            size: 12,
                            color: AppColors.grey500,
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ),
          ],
        ],
      ),
    );
  }
}

/// Card presenting alternative recommendations and budget dupes.
class ProductAlternativesCard extends StatelessWidget {
  /// Creates a [ProductAlternativesCard].
  const ProductAlternativesCard({
    required this.alternatives,
    super.key,
  });

  /// List of alternative products.
  final List<ProductAlternative> alternatives;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        for (var i = 0; i < alternatives.length; i++) ...[
          if (i > 0) const SizedBox(height: 10),
          KoraCard(
            backgroundColor: AppColors.grey50,
            borderColor: AppColors.grey300,
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          if (alternatives[i].brand.isNotEmpty)
                            Text(
                              alternatives[i].brand.toUpperCase(),
                              style: AppTypography.bodyXsBold.copyWith(
                                color: AppColors.grey700,
                                letterSpacing: 0.8,
                              ),
                            ),
                          if (alternatives[i].isBudgetDupe) ...[
                            const SizedBox(width: 6),
                            Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 6,
                                vertical: 2,
                              ),
                              decoration: BoxDecoration(
                                color: AppColors.primary50,
                                borderRadius: BorderRadius.circular(4),
                                border: Border.all(color: AppColors.primary300),
                              ),
                              child: Text(
                                'Budget Dupe',
                                style: AppTypography.bodyXsBold.copyWith(
                                  color: AppColors.primary800,
                                ),
                              ),
                            ),
                          ],
                        ],
                      ),
                      const SizedBox(height: 2),
                      Text(
                        alternatives[i].name,
                        style: AppTypography.bodyMSemiBold.copyWith(
                          color: AppColors.grey1050,
                        ),
                      ),
                      if (alternatives[i].estimatedPrice != null) ...[
                        const SizedBox(height: 4),
                        Text(
                          'Estimated: ${alternatives[i].estimatedPrice!.toStringAsFixed(0)} ${alternatives[i].currency ?? "USD"}',
                          style: AppTypography.bodyXsRegular.copyWith(
                            color: AppColors.grey700,
                          ),
                        ),
                      ],
                    ],
                  ),
                ),
                if (alternatives[i].fitPercentage != null) ...[
                  const SizedBox(width: 12),
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 8,
                      vertical: 4,
                    ),
                    decoration: BoxDecoration(
                      color: AppColors.primary50,
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(color: AppColors.primary300),
                    ),
                    child: Text(
                      '${alternatives[i].fitPercentage}% Fit',
                      style: AppTypography.bodyXsBold.copyWith(
                        color: AppColors.primary800,
                      ),
                    ),
                  ),
                ],
              ],
            ),
          ),
        ],
      ],
    );
  }
}

/// Card listing full INCI ingredients with comedogenicity, irritancy,
/// and pregnancy/fungal acne flags.
class IngredientInciListCard extends StatelessWidget {
  /// Creates an [IngredientInciListCard].
  const IngredientInciListCard({
    required this.formula,
    super.key,
  });

  /// Parsed INCI ingredient analysis list.
  final List<InciIngredientAnalysis> formula;

  @override
  Widget build(BuildContext context) {
    return KoraCard(
      backgroundColor: AppColors.grey50,
      borderColor: AppColors.grey300,
      child: Column(
        children: [
          for (var i = 0; i < formula.length; i++) ...[
            if (i > 0) const Divider(height: 16, color: AppColors.grey200),
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        formula[i].inciName,
                        style: AppTypography.bodyMSemiBold.copyWith(
                          color: AppColors.grey1050,
                        ),
                      ),
                      if (formula[i].commonName != null &&
                          formula[i].commonName!.isNotEmpty) ...[
                        const SizedBox(height: 1),
                        Text(
                          formula[i].commonName!,
                          style: AppTypography.bodyXsMedium.copyWith(
                            color: AppColors.grey700,
                          ),
                        ),
                      ],
                      const SizedBox(height: 2),
                      Text(
                        formula[i].function,
                        style: AppTypography.bodyXsRegular.copyWith(
                          color: AppColors.grey800,
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(width: 8),
                Wrap(
                  spacing: 6,
                  runSpacing: 4,
                  alignment: WrapAlignment.end,
                  children: [
                    _RiskBadge(
                      label: 'Comedo ${formula[i].comedogenicityIndex}/5',
                      isSafe: formula[i].comedogenicityIndex <= 2,
                    ),
                    if (formula[i].irritancyIndex > 0)
                      _RiskBadge(
                        label: 'Irritation ${formula[i].irritancyIndex}/5',
                        isSafe: formula[i].irritancyIndex <= 1,
                      ),
                    if (formula[i].isPregnancySafe)
                      const _RiskBadge(
                        label: 'Pregnancy Safe',
                        isSafe: true,
                      ),
                    if (formula[i].isFungalAcneTrigger)
                      const _RiskBadge(
                        label: 'Fungal Acne Trigger',
                        isSafe: false,
                      ),
                  ],
                ),
              ],
            ),
          ],
        ],
      ),
    );
  }
}

class _RiskBadge extends StatelessWidget {
  const _RiskBadge({
    required this.label,
    required this.isSafe,
  });

  final String label;
  final bool isSafe;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
      decoration: BoxDecoration(
        color: isSafe ? AppColors.primary50 : AppColors.secondary50,
        borderRadius: BorderRadius.circular(100),
        border: Border.all(
          color: isSafe ? AppColors.primary200 : AppColors.secondary200,
        ),
      ),
      child: Text(
        label,
        style: AppTypography.bodyXsMedium.copyWith(
          color: isSafe ? AppColors.primary800 : AppColors.secondary800,
        ),
      ),
    );
  }
}

/// Card presenting medical endorsement and trusted scientific institutions.
class ScientificSourcesAndEndorsementCard extends StatelessWidget {
  /// Creates a [ScientificSourcesAndEndorsementCard].
  const ScientificSourcesAndEndorsementCard({
    this.medicalEndorsement,
    this.scientificSources = const [],
    super.key,
  });

  /// Medical endorsement entity.
  final MedicalEndorsement? medicalEndorsement;

  /// List of scientific sources cited.
  final List<ScientificSource> scientificSources;

  @override
  Widget build(BuildContext context) {
    return KoraCard(
      backgroundColor: AppColors.grey50,
      borderColor: AppColors.grey300,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (medicalEndorsement != null) ...[
            Row(
              children: [
                const Icon(
                  Icons.verified_user_rounded,
                  size: 18,
                  color: AppColors.primary700,
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    'Reviewed by ${medicalEndorsement!.doctorName}',
                    style: AppTypography.bodyMSemiBold.copyWith(
                      color: AppColors.grey1050,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 2),
            Text(
              medicalEndorsement!.credentials,
              style: AppTypography.bodyXsRegular.copyWith(
                color: AppColors.grey700,
              ),
            ),
            if (scientificSources.isNotEmpty)
              const Divider(height: 16, color: AppColors.grey200),
          ],
          if (scientificSources.isNotEmpty) ...[
            Text(
              'Backed by Peer-Reviewed Dermatological Databases:',
              style: AppTypography.bodyXsSemiBold.copyWith(
                color: AppColors.grey700,
              ),
            ),
            const SizedBox(height: 8),
            Wrap(
              spacing: 6,
              runSpacing: 6,
              children: [
                for (final src in scientificSources)
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 8,
                      vertical: 3,
                    ),
                    decoration: BoxDecoration(
                      color: AppColors.grey50,
                      borderRadius: BorderRadius.circular(6),
                      border: Border.all(color: AppColors.grey300),
                    ),
                    child: Text(
                      src.organizationName,
                      style: AppTypography.bodyXsRegular.copyWith(
                        color: AppColors.grey800,
                      ),
                    ),
                  ),
              ],
            ),
          ],
        ],
      ),
    );
  }
}

/// Card rendering application steps and optional tutorial video link.
class IngredientApplicationGuideCard extends StatelessWidget {
  /// Creates an [IngredientApplicationGuideCard].
  const IngredientApplicationGuideCard({
    required this.guide,
    super.key,
  });

  /// Application guide entity.
  final ProductApplicationGuide guide;

  @override
  Widget build(BuildContext context) {
    return KoraCard(
      backgroundColor: AppColors.grey50,
      borderColor: AppColors.grey300,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          for (var i = 0; i < guide.steps.length; i++)
            Padding(
              padding: const EdgeInsets.only(bottom: 8),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    '${i + 1}. ',
                    style: AppTypography.bodySBold.copyWith(
                      color: AppColors.primary700,
                    ),
                  ),
                  Expanded(
                    child: Text(
                      guide.steps[i],
                      style: AppTypography.bodySRegular.copyWith(
                        color: AppColors.grey900,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          if (guide.videoUrl != null && guide.videoUrl!.isNotEmpty) ...[
            const Divider(height: 16, color: AppColors.grey200),
            InkWell(
              onTap: () => context.push(AppRoutes.buildLearnVideoPath('1')),
              borderRadius: BorderRadius.circular(8),
              child: Padding(
                padding: const EdgeInsets.symmetric(vertical: 4),
                child: Row(
                  children: [
                    const Icon(
                      Icons.play_circle_fill_rounded,
                      color: AppColors.primary700,
                      size: 22,
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        'Watch video tutorial '
                        '(${guide.durationText ?? '2 min'})',
                        style: AppTypography.bodySSemiBold.copyWith(
                          color: AppColors.primary800,
                        ),
                      ),
                    ),
                    const Icon(
                      Icons.chevron_right_rounded,
                      color: AppColors.primary700,
                      size: 18,
                    ),
                  ],
                ),
              ),
            ),
          ],
        ],
      ),
    );
  }
}

/// Card displaying retail purchase options.
class PurchaseOptionsCard extends StatelessWidget {
  /// Creates a [PurchaseOptionsCard].
  const PurchaseOptionsCard({
    required this.purchaseOptions,
    super.key,
  });

  /// Purchase options metadata.
  final ProductPurchaseOptions purchaseOptions;

  @override
  Widget build(BuildContext context) {
    if (!purchaseOptions.available) return const SizedBox.shrink();

    return KoraCard(
      backgroundColor: AppColors.grey50,
      borderColor: AppColors.grey300,
      child: Row(
        children: [
          const Icon(
            Icons.shopping_bag_outlined,
            size: 20,
            color: AppColors.primary700,
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Available on ${purchaseOptions.retailerName ?? "Retailer"}',
                  style: AppTypography.bodyMSemiBold.copyWith(
                    color: AppColors.grey1050,
                  ),
                ),
                if (purchaseOptions.price != null)
                  Text(
                    '${purchaseOptions.price!.toStringAsFixed(2)} ${purchaseOptions.currency ?? ""}',
                    style: AppTypography.bodyXsRegular.copyWith(
                      color: AppColors.grey700,
                    ),
                  ),
              ],
            ),
          ),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
            decoration: BoxDecoration(
              color: AppColors.primary50,
              borderRadius: BorderRadius.circular(8),
              border: Border.all(color: AppColors.primary300),
            ),
            child: Text(
              'View Link',
              style: AppTypography.bodyXsBold.copyWith(
                color: AppColors.primary800,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
