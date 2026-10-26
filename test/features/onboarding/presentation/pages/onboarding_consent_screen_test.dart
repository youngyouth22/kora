import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:kora/common/widgets/primary_button.dart';
import 'package:kora/features/onboarding/presentation/pages/onboarding_consent_screen.dart';

void main() {
  group('OnboardingConsentScreen Widget Tests', () {
    testWidgets('renders privacy guarantees, checkbox, and enabled CTA', (
      tester,
    ) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: OnboardingConsentScreen(),
        ),
      );

      expect(find.text('Consent & Privacy'), findsOneWidget);
      expect(find.text('Your trust comes first'), findsOneWidget);
      expect(find.text('Private & Encrypted Storage'), findsOneWidget);
      expect(find.text('Zero Data Resale'), findsOneWidget);
      expect(find.text('Cosmetic Wellness Scope'), findsOneWidget);
      expect(find.text('Complete Deletion Rights'), findsOneWidget);
      expect(find.text('I Agree & Continue'), findsOneWidget);

      // Checkbox is initially checked
      final button = tester.widget<PrimaryButton>(find.byType(PrimaryButton));
      expect(button.isDisabled, isFalse);

      // Tap checkbox to uncheck
      final checkboxFinder = find.byType(Checkbox);
      expect(checkboxFinder, findsOneWidget);
      await tester.tap(checkboxFinder);
      await tester.pump();

      final disabledButton = tester.widget<PrimaryButton>(
        find.byType(PrimaryButton),
      );
      expect(disabledButton.isDisabled, isTrue);
    });
  });
}
