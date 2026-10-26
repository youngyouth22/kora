// ignore_for_file: document_ignores, prefer_initializing_formals

import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:kora/core/constants/product_scanner_constants.dart';
import 'package:kora/features/product_scanner/domain/entities/detected_barcode.dart';
import 'package:kora/features/product_scanner/domain/entities/scanned_product_result.dart';
import 'package:kora/features/product_scanner/domain/repositories/product_scanner_repository.dart';
import 'package:kora/features/product_scanner/domain/usecases/evaluate_product_frame_usecase.dart';
import 'package:kora/features/product_scanner/domain/usecases/process_and_search_product_usecase.dart';
import 'package:kora/features/product_scanner/domain/usecases/process_barcode_usecase.dart';
import 'package:kora/features/product_scanner/presentation/bloc/product_scanner_event.dart';
import 'package:kora/features/product_scanner/presentation/bloc/product_scanner_state.dart';

/// BLoC orchestrating the product scanner guidance, mode switching,
/// live frame analysis (OCR + barcode), and high-resolution search.
class ProductScannerBloc
    extends Bloc<ProductScannerEvent, ProductScannerState> {
  /// Creates a [ProductScannerBloc].
  ProductScannerBloc({
    required ProductScannerRepository repository,
    required EvaluateProductFrameUseCase evaluateFrameUseCase,
    required ProcessAndSearchProductUseCase processProductUseCase,
    required ProcessBarcodeUseCase processBarcodeUseCase,
    int initialScansLeft = 2,
    Duration minBarcodeLockDuration =
        ProductScannerConstants.minBarcodeLockDuration,
  }) : _repository = repository,
       _evaluateFrameUseCase = evaluateFrameUseCase,
       _processProductUseCase = processProductUseCase,
       _processBarcodeUseCase = processBarcodeUseCase,
       _minBarcodeLockDuration = minBarcodeLockDuration,
       super(ProductScannerState(scansLeft: initialScansLeft)) {
    on<LiveCameraFrameEvent>(_onLiveCameraFrame);
    on<ToggleFlashTappedEvent>(_onToggleFlash);
    on<ModeChangedEvent>(_onModeChanged);
    on<ImageCapturedOrPickedEvent>(_onImageCapturedOrPicked);
    on<BarcodeDetectedEvent>(_onBarcodeDetected);
    on<BackToCameraEvent>(_onBackToCamera);
    on<RetryScanEvent>(_onRetryScan);
  }

  final ProductScannerRepository _repository;
  final EvaluateProductFrameUseCase _evaluateFrameUseCase;
  final ProcessAndSearchProductUseCase _processProductUseCase;
  final ProcessBarcodeUseCase _processBarcodeUseCase;

  /// Minimum on-screen time of the lock-on animation, so a fast lookup never
  /// cuts the feedback short.
  final Duration _minBarcodeLockDuration;

  int _frameCount = 0;
  bool _isAnalyzingFrame = false;

  Future<void> _onLiveCameraFrame(
    LiveCameraFrameEvent event,
    Emitter<ProductScannerState> emit,
  ) async {
    if (state.step != ProductScannerStep.cameraGuidance) return;

    // Subsample: 1 frame every 4 for responsiveness without stutter
    _frameCount++;
    if (_frameCount % 4 != 0 || _isAnalyzingFrame) return;

    _isAnalyzingFrame = true;
    try {
      if (state.mode == ScannerCaptureMode.barcode) {
        final detectedBarcode = await _repository.analyzeLiveBarcodeFrame(
          cameraImage: event.image,
          cameraDescription: event.camera,
        );

        if (detectedBarcode != null && detectedBarcode.value.isNotEmpty) {
          add(
            BarcodeDetectedEvent(
              detectedBarcode.value,
              normalizedBox: detectedBarcode.normalizedBox,
            ),
          );
        }
      } else {
        final rawOcr = await _repository.analyzeLiveTextFrame(
          cameraImage: event.image,
          cameraDescription: event.camera,
        );
        final evaluation = _evaluateFrameUseCase(rawOcr);

        final nextStreak = evaluation.isReadyToCapture
            ? state.consecutiveReadyFrames + 1
            : 0;

        emit(
          state.copyWith(
            isLightOk: evaluation.isLightOk,
            hasTextInFrame: evaluation.hasProductTextInFrame,
            isReadyToCapture: evaluation.isReadyToCapture,
            consecutiveReadyFrames: nextStreak,
            guidanceMessage: evaluation.guidanceMessage,
          ),
        );
      }
    } on Exception catch (_) {
      // Ignore transient frame analysis errors to keep stream uninterrupted
    } finally {
      _isAnalyzingFrame = false;
    }
  }

  void _onToggleFlash(
    ToggleFlashTappedEvent event,
    Emitter<ProductScannerState> emit,
  ) {
    emit(state.copyWith(isFlashOn: !state.isFlashOn));
  }

  void _onModeChanged(
    ModeChangedEvent event,
    Emitter<ProductScannerState> emit,
  ) {
    if (state.mode == event.mode) return;

    final initialMessage = event.mode == ScannerCaptureMode.barcode
        ? 'Align barcode or QR code inside the frame'
        : 'Place the product front label inside the frame';

    emit(
      state.copyWith(
        mode: event.mode,
        isReadyToCapture: false,
        consecutiveReadyFrames: 0,
        guidanceMessage: initialMessage,
      ),
    );
  }

  Future<void> _onImageCapturedOrPicked(
    ImageCapturedOrPickedEvent event,
    Emitter<ProductScannerState> emit,
  ) async {
    emit(
      state.copyWith(
        step: ProductScannerStep.processingImage,
        capturedImagePath: event.imagePath,
        consecutiveReadyFrames: 0,
      ),
    );

    try {
      final result = await _processProductUseCase(event.imagePath);

      if (result.extractedRawText.trim().isEmpty) {
        emit(
          state.copyWith(
            step: ProductScannerStep.cameraGuidance,
            isReadyToCapture: false,
            guidanceMessage: 'No text detected — please try again closer',
            errorMessage: 'Could not read text on the product.',
          ),
        );
        return;
      }

      emit(
        state.copyWith(
          step: ProductScannerStep.completed,
          scansLeft: (state.scansLeft > 0) ? state.scansLeft - 1 : 0,
          result: result,
        ),
      );
    } on Exception catch (_) {
      emit(
        state.copyWith(
          step: ProductScannerStep.failure,
          errorMessage: 'Unable to analyze this product. Please try again.',
        ),
      );
    }
  }

  Future<void> _onBarcodeDetected(
    BarcodeDetectedEvent event,
    Emitter<ProductScannerState> emit,
  ) async {
    // Ignore duplicate detections once a code is already locked.
    if (state.step == ProductScannerStep.barcodeLocked) return;

    emit(
      state.copyWith(
        step: ProductScannerStep.barcodeLocked,
        consecutiveReadyFrames: 0,
        detectedBarcode: DetectedBarcode(
          value: event.barcode,
          normalizedBox: event.normalizedBox,
        ),
      ),
    );

    try {
      final results = await Future.wait<Object?>([
        _processBarcodeUseCase(barcode: event.barcode),
        Future<void>.delayed(_minBarcodeLockDuration),
      ]);
      final result = results.first! as ScannedProductResult;
      emit(
        state.copyWith(
          step: ProductScannerStep.completed,
          scansLeft: (state.scansLeft > 0) ? state.scansLeft - 1 : 0,
          result: result,
        ),
      );
    } on Exception catch (_) {
      emit(
        state.copyWith(
          step: ProductScannerStep.failure,
          clearDetectedBarcode: true,
          errorMessage: 'Unable to resolve barcode. Please try again.',
        ),
      );
    }
  }

  void _onBackToCamera(
    BackToCameraEvent event,
    Emitter<ProductScannerState> emit,
  ) {
    emit(
      state.copyWith(
        step: ProductScannerStep.cameraGuidance,
        isReadyToCapture: false,
        consecutiveReadyFrames: 0,
        clearDetectedBarcode: true,
        guidanceMessage: state.mode == ScannerCaptureMode.barcode
            ? 'Align barcode or QR code inside the frame'
            : 'Place the product front label inside the frame',
      ),
    );
  }

  void _onRetryScan(
    RetryScanEvent event,
    Emitter<ProductScannerState> emit,
  ) {
    emit(
      state.copyWith(
        step: ProductScannerStep.cameraGuidance,
        isReadyToCapture: false,
        consecutiveReadyFrames: 0,
        clearDetectedBarcode: true,
      ),
    );
  }

  @override
  Future<void> close() async {
    await _repository.dispose();
    return super.close();
  }
}
