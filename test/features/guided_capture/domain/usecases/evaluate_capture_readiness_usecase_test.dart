import 'package:flutter_test/flutter_test.dart';
import 'package:kora/features/guided_capture/domain/entities/face_analysis_result.dart';
import 'package:kora/features/guided_capture/domain/usecases/evaluate_capture_readiness_usecase.dart';

/// Realistic setup: 1080x1920 upright frame, 390x844 phone viewport.
///
/// With a cover fit, scale = 844 / 1920 = 0.4396 and 42.4px are cropped on
/// each side horizontally. The oval resolves to center (195, 379.8),
/// radii (159.9, 194.4).
const _image = CaptureDimensions(width: 1080, height: 1920);
const _viewport = CaptureDimensions(width: 390, height: 844);

/// Face box centered on the oval (with the expected vertical bias) and
/// filling 75% of the oval width.
const _alignedBox = CaptureBoundingBox(
  left: 267,
  top: 635,
  width: 546,
  height: 546,
);

FaceAnalysisResult _face({
  CaptureBoundingBox box = _alignedBox,
  double brightness = 0.45,
  double clipping = 0,
  double yaw = 0,
  double pitch = 0,
  bool hasFace = true,
  int detectedFaceCount = 1,
  double? leftEyeOpenProbability,
  double? rightEyeOpenProbability,
  double? mouthOpenRatio,
}) {
  return FaceAnalysisResult(
    hasFace: hasFace,
    faceBoundingBox: hasFace ? box : null,
    imageSize: _image,
    normalizedBrightness: brightness,
    highlightClippingRatio: clipping,
    yaw: yaw,
    pitch: pitch,
    detectedFaceCount: detectedFaceCount,
    leftEyeOpenProbability: leftEyeOpenProbability,
    rightEyeOpenProbability: rightEyeOpenProbability,
    mouthOpenRatio: mouthOpenRatio,
  );
}

void main() {
  const useCase = EvaluateCaptureReadinessUseCase();

  CaptureEvaluation evaluate(FaceAnalysisResult analysis) =>
      useCase(analysis, viewportSize: _viewport);

  group('EvaluateCaptureReadinessUseCase', () {
    group('no face', () {
      test('asks to position the face when light is ok', () {
        final result = evaluate(_face(hasFace: false));

        expect(result.hasFace, isFalse);
        expect(result.isLightOk, isTrue);
        expect(result.guidanceMessage, 'Position your face inside the oval');
        expect(result.alignmentScore, 0);
        expect(result.shouldBoostBrightness, isFalse);
        expect(result.isAllValid, isFalse);
      });

      test('asks for more light and boosts screen when too dark', () {
        final result = evaluate(_face(hasFace: false, brightness: 0.12));

        expect(result.isLightOk, isFalse);
        expect(result.shouldBoostBrightness, isTrue);
        expect(
          result.guidanceMessage,
          'Need more light — turn towards a window',
        );
      });

      test('treats an empty image size as no face', () {
        const analysis = FaceAnalysisResult(
          hasFace: true,
          faceBoundingBox: _alignedBox,
          imageSize: CaptureDimensions(width: 0, height: 0),
          normalizedBrightness: 0.45,
        );

        expect(useCase(analysis).hasFace, isFalse);
      });

      test('warns when more than one person is detected in frame', () {
        final result = evaluate(_face(detectedFaceCount: 2));

        expect(result.hasFace, isTrue);
        expect(result.isPositionOk, isFalse);
        expect(result.isAllValid, isFalse);
        expect(
          result.guidanceMessage,
          'Only one person can be scanned at a time',
        );
      });
    });

    group('lighting', () {
      test('accepts a typical auto-exposed indoor face (0.45)', () {
        expect(evaluate(_face()).isLightOk, isTrue);
      });

      test('accepts a dim but usable scene just above the threshold', () {
        expect(evaluate(_face(brightness: 0.26)).isLightOk, isTrue);
      });

      test('rejects a dark scene below the threshold', () {
        final result = evaluate(_face(brightness: 0.20));

        expect(result.isLightOk, isFalse);
        expect(result.shouldBoostBrightness, isTrue);
        expect(result.isAllValid, isFalse);
      });

      test('reports glare when too many pixels are blown out', () {
        final result = evaluate(_face(clipping: 0.40));

        expect(result.isLightOk, isFalse);
        expect(result.shouldBoostBrightness, isFalse);
        expect(result.guidanceMessage, 'Too much light — avoid direct glare');
      });

      test('reports glare when mean luminance is extreme', () {
        expect(evaluate(_face(brightness: 0.93)).isLightOk, isFalse);
      });
    });

    group('position', () {
      test('requests to move closer when the face is small', () {
        final result = evaluate(
          _face(
            box: const CaptureBoundingBox(
              left: 400,
              top: 770,
              width: 280,
              height: 280,
            ),
          ),
        );

        expect(result.isPositionOk, isFalse);
        expect(result.guidanceMessage, 'Move closer');
      });

      test('requests to move back when the face overflows the oval', () {
        final result = evaluate(
          _face(
            box: const CaptureBoundingBox(
              left: 140,
              top: 510,
              width: 800,
              height: 800,
            ),
          ),
        );

        expect(result.isPositionOk, isFalse);
        expect(result.guidanceMessage, 'Move back slightly');
      });

      test('requests centering when the face is off to the side', () {
        final result = evaluate(
          _face(
            box: const CaptureBoundingBox(
              left: 27,
              top: 635,
              width: 546,
              height: 546,
            ),
          ),
        );

        expect(result.isPositionOk, isFalse);
        expect(result.guidanceMessage, 'Center your face in the oval');
        expect(result.faceOffsetFromCenter.dx, greaterThan(0));
      });

      test('accounts for the cover crop of the preview', () {
        // Without the viewport the frame itself is the viewport, so the oval
        // is larger relative to the face → "Move closer". With the real
        // cropped phone viewport the same face fills the oval correctly.
        final analysis = _face(
          box: const CaptureBoundingBox(
            left: 320,
            top: 688,
            width: 440,
            height: 440,
          ),
        );

        final withoutViewport = useCase(analysis);
        final withViewport = evaluate(analysis);

        expect(withoutViewport.guidanceMessage, 'Move closer');
        expect(withViewport.isPositionOk, isTrue);
      });
    });

    group('angle', () {
      test('requests to look straight when yaw exceeds the limit', () {
        final result = evaluate(_face(yaw: 15));

        expect(result.isPositionOk, isTrue);
        expect(result.isAngleOk, isFalse);
        expect(result.guidanceMessage, 'Look straight');
      });

      test('rejects excessive upward pitch', () {
        expect(evaluate(_face(pitch: 9)).isAngleOk, isFalse);
      });

      test('rejects excessive downward pitch', () {
        expect(evaluate(_face(pitch: -20)).isAngleOk, isFalse);
      });
    });

    group('facial expression (eyes and mouth)', () {
      test('asks to open eyes when left or right eye is closed', () {
        final result = evaluate(
          _face(leftEyeOpenProbability: 0.05, rightEyeOpenProbability: 0.08),
        );

        expect(result.isAngleOk, isFalse);
        expect(result.isAllValid, isFalse);
        expect(result.guidanceMessage, 'Open your eyes');
      });

      test(
        'asks to close mouth when mouth opening ratio exceeds threshold',
        () {
          final result = evaluate(_face(mouthOpenRatio: 0.45));

          expect(result.isAngleOk, isFalse);
          expect(result.isAllValid, isFalse);
          expect(result.guidanceMessage, 'Close your mouth');
        },
      );

      test('validates when eyes are open and mouth is resting', () {
        final result = evaluate(
          _face(
            leftEyeOpenProbability: 0.90,
            rightEyeOpenProbability: 0.88,
            mouthOpenRatio: 0.10,
          ),
        );

        expect(result.isAngleOk, isTrue);
        expect(result.isAllValid, isTrue);
      });
    });

    group('alignment score', () {
      test('is exactly 1 when every criterion is met', () {
        final result = evaluate(_face(yaw: 2, pitch: -3));

        expect(result.isAllValid, isTrue);
        expect(result.guidanceMessage, 'Hold still...');
        expect(result.alignmentScore, 1);
      });

      test('stays below 1 when a single criterion fails', () {
        final result = evaluate(_face(yaw: 12));

        expect(result.isAllValid, isFalse);
        expect(result.alignmentScore, lessThan(1));
        expect(result.alignmentScore, greaterThan(0.9));
      });

      test('increases as the user gets closer to valid', () {
        final far = evaluate(_face(yaw: 30, brightness: 0.1));
        final near = evaluate(_face(yaw: 12));

        expect(near.alignmentScore, greaterThan(far.alignmentScore));
      });

      test('stays within [0, 1]', () {
        final result = evaluate(
          _face(
            yaw: 90,
            brightness: 0,
            box: const CaptureBoundingBox(
              left: 0,
              top: 0,
              width: 20,
              height: 20,
            ),
          ),
        );

        expect(result.alignmentScore, inInclusiveRange(0, 1));
      });
    });
  });
}
