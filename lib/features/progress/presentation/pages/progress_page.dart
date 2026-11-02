// ignore_for_file: document_ignores, lines_longer_than_80_chars

import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:get_it/get_it.dart';
import 'package:go_router/go_router.dart';
import 'package:kora/common/app_colors.dart';
import 'package:kora/common/app_typography.dart';
import 'package:kora/common/widgets/empty_state_view.dart';
import 'package:kora/core/router/app_routes.dart';
import 'package:kora/features/progress/domain/entities/progress_scan.dart';
import 'package:kora/features/progress/presentation/bloc/progress_bloc.dart';
import 'package:kora/features/progress/presentation/bloc/progress_event.dart';
import 'package:kora/features/progress/presentation/bloc/progress_state.dart';
import 'package:kora/features/progress/presentation/widgets/progress_calendar_section.dart';
import 'package:kora/features/progress/presentation/widgets/progress_concern_grid_card.dart';
import 'package:kora/features/progress/presentation/widgets/progress_overall_section.dart';
import 'package:kora/features/progress/presentation/widgets/progress_segment_control.dart';
import 'package:kora/features/progress/presentation/widgets/progress_trajectory_chart_card.dart';
import 'package:kora/features/progress/progress_injection.dart';
import 'package:kora/features/skin_analysis/domain/entities/skin_analysis_result.dart';
import 'package:kora/features/skin_analysis/domain/entities/skin_concern.dart';
import 'package:kora/features/skin_analysis/domain/entities/skin_type_info.dart';

/// Main Progress & Comparison dashboard screen (Branch 3 of KoraShellScaffold).
///
/// Minimalist, modern, flat design (zero drop shadows, zero gradients, 1dp
/// borders) backed by [ProgressBloc] and SQL-aligned data (`public.scans`,
/// `public.scan_concerns`, `public.concern_types`, `public.experiments`,
/// `public.activity_days`, `public.streak_state`, `public.milestones`).
class ProgressPage extends StatelessWidget {
  /// Creates a [ProgressPage].
  const ProgressPage({
    this.initialSegment,
    super.key,
  });

  /// Optional initial segment tab (`0` = Overall, `1` = By concern,
  /// `2` = Calendar).
  final int? initialSegment;

  @override
  Widget build(BuildContext context) {
    final getIt = GetIt.instance;
    if (!getIt.isRegistered<ProgressBloc>()) {
      initProgressInjection(getIt);
    }
    final bloc = getIt<ProgressBloc>();
    if (bloc.state.status.isInitial || bloc.state.status.isFailure) {
      bloc.add(ProgressStarted(initialSegment: initialSegment));
    } else if (initialSegment != null &&
        initialSegment != bloc.state.selectedSegment) {
      bloc.add(ProgressSegmentChanged(initialSegment!));
    }

    return BlocProvider<ProgressBloc>.value(
      value: bloc,
      child: const _ProgressDashboardView(),
    );
  }

  /// Converts a [ProgressScan] into a [SkinAnalysisResult] for
  /// `ScanResultPage`.
  static SkinAnalysisResult toSkinAnalysisResult(
    ProgressScan scan,
    Map<String, String> labelsByKey,
  ) {
    return SkinAnalysisResult(
      overallScore: scan.overallScore,
      skinAge: scan.skinAge,
      resizedImageUrl: scan.photoPath,
      skinType: const SkinTypeInfo(
        overallType: 'Combination',
        tZoneType: 'Oily',
        uZoneType: 'Normal',
      ),
      allConcerns: scan.wholeFaceConcerns.map((c) {
        final maskPath = (c.maskPath != null && c.maskPath!.isNotEmpty)
            ? c.maskPath!
            : (scan.photoPath != null && scan.photoPath!.isNotEmpty
                  ? scan.photoPath!
                  : '');
        return SkinConcern(
          id: c.concernKey,
          displayName: labelsByKey[c.concernKey] ?? c.concernKey,
          uiScore: c.rawScore.round(),
          rawScore: c.rawScore,
          maskUrls: maskPath.isNotEmpty ? [maskPath] : const [],
        );
      }).toList(),
    );
  }
}

class _ProgressDashboardView extends StatelessWidget {
  const _ProgressDashboardView();

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
    return Scaffold(
      backgroundColor: AppColors.scaffoldColor,
      appBar: AppBar(
        backgroundColor: AppColors.scaffoldColor,
        elevation: 0,
        scrolledUnderElevation: 0,
        title: Text(
          'Skin Progress',
          style: AppTypography.h5Bold.copyWith(color: AppColors.grey1050),
        ),
        actions: [
          BlocBuilder<ProgressBloc, ProgressState>(
            builder: (context, state) {
              final scanA = state.baselineScan?.id ?? 'scan_1';
              final scanB = state.latestScan?.id ?? 'scan_8';
              return Semantics(
                button: true,
                label: 'Compare Scans',
                child: IconButton(
                  tooltip: 'Compare Scans',
                  icon: const Icon(
                    Icons.compare_arrows_rounded,
                    color: AppColors.primary700,
                  ),
                  onPressed: () =>
                      context.push(AppRoutes.buildComparePath(scanA, scanB)),
                ),
              );
            },
          ),
          const SizedBox(width: 4),
        ],
      ),
      body: SafeArea(
        child: BlocBuilder<ProgressBloc, ProgressState>(
          builder: (context, state) {
            if (state.status.isLoading && state.scans.isEmpty) {
              return const _ProgressLoadingSkeleton();
            }

            if (state.status.isFailure && state.scans.isEmpty) {
              return Center(
                child: Padding(
                  padding: const EdgeInsets.all(24),
                  child: EmptyStateView(
                    title: 'Could not load skin progress',
                    message:
                        state.errorMessage ??
                        'Check your local storage and try reloading.',
                    primaryActionLabel: 'Retry',
                    onPrimaryAction: () => context.read<ProgressBloc>().add(
                      const ProgressStarted(),
                    ),
                  ),
                ),
              );
            }

            if (state.scans.isEmpty) {
              return Center(
                child: Padding(
                  padding: const EdgeInsets.all(24),
                  child: EmptyStateView(
                    title: 'No skin scans recorded yet',
                    message: 'Take your first calibrated weekly scan to unlock your baseline and track real progress.',
                    primaryActionLabel: 'Start Scan Guide',
                    onPrimaryAction: () => context.push(AppRoutes.scanGuide),
                  ),
                ),
              );
            }

            return RefreshIndicator(
              color: AppColors.primary700,
              onRefresh: () async {
                context.read<ProgressBloc>().add(const ProgressStarted());
              },
              child: ListView(
                padding: const EdgeInsets.symmetric(
                  horizontal: 20,
                  vertical: 8,
                ),
                children: [
                  ProgressSegmentControl(
                    selectedIndex: state.selectedSegment,
                    onSelected: (idx) => context.read<ProgressBloc>().add(
                      ProgressSegmentChanged(idx),
                    ),
                  ),
                  const SizedBox(height: 16),
                  if (state.selectedSegment == 0)
                    _buildOverallTab(context, state),
                  if (state.selectedSegment == 1)
                    _buildByConcernTab(context, state),
                  if (state.selectedSegment == 2)
                    _buildCalendarTab(context, state),
                  const SizedBox(height: 28),
                ],
              ),
            );
          },
        ),
      ),
    );
  }

  Widget _buildOverallTab(BuildContext context, ProgressState state) {
    final latest = state.latestScan!;
    final baseline = state.baselineScan!;
    final chronoScans = state.filteredChronologicalScans;
    final plotted = state.overallTrajectoryValues;
    final delta = state.overallRangeDelta;
    final labelsByKey = <String, String>{
      for (final c in state.concernTypes) c.key: c.label,
    };

    final points = List.generate(chronoScans.length, (i) {
      final s = chronoScans[i];
      return TrajectoryDataPoint(
        label: _shortDate(s.createdAt),
        rawScore: s.overallScore,
        plottedScore: i < plotted.length ? plotted[i] : s.overallScore,
      );
    });

    final rangeLabel = state.selectedRange == 0
        ? '4 weeks'
        : (state.selectedRange == 1 ? '12 weeks' : '7 weeks');

    final activeExp = state.experiments.isNotEmpty
        ? state.experiments.first
        : null;
    final experimentAnnotation = activeExp != null
        ? ' · ${activeExp.title} started ${_shortDate(activeExp.startedAt)}'
        : ' · Calibrated tracking';

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        ProgressOverallHeroCard(
          latestScan: latest,
          baselineScan: baseline,
          totalScans: state.scans.length,
          onCompareTap: () => context.push(
            AppRoutes.buildComparePath(baseline.id, latest.id),
          ),
          onLatestScanTap: () => context.push(
            AppRoutes.buildScanResultPath(latest.id),
            extra: ProgressPage.toSkinAnalysisResult(latest, labelsByKey),
          ),
        ),
        const SizedBox(height: 16),
        ProgressRangeFilterBar(
          selectedRange: state.selectedRange,
          smoothEnabled: state.smoothEnabled,
          onRangeSelected: (idx) =>
              context.read<ProgressBloc>().add(ProgressRangeChanged(idx)),
          onSmoothToggled: () => context.read<ProgressBloc>().add(
            const ProgressSmoothingToggled(),
          ),
        ),
        const SizedBox(height: 12),
        ProgressTrajectoryChartCard(
          title: 'Overall Trajectory',
          subtitle:
              '${delta >= 0 ? "+$delta" : "$delta"} points over $rangeLabel$experimentAnnotation',
          delta: delta,
          isStable: delta.abs() < 3,
          points: points,
        ),
        if (state.experiments.isNotEmpty) ...[
          const SizedBox(height: 20),
          Text(
            'Controlled Product Experiments',
            style: AppTypography.h6Bold.copyWith(color: AppColors.grey1050),
          ),
          const SizedBox(height: 10),
          ProgressExperimentSpotlightCard(
            experiment: state.experiments.first,
            onDetailTap: () => context.push(
              AppRoutes.buildExperimentPath(state.experiments.first.id),
            ),
            onVerdictTap: () => context.push(
              AppRoutes.buildExperimentVerdictPath(state.experiments.first.id),
            ),
            onNewExperimentTap: () => context.push(AppRoutes.experimentNew),
          ),
        ],
        const SizedBox(height: 20),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              'Scan History (${state.scans.length})',
              style: AppTypography.h6Bold.copyWith(color: AppColors.grey1050),
            ),
            GestureDetector(
              onTap: () => context.push(
                AppRoutes.buildComparePath(baseline.id, latest.id),
              ),
              child: Text(
                'Compare any 2 scans',
                style: AppTypography.bodyXsSemiBold.copyWith(
                  color: AppColors.primary700,
                ),
              ),
            ),
          ],
        ),
        const SizedBox(height: 10),
        ...List.generate(state.scans.length, (index) {
          final scan = state.scans[index];
          final olderScan = index + 1 < state.scans.length
              ? state.scans[index + 1]
              : scan;
          final stepDelta = (scan.overallScore - olderScan.overallScore)
              .round();
          final isStable =
              index == state.scans.length - 1 ||
              (scan.overallScore - olderScan.overallScore).abs() < 1.0;

          return Padding(
            padding: const EdgeInsets.only(bottom: 10),
            child: ProgressScanHistoryTile(
              scan: scan,
              deltaFromPrevious: stepDelta,
              isStable: isStable,
              isLatest: index == 0,
              onTap: () => context.push(
                AppRoutes.buildScanResultPath(scan.id),
                extra: ProgressPage.toSkinAnalysisResult(scan, labelsByKey),
              ),
              onCompareWithLatest: () => context.push(
                AppRoutes.buildComparePath(scan.id, latest.id),
              ),
            ),
          );
        }),
      ],
    );
  }

  Widget _buildByConcernTab(BuildContext context, ProgressState state) {
    final headline = state.headlineConcerns;
    final secondary = state.secondaryConcerns;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Text(
          'Tap any concern for its 8-week curve, regional HD zones, and active ingredients',
          style: AppTypography.bodySRegular.copyWith(color: AppColors.grey700),
        ),
        const SizedBox(height: 14),
        Text(
          'Primary Headline Concerns (6)',
          style: AppTypography.bodyMSemiBold.copyWith(
            color: AppColors.grey1050,
          ),
        ),
        const SizedBox(height: 10),
        ...headline.map((concern) {
          final traj = state.concernTrajectoryFor(concern.key);
          return Padding(
            padding: const EdgeInsets.only(bottom: 10),
            child: ProgressConcernMetricCard(
              concernType: concern,
              currentScore: traj.current,
              baselineScore: traj.baseline,
              delta: traj.delta,
              isStable: traj.isStable,
              sparklineValues: traj.plottedScores,
              onTap: () => context.push(
                AppRoutes.buildProgressConcernPath(concern.key),
              ),
            ),
          );
        }),
        if (secondary.isNotEmpty) ...[
          const SizedBox(height: 14),
          Text(
            'Secondary Structural & Orbital Metrics (6)',
            style: AppTypography.bodyMSemiBold.copyWith(
              color: AppColors.grey1050,
            ),
          ),
          const SizedBox(height: 10),
          ...secondary.map((concern) {
            final traj = state.concernTrajectoryFor(concern.key);
            return Padding(
              padding: const EdgeInsets.only(bottom: 10),
              child: ProgressConcernMetricCard(
                concernType: concern,
                currentScore: traj.current,
                baselineScore: traj.baseline,
                delta: traj.delta,
                isStable: traj.isStable,
                sparklineValues: traj.plottedScores,
                onTap: () => context.push(
                  AppRoutes.buildProgressConcernPath(concern.key),
                ),
              ),
            );
          }),
        ],
      ],
    );
  }

  Widget _buildCalendarTab(BuildContext context, ProgressState state) {
    final labelsByKey = <String, String>{
      for (final c in state.concernTypes) c.key: c.label,
    };

    return ProgressCalendarSection(
      activeMonth: state.activeMonth,
      selectedDay: state.selectedCalendarDay,
      activityDays: state.activityDays,
      streakState: state.streakState,
      milestones: state.milestones,
      onPreviousMonth: () {
        final prev = DateTime(
          state.activeMonth.year,
          state.activeMonth.month - 1,
        );
        context.read<ProgressBloc>().add(ProgressMonthChanged(prev));
      },
      onNextMonth: () {
        final next = DateTime(
          state.activeMonth.year,
          state.activeMonth.month + 1,
        );
        context.read<ProgressBloc>().add(ProgressMonthChanged(next));
      },
      onDaySelected: (day) {
        context.read<ProgressBloc>().add(ProgressCalendarDaySelected(day));
      },
      onScanInspectTap: (scanId) {
        final scan = state.findScanById(scanId);
        if (scan != null) {
          unawaited(
            context.push(
              AppRoutes.buildScanResultPath(scan.id),
              extra: ProgressPage.toSkinAnalysisResult(scan, labelsByKey),
            ),
          );
        }
      },
    );
  }
}

class _ProgressLoadingSkeleton extends StatelessWidget {
  const _ProgressLoadingSkeleton();

  @override
  Widget build(BuildContext context) {
    return ListView.separated(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
      itemCount: 4,
      separatorBuilder: (_, _) => const SizedBox(height: 12),
      itemBuilder: (_, index) {
        return Container(
          height: index == 0 ? 48 : 130,
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
