import 'dart:math' as math;
import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:kora/common/app_colors.dart';
import 'package:kora/common/app_typography.dart';
import 'package:kora/core/constants/product_scanner_constants.dart';
import 'package:kora/features/product_scanner/presentation/widgets/reticle_corner_painter.dart';

/// Lock-on animation played when a barcode is detected (Telegram-style).
///
/// Sequence, over the frozen [preview]:
/// 1. **Snap** — the brackets jump from the viewfinder onto the code while
///    the rest of the image dims and blurs (the code stays sharp: "cut-out").
/// 2. **Lift** — the cut-out is lifted to the viewfinder center and gently
///    enlarged when small.
/// 3. **Sweep** — a laser line sweeps the crop while the lookup runs.
class BarcodeLockOverlay extends StatefulWidget {
  /// Creates a [BarcodeLockOverlay].
  const BarcodeLockOverlay({
    required this.preview,
    required this.frameRect,
    required this.sourceRect,
    required this.targetRect,
    required this.barcodeValue,
    super.key,
  });

  /// Full-screen (frozen) camera preview, same geometry as the backdrop.
  final Widget preview;

  /// Viewfinder rectangle the brackets start from.
  final Rect frameRect;

  /// Screen rectangle of the detected code (padded).
  final Rect sourceRect;

  /// Destination rectangle of the lifted crop.
  final Rect targetRect;

  /// Decoded value shown under the crop.
  final String barcodeValue;

  @override
  State<BarcodeLockOverlay> createState() => _BarcodeLockOverlayState();
}

class _BarcodeLockOverlayState extends State<BarcodeLockOverlay>
    with TickerProviderStateMixin {
  static const double _snapEnd = 0.45;
  static const double _maxScrimAlpha = 0.72;
  static const double _maxBlurSigma = 10;
  static const double _laserHeight = 3;
  static const double _laserInset = 6;

  late final AnimationController _lock = AnimationController(
    vsync: this,
    duration: ProductScannerConstants.barcodeLockDuration,
  );
  late final AnimationController _laser = AnimationController(
    vsync: this,
    duration: ProductScannerConstants.barcodeLaserSweepDuration,
  );
  bool _started = false;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (_started) return;
    _started = true;
    if (MediaQuery.disableAnimationsOf(context)) {
      _lock.value = 1;
      _laser.value = 0.5;
      return;
    }
    _lock.forward().whenCompleteOrCancel(() {
      if (mounted) _laser.repeat(reverse: true);
    });
  }

  @override
  void dispose() {
    _lock.dispose();
    _laser.dispose();
    super.dispose();
  }

  Matrix4 _cropTransform(Rect source, Rect current) {
    final scale = current.width / source.width;
    return Matrix4.diagonal3Values(scale, scale, 1)..setTranslationRaw(
      current.left - source.left * scale,
      current.top - source.top * scale,
      0,
    );
  }

  @override
  Widget build(BuildContext context) {
    return IgnorePointer(
      child: Semantics(
        liveRegion: true,
        label: 'Barcode detected. Looking up the product.',
        child: AnimatedBuilder(
          animation: Listenable.merge([_lock, _laser]),
          builder: (context, _) => _buildFrame(),
        ),
      ),
    );
  }

  Widget _buildFrame() {
    final t = _lock.value;
    final snap = Curves.easeOutCubic.transform((t / _snapEnd).clamp(0.0, 1.0));
    final lift = Curves.easeOutCubic.transform(
      ((t - _snapEnd) / (1 - _snapEnd)).clamp(0.0, 1.0),
    );
    final source = widget.sourceRect;
    final crop = Rect.lerp(source, widget.targetRect, lift)!;
    final brackets = lift > 0
        ? crop
        : Rect.lerp(widget.frameRect, source, snap)!;
    final scale = crop.width / source.width;
    const radius = ProductScannerConstants.barcodeCropRadius;

    return Stack(
      fit: StackFit.expand,
      children: [
        // 1. Dim + blur everything except the code.
        BackdropFilter(
          filter: ImageFilter.blur(
            sigmaX: _maxBlurSigma * snap,
            sigmaY: _maxBlurSigma * snap,
          ),
          child: ColoredBox(
            color: AppColors.grey1050.withValues(alpha: _maxScrimAlpha * snap),
          ),
        ),

        // 2. Soft glow under the lifted crop.
        Positioned.fromRect(
          rect: crop,
          child: DecoratedBox(
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(radius),
              boxShadow: [
                BoxShadow(
                  color: AppColors.primary500.withValues(alpha: 0.35 * lift),
                  blurRadius: 28,
                  spreadRadius: 2,
                ),
              ],
            ),
          ),
        ),

        // 3. The sharp cut-out of the frozen frame, moved & scaled.
        Positioned.fill(
          child: Transform(
            transform: _cropTransform(source, crop),
            child: ClipRRect(
              clipper: _RRectClipper(
                RRect.fromRectAndRadius(
                  source,
                  Radius.circular(radius / scale),
                ),
              ),
              child: widget.preview,
            ),
          ),
        ),

        // 4. Brackets snapping onto the code.
        Positioned.fromRect(
          rect: brackets.inflate(6),
          child: CustomPaint(
            painter: ReticleCornerPainter(
              bracketLength: math.min(28, brackets.shortestSide / 3),
              strokeWidth: 4,
              cornerRadius: 6,
              color: Color.lerp(
                AppGreyColors.white,
                AppColors.primary400,
                snap,
              )!,
            ),
          ),
        ),

        // 5. Laser sweep once the crop has landed.
        if (_lock.isCompleted)
          Positioned(
            left: crop.left + _laserInset,
            width: math.max(0, crop.width - 2 * _laserInset),
            top:
                crop.top +
                _laserInset +
                _laser.value * math.max(0, crop.height - 2 * _laserInset),
            height: _laserHeight,
            child: DecoratedBox(
              decoration: BoxDecoration(
                color: AppColors.primary400,
                borderRadius: BorderRadius.circular(_laserHeight),
                boxShadow: [
                  BoxShadow(
                    color: AppColors.primary400.withValues(alpha: 0.7),
                    blurRadius: 12,
                    spreadRadius: 1,
                  ),
                ],
              ),
            ),
          ),

        // 6. Decoded value + status, fading in with the lift.
        Positioned(
          left: 24,
          right: 24,
          top: crop.bottom + 24,
          child: Opacity(
            opacity: lift,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  widget.barcodeValue,
                  textAlign: TextAlign.center,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: AppTypography.bodyLMedium.copyWith(
                    color: AppGreyColors.white,
                    letterSpacing: 2,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  'Looking up product…',
                  textAlign: TextAlign.center,
                  style: AppTypography.bodySRegular.copyWith(
                    color: AppColors.grey300,
                  ),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }
}

class _RRectClipper extends CustomClipper<RRect> {
  const _RRectClipper(this.rrect);

  final RRect rrect;

  @override
  RRect getClip(Size size) => rrect;

  @override
  bool shouldReclip(covariant _RRectClipper oldClipper) =>
      oldClipper.rrect != rrect;
}
