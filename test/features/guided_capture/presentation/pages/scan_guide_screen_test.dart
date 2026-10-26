import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:kora/common/widgets/primary_button.dart';
import 'package:kora/features/guided_capture/presentation/pages/scan_guide_screen.dart';

void main() {
  group('ScanGuideScreen Widget Tests', () {
    testWidgets('renders all 4 tips and Start Guided Scan CTA', (
      tester,
    ) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: ScanGuideScreen(),
        ),
      );

      expect(find.text('Scan Guide'), findsOneWidget);
      expect(find.text('Set up for your baseline'), findsOneWidget);
      expect(find.text('Find diffuse, even lighting'), findsOneWidget);
      expect(find.text('Clean, bare skin'), findsOneWidget);
      expect(find.text('Hair back & remove glasses'), findsOneWidget);
      expect(find.text('Neutral facial expression'), findsOneWidget);
      expect(find.text('Start Guided Scan'), findsOneWidget);
      expect(find.byType(PrimaryButton), findsOneWidget);
    });
  });
}
