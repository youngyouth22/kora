import 'package:flutter_test/flutter_test.dart';
import 'package:kora/features/product_scanner/domain/entities/detected_barcode.dart';
import 'package:kora/features/product_scanner/domain/entities/product_frame_evaluation.dart';
import 'package:kora/features/product_scanner/domain/entities/scanned_product_result.dart';
import 'package:kora/features/product_scanner/domain/repositories/product_scanner_repository.dart';
import 'package:kora/features/product_scanner/domain/usecases/process_and_search_product_usecase.dart';

class FakeProductScannerRepository implements ProductScannerRepository {
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
    return ScannedProductResult(
      imagePath: imagePath,
      extractedRawText: 'CeraVe Foaming Cleanser',
      detectedLines: const ['CeraVe', 'Foaming Cleanser'],
      sourceMode: ScanSourceMode.productPhoto,
      backendProductData: const {'id': '123', 'name': 'CeraVe Foaming'},
    );
  }

  @override
  Future<ScannedProductResult> searchByBarcode({
    required String barcode,
    String? capturedImagePath,
  }) async {
    throw UnimplementedError();
  }

  @override
  Future<void> dispose() async {}
}

void main() {
  test('ProcessAndSearchProductUseCase forwards call to repository', () async {
    final repo = FakeProductScannerRepository();
    final useCase = ProcessAndSearchProductUseCase(repo);

    final result = await useCase('path/to/cerave.jpg');

    expect(result.imagePath, 'path/to/cerave.jpg');
    expect(result.extractedRawText, 'CeraVe Foaming Cleanser');
    expect(result.sourceMode, ScanSourceMode.productPhoto);
    expect(result.backendProductData['name'], 'CeraVe Foaming');
  });
}
