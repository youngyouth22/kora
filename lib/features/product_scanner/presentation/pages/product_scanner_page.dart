import 'dart:async';
import 'dart:io';

import 'package:camera/camera.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:get_it/get_it.dart';
import 'package:go_router/go_router.dart';
import 'package:image_picker/image_picker.dart';
import 'package:kora/common/app_colors.dart';
import 'package:kora/common/app_typography.dart';
import 'package:kora/core/network/kora_ai_api_client.dart';
import 'package:kora/core/router/app_routes.dart';
import 'package:kora/features/product_scanner/data/datasources/mlkit_barcode_datasource.dart';
import 'package:kora/features/product_scanner/data/datasources/mlkit_text_ocr_datasource.dart';
import 'package:kora/features/product_scanner/data/datasources/product_remote_datasource.dart';
import 'package:kora/features/product_scanner/data/repositories/product_scanner_repository_impl.dart';
import 'package:kora/features/product_scanner/domain/entities/scanned_product_result.dart';
import 'package:kora/features/product_scanner/domain/repositories/product_scanner_repository.dart';
import 'package:kora/features/product_scanner/domain/usecases/evaluate_product_frame_usecase.dart';
import 'package:kora/features/product_scanner/domain/usecases/process_and_search_product_usecase.dart';
import 'package:kora/features/product_scanner/domain/usecases/process_barcode_usecase.dart';
import 'package:kora/features/product_scanner/presentation/bloc/product_scanner_bloc.dart';
import 'package:kora/features/product_scanner/presentation/bloc/product_scanner_event.dart';
import 'package:kora/features/product_scanner/presentation/bloc/product_scanner_state.dart';
import 'package:kora/features/product_scanner/presentation/widgets/camera_capture_view.dart';
import 'package:kora/features/product_scanner/presentation/widgets/processing_scan_view.dart';

/// Main product scanner page orchestrating live camera streaming,
/// barcode / OCR mode switching, auto-capture, and the processing view.
class ProductScannerPage extends StatelessWidget {
  /// Creates a [ProductScannerPage].
  const ProductScannerPage({
    this.initialScansLeft = 2,
    this.onProductFound,
    super.key,
  });

  /// Remaining scan quota.
  final int initialScansLeft;

  /// Optional completion callback. Defaults to navigating to ingredient
  /// analysis.
  final void Function(ScannedProductResult result)? onProductFound;

  @override
  Widget build(BuildContext context) {
    final getIt = GetIt.instance;
    final repository = getIt.isRegistered<ProductScannerRepository>()
        ? getIt<ProductScannerRepository>()
        : ProductScannerRepositoryImpl(
            ocrDataSource: getIt.isRegistered<MlkitTextOcrDataSource>()
                ? getIt<MlkitTextOcrDataSource>()
                : MlkitTextOcrDataSource(),
            barcodeDataSource: getIt.isRegistered<MlkitBarcodeDataSource>()
                ? getIt<MlkitBarcodeDataSource>()
                : MlkitBarcodeDataSource(),
            remoteDataSource: getIt.isRegistered<ProductRemoteDataSource>()
                ? getIt<ProductRemoteDataSource>()
                : ProductRemoteDataSourceImpl(
                    aiApiClient: getIt.isRegistered<KoraAiApiClient>()
                        ? getIt<KoraAiApiClient>()
                        : null,
                  ),
          );

    return BlocProvider(
      create: (_) => ProductScannerBloc(
        repository: repository,
        evaluateFrameUseCase: EvaluateProductFrameUseCase(),
        processProductUseCase: ProcessAndSearchProductUseCase(repository),
        processBarcodeUseCase: ProcessBarcodeUseCase(repository),
        initialScansLeft: initialScansLeft,
      ),
      child: _ProductScannerView(onProductFound: onProductFound),
    );
  }
}

class _ProductScannerView extends StatefulWidget {
  const _ProductScannerView({this.onProductFound});

  final void Function(ScannedProductResult result)? onProductFound;

  @override
  State<_ProductScannerView> createState() => _ProductScannerViewState();
}

class _ProductScannerViewState extends State<_ProductScannerView>
    with WidgetsBindingObserver {
  CameraController? _cameraController;
  late CameraDescription _backCamera;
  final ImagePicker _imagePicker = ImagePicker();
  bool _isTakingPicture = false;
  bool _isPreviewPaused = false;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    unawaited(
      SystemChrome.setPreferredOrientations([DeviceOrientation.portraitUp]),
    );
    unawaited(_initBackCamera());
  }

  Future<void> _initBackCamera() async {
    try {
      final cameras = await availableCameras();
      if (cameras.isEmpty) return;

      _backCamera = cameras.firstWhere(
        (c) => c.lensDirection == CameraLensDirection.back,
        orElse: () => cameras.first,
      );

      final controller = CameraController(
        _backCamera,
        ResolutionPreset.veryHigh,
        enableAudio: false,
        imageFormatGroup: Platform.isAndroid
            ? ImageFormatGroup.nv21
            : ImageFormatGroup.bgra8888,
      );

      await controller.initialize();
      await controller.setFlashMode(FlashMode.off);
      await _startStream(controller);

      if (mounted) {
        setState(() => _cameraController = controller);
      }
    } on Exception catch (_) {
      // Camera initialization failure handled via UI fallback
    }
  }

  Future<void> _startStream(CameraController controller) async {
    if (controller.value.isStreamingImages) return;

    await controller.startImageStream((CameraImage image) {
      if (!mounted || _isTakingPicture) return;
      context.read<ProductScannerBloc>().add(
        LiveCameraFrameEvent(image: image, camera: _backCamera),
      );
    });
  }

  Future<void> _takePhotoAndProcess() async {
    final controller = _cameraController;
    if (controller == null ||
        !controller.value.isInitialized ||
        _isTakingPicture) {
      return;
    }

    _isTakingPicture = true;
    try {
      await HapticFeedback.mediumImpact();
      if (controller.value.isStreamingImages) {
        await controller.stopImageStream();
      }
      final file = await controller.takePicture();
      if (mounted) {
        context.read<ProductScannerBloc>().add(
          ImageCapturedOrPickedEvent(file.path),
        );
      }
    } on Exception catch (_) {
      _isTakingPicture = false;
      if (mounted && controller.value.isInitialized) {
        await _startStream(controller);
      }
    }
  }

  Future<void> _pickFromGallery() async {
    final picked = await _imagePicker.pickImage(
      source: ImageSource.gallery,
      imageQuality: 95,
    );
    if (picked != null && mounted) {
      if (_cameraController?.value.isStreamingImages ?? false) {
        await _cameraController!.stopImageStream();
      }
      if (mounted) {
        context.read<ProductScannerBloc>().add(
          ImageCapturedOrPickedEvent(picked.path),
        );
      }
    }
  }

  Future<void> _toggleFlash(bool shouldTurnOn) async {
    final controller = _cameraController;
    if (controller == null || !controller.value.isInitialized) return;
    try {
      await controller.setFlashMode(
        shouldTurnOn ? FlashMode.torch : FlashMode.off,
      );
    } on Exception catch (_) {
      // Flash mode change may be unsupported on some devices
    }
  }

  /// Freezes the preview so the lock-on overlay crops a still frame.
  Future<void> _freezePreview() async {
    final controller = _cameraController;
    if (controller == null || _isPreviewPaused) return;
    _isPreviewPaused = true;
    unawaited(HapticFeedback.mediumImpact());
    try {
      await controller.pausePreview();
    } on Exception catch (_) {
      // Pausing is best-effort; the overlay still works on a live preview.
    }
  }

  Future<void> _resumePreview() async {
    final controller = _cameraController;
    if (controller == null || !_isPreviewPaused) return;
    _isPreviewPaused = false;
    try {
      await controller.resumePreview();
    } on Exception catch (_) {
      // Resume failures leave the last frame; the user can close & reopen.
    }
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    unawaited(_cameraController?.dispose());
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.grey1050,
      body: BlocConsumer<ProductScannerBloc, ProductScannerState>(
        listener: (context, state) async {
          // 1. Synchronize physical torch
          await _toggleFlash(state.isFlashOn);

          // 1b. Barcode locked: freeze the frame for the lock-on overlay;
          // unfreeze as soon as we are back on the live viewfinder.
          if (state.step == ProductScannerStep.barcodeLocked) {
            await _freezePreview();
          } else if (state.step == ProductScannerStep.cameraGuidance) {
            await _resumePreview();
          }

          // 2. Auto-capture in product photo mode if stable
          if (state.step == ProductScannerStep.cameraGuidance &&
              state.mode == ScannerCaptureMode.productPhoto &&
              state.consecutiveReadyFrames >= 3 &&
              !_isTakingPicture) {
            await _takePhotoAndProcess();
          }

          // 3. Resume streaming if returning from processing view
          if (state.step == ProductScannerStep.cameraGuidance &&
              _isTakingPicture) {
            _isTakingPicture = false;
            if (_cameraController != null &&
                _cameraController!.value.isInitialized) {
              await _startStream(_cameraController!);
            }
          }

          // 4. Completed: redirect to result
          if (state.step == ProductScannerStep.completed &&
              state.result != null) {
            if (widget.onProductFound != null) {
              widget.onProductFound!(state.result!);
            } else if (context.mounted) {
              final productId =
                  state.result!.backendProductData['product_id']?.toString() ??
                  'demo-1';
              context.pushReplacement(
                AppRoutes.buildRoutineIngredientsPath(productId),
                extra: state.result,
              );
            }
          }
        },
        builder: (context, state) {
          // Screen 2: Processing view with animated laser
          if (state.step == ProductScannerStep.processingImage) {
            return ProcessingScanView(
              imagePath: state.capturedImagePath ?? '',
              onBack: () => context.read<ProductScannerBloc>().add(
                const BackToCameraEvent(),
              ),
            );
          }

          // Failure View
          if (state.step == ProductScannerStep.failure) {
            return Center(
              child: Padding(
                padding: const EdgeInsets.all(24),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Icon(
                      Icons.error_outline_rounded,
                      size: 56,
                      color: AppColors.error400,
                    ),
                    const SizedBox(height: 16),
                    Text(
                      'Scan Unsuccessful',
                      style: AppTypography.h5Bold.copyWith(
                        color: AppGreyColors.white,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      state.errorMessage ??
                          'Unable to recognize the product. Please try again.',
                      style: AppTypography.bodyMRegular.copyWith(
                        color: AppColors.grey400,
                      ),
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 24),
                    ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppColors.primary500,
                        foregroundColor: AppColors.grey1050,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(16),
                        ),
                        minimumSize: const Size(180, 48),
                      ),
                      onPressed: () => context.read<ProductScannerBloc>().add(
                        const RetryScanEvent(),
                      ),
                      child: Text(
                        'Try Again',
                        style: AppTypography.bodyMBold,
                      ),
                    ),
                  ],
                ),
              ),
            );
          }

          // Screen 1: Camera Guidance View
          final controller = _cameraController;
          if (controller == null || !controller.value.isInitialized) {
            return const Center(
              child: CircularProgressIndicator(
                color: AppColors.primary500,
              ),
            );
          }

          final isBarcodeLockVisible =
              state.step == ProductScannerStep.barcodeLocked ||
              state.step == ProductScannerStep.completed;

          return CameraCaptureView(
            cameraController: controller,
            currentMode: state.mode,
            scansLeft: state.scansLeft,
            isFlashOn: state.isFlashOn,
            isReadyToCapture: state.isReadyToCapture,
            hasTextInFrame: state.hasTextInFrame,
            guidanceMessage: state.guidanceMessage,
            lockedBarcode: isBarcodeLockVisible ? state.detectedBarcode : null,
            onModeChanged: (mode) => context.read<ProductScannerBloc>().add(
              ModeChangedEvent(mode),
            ),
            onToggleFlash: () => context.read<ProductScannerBloc>().add(
              const ToggleFlashTappedEvent(),
            ),
            onClose: () => Navigator.of(context).maybePop(),
            onPickFromGallery: () => unawaited(_pickFromGallery()),
            onTakePhoto: () => unawaited(_takePhotoAndProcess()),
            onHowToTap: () => _showHowToModal(context),
          );
        },
      ),
    );
  }

  void _showHowToModal(BuildContext context) {
    unawaited(
      showModalBottomSheet<void>(
        context: context,
        backgroundColor: AppColors.grey1000,
        shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
        ),
        builder: (_) => Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 28),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  const Icon(
                    Icons.help_outline_rounded,
                    color: AppColors.primary400,
                    size: 24,
                  ),
                  const SizedBox(width: 10),
                  Text(
                    'How to scan a product',
                    style: AppTypography.h6Bold.copyWith(
                      color: AppGreyColors.white,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),
              Text(
                '1. Select Product to frame the bottle or Barcode to scan.\n'
                '2. Align within the brackets and keep the camera steady.\n'
                '3. Brackets turn green when the frame is ready to scan.',
                style: AppTypography.bodyMRegular.copyWith(
                  color: AppColors.grey300,
                  height: 1.6,
                ),
              ),
              const SizedBox(height: 24),
            ],
          ),
        ),
      ),
    );
  }
}
