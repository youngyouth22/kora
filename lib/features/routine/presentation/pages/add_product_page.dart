import 'dart:async';

import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:kora/common/app_colors.dart';
import 'package:kora/common/app_typography.dart';
import 'package:kora/common/widgets/app_text_field.dart';
import 'package:kora/common/widgets/kora_card.dart';
import 'package:kora/common/widgets/primary_button.dart';
import 'package:kora/core/router/app_routes.dart';

/// Screen to add a new skincare product to the routine (C08 in blueprint).
class AddProductPage extends StatefulWidget {
  /// Creates an [AddProductPage].
  const AddProductPage({super.key});

  @override
  State<AddProductPage> createState() => _AddProductPageState();
}

class _AddProductPageState extends State<AddProductPage> {
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _brandController = TextEditingController();
  final TextEditingController _searchController = TextEditingController();

  String _selectedStep = 'Serum';
  String _selectedPeriod = 'Both';
  final Set<String> _selectedActives = {'Niacinamide'};

  final List<String> _steps = [
    'Cleanser',
    'Serum',
    'Moisturizer',
    'SPF',
    'Treatment',
  ];
  final List<String> _commonActives = [
    'Niacinamide',
    'Hyaluronic Acid',
    'Retinol',
    'Salicylic Acid',
    'Vitamin C',
    'Ceramides',
    'Azelaic Acid',
    'Peptides',
  ];

  @override
  void dispose() {
    _nameController.dispose();
    _brandController.dispose();
    _searchController.dispose();
    super.dispose();
  }

  Future<void> _onSave() async {
    final name = _nameController.text.trim();
    if (name.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            'Please enter a product name.',
            style: AppTypography.bodySMedium.copyWith(color: AppColors.grey50),
          ),
          backgroundColor: AppColors.error400,
        ),
      );
      return;
    }

    // Nielsen heuristics: Low friction + prompt for experiment test (C08 / C11)
    await showModalBottomSheet<void>(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (bottomSheetContext) {
        return Container(
          decoration: const BoxDecoration(
            color: AppColors.grey50,
            borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
          ),
          padding: const EdgeInsets.fromLTRB(20, 16, 20, 24),
          child: SafeArea(
            top: false,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Center(
                  child: Container(
                    width: 36,
                    height: 4,
                    decoration: BoxDecoration(
                      color: AppColors.grey300,
                      borderRadius: BorderRadius.circular(2),
                    ),
                  ),
                ),
                const SizedBox(height: 16),
                Text(
                  'Product added to routine!',
                  style: AppTypography.h5Bold.copyWith(
                    color: AppColors.grey1050,
                  ),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 8),
                Text(
                  'Do you want to test whether $name really works by '
                  'starting a 6-week experiment?',
                  style: AppTypography.bodySRegular.copyWith(
                    color: AppColors.grey700,
                  ),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 20),
                PrimaryButton(
                  text: 'Start an experiment',
                  height: 52,
                  backgroundColor: AppColors.primary700,
                  onPressed: () {
                    Navigator.of(bottomSheetContext).pop();
                    unawaited(context.push(AppRoutes.experimentNew));
                  },
                ),
                const SizedBox(height: 8),
                TextButton(
                  onPressed: () {
                    Navigator.of(bottomSheetContext).pop();
                    context.pop();
                  },
                  child: Text(
                    'Just save to routine',
                    style: AppTypography.bodySMedium.copyWith(
                      color: AppColors.grey700,
                    ),
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.scaffoldColor,
      appBar: AppBar(
        title: Text(
          'Add Product',
          style: AppTypography.h5Bold.copyWith(color: AppColors.grey1050),
        ),
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // Search in catalog
              AppTextField(
                controller: _searchController,
                hintText: 'Search products in database...',
                prefixIcon: const Icon(Icons.search, color: AppColors.grey600),
              ),
              const SizedBox(height: 12),

              // OCR Label Scan shortcut
              KoraCard(
                onTap: () => context.push(AppRoutes.routineLabel),
                backgroundColor: AppColors.primary50,
                borderColor: AppColors.primary200,
                child: Row(
                  children: [
                    Container(
                      width: 40,
                      height: 40,
                      decoration: BoxDecoration(
                        color: AppColors.primary100,
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: const Icon(
                        Icons.document_scanner_outlined,
                        color: AppColors.primary800,
                        size: 22,
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Scan ingredient label (OCR)',
                            style: AppTypography.bodyMSemiBold.copyWith(
                              color: AppColors.grey1050,
                            ),
                          ),
                          Text(
                            'Instant breakdown of actives and allergens',
                            style: AppTypography.bodyXsRegular.copyWith(
                              color: AppColors.grey700,
                            ),
                          ),
                        ],
                      ),
                    ),
                    const Icon(
                      Icons.chevron_right_rounded,
                      color: AppColors.primary700,
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 20),

              // Step Selector
              Text(
                'Step Category',
                style: AppTypography.bodyMSemiBold.copyWith(
                  color: AppColors.grey1050,
                ),
              ),
              const SizedBox(height: 8),
              Wrap(
                spacing: 8,
                runSpacing: 8,
                children: _steps.map((step) {
                  final isSelected = _selectedStep == step;
                  return ChoiceChip(
                    label: Text(step),
                    selected: isSelected,
                    selectedColor: AppColors.primary700,
                    backgroundColor: AppColors.grey100,
                    labelStyle: AppTypography.bodySMedium.copyWith(
                      color: isSelected ? AppColors.grey50 : AppColors.grey800,
                    ),
                    side: BorderSide(
                      color: isSelected
                          ? AppColors.primary700
                          : AppColors.grey300,
                    ),
                    onSelected: (_) => setState(() => _selectedStep = step),
                  );
                }).toList(),
              ),
              const SizedBox(height: 16),

              // Form fields
              Text(
                'Product Name',
                style: AppTypography.bodyMSemiBold.copyWith(
                  color: AppColors.grey1050,
                ),
              ),
              const SizedBox(height: 6),
              AppTextField(
                controller: _nameController,
                hintText: 'e.g. Niacinamide 10% + Zinc 1%',
              ),
              const SizedBox(height: 14),

              Text(
                'Brand',
                style: AppTypography.bodyMSemiBold.copyWith(
                  color: AppColors.grey1050,
                ),
              ),
              const SizedBox(height: 6),
              AppTextField(
                controller: _brandController,
                hintText: 'e.g. The Ordinary',
              ),
              const SizedBox(height: 16),

              // Key Actives selector
              Text(
                'Key Actives (Optional)',
                style: AppTypography.bodyMSemiBold.copyWith(
                  color: AppColors.grey1050,
                ),
              ),
              const SizedBox(height: 8),
              Wrap(
                spacing: 6,
                runSpacing: 6,
                children: _commonActives.map((active) {
                  final isSelected = _selectedActives.contains(active);
                  return FilterChip(
                    label: Text(active),
                    selected: isSelected,
                    selectedColor: AppColors.primary100,
                    backgroundColor: AppColors.grey100,
                    labelStyle: AppTypography.bodyXsMedium.copyWith(
                      color: isSelected
                          ? AppColors.primary900
                          : AppColors.grey800,
                    ),
                    side: BorderSide(
                      color: isSelected
                          ? AppColors.primary700
                          : AppColors.grey300,
                    ),
                    onSelected: (val) {
                      setState(() {
                        if (val) {
                          _selectedActives.add(active);
                        } else {
                          _selectedActives.remove(active);
                        }
                      });
                    },
                  );
                }).toList(),
              ),
              const SizedBox(height: 16),

              // Routine period
              Text(
                'When do you use it?',
                style: AppTypography.bodyMSemiBold.copyWith(
                  color: AppColors.grey1050,
                ),
              ),
              const SizedBox(height: 8),
              Row(
                children: ['Morning', 'Evening', 'Both'].map((period) {
                  final isSelected = _selectedPeriod == period;
                  return Expanded(
                    child: Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 4),
                      child: OutlinedButton(
                        style: OutlinedButton.styleFrom(
                          backgroundColor: isSelected
                              ? AppColors.primary700
                              : AppColors.grey50,
                          side: BorderSide(
                            color: isSelected
                                ? AppColors.primary700
                                : AppColors.grey300,
                          ),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(10),
                          ),
                          padding: const EdgeInsets.symmetric(vertical: 12),
                        ),
                        onPressed: () =>
                            setState(() => _selectedPeriod = period),
                        child: Text(
                          period,
                          style: AppTypography.bodySMedium.copyWith(
                            color: isSelected
                                ? AppColors.grey50
                                : AppColors.grey800,
                          ),
                        ),
                      ),
                    ),
                  );
                }).toList(),
              ),
              const SizedBox(height: 28),

              // Save CTA
              PrimaryButton(
                text: 'Save product',
                height: 52,
                backgroundColor: AppColors.primary700,
                onPressed: _onSave,
              ),
              const SizedBox(height: 16),
            ],
          ),
        ),
      ),
    );
  }
}
