// ignore_for_file: document_ignores, lines_longer_than_80_chars

import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:kora/common/app_colors.dart';
import 'package:kora/common/app_typography.dart';
import 'package:kora/common/widgets/kora_card.dart';
import 'package:kora/common/widgets/kora_delta_pill.dart';
import 'package:kora/common/widgets/secondary_button.dart';
import 'package:kora/core/router/app_routes.dart';

/// Screen tracking an active product experiment in progress (C12 in blueprint).
class ExperimentDetailPage extends StatelessWidget {
  /// Creates an [ExperimentDetailPage].
  const ExperimentDetailPage({
    this.experimentId = '1',
    super.key,
  });

  /// The experiment identifier.
  final String experimentId;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.scaffoldColor,
      appBar: AppBar(
        title: Text(
          'Retinol Test 0.3%',
          style: AppTypography.h5Bold.copyWith(color: AppColors.grey1050),
        ),
        actions: [
          IconButton(
            tooltip: 'View Verdict',
            icon: const Icon(
              Icons.verified_rounded,
              color: AppColors.primary700,
            ),
            onPressed: () => context.push(
              AppRoutes.buildExperimentVerdictPath(experimentId),
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
                      width: 90,
                      height: 90,
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
                            '12/42',
                            style: AppTypography.h4Bold.copyWith(
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
                      'Targeting Redness & Texture',
                      style: AppTypography.bodyMSemiBold.copyWith(
                        color: AppColors.grey1050,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      'Week 2 of 6 · Next weekly checkpoint on Sunday',
                      style: AppTypography.bodyXsRegular.copyWith(
                        color: AppColors.grey700,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 16),

              // Weekly Scan Checkpoints
              Text(
                'Weekly Checkpoints',
                style: AppTypography.h6Bold.copyWith(color: AppColors.grey1050),
              ),
              const SizedBox(height: 8),
              KoraCard(
                child: Column(
                  children: [
                    _buildCheckpointRow(
                      'Baseline 1 (Sep 21)',
                      'Score: 69',
                      isDone: true,
                    ),
                    const Divider(height: 16, color: AppColors.grey200),
                    _buildCheckpointRow(
                      'Baseline 2 (Sep 28)',
                      'Score: 71',
                      isDone: true,
                    ),
                    const Divider(height: 16, color: AppColors.grey200),
                    _buildCheckpointRow(
                      'Check-in 1 (Oct 5)',
                      'Score: 72 · Redness stable',
                      isDone: true,
                    ),
                    const Divider(height: 16, color: AppColors.grey200),
                    _buildCheckpointRow(
                      'Check-in 2 (Oct 12)',
                      'Score: 75 · Texture improving',
                      isDone: true,
                    ),
                    const Divider(height: 16, color: AppColors.grey200),
                    _buildCheckpointRow(
                      'Check-in 3 (Oct 19)',
                      'Sunday at 6 PM',
                      isDone: false,
                    ),
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
                            'Adherence: 82%',
                            style: AppTypography.bodyMSemiBold.copyWith(
                              color: AppColors.primary900,
                            ),
                          ),
                          Text(
                            'High consistency qualifies for a high-confidence final verdict.',
                            style: AppTypography.bodyXsRegular.copyWith(
                              color: AppColors.grey800,
                            ),
                          ),
                        ],
                      ),
                    ),
                    const KoraDeltaPill(delta: 3),
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
                            'Redness has remained stable (+1 pt). No irritation alert triggered.',
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
                  AppRoutes.buildExperimentVerdictPath(experimentId),
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

  Widget _buildCheckpointRow(
    String title,
    String subtitle, {
    required bool isDone,
  }) {
    return Row(
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
      ],
    );
  }
}
