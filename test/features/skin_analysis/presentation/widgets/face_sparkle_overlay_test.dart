import 'dart:ui' as ui;

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:kora/common/app_colors.dart';
import 'package:kora/features/skin_analysis/presentation/widgets/face_sparkle_overlay.dart';

void main() {
  group('StarParticle Tests', () {
    test('current scale and opacity stay within expected ergonomic bounds', () {
      final particle = StarParticle(
        normalizedPosition: const Offset(0.5, 0.5),
        maxRadius: 8,
        phase: 0,
      );

      for (var t = 0.0; t <= 3.0; t += 0.25) {
        final scale = particle.getScale(t);
        final opacity = particle.getOpacity(t);

        expect(scale, greaterThanOrEqualTo(0.3));
        expect(scale, lessThanOrEqualTo(1.0));

        expect(opacity, greaterThanOrEqualTo(0.25));
        expect(opacity, lessThanOrEqualTo(1.0));
      }
    });
  });

  group('FaceSparklePainter Tests', () {
    test('paints particles and stars onto canvas without throw', () {
      final particles = [
        StarParticle(
          normalizedPosition: const Offset(0.4, 0.3),
        ),
        StarParticle(
          normalizedPosition: const Offset(0.6, 0.3),
          color: AppPrimaryColors.shade300,
        ),
      ];

      const animation = AlwaysStoppedAnimation(0.5);
      final painter = FaceSparklePainter(
        particles: particles,
        animation: animation,
        sourceImageSize: const Size(400, 800),
      );

      final recorder = ui.PictureRecorder();
      final canvas = Canvas(recorder);

      expect(
        () => painter.paint(canvas, const Size(360, 640)),
        returnsNormally,
      );
      recorder.endRecording();
    });
  });

  group('FaceSparkleOverlay Widget Tests', () {
    testWidgets('renders CustomPaint with sparkles given custom points', (
      tester,
    ) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: FaceSparkleOverlay(
              imagePath: '',
              customPoints: [
                Offset(0.4, 0.3),
                Offset(0.6, 0.3),
                Offset(0.5, 0.5),
              ],
            ),
          ),
        ),
      );

      expect(find.byType(FaceSparkleOverlay), findsOneWidget);
      expect(find.byType(CustomPaint), findsWidgets);

      // Advance animation slightly
      await tester.pump(const Duration(milliseconds: 100));
      expect(tester.takeException(), isNull);
    });

    testWidgets('falls back to default face coordinates on empty image path', (
      tester,
    ) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: FaceSparkleOverlay(imagePath: ''),
          ),
        ),
      );

      expect(find.byType(FaceSparkleOverlay), findsOneWidget);
      await tester.pump(const Duration(milliseconds: 50));
      expect(tester.takeException(), isNull);
    });

    testWidgets('renders SizedBox.shrink when isAnimating is false', (
      tester,
    ) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: FaceSparkleOverlay(
              imagePath: '',
              isAnimating: false,
            ),
          ),
        ),
      );

      expect(find.byType(FaceSparkleOverlay), findsOneWidget);
      expect(
        find.descendant(
          of: find.byType(FaceSparkleOverlay),
          matching: find.byType(CustomPaint),
        ),
        findsNothing,
      );
    });
  });
}
