// ignore_for_file: document_ignores, lines_longer_than_80_chars

import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:kora/common/app_colors.dart';
import 'package:kora/common/app_typography.dart';
import 'package:kora/common/widgets/kora_card.dart';
import 'package:kora/common/widgets/primary_button.dart';
import 'package:kora/common/widgets/secondary_button.dart';
import 'package:kora/core/router/app_routes.dart';

/// Product detail and affiliate redirection screen (C18 in blueprint).
class ShopProductPage extends StatelessWidget {
  /// Creates a [ShopProductPage].
  const ShopProductPage({
    this.productId = 'p1',
    super.key,
  });

  /// The product identifier.
  final String productId;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.scaffoldColor,
      appBar: AppBar(
        title: Text(
          'Product Details',
          style: AppTypography.h5Bold.copyWith(color: AppColors.grey1050),
        ),
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // Product Image Mockup
              KoraCard(
                padding: EdgeInsets.zero,
                child: Container(
                  height: 180,
                  decoration: const BoxDecoration(
                    color: AppColors.neutral200,
                    borderRadius: BorderRadius.all(Radius.circular(16)),
                  ),
                  child: Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const Icon(
                          Icons.sanitizer_outlined,
                          size: 60,
                          color: AppColors.primary700,
                        ),
                        const SizedBox(height: 8),
                        Text(
                          'Verified Cosmetic Formulation',
                          style: AppTypography.bodyXsMedium.copyWith(
                            color: AppColors.grey700,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 16),

              Text(
                'Azelaic Acid 10% Suspension',
                style: AppTypography.h5Bold.copyWith(color: AppColors.grey1050),
              ),
              const SizedBox(height: 2),
              Text(
                'The Ordinary · 30ml Emulsion',
                style: AppTypography.bodySRegular.copyWith(
                  color: AppColors.grey700,
                ),
              ),
              const SizedBox(height: 14),

              // Key Actives chips
              Wrap(
                spacing: 6,
                runSpacing: 6,
                children: ['Azelaic Acid 10%', 'Silicones', 'Fragrance-free']
                    .map((act) {
                      return Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 10,
                          vertical: 4,
                        ),
                        decoration: BoxDecoration(
                          color: AppColors.grey100,
                          borderRadius: BorderRadius.circular(100),
                          border: Border.all(color: AppColors.grey300),
                        ),
                        child: Text(
                          act,
                          style: AppTypography.bodyXsMedium.copyWith(
                            color: AppColors.grey900,
                          ),
                        ),
                      );
                    })
                    .toList(),
              ),
              const SizedBox(height: 16),

              // "Good for"
              KoraCard(
                backgroundColor: AppColors.primary50,
                borderColor: AppColors.primary200,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        const Icon(
                          Icons.check_circle_rounded,
                          color: AppColors.primary700,
                          size: 18,
                        ),
                        const SizedBox(width: 8),
                        Text(
                          'Good for',
                          style: AppTypography.bodyMSemiBold.copyWith(
                            color: AppColors.primary900,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 6),
                    Text(
                      'Post-inflammatory erythema (PIE), localized redness, mild texture irregularities, and non-cystic blemishes.',
                      style: AppTypography.bodySRegular.copyWith(
                        color: AppColors.grey900,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 10),

              // "Maybe skip if"
              KoraCard(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        const Icon(
                          Icons.info_outline_rounded,
                          color: AppColors.secondary700,
                          size: 18,
                        ),
                        const SizedBox(width: 8),
                        Text(
                          'Maybe skip if',
                          style: AppTypography.bodyMSemiBold.copyWith(
                            color: AppColors.grey1050,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 6),
                    Text(
                      'You dislike silicone heavy textures under makeup, or your skin is actively reacting to high concentration topical acids.',
                      style: AppTypography.bodySRegular.copyWith(
                        color: AppColors.grey800,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 24),

              // External Retailer Link
              SecondaryButton(
                text: 'View at retailer (Affiliate)',
                height: 52,
                textColor: AppColors.primary700,
                onPressed: () {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text(
                        'Opening authorized retailer in browser...',
                        style: AppTypography.bodySMedium.copyWith(
                          color: AppColors.grey50,
                        ),
                      ),
                      backgroundColor: AppColors.grey1000,
                    ),
                  );
                },
              ),
              const SizedBox(height: 10),

              // Add to routine CTA
              PrimaryButton(
                text: 'Add to my routine',
                height: 52,
                backgroundColor: AppColors.primary700,
                onPressed: () {
                  context.go(AppRoutes.routine);
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text(
                        'Azelaic Acid added to routine.',
                        style: AppTypography.bodySMedium.copyWith(
                          color: AppColors.grey50,
                        ),
                      ),
                      backgroundColor: AppColors.primary700,
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
}
