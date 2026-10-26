import 'package:kora/features/product_scanner/domain/entities/scanned_product_result.dart';
import 'package:kora/features/product_scanner/domain/repositories/product_scanner_repository.dart';

/// Usecase to search product backend by scanned barcode value.
class ProcessBarcodeUseCase {
  /// Creates a [ProcessBarcodeUseCase].
  const ProcessBarcodeUseCase(this._repository);

  final ProductScannerRepository _repository;

  /// Executes barcode lookup.
  Future<ScannedProductResult> call({
    required String barcode,
    String? capturedImagePath,
  }) {
    return _repository.searchByBarcode(
      barcode: barcode,
      capturedImagePath: capturedImagePath,
    );
  }
}
