// ignore_for_file: document_ignores, lines_longer_than_80_chars

import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:kora/common/app_colors.dart';
import 'package:kora/common/app_typography.dart';
import 'package:kora/common/widgets/app_text_field.dart';
import 'package:kora/common/widgets/kora_card.dart';
import 'package:kora/core/router/app_routes.dart';

/// Educational video library screen (C15 in blueprint).
class LearnPage extends StatefulWidget {
  /// Creates a [LearnPage].
  const LearnPage({super.key});

  @override
  State<LearnPage> createState() => _LearnPageState();
}

class _LearnPageState extends State<LearnPage> {
  final TextEditingController _searchController = TextEditingController();
  String _selectedCategory = 'For you';

  final List<String> _categories = [
    'For you',
    'Acne',
    'Retinol',
    'SPF',
    'Barrier',
  ];

  final List<Map<String, String>> _videos = [
    {
      'id': '1',
      'title': 'How to start Retinol without purging',
      'channel': 'Dr. Sam Ellis',
      'duration': '8 min',
      'tag': 'Retinol',
    },
    {
      'id': '2',
      'title':
          'The truth about dark spot treatments (Hydroquinone, Azelaic, Vit C)',
      'channel': 'Doctorly',
      'duration': '11 min',
      'tag': 'Dark spots',
    },
    {
      'id': '3',
      'title': 'SPF explained: Chemical vs Mineral UV filters',
      'channel': 'Lab Muffin Beauty Science',
      'duration': '6 min',
      'tag': 'SPF',
    },
    {
      'id': '4',
      'title': 'Skin barrier repair: The exact 3-step routine',
      'channel': 'Dr. Shereene Idriss',
      'duration': '7 min',
      'tag': 'Barrier',
    },
  ];

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.scaffoldColor,
      appBar: AppBar(
        title: Text(
          'Skin Academy',
          style: AppTypography.h5Bold.copyWith(color: AppColors.grey1050),
        ),
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // Search bar
              AppTextField(
                controller: _searchController,
                hintText: 'Search expert dermatological guides...',
                prefixIcon: const Icon(Icons.search, color: AppColors.grey600),
              ),
              const SizedBox(height: 12),

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
              const SizedBox(height: 18),

              // Featured Video Card
              Text(
                'Featured Guide',
                style: AppTypography.h6Bold.copyWith(color: AppColors.grey1050),
              ),
              const SizedBox(height: 8),
              KoraCard(
                onTap: () => context.push(AppRoutes.buildLearnVideoPath('3')),
                padding: EdgeInsets.zero,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Container(
                      height: 150,
                      decoration: const BoxDecoration(
                        color: AppColors.neutral200,
                        borderRadius: BorderRadius.vertical(
                          top: Radius.circular(16),
                        ),
                      ),
                      child: Center(
                        child: Container(
                          width: 48,
                          height: 48,
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            color: AppColors.primary700.withValues(alpha: 0.9),
                          ),
                          child: const Icon(
                            Icons.play_arrow_rounded,
                            color: AppColors.grey50,
                            size: 30,
                          ),
                        ),
                      ),
                    ),
                    Padding(
                      padding: const EdgeInsets.all(14),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'SPF explained: Chemical vs Mineral filters',
                            style: AppTypography.bodyLBold.copyWith(
                              color: AppColors.grey1050,
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            'Lab Muffin Beauty Science · 6 min · Evidence-based breakdown',
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
              const SizedBox(height: 20),

              // All videos
              Text(
                'Curated Tutorials',
                style: AppTypography.h6Bold.copyWith(color: AppColors.grey1050),
              ),
              const SizedBox(height: 10),
              ..._videos.map((vid) {
                return Padding(
                  padding: const EdgeInsets.only(bottom: 10),
                  child: KoraCard(
                    onTap: () =>
                        context.push(AppRoutes.buildLearnVideoPath(vid['id']!)),
                    child: Row(
                      children: [
                        Container(
                          width: 60,
                          height: 60,
                          decoration: BoxDecoration(
                            color: AppColors.neutral200,
                            borderRadius: BorderRadius.circular(10),
                            border: Border.all(color: AppColors.grey300),
                          ),
                          child: const Icon(
                            Icons.play_circle_outline_rounded,
                            color: AppColors.primary700,
                            size: 28,
                          ),
                        ),
                        const SizedBox(width: 14),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                vid['title']!,
                                style: AppTypography.bodyMSemiBold.copyWith(
                                  color: AppColors.grey1050,
                                ),
                                maxLines: 2,
                                overflow: TextOverflow.ellipsis,
                              ),
                              const SizedBox(height: 2),
                              Text(
                                '${vid['channel']} · ${vid['duration']}',
                                style: AppTypography.bodyXsRegular.copyWith(
                                  color: AppColors.grey700,
                                ),
                              ),
                            ],
                          ),
                        ),
                        const Icon(
                          Icons.chevron_right_rounded,
                          color: AppColors.grey600,
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
