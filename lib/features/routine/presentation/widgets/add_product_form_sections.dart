import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:kora/common/app_colors.dart';
import 'package:kora/common/app_typography.dart';
import 'package:kora/common/widgets/kora_card.dart';
import 'package:kora/common/widgets/primary_button.dart';
import 'package:kora/core/router/app_routes.dart';
import 'package:kora/features/product_scanner/domain/entities/skincare_report.dart';
import 'package:kora/features/routine/domain/entities/routine_product.dart';

/// Card previewing the AI personalized verdict on `AddProductPage`.
class AddProductAiVerdictCard extends StatelessWidget {
  /// Creates an [AddProductAiVerdictCard].
  const AddProductAiVerdictCard({required this.report, super.key});

  /// AI skincare report.
  final SkincareReport report;

  @override
  Widget build(BuildContext context) {
    final score = report.personalizedVerdict.matchScore;
    final isHighMatch = score >= 75;

    return KoraCard(
      onTap: () => context.push(
        AppRoutes.buildRoutineIngredientsPath('ai-scan'),
        extra: report,
      ),
      backgroundColor: isHighMatch
          ? AppColors.primary50
          : AppColors.secondary50,
      borderColor: isHighMatch ? AppColors.primary200 : AppColors.secondary200,
      child: Row(
        children: [
          Container(
            width: 48,
            height: 48,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: AppColors.grey50,
              border: Border.all(
                color: isHighMatch
                    ? AppColors.primary600
                    : AppColors.secondary600,
                width: 2,
              ),
            ),
            alignment: Alignment.center,
            child: Text(
              '$score%',
              style: AppTypography.bodySBold.copyWith(
                color: AppColors.grey1050,
              ),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  report.personalizedVerdict.matchVerdict,
                  style: AppTypography.bodyMSemiBold.copyWith(
                    color: AppColors.grey1050,
                  ),
                ),
                Text(
                  report.personalizedVerdict.headlineReason,
                  style: AppTypography.bodyXsRegular.copyWith(
                    color: AppColors.grey700,
                  ),
                ),
              ],
            ),
          ),
          const Icon(
            Icons.chevron_right_rounded,
            color: AppColors.primary700,
          ),
        ],
      ),
    );
  }
}

/// OCR label scan shortcut banner on `AddProductPage`.
class AddProductOcrShortcutCard extends StatelessWidget {
  /// Creates an [AddProductOcrShortcutCard].
  const AddProductOcrShortcutCard({super.key});

  @override
  Widget build(BuildContext context) {
    return KoraCard(
      onTap: () => context.push(AppRoutes.routineLabel),
      backgroundColor: AppColors.primary50,
      borderColor: AppColors.primary200,
      child: Row(
        children: [
          Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              color: AppColors.primary100,
              borderRadius: BorderRadius.circular(10),
              border: Border.all(color: AppColors.primary300),
            ),
            child: const Icon(
              Icons.document_scanner_outlined,
              color: AppColors.primary800,
              size: 22,
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Scan ingredient label (OCR)',
                  style: AppTypography.bodyMSemiBold.copyWith(
                    color: AppColors.grey1050,
                  ),
                ),
                Text(
                  'Instant breakdown of actives and allergens',
                  style: AppTypography.bodyXsRegular.copyWith(
                    color: AppColors.grey700,
                  ),
                ),
              ],
            ),
          ),
          const Icon(
            Icons.chevron_right_rounded,
            color: AppColors.primary700,
          ),
        ],
      ),
    );
  }
}

/// Routine period selector (`am`, `pm`, `both`) for `AddProductPage`.
class AddProductPeriodSelector extends StatelessWidget {
  /// Creates an [AddProductPeriodSelector].
  const AddProductPeriodSelector({
    required this.selectedPeriod,
    required this.onPeriodSelected,
    super.key,
  });

  /// Currently selected period (`am`, `pm`, `both`).
  final String selectedPeriod;

  /// Callback when a period is chosen.
  final ValueChanged<String> onPeriodSelected;

  @override
  Widget build(BuildContext context) {
    return Row(
      children:
          [
            (key: RoutinePeriod.am, label: 'Morning'),
            (key: RoutinePeriod.pm, label: 'Evening'),
            (key: RoutinePeriod.both, label: 'Both'),
          ].map((item) {
            final isSelected = selectedPeriod == item.key;
            return Expanded(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 4),
                child: OutlinedButton(
                  style: OutlinedButton.styleFrom(
                    backgroundColor: isSelected
                        ? AppColors.primary700
                        : AppColors.grey50,
                    side: BorderSide(
                      color: isSelected
                          ? AppColors.primary700
                          : AppColors.grey300,
                    ),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10),
                    ),
                    padding: const EdgeInsets.symmetric(vertical: 12),
                  ),
                  onPressed: () => onPeriodSelected(item.key),
                  child: Text(
                    item.label,
                    style: AppTypography.bodySMedium.copyWith(
                      color: isSelected ? AppColors.grey50 : AppColors.grey800,
                    ),
                  ),
                ),
              ),
            );
          }).toList(),
    );
  }
}

/// Modal sheet shown after a product is added to the routine.
class ProductSavedConfirmSheet extends StatelessWidget {
  /// Creates a [ProductSavedConfirmSheet].
  const ProductSavedConfirmSheet({
    required this.productName,
    required this.onStartExperiment,
    required this.onKeepInRoutine,
    super.key,
  });

  /// Name of the saved product.
  final String productName;

  /// Triggered when the user opts to start a 6-week experiment.
  final VoidCallback onStartExperiment;

  /// Triggered when the user returns to the routine screen.
  final VoidCallback onKeepInRoutine;

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: const BoxDecoration(
        color: AppColors.grey50,
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      padding: const EdgeInsets.fromLTRB(20, 16, 20, 24),
      child: SafeArea(
        top: false,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Center(
              child: Container(
                width: 36,
                height: 4,
                decoration: BoxDecoration(
                  color: AppColors.grey300,
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
            ),
            const SizedBox(height: 16),
            Text(
              'Product added to routine!',
              style: AppTypography.h5Bold.copyWith(color: AppColors.grey1050),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 8),
            Text(
              'Do you want to test whether $productName really works by '
              'starting a 6-week experiment?',
              style: AppTypography.bodySRegular.copyWith(
                color: AppColors.grey700,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 20),
            PrimaryButton(
              text: 'Start an experiment',
              height: 52,
              backgroundColor: AppColors.primary700,
              onPressed: onStartExperiment,
            ),
            const SizedBox(height: 8),
            TextButton(
              onPressed: onKeepInRoutine,
              child: Text(
                'Just save to routine',
                style: AppTypography.bodySMedium.copyWith(
                  color: AppColors.grey700,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
