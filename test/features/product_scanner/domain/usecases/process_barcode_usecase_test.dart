import 'package:flutter_test/flutter_test.dart';
import 'package:kora/features/product_scanner/domain/entities/detected_barcode.dart';
import 'package:kora/features/product_scanner/domain/entities/product_frame_evaluation.dart';
import 'package:kora/features/product_scanner/domain/entities/scanned_product_result.dart';
import 'package:kora/features/product_scanner/domain/repositories/product_scanner_repository.dart';
import 'package:kora/features/product_scanner/domain/usecases/process_barcode_usecase.dart';

class FakeBarcodeScannerRepository implements ProductScannerRepository {
  @override
  Future<RawOcrFrameData> analyzeLiveTextFrame({
    required dynamic cameraImage,
    required dynamic cameraDescription,
  }) async {
    throw UnimplementedError();
  }

  @override
  Future<DetectedBarcode?> analyzeLiveBarcodeFrame({
    required dynamic cameraImage,
    required dynamic cameraDescription,
  }) async {
    throw UnimplementedError();
  }

  @override
  Future<ScannedProductResult> extractTextAndSearchBackend(
    String imagePath,
  ) async {
    throw UnimplementedError();
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
      backendProductData: {'barcode': barcode, 'matched': true},
    );
  }

  @override
  Future<void> dispose() async {}
}

void main() {
  test('ProcessBarcodeUseCase forwards barcode lookup to repository', () async {
    final repo = FakeBarcodeScannerRepository();
    final useCase = ProcessBarcodeUseCase(repo);

    final result = await useCase(barcode: '3337875597357');

    expect(result.barcodeValue, '3337875597357');
    expect(result.sourceMode, ScanSourceMode.barcode);
    expect(result.backendProductData['matched'], isTrue);
  });
}
