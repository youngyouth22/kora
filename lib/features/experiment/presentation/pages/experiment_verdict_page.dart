import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:kora/common/app_colors.dart';
import 'package:kora/common/app_typography.dart';
import 'package:kora/common/widgets/kora_card.dart';
import 'package:kora/common/widgets/kora_delta_pill.dart';
import 'package:kora/common/widgets/primary_button.dart';
import 'package:kora/common/widgets/secondary_button.dart';
import 'package:kora/core/router/app_routes.dart';
import 'package:kora/features/progress/data/datasources/progress_sql_seed_datasource.dart';
import 'package:kora/features/progress/domain/entities/progress_models.dart';

/// Screen delivering the final scientific verdict on a tested product
/// (C13 in blueprint).
class ExperimentVerdictPage extends StatelessWidget {
  /// Creates an [ExperimentVerdictPage].
  const ExperimentVerdictPage({
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

  String _formatVerdictCode(String code) {
    return code.replaceAll('_', ' ').toUpperCase();
  }

  @override
  Widget build(BuildContext context) {
    final exp = _resolveExperiment();
    final primaryVerdict = exp.primaryVerdict;
    final badgeText = primaryVerdict != null
        ? _formatVerdictCode(primaryVerdict.verdict)
        : 'VISIBLE EFFECT';
    final confidenceLabel = (primaryVerdict?.confidence ?? 'high')
        .toUpperCase();
    final weeks = exp.plannedDays ~/ 7;

    return Scaffold(
      backgroundColor: AppColors.scaffoldColor,
      appBar: AppBar(
        title: Text(
          'Verdict',
          style: AppTypography.h5Bold.copyWith(color: AppColors.grey1050),
        ),
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // Verdict Header Card
              KoraCard(
                padding: const EdgeInsets.all(20),
                backgroundColor: AppColors.primary50,
                borderColor: AppColors.primary300,
                child: Column(
                  children: [
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 14,
                        vertical: 6,
                      ),
                      decoration: BoxDecoration(
                        color: AppColors.primary700,
                        borderRadius: BorderRadius.circular(100),
                      ),
                      child: Text(
                        badgeText,
                        style: AppTypography.bodySBold.copyWith(
                          color: AppColors.grey50,
                          letterSpacing: 0.5,
                        ),
                      ),
                    ),
                    const SizedBox(height: 14),
                    Text(
                      exp.title,
                      style: AppTypography.h5Bold.copyWith(
                        color: AppColors.grey1050,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      '${exp.brand ?? 'Active Formula'} · '
                      '$weeks-week protocol',
                      style: AppTypography.bodySRegular.copyWith(
                        color: AppColors.grey700,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 16),

              // Metrics Breakdown
              Text(
                'Objective Outcomes (Baseline vs Follow-up)',
                style: AppTypography.h6Bold.copyWith(color: AppColors.grey1050),
              ),
              const SizedBox(height: 8),
              KoraCard(
                child: Column(
                  children: [
                    for (var i = 0; i < exp.verdictTargets.length; i++) ...[
                      if (i > 0)
                        const Divider(height: 20, color: AppColors.grey200),
                      _buildOutcomeRow(exp.verdictTargets[i]),
                    ],
                  ],
                ),
              ),
              const SizedBox(height: 16),

              // Scientific Confidence Rating
              KoraCard(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        const Icon(
                          Icons.verified_outlined,
                          color: AppColors.primary700,
                          size: 20,
                        ),
                        const SizedBox(width: 8),
                        Text(
                          'Confidence: $confidenceLabel',
                          style: AppTypography.bodyMSemiBold.copyWith(
                            color: AppColors.grey1050,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 6),
                    Text(
                      exp.notes.isNotEmpty
                          ? exp.notes.join(' ')
                          : 'Based on weekly HD scans, '
                                '${(exp.adherence * 100).round()}% daily '
                                'adherence, and consistent capture lighting.',
                      style: AppTypography.bodySRegular.copyWith(
                        color: AppColors.grey700,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 16),

              // Influencing factors
              KoraCard(
                backgroundColor: AppColors.grey100,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'What could have influenced this?',
                      style: AppTypography.bodyMSemiBold.copyWith(
                        color: AppColors.grey1050,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      '• Concomitant use of daily broad spectrum SPF 50 '
                      'protected new skin cells.\n'
                      '• Noise threshold of ±3.0 pts filtered out lighting '
                      'and hydration fluctuations.',
                      style: AppTypography.bodyXsRegular.copyWith(
                        color: AppColors.grey700,
                        height: 1.45,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 24),

              // Compare Baseline vs Final Scan
              if (exp.baselineScanIds.isNotEmpty &&
                  exp.followupScanIds.isNotEmpty) ...[
                SecondaryButton(
                  text: 'Compare Baseline & Final Scans',
                  height: 52,
                  textColor: AppColors.primary700,
                  onPressed: () => context.push(
                    AppRoutes.buildComparePath(
                      exp.baselineScanIds.first,
                      exp.followupScanIds.last,
                    ),
                  ),
                ),
                const SizedBox(height: 10),
              ],

              // Action CTA: Keep in routine
              PrimaryButton(
                text: 'Keep in routine',
                height: 52,
                backgroundColor: AppColors.primary700,
                onPressed: () {
                  context.go(AppRoutes.routine);
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text(
                        'Product marked as verified and kept in routine.',
                        style: AppTypography.bodySMedium.copyWith(
                          color: AppColors.grey50,
                        ),
                      ),
                      backgroundColor: AppColors.primary700,
                    ),
                  );
                },
              ),
              const SizedBox(height: 10),

              // Action CTA: Share or Stop
              SecondaryButton(
                text: 'Stop using & archive product',
                height: 52,
                textColor: AppColors.error400,
                onPressed: () {
                  context.go(AppRoutes.routine);
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text(
                        'Product archived from active routine.',
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
          ),
        ),
      ),
    );
  }

  Widget _buildOutcomeRow(ProgressVerdictTarget target) {
    final before = target.baseline.round();
    final after = target.post.round();
    final delta = target.delta.round();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Text(
              target.concernLabel,
              style: AppTypography.bodyMSemiBold.copyWith(
                color: AppColors.grey1050,
              ),
            ),
            const Spacer(),
            Text(
              '$before → $after',
              style: AppTypography.bodySMedium.copyWith(
                color: AppColors.grey800,
              ),
            ),
            const SizedBox(width: 8),
            KoraDeltaPill(delta: delta),
          ],
        ),
        const SizedBox(height: 4),
        Text(
          'Signal delta ${delta >= 0 ? '+$delta' : '$delta'} pts '
          '(exceeds ±${target.noise.toStringAsFixed(0)} pt noise floor)',
          style: AppTypography.bodyXsRegular.copyWith(color: AppColors.grey700),
        ),
      ],
    );
  }
}
