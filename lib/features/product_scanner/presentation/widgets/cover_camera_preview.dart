import 'package:camera/camera.dart';
import 'package:flutter/material.dart';

/// Full-bleed camera preview rendered with [BoxFit.cover].
///
/// The geometry in `ScannerLayout.mapNormalizedToScreen` assumes exactly
/// this fitting, so detected boxes line up with what the user sees.
class CoverCameraPreview extends StatelessWidget {
  /// Creates a [CoverCameraPreview].
  const CoverCameraPreview({required this.controller, super.key});

  /// Initialized camera controller.
  final CameraController controller;

  /// Upright (portrait) preview width / height.
  static double uprightAspectRatio(CameraController controller) {
    final ratio = controller.value.aspectRatio;
    return ratio == 0 ? 0 : 1 / ratio;
  }

  @override
  Widget build(BuildContext context) {
    final previewSize = controller.value.previewSize;
    if (previewSize == null) return CameraPreview(controller);

    return ClipRect(
      child: SizedBox.expand(
        child: FittedBox(
          fit: BoxFit.cover,
          child: SizedBox(
            // previewSize is reported in landscape; swap for portrait.
            width: previewSize.height,
            height: previewSize.width,
            child: CameraPreview(controller),
          ),
        ),
      ),
    );
  }
}
