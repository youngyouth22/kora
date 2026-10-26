import 'package:equatable/equatable.dart';

/// Represents skin type analysis including whole face and zone-specific
/// breakdowns.
class SkinTypeInfo extends Equatable {
  /// Creates a [SkinTypeInfo].
  const SkinTypeInfo({
    required this.overallType,
    this.tZoneType,
    this.uZoneType,
    this.maskUrls = const [],
  });

  /// Overall skin category (e.g. 'Oily', 'Dry', 'Combination', 'Normal').
  final String overallType;

  /// Specific skin type evaluated on the T-Zone (forehead & nose).
  final String? tZoneType;

  /// Specific skin type evaluated on the U-Zone (cheeks & chin).
  final String? uZoneType;

  /// Mask URLs visualizing the sebum distribution or skin zones.
  final List<String> maskUrls;

  @override
  List<Object?> get props => [overallType, tZoneType, uZoneType, maskUrls];
}
