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
    this.scoreText,
    super.key,
  });

  /// The URL of the YouCam detection mask image.
  final String imageUrl;

  /// The title of the concern.
  final String concernTitle;

  /// Optional score text (e.g. '58/100').
  final String? scoreText;

  /// Shows the mask viewer as a dialog.
  static Future<void> show(
    BuildContext context, {
    required String imageUrl,
    required String concernTitle,
    String? scoreText,
  }) {
    return showDialog<void>(
      context: context,
      barrierColor: AppGreyColors.shade1050.withValues(alpha: 0.85),
      builder: (context) => SkinConcernMaskViewer(
        imageUrl: imageUrl,
        concernTitle: concernTitle,
        scoreText: scoreText,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
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
                    Text(
                      concernTitle,
                      style: AppTypography.h5Bold.copyWith(
                        color: AppGreyColors.white,
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
              child: ColoredBox(
                color: AppGreyColors.shade1000,
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
                      return Padding(
                        padding: const EdgeInsets.all(40),
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            const Icon(
                              Icons.broken_image_outlined,
                              color: AppGreyColors.shade500,
                              size: 48,
                            ),
                            const SizedBox(height: 12),
                            Text(
                              'Unable to load mask preview',
                              style: AppTypography.bodySRegular.copyWith(
                                color: AppGreyColors.shade400,
                              ),
                            ),
                          ],
                        ),
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
}
