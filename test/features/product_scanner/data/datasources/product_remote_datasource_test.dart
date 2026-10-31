// ignore_for_file: document_ignores

import 'package:dio/dio.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:kora/core/network/api_endpoints.dart';
import 'package:kora/core/network/kora_ai_api_client.dart';
import 'package:kora/features/product_scanner/data/datasources/product_remote_datasource.dart';

class _FakeAdapter implements HttpClientAdapter {
  _FakeAdapter(this.handler);

  final Future<ResponseBody> Function(RequestOptions options) handler;

  @override
  Future<ResponseBody> fetch(
    RequestOptions options,
    Stream<List<int>>? requestStream,
    Future<void>? cancelFuture,
  ) {
    return handler(options);
  }

  @override
  void close({bool force = false}) {}
}

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  group('ProductRemoteDataSourceImpl', () {
    test(
      'searchProductByBarcode calls /scan-product and returns structured map',
      () async {
        RequestOptions? capturedOptions;
        final dio = Dio(BaseOptions(baseUrl: ApiEndpoints.defaultBaseUrl))
          ..httpClientAdapter = _FakeAdapter((options) async {
            capturedOptions = options;
            return ResponseBody.fromString(
              '''
{
  "product": {
    "brand": "La Roche-Posay",
    "name": "Effaclar Duo+",
    "category": "Treatment"
  },
  "matchEvaluation": {
    "overallFitPercentage": 92,
    "executiveSummary": "Excellent fit for acne-prone skin."
  }
}
''',
              200,
              headers: {
                Headers.contentTypeHeader: [Headers.jsonContentType],
              },
            );
          });

        final client = KoraAiApiClient(
          dio: dio,
          apiSecret: 'test-secret',
        );

        final dataSource = ProductRemoteDataSourceImpl(aiApiClient: client);

        final result = await dataSource.searchProductByBarcode(
          barcode: '3337875545778',
        );

        final product = result['product'] as Map<String, dynamic>;
        expect(capturedOptions?.path, ApiEndpoints.scanProduct);
        expect(product['brand'], 'La Roche-Posay');
        expect(result['raw_ocr'], '3337875545778');
      },
    );

    test(
      'searchProductByOcrText falls back to honest report if network times out',
      () async {
        final dio = Dio(BaseOptions(baseUrl: ApiEndpoints.defaultBaseUrl))
          ..httpClientAdapter = _FakeAdapter((options) async {
            throw DioException(
              requestOptions: options,
              type: DioExceptionType.receiveTimeout,
              message: 'Timeout',
            );
          });

        final client = KoraAiApiClient(
          dio: dio,
          apiSecret: 'test-secret',
        );

        final dataSource = ProductRemoteDataSourceImpl(aiApiClient: client);

        final result = await dataSource.searchProductByOcrText(
          rawText: 'Effaclar Duo',
          lines: const ['La Roche-Posay', 'Effaclar Duo'],
          imagePath: '/tmp/test.jpg',
        );

        final verdict = result['personalizedVerdict'] as Map<String, dynamic>;
        expect(result['matched'], isFalse);
        expect(result['brand'], 'La Roche-Posay');
        expect(
          verdict['headlineReason'],
          contains('AI server response delayed'),
        );
      },
    );
  });
}
