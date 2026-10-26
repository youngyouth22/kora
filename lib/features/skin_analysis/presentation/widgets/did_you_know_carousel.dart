// ignore_for_file: document_ignores, lines_longer_than_80_chars

import 'dart:async';

import 'package:flutter/material.dart';
import 'package:kora/common/app_colors.dart';
import 'package:kora/common/app_typography.dart';

class _SkincareFact {
  const _SkincareFact({
    required this.title,
    required this.fact,
  });

  final String title;
  final String fact;
}

/// Educational carousel displaying rotating skincare facts during analysis.
class DidYouKnowCarousel extends StatefulWidget {
  /// Creates a [DidYouKnowCarousel].
  const DidYouKnowCarousel({super.key});

  @override
  State<DidYouKnowCarousel> createState() => _DidYouKnowCarouselState();
}

class _DidYouKnowCarouselState extends State<DidYouKnowCarousel> {
  static const List<_SkincareFact> _facts = [
    _SkincareFact(
      title: 'Did you know?',
      fact: 'Skin cell turnover takes roughly 28 days. Consistency in your routine is key.',
    ),
    _SkincareFact(
      title: 'Skin Barrier Insight',
      fact: 'Ceramides make up over 50% of your skin barrier, locking in hydration.',
    ),
    _SkincareFact(
      title: 'Did you know?',
      fact: 'Broad-spectrum SPF protects both your collagen and uniform pigmentation.',
    ),
    _SkincareFact(
      title: 'Hydration Fact',
      fact: 'Applying moisturizer to damp skin helps seal in up to 30% more hydration.',
    ),
  ];

  int _currentIndex = 0;
  Timer? _timer;

  @override
  void initState() {
    super.initState();
    _timer = Timer.periodic(const Duration(seconds: 4), (timer) {
      if (mounted) {
        setState(() {
          _currentIndex = (_currentIndex + 1) % _facts.length;
        });
      }
    });
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final currentFact = _facts[_currentIndex];

    return Semantics(
      container: true,
      label: '${currentFact.title}: ${currentFact.fact}',
      child: AnimatedSwitcher(
        duration: const Duration(milliseconds: 400),
        child: Container(
          key: ValueKey<int>(_currentIndex),
          padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 14),
          decoration: BoxDecoration(
            color: AppGreyColors.shade1050.withValues(alpha: 0.55),
            borderRadius: BorderRadius.circular(16),
            border: Border.all(
              color: AppGreyColors.white.withValues(alpha: 0.12),
            ),
          ),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: AppPrimaryColors.shade500.withValues(alpha: 0.15),
                  shape: BoxShape.circle,
                ),
                child: const Icon(
                  Icons.auto_awesome,
                  color: AppPrimaryColors.shade400,
                  size: 18,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      currentFact.title,
                      style: AppTypography.bodyMSemiBold.copyWith(
                        color: AppPrimaryColors.shade400,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      currentFact.fact,
                      style: AppTypography.bodySRegular.copyWith(
                        color: AppGreyColors.shade300,
                        height: 1.4,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
