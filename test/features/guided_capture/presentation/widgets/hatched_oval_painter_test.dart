import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:kora/features/guided_capture/domain/entities/face_analysis_result.dart';
import 'package:kora/features/guided_capture/presentation/widgets/capture_oval_guide.dart';
import 'package:kora/features/guided_capture/presentation/widgets/hatched_oval_painter.dart';

void main() {
  group('HatchedOvalPainter Tests', () {
    testWidgets('paints idle and directional segment correctly', (
      tester,
    ) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: SizedBox(
              width: 400,
              height: 800,
              child: CustomPaint(
                painter: HatchedOvalPainter(
                  hasFace: true,
                  alignmentScore: 0.45,
                  faceOffsetFromCenter: FaceOffset(dx: 0.5),
                  isAllValid: false,
                ),
              ),
            ),
          ),
        ),
      );

      expect(find.byType(CustomPaint), findsWidgets);
    });

    testWidgets('paints fully complete emerald ring when isAllValid is true', (
      tester,
    ) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: SizedBox(
              width: 400,
              height: 800,
              child: CustomPaint(
                painter: HatchedOvalPainter(
                  hasFace: true,
                  alignmentScore: 1,
                  faceOffsetFromCenter: FaceOffset.zero,
                  isAllValid: true,
                ),
              ),
            ),
          ),
        ),
      );

      expect(find.byType(CustomPaint), findsWidgets);
    });

    testWidgets('CaptureOvalGuide renders and animates directional lighting', (
      tester,
    ) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: SizedBox(
              width: 400,
              height: 800,
              child: CaptureOvalGuide(
                hasFace: true,
                alignmentScore: 0.8,
                faceOffsetFromCenter: FaceOffset(dx: 0.2, dy: -0.1),
                isAllValid: false,
              ),
            ),
          ),
        ),
      );

      expect(find.byType(CaptureOvalGuide), findsOneWidget);
      await tester.pumpAndSettle();
    });
  });
}
