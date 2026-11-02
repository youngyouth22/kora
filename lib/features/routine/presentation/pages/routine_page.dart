import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:get_it/get_it.dart';
import 'package:go_router/go_router.dart';
import 'package:kora/common/app_colors.dart';
import 'package:kora/common/app_typography.dart';
import 'package:kora/common/widgets/empty_state_view.dart';
import 'package:kora/common/widgets/kora_card.dart';
import 'package:kora/common/widgets/primary_button.dart';
import 'package:kora/core/router/app_routes.dart';
import 'package:kora/features/routine/domain/entities/routine_product.dart';
import 'package:kora/features/routine/presentation/bloc/routine_bloc.dart';
import 'package:kora/features/routine/presentation/bloc/routine_event.dart';
import 'package:kora/features/routine/presentation/bloc/routine_state.dart';
import 'package:kora/features/routine/presentation/widgets/routine_adherence_summary_card.dart';
import 'package:kora/features/routine/presentation/widgets/routine_compatibility_banner.dart';
import 'package:kora/features/routine/presentation/widgets/routine_daily_checkin_card.dart';
import 'package:kora/features/routine/presentation/widgets/routine_period_switcher.dart';
import 'package:kora/features/routine/presentation/widgets/routine_step_card.dart';
import 'package:kora/features/routine/routine_injection.dart';

/// Main Routine & Products dashboard screen (Branch 1 of KoraShellScaffold).
///
/// Minimalist, modern, flat design (zero drop shadows, zero gradients, 1dp
/// borders) backed by [RoutineBloc] and SQL-aligned local Drift storage.
class RoutinePage extends StatelessWidget {
  /// Creates a [RoutinePage].
  const RoutinePage({
    this.initialPeriod,
    super.key,
  });

  /// Optional query parameter (`?period=am` or `?period=pm`) from SQL
  /// deep links.
  final String? initialPeriod;

  @override
  Widget build(BuildContext context) {
    final getIt = GetIt.instance;
    if (!getIt.isRegistered<RoutineBloc>()) {
      initRoutineInjection(getIt);
    }
    final bloc = getIt<RoutineBloc>();
    if (bloc.state.status.isInitial || bloc.state.status.isFailure) {
      bloc.add(RoutineStarted(initialPeriod: initialPeriod));
    } else if (initialPeriod != null &&
        initialPeriod != bloc.state.selectedPeriod) {
      bloc.add(RoutinePeriodChanged(initialPeriod!));
    }

    return BlocProvider<RoutineBloc>.value(
      value: bloc,
      child: const _RoutineDashboardView(),
    );
  }
}

class _RoutineDashboardView extends StatelessWidget {
  const _RoutineDashboardView();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.scaffoldColor,
      appBar: AppBar(
        backgroundColor: AppColors.scaffoldColor,
        elevation: 0,
        scrolledUnderElevation: 0,
        title: Text(
          'Skincare Routine',
          style: AppTypography.h5Bold.copyWith(color: AppColors.grey1050),
        ),
        actions: [
          Semantics(
            button: true,
            label: 'Browse curated product catalog',
            child: IconButton(
              tooltip: 'Product Catalog',
              icon: const Icon(
                Icons.grid_view_outlined,
                color: AppColors.grey900,
              ),
              onPressed: () => context.push(AppRoutes.routineCatalog),
            ),
          ),
          Semantics(
            button: true,
            label: 'Scan ingredient label with camera OCR',
            child: IconButton(
              tooltip: 'Scan Label (OCR)',
              icon: const Icon(
                Icons.document_scanner_outlined,
                color: AppColors.primary700,
              ),
              onPressed: () => context.push(AppRoutes.routineLabel),
            ),
          ),
          const SizedBox(width: 4),
        ],
      ),
      body: SafeArea(
        child: BlocBuilder<RoutineBloc, RoutineState>(
          builder: (context, state) {
            if (state.status.isLoading && state.products.isEmpty) {
              return const _RoutineLoadingSkeleton();
            }

            if (state.status.isFailure && state.products.isEmpty) {
              return Center(
                child: Padding(
                  padding: const EdgeInsets.all(24),
                  child: EmptyStateView(
                    title: 'Could not load your routine',
                    message:
                        state.errorMessage ??
                        'Check your local storage and try reloading.',
                    primaryActionLabel: 'Retry',
                    onPrimaryAction: () => context.read<RoutineBloc>().add(
                      const RoutineStarted(),
                    ),
                  ),
                ),
              );
            }

            final am = state.amSummary;
            final pm = state.pmSummary;
            final periodProducts = state.activePeriodProducts;
            final currentSummary = state.selectedPeriod == RoutinePeriod.am
                ? am
                : pm;

            return RefreshIndicator(
              color: AppColors.primary700,
              onRefresh: () async {
                context.read<RoutineBloc>().add(const RoutineStarted());
              },
              child: ListView(
                padding: const EdgeInsets.symmetric(
                  horizontal: 20,
                  vertical: 8,
                ),
                children: [
                  RoutinePeriodSwitcher(
                    selectedPeriod: state.selectedPeriod,
                    amCompleted: am.completed,
                    amTotal: am.total,
                    pmCompleted: pm.completed,
                    pmTotal: pm.total,
                    onPeriodSelected: (period) => context
                        .read<RoutineBloc>()
                        .add(RoutinePeriodChanged(period)),
                  ),
                  const SizedBox(height: 16),
                  RoutineAdherenceSummaryCard(
                    completedSteps: currentSummary.completed,
                    totalSteps: currentSummary.total,
                    weeklyAdherenceDays: state.weeklyAdherenceDays,
                    onExperimentTap: () {
                      if (state.experimentProductId != null) {
                        unawaited(
                          context.push(AppRoutes.buildExperimentPath('1')),
                        );
                      } else {
                        unawaited(context.push(AppRoutes.experimentNew));
                      }
                    },
                  ),
                  const SizedBox(height: 10),
                  RoutineDailyCheckinCard(
                    checkin: state.todayCheckin,
                    onTap: () => context.push(AppRoutes.routineCheckin),
                  ),
                  for (final notice in state.compatibilityNotices) ...[
                    const SizedBox(height: 10),
                    RoutineCompatibilityBanner(notice: notice),
                  ],
                  const SizedBox(height: 20),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Expanded(
                        child: Text(
                          state.selectedPeriod == RoutinePeriod.am
                              ? 'Morning Protocol (AM)'
                              : 'Evening Protocol (PM)',
                          style: AppTypography.h6Bold.copyWith(
                            color: AppColors.grey1050,
                          ),
                        ),
                      ),
                      Semantics(
                        button: true,
                        label: 'Explore product catalog',
                        child: InkWell(
                          onTap: () => context.push(AppRoutes.routineCatalog),
                          borderRadius: BorderRadius.circular(6),
                          child: Padding(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 6,
                              vertical: 2,
                            ),
                            child: Text(
                              'Browse catalog',
                              style: AppTypography.bodyXsSemiBold.copyWith(
                                color: AppColors.primary700,
                              ),
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 10),
                  if (periodProducts.isEmpty)
                    _EmptyPeriodCard(
                      period: state.selectedPeriod,
                      onAddTap: () => context.push(AppRoutes.routineAdd),
                    )
                  else
                    ...List.generate(periodProducts.length, (index) {
                      final product = periodProducts[index];
                      final isDone = state.isStepDone(product.id);
                      final isExperiment =
                          product.id == state.experimentProductId;

                      return Padding(
                        padding: const EdgeInsets.only(bottom: 10),
                        child: RoutineStepCard(
                          product: product,
                          stepIndex: index + 1,
                          isDone: isDone,
                          isInExperiment: isExperiment,
                          onToggleDone: () => context.read<RoutineBloc>().add(
                            RoutineStepToggled(itemId: product.id),
                          ),
                          onCardTap: () => context.push(
                            AppRoutes.buildRoutineProductDetailPath(product.id),
                          ),
                          onIngredientsTap: () => context.push(
                            AppRoutes.buildRoutineIngredientsPath(product.id),
                          ),
                        ),
                      );
                    }),
                  const SizedBox(height: 14),
                  PrimaryButton(
                    text: '+ Add product to routine',
                    height: 52,
                    backgroundColor: AppColors.primary700,
                    onPressed: () => context.push(AppRoutes.routineAdd),
                  ),
                  const SizedBox(height: 24),
                ],
              ),
            );
          },
        ),
      ),
    );
  }
}

class _EmptyPeriodCard extends StatelessWidget {
  const _EmptyPeriodCard({
    required this.period,
    required this.onAddTap,
  });

  final String period;
  final VoidCallback onAddTap;

  @override
  Widget build(BuildContext context) {
    final label = period == RoutinePeriod.am ? 'morning' : 'evening';
    return KoraCard(
      padding: const EdgeInsets.all(24),
      child: Column(
        children: [
          const Icon(
            Icons.spa_outlined,
            size: 32,
            color: AppColors.primary700,
          ),
          const SizedBox(height: 10),
          Text(
            'Your $label routine is empty',
            style: AppTypography.bodyLSemiBold.copyWith(
              color: AppColors.grey1050,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            'Add a cleanser, treatment, or SPF to track your daily '
            'consistency.',
            textAlign: TextAlign.center,
            style: AppTypography.bodySRegular.copyWith(
              color: AppColors.grey700,
            ),
          ),
        ],
      ),
    );
  }
}

class _RoutineLoadingSkeleton extends StatelessWidget {
  const _RoutineLoadingSkeleton();

  @override
  Widget build(BuildContext context) {
    return ListView.separated(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
      itemCount: 4,
      separatorBuilder: (_, _) => const SizedBox(height: 12),
      itemBuilder: (_, index) {
        return Container(
          height: index == 0 ? 48 : 96,
          decoration: BoxDecoration(
            color: AppColors.grey100,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: AppColors.grey300),
          ),
        );
      },
    );
  }
}
