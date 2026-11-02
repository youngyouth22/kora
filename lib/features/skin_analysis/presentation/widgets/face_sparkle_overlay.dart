import 'dart:async';
import 'dart:io';
import 'dart:math' as math;
import 'dart:ui' as ui;

import 'package:flutter/material.dart';
import 'package:google_mlkit_face_detection/google_mlkit_face_detection.dart';
import 'package:kora/common/app_colors.dart';

/// Represents a single shimmering sparkle star positioned on a facial landmark.
class StarParticle {
  /// Creates a [StarParticle].
  StarParticle({
    required this.normalizedPosition,
    this.maxRadius = 7.0,
    this.speed = 2.0,
    double? phase,
    this.color = AppPrimaryColors.shade400,
  }) : phase = phase ?? (math.Random().nextDouble() * math.pi * 2);

  /// Normalized position in [0.0, 1.0] relative to image coordinates.
  final Offset normalizedPosition;

  /// Maximum radius of the 4-pointed star.
  final double maxRadius;

  /// Shimmer frequency speed.
  final double speed;

  /// Initial sine phase offset.
  final double phase;

  /// Primary color of the sparkle.
  final Color color;

  /// Calculates the dynamic scale (30% to 100%) for animation value [t].
  double getScale(double t) => (math.sin(phase + t * speed).abs() * 0.7) + 0.3;

  /// Calculates the dynamic opacity (25% to 100%) for animation value [t].
  double getOpacity(double t) =>
      (math.sin(phase + t * speed).abs() * 0.75) + 0.25;
}

/// Custom painter rendering animated 4-pointed sparkle stars on face
/// coordinates.
class FaceSparklePainter extends CustomPainter {
  /// Creates a [FaceSparklePainter].
  FaceSparklePainter({
    required this.particles,
    required this.animation,
    this.sourceImageSize,
  }) : super(repaint: animation);

  /// Particles to render.
  final List<StarParticle> particles;

  /// Continuous animation driver.
  final Animation<double> animation;

  /// Original image size to map normalized coordinates under [BoxFit.cover].
  final Size? sourceImageSize;

  @override
  void paint(Canvas canvas, Size size) {
    if (particles.isEmpty) return;

    final t = animation.value * math.pi * 2;
    final fillPaint = Paint()..style = PaintingStyle.fill;
    final glowPaint = Paint()..style = PaintingStyle.fill;
    final centerPaint = Paint()..style = PaintingStyle.fill;

    // Calculate BoxFit.cover mapping
    final imgW = sourceImageSize?.width ?? size.width;
    final imgH = sourceImageSize?.height ?? size.height;
    final scale = math.max(size.width / imgW, size.height / imgH);
    final scaledW = imgW * scale;
    final scaledH = imgH * scale;
    final dx = (size.width - scaledW) / 2.0;
    final dy = (size.height - scaledH) / 2.0;

    for (final particle in particles) {
      final pScale = particle.getScale(t);
      final opacity = particle.getOpacity(t);
      final r = particle.maxRadius * pScale;

      final px = (particle.normalizedPosition.dx * scaledW) + dx;
      final py = (particle.normalizedPosition.dy * scaledH) + dy;
      final pos = Offset(px, py);

      // 1. Soft radial glow halo behind the star
      glowPaint.color = particle.color.withValues(alpha: opacity * 0.35);
      canvas.drawCircle(pos, r * 1.5, glowPaint);

      // 2. 4-pointed sparkle star with curved quadratic beziers
      fillPaint.color = particle.color.withValues(alpha: opacity);
      final pinch = r / 3.2;
      final starPath = Path()
        ..moveTo(pos.dx, pos.dy - r)
        ..quadraticBezierTo(pos.dx, pos.dy, pos.dx + pinch, pos.dy)
        ..lineTo(pos.dx + r, pos.dy)
        ..quadraticBezierTo(pos.dx, pos.dy, pos.dx, pos.dy + pinch)
        ..lineTo(pos.dx, pos.dy + r)
        ..quadraticBezierTo(pos.dx, pos.dy, pos.dx - pinch, pos.dy)
        ..lineTo(pos.dx - r, pos.dy)
        ..quadraticBezierTo(pos.dx, pos.dy, pos.dx, pos.dy - pinch)
        ..close();

      canvas.drawPath(starPath, fillPaint);

      // 3. Bright central white highlight dot
      centerPaint.color = AppGreyColors.white.withValues(alpha: opacity);
      canvas.drawCircle(pos, r / 3.4, centerPaint);
    }
  }

  @override
  bool shouldRepaint(covariant FaceSparklePainter oldDelegate) => true;
}

/// Animated overlay detecting face landmarks and displaying sparkling stars.
class FaceSparkleOverlay extends StatefulWidget {
  /// Creates a [FaceSparkleOverlay].
  const FaceSparkleOverlay({
    required this.imagePath,
    this.isAnimating = true,
    this.customPoints,
    this.imageSize,
    super.key,
  });

  /// Path to the captured facial image file.
  final String imagePath;

  /// Whether the sparkles are actively animating.
  final bool isAnimating;

  /// Optional pre-computed normalized points (e.g. for testing or mocking).
  final List<Offset>? customPoints;

  /// Optional known image size.
  final Size? imageSize;

  @override
  State<FaceSparkleOverlay> createState() => _FaceSparkleOverlayState();
}

class _FaceSparkleOverlayState extends State<FaceSparkleOverlay>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller;
  List<StarParticle> _sparkles = [];
  Size? _detectedImageSize;

  static const List<Color> _sparklePalette = [
    AppPrimaryColors.shade400,
    AppPrimaryColors.shade300,
    AppPrimaryColors.shade500,
    AppGreyColors.white,
  ];

  @override
  void initState() {
    super.initState();
    _detectedImageSize = widget.imageSize;
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 4),
    );

    if (widget.isAnimating) {
      _controller.repeat();
    }

    if (widget.customPoints != null && widget.customPoints!.isNotEmpty) {
      _generateParticles(widget.customPoints!);
    } else {
      _initDefaultSparkles();
      WidgetsBinding.instance.addPostFrameCallback((_) {
        unawaited(_detectFaceLandmarks());
      });
    }
  }

  @override
  void didUpdateWidget(covariant FaceSparkleOverlay oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.isAnimating != oldWidget.isAnimating) {
      if (widget.isAnimating) {
        _controller.repeat();
      } else {
        _controller.stop();
      }
    }

    if (widget.imagePath != oldWidget.imagePath ||
        widget.customPoints != oldWidget.customPoints) {
      if (widget.customPoints != null && widget.customPoints!.isNotEmpty) {
        _generateParticles(widget.customPoints!);
      } else {
        unawaited(_detectFaceLandmarks());
      }
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  /// Initializes realistic default sparkles positioned across facial regions
  /// so visual feedback is instantaneous while ML Kit processes.
  void _initDefaultSparkles() {
    // Proportional facial coordinates
    // (center-x ~ 0.5, face region 0.25 to 0.65)
    const defaultFacePoints = <Offset>[
      // Forehead
      Offset(0.42, 0.25),
      Offset(0.50, 0.23),
      Offset(0.58, 0.25),
      // Left eye & eyebrow
      Offset(0.38, 0.32),
      Offset(0.42, 0.31),
      Offset(0.36, 0.35),
      Offset(0.42, 0.36),
      // Right eye & eyebrow
      Offset(0.58, 0.31),
      Offset(0.62, 0.32),
      Offset(0.58, 0.36),
      Offset(0.64, 0.35),
      // Nose bridge & tip
      Offset(0.50, 0.35),
      Offset(0.50, 0.40),
      Offset(0.50, 0.45),
      // Cheeks (skin focus zones)
      Offset(0.33, 0.42),
      Offset(0.37, 0.45),
      Offset(0.63, 0.45),
      Offset(0.67, 0.42),
      // Mouth & jawline
      Offset(0.45, 0.53),
      Offset(0.50, 0.53),
      Offset(0.55, 0.53),
      Offset(0.35, 0.56),
      Offset(0.50, 0.62),
      Offset(0.65, 0.56),
    ];

    _generateParticles(defaultFacePoints);
  }

  Future<void> _detectFaceLandmarks() async {
    final path = widget.imagePath;
    if (path.isEmpty) return;

    final file = File(path);
    if (!file.existsSync()) return;

    FaceDetector? detector;
    try {
      final inputImage = InputImage.fromFilePath(path);
      detector = FaceDetector(
        options: FaceDetectorOptions(
          enableContours: true,
          enableLandmarks: true,
        ),
      );
      final faces = await detector.processImage(inputImage);
      await detector.close();
      detector = null;

      if (!mounted || faces.isEmpty) return;

      // Read image resolution for exact coordinate mapping
      final bytes = await file.readAsBytes();
      final codec = await ui.instantiateImageCodec(bytes);
      final frame = await codec.getNextFrame();
      final imgW = frame.image.width.toDouble();
      final imgH = frame.image.height.toDouble();

      final primaryFace = faces.first;
      final points = <Offset>[];

      void addContour(FaceContourType type, {int step = 2}) {
        final contour = primaryFace.contours[type];
        if (contour != null && contour.points.isNotEmpty) {
          for (var i = 0; i < contour.points.length; i += step) {
            final pt = contour.points[i];
            points.add(Offset(pt.x / imgW, pt.y / imgH));
          }
        }
      }

      addContour(FaceContourType.face, step: 3);
      addContour(FaceContourType.leftEye);
      addContour(FaceContourType.rightEye);
      addContour(FaceContourType.leftEyebrowTop);
      addContour(FaceContourType.rightEyebrowTop);
      addContour(FaceContourType.noseBridge, step: 1);
      addContour(FaceContourType.leftCheek, step: 1);
      addContour(FaceContourType.rightCheek, step: 1);
      addContour(FaceContourType.upperLipTop, step: 3);
      addContour(FaceContourType.lowerLipBottom, step: 3);

      if (points.isNotEmpty && mounted) {
        setState(() {
          _detectedImageSize = Size(imgW, imgH);
          _generateParticles(points);
        });
      }
    } on Exception catch (_) {
      // Fallback points are already active
    } finally {
      await detector?.close();
    }
  }

  void _generateParticles(List<Offset> points) {
    final random = math.Random(42);
    _sparkles = points.map((pt) {
      final color = _sparklePalette[random.nextInt(_sparklePalette.length)];
      final radius = 5.0 + (random.nextDouble() * 4.5);
      final speed = 1.3 + (random.nextDouble() * 2.2);
      final phase = random.nextDouble() * math.pi * 2;

      return StarParticle(
        normalizedPosition: pt,
        maxRadius: radius,
        speed: speed,
        phase: phase,
        color: color,
      );
    }).toList();
  }

  @override
  Widget build(BuildContext context) {
    if (!widget.isAnimating) {
      return const SizedBox.shrink();
    }

    return LayoutBuilder(
      builder: (context, constraints) {
        return CustomPaint(
          size: Size(constraints.maxWidth, constraints.maxHeight),
          painter: FaceSparklePainter(
            particles: _sparkles,
            animation: _controller,
            sourceImageSize: _detectedImageSize,
          ),
        );
      },
    );
  }
}
