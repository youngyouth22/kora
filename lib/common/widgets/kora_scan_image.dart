// ignore_for_file: document_ignores, lines_longer_than_80_chars

import 'dart:io';

import 'package:flutter/material.dart';
import 'package:kora/common/app_colors.dart';
import 'package:kora/common/image_resources.dart';
import 'package:kora/core/network/api_endpoints.dart';

/// Universal, robust skin scan image viewer.
///
/// Resolves images seamlessly from:
/// 1. Remote HTTP/HTTPS URLs (YouCam, Cloud, signed URLs)
/// 2. Local device files (camera capture, isolate-preprocessed HD cache)
/// 3. Flutter asset bundle paths (`assets/...`)
/// 4. Supabase storage keys (`scan-photos/...`, `scan-masks/...`)
/// 5. High-resolution fallback asset portraits (`onboardingScanWeek1`, `week3`, `week6`)
///
/// Also provides an optional calibrated facial zone mesh overlay for
/// "Detected Zones" mode.
class KoraScanImage extends StatelessWidget {
  /// Creates a [KoraScanImage].
  const KoraScanImage({
    this.photoPath,
    this.scanId,
    this.fallbackAsset,
    this.width,
    this.height,
    this.fit = BoxFit.cover,
    this.borderRadius,
    this.showMeshOverlay = false,
    this.zoneHighlight,
    this.semanticLabel,
    super.key,
  });

  /// The raw path or URL. Can be local path, asset, remote URL, or storage key.
  final String? photoPath;

  /// Optional scan identifier used to pick a contextual fallback asset.
  final String? scanId;

  /// Explicit fallback asset to use if [photoPath] is empty or fails.
  final String? fallbackAsset;

  /// Width constraint.
  final double? width;

  /// Height constraint.
  final double? height;

  /// Image box fit (defaults to [BoxFit.cover]).
  final BoxFit fit;

  /// Optional clipping border radius.
  final BorderRadius? borderRadius;

  /// Whether to render calibrated facial zone geometry overlay.
  final bool showMeshOverlay;

  /// Specific facial zone key to highlight (e.g. `'forehead'`, `'left_cheek'`).
  final String? zoneHighlight;

  /// Accessibility description.
  final String? semanticLabel;

  /// Path to the most recently captured real skin photo on this device.
  static String? latestCapturedPhotoPath;

  /// Selects a deterministic portrait asset based on [scanId].
  static String resolveDefaultFallbackAsset(String? id) {
    if (id == null || id.isEmpty) {
      return ImageResources.onboardingScanWeek1;
    }
    final lower = id.toLowerCase();
    if (lower.contains('scan_1') ||
        lower.contains('scan_2') ||
        lower.contains('base')) {
      return ImageResources.onboardingScanWeek1;
    }
    if (lower.contains('scan_3') ||
        lower.contains('scan_4') ||
        lower.contains('scan_5')) {
      return ImageResources.onboardingScanWeek3;
    }
    return ImageResources.onboardingScanWeek6;
  }

  @override
  Widget build(BuildContext context) {
    final effectiveFallback =
        fallbackAsset ?? resolveDefaultFallbackAsset(scanId);

    var imageWidget = _buildBaseImage(effectiveFallback);

    if (showMeshOverlay) {
      imageWidget = Stack(
        fit: StackFit.passthrough,
        children: [
          imageWidget,
          Positioned.fill(
            child: CustomPaint(
              painter: _FacialMeshPainter(
                highlightZone: zoneHighlight,
                meshColor: AppColors.primary400,
                accentColor: AppColors.primary600,
              ),
            ),
          ),
        ],
      );
    }

    if (borderRadius != null) {
      imageWidget = ClipRRect(
        borderRadius: borderRadius!,
        child: imageWidget,
      );
    }

    return Semantics(
      label: semanticLabel ?? 'Skin scan image',
      image: true,
      child: SizedBox(
        width: width,
        height: height,
        child: imageWidget,
      ),
    );
  }

  Widget _buildBaseImage(String fallbackAssetPath) {
    final raw = photoPath?.trim();

    // 1. Check direct local file path first (priority: user's real camera photo)
    if (raw != null && raw.isNotEmpty) {
      final cleanPath = raw.startsWith('file://') ? raw.substring(7) : raw;
      try {
        final decoded = Uri.decodeFull(cleanPath);
        for (final p in [cleanPath, decoded, raw]) {
          final file = File(p);
          if (file.existsSync()) {
            return Image.file(
              file,
              width: width,
              height: height,
              fit: fit,
              errorBuilder: (_, _, _) => _buildAssetImage(fallbackAssetPath),
            );
          }
        }
      } on Object {
        // Ignore file system inspection failures
      }

      // 2. Direct web URL
      if (raw.startsWith('http://') || raw.startsWith('https://')) {
        return Image.network(
          raw,
          width: width,
          height: height,
          fit: fit,
          errorBuilder: (_, _, _) => _buildAssetImage(fallbackAssetPath),
          loadingBuilder: (context, child, loadingProgress) {
            if (loadingProgress == null) return child;
            return _buildLoadingPlaceholder();
          },
        );
      }

      // 3. Direct Flutter Asset
      if (raw.startsWith('assets/')) {
        return _buildAssetImage(raw, fallbackAsset: fallbackAssetPath);
      }

      // 4. Supabase Storage Path (e.g. 'scan-photos/user_1/scan_1.jpg')
      if (raw.startsWith('scan-photos/') || raw.startsWith('scan-masks/')) {
        final supabaseUrl =
            '${ApiEndpoints.supabaseUrl}/storage/v1/object/public/$raw';
        return Image.network(
          supabaseUrl,
          width: width,
          height: height,
          fit: fit,
          errorBuilder: (_, _, _) => _buildAssetImage(fallbackAssetPath),
          loadingBuilder: (context, child, loadingProgress) {
            if (loadingProgress == null) return child;
            return _buildLoadingPlaceholder();
          },
        );
      }
    }

    // Default to the contextual fallback asset or real user photo if available
    return _buildAssetImage(fallbackAssetPath);
  }

  Widget _buildAssetImage(String assetPath, {String? fallbackAsset}) {
    // Priority: If the user has taken a real photo on this device, use it!
    final realPhoto = latestCapturedPhotoPath;
    if (realPhoto != null && realPhoto.isNotEmpty) {
      try {
        final file = File(realPhoto);
        if (file.existsSync()) {
          return Image.file(
            file,
            width: width,
            height: height,
            fit: fit,
            errorBuilder: (_, _, _) =>
                _buildRawAsset(assetPath, fallbackAsset: fallbackAsset),
          );
        }
      } on Object {
        // Fallback gracefully to default asset if unreadable.
      }
    }

    return _buildRawAsset(assetPath, fallbackAsset: fallbackAsset);
  }

  Widget _buildRawAsset(String assetPath, {String? fallbackAsset}) {
    return Image.asset(
      assetPath,
      width: width,
      height: height,
      fit: fit,
      errorBuilder: (context, error, stackTrace) {
        if (fallbackAsset != null && fallbackAsset != assetPath) {
          return Image.asset(
            fallbackAsset,
            width: width,
            height: height,
            fit: fit,
            errorBuilder: (_, _, _) => _buildFallbackContainer(),
          );
        }
        return _buildFallbackContainer();
      },
    );
  }

  Widget _buildLoadingPlaceholder() {
    return Container(
      width: width,
      height: height,
      color: AppColors.neutral300,
      alignment: Alignment.center,
      child: const SizedBox(
        width: 24,
        height: 24,
        child: CircularProgressIndicator(
          strokeWidth: 2,
          color: AppColors.primary600,
        ),
      ),
    );
  }

  Widget _buildFallbackContainer() {
    return Container(
      width: width,
      height: height,
      color: AppColors.neutral300,
      alignment: Alignment.center,
      child: const Icon(
        Icons.face_retouching_natural_rounded,
        size: 32,
        color: AppColors.primary700,
      ),
    );
  }
}

/// Custom painter rendering a calibrated HD facial mesh overlay.
class _FacialMeshPainter extends CustomPainter {
  const _FacialMeshPainter({
    required this.meshColor,
    required this.accentColor,
    this.highlightZone,
  });

  final Color meshColor;
  final Color accentColor;
  final String? highlightZone;

  @override
  void paint(Canvas canvas, Size size) {
    final w = size.width;
    final h = size.height;

    final linePaint = Paint()
      ..color = meshColor.withValues(alpha: 0.45)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.2;

    final highlightPaint = Paint()
      ..color = accentColor.withValues(alpha: 0.85)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2.0;

    final fillHighlightPaint = Paint()
      ..color = accentColor.withValues(alpha: 0.16)
      ..style = PaintingStyle.fill;

    final dotPaint = Paint()
      ..color = AppColors.grey50
      ..style = PaintingStyle.fill;

    final dotStroke = Paint()
      ..color = accentColor
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.5;

    // Standard normalized facial landmark regions:
    // Forehead / T-Zone
    final foreheadRect = Rect.fromCenter(
      center: Offset(w * 0.50, h * 0.28),
      width: w * 0.46,
      height: h * 0.16,
    );

    // Left Cheek (viewer's left = user's right)
    final leftCheekRect = Rect.fromCenter(
      center: Offset(w * 0.32, h * 0.55),
      width: w * 0.22,
      height: h * 0.20,
    );

    // Right Cheek (viewer's right = user's left)
    final rightCheekRect = Rect.fromCenter(
      center: Offset(w * 0.68, h * 0.55),
      width: w * 0.22,
      height: h * 0.20,
    );

    // Nose Bridge
    final noseRect = Rect.fromCenter(
      center: Offset(w * 0.50, h * 0.52),
      width: w * 0.16,
      height: h * 0.22,
    );

    // Chin / Jawline
    final chinRect = Rect.fromCenter(
      center: Offset(w * 0.50, h * 0.78),
      width: w * 0.30,
      height: h * 0.12,
    );

    void drawZone(Rect rect, String key) {
      final isHighlighted =
          highlightZone == null ||
          highlightZone!.toLowerCase().contains(key.toLowerCase());
      final paintToUse = isHighlighted ? highlightPaint : linePaint;

      final rrect = RRect.fromRectAndRadius(rect, const Radius.circular(10));
      if (isHighlighted) {
        canvas.drawRRect(rrect, fillHighlightPaint);
      }
      const markerLen = 6.0;
      canvas
        ..drawRRect(rrect, paintToUse)
        ..drawLine(
          Offset(rect.left, rect.top),
          Offset(rect.left + markerLen, rect.top),
          paintToUse,
        )
        ..drawLine(
          Offset(rect.left, rect.top),
          Offset(rect.left, rect.top + markerLen),
          paintToUse,
        )
        ..drawLine(
          Offset(rect.right, rect.bottom),
          Offset(rect.right - markerLen, rect.bottom),
          paintToUse,
        )
        ..drawLine(
          Offset(rect.right, rect.bottom),
          Offset(rect.right, rect.bottom - markerLen),
          paintToUse,
        );
    }

    drawZone(foreheadRect, 'forehead');
    drawZone(leftCheekRect, 'left_cheek');
    drawZone(rightCheekRect, 'right_cheek');
    drawZone(noseRect, 'nose');
    drawZone(chinRect, 'chin');

    // Central alignment axis
    final axisPath = Path()
      ..moveTo(w * 0.50, h * 0.12)
      ..lineTo(w * 0.50, h * 0.88);
    canvas
      ..drawPath(axisPath, linePaint..strokeWidth = 0.8)
      ..drawLine(
        Offset(w * 0.24, h * 0.42),
        Offset(w * 0.76, h * 0.42),
        linePaint,
      );

    // Center focal points
    final focalPoints = [
      Offset(w * 0.50, h * 0.28),
      Offset(w * 0.32, h * 0.55),
      Offset(w * 0.68, h * 0.55),
      Offset(w * 0.50, h * 0.52),
      Offset(w * 0.50, h * 0.78),
    ];

    for (final p in focalPoints) {
      canvas
        ..drawCircle(p, 3.5, dotPaint)
        ..drawCircle(p, 3.5, dotStroke);
    }
  }

  @override
  bool shouldRepaint(covariant _FacialMeshPainter oldDelegate) {
    return oldDelegate.highlightZone != highlightZone ||
        oldDelegate.meshColor != meshColor ||
        oldDelegate.accentColor != accentColor;
  }
}
