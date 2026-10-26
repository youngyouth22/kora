import 'package:flutter_test/flutter_test.dart';
import 'package:kora/features/skin_analysis/data/models/skin_analysis_result_model.dart';

void main() {
  final sampleJson = {
    'status': 200,
    'data': {
      'error': null,
      'results': {
        'output': [
          {
            'ui_score': 70,
            'mask_urls': ['https://example.com/tear_trough.png'],
            'raw_score': 56.06722831726074,
            'type': 'tear_trough',
            'url': null,
          },
          {
            'ui_score': 63,
            'mask_urls': ['https://example.com/droopy_lower_eyelid.png'],
            'raw_score': 39.80274796485901,
            'type': 'droopy_lower_eyelid',
            'url': null,
          },
          {
            'ui_score': 58,
            'mask_urls': ['https://example.com/eye_bag.png'],
            'raw_score': 27.279239892959595,
            'type': 'eye_bag',
            'url': null,
          },
          {
            'ui_score': 99,
            'mask_urls': ['https://example.com/acne.png'],
            'raw_score': 100.0,
            'type': 'acne',
            'url': null,
          },
          {
            'mask_urls': ['https://example.com/skin_type.png'],
            'type': 'skin_type',
            'region': 'whole',
            'skin_type': 'Oily',
            'url': null,
          },
          {
            'mask_urls': ['https://example.com/skin_type_t.png'],
            'type': 'skin_type',
            'region': 't_zone',
            'skin_type': 'Oily',
            'url': null,
          },
          {
            'score': 75.13333333333334,
            'type': 'all',
            'url': null,
          },
          {
            'score': 52,
            'type': 'skin_age',
            'url': null,
          },
          {
            'mask_urls': ['https://example.com/resized.jpg'],
            'type': 'resize_image',
            'url': null,
          },
        ],
      },
      'task_status': 'success',
    },
  };

  test('correctly deserializes YouCam JSON into SkinAnalysisResultModel', () {
    final model = SkinAnalysisResultModel.fromJson(sampleJson);

    expect(model.overallScore, closeTo(75.13, 0.01));
    expect(model.skinAge, 52);
    expect(model.resizedImageUrl, 'https://example.com/resized.jpg');
    expect(model.skinTypeInfo?.overallType, 'Oily');
    expect(model.skinTypeInfo?.tZoneType, 'Oily');
    expect(model.concerns.length, 4);

    final entity = model.toEntity();
    expect(entity.overallScore, closeTo(75.13, 0.01));
    expect(entity.skinAge, 52);
    expect(entity.skinType?.overallType, 'Oily');

    // Areas needing attention (lowest ui_score first)
    final attention = entity.areasNeedingAttention;
    expect(attention.length, 3);
    expect(attention[0].id, 'eye_bag');
    expect(attention[0].uiScore, 58);
    expect(attention[1].id, 'droopy_lower_eyelid');
    expect(attention[1].uiScore, 63);
    expect(attention[2].id, 'tear_trough');
    expect(attention[2].uiScore, 70);

    // Strengths (highest ui_score first)
    final strengths = entity.strengths;
    expect(strengths[0].id, 'acne');
    expect(strengths[0].uiScore, 99);
  });
}
