import 'package:equatable/equatable.dart';

/// Pure domain entity representing a skincare experiment (e.g. testing an
/// active ingredient).
class SkincareExperiment extends Equatable {
  /// Creates a [SkincareExperiment].
  const SkincareExperiment({
    required this.id,
    required this.userId,
    required this.title,
    required this.targets,
    required this.startedAt,
    required this.startedOn,
    required this.createdAt,
    required this.updatedAt,
    this.itemId,
    this.plannedDays = 42,
    this.endedAt,
    this.status = 'active',
    this.verdict,
    this.adherence,
    this.baselineScanId,
    this.followupScanId,
  });

  /// Unique identifier (UUID).
  final String id;

  /// User identifier.
  final String userId;

  /// Optional routine product item linked to this experiment.
  final String? itemId;

  /// Experiment title.
  final String title;

  /// Targeted skin concern keys (1..2).
  final List<String> targets;

  /// Planned tracking days (14..180).
  final int plannedDays;

  /// Started timestamp.
  final DateTime startedAt;

  /// Started ISO date (YYYY-MM-DD).
  final String startedOn;

  /// Ended timestamp if stopped or completed.
  final DateTime? endedAt;

  /// Status: active, paused, completed, stopped.
  final String status;

  /// AI / statistical verdict summary text.
  final String? verdict;

  /// Adherence rate (0.000 to 1.000).
  final double? adherence;

  /// Linked baseline scan identifier.
  final String? baselineScanId;

  /// Linked followup scan identifier.
  final String? followupScanId;

  /// Creation timestamp.
  final DateTime createdAt;

  /// Last updated timestamp.
  final DateTime updatedAt;

  @override
  List<Object?> get props => [
    id,
    userId,
    itemId,
    title,
    targets,
    plannedDays,
    startedAt,
    startedOn,
    endedAt,
    status,
    verdict,
    adherence,
    baselineScanId,
    followupScanId,
    createdAt,
    updatedAt,
  ];
}
