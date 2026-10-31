// ignore_for_file: document_ignores, one_member_abstracts
// ignore_for_file: lines_longer_than_80_chars, prefer_initializing_formals

import 'dart:io';

import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';
import 'package:get_it/get_it.dart';
import 'package:kora/core/error/exceptions.dart';
import 'package:kora/core/network/api_endpoints.dart';
import 'package:kora/core/network/kora_ai_api_client.dart';
import 'package:kora/features/onboarding/domain/entities/user_skin_profile.dart';
import 'package:kora/features/onboarding/domain/repositories/user_profile_repository.dart';
import 'package:kora/features/skin_analysis/data/models/skin_analysis_result_model.dart';
import 'package:kora/features/skin_analysis/data/models/skin_report_model.dart';
import 'package:kora/features/skin_analysis/data/models/skin_report_request_model.dart';

/// Contract for remote skin analysis operations.
abstract class SkinAnalysisRemoteDataSource {
  /// Initiates and polls for skin analysis results.
  ///
  /// If [useMock] is true, returns realistic pre-recorded YouCam data
  /// to save API credits during development.
  Future<SkinAnalysisResultModel> analyzeSkin({
    required String imagePath,
    bool useMock = false,
  });
}

/// Remote data source implementation.
class SkinAnalysisRemoteDataSourceImpl implements SkinAnalysisRemoteDataSource {
  /// Creates a [SkinAnalysisRemoteDataSourceImpl].
  SkinAnalysisRemoteDataSourceImpl({
    Dio? dio,
    KoraAiApiClient? aiApiClient,
    UserSkinProfile? userProfile,
    List<String> currentRoutineIngredients = const [],
    String? youcamApiKey,
    String? youcamBaseUrl,
    String? supabaseUrl,
  }) : _dio = dio ?? Dio(),
       _aiApiClient = aiApiClient,
       _userProfile = userProfile,
       _currentRoutineIngredients = currentRoutineIngredients,
       _youcamApiKey = youcamApiKey ?? ApiEndpoints.youcamApiKey,
       _youcamBaseUrl = youcamBaseUrl ?? ApiEndpoints.youcamBaseUrl,
       _supabaseUrl = supabaseUrl ?? ApiEndpoints.supabaseUrl;

  final Dio _dio;
  final KoraAiApiClient? _aiApiClient;
  final UserSkinProfile? _userProfile;
  final List<String> _currentRoutineIngredients;
  final String _youcamApiKey;
  final String _youcamBaseUrl;
  final String _supabaseUrl;

  KoraAiApiClient get _client =>
      _aiApiClient ??
      (GetIt.instance.isRegistered<KoraAiApiClient>()
          ? GetIt.instance<KoraAiApiClient>()
          : KoraAiApiClient());

  /// Requests a personalized AI [SkinReportModel] from `POST /api/skin-report`
  /// on the Kora Skin Coach backend using normalized `raw_score` telemetry.
  Future<SkinReportModel> generateSkinReport({
    required SkinReportRequestModel request,
  }) async {
    final client = _client;
    final responseJson = await client.post(
      ApiEndpoints.skinReport,
      data: request.toJson(),
    );
    return ReportResultModel.fromJson(responseJson).report;
  }

  Future<SkinAnalysisResultModel> _enrichWithAiReportIfAvailable(
    SkinAnalysisResultModel baseResult,
  ) async {
    final client = _client;
    if (!(await client.isConfigured())) {
      return baseResult;
    }

    try {
      var profile = _userProfile;
      if (profile == null &&
          GetIt.instance.isRegistered<UserProfileRepository>()) {
        final profileRes = await GetIt.instance<UserProfileRepository>()
            .getProfile(id: 'local-user');
        profile = profileRes.fold((_) => null, (p) => p);
      }

      final request = SkinReportRequestModel.fromAnalysis(
        analysis: baseResult,
        userProfile: profile,
        fallbackUserId: client.currentUserId,
        currentRoutineIngredients: _currentRoutineIngredients,
      );
      final liveReport = await generateSkinReport(request: request);
      return baseResult.copyWithReport(liveReport);
    } on Object catch (e, st) {
      debugPrint('[SkinAnalysisRemoteDataSource] /skin-report error: $e\n$st');
      // Preserve offline/resilient fallback report if Render AI is unreachable.
      return baseResult;
    }
  }

  Future<SkinAnalysisResultModel> _analyzeWithYouCamDirect(
    String imagePath,
  ) async {
    final file = File(imagePath);
    if (!file.existsSync()) {
      throw const ServerException(message: 'Scan image file not found.');
    }

    final fileSize = file.lengthSync();
    final fileName = 'scan_${DateTime.now().millisecondsSinceEpoch}.jpg';

    // Step 1: Register file with YouCam API
    final fileRegRes = await _dio.post<Map<String, dynamic>>(
      '$_youcamBaseUrl/s2s/v2.0/file',
      data: {
        'files': [
          {
            'content_type': 'image/jpeg',
            'file_name': fileName,
            'file_size': fileSize,
          },
        ],
      },
      options: Options(
        headers: {
          'Authorization': 'Bearer $_youcamApiKey',
          'Content-Type': 'application/json',
          'X-Pxy-Src': 'kora',
        },
      ),
    );

    final fileData = fileRegRes.data;
    final fileDataObj = fileData?['data'] as Map<String, dynamic>?;
    final filesList = fileDataObj?['files'] as List<dynamic>?;
    final fileObj = filesList?.firstOrNull as Map<String, dynamic>?;
    final fileId = fileObj?['file_id']?.toString();
    final reqList = fileObj?['requests'] as List<dynamic>?;
    final reqObj = reqList?.firstOrNull as Map<String, dynamic>?;
    final uploadUrl = reqObj?['url']?.toString();
    final uploadHeaders =
        (reqObj?['headers'] as Map<String, dynamic>?)?.map(
          (k, v) => MapEntry(k, v.toString()),
        ) ??
        {};

    if (fileId == null || uploadUrl == null) {
      throw const ServerException(message: 'YouCam file registration failed.');
    }

    // Step 2: Upload image bytes to YouCam pre-signed S3 URL
    final bytes = await file.readAsBytes();
    await _dio.put<void>(
      uploadUrl,
      data: Stream.fromIterable([bytes]),
      options: Options(
        headers: {
          Headers.contentLengthHeader: bytes.length,
          'Content-Type': 'image/jpeg',
          ...uploadHeaders,
        },
      ),
    );

    // Step 3: Trigger skin analysis task with all 16 SD actions and mask overlays
    const actions = [
      'wrinkle',
      'pore',
      'texture',
      'acne',
      'oiliness',
      'radiance',
      'eye_bag',
      'age_spot',
      'dark_circle_v2',
      'droopy_upper_eyelid',
      'droopy_lower_eyelid',
      'firmness',
      'moisture',
      'redness',
      'tear_trough',
      'skin_type',
    ];

    final taskRes = await _dio.post<Map<String, dynamic>>(
      '$_youcamBaseUrl/s2s/v2.1/task/skin-analysis',
      data: {
        'src_file_id': fileId,
        'dst_actions': actions,
        'format': 'json',
        'miniserver_args': {'enable_mask_overlay': true},
      },
      options: Options(
        headers: {
          'Authorization': 'Bearer $_youcamApiKey',
          'Content-Type': 'application/json',
          'X-Pxy-Src': 'kora',
        },
      ),
    );

    final taskDataObj = taskRes.data?['data'] as Map<String, dynamic>?;
    final taskId = taskDataObj?['task_id']?.toString();
    if (taskId == null) {
      throw const ServerException(message: 'YouCam task creation failed.');
    }

    // Step 4: Poll task status (up to 45 seconds)
    for (var i = 0; i < 22; i++) {
      await Future<void>.delayed(const Duration(seconds: 2));
      final statusRes = await _dio.get<Map<String, dynamic>>(
        '$_youcamBaseUrl/s2s/v2.1/task/skin-analysis/$taskId',
        options: Options(
          headers: {
            'Authorization': 'Bearer $_youcamApiKey',
            'X-Pxy-Src': 'kora',
          },
        ),
      );

      final statusData = statusRes.data?['data'] as Map<String, dynamic>?;
      final taskStatus = statusData?['task_status']?.toString().toLowerCase();

      if (taskStatus == 'success' ||
          taskStatus == 'succeeded' ||
          taskStatus == 'completed') {
        final parsed = SkinAnalysisResultModel.fromJson(statusData!);
        return _enrichWithAiReportIfAvailable(parsed);
      }

      if (taskStatus == 'error' ||
          taskStatus == 'failed' ||
          taskStatus == 'failure') {
        final errorMsg =
            statusData?['error_message']?.toString() ??
            'YouCam analysis failed.';
        throw ServerException(message: errorMsg);
      }
    }

    throw const ServerException(message: 'YouCam task polling timed out.');
  }

  /// Executes skin analysis via Supabase Edge Function `/functions/v1/scan`.
  ///
  /// This orchestrates:
  /// - Server-side permission/gate checks
  /// - Direct S3 upload of the user's photo
  /// - YouCam AI execution
  /// - Storing mask images in the private 'scan-masks' Supabase storage bucket
  /// - Generating secure, time-limited signed URLs
  /// - Deleting user images from YouCam servers for privacy
  Future<SkinAnalysisResultModel> _analyzeWithSupabaseEdgeFunction(
    String imagePath,
  ) async {
    final file = File(imagePath);
    if (!file.existsSync()) {
      throw const ServerException(message: 'Scan image file not found.');
    }

    final jwt = _client.currentUserJwt;
    final headers = <String, String>{
      'Content-Type': 'application/json',
      if (jwt.isNotEmpty) 'Authorization': 'Bearer $jwt',
    };

    final edgeUrl = '$_supabaseUrl${ApiEndpoints.scanFunction}';

    // Step 1: Request upload target from Edge Function
    final startRes = await _dio.post<Map<String, dynamic>>(
      edgeUrl,
      data: {
        'action': 'start',
        'mode': 'HD',
        'content_type': 'image/jpeg',
        'file_size': file.lengthSync(),
      },
      options: Options(headers: headers),
    );

    final startData = startRes.data;
    if (startData == null) {
      throw const ServerException(
        message: 'Invalid start response from scan Edge Function.',
      );
    }

    final scanId = startData['scan_id']?.toString();
    final upload = startData['upload'] as Map<String, dynamic>?;
    final uploadUrl = upload?['url']?.toString();
    final uploadHeaders =
        (upload?['headers'] as Map<String, dynamic>?)?.map(
          (k, v) => MapEntry(k, v.toString()),
        ) ??
        {};

    if (scanId == null || uploadUrl == null) {
      throw const ServerException(
        message: 'Upload target not received from scan Edge Function.',
      );
    }

    // Step 2: Upload image directly to YouCam pre-signed upload URL
    final bytes = await file.readAsBytes();
    await _dio.put<void>(
      uploadUrl,
      data: Stream.fromIterable([bytes]),
      options: Options(
        headers: {
          Headers.contentLengthHeader: bytes.length,
          'Content-Type': 'image/jpeg',
          ...uploadHeaders,
        },
      ),
    );

    // Step 3: Run task (Edge Function triggers task and stores masks in bucket)
    await _dio.post<Map<String, dynamic>>(
      edgeUrl,
      data: {
        'action': 'run',
        'scan_id': scanId,
        'enable_mask_overlay': true,
      },
      options: Options(headers: headers),
    );

    // Step 4: Poll status until complete
    for (var i = 0; i < 25; i++) {
      await Future<void>.delayed(const Duration(seconds: 2));
      final statusRes = await _dio.post<Map<String, dynamic>>(
        edgeUrl,
        data: {
          'action': 'status',
          'scan_id': scanId,
        },
        options: Options(headers: headers),
      );

      final statusData = statusRes.data;
      final status = statusData?['status']?.toString().toLowerCase();

      if (status == 'done') {
        final parsed = SkinAnalysisResultModel.fromJson(statusData!);
        return _enrichWithAiReportIfAvailable(parsed);
      }

      if (status == 'failed') {
        final errorMsg =
            statusData?['message']?.toString() ??
            'Supabase scan analysis failed.';
        throw ServerException(message: errorMsg);
      }
    }

    throw const ServerException(
      message: 'Supabase scan Edge Function polling timed out.',
    );
  }

  @override
  Future<SkinAnalysisResultModel> analyzeSkin({
    required String imagePath,
    bool useMock = false,
  }) async {
    if (!useMock) {
      Object? lastError;

      // 1. Prioritize the Supabase Edge Function if user has an active Supabase session
      final jwt = _client.currentUserJwt;
      if (jwt.isNotEmpty) {
        try {
          debugPrint(
            '[SkinAnalysisRemoteDataSource] Running secure scan via Supabase Edge Function...',
          );
          return await _analyzeWithSupabaseEdgeFunction(imagePath);
        } on Object catch (e, st) {
          lastError = e;
          debugPrint(
            '[SkinAnalysisRemoteDataSource] Supabase Edge Function unavailable or failed: $e\n$st',
          );
        }
      } else {
        debugPrint(
          '[SkinAnalysisRemoteDataSource] No active Supabase JWT session, using direct YouCam API...',
        );
      }

      // 2. Direct YouCam API fallback (works without Supabase JWT)
      if (_youcamApiKey.isNotEmpty) {
        try {
          debugPrint(
            '[SkinAnalysisRemoteDataSource] Falling back to direct YouCam analysis...',
          );
          return await _analyzeWithYouCamDirect(imagePath);
        } on Object catch (e, st) {
          lastError = e;
          debugPrint(
            '[SkinAnalysisRemoteDataSource] Direct YouCam analysis failed: $e\n$st',
          );
        }
      }

      // Live scan requested: do NOT fall back to mock data!
      if (lastError is AppException) {
        throw lastError;
      } else if (lastError is Exception) {
        throw ServerException(message: lastError.toString());
      } else {
        throw const ServerException(
          message: 'Unable to reach YouCam AI or Supabase Edge Function. Check your connection and try again.',
        );
      }
    }

    // 3. High-fidelity fixture response provided ONLY when useMock == true (tests/preview)
    await Future<void>.delayed(const Duration(milliseconds: 1500));
    final base = SkinAnalysisResultModel.fromJson(_mockYouCamResponse);
    return _enrichWithAiReportIfAvailable(base);
  }

  /// Official YouCam Skin AI response structure with 16 concerns, scores, and masks.
  static final Map<String, dynamic> _mockYouCamResponse = {
    'status': 200,
    'data': {
      'error': null,
      'results': {
        'output': [
          {
            'ui_score': 70,
            'mask_urls': [
              'https://yce-us.s3-accelerate.amazonaws.com/ttl30/512028098225506616/122582823308/v2/aeMNNB0KmUIP8rnQ996tC5Q/d742498f-683c-45da-ac2d-a25cb6c8d4bf_tear_trough_output.png',
            ],
            'raw_score': 56.06722831726074,
            'type': 'tear_trough',
            'url': null,
          },
          {
            'ui_score': 63,
            'mask_urls': [
              'https://yce-us.s3-accelerate.amazonaws.com/ttl30/512028098225506616/122582823308/v2/aeMNNB0KmUIP8rnQ996tC5Q/d742498f-683c-45da-ac2d-a25cb6c8d4bf_droopy_lower_eyelid_output.png',
            ],
            'raw_score': 39.80274796485901,
            'type': 'droopy_lower_eyelid',
            'url': null,
          },
          {
            'ui_score': 58,
            'mask_urls': [
              'https://yce-us.s3-accelerate.amazonaws.com/ttl30/512028098225506616/122582823308/v2/aeMNNB0KmUIP8rnQ996tC5Q/d742498f-683c-45da-ac2d-a25cb6c8d4bf_eye_bag_output.png',
            ],
            'raw_score': 27.279239892959595,
            'type': 'eye_bag',
            'url': null,
          },
          {
            'ui_score': 81,
            'mask_urls': [
              'https://yce-us.s3-accelerate.amazonaws.com/ttl30/512028098225506616/122582823308/v2/aeMNNB0KmUIP8rnQ996tC5Q/d742498f-683c-45da-ac2d-a25cb6c8d4bf_droopy_upper_eyelid_output.png',
            ],
            'raw_score': 80.843186378479,
            'type': 'droopy_upper_eyelid',
            'url': null,
          },
          {
            'ui_score': 79,
            'mask_urls': [
              'https://yce-us.s3-accelerate.amazonaws.com/ttl30/512028098225506616/122582823308/v2/aeMNNB0KmUIP8rnQ996tC5Q/d742498f-683c-45da-ac2d-a25cb6c8d4bf_pore_output.png',
            ],
            'raw_score': 76.49276053905487,
            'type': 'pore',
            'url': null,
          },
          {
            'ui_score': 97,
            'mask_urls': [
              'https://yce-us.s3-accelerate.amazonaws.com/ttl30/512028098225506616/122582823308/v2/aeMNNB0KmUIP8rnQ996tC5Q/d742498f-683c-45da-ac2d-a25cb6c8d4bf_redness_output.png',
            ],
            'raw_score': 98.29679870605469,
            'type': 'redness',
            'url': null,
          },
          {
            'ui_score': 74,
            'mask_urls': [
              'https://yce-us.s3-accelerate.amazonaws.com/ttl30/512028098225506616/122582823308/v2/aeMNNB0KmUIP8rnQ996tC5Q/d742498f-683c-45da-ac2d-a25cb6c8d4bf_texture_output.png',
            ],
            'raw_score': 64.00617361068726,
            'type': 'texture',
            'url': null,
          },
          {
            'ui_score': 84,
            'mask_urls': [
              'https://yce-us.s3-accelerate.amazonaws.com/ttl30/512028098225506616/122582823308/v2/aeMNNB0KmUIP8rnQ996tC5Q/d742498f-683c-45da-ac2d-a25cb6c8d4bf_firmness_output.png',
            ],
            'raw_score': 86.62776350975037,
            'type': 'firmness',
            'url': null,
          },
          {
            'ui_score': 65,
            'mask_urls': [
              'https://yce-us.s3-accelerate.amazonaws.com/ttl30/512028098225506616/122582823308/v2/aeMNNB0KmUIP8rnQ996tC5Q/d742498f-683c-45da-ac2d-a25cb6c8d4bf_oiliness_output.png',
            ],
            'raw_score': 44.694091796875,
            'type': 'oiliness',
            'url': null,
          },
          {
            'ui_score': 77,
            'mask_urls': [
              'https://yce-us.s3-accelerate.amazonaws.com/ttl30/512028098225506616/122582823308/v2/aeMNNB0KmUIP8rnQ996tC5Q/d742498f-683c-45da-ac2d-a25cb6c8d4bf_radiance_output.png',
            ],
            'raw_score': 72.00771570205688,
            'type': 'radiance',
            'url': null,
          },
          {
            'ui_score': 72,
            'mask_urls': [
              'https://yce-us.s3-accelerate.amazonaws.com/ttl30/512028098225506616/122582823308/v2/aeMNNB0KmUIP8rnQ996tC5Q/d742498f-683c-45da-ac2d-a25cb6c8d4bf_age_spot_output.png',
            ],
            'raw_score': 74.18103790283203,
            'type': 'age_spot',
            'url': null,
          },
          {
            'ui_score': 72,
            'mask_urls': [
              'https://yce-us.s3-accelerate.amazonaws.com/ttl30/512028098225506616/122582823308/v2/aeMNNB0KmUIP8rnQ996tC5Q/d742498f-683c-45da-ac2d-a25cb6c8d4bf_dark_circle_v2_output.png',
            ],
            'raw_score': 68.30209791660309,
            'type': 'dark_circle_v2',
            'url': null,
          },
          {
            'ui_score': 99,
            'mask_urls': [
              'https://yce-us.s3-accelerate.amazonaws.com/ttl30/512028098225506616/122582823308/v2/aeMNNB0KmUIP8rnQ996tC5Q/d742498f-683c-45da-ac2d-a25cb6c8d4bf_acne_output.png',
            ],
            'raw_score': 100,
            'type': 'acne',
            'url': null,
          },
          {
            'ui_score': 71,
            'mask_urls': [
              'https://yce-us.s3-accelerate.amazonaws.com/ttl30/512028098225506616/122582823308/v2/aeMNNB0KmUIP8rnQ996tC5Q/d742498f-683c-45da-ac2d-a25cb6c8d4bf_wrinkle_output.png',
            ],
            'raw_score': 64.95578289031982,
            'type': 'wrinkle',
            'url': null,
          },
          {
            'ui_score': 65,
            'mask_urls': [
              'https://yce-us.s3-accelerate.amazonaws.com/ttl30/512028098225506616/122582823308/v2/aeMNNB0KmUIP8rnQ996tC5Q/d742498f-683c-45da-ac2d-a25cb6c8d4bf_moisture_output.png',
            ],
            'raw_score': 37.04833984375,
            'type': 'moisture',
            'url': null,
          },
          {
            'mask_urls': [
              'https://yce-us.s3-accelerate.amazonaws.com/ttl30/512028098225506616/122582823308/v2/aeMNNB0KmUIP8rnQ996tC5Q/d742498f-683c-45da-ac2d-a25cb6c8d4bf_skin_type_output.png',
            ],
            'type': 'skin_type',
            'region': 'whole',
            'skin_type': 'Oily',
            'url': null,
          },
          {
            'mask_urls': [
              'https://yce-us.s3-accelerate.amazonaws.com/ttl30/512028098225506616/122582823308/v2/aeMNNB0KmUIP8rnQ996tC5Q/d742498f-683c-45da-ac2d-a25cb6c8d4bf_skin_type_t_zone_output.png',
            ],
            'type': 'skin_type',
            'region': 't_zone',
            'skin_type': 'Oily',
            'url': null,
          },
          {
            'mask_urls': [
              'https://yce-us.s3-accelerate.amazonaws.com/ttl30/512028098225506616/122582823308/v2/aeMNNB0KmUIP8rnQ996tC5Q/d742498f-683c-45da-ac2d-a25cb6c8d4bf_skin_type_u_zone_output.png',
            ],
            'type': 'skin_type',
            'region': 'u_zone',
            'skin_type': 'Oily',
            'url': null,
          },
          {'score': 75.13333333333334, 'type': 'all', 'url': null},
          {'score': 52, 'type': 'skin_age', 'url': null},
          {
            'mask_urls': [
              'https://yce-us.s3-accelerate.amazonaws.com/ttl30/512028098225506616/122582823308/v2/aeMNNB0KmUIP8rnQ996tC5Q/d742498f-683c-45da-ac2d-a25cb6c8d4bf_resize_image.jpg',
            ],
            'type': 'resize_image',
            'url': null,
          },
        ],
      },
      'report': {
        'headline': 'Calm, clear skin with a strong foundation',
        'summary': 'Overall 69/100 on your first scan. Strengths: acne, firmness. Focus: moisture, eye area.',
        'overall': {
          'score': 69.3,
          'band': 'moderate',
          'caption': 'Your starting point, not a verdict.',
        },
        'profile_chips': [
          {
            'label': 'Combination',
            'sublabel': 'Skin type',
            'kind': 'skin_type',
          },
          {
            'label': 'Moisture',
            'sublabel': 'Focus · your goal',
            'kind': 'goal',
          },
          {'label': 'Acne', 'sublabel': 'Strength', 'kind': 'concern'},
        ],
        'strengths': [
          {
            'title': 'Clear Complexion',
            'description': 'Your skin is free of active breakouts, showing natural clarity and balance.',
            'evidence': [
              {'concern': 'acne', 'raw': 88.5},
            ],
          },
          {
            'title': 'Firm Foundation',
            'description': 'Your skin displays strong structural support and natural elasticity.',
            'evidence': [
              {'concern': 'firmness', 'raw': 82.0},
            ],
          },
        ],
        'regions': [
          {
            'area': 'eye_area',
            'title': 'Eye area',
            'observation': 'Droopy upper eyelid 52, dark circles 42.',
            'why_it_matters': 'Puffiness and eyelid laxity are mostly structural, so skincare can soften the look but not change the shape.',
            'suggested_focus': 'Gentle eye care with caffeine, sunscreen around the eyes and regular sleep.',
            'confidence': 'measured',
            'evidence': [
              {'concern': 'droopy_upper_eyelid', 'raw': 52.0},
              {'concern': 'dark_circle_v2', 'raw': 42.0},
            ],
          },
          {
            'area': 'whole_face',
            'title': 'Skin balance',
            'observation': 'Moisture 58. Skin type measured: combination.',
            'why_it_matters': 'Oil and water are different things: oily skin can still be dehydrated.',
            'suggested_focus':
                'Hydrate first with a gentle, non-stripping routine.',
            'confidence': 'measured',
            'evidence': [
              {'concern': 'moisture', 'raw': 58.0},
            ],
          },
        ],
        'goal_validation': {
          'goal': 'moisture',
          'alignment': 'strong',
          'value': 0.85,
          'explanation': 'Your scan strongly aligns with this goal: Moisture scored 58. Your program is tailored to support hydration.',
        },
        'routine_preview': [
          {
            'step': 1,
            'name': 'Gentle Hydrating Cleanser',
            'time_of_day': 'both',
            'ingredient_ids': ['glycerin'],
            'instruction':
                'Cleanse gently with lukewarm water morning and night.',
            'why': 'Supports your skin barrier without stripping natural oils.',
          },
          {
            'step': 2,
            'name': 'Barrier Support Moisturizer',
            'time_of_day': 'both',
            'ingredient_ids': ['ceramides', 'hyaluronic_acid'],
            'instruction': 'Apply to damp skin after cleansing.',
            'why':
                'Boosts hydration score from 58 to optimal hydration levels.',
          },
          {
            'step': 3,
            'name': 'Broad-Spectrum SPF 30+',
            'time_of_day': 'am',
            'ingredient_ids': ['zinc_oxide'],
            'instruction':
                'Apply two finger lengths every morning as the final step.',
            'why': "Prevents photo-aging and preserves your skin's natural firmness.",
          },
        ],
        'coach_message': 'Start simple: hydrate, protect, and add only one new active at a time. I will track every change with you.',
        'disclaimers': ['Estimates from a photo, not medical advice.'],
        'safety': {
          'needs_professional_review': false,
          'reasons': <String>[],
        },
      },
      'task_status': 'success',
    },
  };
}
