import 'package:flutter_test/flutter_test.dart';
import 'package:kora/features/product_scanner/domain/entities/product_frame_evaluation.dart';
import 'package:kora/features/product_scanner/domain/entities/scanner_bounding_box.dart';
import 'package:kora/features/product_scanner/domain/usecases/evaluate_product_frame_usecase.dart';

void main() {
  late EvaluateProductFrameUseCase useCase;

  setUp(() {
    useCase = EvaluateProductFrameUseCase();
  });

  group('EvaluateProductFrameUseCase', () {
    test('returns too dark when brightness is below threshold', () {
      const data = RawOcrFrameData(
        fullText: 'CeraVe Foaming Cleanser 236ml',
        textBlockBoxes: [
          ScannerBoundingBox(left: 100, top: 200, right: 300, bottom: 400),
        ],
        imageWidth: 400,
        imageHeight: 800,
        normalizedBrightness: 0.15,
      );

      final result = useCase(data);

      expect(result.isLightOk, isFalse);
      expect(result.isReadyToCapture, isFalse);
      expect(result.guidanceMessage, contains('Too dark'));
    });

    test(
      'prompts to place product inside frame when no text blocks in zone',
      () {
        const data = RawOcrFrameData(
          fullText: '',
          textBlockBoxes: [],
          imageWidth: 400,
          imageHeight: 800,
          normalizedBrightness: 0.60,
        );

        final result = useCase(data);

        expect(result.isLightOk, isTrue);
        expect(result.hasProductTextInFrame, isFalse);
        expect(result.isReadyToCapture, isFalse);
        expect(
          result.guidanceMessage,
          contains('Place the product front label'),
        );
      },
    );

    test('prompts to move closer when text is too small or short', () {
      const data = RawOcrFrameData(
        fullText: 'Tiny label',
        textBlockBoxes: [
          ScannerBoundingBox(left: 190, top: 390, right: 210, bottom: 410),
        ],
        imageWidth: 400,
        imageHeight: 800,
        normalizedBrightness: 0.50,
      );

      final result = useCase(data);

      expect(result.isLightOk, isTrue);
      expect(result.hasProductTextInFrame, isTrue);
      expect(result.isTextReadableAndCloseEnough, isFalse);
      expect(result.isReadyToCapture, isFalse);
      expect(result.guidanceMessage, contains('Move closer'));
    });

    test(
      'marks ready to capture when well-lit and product text spans zone',
      () {
        const data = RawOcrFrameData(
          fullText: 'CeraVe Foaming Cleanser Gel Moussant 236ml',
          textBlockBoxes: [
            ScannerBoundingBox(left: 100, top: 250, right: 300, bottom: 350),
            ScannerBoundingBox(left: 120, top: 380, right: 280, bottom: 500),
          ],
          imageWidth: 400,
          imageHeight: 800,
          normalizedBrightness: 0.55,
        );

        final result = useCase(data);

        expect(result.isLightOk, isTrue);
        expect(result.hasProductTextInFrame, isTrue);
        expect(result.isTextReadableAndCloseEnough, isTrue);
        expect(result.isReadyToCapture, isTrue);
        expect(result.guidanceMessage, contains('Hold still — ready to scan'));
      },
    );
  });
}
