import 'package:equatable/equatable.dart';

/// Pure Dart bounding box entity representing coordinate bounds.
class ScannerBoundingBox extends Equatable {
  /// Creates a [ScannerBoundingBox].
  const ScannerBoundingBox({
    required this.left,
    required this.top,
    required this.right,
    required this.bottom,
  });

  /// Left coordinate.
  final double left;

  /// Top coordinate.
  final double top;

  /// Right coordinate.
  final double right;

  /// Bottom coordinate.
  final double bottom;

  /// Width of the bounding box.
  double get width => right - left;

  /// Height of the bounding box.
  double get height => bottom - top;

  /// Center X coordinate.
  double get centerX => left + (width / 2);

  /// Center Y coordinate.
  double get centerY => top + (height / 2);

  /// Returns true if the given point is inside this bounding box.
  bool contains(double x, double y) =>
      x >= left && x <= right && y >= top && y <= bottom;

  @override
  List<Object?> get props => [left, top, right, bottom];
}
