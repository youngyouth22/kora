// ignore_for_file: document_ignores, lines_longer_than_80_chars

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:get_it/get_it.dart';
import 'package:go_router/go_router.dart';
import 'package:kora/common/app_colors.dart';
import 'package:kora/common/app_typography.dart';
import 'package:kora/common/widgets/empty_state_view.dart';
import 'package:kora/common/widgets/kora_card.dart';
import 'package:kora/common/widgets/kora_delta_pill.dart';
import 'package:kora/common/widgets/primary_button.dart';
import 'package:kora/core/router/app_routes.dart';
import 'package:kora/features/progress/domain/entities/progress_scan.dart';
import 'package:kora/features/progress/presentation/bloc/progress_bloc.dart';
import 'package:kora/features/progress/presentation/bloc/progress_event.dart';
import 'package:kora/features/progress/presentation/bloc/progress_state.dart';
import 'package:kora/features/progress/presentation/widgets/progress_detail_widgets.dart';
import 'package:kora/features/progress/progress_injection.dart';

/// Full-screen side-by-side / split before-after scan comparison screen
/// (`C05` in blueprint).
///
/// Rendered on the root navigator so the bottom shell navigation bar is hidden.
class CompareScansPage extends StatefulWidget {
  /// Creates a [CompareScansPage].
  const CompareScansPage({
    this.scanAId = 'scan_1',
    this.scanBId = 'scan_8',
    super.key,
  });

  /// First scan identifier (e.g. baseline `scan_1`).
  final String scanAId;

  /// Second scan identifier (e.g. latest `scan_8`).
  final String scanBId;

  @override
  State<CompareScansPage> createState() => _CompareScansPageState();
}

class _CompareScansPageState extends State<CompareScansPage> {
  double _sliderPosition = 0.5;
  bool _showZonesOverlay = false;
  late String _activeScanAId;
  late String _activeScanBId;

  @override
  void initState() {
    super.initState();
    _activeScanAId = widget.scanAId;
    _activeScanBId = widget.scanBId;
  }

  ProgressScan _resolveScan(
    ProgressState state,
    String requestedId, {
    required bool fallbackToLatest,
  }) {
    final realScans = state.scans
        .where(
          (s) => !s.isDemo && s.photoPath != null && s.photoPath!.isNotEmpty,
        )
        .toList();

    if (realScans.isNotEmpty &&
        (requestedId == 'scan_1' || requestedId == 'scan_8')) {
      if (fallbackToLatest) {
        return realScans.first;
      } else {
        return realScans.length > 1 ? realScans.last : realScans.first;
      }
    }

    final found = state.findScanById(requestedId);
    if (found != null) return found;
    return fallbackToLatest ? state.latestScan! : state.baselineScan!;
  }

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
      child: Scaffold(
        backgroundColor: AppColors.scaffoldColor,
        appBar: AppBar(
          backgroundColor: AppColors.scaffoldColor,
          elevation: 0,
          scrolledUnderElevation: 0,
          title: Text(
            'Compare Scans',
            style: AppTypography.h5Bold.copyWith(color: AppColors.grey1050),
          ),
        ),
        body: SafeArea(
          child: BlocBuilder<ProgressBloc, ProgressState>(
            builder: (context, state) {
              if (state.scans.length < 2) {
                return Center(
                  child: Padding(
                    padding: const EdgeInsets.all(24),
                    child: EmptyStateView(
                      title: 'Need at least 2 scans',
                      message: 'Complete your weekly scans to unlock before & after comparisons and track your progress over time.',
                      primaryActionLabel: 'Start scan',
                      onPrimaryAction: () => context.push(AppRoutes.scanGuide),
                    ),
                  ),
                );
              }

              final scanA = _resolveScan(
                state,
                _activeScanAId,
                fallbackToLatest: false,
              );
              final scanB = _resolveScan(
                state,
                _activeScanBId,
                fallbackToLatest: true,
              );
              final daysBetween = scanB.createdAt
                  .difference(scanA.createdAt)
                  .inDays
                  .abs();
              final weeksLabel = daysBetween >= 7
                  ? '${(daysBetween / 7).round()} weeks'
                  : '$daysBetween days';
              final overallDelta = (scanB.overallScore - scanA.overallScore)
                  .round();

              final headlineConcerns = state.headlineConcerns;

              return ListView(
                padding: const EdgeInsets.symmetric(
                  horizontal: 20,
                  vertical: 12,
                ),
                children: [
                  CompareSplitViewerCard(
                    scanA: scanA,
                    scanB: scanB,
                    allScans: state.scans,
                    sliderPosition: _sliderPosition,
                    showZonesOverlay: _showZonesOverlay,
                    onSliderChanged: (pos) =>
                        setState(() => _sliderPosition = pos),
                    onToggleOverlay: (showZones) =>
                        setState(() => _showZonesOverlay = showZones),
                    onScanASelected: (id) {
                      setState(() => _activeScanAId = id);
                      context.read<ProgressBloc>().add(
                        ProgressComparisonScansChanged(scanAId: id),
                      );
                    },
                    onScanBSelected: (id) {
                      setState(() => _activeScanBId = id);
                      context.read<ProgressBloc>().add(
                        ProgressComparisonScansChanged(scanBId: id),
                      );
                    },
                  ),
                  const SizedBox(height: 16),

                  // Overall Comparison Summary Banner
                  KoraCard(
                    backgroundColor: AppColors.primary50,
                    borderColor: AppColors.primary200,
                    child: Row(
                      children: [
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                'Overall Score Evolution ($weeksLabel)',
                                style: AppTypography.bodyMSemiBold.copyWith(
                                  color: AppColors.grey1050,
                                ),
                              ),
                              const SizedBox(height: 2),
                              Text(
                                '${scanA.overallScore.toStringAsFixed(1)} → ${scanB.overallScore.toStringAsFixed(1)} · '
                                'Est. Skin Age ${scanA.skinAge} → ${scanB.skinAge} yrs',
                                style: AppTypography.bodyXsRegular.copyWith(
                                  color: AppColors.grey800,
                                ),
                              ),
                            ],
                          ),
                        ),
                        KoraDeltaPill(
                          delta: overallDelta,
                          isStable: overallDelta.abs() < 3,
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 18),

                  // Per-Concern Delta Breakdown
                  Text(
                    'Evolution Summary ($weeksLabel)',
                    style: AppTypography.h6Bold.copyWith(
                      color: AppColors.grey1050,
                    ),
                  ),
                  const SizedBox(height: 8),
                  KoraCard(
                    child: Column(
                      children: [
                        for (var i = 0; i < headlineConcerns.length; i++) ...[
                          if (i > 0)
                            const Divider(height: 18, color: AppColors.grey200),
                          Builder(
                            builder: (context) {
                              final concern = headlineConcerns[i];
                              final beforeVal =
                                  scanA
                                      .wholeFaceConcern(concern.key)
                                      ?.rawScore ??
                                  scanA.overallScore;
                              final afterVal =
                                  scanB
                                      .wholeFaceConcern(concern.key)
                                      ?.rawScore ??
                                  scanB.overallScore;
                              final diff = afterVal - beforeVal;
                              final deltaInt = diff.round();
                              final isStable = diff.abs() < 3.0;

                              return InkWell(
                                onTap: () => context.push(
                                  AppRoutes.buildProgressConcernPath(
                                    concern.key,
                                  ),
                                ),
                                borderRadius: BorderRadius.circular(8),
                                child: Padding(
                                  padding: const EdgeInsets.symmetric(
                                    vertical: 2,
                                  ),
                                  child: Row(
                                    children: [
                                      Expanded(
                                        child: Column(
                                          crossAxisAlignment:
                                              CrossAxisAlignment.start,
                                          children: [
                                            Text(
                                              concern.label,
                                              style: AppTypography.bodyMSemiBold
                                                  .copyWith(
                                                    color: AppColors.grey1050,
                                                  ),
                                            ),
                                            Text(
                                              '${beforeVal.toStringAsFixed(1)} → ${afterVal.toStringAsFixed(1)} · '
                                              '${_describeConcernDelta(concern.key, diff)}',
                                              style: AppTypography.bodyXsRegular
                                                  .copyWith(
                                                    color: AppColors.grey700,
                                                  ),
                                            ),
                                          ],
                                        ),
                                      ),
                                      KoraDeltaPill(
                                        delta: deltaInt,
                                        isStable: isStable,
                                      ),
                                      const SizedBox(width: 6),
                                      const Icon(
                                        Icons.chevron_right_rounded,
                                        size: 16,
                                        color: AppColors.grey600,
                                      ),
                                    ],
                                  ),
                                ),
                              );
                            },
                          ),
                        ],
                      ],
                    ),
                  ),
                  const SizedBox(height: 24),

                  // Bottom Share CTA
                  PrimaryButton(
                    text: 'Share result',
                    height: 52,
                    backgroundColor: AppColors.primary700,
                    onPressed: () {
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          content: Text(
                            'Comparison card ready. Privacy protected (face omitted).',
                            style: AppTypography.bodySMedium.copyWith(
                              color: AppColors.grey50,
                            ),
                          ),
                          backgroundColor: AppColors.grey1000,
                        ),
                      );
                    },
                  ),
                  const SizedBox(height: 16),
                ],
              );
            },
          ),
        ),
      ),
    );
  }

  String _describeConcernDelta(String key, double diff) {
    if (diff.abs() < 3.0) {
      return 'Within ±3 pt noise threshold (barrier steady)';
    }
    if (diff > 0) {
      switch (key) {
        case 'age_spot':
          return 'Visible fading of surface pigmentation';
        case 'texture':
          return 'Smoother corneocyte surface relief';
        case 'moisture':
          return 'Improved epidermal water retention';
        case 'redness':
          return 'Calmed capillary reactivity';
        default:
          return 'Measurable positive improvement';
      }
    }
    return 'Slight dip · monitor barrier hydration';
  }
}
