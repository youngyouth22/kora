import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:get_it/get_it.dart';
import 'package:kora/features/routine/presentation/pages/routine_catalog_page.dart';
import 'package:kora/features/routine/presentation/pages/routine_checkin_page.dart';
import 'package:kora/features/routine/presentation/pages/routine_page.dart';
import 'package:kora/features/routine/presentation/widgets/routine_period_switcher.dart';
import 'package:kora/features/routine/presentation/widgets/routine_step_card.dart';

void main() {
  setUp(() async {
    await GetIt.instance.reset();
  });

  tearDown(() async {
    await GetIt.instance.reset();
  });

  testWidgets(
    'RoutinePage renders AM products and switches to Evening (PM) period',
    (tester) async {
      tester.view.physicalSize = const Size(1080, 2800);
      tester.view.devicePixelRatio = 2.0;
      addTearDown(tester.view.resetPhysicalSize);
      addTearDown(tester.view.resetDevicePixelRatio);

      await tester.pumpWidget(
        const MaterialApp(home: RoutinePage()),
      );
      await tester.pumpAndSettle();

      expect(find.byType(RoutinePeriodSwitcher), findsOneWidget);
      expect(find.byType(RoutineStepCard), findsWidgets);
      expect(find.text('Hydrating Facial Cleanser'), findsOneWidget);
      expect(find.text('Heartleaf 77% Soothing Toner'), findsOneWidget);
      expect(find.text('C-Glow 15% Vitamin C Serum'), findsOneWidget);

      // Switch to Evening (PM)
      await tester.tap(find.textContaining('Evening'));
      await tester.pumpAndSettle();

      expect(find.text('Retinol 0.3% Emulsion'), findsOneWidget);
    },
  );

  testWidgets(
    'RoutineCatalogPage displays SQL-aligned catalog products',
    (tester) async {
      await tester.pumpWidget(
        const MaterialApp(home: RoutineCatalogPage()),
      );
      await tester.pumpAndSettle();

      expect(find.text('Dermatology Catalog'), findsOneWidget);
      expect(find.text('Hydrating Facial Cleanser'), findsOneWidget);
    },
  );

  testWidgets(
    'RoutineCheckinPage renders skin feel options and notes field',
    (tester) async {
      await tester.pumpWidget(
        const MaterialApp(home: RoutineCheckinPage()),
      );
      await tester.pumpAndSettle();

      expect(find.text('Daily Skin Check-in'), findsOneWidget);
      expect(find.text('Hydrated & radiant'), findsOneWidget);
      expect(find.text('Calm & steady'), findsOneWidget);
      expect(find.text('More reactive / dry'), findsOneWidget);
    },
  );
}
