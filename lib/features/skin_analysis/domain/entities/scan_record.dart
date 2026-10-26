import 'package:equatable/equatable.dart';

/// Pure domain entity representing a historical skin scan record.
class ScanRecord extends Equatable {
  /// Creates a [ScanRecord].
  const ScanRecord({
    required this.id,
    required this.userId,
    required this.createdAt,
    this.status = 'done',
    this.mode = 'SD',
    this.overallScore,
    this.skinAge,
    this.photoPath,
    this.concerns = const [],
    this.completedAt,
  });

  /// Unique scan identifier (UUID).
  final String id;

  /// User identifier.
  final String userId;

  /// Processing status: created, uploading, processing, done, failed.
  final String status;

  /// SD or HD.
  final String mode;

  /// Overall skin composite score (0..100).
  final double? overallScore;

  /// Biological skin age estimate.
  final int? skinAge;

  /// Local or remote photo path.
  final String? photoPath;

  /// Individual concern metric breakdown.
  final List<ScanConcernRecord> concerns;

  /// Creation timestamp.
  final DateTime createdAt;

  /// Completion timestamp.
  final DateTime? completedAt;

  @override
  List<Object?> get props => [
    id,
    userId,
    status,
    mode,
    overallScore,
    skinAge,
    photoPath,
    concerns,
    createdAt,
    completedAt,
  ];
}

/// Pure domain entity representing an individual concern score within a scan.
class ScanConcernRecord extends Equatable {
  /// Creates a [ScanConcernRecord].
  const ScanConcernRecord({
    required this.id,
    required this.scanId,
    required this.userId,
    required this.concern,
    required this.rawScore,
    this.zone,
    this.uiScore,
    this.maskPath,
  });

  /// Unique identifier (UUID).
  final String id;

  /// Associated scan identifier.
  final String scanId;

  /// User identifier.
  final String userId;

  /// Concern metric key (e.g. pores, spots, wrinkles, texture).
  final String concern;

  /// Optional facial zone (e.g. forehead, nose, left_cheek).
  final String? zone;

  /// Clinical raw score (0..100).
  final double rawScore;

  /// Display cosmetic score.
  final double? uiScore;

  /// Optional segmentation mask path.
  final String? maskPath;

  @override
  List<Object?> get props => [
    id,
    scanId,
    userId,
    concern,
    zone,
    rawScore,
    uiScore,
    maskPath,
  ];
}
