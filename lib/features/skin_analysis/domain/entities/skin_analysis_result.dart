import 'package:equatable/equatable.dart';
import 'package:kora/features/skin_analysis/domain/entities/skin_concern.dart';
import 'package:kora/features/skin_analysis/domain/entities/skin_report.dart';
import 'package:kora/features/skin_analysis/domain/entities/skin_type_info.dart';

/// Aggregated report from a full YouCam skin scan.
class SkinAnalysisResult extends Equatable {
  /// Creates a [SkinAnalysisResult].
  const SkinAnalysisResult({
    required this.overallScore,
    required this.allConcerns,
    this.skinAge,
    this.skinType,
    this.resizedImageUrl,
    this.report,
  });

  /// Overall composite score (0 to 100).
  final double overallScore;

  /// Estimated biological skin age (if available).
  final int? skinAge;

  /// Skin type evaluation (e.g. Oily, Dry, Combination).
  final SkinTypeInfo? skinType;

  /// Preprocessed/resized face image URL.
  final String? resizedImageUrl;

  /// All individual concerns evaluated.
  final List<SkinConcern> allConcerns;

  /// Validated AI Skin Analyst report (if generated).
  final SkinReport? report;

  /// Top 3 concerns with the lowest ui_score (areas that need attention),
  /// sorted from lowest to highest score.
  List<SkinConcern> get areasNeedingAttention {
    final sorted = List<SkinConcern>.from(allConcerns)
      ..sort((a, b) => a.uiScore.compareTo(b.uiScore));
    return sorted.take(3).toList();
  }

  /// Top 3 concerns with the highest ui_score (skin strengths),
  /// sorted from highest to lowest score.
  List<SkinConcern> get strengths {
    final sorted = List<SkinConcern>.from(allConcerns)
      ..sort((a, b) => b.uiScore.compareTo(a.uiScore));
    return sorted.take(3).toList();
  }

  @override
  List<Object?> get props => [
    overallScore,
    skinAge,
    skinType,
    resizedImageUrl,
    allConcerns,
    report,
  ];
}
