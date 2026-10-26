// ignore_for_file: document_ignores, lines_longer_than_80_chars

import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:kora/common/app_colors.dart';
import 'package:kora/common/app_typography.dart';
import 'package:kora/common/widgets/kora_card.dart';
import 'package:kora/common/widgets/primary_button.dart';
import 'package:kora/core/router/app_routes.dart';

/// Screen displaying OCR breakdown and ingredient analysis (C10 in blueprint).
class IngredientAnalysisPage extends StatelessWidget {
  /// Creates an [IngredientAnalysisPage].
  const IngredientAnalysisPage({
    this.productId = 'demo-1',
    super.key,
  });

  /// The product or scan identifier.
  final String productId;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.scaffoldColor,
      appBar: AppBar(
        title: Text(
          'Ingredient Breakdown',
          style: AppTypography.h5Bold.copyWith(color: AppColors.grey1050),
        ),
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // Product Name card
              KoraCard(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Detected Actives',
                      style: AppTypography.bodyMSemiBold.copyWith(
                        color: AppColors.grey1050,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Wrap(
                      spacing: 8,
                      runSpacing: 8,
                      children: [
                        _buildActiveChip('Retinol 0.3%', isPrimary: true),
                        _buildActiveChip('Glycerin'),
                        _buildActiveChip('Niacinamide 2%'),
                        _buildActiveChip('Sodium Hyaluronate'),
                      ],
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 16),

              // Worth Knowing section
              Text(
                'Worth knowing',
                style: AppTypography.h6Bold.copyWith(color: AppColors.grey1050),
              ),
              const SizedBox(height: 8),
              KoraCard(
                child: Column(
                  children: [
                    _buildInsightRow(
                      icon: Icons.info_outline_rounded,
                      title: 'Synthetic fragrance absent',
                      subtitle: 'Formulation is fragrance-free; gentle on reactive skin.',
                    ),
                    const Divider(height: 16, color: AppColors.grey200),
                    _buildInsightRow(
                      icon: Icons.warning_amber_rounded,
                      title: 'Active concentration',
                      subtitle: '0.3% Retinol is intermediate. Introduce 2 nights a week.',
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 16),

              // Routine Compatibility
              Text(
                'Fits your routine?',
                style: AppTypography.h6Bold.copyWith(color: AppColors.grey1050),
              ),
              const SizedBox(height: 8),
              KoraCard(
                backgroundColor: AppColors.primary50,
                borderColor: AppColors.primary200,
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Icon(
                      Icons.check_circle_rounded,
                      color: AppColors.primary700,
                      size: 20,
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Compatible with current AM regimen',
                            style: AppTypography.bodyMSemiBold.copyWith(
                              color: AppColors.primary900,
                            ),
                          ),
                          const SizedBox(height: 2),
                          Text(
                            'Do not apply on the same night as exfoliating acids. Always apply broad spectrum SPF 50 the next morning.',
                            style: AppTypography.bodySRegular.copyWith(
                              color: AppColors.grey800,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 16),

              // Neutral Medical Disclaimer
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 14,
                  vertical: 10,
                ),
                decoration: BoxDecoration(
                  color: AppColors.grey100,
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Text(
                  'Informational, not medical advice. Always consult your prescribing physician if you are using dermatological medication.',
                  style: AppTypography.bodyXsRegular.copyWith(
                    color: AppColors.grey700,
                  ),
                  textAlign: TextAlign.center,
                ),
              ),
              const SizedBox(height: 24),

              // Action buttons
              PrimaryButton(
                text: 'Add to routine',
                height: 52,
                backgroundColor: AppColors.primary700,
                onPressed: () => context.go(AppRoutes.routine),
              ),
              const SizedBox(height: 10),
              OutlinedButton(
                style: OutlinedButton.styleFrom(
                  minimumSize: const Size.fromHeight(52),
                  side: const BorderSide(color: AppColors.grey400),
                  shape: const StadiumBorder(),
                ),
                onPressed: () => context.push(AppRoutes.experimentNew),
                child: Text(
                  'Start an experiment with this',
                  style: AppTypography.bodySMedium.copyWith(
                    color: AppColors.grey900,
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

  Widget _buildActiveChip(String label, {bool isPrimary = false}) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
      decoration: BoxDecoration(
        color: isPrimary ? AppColors.primary100 : AppColors.grey100,
        borderRadius: BorderRadius.circular(100),
        border: Border.all(
          color: isPrimary ? AppColors.primary300 : AppColors.grey300,
        ),
      ),
      child: Text(
        label,
        style: AppTypography.bodyXsMedium.copyWith(
          color: isPrimary ? AppColors.primary900 : AppColors.grey800,
        ),
      ),
    );
  }

  Widget _buildInsightRow({
    required IconData icon,
    required String title,
    required String subtitle,
  }) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Icon(icon, size: 20, color: AppColors.primary700),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                title,
                style: AppTypography.bodyMSemiBold.copyWith(
                  color: AppColors.grey1050,
                ),
              ),
              const SizedBox(height: 2),
              Text(
                subtitle,
                style: AppTypography.bodyXsRegular.copyWith(
                  color: AppColors.grey700,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}
