import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:kora/common/app_colors.dart';
import 'package:kora/common/app_typography.dart';
import 'package:kora/common/widgets/kora_card.dart';
import 'package:kora/common/widgets/kora_delta_pill.dart';
import 'package:kora/common/widgets/secondary_button.dart';
import 'package:kora/core/router/app_routes.dart';
import 'package:kora/features/progress/data/datasources/progress_sql_seed_datasource.dart';
import 'package:kora/features/progress/domain/entities/progress_models.dart';
import 'package:kora/features/progress/domain/entities/progress_scan.dart';

/// Screen tracking an active or completed product experiment
/// (C12 in blueprint).
class ExperimentDetailPage extends StatelessWidget {
  /// Creates an [ExperimentDetailPage].
  const ExperimentDetailPage({
    this.experimentId = 'exp-retinol-demo',
    super.key,
  });

  /// The experiment identifier.
  final String experimentId;

  ProgressExperiment _resolveExperiment() {
    final experiments = ProgressSqlSeedDataSource.buildSeedExperiments();
    return experiments.firstWhere(
      (e) => e.id == experimentId,
      orElse: () => experiments.first,
    );
  }

  @override
  Widget build(BuildContext context) {
    final exp = _resolveExperiment();
    final scans = ProgressSqlSeedDataSource.buildSeedScans();
    final concernTypes = ProgressSqlSeedDataSource.buildConcernTypes();
    final concernLabels = {for (final c in concernTypes) c.key: c.label};
    final scanMap = {for (final s in scans) s.id: s};
    final targetLabels = exp.targets
        .map((code) => concernLabels[code] ?? code)
        .join(' & ');
    final elapsed = exp.elapsedDays(
      ProgressSqlSeedDataSource.defaultReferenceDate,
    );
    final primaryVerdict = exp.primaryVerdict;

    return Scaffold(
      backgroundColor: AppColors.scaffoldColor,
      appBar: AppBar(
        title: Text(
          exp.title,
          style: AppTypography.h6Bold.copyWith(color: AppColors.grey1050),
        ),
        actions: [
          IconButton(
            tooltip: 'View Verdict',
            icon: const Icon(
              Icons.verified_rounded,
              color: AppColors.primary700,
            ),
            onPressed: () => context.push(
              AppRoutes.buildExperimentVerdictPath(exp.id),
            ),
          ),
        ],
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // Day counter & progress ring
              KoraCard(
                padding: const EdgeInsets.all(20),
                child: Column(
                  children: [
                    Container(
                      width: 92,
                      height: 92,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: AppColors.primary50,
                        border: Border.all(
                          color: AppColors.primary700,
                          width: 3,
                        ),
                      ),
                      alignment: Alignment.center,
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Text(
                            '$elapsed/${exp.plannedDays}',
                            style: AppTypography.h5Bold.copyWith(
                              color: AppColors.primary900,
                              height: 1.1,
                            ),
                          ),
                          Text(
                            'days',
                            style: AppTypography.bodyXsRegular.copyWith(
                              color: AppColors.primary800,
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 14),
                    Text(
                      'Targeting $targetLabels',
                      style: AppTypography.bodyMSemiBold.copyWith(
                        color: AppColors.grey1050,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      '${exp.brand ?? 'Active Formula'} · ${exp.title}',
                      style: AppTypography.bodyXsRegular.copyWith(
                        color: AppColors.grey700,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 16),

              // Weekly Scan Checkpoints
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'Scan Checkpoints',
                    style: AppTypography.h6Bold.copyWith(
                      color: AppColors.grey1050,
                    ),
                  ),
                  if (exp.baselineScanIds.isNotEmpty &&
                      exp.followupScanIds.isNotEmpty)
                    TextButton(
                      onPressed: () => context.push(
                        AppRoutes.buildComparePath(
                          exp.baselineScanIds.first,
                          exp.followupScanIds.last,
                        ),
                      ),
                      child: Text(
                        'Compare Base vs Final',
                        style: AppTypography.bodyXsBold.copyWith(
                          color: AppColors.primary700,
                        ),
                      ),
                    ),
                ],
              ),
              const SizedBox(height: 8),
              KoraCard(
                child: Column(
                  children: [
                    for (var i = 0; i < exp.baselineScanIds.length; i++) ...[
                      if (i > 0)
                        const Divider(height: 16, color: AppColors.grey200),
                      _buildScanCheckpoint(
                        context,
                        role: 'Baseline ${i + 1}',
                        scan: scanMap[exp.baselineScanIds[i]],
                        isDone: true,
                      ),
                    ],
                    for (var i = 0; i < exp.followupScanIds.length; i++) ...[
                      const Divider(height: 16, color: AppColors.grey200),
                      _buildScanCheckpoint(
                        context,
                        role: 'Follow-up ${i + 1}',
                        scan: scanMap[exp.followupScanIds[i]],
                        isDone: true,
                      ),
                    ],
                  ],
                ),
              ),
              const SizedBox(height: 16),

              // Adherence card
              KoraCard(
                backgroundColor: AppColors.primary50,
                borderColor: AppColors.primary200,
                child: Row(
                  children: [
                    const Icon(
                      Icons.insights_rounded,
                      color: AppColors.primary700,
                      size: 22,
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Adherence: ${(exp.adherence * 100).round()}%',
                            style: AppTypography.bodyMSemiBold.copyWith(
                              color: AppColors.primary900,
                            ),
                          ),
                          Text(
                            'High consistency qualifies for a '
                            '${primaryVerdict?.confidence ?? 'high'}-'
                            'confidence verdict.',
                            style: AppTypography.bodyXsRegular.copyWith(
                              color: AppColors.grey800,
                            ),
                          ),
                        ],
                      ),
                    ),
                    KoraDeltaPill(
                      delta: primaryVerdict != null
                          ? primaryVerdict.delta.round()
                          : 3,
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 16),

              // Irritation Sentinel
              KoraCard(
                child: Row(
                  children: [
                    const Icon(
                      Icons.shield_outlined,
                      color: AppColors.primary700,
                      size: 20,
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Safety & Irritation Sentinel',
                            style: AppTypography.bodyMSemiBold.copyWith(
                              color: AppColors.grey1050,
                            ),
                          ),
                          Text(
                            'Redness has remained stable. '
                            'No irritation alert triggered.',
                            style: AppTypography.bodyXsRegular.copyWith(
                              color: AppColors.grey700,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 24),

              // View Verdict preview
              SecondaryButton(
                text: 'View full verdict preview',
                height: 52,
                textColor: AppColors.primary700,
                onPressed: () => context.push(
                  AppRoutes.buildExperimentVerdictPath(exp.id),
                ),
              ),
              const SizedBox(height: 10),

              // Stop or Pause
              TextButton(
                onPressed: () {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text(
                        'Experiment paused. Resume anytime.',
                        style: AppTypography.bodySMedium.copyWith(
                          color: AppColors.grey50,
                        ),
                      ),
                      backgroundColor: AppColors.grey1000,
                    ),
                  );
                },
                child: Text(
                  'Pause or stop experiment',
                  style: AppTypography.bodySMedium.copyWith(
                    color: AppColors.error400,
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

  Widget _buildScanCheckpoint(
    BuildContext context, {
    required String role,
    required ProgressScan? scan,
    required bool isDone,
  }) {
    final dateStr = scan != null
        ? '${scan.completedAt.day}/${scan.completedAt.month}'
        : '';
    final title = scan != null ? '$role ($dateStr)' : role;
    final scoreStr = scan != null ? scan.overallScore.toStringAsFixed(1) : '--';
    final qualityStr = scan != null && scan.qualityOk ? 'HD Pass' : 'Review';
    final subtitle = scan != null
        ? 'Raw Score: $scoreStr · Quality: $qualityStr'
        : 'Scheduled checkpoint';

    return InkWell(
      onTap: scan == null
          ? null
          : () => context.push(AppRoutes.buildScanResultPath(scan.id)),
      borderRadius: BorderRadius.circular(8),
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 4),
        child: Row(
          children: [
            Container(
              width: 22,
              height: 22,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: isDone ? AppColors.primary700 : AppColors.grey200,
              ),
              alignment: Alignment.center,
              child: isDone
                  ? const Icon(Icons.check, size: 14, color: AppColors.grey50)
                  : null,
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: AppTypography.bodyMSemiBold.copyWith(
                      color: isDone ? AppColors.grey1050 : AppColors.grey700,
                    ),
                  ),
                  Text(
                    subtitle,
                    style: AppTypography.bodyXsRegular.copyWith(
                      color: AppColors.grey600,
                    ),
                  ),
                ],
              ),
            ),
            if (scan != null)
              const Icon(
                Icons.chevron_right_rounded,
                size: 18,
                color: AppColors.grey500,
              ),
          ],
        ),
      ),
    );
  }
}
