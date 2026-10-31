// ignore_for_file: document_ignores

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:kora/features/skin_analysis/domain/entities/skin_concern.dart';
import 'package:kora/features/skin_analysis/presentation/widgets/youcam_mask_gallery_widget.dart';

void main() {
  const testConcerns = [
    SkinConcern(
      id: 'pore',
      displayName: 'Pores',
      uiScore: 78,
      rawScore: 78.4,
      maskUrls: ['https://example.com/pore_mask.png'],
    ),
    SkinConcern(
      id: 'redness',
      displayName: 'Redness & Sensitivity',
      uiScore: 62,
      rawScore: 61.5,
      maskUrls: ['https://example.com/redness_mask.png'],
    ),
    SkinConcern(
      id: 'acne',
      displayName: 'Blemishes & Acne',
      uiScore: 86,
      rawScore: 86,
    ),
  ];

  Widget buildTestWidget({List<SkinConcern> concerns = testConcerns}) {
    return MaterialApp(
      home: Scaffold(
        body: SingleChildScrollView(
          child: YouCamMaskGalleryWidget(concerns: concerns),
        ),
      ),
    );
  }

  testWidgets('renders YouCam AI Detection Maps header and chromatic legend', (
    tester,
  ) async {
    await tester.pumpWidget(buildTestWidget());

    expect(find.text('YouCam AI Detection Maps (3)'), findsOneWidget);
    expect(find.text('YOUCAM CHROMATIC SCALE'), findsOneWidget);
    expect(find.text('All (3)'), findsOneWidget);
    expect(find.text('Needs Attention (1)'), findsOneWidget);
    expect(find.text('Strengths (2)'), findsOneWidget);
  });

  testWidgets('filters concerns when tapping filter chips', (tester) async {
    await tester.pumpWidget(buildTestWidget());

    // Tap 'Needs Attention (1)'
    await tester.tap(find.text('Needs Attention (1)'));
    await tester.pumpAndSettle();

    // Redness is < 70, so it appears in the grid/chips
    expect(find.text('Redness & Sensitivity'), findsWidgets);

    // Tap 'Strengths (2)'
    await tester.tap(find.text('Strengths (2)'));
    await tester.pumpAndSettle();

    expect(find.text('Pores'), findsWidgets);
    expect(find.text('Blemishes & Acne'), findsWidgets);
  });

  testWidgets('switches selected concern when tapping a horizontal chip', (
    tester,
  ) async {
    await tester.pumpWidget(buildTestWidget());

    // Initially first item (Pores) is present
    expect(find.text('Cyan / Violet Micro-Pore Density'), findsWidgets);

    // Tap 'Redness & Sensitivity' chip
    await tester.tap(
      find.text('Redness & Sensitivity').first,
      warnIfMissed: false,
    );
    await tester.pumpAndSettle();

    // Now Redness heatmap description is shown
    expect(find.text('Coral / Red Erythema Heatmap'), findsWidgets);
  });

  testWidgets('handles empty concerns list gracefully', (tester) async {
    await tester.pumpWidget(buildTestWidget(concerns: const []));

    expect(find.byType(YouCamMaskGalleryWidget), findsOneWidget);
    expect(find.text('YouCam AI Detection Maps'), findsNothing);
  });
}
