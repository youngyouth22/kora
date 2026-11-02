import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:kora/common/widgets/primary_button.dart';
import 'package:kora/features/profile/presentation/pages/skin_profile_page.dart';
import 'package:kora/features/profile/presentation/widgets/setting_section.dart';

void main() {
  group('SkinProfilePage', () {
    testWidgets('renders all sections and options properly', (tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: SkinProfilePage(),
        ),
      );
      await tester.pumpAndSettle();

      expect(find.text('Skin Profile'), findsOneWidget);
      expect(find.byType(SettingSection), findsNWidgets(4));
      expect(find.text('Skin Type'), findsOneWidget);
      expect(
        find.text('Skin Tone (Fitzpatrick Phototype)'),
        findsOneWidget,
      );
      expect(find.text('Primary Skin Goals & Concerns'), findsOneWidget);
      expect(find.text('Sensitivities'), findsOneWidget);

      expect(find.text('Oily'), findsOneWidget);
      expect(find.text('Dry'), findsOneWidget);
      expect(find.text('Combination'), findsOneWidget);
      expect(find.text('Normal'), findsOneWidget);
      expect(find.text('Not sure'), findsOneWidget);

      expect(find.text('Acne & blemishes'), findsOneWidget);
      expect(find.text('Dark spots & pigmentation'), findsOneWidget);
      expect(find.text('Sensitive skin barrier'), findsOneWidget);

      expect(
        find.widgetWithText(PrimaryButton, 'Save skin profile'),
        findsOneWidget,
      );
    });

    testWidgets('allows selecting skin type and goals and tapping save', (
      tester,
    ) async {
      tester.view.physicalSize = const Size(800, 2400);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(() {
        tester.view.resetPhysicalSize();
        tester.view.resetDevicePixelRatio();
      });

      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: SkinProfilePage(),
          ),
        ),
      );
      await tester.pumpAndSettle();

      // Tap 'Oily'
      await tester.tap(find.text('Oily'));
      await tester.pumpAndSettle();

      // Tap 'Dark spots & pigmentation' chip
      await tester.tap(find.text('Dark spots & pigmentation'));
      await tester.pumpAndSettle();

      // Tap 'Sensitive skin barrier' switch
      await tester.tap(find.byType(Switch));
      await tester.pumpAndSettle();

      // Tap Save button
      await tester.tap(find.widgetWithText(PrimaryButton, 'Save skin profile'));
      await tester.pump();
      await tester.pumpAndSettle();

      expect(find.text('Skin profile updated successfully'), findsOneWidget);
    });
  });
}
