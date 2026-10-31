// ignore_for_file: document_ignores, lines_longer_than_80_chars, prefer_initializing_formals

import 'dart:convert';

import 'package:flutter/foundation.dart';
import 'package:get_it/get_it.dart';
import 'package:kora/core/network/api_endpoints.dart';
import 'package:kora/core/network/kora_ai_api_client.dart';
import 'package:kora/features/onboarding/domain/entities/user_skin_profile.dart';
import 'package:kora/features/product_scanner/data/models/skincare_report_model.dart';

/// Datasource contract for remote product lookup via text or barcode.
abstract class ProductRemoteDataSource {
  /// Searches the product catalogue using OCR-extracted text and lines.
  Future<Map<String, dynamic>> searchProductByOcrText({
    required String rawText,
    required List<String> lines,
    required String imagePath,
    UserSkinProfile? userProfile,
    List<String> currentRoutineIngredients = const [],
  });

  /// Searches the product catalogue using a scanned barcode.
  Future<Map<String, dynamic>> searchProductByBarcode({
    required String barcode,
    String? imagePath,
    UserSkinProfile? userProfile,
    List<String> currentRoutineIngredients = const [],
  });
}

/// Production implementation with Kora AI backend (`POST /scan-product`)
/// integration orchestrating skincareScanWorkflow and resilient offline fallback.
class ProductRemoteDataSourceImpl implements ProductRemoteDataSource {
  /// Creates a [ProductRemoteDataSourceImpl].
  const ProductRemoteDataSourceImpl({
    KoraAiApiClient? aiApiClient,
  }) : _aiApiClient = aiApiClient;

  final KoraAiApiClient? _aiApiClient;

  KoraAiApiClient get _client {
    if (_aiApiClient != null) return _aiApiClient;
    final getIt = GetIt.instance;
    if (getIt.isRegistered<KoraAiApiClient>()) {
      return getIt<KoraAiApiClient>();
    }
    return KoraAiApiClient();
  }

  @override
  Future<Map<String, dynamic>> searchProductByOcrText({
    required String rawText,
    required List<String> lines,
    required String imagePath,
    UserSkinProfile? userProfile,
    List<String> currentRoutineIngredients = const [],
  }) async {
    final client = _client;
    final topLines = lines
        .where((l) => l.trim().length > 1)
        .take(8)
        .join(' ')
        .trim();
    final query = (rawText.trim().isNotEmpty && rawText.length <= 400)
        ? rawText.trim()
        : (topLines.isNotEmpty ? topLines : rawText.trim());
    var hadNetworkAttempt = false;

    if (await client.isConfigured()) {
      hadNetworkAttempt = true;
      try {
        final request = ScanProductRequestModel.fromInput(
          rawInput: query,
          profile: userProfile,
          currentRoutineIngredients: currentRoutineIngredients,
        );
        final response = await client.post(
          ApiEndpoints.scanProduct,
          data: request.toJson(),
        );
        final result = Map<String, dynamic>.from(response);
        result['image_path'] = imagePath;
        result['raw_ocr'] = query;
        result['product_id'] ??=
            'prod-${DateTime.now().millisecondsSinceEpoch}';
        return result;
      } on Object catch (e, st) {
        debugPrint('[ProductRemoteDataSource] /scan-product error: $e\n$st');
        // Fallback: direct agent query if workflow endpoint is busy
        try {
          final agentResponse = await client.post(
            '/api/agents/staticProductBuilder/generate',
            data: {
              'messages': [
                {
                  'role': 'user',
                  'content':
                      'Analyze cosmetic product: $query. Return full JSON.',
                },
              ],
            },
          );
          final extracted = _extractJsonFromAgentResponse(agentResponse);
          extracted['image_path'] = imagePath;
          extracted['raw_ocr'] = query;
          extracted['product_id'] ??=
              'prod-${DateTime.now().millisecondsSinceEpoch}';
          return extracted;
        } on Object catch (e2, st2) {
          debugPrint(
            '[ProductRemoteDataSource] fallback agent error: $e2\n$st2',
          );
        }
      }
    }

    final brand = lines.isNotEmpty ? lines.first : 'Scanned Product';
    final name = lines.length > 1
        ? lines.skip(1).take(2).join(' ')
        : (lines.isNotEmpty ? lines.first : query);

    return _buildOfflineReportJson(
      brand: brand,
      name: name,
      rawInput: rawText,
      imagePath: imagePath,
      isNetworkFailure: hadNetworkAttempt,
    );
  }

  @override
  Future<Map<String, dynamic>> searchProductByBarcode({
    required String barcode,
    String? imagePath,
    UserSkinProfile? userProfile,
    List<String> currentRoutineIngredients = const [],
  }) async {
    final client = _client;
    var hadNetworkAttempt = false;

    if (await client.isConfigured()) {
      hadNetworkAttempt = true;
      try {
        final request = ScanProductRequestModel.fromInput(
          rawInput: barcode,
          profile: userProfile,
          currentRoutineIngredients: currentRoutineIngredients,
        );
        final response = await client.post(
          ApiEndpoints.scanProduct,
          data: request.toJson(),
        );
        final result = Map<String, dynamic>.from(response);
        result['image_path'] = imagePath ?? '';
        result['raw_ocr'] = barcode;
        result['product_id'] ??=
            'prod-${DateTime.now().millisecondsSinceEpoch}';
        return result;
      } on Object catch (e, st) {
        debugPrint('[ProductRemoteDataSource] /scan-product error: $e\n$st');
        // Fallback: direct agent query if workflow endpoint is busy
        try {
          final agentResponse = await client.post(
            '/api/agents/staticProductBuilder/generate',
            data: {
              'messages': [
                {
                  'role': 'user',
                  'content':
                      'Analyze cosmetic barcode: $barcode. Return full JSON.',
                },
              ],
            },
          );
          final extracted = _extractJsonFromAgentResponse(agentResponse);
          extracted['image_path'] = imagePath ?? '';
          extracted['raw_ocr'] = barcode;
          extracted['product_id'] ??=
              'prod-${DateTime.now().millisecondsSinceEpoch}';
          return extracted;
        } on Object catch (e2, st2) {
          debugPrint(
            '[ProductRemoteDataSource] fallback agent error: $e2\n$st2',
          );
        }
      }
    }

    return _buildOfflineReportJson(
      brand: 'Scanned Barcode',
      name: 'Item $barcode',
      rawInput: barcode,
      imagePath: imagePath ?? '',
      isNetworkFailure: hadNetworkAttempt,
    );
  }

  static Map<String, dynamic> _extractJsonFromAgentResponse(
    Map<String, dynamic> response,
  ) {
    if (response.containsKey('productName') ||
        response.containsKey('product') ||
        response.containsKey('inciAnalysis')) {
      return response;
    }
    final text = response['text']?.toString() ?? '';
    if (text.isNotEmpty) {
      var raw = text.trim();
      if (raw.startsWith('```json')) {
        raw = raw.substring(7);
      } else if (raw.startsWith('```')) {
        raw = raw.substring(3);
      }
      if (raw.endsWith('```')) {
        raw = raw.substring(0, raw.length - 3);
      }
      raw = raw.trim();
      try {
        final decoded = jsonDecode(raw);
        if (decoded is Map<String, dynamic>) {
          return decoded;
        }
      } on Object {
        // Fall through
      }
    }
    return response;
  }

  static Map<String, dynamic> _buildOfflineReportJson({
    required String brand,
    required String name,
    required String rawInput,
    required String imagePath,
    bool isNetworkFailure = false,
  }) {
    return {
      'matched': false,
      'product_id': 'offline-${DateTime.now().millisecondsSinceEpoch}',
      'brand': brand,
      'product_name': name,
      'raw_ocr': rawInput,
      'image_path': imagePath,
      'product': {
        'brand': brand,
        'name': name,
        'category': 'Cosmetic Care',
        'imageUrl': null,
      },
      'personalizedVerdict': {
        'matchScore': 0,
        'matchVerdict': 'Analysis Pending',
        'headlineReason': isNetworkFailure
            ? 'AI server response delayed. Local scan saved.'
            : 'Product captured locally without live connection.',
        'explanation': isNetworkFailure
            ? 'The skincare analysis server is currently busy or unreachable. Tap to retry.'
            : 'Connect to the internet to run full AI INCI safety breakdown.',
        'benefitsForUser': <String>[],
        'concernsOrRisksForUser': <String>[
          if (isNetworkFailure)
            'Server response timed out. Saved locally.'
          else
            'Live AI analysis unavailable offline.',
        ],
        'routineCompatibility': {
          'isCompatibleWithCurrentRoutine': true,
          'conflictingIngredients': <String>[],
          'integrationAdvice': isNetworkFailure
              ? 'Retry analysis when the network stabilizes.'
              : 'Reconnect to internet for routine safety verification.',
        },
      },
      'applicationGuide': {
        'steps': <String>[
          'Follow instructions printed on product packaging.',
        ],
        'videoUrl': null,
      },
      'purchaseOptions': {
        'available': false,
      },
      'formulaStatic': <Map<String, dynamic>>[],
    };
  }
}
