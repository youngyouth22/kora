import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:kora/common/widgets/kora_scan_image.dart';
import 'package:kora/features/progress/domain/entities/progress_scan.dart';
import 'package:kora/features/progress/presentation/widgets/progress_detail_widgets.dart';

void main() {
  final scanA = ProgressScan(
    id: 'scan_1',
    userId: 'user_1',
    status: 'done',
    mode: 'HD',
    overallScore: 68,
    skinAge: 32,
    qualityOk: true,
    createdAt: DateTime(2026, 9, 2),
    completedAt: DateTime(2026, 9, 2, 1),
    concerns: const [],
  );

  final scanB = ProgressScan(
    id: 'scan_8',
    userId: 'user_1',
    status: 'done',
    mode: 'HD',
    overallScore: 78,
    skinAge: 29,
    qualityOk: true,
    createdAt: DateTime(2026, 10, 20),
    completedAt: DateTime(2026, 10, 20, 1),
    concerns: const [],
  );

  testWidgets(
    'CompareSplitViewerCard renders real scan images and handles drag/tap reactively',
    (tester) async {
      var currentPosition = 0.5;
      var overlayEnabled = false;

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: StatefulBuilder(
              builder: (context, setState) {
                return SingleChildScrollView(
                  child: CompareSplitViewerCard(
                    scanA: scanA,
                    scanB: scanB,
                    allScans: [scanA, scanB],
                    sliderPosition: currentPosition,
                    showZonesOverlay: overlayEnabled,
                    onSliderChanged: (pos) =>
                        setState(() => currentPosition = pos),
                    onToggleOverlay: (show) =>
                        setState(() => overlayEnabled = show),
                    onScanASelected: (_) {},
                    onScanBSelected: (_) {},
                  ),
                );
              },
            ),
          ),
        ),
      );
      await tester.pump();

      // Check images are rendered
      expect(find.byType(KoraScanImage), findsNWidgets(2));
      expect(find.text('BEFORE · Sep 2'), findsOneWidget);
      expect(find.text('AFTER · Oct 20'), findsOneWidget);

      // Verify horizontal drag on the card
      final gestureFinder = find.byKey(
        const Key('compare_split_slider_gesture'),
      );
      await tester.drag(gestureFinder, const Offset(100, 0));
      await tester.pump();

      expect(currentPosition, isNot(0.5));

      // Verify toggle overlay
      await tester.tap(find.text('Detected Zones'));
      await tester.pump();
      expect(overlayEnabled, isTrue);
    },
  );
}
