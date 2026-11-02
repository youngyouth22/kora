import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:kora/common/widgets/primary_button.dart';
import 'package:kora/features/profile/presentation/pages/routine_preferences_page.dart';
import 'package:kora/features/profile/presentation/widgets/setting_section.dart';

void main() {
  group('RoutinePreferencesPage', () {
    testWidgets('renders all sections and options properly', (tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: RoutinePreferencesPage(),
        ),
      );
      await tester.pumpAndSettle();

      expect(find.text('Routine Preferences'), findsOneWidget);
      expect(find.byType(SettingSection), findsNWidgets(4));

      expect(find.text('Current Routine Complexity'), findsOneWidget);
      expect(find.text('Guidance & Suggestions'), findsOneWidget);
      expect(find.text('Product Experimentation'), findsOneWidget);
      expect(find.text('Daily Schedule & Reminders'), findsOneWidget);

      expect(find.text('Minimalist (1–2 products)'), findsOneWidget);
      expect(find.text('Moderate (3–4 products)'), findsOneWidget);
      expect(find.text('Advanced (5+ products)'), findsOneWidget);
      expect(find.text('Irregular or starting fresh'), findsOneWidget);

      expect(find.text('Proactive tailored boosters'), findsOneWidget);
      expect(find.text('Alert only when metrics decline'), findsOneWidget);
      expect(find.text('Track my current routine only'), findsOneWidget);

      expect(find.text('Testing a new product'), findsOneWidget);
      expect(find.text('Planning to introduce one soon'), findsOneWidget);
      expect(find.text('Testing routine stability'), findsOneWidget);

      expect(find.text('Morning routine'), findsOneWidget);
      expect(find.text('Evening routine'), findsOneWidget);
      expect(find.text('Weekly scan day'), findsOneWidget);

      expect(
        find.widgetWithText(PrimaryButton, 'Save preferences'),
        findsOneWidget,
      );
    });

    testWidgets('allows changing routine level and tapping save', (
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
            body: RoutinePreferencesPage(),
          ),
        ),
      );
      await tester.pumpAndSettle();

      // Tap 'Minimalist (1–2 products)'
      await tester.tap(find.text('Minimalist (1–2 products)'));
      await tester.pumpAndSettle();

      // Tap 'Alert only when metrics decline'
      await tester.tap(find.text('Alert only when metrics decline'));
      await tester.pumpAndSettle();

      // Tap Save button
      await tester.tap(find.widgetWithText(PrimaryButton, 'Save preferences'));
      await tester.pump();
      await tester.pumpAndSettle();

      expect(
        find.text('Routine preferences updated successfully'),
        findsOneWidget,
      );
    });
  });
}
