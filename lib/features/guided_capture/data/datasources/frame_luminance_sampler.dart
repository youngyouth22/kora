import 'dart:typed_data';

/// Luminance statistics of the central region of a camera frame.
class LuminanceStats {
  /// Creates a [LuminanceStats].
  const LuminanceStats({required this.mean, required this.clippedRatio});

  /// Neutral fallback used when the frame cannot be sampled.
  static const LuminanceStats neutral = LuminanceStats(
    mean: 0.5,
    clippedRatio: 0,
  );

  /// Mean luminance [0.0 to 1.0].
  final double mean;

  /// Share [0.0 to 1.0] of blown-out (near-white) pixels.
  final double clippedRatio;
}

/// Pixel layout of the luminance source plane.
enum LumaLayout {
  /// One byte per pixel holding luma (Y plane of NV21 / YUV420).
  yPlane,

  /// Four bytes per pixel in B, G, R, A order (iOS BGRA8888).
  bgra,
}

/// Samples the luminance of the central region of a camera frame.
///
/// Only the luma rows are read (NV21 buffers also carry chroma bytes, which
/// sit around 128 and would bias the mean towards mid-grey) and row padding
/// is skipped by honoring the row stride.
class FrameLuminanceSampler {
  /// Creates a [FrameLuminanceSampler].
  const FrameLuminanceSampler();

  /// Fraction of the frame (per axis) kept around the center.
  static const double centralRegionFraction = 0.5;

  /// Pixel step between samples on both axes.
  static const int sampleStep = 8;

  /// 8-bit luma value from which a pixel is considered blown out.
  static const int clippingThreshold = 245;

  /// Computes [LuminanceStats] for a frame plane.
  LuminanceStats sample({
    required Uint8List bytes,
    required int width,
    required int height,
    required int bytesPerRow,
    required LumaLayout layout,
  }) {
    if (width <= 0 || height <= 0 || bytes.isEmpty) {
      return LuminanceStats.neutral;
    }

    final bytesPerPixel = layout == LumaLayout.bgra ? 4 : 1;
    final stride = bytesPerRow > 0 ? bytesPerRow : width * bytesPerPixel;
    final marginX = (width * (1 - centralRegionFraction) / 2).round();
    final marginY = (height * (1 - centralRegionFraction) / 2).round();

    var sum = 0;
    var clipped = 0;
    var count = 0;

    for (var y = marginY; y < height - marginY; y += sampleStep) {
      final rowStart = y * stride;
      for (var x = marginX; x < width - marginX; x += sampleStep) {
        final index = rowStart + x * bytesPerPixel;
        if (index + bytesPerPixel > bytes.length) break;

        final int luma;
        if (layout == LumaLayout.bgra) {
          final b = bytes[index];
          final g = bytes[index + 1];
          final r = bytes[index + 2];
          luma = (r * 299 + g * 587 + b * 114) ~/ 1000;
        } else {
          luma = bytes[index];
        }

        sum += luma;
        if (luma >= clippingThreshold) clipped++;
        count++;
      }
    }

    if (count == 0) return LuminanceStats.neutral;
    return LuminanceStats(
      mean: sum / count / 255,
      clippedRatio: clipped / count,
    );
  }
}
