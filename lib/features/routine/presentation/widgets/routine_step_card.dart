import 'package:flutter/material.dart';
import 'package:kora/common/app_colors.dart';
import 'package:kora/common/app_typography.dart';
import 'package:kora/common/widgets/kora_card.dart';
import 'package:kora/features/routine/domain/entities/routine_product.dart';

/// Minimalist flat routine product card displaying step category, experiment
/// badge, days used, active ingredients pills, completion checkmark, and
/// direct navigation to product detail or ingredient analysis.
class RoutineStepCard extends StatelessWidget {
  /// Creates a [RoutineStepCard].
  const RoutineStepCard({
    required this.product,
    required this.stepIndex,
    required this.isDone,
    required this.isInExperiment,
    required this.onToggleDone,
    required this.onCardTap,
    required this.onIngredientsTap,
    super.key,
  });

  /// The routine item entity (`public.routine_items`).
  final RoutineProduct product;

  /// 1-based step number in the active period.
  final int stepIndex;

  /// Whether this step is completed for the active period today.
  final bool isDone;

  /// Whether this item is linked to an active experiment.
  final bool isInExperiment;

  /// Callback when the circular completion checkbox is tapped.
  final VoidCallback onToggleDone;

  /// Callback when the card is tapped (opens product detail).
  final VoidCallback onCardTap;

  /// Callback when the INCI / Ingredients action pill is tapped.
  final VoidCallback onIngredientsTap;

  @override
  Widget build(BuildContext context) {
    final stepLabel = RoutineStepType.displayLabel(product.stepType);
    final daysCount = product.daysUsed();

    return KoraCard(
      onTap: onCardTap,
      borderColor: isInExperiment ? AppColors.primary400 : AppColors.grey300,
      padding: const EdgeInsets.all(14),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Touch target >= 48x48dp for checkbox
              Semantics(
                button: true,
                checked: isDone,
                label: 'Mark ${product.name} as ${isDone ? 'undone' : 'done'}',
                child: GestureDetector(
                  behavior: HitTestBehavior.opaque,
                  onTap: onToggleDone,
                  child: SizedBox(
                    width: 48,
                    height: 48,
                    child: Align(
                      alignment: Alignment.topLeft,
                      child: AnimatedContainer(
                        duration: const Duration(milliseconds: 200),
                        curve: Curves.easeOut,
                        width: 26,
                        height: 26,
                        margin: const EdgeInsets.only(top: 2),
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          color: isDone
                              ? AppColors.primary700
                              : Colors.transparent,
                          border: Border.all(
                            color: isDone
                                ? AppColors.primary700
                                : AppColors.grey400,
                            width: 1.5,
                          ),
                        ),
                        alignment: Alignment.center,
                        child: isDone
                            ? const Icon(
                                Icons.check_rounded,
                                size: 15,
                                color: AppColors.grey50,
                              )
                            : Text(
                                '$stepIndex',
                                style: AppTypography.bodyXsSemiBold.copyWith(
                                  color: AppColors.grey700,
                                ),
                              ),
                      ),
                    ),
                  ),
                ),
              ),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 7,
                            vertical: 2,
                          ),
                          decoration: BoxDecoration(
                            color: AppColors.neutral300,
                            borderRadius: BorderRadius.circular(5),
                            border: Border.all(color: AppColors.grey300),
                          ),
                          child: Text(
                            'STEP $stepIndex · ${stepLabel.toUpperCase()}',
                            style: AppTypography.bodyXsBold.copyWith(
                              color: AppColors.grey900,
                              letterSpacing: 0.3,
                            ),
                          ),
                        ),
                        if (isInExperiment) ...[
                          const SizedBox(width: 6),
                          Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 7,
                              vertical: 2,
                            ),
                            decoration: BoxDecoration(
                              color: AppColors.primary50,
                              borderRadius: BorderRadius.circular(5),
                              border: Border.all(color: AppColors.primary300),
                            ),
                            child: Text(
                              'IN TEST',
                              style: AppTypography.bodyXsBold.copyWith(
                                color: AppColors.primary800,
                                letterSpacing: 0.3,
                              ),
                            ),
                          ),
                        ],
                        const Spacer(),
                        Text(
                          '${daysCount}d',
                          style: AppTypography.bodyXsMedium.copyWith(
                            color: AppColors.grey600,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 6),
                    Text(
                      product.name,
                      style: AppTypography.bodyMSemiBold.copyWith(
                        color: isDone ? AppColors.grey600 : AppColors.grey1050,
                        decoration: isDone ? TextDecoration.lineThrough : null,
                      ),
                    ),
                    if (product.brand != null && product.brand!.isNotEmpty)
                      Text(
                        product.brand!,
                        style: AppTypography.bodyXsRegular.copyWith(
                          color: AppColors.grey700,
                        ),
                      ),
                  ],
                ),
              ),
            ],
          ),
          if (product.actives.isNotEmpty) ...[
            const SizedBox(height: 8),
            Row(
              children: [
                Expanded(
                  child: Wrap(
                    spacing: 6,
                    runSpacing: 4,
                    children: product.actives.map((active) {
                      return Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 8,
                          vertical: 3,
                        ),
                        decoration: BoxDecoration(
                          color: AppColors.grey100,
                          borderRadius: BorderRadius.circular(6),
                          border: Border.all(color: AppColors.grey300),
                        ),
                        child: Text(
                          active,
                          style: AppTypography.bodyXsRegular.copyWith(
                            color: AppColors.grey800,
                          ),
                        ),
                      );
                    }).toList(),
                  ),
                ),
                const SizedBox(width: 8),
                Semantics(
                  button: true,
                  label: 'Analyze ingredients for ${product.name}',
                  child: InkWell(
                    onTap: onIngredientsTap,
                    borderRadius: BorderRadius.circular(6),
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 8,
                        vertical: 4,
                      ),
                      decoration: BoxDecoration(
                        color: AppColors.primary50,
                        borderRadius: BorderRadius.circular(6),
                        border: Border.all(color: AppColors.primary200),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          const Icon(
                            Icons.biotech_outlined,
                            size: 13,
                            color: AppColors.primary800,
                          ),
                          const SizedBox(width: 4),
                          Text(
                            'INCI',
                            style: AppTypography.bodyXsSemiBold.copyWith(
                              color: AppColors.primary800,
                            ),
                          ),
                        ],
                      ),
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
