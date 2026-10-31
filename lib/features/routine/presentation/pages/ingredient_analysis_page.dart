// ignore_for_file: avoid_redundant_argument_values, document_ignores

import 'dart:async';

import 'package:flutter/material.dart';
import 'package:get_it/get_it.dart';
import 'package:go_router/go_router.dart';
import 'package:kora/common/app_colors.dart';
import 'package:kora/common/app_typography.dart';
import 'package:kora/common/widgets/kora_card.dart';
import 'package:kora/common/widgets/primary_button.dart';
import 'package:kora/core/router/app_routes.dart';
import 'package:kora/features/coach/presentation/widgets/coach_bottom_sheet.dart';
import 'package:kora/features/product_scanner/domain/entities/scanned_product_result.dart';
import 'package:kora/features/product_scanner/domain/entities/skincare_report.dart';
import 'package:kora/features/routine/presentation/bloc/routine_bloc.dart';
import 'package:kora/features/routine/presentation/widgets/ingredient_analysis_cards.dart';
import 'package:kora/features/routine/routine_injection.dart';

/// Screen displaying OCR/barcode breakdown and full personalized AI SkincareReport
/// from skincareScanWorkflow with ultra-premium flat styling and 0 shadows.
class IngredientAnalysisPage extends StatelessWidget {
  /// Creates an [IngredientAnalysisPage].
  const IngredientAnalysisPage({
    this.productId = 'demo-1',
    this.scanResult,
    this.skincareReport,
    super.key,
  });

  /// The product or scan identifier.
  final String productId;

  /// Optional completed product scan result containing OCR/barcode and report.
  final ScannedProductResult? scanResult;

  /// Direct [SkincareReport] override if provided independently.
  final SkincareReport? skincareReport;

  SkincareReport? get _resolvedReport =>
      skincareReport ?? scanResult?.skincareReport;

  @override
  Widget build(BuildContext context) {
    final getIt = GetIt.instance;
    if (!getIt.isRegistered<RoutineBloc>()) {
      initRoutineInjection(getIt);
    }
    final routineState = getIt<RoutineBloc>().state;
    final routineProduct = routineState.findProductById(productId);
    final catalogProduct = routineState.findCatalogProduct(productId);

    final report = _resolvedReport;
    final verdict = report?.personalizedVerdict;
    final compatibility = verdict?.routineCompatibility;
    final formula = report?.formulaStatic ?? const <InciIngredientAnalysis>[];

    final hasDetectedLines = scanResult?.detectedLines.isNotEmpty ?? false;
    final resolvedName =
        report?.product.name ??
        routineProduct?.name ??
        catalogProduct?.name ??
        (hasDetectedLines && scanResult!.detectedLines.length > 1
            ? scanResult!.detectedLines.skip(1).take(2).join(' ')
            : (scanResult?.extractedRawText.isNotEmpty ?? false
                  ? scanResult!.extractedRawText
                  : 'Scanned Product'));
    final resolvedBrand =
        report?.product.brand ??
        routineProduct?.brand ??
        catalogProduct?.brand ??
        (hasDetectedLines ? scanResult!.detectedLines.first : 'Brand');
    final resolvedActives = formula.isNotEmpty
        ? formula.map((f) => f.inciName).toList()
        : (routineProduct?.actives.isNotEmpty ?? false)
        ? routineProduct!.actives
        : (catalogProduct?.actives.isNotEmpty ?? false)
        ? catalogProduct!.actives
        : const <String>[];

    final backendData = scanResult?.backendProductData;
    final inciAnalysis = backendData?['inciAnalysis'] is Map
        ? backendData!['inciAnalysis'] as Map
        : null;
    final resolvedRawInci =
        report?.rawInciText ??
        inciAnalysis?['allIngredientsRaw']?.toString() ??
        backendData?['allIngredientsRaw']?.toString() ??
        routineProduct?.ingredientsRaw ??
        catalogProduct?.ingredientsRaw;

    final resolvedScore =
        verdict?.matchScore ??
        (report != null ? 85 : (routineProduct != null ? 90 : 0));
    final resolvedVerdictLabel =
        verdict?.matchVerdict ??
        (resolvedScore > 0
            ? '$resolvedScore% Match · High Fit'
            : 'Pending Analysis');
    final resolvedHeadline =
        verdict?.headlineReason ??
        catalogProduct?.goodFor ??
        (report != null
            ? 'Analyzed with your skin profile.'
            : 'Product details captured.');
    final resolvedExplanation =
        verdict?.explanation ??
        (report != null
            ? 'Cosmetic formula reviewed by Kora AI Coach.'
            : 'Detailed dermatological analysis available with active '
                  'connection.');

    return Scaffold(
      backgroundColor: AppColors.scaffoldColor,
      appBar: AppBar(
        backgroundColor: AppColors.scaffoldColor,
        elevation: 0,
        scrolledUnderElevation: 0,
        title: Text(
          'Product Analysis',
          style: AppTypography.h5Bold.copyWith(color: AppColors.grey1050),
        ),
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // 1. Header Card (Flat, 0 shadow, 0 gradient)
              IngredientProductHeaderCard(
                brand: resolvedBrand,
                productName: resolvedName,
                category: report?.product.category,
                imageUrl: report?.product.imageUrl,
                verdictLabel: resolvedVerdictLabel,
                matchScore: resolvedScore,
                headlineReason: resolvedHeadline,
                explanation: resolvedExplanation,
              ),
              const SizedBox(height: 16),

              // 2. The 3 Core AI Pillars (Skin Fit, Effectiveness, Safety)
              if (report?.pillars != null) ...[
                Text(
                  'AI Evaluation Pillars',
                  style: AppTypography.h6Bold.copyWith(
                    color: AppColors.grey1050,
                  ),
                ),
                const SizedBox(height: 8),
                ProductPillarsCard(pillars: report!.pillars!),
                const SizedBox(height: 16),
              ],

              // 3. AI Assistant & Interactive Questions (Opens Brand New Chat!)
              if (report?.aiAssistant != null) ...[
                Text(
                  'Kora AI Consultation',
                  style: AppTypography.h6Bold.copyWith(
                    color: AppColors.grey1050,
                  ),
                ),
                const SizedBox(height: 8),
                ProductAiAssistantCard(
                  aiAssistant: report!.aiAssistant!,
                  onQuestionTap: (question) {
                    unawaited(
                      showCoachBottomSheet<void>(
                        context,
                        initialQuestion: question,
                        forceNewThread: true,
                      ),
                    );
                  },
                ),
                const SizedBox(height: 16),
              ],

              // 4. Detected Actives
              if (resolvedActives.isNotEmpty) ...[
                KoraCard(
                  backgroundColor: AppColors.grey50,
                  borderColor: AppColors.grey300,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Detected Actives',
                        style: AppTypography.bodyMSemiBold.copyWith(
                          color: AppColors.grey1050,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Wrap(
                        spacing: 8,
                        runSpacing: 8,
                        children: [
                          for (var i = 0; i < resolvedActives.length; i++)
                            _ActiveChip(
                              label: resolvedActives[i],
                              isPrimary: i == 0,
                            ),
                        ],
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 16),
              ],

              // 5. Worth Knowing / Benefits & Precautions
              if (verdict != null &&
                  (verdict.benefitsForUser.isNotEmpty ||
                      verdict.concernsOrRisksForUser.isNotEmpty)) ...[
                Text(
                  'Worth knowing',
                  style: AppTypography.h6Bold.copyWith(
                    color: AppColors.grey1050,
                  ),
                ),
                const SizedBox(height: 8),
                KoraCard(
                  backgroundColor: AppColors.grey50,
                  borderColor: AppColors.grey300,
                  child: Column(
                    children: [
                      for (
                        var i = 0;
                        i < verdict.benefitsForUser.length;
                        i++
                      ) ...[
                        if (i > 0)
                          const Divider(height: 16, color: AppColors.grey200),
                        _InsightRow(
                          icon: Icons.check_circle_outline_rounded,
                          title: 'Why it suits your skin',
                          subtitle: verdict.benefitsForUser[i],
                        ),
                      ],
                      if (verdict.concernsOrRisksForUser.isNotEmpty) ...[
                        if (verdict.benefitsForUser.isNotEmpty)
                          const Divider(height: 16, color: AppColors.grey200),
                        _InsightRow(
                          icon: Icons.warning_amber_rounded,
                          title: 'Precautions for your profile',
                          subtitle: verdict.concernsOrRisksForUser.join(' • '),
                        ),
                      ],
                    ],
                  ),
                ),
                const SizedBox(height: 16),
              ] else if (catalogProduct != null) ...[
                Text(
                  'Worth knowing',
                  style: AppTypography.h6Bold.copyWith(
                    color: AppColors.grey1050,
                  ),
                ),
                const SizedBox(height: 8),
                KoraCard(
                  backgroundColor: AppColors.grey50,
                  borderColor: AppColors.grey300,
                  child: Column(
                    children: [
                      _InsightRow(
                        icon: Icons.info_outline_rounded,
                        title: 'Recommended focus',
                        subtitle:
                            catalogProduct.goodFor ??
                            'Targets key skin priorities.',
                      ),
                      if (catalogProduct.skipIf != null) ...[
                        const Divider(height: 16, color: AppColors.grey200),
                        _InsightRow(
                          icon: Icons.warning_amber_rounded,
                          title: 'Usage guidance',
                          subtitle: catalogProduct.skipIf!,
                        ),
                      ],
                    ],
                  ),
                ),
                const SizedBox(height: 16),
              ],

              // 6. Routine Compatibility
              if (compatibility != null) ...[
                Text(
                  'Fits your routine?',
                  style: AppTypography.h6Bold.copyWith(
                    color: AppColors.grey1050,
                  ),
                ),
                const SizedBox(height: 8),
                KoraCard(
                  backgroundColor: compatibility.isCompatibleWithCurrentRoutine
                      ? AppColors.primary50
                      : AppColors.secondary50,
                  borderColor: compatibility.isCompatibleWithCurrentRoutine
                      ? AppColors.primary200
                      : AppColors.secondary200,
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Icon(
                        compatibility.isCompatibleWithCurrentRoutine
                            ? Icons.check_circle_rounded
                            : Icons.info_rounded,
                        color: compatibility.isCompatibleWithCurrentRoutine
                            ? AppColors.primary700
                            : AppColors.secondary700,
                        size: 20,
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              compatibility.isCompatibleWithCurrentRoutine
                                  ? 'Compatible with your current regimen'
                                  : 'Layer with care in your routine',
                              style: AppTypography.bodyMSemiBold.copyWith(
                                color: AppColors.primary900,
                              ),
                            ),
                            const SizedBox(height: 2),
                            Text(
                              compatibility.integrationAdvice,
                              style: AppTypography.bodySRegular.copyWith(
                                color: AppColors.grey800,
                              ),
                            ),
                            if (compatibility
                                .conflictingIngredients
                                .isNotEmpty) ...[
                              const SizedBox(height: 6),
                              Builder(
                                builder: (context) {
                                  final joined = compatibility
                                      .conflictingIngredients
                                      .join(', ');
                                  return Text(
                                    'Conflicts: $joined',
                                    style: AppTypography.bodyXsSemiBold
                                        .copyWith(
                                          color: AppColors.error600,
                                        ),
                                  );
                                },
                              ),
                            ],
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 16),
              ],

              // 7. Alternatives & Budget Dupes
              if (report != null && report.alternatives.isNotEmpty) ...[
                Text(
                  'Alternative Options & Budget Dupes',
                  style: AppTypography.h6Bold.copyWith(
                    color: AppColors.grey1050,
                  ),
                ),
                const SizedBox(height: 8),
                ProductAlternativesCard(alternatives: report.alternatives),
                const SizedBox(height: 16),
              ],

              // 8. Application Guide
              if (report != null &&
                  report.applicationGuide.steps.isNotEmpty) ...[
                Text(
                  'Application Guide',
                  style: AppTypography.h6Bold.copyWith(
                    color: AppColors.grey1050,
                  ),
                ),
                const SizedBox(height: 8),
                IngredientApplicationGuideCard(guide: report.applicationGuide),
                const SizedBox(height: 16),
              ],

              // 9. INCI Safety & Detailed Breakdown
              if (formula.isNotEmpty) ...[
                Text(
                  'INCI Safety & Detailed Breakdown',
                  style: AppTypography.h6Bold.copyWith(
                    color: AppColors.grey1050,
                  ),
                ),
                const SizedBox(height: 8),
                IngredientInciListCard(formula: formula),
                const SizedBox(height: 16),
              ] else if (resolvedRawInci != null &&
                  resolvedRawInci.isNotEmpty) ...[
                Text(
                  'Full INCI Formula',
                  style: AppTypography.h6Bold.copyWith(
                    color: AppColors.grey1050,
                  ),
                ),
                const SizedBox(height: 8),
                KoraCard(
                  backgroundColor: AppColors.grey50,
                  borderColor: AppColors.grey300,
                  child: Text(
                    resolvedRawInci,
                    style: AppTypography.bodyXsRegular.copyWith(
                      color: AppColors.grey800,
                      height: 1.5,
                    ),
                  ),
                ),
                const SizedBox(height: 16),
              ],

              // 10. Scientific Sources & Medical Endorsement
              if (report != null &&
                  (report.medicalEndorsement != null ||
                      report.scientificSources.isNotEmpty)) ...[
                Text(
                  'Scientific Backing & Validation',
                  style: AppTypography.h6Bold.copyWith(
                    color: AppColors.grey1050,
                  ),
                ),
                const SizedBox(height: 8),
                ScientificSourcesAndEndorsementCard(
                  medicalEndorsement: report.medicalEndorsement,
                  scientificSources: report.scientificSources,
                ),
                const SizedBox(height: 16),
              ],

              // 11. Purchase Options
              if (report != null && report.purchaseOptions.available) ...[
                Text(
                  'Purchase Availability',
                  style: AppTypography.h6Bold.copyWith(
                    color: AppColors.grey1050,
                  ),
                ),
                const SizedBox(height: 8),
                PurchaseOptionsCard(purchaseOptions: report.purchaseOptions),
                const SizedBox(height: 16),
              ],

              // Disclaimer
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 14,
                  vertical: 10,
                ),
                decoration: BoxDecoration(
                  color: AppColors.grey100,
                  borderRadius: BorderRadius.circular(10),
                  border: Border.all(color: AppColors.grey300),
                ),
                child: Text(
                  'Informational, not medical advice. Always consult your '
                  'prescribing physician if you are using dermatological '
                  'medication.',
                  style: AppTypography.bodyXsRegular.copyWith(
                    color: AppColors.grey700,
                  ),
                  textAlign: TextAlign.center,
                ),
              ),
              const SizedBox(height: 24),

              // Action buttons (Flat, 52dp)
              PrimaryButton(
                text: 'Add to routine',
                height: 52,
                backgroundColor: AppColors.primary700,
                onPressed: () => context.go(AppRoutes.routine),
              ),
              const SizedBox(height: 10),
              OutlinedButton(
                style: OutlinedButton.styleFrom(
                  minimumSize: const Size.fromHeight(52),
                  side: const BorderSide(color: AppColors.grey400),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(16),
                  ),
                ),
                onPressed: () => context.push(AppRoutes.experimentNew),
                child: Text(
                  'Start an experiment with this',
                  style: AppTypography.bodySMedium.copyWith(
                    color: AppColors.grey900,
                  ),
                ),
              ),
              const SizedBox(height: 10),
              TextButton.icon(
                onPressed: () {
                  unawaited(
                    showCoachBottomSheet<void>(
                      context,
                      initialQuestion:
                          'Can I safely layer $resolvedName with my current '
                          'routine?',
                      forceNewThread: true,
                    ),
                  );
                },
                icon: const Icon(
                  Icons.chat_bubble_outline_rounded,
                  size: 18,
                  color: AppColors.primary700,
                ),
                label: Text(
                  'Ask Kora Coach about this formula',
                  style: AppTypography.bodySMedium.copyWith(
                    color: AppColors.primary800,
                  ),
                ),
              ),
              const SizedBox(height: 16),
            ],
          ),
        ),
      ),
    );
  }
}

class _ActiveChip extends StatelessWidget {
  const _ActiveChip({required this.label, this.isPrimary = false});

  final String label;
  final bool isPrimary;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
      decoration: BoxDecoration(
        color: isPrimary ? AppColors.primary50 : AppColors.grey100,
        borderRadius: BorderRadius.circular(100),
        border: Border.all(
          color: isPrimary ? AppColors.primary200 : AppColors.grey300,
        ),
      ),
      child: Text(
        label,
        style: AppTypography.bodyXsMedium.copyWith(
          color: isPrimary ? AppColors.primary900 : AppColors.grey800,
        ),
      ),
    );
  }
}

class _InsightRow extends StatelessWidget {
  const _InsightRow({
    required this.icon,
    required this.title,
    required this.subtitle,
  });

  final IconData icon;
  final String title;
  final String subtitle;

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Icon(icon, size: 20, color: AppColors.primary700),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                title,
                style: AppTypography.bodyMSemiBold.copyWith(
                  color: AppColors.grey1050,
                ),
              ),
              const SizedBox(height: 2),
              Text(
                subtitle,
                style: AppTypography.bodyXsRegular.copyWith(
                  color: AppColors.grey700,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}
