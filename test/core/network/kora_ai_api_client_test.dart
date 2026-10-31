// ignore_for_file: document_ignores

import 'package:dio/dio.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:kora/core/error/exceptions.dart';
import 'package:kora/core/network/api_endpoints.dart';
import 'package:kora/core/network/kora_ai_api_client.dart';

class _FakeHttpClientAdapter implements HttpClientAdapter {
  _FakeHttpClientAdapter(this.handler);

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

  group('KoraAiApiClient', () {
    test('parseDotEnv parses key-value pairs and ignores comments', () {
      const content = '''
# Comment line
KORA_AI_BASE_URL=https://kora-skin-coach.onrender.com
MASTRA_API_SECRET="secret-token-123"
''';
      final parsed = KoraAiApiClient.parseDotEnv(content);
      expect(
        parsed['KORA_AI_BASE_URL'],
        'https://kora-skin-coach.onrender.com',
      );
      expect(parsed['MASTRA_API_SECRET'], 'secret-token-123');
    });

    test(
      'injects Bearer token, x-user-jwt, and x-user-id on authenticated POST',
      () async {
        RequestOptions? capturedOptions;
        final dio = Dio(BaseOptions(baseUrl: ApiEndpoints.defaultBaseUrl))
          ..httpClientAdapter = _FakeHttpClientAdapter((options) async {
            capturedOptions = options;
            return ResponseBody.fromString(
              '{"ok": true}',
              200,
              headers: {
                Headers.contentTypeHeader: [Headers.jsonContentType],
              },
            );
          });

        final client = KoraAiApiClient(
          dio: dio,
          apiSecret: 'mastra-secret-xyz',
          fallbackUserId: 'user-uuid-42',
          fallbackUserJwt: 'supabase-jwt-abc',
        );

        final res = await client.post(
          ApiEndpoints.coachChat,
          data: {'message': 'Hello'},
        );

        expect(res['ok'], isTrue);
        expect(
          capturedOptions?.headers['Authorization'],
          'Bearer mastra-secret-xyz',
        );
        expect(capturedOptions?.headers['x-user-id'], 'user-uuid-42');
        expect(capturedOptions?.headers['x-user-jwt'], 'supabase-jwt-abc');
      },
    );

    test(
      'checkHealth performs public GET /health without auth headers',
      () async {
        RequestOptions? capturedOptions;
        final dio = Dio(BaseOptions(baseUrl: ApiEndpoints.defaultBaseUrl))
          ..httpClientAdapter = _FakeHttpClientAdapter((options) async {
            capturedOptions = options;
            return ResponseBody.fromString('{"status":"ok"}', 200);
          });

        final client = KoraAiApiClient(
          dio: dio,
          apiSecret: 'mastra-secret-xyz',
          fallbackUserId: 'user-uuid-42',
          fallbackUserJwt: 'supabase-jwt-abc',
        );

        final healthy = await client.checkHealth();
        expect(healthy, isTrue);
        expect(capturedOptions?.path, ApiEndpoints.health);
        expect(capturedOptions?.headers.containsKey('Authorization'), isFalse);
      },
    );

    test('maps HTTP 401 badResponse to AuthException', () async {
      final dio = Dio(BaseOptions(baseUrl: ApiEndpoints.defaultBaseUrl))
        ..httpClientAdapter = _FakeHttpClientAdapter((options) async {
          return ResponseBody.fromString(
            '{"message":"Invalid Bearer token"}',
            401,
            headers: {
              Headers.contentTypeHeader: [Headers.jsonContentType],
            },
          );
        });

      final client = KoraAiApiClient(
        dio: dio,
        apiSecret: 'wrong-secret',
      );

      expect(
        () => client.post(ApiEndpoints.skinReport, data: const {}),
        throwsA(isA<AuthException>()),
      );
    });

    test('maps HTTP 500 badResponse to ServerException', () async {
      final dio = Dio(BaseOptions(baseUrl: ApiEndpoints.defaultBaseUrl))
        ..httpClientAdapter = _FakeHttpClientAdapter((options) async {
          return ResponseBody.fromString(
            '{"error":"LLM timeout"}',
            500,
            headers: {
              Headers.contentTypeHeader: [Headers.jsonContentType],
            },
          );
        });

      final client = KoraAiApiClient(
        dio: dio,
        apiSecret: 'mastra-secret-xyz',
      );

      expect(
        () => client.post(ApiEndpoints.scanProduct, data: const {}),
        throwsA(isA<ServerException>()),
      );
    });
  });
}
