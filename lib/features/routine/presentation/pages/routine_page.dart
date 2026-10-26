import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:kora/common/app_colors.dart';
import 'package:kora/common/app_typography.dart';
import 'package:kora/common/widgets/kora_card.dart';
import 'package:kora/common/widgets/primary_button.dart';
import 'package:kora/core/router/app_routes.dart';

/// Routine management and daily tracking screen (C07 in blueprint).
class RoutinePage extends StatefulWidget {
  /// Creates a [RoutinePage].
  const RoutinePage({super.key});

  @override
  State<RoutinePage> createState() => _RoutinePageState();
}

class _RoutinePageState extends State<RoutinePage> {
  int _selectedTab = 0; // 0: Morning, 1: Evening

  // Morning items state
  final List<Map<String, dynamic>> _morningItems = [
    {
      'name': 'Gentle Hydrating Cleanser',
      'brand': 'CeraVe',
      'step': 'Cleanser',
      'actives': ['Ceramides', 'Hyaluronic Acid'],
      'days': 42,
      'done': true,
    },
    {
      'name': 'Vitamin C 15% Super Serum',
      'brand': 'Geek & Gorgeous',
      'step': 'Serum',
      'actives': ['L-Ascorbic Acid', 'Ferulic Acid'],
      'days': 28,
      'done': true,
    },
    {
      'name': 'Barrier Support Moisturizer',
      'brand': 'Avene',
      'step': 'Moisturizer',
      'actives': ['Thermal Water', 'Squalane'],
      'days': 42,
      'done': false,
    },
    {
      'name': 'Mineral UV Defense SPF 50',
      'brand': 'La Roche-Posay',
      'step': 'Sunscreen',
      'actives': ['Zinc Oxide', 'Titanium Dioxide'],
      'days': 60,
      'done': false,
    },
  ];

  // Evening items state
  final List<Map<String, dynamic>> _eveningItems = [
    {
      'name': 'Micellar Water Makeup Remover',
      'brand': 'Bioderma',
      'step': 'First Cleanse',
      'actives': ['Micelles', 'Cucumber Extract'],
      'days': 42,
      'done': false,
    },
    {
      'name': 'Gentle Hydrating Cleanser',
      'brand': 'CeraVe',
      'step': 'Second Cleanse',
      'actives': ['Ceramides'],
      'days': 42,
      'done': false,
    },
    {
      'name': 'Retinol 0.3% Emulsion (In Experiment)',
      'brand': 'The Ordinary',
      'step': 'Active Treatment',
      'actives': ['Retinol 0.3%', 'Bisabolol'],
      'days': 12,
      'done': false,
      'isExperiment': true,
    },
    {
      'name': 'Intensive Ceramide Balm',
      'brand': 'CeraVe',
      'step': 'Moisturizer',
      'actives': ['Ceramides 1, 3, 6-II', 'Cholesterol'],
      'days': 42,
      'done': false,
    },
  ];

  @override
  Widget build(BuildContext context) {
    final currentList = _selectedTab == 0 ? _morningItems : _eveningItems;

    return Scaffold(
      backgroundColor: AppColors.scaffoldColor,
      appBar: AppBar(
        title: Text(
          'Skincare Routine',
          style: AppTypography.h5Bold.copyWith(color: AppColors.grey1050),
        ),
        actions: [
          IconButton(
            tooltip: 'Scan Label (OCR)',
            icon: const Icon(
              Icons.document_scanner_outlined,
              color: AppColors.primary700,
            ),
            onPressed: () => context.push(AppRoutes.routineLabel),
          ),
        ],
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              _buildPeriodTabs(),
              const SizedBox(height: 16),
              _buildAdherenceCard(),
              const SizedBox(height: 12),
              if (_selectedTab == 1) _buildCompatibilityWarning(),
              const SizedBox(height: 16),
              Text(
                _selectedTab == 0 ? 'Morning Steps (AM)' : 'Evening Steps (PM)',
                style: AppTypography.h6Bold.copyWith(color: AppColors.grey1050),
              ),
              const SizedBox(height: 10),
              ...List.generate(currentList.length, (index) {
                final item = currentList[index];
                return Padding(
                  padding: const EdgeInsets.only(bottom: 10),
                  child: _buildRoutineItemCard(item, () {
                    setState(() {
                      item['done'] = !(item['done'] as bool);
                    });
                  }),
                );
              }),
              const SizedBox(height: 20),
              PrimaryButton(
                text: '+ Add product',
                height: 52,
                backgroundColor: AppColors.primary700,
                onPressed: () => context.push(AppRoutes.routineAdd),
              ),
              const SizedBox(height: 24),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildPeriodTabs() {
    return Container(
      decoration: BoxDecoration(
        color: AppColors.grey100,
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: AppColors.grey300),
      ),
      padding: const EdgeInsets.all(4),
      child: Row(
        children: [
          _buildTabItem(
            title: 'Morning (AM)',
            index: 0,
            icon: Icons.wb_sunny_outlined,
          ),
          _buildTabItem(
            title: 'Evening (PM)',
            index: 1,
            icon: Icons.nightlight_outlined,
          ),
        ],
      ),
    );
  }

  Widget _buildTabItem({
    required String title,
    required int index,
    required IconData icon,
  }) {
    final isSelected = _selectedTab == index;
    return Expanded(
      child: GestureDetector(
        onTap: () => setState(() => _selectedTab = index),
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 9),
          decoration: BoxDecoration(
            color: isSelected ? AppColors.grey50 : Colors.transparent,
            borderRadius: BorderRadius.circular(8),
            border: isSelected ? Border.all(color: AppColors.grey300) : null,
          ),
          alignment: Alignment.center,
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                icon,
                size: 16,
                color: isSelected ? AppColors.primary700 : AppColors.grey600,
              ),
              const SizedBox(width: 6),
              Text(
                title,
                style: isSelected
                    ? AppTypography.bodySMedium.copyWith(
                        color: AppColors.primary900,
                      )
                    : AppTypography.bodySRegular.copyWith(
                        color: AppColors.grey700,
                      ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildAdherenceCard() {
    return KoraCard(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      child: Row(
        children: [
          Container(
            width: 38,
            height: 38,
            decoration: BoxDecoration(
              color: AppColors.primary50,
              borderRadius: BorderRadius.circular(10),
            ),
            child: const Icon(
              Icons.check_circle_outline_rounded,
              color: AppColors.primary700,
              size: 20,
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Adherence: 5 of 7 days this week',
                  style: AppTypography.bodyMSemiBold.copyWith(
                    color: AppColors.grey1050,
                  ),
                ),
                Text(
                  'Consistency makes verdicts scientifically dependable.',
                  style: AppTypography.bodyXsRegular.copyWith(
                    color: AppColors.grey700,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCompatibilityWarning() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
      decoration: BoxDecoration(
        color: AppColors.secondary50,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColors.secondary200),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Icon(
            Icons.info_outline_rounded,
            color: AppColors.secondary700,
            size: 18,
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Text(
              'Compatibility check: Avoid layering AHA/BHA exfoliants with Retinol on the same evening to prevent irritation.',
              style: AppTypography.bodyXsRegular.copyWith(
                color: AppColors.secondary900,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildRoutineItemCard(
    Map<String, dynamic> item,
    VoidCallback onToggle,
  ) {
    final done = item['done'] as bool;
    final name = item['name'] as String;
    final brand = item['brand'] as String;
    final step = item['step'] as String;
    final actives = (item['actives'] as List<dynamic>).cast<String>();
    final days = item['days'] as int;
    final isExperiment = item['isExperiment'] as bool? ?? false;

    return KoraCard(
      borderColor: isExperiment ? AppColors.primary300 : AppColors.grey300,
      backgroundColor: isExperiment
          ? AppColors.primary50.withValues(alpha: 0.3)
          : AppColors.grey50,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              GestureDetector(
                onTap: onToggle,
                child: Container(
                  width: 24,
                  height: 24,
                  margin: const EdgeInsets.only(top: 2),
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: done ? AppColors.primary700 : Colors.transparent,
                    border: Border.all(
                      color: done ? AppColors.primary700 : AppColors.grey400,
                      width: 1.5,
                    ),
                  ),
                  alignment: Alignment.center,
                  child: done
                      ? const Icon(
                          Icons.check,
                          size: 14,
                          color: AppColors.grey50,
                        )
                      : null,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Text(
                          step.toUpperCase(),
                          style: AppTypography.bodyXsBold.copyWith(
                            color: AppColors.primary800,
                            letterSpacing: 0.4,
                          ),
                        ),
                        if (isExperiment) ...[
                          const SizedBox(width: 6),
                          Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 6,
                              vertical: 2,
                            ),
                            decoration: BoxDecoration(
                              color: AppColors.primary700,
                              borderRadius: BorderRadius.circular(4),
                            ),
                            child: Text(
                              'EXPERIMENT',
                              style: AppTypography.bodyXsBold.copyWith(
                                color: AppColors.grey50,
                                fontSize: 9,
                              ),
                            ),
                          ),
                        ],
                        const Spacer(),
                        Text(
                          'used $days d',
                          style: AppTypography.bodyXsRegular.copyWith(
                            color: AppColors.grey600,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 2),
                    Text(
                      name,
                      style: AppTypography.bodyMSemiBold.copyWith(
                        color: AppColors.grey1050,
                        decoration: done ? TextDecoration.lineThrough : null,
                      ),
                    ),
                    Text(
                      brand,
                      style: AppTypography.bodyXsRegular.copyWith(
                        color: AppColors.grey700,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 10),
          Wrap(
            spacing: 6,
            runSpacing: 4,
            children: actives.map((active) {
              return Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                decoration: BoxDecoration(
                  color: AppColors.grey100,
                  borderRadius: BorderRadius.circular(6),
                ),
                child: Text(
                  active,
                  style: AppTypography.bodyXsRegular.copyWith(
                    color: AppColors.grey800,
                  ),
                ),
              );
            }).toList(),
          ),
        ],
      ),
    );
  }
}
