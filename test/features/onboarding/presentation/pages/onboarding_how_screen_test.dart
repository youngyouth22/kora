import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:kora/common/widgets/primary_button.dart';
import 'package:kora/features/onboarding/presentation/pages/onboarding_how_screen.dart';

void main() {
  group('OnboardingHowScreen Widget Tests', () {
    testWidgets('renders all 3 scientific pillars and continue CTA', (
      tester,
    ) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: OnboardingHowScreen(),
        ),
      );

      expect(find.text('How Kora Works'), findsOneWidget);
      expect(find.text('Science over guesswork'), findsOneWidget);
      expect(find.text('Lighting Normalization'), findsOneWidget);
      expect(find.text('16 Deep Biomarkers'), findsOneWidget);
      expect(find.text('Weekly Delta vs Daily Noise'), findsOneWidget);
      expect(find.text("Got it, let's continue"), findsOneWidget);
      expect(find.byType(PrimaryButton), findsOneWidget);
    });
  });
}
