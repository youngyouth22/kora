import 'dart:typed_data';

import 'package:equatable/equatable.dart';

/// Pure Dart abstraction of an incoming camera frame for face detection.
class CameraFrameInput extends Equatable {
  /// Creates a [CameraFrameInput].
  const CameraFrameInput({
    required this.planeBytes,
    required this.bytesPerRow,
    required this.width,
    required this.height,
    required this.sensorOrientation,
    required this.isFrontCamera,
    this.rawFormat,
  });

  /// Raw bytes for each image plane (e.g. Y, U, V or BGRA).
  final List<Uint8List> planeBytes;

  /// Row stride in bytes for each plane.
  final List<int> bytesPerRow;

  /// Sensor width of the frame.
  final int width;

  /// Sensor height of the frame.
  final int height;

  /// Sensor clockwise orientation degrees (0, 90, 180, 270).
  final int sensorOrientation;

  /// True if captured from the front-facing camera.
  final bool isFrontCamera;

  /// Raw image format indicator (e.g. Android ImageFormat or iOS
  /// four-char-code).
  final int? rawFormat;

  @override
  List<Object?> get props => [
    planeBytes,
    bytesPerRow,
    width,
    height,
    sensorOrientation,
    isFrontCamera,
    rawFormat,
  ];
}
