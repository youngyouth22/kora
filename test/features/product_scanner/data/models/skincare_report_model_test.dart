import 'package:flutter_test/flutter_test.dart';
import 'package:kora/features/onboarding/domain/entities/user_skin_profile.dart';
import 'package:kora/features/product_scanner/data/models/skincare_report_model.dart';

void main() {
  group('SkincareReportModel & ScanProductRequestModel', () {
    final sampleProductResponse = {
      'product': {
        'brand': 'La Roche-Posay',
        'name': 'Mela B3 Serum',
        'category': 'Serum',
        'imageUrl': 'https://example.com/mela-b3.jpg',
      },
      'personalizedVerdict': {
        'matchScore': 92,
        'matchVerdict': 'Excellente correspondance',
        'headlineReason': 'Cible directement vos pores et taches',
        'explanation': 'Formule enrichie en Niacinamide 10% et Melasyl.',
        'benefitsForUser': [
          'Cible directement vos pores',
          'Renforce la barrière cutanée',
        ],
        'concernsOrRisksForUser': [
          'Introduire progressivement 1 soir sur 2',
        ],
        'routineCompatibility': {
          'isCompatibleWithCurrentRoutine': true,
          'conflictingIngredients': <String>[],
          'integrationAdvice': 'Appliquer soir et matin avant la crème.',
        },
      },
      'applicationGuide': {
        'steps': [
          'Appliquer 3 gouttes sur peau propre.',
          'Terminer par un SPF 50 le matin.',
        ],
        'videoUrl': 'https://youtube.com/watch?v=123',
        'thumbnailUrl': 'https://example.com/thumb.jpg',
        'durationText': '1:45',
      },
      'purchaseOptions': {
        'available': true,
        'retailerName': 'Pharmacie',
        'price': 39.90,
        'currency': 'EUR',
        'productUrl': 'https://example.com/buy',
      },
      'formulaStatic': [
        {
          'inciName': 'Niacinamide',
          'function': 'Pore refining & soothing',
          'safetyRating': 'safe',
          'comedogenicityIndex': 0,
          'isPregnancySafe': true,
        },
      ],
    };

    test('deserializes SkincareReportModel and converts to domain entity', () {
      final model = SkincareReportModel.fromJson(sampleProductResponse);
      final entity = model.toEntity();

      expect(entity.product.brand, 'La Roche-Posay');
      expect(entity.product.name, 'Mela B3 Serum');
      expect(entity.personalizedVerdict.matchScore, 92);
      expect(
        entity.personalizedVerdict.matchVerdict,
        'Excellente correspondance',
      );
      expect(entity.personalizedVerdict.benefitsForUser.length, 2);
      expect(
        entity
            .personalizedVerdict
            .routineCompatibility
            .isCompatibleWithCurrentRoutine,
        isTrue,
      );
      expect(entity.applicationGuide.steps.length, 2);
      expect(entity.applicationGuide.durationText, '1:45');
      expect(entity.purchaseOptions.available, isTrue);
      expect(entity.purchaseOptions.price, 39.90);
      expect(entity.formulaStatic.first.inciName, 'Niacinamide');
      expect(entity.formulaStatic.first.comedogenicityIndex, 0);
      expect(entity.formulaStatic.first.isPregnancySafe, isTrue);

      final roundTrip = SkincareReportModel.fromJson(model.toJson()).toEntity();
      expect(roundTrip, entity);
    });

    test('deserializes Mastra skincareScanWorkflow real response format', () {
      final mastraWorkflowResponse = {
        'cacheHit': false,
        'product': {
          'brand': 'La Roche-Posay',
          'name': 'Toleriane Double Repair Face Moisturizer UV SPF 30',
          'category': 'Moisturizer with SPF',
          'imageUrl': 'https://images.unsplash.com/photo-1556228720',
          'barcode': '3337875545778',
        },
        'matchEvaluation': {
          'overallFitPercentage': 91,
          'executiveSummary':
              'La Roche-Posay Toleriane Double Repair UV SPF 30 is an '
              'excellent match.',
          'pillars': {
            'skinFit': {
              'level': 'High',
              'score': 90,
              'title': 'Combination Skin Fit',
              'explanation':
                  'Non-comedogenic formula balances shine and moisture.',
            },
            'effectiveness': {
              'level': 'High',
              'score': 88,
              'title': 'Effectiveness',
              'explanation': 'Niacinamide visibly refines pores.',
            },
            'safety': {
              'level': 'High',
              'score': 95,
              'title': 'Safety',
              'explanation': 'Gentle and fragrance-free.',
              'pregnancySafe': true,
              'fungalAcneSafe': false,
            },
          },
        },
        'purchaseOptions': {
          'available': true,
          'retailerName': 'Amazon',
          'price': 20.0,
          'currency': 'USD',
          'productUrl': 'https://www.amazon.com/dp/123',
        },
        'aiAssistant': {
          'shortExplanation':
              'Lightweight, non-comedogenic, and packed with Niacinamide.',
          'suggestedQuestions': [
            {
              'emoji': '🤔',
              'question': 'How does Niacinamide help with pores?',
            },
          ],
          'routineConflictWarning': null,
        },
        'applicationGuide': {
          'instructions': [
            'Cleanse face thoroughly and pat dry.',
            'Apply a generous amount to face and neck.',
          ],
          'videoTutorial': {
            'title': 'How To Use',
            'videoUrl': 'https://youtube.com/watch?v=lrp-uv',
            'thumbnailUrl': 'https://img.youtube.com/vi/lrp-uv.jpg',
            'durationText': '1:30',
          },
        },
        'inciAnalysis': {
          'allIngredientsRaw': 'WATER, NIACINAMIDE, GLYCERIN, CERAMIDE NP',
          'detailedBreakdown': [
            {
              'inciName': 'NIACINAMIDE',
              'commonName': 'Vitamin B3',
              'function': 'Barrier Strengthening & Pore Refining',
              'safetyRating': 'Safe',
              'comedogenicityIndex': 0,
              'irritancyIndex': 0,
              'isPregnancySafe': true,
              'isFungalAcneTrigger': false,
            },
            {
              'inciName': 'CERAMIDE NP',
              'commonName': 'Ceramide NP',
              'function': 'Skin-Identical Lipid',
              'safetyRating': 'Safe',
              'comedogenicityIndex': 0,
              'irritancyIndex': 0,
              'isPregnancySafe': true,
              'isFungalAcneTrigger': false,
            },
          ],
        },
      };

      final model = SkincareReportModel.fromJson(mastraWorkflowResponse);
      final entity = model.toEntity();

      expect(entity.product.brand, 'La Roche-Posay');
      expect(
        entity.product.name,
        'Toleriane Double Repair Face Moisturizer UV SPF 30',
      );
      expect(entity.personalizedVerdict.matchScore, 91);
      expect(
        entity.personalizedVerdict.matchVerdict,
        '91% Match · High Fit',
      );
      expect(entity.personalizedVerdict.benefitsForUser.length, 2);
      expect(
        entity
            .personalizedVerdict
            .routineCompatibility
            .isCompatibleWithCurrentRoutine,
        isTrue,
      );
      expect(entity.applicationGuide.steps.length, 2);
      expect(
        entity.applicationGuide.videoUrl,
        'https://youtube.com/watch?v=lrp-uv',
      );
      expect(entity.formulaStatic.length, 2);
      expect(entity.formulaStatic.first.inciName, 'NIACINAMIDE');
      expect(entity.formulaStatic.first.commonName, 'Vitamin B3');
      expect(entity.formulaStatic.first.comedogenicityIndex, 0);
      expect(entity.formulaStatic.first.isPregnancySafe, isTrue);
      expect(entity.pillars?.skinFit?.score, 90);
      expect(entity.pillars?.effectiveness?.score, 88);
      expect(entity.pillars?.safety?.pregnancySafe, isTrue);
      expect(entity.aiAssistant?.suggestedQuestions.length, 1);
      expect(
        entity.aiAssistant?.suggestedQuestions.first.question,
        'How does Niacinamide help with pores?',
      );
      expect(
        entity.rawInciText,
        'WATER, NIACINAMIDE, GLYCERIN, CERAMIDE NP',
      );
    });

    test('builds ScanProductRequestModel from UserSkinProfile', () {
      const profile = UserSkinProfile(
        skinType: SkinType.oily,
        primaryGoals: [SkinGoal.acne, SkinGoal.pores],
      );

      final request = ScanProductRequestModel.fromInput(
        rawInput: '3337875545778',
        profile: profile,
        currentRoutineIngredients: const ['Salicylic Acid', 'Niacinamide'],
        sensitivities: const ['essential_oils'],
      );

      final json = request.toJson();
      expect(json['rawInput'], '3337875545778');
      final profileMap = json['userProfile'] as Map<String, dynamic>;
      expect(profileMap['skinType'], 'oily');
      expect(profileMap['concerns'], ['acne', 'pores']);
      expect(profileMap['sensitivities'], ['essential_oils']);
      expect(
        profileMap['currentRoutineIngredients'],
        ['Salicylic Acid', 'Niacinamide'],
      );
    });
  });
}
