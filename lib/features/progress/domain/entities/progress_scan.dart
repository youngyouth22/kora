import 'package:equatable/equatable.dart';

/// Represents a reference skin concern type (`public.concern_types` in SQL).
///
/// Key matches YouCam Skin Analysis concern names (`acne`, `redness`,
/// `age_spot`, `texture`, `pore`, `moisture`, `wrinkle`, `firmness`,
/// `radiance`, `oiliness`, `dark_circle_v2`, `eye_bag`).
class ProgressConcernType extends Equatable {
  /// Creates a [ProgressConcernType].
  const ProgressConcernType({
    required this.key,
    required this.label,
    required this.isHeadline,
    required this.sortOrder,
    required this.description,
    required this.recommendedActives,
    required this.relatedVideoId,
    required this.relatedVideoTitle,
  });

  /// Canonical SQL key (`concern_types.key`).
  final String key;

  /// Human-readable display label (`concern_types.label`).
  final String label;

  /// Whether this is one of the 6 primary headline concerns
  /// (`concern_types.is_headline`).
  final bool isHeadline;

  /// Sort order (`concern_types.sort_order`).
  final int sortOrder;

  /// Educational non-medical explanation of what this score reflects.
  final String description;

  /// Evidence-based cosmetic active recommendations for this concern.
  final List<({String name, String role})> recommendedActives;

  /// Linked educational video ID (`catalog_videos.id`).
  final String relatedVideoId;

  /// Linked educational video title.
  final String relatedVideoTitle;

  @override
  List<Object?> get props => [
    key,
    label,
    isHeadline,
    sortOrder,
    description,
    recommendedActives,
    relatedVideoId,
    relatedVideoTitle,
  ];
}

/// Represents a single concern measurement inside a scan
/// (`public.scan_concerns` in SQL).
///
/// Per Article 5, only [rawScore] is used for trends, comparisons, and UI
/// display; `ui_score` is never shown.
class ProgressConcernScore extends Equatable {
  /// Creates a [ProgressConcernScore].
  const ProgressConcernScore({
    required this.id,
    required this.scanId,
    required this.userId,
    required this.concernKey,
    required this.rawScore,
    this.zone,
    this.uiScore,
    this.maskPath,
  });

  /// Unique row identifier (`scan_concerns.id`).
  final String id;

  /// Parent scan identifier (`scan_concerns.scan_id`).
  final String scanId;

  /// User identifier (`scan_concerns.user_id`).
  final String userId;

  /// Concern key (`scan_concerns.concern`, e.g., `'age_spot'`, `'redness'`).
  final String concernKey;

  /// Optional anatomical zone (`'forehead'`, `'nose'`, `'left_cheek'`,
  /// `'right_cheek'`, `'chin'`, or `null` for whole face).
  final String? zone;

  /// Real clinical precision score (`0.0` to `100.0`, higher is better).
  final double rawScore;

  /// Optional provider display score (stored for schema parity, never shown).
  final double? uiScore;

  /// Optional storage path in `scan-masks`.
  final String? maskPath;

  @override
  List<Object?> get props => [
    id,
    scanId,
    userId,
    concernKey,
    zone,
    rawScore,
    uiScore,
    maskPath,
  ];
}

/// Represents a completed weekly skin scan (`public.scans` in SQL).
class ProgressScan extends Equatable {
  /// Creates a [ProgressScan].
  const ProgressScan({
    required this.id,
    required this.userId,
    required this.status,
    required this.mode,
    required this.overallScore,
    required this.skinAge,
    required this.qualityOk,
    required this.createdAt,
    required this.completedAt,
    required this.concerns,
    this.qualityFlags = const {},
    this.photoPath,
    this.isDemo = false,
    this.note,
    this.experimentRole,
  });

  /// Scan UUID (`scans.id`).
  final String id;

  /// User UUID (`scans.user_id`).
  final String userId;

  /// Scan status (`'created'`, `'uploading'`, `'processing'`, `'done'`,
  /// `'failed'`, `'canceled'`).
  final String status;

  /// Scan mode (`'SD'` or `'HD'`).
  final String mode;

  /// Overall precision score (`scans.overall_score`, average of `raw_score`).
  final double overallScore;

  /// Estimated skin age (`scans.skin_age`).
  final int skinAge;

  /// Lighting and positioning quality gate flag (`scans.quality_ok`).
  final bool qualityOk;

  /// Quality diagnostic metadata (`scans.quality_flags`).
  final Map<String, dynamic> qualityFlags;

  /// Optional storage path (`scans.photo_path`).
  final String? photoPath;

  /// Whether this scan belongs to the synthetic demo seed (`scans.is_demo`).
  final bool isDemo;

  /// Creation timestamp (`scans.created_at`).
  final DateTime createdAt;

  /// Completion timestamp (`scans.completed_at`).
  final DateTime completedAt;

  /// Whole-face and regional concern scores for this scan.
  final List<ProgressConcernScore> concerns;

  /// Contextual note or milestone label for the timeline.
  final String? note;

  /// Role in the active/completed experiment (`'baseline'` or `'followup'`).
  final String? experimentRole;

  /// Returns the whole-face [ProgressConcernScore] for [concernKey], or `null`.
  ProgressConcernScore? wholeFaceConcern(String concernKey) {
    final normalized = _normalizeConcernKey(concernKey);
    for (final item in concerns) {
      if (item.concernKey == normalized &&
          (item.zone == null || item.zone!.isEmpty || item.zone == 'whole')) {
        return item;
      }
    }
    return null;
  }

  /// Returns regional concern scores (`zone != null`) for [concernKey].
  List<ProgressConcernScore> regionalConcerns(String concernKey) {
    final normalized = _normalizeConcernKey(concernKey);
    return concerns
        .where(
          (item) =>
              item.concernKey == normalized &&
              item.zone != null &&
              item.zone!.isNotEmpty &&
              item.zone != 'whole',
        )
        .toList();
  }

  /// Returns all whole-face concern scores sorted by `rawScore` ascending.
  List<ProgressConcernScore> get wholeFaceConcerns {
    return concerns
        .where((c) => c.zone == null || c.zone!.isEmpty || c.zone == 'whole')
        .toList();
  }

  static String _normalizeConcernKey(String raw) {
    switch (raw.toLowerCase()) {
      case 'dark_spots':
      case 'spots':
        return 'age_spot';
      case 'pores':
        return 'pore';
      case 'hydration':
        return 'moisture';
      case 'wrinkles':
        return 'wrinkle';
      case 'dark_circles':
      case 'dark_circle':
        return 'dark_circle_v2';
      default:
        return raw.toLowerCase();
    }
  }

  @override
  List<Object?> get props => [
    id,
    userId,
    status,
    mode,
    overallScore,
    skinAge,
    qualityOk,
    qualityFlags,
    photoPath,
    isDemo,
    createdAt,
    completedAt,
    concerns,
    note,
    experimentRole,
  ];
}
