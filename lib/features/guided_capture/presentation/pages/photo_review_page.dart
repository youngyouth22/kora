import 'dart:async';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:go_router/go_router.dart';
import 'package:kora/common/app_colors.dart';
import 'package:kora/common/app_typography.dart';
import 'package:kora/common/widgets/primary_button.dart';
import 'package:kora/common/widgets/secondary_button.dart';
import 'package:kora/core/router/app_routes.dart';

/// Screen allowing the user to review their captured photo before proceeding
/// to skin analysis.
///
/// Features:
/// - Screen partitioned into ~80% top photo preview and ~20% bottom action bar.
/// - Pinch-to-zoom ([InteractiveViewer]) so the user can inspect skin texture,
///   lighting, and clarity up close.
/// - Two ergonomic 52dp action buttons: "Retake" and "Use this photo".
/// - Graceful fallback placeholder if the image file is missing or unreadable.
/// - Full accessibility semantics and design token adherence.
class PhotoReviewPage extends StatelessWidget {
  /// Creates a [PhotoReviewPage].
  const PhotoReviewPage({
    required this.imagePath,
    this.imageProvider,
    this.onRetake,
    this.onUsePhoto,
    super.key,
  });

  /// Path to the captured photo on disk.
  final String imagePath;

  /// Optional override image provider (e.g. for testing or memory images).
  final ImageProvider? imageProvider;

  /// Optional callback invoked when the user taps "Retake".
  /// Defaults to popping the current screen with [Navigator.maybePop].
  final VoidCallback? onRetake;

  /// Optional callback invoked when the user taps "Use this photo".
  /// Defaults to pushing [AppRoutes.scanAnalyzing] with [imagePath] as extra.
  final ValueChanged<String>? onUsePhoto;

  @override
  Widget build(BuildContext context) {
    return AnnotatedRegion(
      value: SystemUiOverlayStyle.light,
      child: Scaffold(
        backgroundColor: AppGreyColors.shade1050,
        body: SafeArea(
          top: false,
          child: Stack(
            children: [
              Positioned.fill(
                child: _PhotoPreviewSection(
                  imagePath: imagePath,
                  imageProvider: imageProvider,
                ),
              ),
              Positioned(
                bottom: 0,
                left: 0,
                right: 0,
                child: _ActionBarSection(
                  onRetake: () {
                    if (onRetake != null) {
                      onRetake!();
                    } else {
                      Navigator.of(context).maybePop();
                    }
                  },
                  onUsePhoto: () {
                    if (onUsePhoto != null) {
                      onUsePhoto!(imagePath);
                    } else {
                      unawaited(
                        context.push(AppRoutes.scanAnalyzing, extra: imagePath),
                      );
                    }
                  },
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _PhotoPreviewSection extends StatelessWidget {
  const _PhotoPreviewSection({
    required this.imagePath,
    required this.imageProvider,
  });

  final String imagePath;
  final ImageProvider? imageProvider;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      color: AppGreyColors.shade1050,
      child: Stack(
        fit: StackFit.expand,
        children: [
          InteractiveViewer(
            minScale: 1,
            maxScale: 4,
            child: Center(child: _buildImage()),
          ),
          SafeArea(
            child: Align(
              alignment: Alignment.topCenter,
              child: Padding(
                padding: const EdgeInsets.only(top: 12),
                child: Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 14,
                    vertical: 6,
                  ),
                  decoration: BoxDecoration(
                    color: AppGreyColors.shade1050.withValues(alpha: 0.65),
                    borderRadius: BorderRadius.circular(100),
                    border: Border.all(
                      color: AppGreyColors.shade800,
                      width: 0.8,
                    ),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const Icon(
                        Icons.zoom_in,
                        color: AppGreyColors.white,
                        size: 16,
                      ),
                      const SizedBox(width: 6),
                      Text(
                        'Pinch to inspect quality',
                        style: AppTypography.captureIndicatorChipText.copyWith(
                          color: AppGreyColors.white,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildImage() {
    if (imageProvider != null) {
      return Image(
        image: imageProvider!,
        fit: BoxFit.cover,
        width: double.infinity,
        height: double.infinity,
      );
    }

    final file = imagePath.isNotEmpty ? File(imagePath) : null;
    if (file == null || !file.existsSync()) {
      return const _PhotoFallbackView();
    }

    return Image.file(
      file,
      fit: BoxFit.cover,
      width: double.infinity,
      height: double.infinity,
      gaplessPlayback: true,
      errorBuilder: (context, error, stackTrace) => const _PhotoFallbackView(),
    );
  }
}

class _PhotoFallbackView extends StatelessWidget {
  const _PhotoFallbackView();

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Icon(
            Icons.broken_image_outlined,
            color: AppGreyColors.shade400,
            size: 48,
          ),
          const SizedBox(height: 12),
          Text(
            'Photo preview unavailable',
            style: AppTypography.bodyMSemiBold.copyWith(
              color: AppGreyColors.shade400,
            ),
          ),
        ],
      ),
    );
  }
}

class _ActionBarSection extends StatelessWidget {
  const _ActionBarSection({
    required this.onRetake,
    required this.onUsePhoto,
  });

  final VoidCallback onRetake;
  final VoidCallback onUsePhoto;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 32, horizontal: 24),
      decoration: const BoxDecoration(
        color: AppGreyColors.white,
        borderRadius: BorderRadius.vertical(top: Radius.circular(32)),
      ),
      child: Column(
        spacing: 12,
        children: [
          Semantics(
            button: true,
            label: 'Use this photo for skin analysis',
            child: PrimaryButton(
              text: 'Use this photo',
              onPressed: onUsePhoto,
            ),
          ),
          Semantics(
            button: true,
            label: 'Retake photo',
            child: SecondaryButton(
              text: 'Retake',
              onPressed: onRetake,
            ),
          ),
        ],
      ),
    );
  }
}
