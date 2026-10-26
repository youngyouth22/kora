// ignore_for_file: document_ignores, lines_longer_than_80_chars

import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:kora/common/app_colors.dart';
import 'package:kora/common/app_typography.dart';
import 'package:kora/common/widgets/kora_card.dart';
import 'package:kora/common/widgets/kora_delta_pill.dart';
import 'package:kora/common/widgets/kora_score_ring.dart';
import 'package:kora/common/widgets/primary_button.dart';
import 'package:kora/core/router/app_routes.dart';

/// Detailed concern progression screen (C04 in blueprint).
class ConcernDetailPage extends StatelessWidget {
  /// Creates a [ConcernDetailPage].
  const ConcernDetailPage({
    this.concernType = 'dark_spots',
    super.key,
  });

  /// The concern identifier passed via route parameter.
  final String concernType;

  String _getConcernTitle() {
    switch (concernType.toLowerCase()) {
      case 'redness':
        return 'Redness';
      case 'pores':
        return 'Pores';
      case 'texture':
        return 'Texture';
      case 'hydration':
        return 'Hydration';
      case 'wrinkles':
        return 'Wrinkles & Firmness';
      case 'dark_spots':
      default:
        return 'Dark spots';
    }
  }

  int _getScore() {
    switch (concernType.toLowerCase()) {
      case 'redness':
        return 71;
      case 'pores':
        return 68;
      case 'texture':
        return 58;
      case 'hydration':
        return 82;
      case 'wrinkles':
        return 76;
      case 'dark_spots':
      default:
        return 64;
    }
  }

  @override
  Widget build(BuildContext context) {
    final title = _getConcernTitle();
    final score = _getScore();

    return Scaffold(
      backgroundColor: AppColors.scaffoldColor,
      appBar: AppBar(
        title: Text(
          title,
          style: AppTypography.h5Bold.copyWith(color: AppColors.grey1050),
        ),
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // Score & Trend card
              KoraCard(
                padding: const EdgeInsets.all(20),
                child: Column(
                  children: [
                    KoraScoreRing(
                      score: score,
                      size: ScoreRingSize.l,
                      subtitle: 'Raw precision score (0-100)',
                    ),
                    const SizedBox(height: 12),
                    const KoraDeltaPill(delta: 6),
                    const SizedBox(height: 6),
                    Text(
                      'Last 8 weeks: +6 points overall',
                      style: AppTypography.bodySMedium.copyWith(
                        color: AppColors.grey800,
                      ),
                    ),
                    const SizedBox(height: 16),
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

              // What this means
              Text(
                'What this means',
                style: AppTypography.h6Bold.copyWith(color: AppColors.grey1050),
              ),
              const SizedBox(height: 8),
              KoraCard(
                child: Text(
                  'Pigment spots and uneven tone are caused by melanin clusters responding to sun exposure or past breakouts. Improvement occurs as superficial skin cells gradually shed over 6 to 12 weeks.',
                  style: AppTypography.bodySRegular.copyWith(
                    color: AppColors.grey900,
                    height: 1.5,
                  ),
                ),
              ),
              const SizedBox(height: 16),

              // What can help
              Text(
                'What can help',
                style: AppTypography.h6Bold.copyWith(color: AppColors.grey1050),
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
                    _buildIngredientRow(
                      'Azelaic Acid 10%',
                      'Calms redness while inhibiting tyrosinase.',
                    ),
                    const SizedBox(height: 8),
                    _buildIngredientRow(
                      'Vitamin C (L-Ascorbic)',
                      'Antioxidant shield promoting even luminosity.',
                    ),
                    const SizedBox(height: 8),
                    _buildIngredientRow(
                      'Daily Broad Spectrum SPF 50',
                      'Prevents UV-induced re-pigmentation.',
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 16),

              // Related Actions
              Text(
                'Related resources',
                style: AppTypography.h6Bold.copyWith(color: AppColors.grey1050),
              ),
              const SizedBox(height: 8),
              KoraCard(
                onTap: () => context.push(AppRoutes.buildLearnVideoPath('2')),
                padding: const EdgeInsets.all(12),
                child: Row(
                  children: [
                    const Icon(
                      Icons.video_library_outlined,
                      color: AppColors.primary700,
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Text(
                        'Video: The truth about dark spot treatments (11 min)',
                        style: AppTypography.bodySMedium.copyWith(
                          color: AppColors.grey1050,
                        ),
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

              // Bottom CTA
              PrimaryButton(
                text: 'Test a product for this',
                height: 52,
                backgroundColor: AppColors.primary700,
                onPressed: () => context.push(AppRoutes.experimentNew),
              ),
              const SizedBox(height: 12),
            ],
          ),
        ),
      ),
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
                  style: AppTypography.bodySMedium.copyWith(
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
