import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:kora/common/widgets/kora_scan_image.dart';

void main() {
  group('KoraScanImage', () {
    testWidgets('renders fallback asset image when photoPath is null', (
      tester,
    ) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: KoraScanImage(
              scanId: 'scan_1',
            ),
          ),
        ),
      );
      await tester.pump();

      expect(find.byType(Image), findsOneWidget);
    });

    testWidgets('renders mesh overlay when showMeshOverlay is true', (
      tester,
    ) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: KoraScanImage(
              scanId: 'scan_8',
              showMeshOverlay: true,
              zoneHighlight: 'forehead',
            ),
          ),
        ),
      );
      await tester.pump();

      expect(find.byType(CustomPaint), findsWidgets);
    });

    test(
      'resolveDefaultFallbackAsset picks deterministic asset per scanId',
      () {
        final week1 = KoraScanImage.resolveDefaultFallbackAsset('scan_1');
        final week3 = KoraScanImage.resolveDefaultFallbackAsset('scan_4');
        final week6 = KoraScanImage.resolveDefaultFallbackAsset('scan_8');

        expect(week1, contains('week1'));
        expect(week3, contains('week3'));
        expect(week6, contains('week6'));
      },
    );
  });
}
