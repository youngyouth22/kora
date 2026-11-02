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

  /// Top 3 concerns with the lowest raw_score (areas that need attention),
  /// sorted from lowest to highest score.
  List<SkinConcern> get areasNeedingAttention {
    final sorted = List<SkinConcern>.from(allConcerns)
      ..sort((a, b) => a.rawScore.compareTo(b.rawScore));
    return sorted.take(3).toList();
  }

  /// Top 3 concerns with the highest raw_score (skin strengths),
  /// sorted from highest to lowest score.
  List<SkinConcern> get strengths {
    final sorted = List<SkinConcern>.from(allConcerns)
      ..sort((a, b) => b.rawScore.compareTo(a.rawScore));
    return sorted.take(3).toList();
  }

  /// Creates a copy of this result with specified fields replaced.
  SkinAnalysisResult copyWith({
    double? overallScore,
    int? skinAge,
    SkinTypeInfo? skinType,
    String? resizedImageUrl,
    List<SkinConcern>? allConcerns,
    SkinReport? report,
  }) {
    return SkinAnalysisResult(
      overallScore: overallScore ?? this.overallScore,
      skinAge: skinAge ?? this.skinAge,
      skinType: skinType ?? this.skinType,
      resizedImageUrl: resizedImageUrl ?? this.resizedImageUrl,
      allConcerns: allConcerns ?? this.allConcerns,
      report: report ?? this.report,
    );
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
