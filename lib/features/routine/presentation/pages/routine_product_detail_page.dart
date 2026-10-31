import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:get_it/get_it.dart';
import 'package:go_router/go_router.dart';
import 'package:kora/common/app_colors.dart';
import 'package:kora/common/app_typography.dart';
import 'package:kora/common/widgets/kora_card.dart';
import 'package:kora/common/widgets/primary_button.dart';
import 'package:kora/common/widgets/secondary_button.dart';
import 'package:kora/core/router/app_routes.dart';
import 'package:kora/features/routine/domain/entities/routine_product.dart';
import 'package:kora/features/routine/presentation/bloc/routine_bloc.dart';
import 'package:kora/features/routine/presentation/bloc/routine_event.dart';
import 'package:kora/features/routine/presentation/bloc/routine_state.dart';
import 'package:kora/features/routine/routine_injection.dart';

/// Full-screen detail and editing page for a single [RoutineProduct]
/// (`public.routine_items` in Supabase).
///
/// Rendered on the root navigator so the bottom shell bar is hidden.
class RoutineProductDetailPage extends StatelessWidget {
  /// Creates a [RoutineProductDetailPage].
  const RoutineProductDetailPage({
    required this.productId,
    super.key,
  });

  /// Identifier of the routine product (`routine_items.id`).
  final String productId;

  @override
  Widget build(BuildContext context) {
    final getIt = GetIt.instance;
    if (!getIt.isRegistered<RoutineBloc>()) {
      initRoutineInjection(getIt);
    }
    final bloc = getIt<RoutineBloc>();
    if (bloc.state.status.isInitial) {
      bloc.add(const RoutineStarted());
    }

    return BlocProvider<RoutineBloc>.value(
      value: bloc,
      child: _RoutineProductDetailView(productId: productId),
    );
  }
}

class _RoutineProductDetailView extends StatelessWidget {
  const _RoutineProductDetailView({required this.productId});

  final String productId;

  static const List<String> _weekdayLabels = [
    'M',
    'T',
    'W',
    'T',
    'F',
    'S',
    'S',
  ];

  void _togglePeriod(BuildContext context, RoutineProduct product, String p) {
    context.read<RoutineBloc>().add(
      RoutineProductSaved(product.copyWith(period: p)),
    );
  }

  void _toggleDay(BuildContext context, RoutineProduct product, int day) {
    final currentDays = List<int>.from(
      product.days ?? const [1, 2, 3, 4, 5, 6, 7],
    );
    if (currentDays.contains(day)) {
      if (currentDays.length > 1) {
        currentDays.remove(day);
      }
    } else {
      currentDays
        ..add(day)
        ..sort();
    }
    final isEveryDay = currentDays.length == 7;
    context.read<RoutineBloc>().add(
      RoutineProductSaved(
        product.copyWith(
          days: isEveryDay ? null : currentDays,
          clearDays: isEveryDay,
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<RoutineBloc, RoutineState>(
      builder: (context, state) {
        final product = state.findProductById(productId);
        if (product == null) {
          return Scaffold(
            backgroundColor: AppColors.scaffoldColor,
            appBar: AppBar(
              backgroundColor: AppColors.scaffoldColor,
              elevation: 0,
              title: Text(
                'Product Detail',
                style: AppTypography.h5Bold.copyWith(color: AppColors.grey1050),
              ),
            ),
            body: Center(
              child: Text(
                'Product not found in active routine.',
                style: AppTypography.bodyMRegular.copyWith(
                  color: AppColors.grey700,
                ),
              ),
            ),
          );
        }

        final isExperiment = product.id == state.experimentProductId;
        final activeDays = product.days ?? const [1, 2, 3, 4, 5, 6, 7];

        return Scaffold(
          backgroundColor: AppColors.scaffoldColor,
          appBar: AppBar(
            backgroundColor: AppColors.scaffoldColor,
            elevation: 0,
            scrolledUnderElevation: 0,
            title: Text(
              RoutineStepType.displayLabel(product.stepType),
              style: AppTypography.h5Bold.copyWith(color: AppColors.grey1050),
            ),
            actions: [
              Semantics(
                button: true,
                label: 'Remove ${product.name} from routine',
                child: IconButton(
                  tooltip: 'Delete product',
                  icon: const Icon(
                    Icons.delete_outline_rounded,
                    color: AppColors.error500,
                  ),
                  onPressed: () {
                    context.read<RoutineBloc>().add(
                      RoutineProductDeleted(product.id),
                    );
                    context.pop();
                  },
                ),
              ),
            ],
          ),
          body: SafeArea(
            child: ListView(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
              children: [
                // Header card
                KoraCard(
                  padding: const EdgeInsets.all(18),
                  borderColor: isExperiment
                      ? AppColors.primary400
                      : AppColors.grey300,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 8,
                              vertical: 3,
                            ),
                            decoration: BoxDecoration(
                              color: AppColors.neutral300,
                              borderRadius: BorderRadius.circular(6),
                              border: Border.all(color: AppColors.grey300),
                            ),
                            child: Text(
                              RoutineStepType.displayLabel(
                                product.stepType,
                              ).toUpperCase(),
                              style: AppTypography.bodyXsBold.copyWith(
                                color: AppColors.grey900,
                              ),
                            ),
                          ),
                          if (isExperiment) ...[
                            const SizedBox(width: 8),
                            Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 8,
                                vertical: 3,
                              ),
                              decoration: BoxDecoration(
                                color: AppColors.primary50,
                                borderRadius: BorderRadius.circular(6),
                                border: Border.all(color: AppColors.primary300),
                              ),
                              child: Text(
                                'ACTIVE EXPERIMENT',
                                style: AppTypography.bodyXsBold.copyWith(
                                  color: AppColors.primary800,
                                ),
                              ),
                            ),
                          ],
                          const Spacer(),
                          Text(
                            '${product.daysUsed()} days in routine',
                            style: AppTypography.bodyXsMedium.copyWith(
                              color: AppColors.grey700,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 10),
                      Text(
                        product.name,
                        style: AppTypography.h5Bold.copyWith(
                          color: AppColors.grey1050,
                        ),
                      ),
                      if (product.brand != null && product.brand!.isNotEmpty)
                        Text(
                          product.brand!,
                          style: AppTypography.bodyMRegular.copyWith(
                            color: AppColors.grey700,
                          ),
                        ),
                    ],
                  ),
                ),
                const SizedBox(height: 16),

                // Period selector
                Text(
                  'Application Period',
                  style: AppTypography.bodyMSemiBold.copyWith(
                    color: AppColors.grey1050,
                  ),
                ),
                const SizedBox(height: 8),
                Row(
                  children: [
                    _PeriodChip(
                      label: 'Morning',
                      value: RoutinePeriod.am,
                      selected: product.period == RoutinePeriod.am,
                      onTap: () =>
                          _togglePeriod(context, product, RoutinePeriod.am),
                    ),
                    const SizedBox(width: 8),
                    _PeriodChip(
                      label: 'Evening',
                      value: RoutinePeriod.pm,
                      selected: product.period == RoutinePeriod.pm,
                      onTap: () =>
                          _togglePeriod(context, product, RoutinePeriod.pm),
                    ),
                    const SizedBox(width: 8),
                    _PeriodChip(
                      label: 'Both',
                      value: RoutinePeriod.both,
                      selected: product.period == RoutinePeriod.both,
                      onTap: () =>
                          _togglePeriod(context, product, RoutinePeriod.both),
                    ),
                  ],
                ),
                const SizedBox(height: 18),

                // ISO weekdays schedule (1..7)
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      'Weekly Schedule',
                      style: AppTypography.bodyMSemiBold.copyWith(
                        color: AppColors.grey1050,
                      ),
                    ),
                    Text(
                      product.days == null
                          ? 'Every day'
                          : '${activeDays.length} days / week',
                      style: AppTypography.bodyXsMedium.copyWith(
                        color: AppColors.primary700,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                KoraCard(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 12,
                    vertical: 12,
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: List.generate(7, (i) {
                      final isoDay = i + 1;
                      final isSelected = activeDays.contains(isoDay);
                      return Semantics(
                        button: true,
                        selected: isSelected,
                        label: 'Weekday $isoDay',
                        child: GestureDetector(
                          onTap: () => _toggleDay(context, product, isoDay),
                          child: Container(
                            width: 38,
                            height: 38,
                            decoration: BoxDecoration(
                              color: isSelected
                                  ? AppColors.primary700
                                  : AppColors.grey100,
                              borderRadius: BorderRadius.circular(10),
                              border: Border.all(
                                color: isSelected
                                    ? AppColors.primary700
                                    : AppColors.grey300,
                              ),
                            ),
                            alignment: Alignment.center,
                            child: Text(
                              _weekdayLabels[i],
                              style: AppTypography.bodySSemiBold.copyWith(
                                color: isSelected
                                    ? AppColors.grey50
                                    : AppColors.grey800,
                              ),
                            ),
                          ),
                        ),
                      );
                    }),
                  ),
                ),
                const SizedBox(height: 18),

                // Key Actives & Raw INCI
                Text(
                  'Active Ingredients & Formula',
                  style: AppTypography.bodyMSemiBold.copyWith(
                    color: AppColors.grey1050,
                  ),
                ),
                const SizedBox(height: 8),
                KoraCard(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Wrap(
                        spacing: 6,
                        runSpacing: 6,
                        children: product.actives.isNotEmpty
                            ? product.actives.map((a) {
                                return Container(
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: 10,
                                    vertical: 4,
                                  ),
                                  decoration: BoxDecoration(
                                    color: AppColors.primary50,
                                    borderRadius: BorderRadius.circular(8),
                                    border: Border.all(
                                      color: AppColors.primary200,
                                    ),
                                  ),
                                  child: Text(
                                    a,
                                    style: AppTypography.bodyXsSemiBold
                                        .copyWith(
                                          color: AppColors.primary900,
                                        ),
                                  ),
                                );
                              }).toList()
                            : [
                                Text(
                                  'Gentle barrier formula (no strong actives)',
                                  style: AppTypography.bodySRegular.copyWith(
                                    color: AppColors.grey700,
                                  ),
                                ),
                              ],
                      ),
                      if (product.ingredientsRaw != null &&
                          product.ingredientsRaw!.isNotEmpty) ...[
                        const Divider(height: 20, color: AppColors.grey200),
                        Text(
                          'INCI List (OCR)',
                          style: AppTypography.bodyXsBold.copyWith(
                            color: AppColors.grey800,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          product.ingredientsRaw!,
                          style: AppTypography.bodyXsRegular.copyWith(
                            color: AppColors.grey700,
                            height: 1.45,
                          ),
                        ),
                      ],
                    ],
                  ),
                ),
                const SizedBox(height: 24),

                PrimaryButton(
                  text: 'View full ingredient breakdown',
                  height: 52,
                  backgroundColor: AppColors.primary700,
                  onPressed: () => context.push(
                    AppRoutes.buildRoutineIngredientsPath(product.id),
                  ),
                ),
                const SizedBox(height: 10),
                SecondaryButton(
                  text: isExperiment
                      ? 'View active 6-week experiment'
                      : 'Test this product in an experiment',
                  height: 52,
                  textColor: AppColors.grey900,
                  onPressed: () => context.push(
                    isExperiment
                        ? AppRoutes.buildExperimentPath('1')
                        : AppRoutes.experimentNew,
                  ),
                ),
                const SizedBox(height: 20),
              ],
            ),
          ),
        );
      },
    );
  }
}

class _PeriodChip extends StatelessWidget {
  const _PeriodChip({
    required this.label,
    required this.value,
    required this.selected,
    required this.onTap,
  });

  final String label;
  final String value;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: GestureDetector(
        onTap: onTap,
        child: Container(
          height: 44,
          decoration: BoxDecoration(
            color: selected ? AppColors.primary700 : AppColors.grey50,
            borderRadius: BorderRadius.circular(10),
            border: Border.all(
              color: selected ? AppColors.primary700 : AppColors.grey300,
            ),
          ),
          alignment: Alignment.center,
          child: Text(
            label,
            style: AppTypography.bodySMedium.copyWith(
              color: selected ? AppColors.grey50 : AppColors.grey800,
            ),
          ),
        ),
      ),
    );
  }
}
