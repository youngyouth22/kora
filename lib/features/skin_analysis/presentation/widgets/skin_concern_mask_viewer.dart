// ignore_for_file: document_ignores, lines_longer_than_80_chars

import 'package:flutter/material.dart';
import 'package:kora/common/app_colors.dart';
import 'package:kora/common/app_typography.dart';

/// Modal dialog allowing inspection of a YouCam detection mask with pinch-to-zoom.
class SkinConcernMaskViewer extends StatelessWidget {
  /// Creates a [SkinConcernMaskViewer].
  const SkinConcernMaskViewer({
    required this.imageUrl,
    required this.concernTitle,
    this.concernId = '',
    this.scoreText,
    super.key,
  });

  /// The URL of the YouCam detection mask image.
  final String imageUrl;

  /// The title of the concern.
  final String concernTitle;

  /// Canonical concern ID (e.g. 'pore', 'redness').
  final String concernId;

  /// Optional score text (e.g. '58/100').
  final String? scoreText;

  /// Shows the mask viewer as a dialog.
  static Future<void> show(
    BuildContext context, {
    required String imageUrl,
    required String concernTitle,
    String concernId = '',
    String? scoreText,
  }) {
    return showDialog<void>(
      context: context,
      barrierColor: AppGreyColors.shade1050.withValues(alpha: 0.88),
      builder: (context) => SkinConcernMaskViewer(
        imageUrl: imageUrl,
        concernTitle: concernTitle,
        concernId: concernId,
        scoreText: scoreText,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final colorDesc = YouCamConcernColorHelper.getColorDescription(concernId);
    final concernColor = YouCamConcernColorHelper.getColor(concernId);

    return Dialog(
      backgroundColor: Colors.transparent,
      insetPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 24),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Row(
                      children: [
                        Container(
                          width: 10,
                          height: 10,
                          decoration: BoxDecoration(
                            color: concernColor,
                            shape: BoxShape.circle,
                          ),
                        ),
                        const SizedBox(width: 8),
                        Flexible(
                          child: Text(
                            concernTitle,
                            style: AppTypography.h5Bold.copyWith(
                              color: AppGreyColors.white,
                            ),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 4),
                    Text(
                      colorDesc,
                      style: AppTypography.bodyXsMedium.copyWith(
                        color: AppGreyColors.shade300,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    if (scoreText != null)
                      Text(
                        'Score: $scoreText · Pinch to zoom',
                        style: AppTypography.bodySRegular.copyWith(
                          color: AppGreyColors.shade400,
                        ),
                      ),
                  ],
                ),
              ),
              IconButton(
                onPressed: () => Navigator.of(context).pop(),
                icon: const Icon(
                  Icons.close,
                  color: AppGreyColors.white,
                  size: 24,
                ),
                tooltip: 'Close image',
              ),
            ],
          ),
          const SizedBox(height: 16),
          Flexible(
            child: ClipRRect(
              borderRadius: BorderRadius.circular(16),
              child: Container(
                decoration: BoxDecoration(
                  color: AppGreyColors.shade1000,
                  border: Border.all(
                    color: AppGreyColors.shade800,
                  ),
                ),
                child: InteractiveViewer(
                  maxScale: 4,
                  child: Image.network(
                    imageUrl,
                    fit: BoxFit.contain,
                    loadingBuilder: (context, child, loadingProgress) {
                      if (loadingProgress == null) return child;
                      return const Center(
                        child: Padding(
                          padding: EdgeInsets.all(40),
                          child: CircularProgressIndicator(
                            strokeWidth: 2,
                            color: AppPrimaryColors.shade400,
                          ),
                        ),
                      );
                    },
                    errorBuilder: (context, error, stackTrace) {
                      return _buildFallbackVisualizer(
                        context,
                        concernColor,
                        colorDesc,
                      );
                    },
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildFallbackVisualizer(
    BuildContext context,
    Color concernColor,
    String colorDesc,
  ) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 36),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 72,
            height: 72,
            decoration: BoxDecoration(
              color: concernColor.withValues(alpha: 0.15),
              shape: BoxShape.circle,
              border: Border.all(color: concernColor, width: 2),
            ),
            child: Icon(
              Icons.center_focus_strong,
              color: concernColor,
              size: 36,
            ),
          ),
          const SizedBox(height: 16),
          Text(
            concernTitle,
            style: AppTypography.h6Bold.copyWith(
              color: AppGreyColors.white,
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 6),
          Text(
            colorDesc,
            style: AppTypography.bodySRegular.copyWith(
              color: AppGreyColors.shade300,
            ),
            textAlign: TextAlign.center,
          ),
          if (scoreText != null) ...[
            const SizedBox(height: 12),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
              decoration: BoxDecoration(
                color: AppGreyColors.shade900,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: AppGreyColors.shade700),
              ),
              child: Text(
                'Raw Score: $scoreText',
                style: AppTypography.bodySSemiBold.copyWith(
                  color: AppGreyColors.white,
                ),
              ),
            ),
          ],
        ],
      ),
    );
  }
}

/// Helper mapping YouCam detection concerns to official chromatic scales.
abstract final class YouCamConcernColorHelper {
  /// Resolves the prominent brand color for a YouCam concern.
  static Color getColor(String id) {
    switch (id.toLowerCase()) {
      case 'redness':
      case 'acne':
        return AppErrorColors.shade500;
      case 'pore':
      case 'firmness':
        return AppPrimaryColors.shade500;
      case 'texture':
      case 'wrinkle':
      case 'age_spot':
      case 'spot':
      case 'oiliness':
        return AppSecondaryColors.shade600;
      case 'dark_circle':
      case 'dark_circle_v2':
      case 'eye_bag':
      case 'tear_trough':
      case 'droopy_upper_eyelid':
      case 'droopy_lower_eyelid':
        return const Color(0xFF6B46C1);
      case 'moisture':
      case 'radiance':
      default:
        return AppPrimaryColors.shade600;
    }
  }

  /// Returns user-friendly description of the YouCam detection heatmap.
  static String getColorDescription(String id) {
    switch (id.toLowerCase()) {
      case 'redness':
        return 'Coral / Red Erythema Heatmap';
      case 'acne':
        return 'Ruby Active Blemish Mapping';
      case 'pore':
        return 'Cyan / Violet Micro-Pore Density';
      case 'texture':
        return 'Amber / Lime Micro-Relief Grid';
      case 'wrinkle':
        return 'Orange / Yellow Line Contour Analysis';
      case 'age_spot':
      case 'spot':
        return 'Bronze Melanin Pigmentation Map';
      case 'dark_circle':
      case 'dark_circle_v2':
        return 'Deep Indigo Infraorbital Band';
      case 'eye_bag':
        return 'Violet Lower Periorbital Volume Map';
      case 'tear_trough':
        return 'Cyan Nasojugal Groove Contour';
      case 'droopy_upper_eyelid':
        return 'Violet Palpebral Crease Vector';
      case 'droopy_lower_eyelid':
        return 'Purple Marginal Eyelid Tension Map';
      case 'firmness':
        return 'Teal Dermal Elastic Vector Map';
      case 'moisture':
        return 'Aqua Transepidermal Hydration Field';
      case 'oiliness':
        return 'Golden Sebum Concentration Map';
      case 'radiance':
        return 'Warm Amber Epidermal Luminosity Map';
      case 'skin_type':
      default:
        return 'Multi-Zone T-Zone vs U-Zone Chroma Map';
    }
  }
}
