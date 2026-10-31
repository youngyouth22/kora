import 'package:equatable/equatable.dart';

/// Pure domain entity mirroring `public.checkins` from the Supabase migration
/// (`20261012000000_skinproof_init.sql`).
class SkinCheckin extends Equatable {
  /// Creates a [SkinCheckin].
  const SkinCheckin({
    required this.id,
    required this.userId,
    required this.checkinDate,
    required this.skinFeel,
    required this.createdAt,
    this.scanId,
    this.newProducts = false,
    this.note,
  }) : assert(
         skinFeel >= 1 && skinFeel <= 3,
         'skin_feel must be between 1 and 3 (SQL check constraint)',
       );

  /// Unique UUID.
  final String id;

  /// User UUID.
  final String userId;

  /// Optional linked scan UUID.
  final String? scanId;

  /// ISO date string (`YYYY-MM-DD`).
  final String checkinDate;

  /// Skin feel rating (`1` = worse, `2` = same, `3` = better).
  final int skinFeel;

  /// Whether the user introduced any new skincare product today.
  final bool newProducts;

  /// Optional personal note for the day.
  final String? note;

  /// Creation timestamp.
  final DateTime createdAt;

  /// Human-readable label for [skinFeel].
  String get skinFeelLabel {
    switch (skinFeel) {
      case 1:
        return 'More reactive / dry';
      case 2:
        return 'Calm & steady';
      case 3:
      default:
        return 'Hydrated & radiant';
    }
  }

  @override
  List<Object?> get props => [
    id,
    userId,
    scanId,
    checkinDate,
    skinFeel,
    newProducts,
    note,
    createdAt,
  ];
}
