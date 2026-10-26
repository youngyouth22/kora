import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:kora/common/widgets/primary_button.dart';
import 'package:kora/features/onboarding/presentation/pages/onboarding_build_screen.dart';

void main() {
  group('OnboardingBuildScreen Widget Tests', () {
    testWidgets('renders title, subtitle, checklist, and circular progress', (
      tester,
    ) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: OnboardingBuildScreen(
            autoAdvanceDuration: Duration(milliseconds: 100),
          ),
        ),
      );

      expect(find.text('Building Your Skin Baseline'), findsOneWidget);
      expect(
        find.text(
          'Calibrating algorithms to your Fitzpatrick profile, '
          'active ingredients, and skin goals.',
        ),
        findsOneWidget,
      );
      expect(find.text('Fitzpatrick skin tone calibration'), findsOneWidget);
      expect(find.text('16 dermatological baseline markers'), findsOneWidget);
      expect(find.byType(CircularProgressIndicator), findsWidgets);

      // Fast-forward animation to completion
      await tester.pump(const Duration(milliseconds: 150));
      await tester.pumpAndSettle();

      expect(find.text('View How Kora Works'), findsOneWidget);
      expect(find.byType(PrimaryButton), findsOneWidget);
    });
  });
}
