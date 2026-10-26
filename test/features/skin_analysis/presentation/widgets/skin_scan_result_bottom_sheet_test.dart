// ignore_for_file: document_ignores, lines_longer_than_80_chars

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:kora/features/skin_analysis/domain/entities/skin_analysis_result.dart';
import 'package:kora/features/skin_analysis/domain/entities/skin_concern.dart';
import 'package:kora/features/skin_analysis/domain/entities/skin_report.dart';
import 'package:kora/features/skin_analysis/domain/entities/skin_type_info.dart';
import 'package:kora/features/skin_analysis/presentation/widgets/skin_scan_result_bottom_sheet.dart';

void main() {
  const testResult = SkinAnalysisResult(
    overallScore: 75.1,
    skinAge: 52,
    skinType: SkinTypeInfo(
      overallType: 'Oily',
      tZoneType: 'Oily',
      uZoneType: 'Normal',
    ),
    allConcerns: [
      SkinConcern(
        id: 'eye_bag',
        displayName: 'Eye Bags',
        uiScore: 58,
        rawScore: 27,
      ),
      SkinConcern(
        id: 'acne',
        displayName: 'Blemishes & Acne',
        uiScore: 99,
        rawScore: 100,
      ),
      SkinConcern(
        id: 'pore',
        displayName: 'Pores',
        uiScore: 79,
        rawScore: 76.5,
      ),
      SkinConcern(
        id: 'redness',
        displayName: 'Redness',
        uiScore: 97,
        rawScore: 98.3,
      ),
    ],
  );

  const testReport = SkinReport(
    headline: 'Calm, clear skin with a strong foundation',
    summary: 'Overall 69/100 on your first scan. Strengths: acne, firmness. Focus: moisture, eye area.',
    overall: OverallScore(
      score: 69.3,
      band: 'moderate',
      caption: 'Your starting point, not a verdict.',
    ),
    profileChips: [
      ProfileChip(
        label: 'Combination',
        sublabel: 'Skin type',
        kind: 'skin_type',
      ),
      ProfileChip(
        label: 'Moisture',
        sublabel: 'Focus · your goal',
        kind: 'goal',
      ),
      ProfileChip(label: 'Acne', sublabel: 'Strength', kind: 'concern'),
    ],
    strengths: [
      StrengthItem(
        title: 'Clear Complexion',
        description: 'Your skin is free of active breakouts, showing natural clarity and balance.',
        evidence: [Evidence(concern: 'acne', raw: 88.5)],
      ),
      StrengthItem(
        title: 'Firm Foundation',
        description: 'Your skin displays strong structural support and natural elasticity.',
        evidence: [Evidence(concern: 'firmness', raw: 82)],
      ),
    ],
    regions: [
      RegionItem(
        area: 'eye_area',
        title: 'Eye area',
        observation: 'Droopy upper eyelid 52, dark circles 42.',
        whyItMatters: 'Structural puffiness and eyelid laxity.',
        suggestedFocus: 'Gentle eye care with caffeine and regular sleep.',
        confidence: 'measured',
        evidence: [
          Evidence(concern: 'droopy_upper_eyelid', raw: 52),
          Evidence(concern: 'dark_circle_v2', raw: 42),
        ],
      ),
    ],
    goalValidation: GoalValidation(
      goal: 'moisture',
      alignment: 'strong',
      value: 0.85,
      explanation:
          'Your scan strongly aligns with this goal: Moisture scored 58.',
    ),
    routinePreview: [
      RoutineStep(
        step: 1,
        name: 'Gentle Hydrating Cleanser',
        timeOfDay: 'both',
        ingredientIds: ['glycerin'],
        instruction: 'Cleanse gently with lukewarm water morning and night.',
        why: 'Supports your skin barrier without stripping natural oils.',
      ),
      RoutineStep(
        step: 2,
        name: 'Barrier Support Moisturizer',
        timeOfDay: 'both',
        ingredientIds: ['ceramides', 'hyaluronic_acid'],
        instruction: 'Apply to damp skin after cleansing.',
        why: 'Boosts hydration score from 58 to optimal hydration levels.',
      ),
    ],
    coachMessage: 'Start simple: hydrate, protect, and add only one new active at a time. I will track every change with you.',
    disclaimers: ['Estimates from a photo, not medical advice.'],
    safety: SafetyReport(needsProfessionalReview: false),
  );

  const testResultWithReport = SkinAnalysisResult(
    overallScore: 69.3,
    allConcerns: [
      SkinConcern(
        id: 'droopy_upper_eyelid',
        displayName: 'Upper Eyelid',
        uiScore: 52,
        rawScore: 52,
        maskUrls: ['https://example.com/droopy_upper_eyelid.png'],
      ),
      SkinConcern(
        id: 'dark_circle_v2',
        displayName: 'Dark Circles',
        uiScore: 42,
        rawScore: 42,
        maskUrls: ['https://example.com/dark_circle.png'],
      ),
      SkinConcern(
        id: 'acne',
        displayName: 'Blemishes & Acne',
        uiScore: 88,
        rawScore: 88.5,
      ),
    ],
    report: testReport,
  );

  testWidgets(
    'renders overall score, skin type, strengths and attention areas without report',
    (tester) async {
      tester.view.physicalSize = const Size(800, 2400);
      tester.view.devicePixelRatio = 1;
      addTearDown(() {
        tester.view.resetPhysicalSize();
        tester.view.resetDevicePixelRatio();
      });

      var savedToRoutine = false;

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: SkinScanResultBottomSheet(
              result: testResult,
              onSaveToRoutine: () {
                savedToRoutine = true;
              },
            ),
          ),
        ),
      );

      // Header & score
      expect(find.text('Skin Health Report'), findsOneWidget);
      expect(find.text('75'), findsOneWidget);
      expect(find.text('Oily'), findsOneWidget);
      expect(find.text('52 yrs'), findsOneWidget);

      // Attention & strengths titles
      expect(find.text('Areas Needing Attention'), findsOneWidget);
      expect(find.text('Your Skin Strengths'), findsOneWidget);

      // Concern items
      expect(find.text('Eye Bags'), findsWidgets);
      expect(find.text('Blemishes & Acne'), findsWidgets);

      // Tap CTA
      final ctaFinder = find.text('Save to My Routine');
      expect(ctaFinder, findsOneWidget);
      await tester.tap(ctaFinder);
      await tester.pumpAndSettle();

      expect(savedToRoutine, isTrue);
    },
  );

  testWidgets(
    'renders full AI SkinReport with headline, profile chips, YouCam masks, routine & coach note',
    (tester) async {
      tester.view.physicalSize = const Size(800, 3600);
      tester.view.devicePixelRatio = 1;
      addTearDown(() {
        tester.view.resetPhysicalSize();
        tester.view.resetDevicePixelRatio();
      });

      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: SkinScanResultBottomSheet(
              result: testResultWithReport,
              isStandalonePage: true,
            ),
          ),
        ),
      );

      // AI Headline and Summary
      expect(
        find.text('Calm, clear skin with a strong foundation'),
        findsOneWidget,
      );
      expect(
        find.text(
          'Overall 69/100 on your first scan. Strengths: acne, firmness. Focus: moisture, eye area.',
        ),
        findsOneWidget,
      );

      // Profile chips
      expect(find.text('Combination'), findsOneWidget);
      expect(find.text('Skin type'), findsOneWidget);

      // Overall Band and caption
      expect(find.text('Moderate'), findsOneWidget);
      expect(find.text('Your starting point, not a verdict.'), findsOneWidget);

      // Goal validation
      expect(find.text('Goal: MOISTURE'), findsOneWidget);
      expect(find.text('85% alignment'), findsOneWidget);

      // Areas needing attention with YouCam mask section
      expect(find.text('YouCam AI Detection Mask'), findsWidgets);
      expect(find.text('Pinch to Zoom'), findsWidgets);

      // Regional breakdown
      expect(find.text('Regional Breakdown'), findsOneWidget);
      expect(find.text('Eye area'), findsWidgets);

      // Strengths
      expect(find.text('Clear Complexion'), findsOneWidget);
      expect(find.text('Firm Foundation'), findsOneWidget);

      // Routine steps
      expect(find.text('Recommended Routine'), findsOneWidget);
      expect(find.text('Gentle Hydrating Cleanser'), findsOneWidget);
      expect(find.text('Barrier Support Moisturizer'), findsOneWidget);
      expect(find.text('#glycerin'), findsOneWidget);

      // Coach Note
      expect(find.text('Coach Note'), findsOneWidget);
      expect(
        find.text(
          'Start simple: hydrate, protect, and add only one new active at a time. I will track every change with you.',
        ),
        findsOneWidget,
      );

      // Disclaimer
      expect(
        find.text('Estimates from a photo, not medical advice.'),
        findsOneWidget,
      );
    },
  );
}
