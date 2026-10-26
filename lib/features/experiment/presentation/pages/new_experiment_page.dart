// ignore_for_file: document_ignores, lines_longer_than_80_chars

import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:kora/common/app_colors.dart';
import 'package:kora/common/app_typography.dart';
import 'package:kora/common/widgets/kora_card.dart';
import 'package:kora/common/widgets/primary_button.dart';
import 'package:kora/core/router/app_routes.dart';

/// Screen to frame and launch a scientifically controlled product experiment (C11 in blueprint).
class NewExperimentPage extends StatefulWidget {
  /// Creates a [NewExperimentPage].
  const NewExperimentPage({super.key});

  @override
  State<NewExperimentPage> createState() => _NewExperimentPageState();
}

class _NewExperimentPageState extends State<NewExperimentPage> {
  String _selectedProduct = 'Retinol 0.3% Emulsion';
  final Set<String> _selectedConcerns = {'Redness', 'Texture'};
  int _selectedDurationWeeks = 6;

  final List<String> _productsInRoutine = [
    'Retinol 0.3% Emulsion',
    'Vitamin C 15% Super Serum',
    'Azelaic Acid 10% Suspension',
  ];

  final List<String> _availableConcerns = [
    'Dark spots',
    'Redness',
    'Texture',
    'Pores',
    'Hydration',
  ];

  final List<int> _durations = [4, 6, 8, 12];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.scaffoldColor,
      appBar: AppBar(
        title: Text(
          'New Experiment',
          style: AppTypography.h5Bold.copyWith(color: AppColors.grey1050),
        ),
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // Product selection
              Text(
                'Product to test',
                style: AppTypography.bodyMSemiBold.copyWith(
                  color: AppColors.grey1050,
                ),
              ),
              const SizedBox(height: 8),
              KoraCard(
                padding: const EdgeInsets.symmetric(
                  horizontal: 14,
                  vertical: 4,
                ),
                child: DropdownButtonHideUnderline(
                  child: DropdownButton<String>(
                    value: _selectedProduct,
                    isExpanded: true,
                    icon: const Icon(
                      Icons.arrow_drop_down,
                      color: AppColors.primary700,
                    ),
                    items: _productsInRoutine.map((prod) {
                      return DropdownMenuItem(
                        value: prod,
                        child: Text(
                          prod,
                          style: AppTypography.bodyMRegular.copyWith(
                            color: AppColors.grey1050,
                          ),
                        ),
                      );
                    }).toList(),
                    onChanged: (val) {
                      if (val != null) setState(() => _selectedProduct = val);
                    },
                  ),
                ),
              ),
              const SizedBox(height: 18),

              // Target concerns (Pick 1 to 2)
              Text(
                'Target concerns (Pick up to 2)',
                style: AppTypography.bodyMSemiBold.copyWith(
                  color: AppColors.grey1050,
                ),
              ),
              const SizedBox(height: 8),
              Wrap(
                spacing: 8,
                runSpacing: 8,
                children: _availableConcerns.map((concern) {
                  final isSelected = _selectedConcerns.contains(concern);
                  return FilterChip(
                    label: Text(concern),
                    selected: isSelected,
                    selectedColor: AppColors.primary100,
                    backgroundColor: AppColors.grey100,
                    labelStyle: AppTypography.bodySMedium.copyWith(
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
                          if (_selectedConcerns.length < 2) {
                            _selectedConcerns.add(concern);
                          }
                        } else {
                          _selectedConcerns.remove(concern);
                        }
                      });
                    },
                  );
                }).toList(),
              ),
              const SizedBox(height: 18),

              // Duration selector
              Text(
                'Test Duration',
                style: AppTypography.bodyMSemiBold.copyWith(
                  color: AppColors.grey1050,
                ),
              ),
              const SizedBox(height: 8),
              Row(
                children: _durations.map((wks) {
                  final isSelected = _selectedDurationWeeks == wks;
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
                            setState(() => _selectedDurationWeeks = wks),
                        child: Text(
                          '$wks wks${wks == 6 ? ' *' : ''}',
                          style: AppTypography.bodyXsBold.copyWith(
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
              const SizedBox(height: 4),
              Text(
                '* 6 to 8 weeks is scientifically optimal for skin turnover.',
                style: AppTypography.bodyXsRegular.copyWith(
                  color: AppColors.grey700,
                ),
              ),
              const SizedBox(height: 18),

              // Scientific baseline explanation
              KoraCard(
                backgroundColor: AppColors.primary50,
                borderColor: AppColors.primary200,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'How we compare',
                      style: AppTypography.bodyMSemiBold.copyWith(
                        color: AppColors.primary900,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      'Your last 2 weekly scans form the baseline. Future scans are compared using a noise-filtered rolling average to deliver an unbiased final verdict.',
                      style: AppTypography.bodySRegular.copyWith(
                        color: AppColors.grey800,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 12),

              // One change rule
              KoraCard(
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Icon(
                      Icons.science_outlined,
                      color: AppColors.secondary700,
                      size: 20,
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'One change at a time',
                            style: AppTypography.bodyMSemiBold.copyWith(
                              color: AppColors.grey1050,
                            ),
                          ),
                          const SizedBox(height: 2),
                          Text(
                            'Avoid adding other active serums simultaneously so results can be attributed directly to this formula.',
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
              const SizedBox(height: 28),

              // Launch CTA
              PrimaryButton(
                text: 'Start experiment',
                height: 52,
                backgroundColor: AppColors.primary700,
                onPressed: () {
                  context.pushReplacement(AppRoutes.buildExperimentPath('1'));
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
