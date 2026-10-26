import 'package:flutter_test/flutter_test.dart';
import 'package:kora/features/product_scanner/domain/entities/detected_barcode.dart';
import 'package:kora/features/product_scanner/domain/entities/product_frame_evaluation.dart';
import 'package:kora/features/product_scanner/domain/entities/scanned_product_result.dart';
import 'package:kora/features/product_scanner/domain/repositories/product_scanner_repository.dart';
import 'package:kora/features/product_scanner/domain/usecases/evaluate_product_frame_usecase.dart';
import 'package:kora/features/product_scanner/domain/usecases/process_and_search_product_usecase.dart';
import 'package:kora/features/product_scanner/domain/usecases/process_barcode_usecase.dart';
import 'package:kora/features/product_scanner/presentation/bloc/product_scanner_bloc.dart';
import 'package:kora/features/product_scanner/presentation/bloc/product_scanner_event.dart';
import 'package:kora/features/product_scanner/presentation/bloc/product_scanner_state.dart';

class FakeFullProductScannerRepo implements ProductScannerRepository {
  @override
  Future<RawOcrFrameData> analyzeLiveTextFrame({
    required dynamic cameraImage,
    required dynamic cameraDescription,
  }) async {
    return const RawOcrFrameData(
      fullText: 'CeraVe Foaming Cleanser',
      textBlockBoxes: [],
      imageWidth: 400,
      imageHeight: 800,
      normalizedBrightness: 0.5,
    );
  }

  @override
  Future<DetectedBarcode?> analyzeLiveBarcodeFrame({
    required dynamic cameraImage,
    required dynamic cameraDescription,
  }) async {
    return const DetectedBarcode(value: '3337875597357');
  }

  @override
  Future<ScannedProductResult> extractTextAndSearchBackend(
    String imagePath,
  ) async {
    return ScannedProductResult(
      imagePath: imagePath,
      extractedRawText: 'CeraVe Foaming Cleanser',
      detectedLines: const ['CeraVe', 'Foaming Cleanser'],
      sourceMode: ScanSourceMode.productPhoto,
      backendProductData: const {'matched': true},
    );
  }

  @override
  Future<ScannedProductResult> searchByBarcode({
    required String barcode,
    String? capturedImagePath,
  }) async {
    return ScannedProductResult(
      imagePath: capturedImagePath ?? '',
      extractedRawText: barcode,
      detectedLines: [barcode],
      sourceMode: ScanSourceMode.barcode,
      barcodeValue: barcode,
      backendProductData: const {'matched': true},
    );
  }

  @override
  Future<void> dispose() async {}
}

void main() {
  late FakeFullProductScannerRepo repo;
  late EvaluateProductFrameUseCase evalUseCase;
  late ProcessAndSearchProductUseCase processUseCase;
  late ProcessBarcodeUseCase barcodeUseCase;

  setUp(() {
    repo = FakeFullProductScannerRepo();
    evalUseCase = EvaluateProductFrameUseCase();
    processUseCase = ProcessAndSearchProductUseCase(repo);
    barcodeUseCase = ProcessBarcodeUseCase(repo);
  });

  ProductScannerBloc buildBloc({Duration minLockDuration = Duration.zero}) =>
      ProductScannerBloc(
        repository: repo,
        evaluateFrameUseCase: evalUseCase,
        processProductUseCase: processUseCase,
        processBarcodeUseCase: barcodeUseCase,
        minBarcodeLockDuration: minLockDuration,
      );

  group('ProductScannerBloc', () {
    test(
      'initial state has 2 scansLeft and cameraGuidance step in photo mode',
      () {
        final bloc = buildBloc();
        expect(bloc.state.step, ProductScannerStep.cameraGuidance);
        expect(bloc.state.mode, ScannerCaptureMode.productPhoto);
        expect(bloc.state.scansLeft, 2);
        expect(bloc.state.isFlashOn, isFalse);
      },
    );

    test('toggling flash flips isFlashOn', () async {
      final bloc = buildBloc();
      expect(bloc.state.isFlashOn, isFalse);

      bloc.add(const ToggleFlashTappedEvent());
      await Future<void>.delayed(const Duration(milliseconds: 10));
      expect(bloc.state.isFlashOn, isTrue);

      bloc.add(const ToggleFlashTappedEvent());
      await Future<void>.delayed(const Duration(milliseconds: 10));
      expect(bloc.state.isFlashOn, isFalse);
    });

    test('mode changed switches mode and resets frame streak', () async {
      final bloc = buildBloc();
      expect(bloc.state.mode, ScannerCaptureMode.productPhoto);

      bloc.add(const ModeChangedEvent(ScannerCaptureMode.barcode));
      await Future<void>.delayed(const Duration(milliseconds: 10));

      expect(bloc.state.mode, ScannerCaptureMode.barcode);
      expect(bloc.state.consecutiveReadyFrames, 0);
      expect(
        bloc.state.guidanceMessage,
        'Align barcode or QR code inside the frame',
      );
    });

    test(
      'photo capture event transitions through processing to completed',
      () async {
        final bloc = buildBloc()
          ..add(const ImageCapturedOrPickedEvent('test/cerave.jpg'));
        await Future<void>.delayed(const Duration(milliseconds: 50));

        expect(bloc.state.step, ProductScannerStep.completed);
        expect(bloc.state.scansLeft, 1);
        expect(bloc.state.result?.extractedRawText, 'CeraVe Foaming Cleanser');
        expect(bloc.state.result?.sourceMode, ScanSourceMode.productPhoto);
      },
    );

    test(
      'barcode detected event transitions through barcodeLocked to completed',
      () async {
        final bloc = buildBloc(
          minLockDuration: const Duration(milliseconds: 100),
        )..add(const BarcodeDetectedEvent('3337875597357'));

        await Future<void>.delayed(const Duration(milliseconds: 10));
        expect(bloc.state.step, ProductScannerStep.barcodeLocked);
        expect(bloc.state.detectedBarcode?.value, '3337875597357');

        await Future<void>.delayed(const Duration(milliseconds: 150));
        expect(bloc.state.step, ProductScannerStep.completed);
        expect(bloc.state.scansLeft, 1);
        expect(bloc.state.result?.barcodeValue, '3337875597357');
        expect(bloc.state.result?.sourceMode, ScanSourceMode.barcode);
      },
    );

    test('back to camera resets state step to cameraGuidance', () async {
      final bloc = buildBloc()
        ..add(const ImageCapturedOrPickedEvent('test/photo.jpg'));
      await Future<void>.delayed(const Duration(milliseconds: 50));
      expect(bloc.state.step, ProductScannerStep.completed);

      bloc.add(const BackToCameraEvent());
      await Future<void>.delayed(const Duration(milliseconds: 10));
      expect(bloc.state.step, ProductScannerStep.cameraGuidance);
    });
  });
}
