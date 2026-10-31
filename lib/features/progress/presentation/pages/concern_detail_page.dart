// ignore_for_file: document_ignores, lines_longer_than_80_chars

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:get_it/get_it.dart';
import 'package:go_router/go_router.dart';
import 'package:kora/common/app_colors.dart';
import 'package:kora/common/app_typography.dart';
import 'package:kora/common/widgets/kora_card.dart';
import 'package:kora/common/widgets/kora_delta_pill.dart';
import 'package:kora/common/widgets/kora_score_ring.dart';
import 'package:kora/common/widgets/primary_button.dart';
import 'package:kora/common/widgets/secondary_button.dart';
import 'package:kora/core/router/app_routes.dart';
import 'package:kora/features/progress/presentation/bloc/progress_bloc.dart';
import 'package:kora/features/progress/presentation/bloc/progress_event.dart';
import 'package:kora/features/progress/presentation/bloc/progress_state.dart';
import 'package:kora/features/progress/presentation/widgets/progress_detail_widgets.dart';
import 'package:kora/features/progress/presentation/widgets/progress_segment_control.dart';
import 'package:kora/features/progress/presentation/widgets/progress_trajectory_chart_card.dart';
import 'package:kora/features/progress/progress_injection.dart';

/// Full-screen concern progression breakdown (`C04` in blueprint).
///
/// Rendered on the root navigator so the bottom shell navigation bar is hidden.
class ConcernDetailPage extends StatelessWidget {
  /// Creates a [ConcernDetailPage].
  const ConcernDetailPage({
    this.concernType = 'age_spot',
    super.key,
  });

  /// Concern identifier passed via route parameter (`/progress/concern/:type`).
  final String concernType;

  @override
  Widget build(BuildContext context) {
    final getIt = GetIt.instance;
    if (!getIt.isRegistered<ProgressBloc>()) {
      initProgressInjection(getIt);
    }
    final bloc = getIt<ProgressBloc>();
    if (bloc.state.status.isInitial) {
      bloc.add(const ProgressStarted());
    }

    return BlocProvider<ProgressBloc>.value(
      value: bloc,
      child: _ConcernDetailView(concernType: concernType),
    );
  }
}

class _ConcernDetailView extends StatelessWidget {
  const _ConcernDetailView({required this.concernType});

  final String concernType;

  static const List<String> _shortMonths = [
    'Jan',
    'Feb',
    'Mar',
    'Apr',
    'May',
    'Jun',
    'Jul',
    'Aug',
    'Sep',
    'Oct',
    'Nov',
    'Dec',
  ];

  String _shortDate(DateTime dt) => '${_shortMonths[dt.month - 1]} ${dt.day}';

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<ProgressBloc, ProgressState>(
      builder: (context, state) {
        final concernMeta = state.findConcernType(concernType);
        final title = concernMeta?.label ?? 'Dark spots';
        final canonicalKey = concernMeta?.key ?? 'age_spot';
        final traj = state.concernTrajectoryFor(canonicalKey);
        final currentScore = traj.current.round();

        final points = List.generate(traj.scans.length, (i) {
          final s = traj.scans[i];
          return TrajectoryDataPoint(
            label: _shortDate(s.createdAt),
            rawScore: i < traj.rawScores.length ? traj.rawScores[i] : 65,
            plottedScore: i < traj.plottedScores.length
                ? traj.plottedScores[i]
                : 65,
          );
        });

        final latestZones =
            state.latestScan?.regionalConcerns(canonicalKey) ?? const [];
        final baselineZones =
            state.baselineScan?.regionalConcerns(canonicalKey) ?? const [];

        return Scaffold(
          backgroundColor: AppColors.scaffoldColor,
          appBar: AppBar(
            backgroundColor: AppColors.scaffoldColor,
            elevation: 0,
            scrolledUnderElevation: 0,
            title: Text(
              title,
              style: AppTypography.h5Bold.copyWith(color: AppColors.grey1050),
            ),
            actions: [
              Semantics(
                button: true,
                label: 'Compare baseline and latest scans',
                child: IconButton(
                  tooltip: 'Compare Scans',
                  icon: const Icon(
                    Icons.compare_arrows_rounded,
                    color: AppColors.primary700,
                  ),
                  onPressed: () => context.push(
                    AppRoutes.buildComparePath(
                      state.baselineScan?.id ?? 'scan_1',
                      state.latestScan?.id ?? 'scan_8',
                    ),
                  ),
                ),
              ),
            ],
          ),
          body: SafeArea(
            child: ListView(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
              children: [
                // 1. Score & Trend Hero Card
                KoraCard(
                  padding: const EdgeInsets.all(20),
                  child: Column(
                    children: [
                      KoraScoreRing(
                        score: currentScore,
                        size: ScoreRingSize.l,
                        subtitle: 'Raw precision score (0–100)',
                      ),
                      const SizedBox(height: 12),
                      KoraDeltaPill(
                        delta: traj.delta,
                        isStable: traj.isStable,
                      ),
                      const SizedBox(height: 6),
                      Text(
                        'Baseline ${traj.baseline.toStringAsFixed(1)} → Now ${traj.current.toStringAsFixed(1)} '
                        '(${traj.delta >= 0 ? "+${traj.delta}" : "${traj.delta}"} points)',
                        style: AppTypography.bodySMedium.copyWith(
                          color: AppColors.grey800,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        'Higher scores reflect improved skin clarity and barrier consistency.',
                        style: AppTypography.bodyXsRegular.copyWith(
                          color: AppColors.grey700,
                        ),
                        textAlign: TextAlign.center,
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 16),

                // 2. Range Filter & Dedicated Trajectory Chart
                ProgressRangeFilterBar(
                  selectedRange: state.selectedRange,
                  smoothEnabled: state.smoothEnabled,
                  onRangeSelected: (idx) => context.read<ProgressBloc>().add(
                    ProgressRangeChanged(idx),
                  ),
                  onSmoothToggled: () => context.read<ProgressBloc>().add(
                    const ProgressSmoothingToggled(),
                  ),
                ),
                const SizedBox(height: 12),
                ProgressTrajectoryChartCard(
                  title: '$title Trajectory',
                  subtitle: 'Weekly raw_score progression with ±3.0 pt noise threshold',
                  delta: traj.delta,
                  isStable: traj.isStable,
                  points: points,
                ),
                if (latestZones.isNotEmpty) ...[
                  const SizedBox(height: 16),
                  ConcernRegionalZoneCard(
                    latestZones: latestZones,
                    baselineZones: baselineZones,
                  ),
                ],
                const SizedBox(height: 16),

                // 3. What this means
                Text(
                  'What this means',
                  style: AppTypography.h6Bold.copyWith(
                    color: AppColors.grey1050,
                  ),
                ),
                const SizedBox(height: 8),
                KoraCard(
                  child: Text(
                    concernMeta?.description ?? 'Pigment spots and uneven tone are caused by melanin clusters responding to sun exposure or past breakouts. Improvement occurs as superficial skin cells gradually shed over 6 to 12 weeks.',
                    style: AppTypography.bodySRegular.copyWith(
                      color: AppColors.grey900,
                      height: 1.5,
                    ),
                  ),
                ),
                const SizedBox(height: 16),

                // 4. What can help (Evidence-based actives)
                Text(
                  'What can help',
                  style: AppTypography.h6Bold.copyWith(
                    color: AppColors.grey1050,
                  ),
                ),
                const SizedBox(height: 8),
                KoraCard(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Evidence-based cosmetic active categories:',
                        style: AppTypography.bodyXsMedium.copyWith(
                          color: AppColors.grey700,
                        ),
                      ),
                      const SizedBox(height: 10),
                      if (concernMeta != null &&
                          concernMeta.recommendedActives.isNotEmpty)
                        for (final active in concernMeta.recommendedActives)
                          Padding(
                            padding: const EdgeInsets.only(bottom: 8),
                            child: _buildIngredientRow(
                              active.name,
                              active.role,
                            ),
                          )
                      else ...[
                        _buildIngredientRow(
                          'Azelaic Acid 10%',
                          'Calms redness while inhibiting tyrosinase.',
                        ),
                        const SizedBox(height: 8),
                        _buildIngredientRow(
                          'Vitamin C (L-Ascorbic)',
                          'Antioxidant shield promoting even luminosity.',
                        ),
                      ],
                    ],
                  ),
                ),
                const SizedBox(height: 16),

                // 5. Related Academy Resource
                Text(
                  'Related resources',
                  style: AppTypography.h6Bold.copyWith(
                    color: AppColors.grey1050,
                  ),
                ),
                const SizedBox(height: 8),
                KoraCard(
                  onTap: () => context.push(
                    AppRoutes.buildLearnVideoPath(
                      concernMeta?.relatedVideoId ?? '2',
                    ),
                  ),
                  padding: const EdgeInsets.all(14),
                  child: Row(
                    children: [
                      Container(
                        width: 40,
                        height: 40,
                        decoration: BoxDecoration(
                          color: AppColors.primary50,
                          borderRadius: BorderRadius.circular(8),
                          border: Border.all(color: AppColors.primary200),
                        ),
                        alignment: Alignment.center,
                        child: const Icon(
                          Icons.play_circle_outline_rounded,
                          color: AppColors.primary700,
                          size: 22,
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              concernMeta?.relatedVideoTitle ?? 'The truth about dark spot treatments (11 min)',
                              style: AppTypography.bodySMedium.copyWith(
                                color: AppColors.grey1050,
                              ),
                            ),
                            Text(
                              'Skin Academy · Dermatologist guide',
                              style: AppTypography.bodyXsRegular.copyWith(
                                color: AppColors.grey700,
                              ),
                            ),
                          ],
                        ),
                      ),
                      const Icon(
                        Icons.chevron_right_rounded,
                        color: AppColors.grey600,
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 24),

                // 6. Primary & Secondary CTAs
                PrimaryButton(
                  text: 'Test a product for this',
                  height: 52,
                  backgroundColor: AppColors.primary700,
                  onPressed: () => context.push(AppRoutes.experimentNew),
                ),
                const SizedBox(height: 10),
                SecondaryButton(
                  text: 'Browse matching products in catalog',
                  height: 52,
                  textColor: AppColors.grey900,
                  onPressed: () => context.push(AppRoutes.routineCatalog),
                ),
                const SizedBox(height: 16),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildIngredientRow(String title, String desc) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          width: 6,
          height: 6,
          margin: const EdgeInsets.only(top: 6, right: 10),
          decoration: const BoxDecoration(
            shape: BoxShape.circle,
            color: AppColors.primary700,
          ),
        ),
        Expanded(
          child: RichText(
            text: TextSpan(
              style: AppTypography.bodySRegular.copyWith(
                color: AppColors.grey900,
              ),
              children: [
                TextSpan(
                  text: '$title: ',
                  style: AppTypography.bodySSemiBold.copyWith(
                    color: AppColors.grey1050,
                  ),
                ),
                TextSpan(text: desc),
              ],
            ),
          ),
        ),
      ],
    );
  }
}
