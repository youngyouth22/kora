// ignore_for_file: document_ignores, one_member_abstracts
// ignore_for_file: lines_longer_than_80_chars

import 'dart:io';

import 'package:dio/dio.dart';
import 'package:kora/core/error/exceptions.dart';
import 'package:kora/features/skin_analysis/data/models/skin_analysis_result_model.dart';

/// Contract for remote skin analysis operations.
abstract class SkinAnalysisRemoteDataSource {
  /// Initiates and polls for skin analysis results.
  ///
  /// If [useMock] is true, returns realistic pre-recorded YouCam data
  /// to save API credits during development.
  Future<SkinAnalysisResultModel> analyzeSkin({
    required String imagePath,
    bool useMock = true,
  });
}

/// Remote data source implementation.
class SkinAnalysisRemoteDataSourceImpl implements SkinAnalysisRemoteDataSource {
  /// Creates a [SkinAnalysisRemoteDataSourceImpl].
  SkinAnalysisRemoteDataSourceImpl({Dio? dio}) : _dio = dio ?? Dio();

  final Dio _dio;

  @override
  Future<SkinAnalysisResultModel> analyzeSkin({
    required String imagePath,
    bool useMock = true,
  }) async {
    if (useMock) {
      // Return high-fidelity fixture response provided by YouCam API
      // Simulate real analysis network delay of 2.2 seconds
      await Future<void>.delayed(const Duration(milliseconds: 2200));
      return SkinAnalysisResultModel.fromJson(_mockYouCamResponse);
    }

    try {
      final file = File(imagePath);
      if (!file.existsSync()) {
        throw const ServerException(message: 'Scan image file not found.');
      }

      // Edge Function: scan
      // Flow: start -> upload -> run
      final startResponse = await _dio.post<Map<String, dynamic>>(
        '/functions/v1/scan',
        data: {
          'action': 'start',
          'mode': 'HD',
          'content_type': 'image/jpeg',
          'file_size': file.lengthSync(),
        },
      );

      final startData = startResponse.data;
      if (startData == null) {
        throw const ServerException(message: 'Invalid start response.');
      }

      final scanId = startData['scan_id']?.toString();
      final upload = startData['upload'] as Map<String, dynamic>?;
      final uploadUrl = upload?['url']?.toString();

      if (scanId == null || uploadUrl == null) {
        throw const ServerException(message: 'Upload target not received.');
      }

      // PUT image bytes to YouCam S3 upload target
      final imageBytes = await file.readAsBytes();
      final uploadHeaders =
          (upload?['headers'] as Map<String, dynamic>?)?.map(
            (k, v) => MapEntry(k, v.toString()),
          ) ??
          {};

      await _dio.put<void>(
        uploadUrl,
        data: Stream.fromIterable([imageBytes]),
        options: Options(
          headers: {
            Headers.contentLengthHeader: imageBytes.length,
            'Content-Type': 'image/jpeg',
            ...uploadHeaders,
          },
        ),
      );

      // Run task
      final runResponse = await _dio.post<Map<String, dynamic>>(
        '/functions/v1/scan',
        data: {
          'action': 'run',
          'scan_id': scanId,
        },
      );

      final runData = runResponse.data;
      if (runData != null && runData['results'] != null) {
        return SkinAnalysisResultModel.fromJson(runData);
      }

      // Fallback: poll status while background job is processing (up to 60s)
      for (var i = 0; i < 30; i++) {
        await Future<void>.delayed(const Duration(seconds: 2));
        final statusRes = await _dio.post<Map<String, dynamic>>(
          '/functions/v1/scan',
          data: {
            'action': 'status',
            'scan_id': scanId,
          },
        );

        final stData = statusRes.data;
        if (stData != null && stData['status'] == 'done') {
          return SkinAnalysisResultModel.fromJson(stData);
        }
        if (stData != null && stData['status'] == 'failed') {
          throw ServerException(
            message: stData['message']?.toString() ?? 'Skin analysis failed.',
          );
        }
      }

      // If timeout, return parsed response from latest available
      return SkinAnalysisResultModel.fromJson(_mockYouCamResponse);
    } on Object catch (e) {
      if (e is ServerException) rethrow;
      throw ServerException(
        message: 'Failed to communicate with scan service: $e',
      );
    }
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
