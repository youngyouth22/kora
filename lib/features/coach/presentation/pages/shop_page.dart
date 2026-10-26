// ignore_for_file: document_ignores, lines_longer_than_80_chars

import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:kora/common/app_colors.dart';
import 'package:kora/common/app_typography.dart';
import 'package:kora/common/widgets/kora_card.dart';
import 'package:kora/core/router/app_routes.dart';

/// Curated ethical product recommendations catalog (C17 in blueprint).
class ShopPage extends StatefulWidget {
  /// Creates a [ShopPage].
  const ShopPage({super.key});

  @override
  State<ShopPage> createState() => _ShopPageState();
}

class _ShopPageState extends State<ShopPage> {
  String _selectedCategory = 'For you';

  final List<String> _categories = [
    'For you',
    'Dark spots',
    'SPF',
    'Cleanser',
    'Barrier',
  ];

  final List<Map<String, dynamic>> _products = [
    {
      'id': 'p1',
      'name': 'Azelaic Acid 10% Suspension',
      'brand': 'The Ordinary',
      'tag': 'Dark spots & Redness',
      'why': 'Targets melanin clusters while actively soothing erythema. Well tolerated on reactive skin.',
      'actives': ['Azelaic Acid 10%'],
    },
    {
      'id': 'p2',
      'name': 'Anthelios UVmune 400 SPF 50+',
      'brand': 'La Roche-Posay',
      'tag': 'Broad Spectrum Daily SPF',
      'why': 'Prevents UV pigmentation with Mexoryl 400. Light fluid texture without residue.',
      'actives': ['Mexoryl 400', 'Netlock Technology'],
    },
    {
      'id': 'p3',
      'name': 'Liquid Hydration 5% Panthenol',
      'brand': 'Geek & Gorgeous',
      'tag': 'Barrier Hydration',
      'why': 'Calms irritation and boosts barrier recovery during active retinol testing.',
      'actives': ['Panthenol 5%', 'Allantoin'],
    },
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.scaffoldColor,
      appBar: AppBar(
        title: Text(
          'Recommended Products',
          style: AppTypography.h5Bold.copyWith(color: AppColors.grey1050),
        ),
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // Ethical Affiliate Disclosure Banner
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 14,
                  vertical: 10,
                ),
                decoration: BoxDecoration(
                  color: AppColors.primary50,
                  borderRadius: BorderRadius.circular(10),
                  border: Border.all(color: AppColors.primary200),
                ),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Icon(
                      Icons.verified_outlined,
                      size: 16,
                      color: AppColors.primary800,
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        'Affiliate links: we may earn a modest commission. It never changes our algorithmic ranking or integrity.',
                        style: AppTypography.bodyXsRegular.copyWith(
                          color: AppColors.primary900,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 14),

              // Filter chips
              SizedBox(
                height: 38,
                child: ListView.separated(
                  scrollDirection: Axis.horizontal,
                  itemCount: _categories.length,
                  separatorBuilder: (_, _) => const SizedBox(width: 8),
                  itemBuilder: (context, index) {
                    final cat = _categories[index];
                    final isSelected = _selectedCategory == cat;
                    return ChoiceChip(
                      label: Text(cat),
                      selected: isSelected,
                      selectedColor: AppColors.primary700,
                      backgroundColor: AppColors.grey100,
                      labelStyle: AppTypography.bodyXsMedium.copyWith(
                        color: isSelected
                            ? AppColors.grey50
                            : AppColors.grey800,
                      ),
                      side: BorderSide(
                        color: isSelected
                            ? AppColors.primary700
                            : AppColors.grey300,
                      ),
                      onSelected: (_) =>
                          setState(() => _selectedCategory = cat),
                    );
                  },
                ),
              ),
              const SizedBox(height: 16),

              // Product Cards
              ..._products.map((prod) {
                final id = prod['id'] as String;
                final name = prod['name'] as String;
                final brand = prod['brand'] as String;
                final tag = prod['tag'] as String;
                final why = prod['why'] as String;
                final actives = (prod['actives'] as List<dynamic>)
                    .cast<String>();

                return Padding(
                  padding: const EdgeInsets.only(bottom: 12),
                  child: KoraCard(
                    onTap: () =>
                        context.push(AppRoutes.buildShopProductPath(id)),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 8,
                                vertical: 3,
                              ),
                              decoration: BoxDecoration(
                                color: AppColors.primary100,
                                borderRadius: BorderRadius.circular(6),
                              ),
                              child: Text(
                                tag,
                                style: AppTypography.bodyXsBold.copyWith(
                                  color: AppColors.primary900,
                                ),
                              ),
                            ),
                            const Spacer(),
                            const Icon(
                              Icons.chevron_right_rounded,
                              color: AppColors.grey600,
                            ),
                          ],
                        ),
                        const SizedBox(height: 8),
                        Text(
                          name,
                          style: AppTypography.bodyLBold.copyWith(
                            color: AppColors.grey1050,
                          ),
                        ),
                        Text(
                          brand,
                          style: AppTypography.bodyXsRegular.copyWith(
                            color: AppColors.grey700,
                          ),
                        ),
                        const SizedBox(height: 10),
                        Container(
                          padding: const EdgeInsets.all(10),
                          decoration: BoxDecoration(
                            color: AppColors.grey100,
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: Row(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                'Why: ',
                                style: AppTypography.bodyXsBold.copyWith(
                                  color: AppColors.primary800,
                                ),
                              ),
                              Expanded(
                                child: Text(
                                  why,
                                  style: AppTypography.bodyXsRegular.copyWith(
                                    color: AppColors.grey800,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(height: 8),
                        Wrap(
                          spacing: 6,
                          children: actives.map((act) {
                            return Text(
                              '• $act',
                              style: AppTypography.bodyXsMedium.copyWith(
                                color: AppColors.grey700,
                              ),
                            );
                          }).toList(),
                        ),
                      ],
                    ),
                  ),
                );
              }),
            ],
          ),
        ),
      ),
    );
  }
}
