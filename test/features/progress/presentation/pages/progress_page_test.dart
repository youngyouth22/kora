import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:get_it/get_it.dart';
import 'package:kora/features/progress/presentation/pages/compare_scans_page.dart';
import 'package:kora/features/progress/presentation/pages/concern_detail_page.dart';
import 'package:kora/features/progress/presentation/pages/progress_page.dart';

void main() {
  setUp(() async {
    await GetIt.instance.reset();
  });

  tearDown(() async {
    await GetIt.instance.reset();
  });

  testWidgets(
    'ProgressPage renders Overall, By concern, and Calendar segments',
    (tester) async {
      tester.view.physicalSize = const Size(1080, 2800);
      tester.view.devicePixelRatio = 2.0;
      addTearDown(tester.view.resetPhysicalSize);
      addTearDown(tester.view.resetDevicePixelRatio);

      await tester.pumpWidget(
        const MaterialApp(home: ProgressPage()),
      );
      await tester.pumpAndSettle();

      expect(find.text('Skin Progress'), findsOneWidget);
      expect(find.text('Overall Trajectory'), findsOneWidget);
      expect(find.text('Controlled Product Experiments'), findsOneWidget);

      // Switch to By concern segment
      await tester.tap(find.text('By concern'));
      await tester.pumpAndSettle();

      expect(find.text('Primary Headline Concerns (6)'), findsOneWidget);
      expect(find.text('Dark spots'), findsOneWidget);
      expect(find.text('Redness'), findsOneWidget);

      // Switch to Calendar segment
      await tester.tap(find.text('Calendar'));
      await tester.pumpAndSettle();

      expect(find.text('Active days'), findsOneWidget);
      expect(find.text('Unlocked Milestones'), findsOneWidget);
    },
  );

  testWidgets(
    'ConcernDetailPage renders trajectory chart, regional zones, and actives',
    (tester) async {
      tester.view.physicalSize = const Size(1080, 2800);
      tester.view.devicePixelRatio = 2.0;
      addTearDown(tester.view.resetPhysicalSize);
      addTearDown(tester.view.resetDevicePixelRatio);

      await tester.pumpWidget(
        const MaterialApp(
          home: ConcernDetailPage(),
        ),
      );
      await tester.pumpAndSettle();

      expect(find.text('Dark spots'), findsOneWidget);
      expect(find.text('Dark spots Trajectory'), findsOneWidget);
      expect(find.text('Regional Facial Zones (HD)'), findsOneWidget);
      expect(find.text('What this means'), findsOneWidget);
      expect(find.text('What can help'), findsOneWidget);

      await tester.scrollUntilVisible(
        find.text('Test a product for this'),
        300,
        scrollable: find.byType(Scrollable),
      );
      expect(find.text('Test a product for this'), findsOneWidget);
    },
  );

  testWidgets(
    'CompareScansPage renders split comparison viewer and concern deltas',
    (tester) async {
      tester.view.physicalSize = const Size(1080, 2800);
      tester.view.devicePixelRatio = 2.0;
      addTearDown(tester.view.resetPhysicalSize);
      addTearDown(tester.view.resetDevicePixelRatio);

      await tester.pumpWidget(
        const MaterialApp(
          home: CompareScansPage(),
        ),
      );
      await tester.pumpAndSettle();

      expect(find.text('Compare Scans'), findsOneWidget);
      expect(find.text('BEFORE (SCAN A)'), findsOneWidget);
      expect(find.text('AFTER (SCAN B)'), findsOneWidget);
      expect(find.text('Detected Zones'), findsOneWidget);
      expect(find.text('Share result'), findsOneWidget);
    },
  );
}
