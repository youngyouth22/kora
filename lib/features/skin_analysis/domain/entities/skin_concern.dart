// ignore_for_file: document_ignores, lines_longer_than_80_chars

import 'package:equatable/equatable.dart';

/// Represents a single skin condition or concern analyzed by YouCam AI.
class SkinConcern extends Equatable {
  /// Creates a [SkinConcern].
  const SkinConcern({
    required this.id,
    required this.displayName,
    required this.uiScore,
    required this.rawScore,
    this.maskUrls = const [],
    this.customAdvice,
  });

  /// Canonical identifier (e.g. 'pore', 'wrinkle', 'acne', 'redness', 'texture').
  final String id;

  /// User-friendly label for display.
  final String displayName;

  /// Normalized user-facing score between 0 and 100 (higher is always better).
  final int uiScore;

  /// Raw algorithm score (internal metric).
  final double rawScore;

  /// URLs of detection mask images returned by the API.
  final List<String> maskUrls;

  /// Optional specific advice for this concern.
  final String? customAdvice;

  /// Calculates star rating from 1 to 5 based on [uiScore].
  ///
  /// Criteria:
  /// - >= 85 : 5 stars (Excellent)
  /// - 70..84: 4 stars (Good)
  /// - 55..69: 3 stars (Fair)
  /// - 40..54: 2 stars (Needs care)
  /// - < 40  : 1 star  (Needs attention)
  int get starRating {
    if (uiScore >= 85) return 5;
    if (uiScore >= 70) return 4;
    if (uiScore >= 55) return 3;
    if (uiScore >= 40) return 2;
    return 1;
  }

  /// Provides gentle, non-medical advice based on the concern type and score.
  String get advice {
    if (customAdvice != null && customAdvice!.isNotEmpty) {
      return customAdvice!;
    }
    return _defaultAdviceFor(id, uiScore);
  }

  static String _defaultAdviceFor(String id, int score) {
    final isGood = score >= 70;
    switch (id) {
      case 'pore':
        return isGood
            ? 'Pores appear refined and clean. Continue gentle cleansing.'
            : 'Focus on gentle double cleansing and light BHA exfoliation.';
      case 'wrinkle':
        return isGood
            ? 'Skin looks smooth and elastic. Keep protecting with daily SPF.'
            : 'Boost hydration and barrier support with peptides and ceramides.';
      case 'texture':
        return isGood
            ? 'Skin surface is soft and even-toned.'
            : 'Incorporate mild PHA or lactic acid to refine surface texture.';
      case 'acne':
        return isGood
            ? 'Skin is calm and clear with minimal blemish activity.'
            : 'Keep the routine soothing with centella and non-comedogenic care.';
      case 'redness':
        return isGood
            ? 'Tone is even with minimal visible irritation.'
            : 'Calm the barrier with niacinamide, panthenol, and fragrance-free care.';
      case 'oiliness':
        return isGood
            ? 'Sebum balance is well regulated.'
            : 'Use lightweight water-gel textures and zinc-infused serums.';
      case 'moisture':
        return isGood
            ? 'Hydration levels are well balanced and plump.'
            : 'Layer humectants like hyaluronic acid followed by an occlusive cream.';
      case 'radiance':
        return isGood
            ? 'Complexion has a healthy, luminous natural glow.'
            : 'Introduce vitamin C derivatives and morning antioxidant protection.';
      case 'firmness':
        return isGood
            ? 'Skin maintains great elasticity and bounce.'
            : 'Support resilience with firming peptides and facial massage.';
      case 'dark_circle_v2':
      case 'dark_circle':
        return isGood
            ? 'Under-eye area is bright and well rested.'
            : 'Prioritize restorative sleep and caffeine or peptide eye creams.';
      case 'eye_bag':
        return isGood
            ? 'Under-eye contour is smooth with minimal swelling.'
            : 'Use cool compresses and lymphatic under-eye drainage.';
      case 'tear_trough':
        return isGood
            ? 'Tear trough region is well supported and hydrated.'
            : 'Keep the delicate under-eye zone deeply nourished with rich emollients.';
      case 'droopy_upper_eyelid':
        return isGood
            ? 'Upper eyelid area shows great firmness.'
            : 'Gentle upward pressure and firming peptide eye care support firmness.';
      case 'droopy_lower_eyelid':
        return isGood
            ? 'Lower eyelid resilience is well preserved.'
            : 'Hydrate gently without pulling the delicate orbital skin.';
      case 'age_spot':
        return isGood
            ? 'Skin tone is uniform with minimal pigmentation.'
            : 'Daily broad-spectrum SPF is your best ally against pigmentation.';
      default:
        return isGood
            ? 'Skin health is well maintained.'
            : 'Nourish gently with barrier-supporting hydration.';
    }
  }

  @override
  List<Object?> get props => [
    id,
    displayName,
    uiScore,
    rawScore,
    maskUrls,
    customAdvice,
  ];
}
