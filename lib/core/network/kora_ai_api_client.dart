// ignore_for_file: document_ignores, prefer_initializing_formals, lines_longer_than_80_chars

import 'package:dio/dio.dart';
import 'package:flutter/services.dart';
import 'package:kora/core/error/exceptions.dart';
import 'package:kora/core/network/api_endpoints.dart';
import 'package:supabase/supabase.dart' hide AuthException, Headers;

/// HTTP client dedicated to the Kora Skin Coach AI backend on Render.
///
/// Automatically injects:
/// - `Authorization: Bearer <MASTRA_API_SECRET>`
/// - `x-user-jwt: <SUPABASE_ACCESS_TOKEN>`
/// - `x-user-id: <SUPABASE_USER_ID>`
class KoraAiApiClient {
  /// Creates a [KoraAiApiClient].
  KoraAiApiClient({
    Dio? dio,
    SupabaseClient? supabaseClient,
    String? apiSecret,
    String? baseUrl,
    String? fallbackUserId,
    String? fallbackUserJwt,
  }) : _supabaseClient = supabaseClient,
       _apiSecretOverride = apiSecret,
       _baseUrlOverride = baseUrl,
       _fallbackUserId = fallbackUserId,
       _fallbackUserJwt = fallbackUserJwt,
       _dio =
           dio ??
           Dio(
             BaseOptions(
               baseUrl: baseUrl ?? ApiEndpoints.defaultBaseUrl,
               connectTimeout: const Duration(
                 milliseconds: ApiEndpoints.connectTimeoutMs,
               ),
               receiveTimeout: const Duration(
                 milliseconds: ApiEndpoints.receiveTimeoutMs,
               ),
               sendTimeout: const Duration(
                 milliseconds: ApiEndpoints.sendTimeoutMs,
               ),
               headers: {
                 Headers.contentTypeHeader: Headers.jsonContentType,
                 Headers.acceptHeader: Headers.jsonContentType,
               },
             ),
           ) {
    _dio.interceptors.add(
      InterceptorsWrapper(
        onRequest: (options, handler) async {
          await _ensureEnvLoaded();

          if (_resolvedBaseUrl.isNotEmpty &&
              options.baseUrl == ApiEndpoints.defaultBaseUrl) {
            options.baseUrl = _resolvedBaseUrl;
          }

          // Public health check requires no authentication headers.
          if (options.path == ApiEndpoints.health) {
            return handler.next(options);
          }

          final secret = _resolvedApiSecret;
          if (secret.isNotEmpty) {
            options.headers['Authorization'] = 'Bearer $secret';
          }

          final jwt = currentUserJwt;
          if (jwt.isNotEmpty) {
            options.headers['x-user-jwt'] = jwt;
          }

          final uid = currentUserId;
          if (uid.isNotEmpty) {
            options.headers['x-user-id'] = uid;
          }

          return handler.next(options);
        },
      ),
    );
  }

  final Dio _dio;
  final SupabaseClient? _supabaseClient;
  final String? _apiSecretOverride;
  final String? _baseUrlOverride;
  final String? _fallbackUserId;
  final String? _fallbackUserJwt;

  Map<String, String>? _envCache;

  /// Parses key-value lines from `.env` content.
  static Map<String, String> parseDotEnv(String content) {
    final result = <String, String>{};
    for (final rawLine in content.split('\n')) {
      final line = rawLine.trim();
      if (line.isEmpty || line.startsWith('#')) continue;
      final eqIndex = line.indexOf('=');
      if (eqIndex <= 0) continue;
      final key = line.substring(0, eqIndex).trim();
      var value = line.substring(eqIndex + 1).trim();
      if ((value.startsWith('"') && value.endsWith('"')) ||
          (value.startsWith("'") && value.endsWith("'"))) {
        value = value.substring(1, value.length - 1);
      }
      result[key] = value;
    }
    return result;
  }

  Future<void> _ensureEnvLoaded() async {
    if (_envCache != null) return;
    try {
      final rawEnv = await rootBundle.loadString('.env');
      _envCache = parseDotEnv(rawEnv);
    } on Object {
      _envCache = const {};
    }
  }

  String get _resolvedBaseUrl {
    if (_baseUrlOverride != null && _baseUrlOverride.isNotEmpty) {
      return _baseUrlOverride;
    }
    final envUrl = _envCache?['KORA_AI_BASE_URL']?.trim();
    if (envUrl != null && envUrl.isNotEmpty) {
      return envUrl;
    }
    return ApiEndpoints.defaultBaseUrl;
  }

  String get _resolvedApiSecret {
    if (_apiSecretOverride != null && _apiSecretOverride.isNotEmpty) {
      return _apiSecretOverride;
    }
    if (ApiEndpoints.compileTimeApiSecret.isNotEmpty) {
      return ApiEndpoints.compileTimeApiSecret;
    }
    final envSecret = _envCache?['MASTRA_API_SECRET']?.trim() ?? '';
    if (envSecret.isNotEmpty && envSecret != 'YOUR_MASTRA_API_SECRET_HERE') {
      return envSecret;
    }
    return ApiEndpoints.defaultApiSecret;
  }

  /// Whether a real `MASTRA_API_SECRET` is configured.
  Future<bool> isConfigured() async {
    await _ensureEnvLoaded();
    return _resolvedApiSecret.isNotEmpty;
  }

  /// Resolves the active Supabase user ID or fallback anonymous ID.
  String get currentUserId {
    final supabaseUid = _supabaseClient?.auth.currentUser?.id;
    if (supabaseUid != null && supabaseUid.isNotEmpty) {
      return supabaseUid;
    }
    return _fallbackUserId ?? 'anonymous-user';
  }

  /// Resolves the active Supabase session JWT or fallback token.
  String get currentUserJwt {
    final token = _supabaseClient?.auth.currentSession?.accessToken;
    if (token != null && token.isNotEmpty) {
      return token;
    }
    return _fallbackUserJwt ?? '';
  }

  /// Performs a public `GET /health` check against the Kora AI backend.
  Future<bool> checkHealth() async {
    try {
      final response = await _dio.get<dynamic>(ApiEndpoints.health);
      final status = response.statusCode ?? 500;
      return status >= 200 && status < 300;
    } on DioException catch (e) {
      throw _mapDioException(e);
    } on Object catch (e) {
      throw ServerException(message: 'Health check failed: $e', cause: e);
    }
  }

  /// Sends an authenticated `POST` request with a JSON [data] payload.
  Future<Map<String, dynamic>> post(
    String path, {
    required Map<String, dynamic> data,
  }) async {
    try {
      final response = await _dio.post<Map<String, dynamic>>(
        path,
        data: data,
      );
      final responseData = response.data;
      if (responseData == null) {
        throw ServerException(
          message: 'Empty response from $path',
          statusCode: response.statusCode,
        );
      }
      return responseData;
    } on DioException catch (e) {
      throw _mapDioException(e);
    } on AppException {
      rethrow;
    } on Object catch (e) {
      throw ServerException(
        message: 'Unexpected error calling $path: $e',
        cause: e,
      );
    }
  }

  AppException _mapDioException(DioException e) {
    final statusCode = e.response?.statusCode;
    final responseData = e.response?.data;
    String? serverMessage;
    if (responseData is Map<String, dynamic>) {
      serverMessage =
          responseData['message']?.toString() ??
          responseData['error']?.toString();
    }

    switch (e.type) {
      case DioExceptionType.connectionTimeout:
      case DioExceptionType.sendTimeout:
      case DioExceptionType.receiveTimeout:
      case DioExceptionType.connectionError:
        final detail = e.error != null ? ' (${e.error})' : '';
        return NetworkException(
          message:
              serverMessage ??
              'Unable to reach Kora AI Coach$detail. Check your internet connection and try again.',
          statusCode: statusCode,
          cause: e,
        );
      case DioExceptionType.badResponse:
        if (statusCode == 401 || statusCode == 403) {
          return AuthException(
            message:
                serverMessage ??
                'Session expired or unauthorized. Please sign in again.',
            statusCode: statusCode,
            cause: e,
          );
        }
        return ServerException(
          message:
              serverMessage ??
              'Kora AI service encountered an error (HTTP $statusCode). Please try again.',
          statusCode: statusCode,
          cause: e,
        );
      case DioExceptionType.cancel:
      case DioExceptionType.badCertificate:
      case DioExceptionType.unknown:
      // ignore: no_default_cases
      default:
        return NetworkException(
          message:
              serverMessage ??
              'Network interruption while communicating with Kora AI.',
          statusCode: statusCode,
          cause: e,
        );
    }
  }
}
