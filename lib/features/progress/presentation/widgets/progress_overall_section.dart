// ignore_for_file: document_ignores, lines_longer_than_80_chars, avoid_redundant_argument_values

import 'package:flutter/material.dart';
import 'package:kora/common/app_colors.dart';
import 'package:kora/common/app_typography.dart';
import 'package:kora/common/widgets/kora_card.dart';
import 'package:kora/common/widgets/kora_delta_pill.dart';
import 'package:kora/common/widgets/kora_score_ring.dart';
import 'package:kora/features/progress/domain/entities/progress_models.dart';
import 'package:kora/features/progress/domain/entities/progress_scan.dart';

/// Hero summary banner on the Overall Progress tab displaying the latest
/// composite `raw_score`, biological skin age, total completed scans, and
/// a direct shortcut to side-by-side scan comparison.
class ProgressOverallHeroCard extends StatelessWidget {
  /// Creates a [ProgressOverallHeroCard].
  const ProgressOverallHeroCard({
    required this.latestScan,
    required this.baselineScan,
    required this.totalScans,
    required this.onCompareTap,
    required this.onLatestScanTap,
    super.key,
  });

  /// Newest completed scan.
  final ProgressScan latestScan;

  /// Initial baseline scan.
  final ProgressScan baselineScan;

  /// Total number of completed scans (`scans.length`).
  final int totalScans;

  /// Callback to open `CompareScansPage`.
  final VoidCallback onCompareTap;

  /// Callback to open `ScanResultPage` for [latestScan].
  final VoidCallback onLatestScanTap;

  @override
  Widget build(BuildContext context) {
    final totalDelta = (latestScan.overallScore - baselineScan.overallScore)
        .round();
    final ageDelta = latestScan.skinAge - baselineScan.skinAge;

    return KoraCard(
      padding: const EdgeInsets.all(18),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Row(
            children: [
              GestureDetector(
                onTap: onLatestScanTap,
                child: KoraScoreRing(
                  score: latestScan.overallScore.round(),
                  ringColor: AppColors.primary700,
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 8,
                            vertical: 2,
                          ),
                          decoration: BoxDecoration(
                            color: AppColors.primary50,
                            borderRadius: BorderRadius.circular(6),
                            border: Border.all(color: AppColors.primary200),
                          ),
                          child: Text(
                            'RAW PRECISION SCORE',
                            style: AppTypography.bodyXsBold.copyWith(
                              color: AppColors.primary800,
                              letterSpacing: 0.4,
                            ),
                          ),
                        ),
                        const SizedBox(width: 8),
                        KoraDeltaPill(
                          delta: totalDelta,
                          isStable: totalDelta.abs() < 3,
                        ),
                      ],
                    ),
                    const SizedBox(height: 6),
                    Text(
                      '${latestScan.overallScore.toStringAsFixed(1)} / 100 Overall',
                      style: AppTypography.h5Bold.copyWith(
                        color: AppColors.grey1050,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      'Baseline ${baselineScan.overallScore.toStringAsFixed(1)} → Now ${latestScan.overallScore.toStringAsFixed(1)} across $totalScans weekly scans',
                      style: AppTypography.bodyXsRegular.copyWith(
                        color: AppColors.grey700,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          const Divider(height: 1, color: AppColors.grey200),
          const SizedBox(height: 12),
          Row(
            children: [
              Expanded(
                child: _MetricPill(
                  label: 'Est. Skin Age',
                  value: '${latestScan.skinAge} yrs',
                  badge: ageDelta < 0 ? '$ageDelta yrs' : 'Steady',
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: _MetricPill(
                  label: 'Capture Quality',
                  value: latestScan.qualityOk ? 'Calibrated HD' : 'Standard',
                  badge: '96% match',
                ),
              ),
              const SizedBox(width: 10),
              Semantics(
                button: true,
                label: 'Compare baseline and latest scans side by side',
                child: InkWell(
                  onTap: onCompareTap,
                  borderRadius: BorderRadius.circular(10),
                  child: Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 12,
                      vertical: 10,
                    ),
                    decoration: BoxDecoration(
                      color: AppColors.primary700,
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        const Icon(
                          Icons.compare_arrows_rounded,
                          size: 16,
                          color: AppColors.grey50,
                        ),
                        const SizedBox(width: 6),
                        Text(
                          'Compare',
                          style: AppTypography.bodyXsBold.copyWith(
                            color: AppColors.grey50,
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
      ),
    );
  }
}

class _MetricPill extends StatelessWidget {
  const _MetricPill({
    required this.label,
    required this.value,
    required this.badge,
  });

  final String label;
  final String value;
  final String badge;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
      decoration: BoxDecoration(
        color: AppColors.neutral300,
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: AppColors.grey300),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            label,
            style: AppTypography.bodyXsRegular.copyWith(
              color: AppColors.grey700,
            ),
          ),
          const SizedBox(height: 2),
          Row(
            children: [
              Flexible(
                child: Text(
                  value,
                  style: AppTypography.bodySSemiBold.copyWith(
                    color: AppColors.grey1050,
                  ),
                  overflow: TextOverflow.ellipsis,
                ),
              ),
              const SizedBox(width: 4),
              Text(
                badge,
                style: AppTypography.bodyXsBold.copyWith(
                  color: AppColors.primary700,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

/// Card showcasing an active or completed skincare product experiment
/// (`public.experiments`) with direct navigation to `ExperimentDetailPage`
/// and `ExperimentVerdictPage`.
class ProgressExperimentSpotlightCard extends StatelessWidget {
  /// Creates a [ProgressExperimentSpotlightCard].
  const ProgressExperimentSpotlightCard({
    required this.experiment,
    required this.onDetailTap,
    required this.onVerdictTap,
    required this.onNewExperimentTap,
    super.key,
  });

  /// Experiment entity.
  final ProgressExperiment experiment;

  /// Opens `/experiment/:id`.
  final VoidCallback onDetailTap;

  /// Opens `/experiment/:id/verdict`.
  final VoidCallback onVerdictTap;

  /// Opens `/experiment/new`.
  final VoidCallback onNewExperimentTap;

  @override
  Widget build(BuildContext context) {
    final isCompleted = experiment.status == 'completed';
    final primary = experiment.primaryVerdict;
    final adherencePct = (experiment.adherence * 100).round();

    return KoraCard(
      onTap: isCompleted ? onVerdictTap : onDetailTap,
      backgroundColor: isCompleted ? AppColors.primary50 : AppColors.grey50,
      borderColor: isCompleted ? AppColors.primary300 : AppColors.grey300,
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                decoration: BoxDecoration(
                  color: isCompleted
                      ? AppColors.primary700
                      : AppColors.neutral300,
                  borderRadius: BorderRadius.circular(6),
                  border: isCompleted
                      ? null
                      : Border.all(color: AppColors.grey300),
                ),
                child: Text(
                  isCompleted ? 'VERDICT UNLOCKED' : 'ACTIVE EXPERIMENT',
                  style: AppTypography.bodyXsBold.copyWith(
                    color: isCompleted ? AppColors.grey50 : AppColors.grey900,
                    letterSpacing: 0.4,
                  ),
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  '${experiment.plannedDays}d · $adherencePct% adherence',
                  style: AppTypography.bodyXsMedium.copyWith(
                    color: AppColors.grey700,
                  ),
                  overflow: TextOverflow.ellipsis,
                ),
              ),
              const SizedBox(width: 6),
              Semantics(
                button: true,
                label: 'Start a new product experiment',
                child: GestureDetector(
                  onTap: onNewExperimentTap,
                  child: Text(
                    '+ New test',
                    style: AppTypography.bodyXsBold.copyWith(
                      color: AppColors.primary700,
                    ),
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 10),
          Row(
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      experiment.title,
                      style: AppTypography.bodyLBold.copyWith(
                        color: AppColors.grey1050,
                      ),
                    ),
                    if (primary != null)
                      Text(
                        '${primary.concernLabel}: ${primary.baseline.toStringAsFixed(1)} → ${primary.post.toStringAsFixed(1)} '
                        '(${primary.confidence.toUpperCase()} confidence)',
                        style: AppTypography.bodyXsRegular.copyWith(
                          color: AppColors.grey800,
                        ),
                      ),
                  ],
                ),
              ),
              if (primary != null)
                KoraDeltaPill(
                  delta: primary.delta.round(),
                  isStable: primary.delta.abs() < primary.noise,
                ),
            ],
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              Expanded(
                child: Semantics(
                  button: true,
                  label: 'Inspect experiment checkpoints',
                  child: InkWell(
                    onTap: onDetailTap,
                    borderRadius: BorderRadius.circular(8),
                    child: Container(
                      padding: const EdgeInsets.symmetric(vertical: 8),
                      decoration: BoxDecoration(
                        color: AppColors.grey50,
                        borderRadius: BorderRadius.circular(8),
                        border: Border.all(color: AppColors.grey300),
                      ),
                      alignment: Alignment.center,
                      child: Text(
                        'Checkpoints (${experiment.baselineScanIds.length + experiment.followupScanIds.length} scans)',
                        style: AppTypography.bodyXsSemiBold.copyWith(
                          color: AppColors.grey900,
                        ),
                      ),
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: Semantics(
                  button: true,
                  label: 'Open scientific verdict report',
                  child: InkWell(
                    onTap: onVerdictTap,
                    borderRadius: BorderRadius.circular(8),
                    child: Container(
                      padding: const EdgeInsets.symmetric(vertical: 8),
                      decoration: BoxDecoration(
                        color: AppColors.primary700,
                        borderRadius: BorderRadius.circular(8),
                      ),
                      alignment: Alignment.center,
                      child: Text(
                        'Scientific Verdict',
                        style: AppTypography.bodyXsSemiBold.copyWith(
                          color: AppColors.grey50,
                        ),
                      ),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

/// Individual row item inside the Scan History list on the Overall tab.
class ProgressScanHistoryTile extends StatelessWidget {
  /// Creates a [ProgressScanHistoryTile].
  const ProgressScanHistoryTile({
    required this.scan,
    required this.deltaFromPrevious,
    required this.isStable,
    required this.onTap,
    required this.onCompareWithLatest,
    this.isLatest = false,
    super.key,
  });

  /// Scan record.
  final ProgressScan scan;

  /// Signed score delta relative to the immediately preceding scan.
  final int deltaFromPrevious;

  /// Whether [deltaFromPrevious] is within the noise threshold.
  final bool isStable;

  /// Whether this is the most recent scan.
  final bool isLatest;

  /// Opens `/scan/result/:id`.
  final VoidCallback onTap;

  /// Opens `/compare/:scanId/:latestId`.
  final VoidCallback onCompareWithLatest;

  static const List<String> _months = [
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

  String _formatDate(DateTime dt) {
    return '${_months[dt.month - 1]} ${dt.day}';
  }

  @override
  Widget build(BuildContext context) {
    final roleBadge = scan.experimentRole == 'baseline'
        ? 'BASELINE'
        : 'FOLLOW-UP';

    return KoraCard(
      onTap: onTap,
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
      child: Row(
        children: [
          Container(
            width: 46,
            height: 46,
            decoration: BoxDecoration(
              color: isLatest ? AppColors.primary50 : AppColors.neutral300,
              borderRadius: BorderRadius.circular(10),
              border: Border.all(
                color: isLatest ? AppColors.primary300 : AppColors.grey300,
              ),
            ),
            alignment: Alignment.center,
            child: Text(
              scan.overallScore.toStringAsFixed(0),
              style: AppTypography.bodyLBold.copyWith(
                color: isLatest ? AppColors.primary900 : AppColors.grey1050,
              ),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Flexible(
                      child: Text(
                        _formatDate(scan.createdAt),
                        style: AppTypography.bodyMSemiBold.copyWith(
                          color: AppColors.grey1050,
                        ),
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                    const SizedBox(width: 6),
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 6,
                        vertical: 1,
                      ),
                      decoration: BoxDecoration(
                        color: AppColors.grey100,
                        borderRadius: BorderRadius.circular(4),
                        border: Border.all(color: AppColors.grey300),
                      ),
                      child: Text(
                        '${scan.mode} · $roleBadge',
                        style: AppTypography.bodyXsBold.copyWith(
                          color: AppColors.grey700,
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 2),
                Text(
                  scan.note ?? 'Calibrated weekly scan',
                  style: AppTypography.bodyXsRegular.copyWith(
                    color: AppColors.grey700,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ],
            ),
          ),
          const SizedBox(width: 8),
          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              KoraDeltaPill(delta: deltaFromPrevious, isStable: isStable),
              if (!isLatest) ...[
                const SizedBox(height: 4),
                GestureDetector(
                  onTap: onCompareWithLatest,
                  child: Text(
                    'Compare →',
                    style: AppTypography.bodyXsSemiBold.copyWith(
                      color: AppColors.primary700,
                    ),
                  ),
                ),
              ],
            ],
          ),
        ],
      ),
    );
  }
}
