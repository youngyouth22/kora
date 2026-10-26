// ignore_for_file: document_ignores, lines_longer_than_80_chars

import 'package:flutter/material.dart';
import 'package:kora/common/app_colors.dart';
import 'package:kora/common/app_typography.dart';
import 'package:kora/common/widgets/kora_card.dart';

/// Embedded video player and editorial takeaways screen (C16 in blueprint).
class LearnVideoPage extends StatefulWidget {
  /// Creates a [LearnVideoPage].
  const LearnVideoPage({
    this.videoId = '1',
    super.key,
  });

  /// The video identifier.
  final String videoId;

  @override
  State<LearnVideoPage> createState() => _LearnVideoPageState();
}

class _LearnVideoPageState extends State<LearnVideoPage> {
  bool _isPlaying = false;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.scaffoldColor,
      appBar: AppBar(
        title: Text(
          'Video Guide',
          style: AppTypography.h5Bold.copyWith(color: AppColors.grey1050),
        ),
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // Clean Modern Flat Video Player Mockup
              KoraCard(
                padding: EdgeInsets.zero,
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(16),
                  child: Container(
                    height: 200,
                    color: AppColors.grey1050,
                    child: Stack(
                      alignment: Alignment.center,
                      children: [
                        Center(
                          child: GestureDetector(
                            onTap: () =>
                                setState(() => _isPlaying = !_isPlaying),
                            child: Container(
                              width: 56,
                              height: 56,
                              decoration: BoxDecoration(
                                shape: BoxShape.circle,
                                color: AppColors.primary700,
                                border: Border.all(
                                  color: AppColors.grey50,
                                  width: 2,
                                ),
                              ),
                              child: Icon(
                                _isPlaying
                                    ? Icons.pause_rounded
                                    : Icons.play_arrow_rounded,
                                size: 32,
                                color: AppColors.grey50,
                              ),
                            ),
                          ),
                        ),
                        Positioned(
                          bottom: 12,
                          left: 16,
                          right: 16,
                          child: Row(
                            children: [
                              Text(
                                _isPlaying ? '02:45 / 08:12' : '00:00 / 08:12',
                                style: AppTypography.bodyXsRegular.copyWith(
                                  color: AppColors.grey200,
                                ),
                              ),
                              const Spacer(),
                              const Icon(
                                Icons.fullscreen_rounded,
                                color: AppColors.grey200,
                                size: 20,
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 16),

              // Title and Channel metadata
              Text(
                'How to start Retinol without purging or barrier irritation',
                style: AppTypography.h6Bold.copyWith(color: AppColors.grey1050),
              ),
              const SizedBox(height: 4),
              Text(
                'By Dr. Sam Ellis · 8 min · Board-Certified Dermatologist',
                style: AppTypography.bodySRegular.copyWith(
                  color: AppColors.grey700,
                ),
              ),
              const SizedBox(height: 16),

              // Key takeaways editorial notes
              Text(
                'Key Takeaways (Our Notes)',
                style: AppTypography.bodyMSemiBold.copyWith(
                  color: AppColors.grey1050,
                ),
              ),
              const SizedBox(height: 8),
              KoraCard(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _buildTakeawayItem(
                      '1',
                      'Start with a low concentration (0.2% - 0.3%) twice a week for the first 2 weeks.',
                    ),
                    const SizedBox(height: 10),
                    _buildTakeawayItem(
                      '2',
                      'Use the "sandwich method": apply light moisturizer, wait 5 min, apply retinol, then seal with barrier cream.',
                    ),
                    const SizedBox(height: 10),
                    _buildTakeawayItem(
                      '3',
                      'Never apply exfoliating acids (AHA/BHA) on the same evening.',
                    ),
                    const SizedBox(height: 10),
                    _buildTakeawayItem(
                      '4',
                      'Daily broad spectrum SPF 50 is non-negotiable every single morning.',
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 16),

              // Tags
              Text(
                'Tags & Topics',
                style: AppTypography.bodyMSemiBold.copyWith(
                  color: AppColors.grey1050,
                ),
              ),
              const SizedBox(height: 8),
              Wrap(
                spacing: 8,
                runSpacing: 8,
                children:
                    ['Retinol', 'Beginner', 'Barrier Health', 'Anti-Aging'].map(
                      (tag) {
                        return Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 10,
                            vertical: 5,
                          ),
                          decoration: BoxDecoration(
                            color: AppColors.grey100,
                            borderRadius: BorderRadius.circular(100),
                            border: Border.all(color: AppColors.grey300),
                          ),
                          child: Text(
                            tag,
                            style: AppTypography.bodyXsMedium.copyWith(
                              color: AppColors.grey800,
                            ),
                          ),
                        );
                      },
                    ).toList(),
              ),
              const SizedBox(height: 24),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildTakeawayItem(String number, String text) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          width: 20,
          height: 20,
          decoration: const BoxDecoration(
            shape: BoxShape.circle,
            color: AppColors.primary100,
          ),
          alignment: Alignment.center,
          child: Text(
            number,
            style: AppTypography.bodyXsBold.copyWith(
              color: AppColors.primary900,
            ),
          ),
        ),
        const SizedBox(width: 10),
        Expanded(
          child: Text(
            text,
            style: AppTypography.bodySRegular.copyWith(
              color: AppColors.grey900,
              height: 1.45,
            ),
          ),
        ),
      ],
    );
  }
}
