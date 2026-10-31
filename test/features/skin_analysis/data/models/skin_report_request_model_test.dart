import 'package:flutter_test/flutter_test.dart';
import 'package:kora/features/onboarding/domain/entities/user_demographics.dart';
import 'package:kora/features/onboarding/domain/entities/user_skin_profile.dart';
import 'package:kora/features/skin_analysis/data/models/skin_analysis_result_model.dart';
import 'package:kora/features/skin_analysis/data/models/skin_report_request_model.dart';

void main() {
  group('SkinReportRequestModel', () {
    test(
      'computes overall strictly from raw_score mean without ui_score',
      () {
        const analysis = SkinAnalysisResultModel(
          overallScore: 88, // Provider inflated score
          skinAge: 26,
          skinTypeInfo: SkinTypeInfoModel(
            overallType: 'Combination',
            tZoneType: 'Oily',
            uZoneType: 'Normal',
          ),
          concerns: [
            SkinConcernModel(
              type: 'pore',
              uiScore: 95, // Inflated UI score (must be ignored)
              rawScore: 82.5,
            ),
            SkinConcernModel(
              type: 'age_spot',
              uiScore: 80, // Inflated UI score (must be ignored)
              rawScore: 61.2,
            ),
            SkinConcernModel(
              type: 'moisture',
              uiScore: 75,
              rawScore: 54,
            ),
          ],
        );

        const profile = UserSkinProfile(
          userId: 'uuid-user-123',
          skinType: SkinType.combination,
          primaryGoals: [SkinGoal.darkSpots, SkinGoal.dehydration],
          demographics: UserDemographics(hasSensitiveSkin: true),
        );

        final request = SkinReportRequestModel.fromAnalysis(
          analysis: analysis,
          userProfile: profile,
          currentRoutineIngredients: const ['Niacinamide', 'Glycerin'],
          sensitivities: const ['fragrance'],
        );

        final json = request.toJson();
        final scanJson = json['scan'] as Map<String, dynamic>;
        final profileJson = json['profile'] as Map<String, dynamic>;

        // Mean of (82.5 + 61.2 + 54.0) / 3 = 65.9
        expect(scanJson['overall'], 65.9);
        expect(scanJson['overallBand'], 'moderate');
        expect(scanJson['providerOverallIgnored'], 88.0);
        expect(scanJson['skinAge'], 26);
        expect(scanJson['strengths'], contains('pore'));
        expect(scanJson['focus'], containsAll(['moisture', 'age_spot']));
        expect(scanJson['patterns'], contains('oily_dehydrated'));

        final serialized = json.toString();
        expect(serialized.contains('ui_score'), isFalse);
        expect(serialized.contains('uiScore'), isFalse);

        expect(profileJson['userId'], 'uuid-user-123');
        expect(profileJson['skinType'], 'combination');
        expect(
          profileJson['sensitivities'],
          containsAll(['fragrance', 'sensitive_skin']),
        );
        expect(
          profileJson['currentRoutineIngredients'],
          ['Niacinamide', 'Glycerin'],
        );
      },
    );
  });
}
