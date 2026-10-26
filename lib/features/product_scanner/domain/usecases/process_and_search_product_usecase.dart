import 'package:kora/features/product_scanner/domain/entities/scanned_product_result.dart';
import 'package:kora/features/product_scanner/domain/repositories/product_scanner_repository.dart';

/// Usecase to process captured high-resolution photo and search backend
/// product database.
class ProcessAndSearchProductUseCase {
  /// Creates a [ProcessAndSearchProductUseCase].
  const ProcessAndSearchProductUseCase(this._repository);

  final ProductScannerRepository _repository;

  /// Executes text extraction and backend product search.
  Future<ScannedProductResult> call(String imagePath) {
    return _repository.extractTextAndSearchBackend(imagePath);
  }
}
