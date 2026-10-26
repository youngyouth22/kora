// ignore_for_file: document_ignores

import 'package:flutter_test/flutter_test.dart';
import 'package:kora/features/skin_analysis/data/models/skin_report_model.dart';

void main() {
  final sampleReportJson = {
    'report': {
      'headline': 'Calm, clear skin with a strong foundation',
      'summary': 'Overall 69/100 on your first scan. Strengths: acne, firmness. Focus: moisture, eye area.',
      'overall': {
        'score': 69.3,
        'band': 'moderate',
        'caption': 'Your starting point, not a verdict.',
      },
      'profile_chips': [
        {'label': 'Combination', 'sublabel': 'Skin type', 'kind': 'skin_type'},
        {'label': 'Moisture', 'sublabel': 'Focus · your goal', 'kind': 'goal'},
        {'label': 'Acne', 'sublabel': 'Strength', 'kind': 'concern'},
      ],
      'strengths': [
        {
          'title': 'Clear Complexion',
          'description':
              'Your skin is free of active breakouts, showing natural clarity.',
          'evidence': [
            {'concern': 'acne', 'raw': 88.5},
          ],
        },
      ],
      'regions': [
        {
          'area': 'eye_area',
          'title': 'Eye area',
          'observation': 'Droopy upper eyelid 52, dark circles 42.',
          'why_it_matters': 'Structural eyelid laxity.',
          'suggested_focus': 'Gentle eye care with caffeine and sleep.',
          'confidence': 'measured',
          'evidence': [
            {'concern': 'droopy_upper_eyelid', 'raw': 52.0},
          ],
        },
      ],
      'goal_validation': {
        'goal': 'moisture',
        'alignment': 'strong',
        'value': 0.85,
        'explanation': 'Your scan strongly aligns with this goal.',
      },
      'routine_preview': [
        {
          'step': 1,
          'name': 'Gentle Hydrating Cleanser',
          'time_of_day': 'both',
          'ingredient_ids': ['glycerin'],
          'instruction': 'Cleanse gently with lukewarm water.',
          'why': 'Preserves moisture barrier.',
        },
      ],
      'coach_message': 'Start simple: hydrate and protect.',
      'disclaimers': ['Estimates from a photo, not medical advice.'],
      'safety': {
        'needs_professional_review': false,
        'reasons': <String>[],
      },
    },
    'source': 'llm',
    'attempts': 1,
    'errors': <String>[],
  };

  test('deserializes ReportResultModel and maps to pure domain entity', () {
    final resultModel = ReportResultModel.fromJson(sampleReportJson);

    expect(resultModel.source, 'llm');
    expect(resultModel.attempts, 1);
    expect(resultModel.errors, isEmpty);

    final reportModel = resultModel.report;
    expect(reportModel.headline, 'Calm, clear skin with a strong foundation');
    expect(reportModel.overall.score, 69.3);
    expect(reportModel.overall.band, 'moderate');
    expect(reportModel.overall.caption, 'Your starting point, not a verdict.');
    expect(reportModel.profileChips.length, 3);
    expect(reportModel.profileChips.first.label, 'Combination');
    expect(reportModel.strengths.first.title, 'Clear Complexion');
    expect(reportModel.regions.first.area, 'eye_area');
    expect(reportModel.goalValidation?.goal, 'moisture');
    expect(reportModel.goalValidation?.value, 0.85);
    expect(reportModel.routinePreview.first.name, 'Gentle Hydrating Cleanser');
    expect(reportModel.routinePreview.first.ingredientIds, ['glycerin']);
    expect(reportModel.coachMessage, 'Start simple: hydrate and protect.');
    expect(reportModel.safety.needsProfessionalReview, isFalse);

    // Entity mapping
    final entity = reportModel.toEntity();
    expect(entity.headline, 'Calm, clear skin with a strong foundation');
    expect(entity.overall.score, 69.3);
    expect(entity.profileChips.length, 3);
    expect(entity.strengths.length, 1);
    expect(entity.regions.length, 1);
    expect(entity.routinePreview.length, 1);
    expect(entity.safety.needsProfessionalReview, isFalse);
  });
}
