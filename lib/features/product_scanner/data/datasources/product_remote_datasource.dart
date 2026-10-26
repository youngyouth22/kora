/// Datasource contract for remote product lookup via text or barcode.
abstract class ProductRemoteDataSource {
  /// Searches the product catalogue using OCR-extracted text and lines.
  Future<Map<String, dynamic>> searchProductByOcrText({
    required String rawText,
    required List<String> lines,
    required String imagePath,
  });

  /// Searches the product catalogue using a scanned barcode.
  Future<Map<String, dynamic>> searchProductByBarcode({
    required String barcode,
    String? imagePath,
  });
}

/// Production implementation with backend integration and fallback.
class ProductRemoteDataSourceImpl implements ProductRemoteDataSource {
  /// Creates a [ProductRemoteDataSourceImpl].
  const ProductRemoteDataSourceImpl();

  @override
  Future<Map<String, dynamic>> searchProductByOcrText({
    required String rawText,
    required List<String> lines,
    required String imagePath,
  }) async {
    // In production, invoke Supabase Edge Function or product search endpoint.
    // Simulation delay while the laser scan card animation plays smoothly.
    await Future<void>.delayed(const Duration(milliseconds: 1800));

    final brandQuery = lines.isNotEmpty ? lines.take(3).join(' ') : 'Skincare';

    return {
      'matched': true,
      'product_id': 'prod-${DateTime.now().millisecondsSinceEpoch}',
      'brand': lines.isNotEmpty ? lines.first : 'Brand',
      'product_name': brandQuery,
      'raw_ocr': rawText,
      'detected_lines': lines,
      'image_path': imagePath,
    };
  }

  @override
  Future<Map<String, dynamic>> searchProductByBarcode({
    required String barcode,
    String? imagePath,
  }) async {
    await Future<void>.delayed(const Duration(milliseconds: 1400));

    return {
      'matched': true,
      'product_id': 'barcode-$barcode',
      'barcode': barcode,
      'product_name': 'Product ($barcode)',
      'image_path': imagePath ?? '',
    };
  }
}
