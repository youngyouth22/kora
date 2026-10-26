// ignore_for_file: document_ignores, lines_longer_than_80_chars

import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:kora/common/app_colors.dart';
import 'package:kora/common/app_typography.dart';
import 'package:kora/common/widgets/kora_card.dart';
import 'package:kora/common/widgets/kora_delta_pill.dart';
import 'package:kora/common/widgets/primary_button.dart';
import 'package:kora/common/widgets/secondary_button.dart';
import 'package:kora/core/router/app_routes.dart';

/// Screen delivering the final scientific verdict on a tested product (C13 in blueprint).
class ExperimentVerdictPage extends StatelessWidget {
  /// Creates an [ExperimentVerdictPage].
  const ExperimentVerdictPage({
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
                        'VISIBLE EFFECT',
                        style: AppTypography.bodySBold.copyWith(
                          color: AppColors.grey50,
                          letterSpacing: 0.5,
                        ),
                      ),
                    ),
                    const SizedBox(height: 14),
                    Text(
                      'Retinol 0.3% Emulsion',
                      style: AppTypography.h5Bold.copyWith(
                        color: AppColors.grey1050,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      '6-week trial completed · Sep 21 to Nov 2',
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
                'Objective Outcomes',
                style: AppTypography.h6Bold.copyWith(color: AppColors.grey1050),
              ),
              const SizedBox(height: 8),
              KoraCard(
                child: Column(
                  children: [
                    _buildOutcomeRow(
                      concern: 'Dark spots',
                      before: 58,
                      after: 69,
                      delta: 11,
                      summary: 'Clear clinical lightening of post-acne marks',
                    ),
                    const Divider(height: 20, color: AppColors.grey200),
                    _buildOutcomeRow(
                      concern: 'Skin Texture',
                      before: 62,
                      after: 68,
                      delta: 6,
                      summary: 'Measurable reduction in surface micro-bumps',
                    ),
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
                          'Confidence: Medium-High',
                          style: AppTypography.bodyMSemiBold.copyWith(
                            color: AppColors.grey1050,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 6),
                    Text(
                      'Based on 5 weekly scans, 82% daily adherence, and consistent indoor daylight capture conditions.',
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
                      '• Concomitant use of daily broad spectrum SPF 50 protected new skin cells.\n• Autumn seasonal decrease in UV index supported pigmentation fading.',
                      style: AppTypography.bodyXsRegular.copyWith(
                        color: AppColors.grey700,
                        height: 1.45,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 24),

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

  Widget _buildOutcomeRow({
    required String concern,
    required int before,
    required int after,
    required int delta,
    required String summary,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Text(
              concern,
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
          summary,
          style: AppTypography.bodyXsRegular.copyWith(color: AppColors.grey700),
        ),
      ],
    );
  }
}
