import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:kora/common/app_colors.dart';
import 'package:kora/features/home/presentation/widgets/day_streak_bar.dart';

void main() {
  Widget buildTestableWidget({
    Widget child = const DayStreakBar(),
    Size surfaceSize = const Size(390, 844),
  }) {
    return MaterialApp(
      home: Scaffold(
        backgroundColor: AppColors.scaffoldColor,
        body: Center(
          child: child,
        ),
      ),
    );
  }

  group('DayStreakBar Widget Tests', () {
    testWidgets('renders 7 days with default configuration matching design', (
      tester,
    ) async {
      await tester.pumpWidget(buildTestableWidget());

      // 1 completed day with check icon
      expect(find.byIcon(Icons.check_rounded), findsOneWidget);

      // 6 text days with numbers '2', '3', '4', '5', '6', '7'
      expect(find.text('2'), findsOneWidget);
      expect(find.text('3'), findsOneWidget);
      expect(find.text('4'), findsOneWidget);
      expect(find.text('5'), findsOneWidget);
      expect(find.text('6'), findsOneWidget);
      expect(find.text('7'), findsOneWidget);

      // 'Day' label is present on all non-completed days (6 times)
      expect(find.text('Day'), findsNWidgets(6));
    });

    testWidgets('triggers onDayTap callback when a day circle is tapped', (
      tester,
    ) async {
      StreakDay? tappedDay;

      await tester.pumpWidget(
        buildTestableWidget(
          child: DayStreakBar(
            onDayTap: (day) => tappedDay = day,
          ),
        ),
      );

      // Tap on Day 2
      await tester.tap(find.text('2'));
      await tester.pumpAndSettle();

      expect(tappedDay, isNotNull);
      expect(tappedDay!.dayNumber, 2);
      expect(tappedDay!.isToday, isTrue);

      // Tap on Day 1 (completed check icon)
      await tester.tap(find.byIcon(Icons.check_rounded));
      await tester.pumpAndSettle();

      expect(tappedDay!.dayNumber, 1);
      expect(tappedDay!.isCompleted, isTrue);
    });

    testWidgets('is fully responsive on narrow screens without overflow', (
      tester,
    ) async {
      // Narrow device screen (e.g. 320px width)
      tester.view.physicalSize = const Size(320, 600);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(tester.view.resetPhysicalSize);
      addTearDown(tester.view.resetDevicePixelRatio);

      await tester.pumpWidget(buildTestableWidget());
      await tester.pumpAndSettle();

      // No Flutter layout overflow error
      expect(tester.takeException(), isNull);
      expect(find.byIcon(Icons.check_rounded), findsOneWidget);
      expect(find.text('7'), findsOneWidget);
    });

    testWidgets('is constrained and well-proportioned on wide tablet screens', (
      tester,
    ) async {
      // Wide tablet screen (e.g. 800px width)
      tester.view.physicalSize = const Size(800, 1200);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(tester.view.resetPhysicalSize);
      addTearDown(tester.view.resetDevicePixelRatio);

      await tester.pumpWidget(buildTestableWidget());
      await tester.pumpAndSettle();

      expect(tester.takeException(), isNull);
      final constrainedBoxFinder = find.byType(ConstrainedBox);
      expect(constrainedBoxFinder, findsWidgets);
    });

    testWidgets('renders custom days list correctly', (tester) async {
      const customDays = [
        StreakDay(dayNumber: 1, isCompleted: true, isToday: false),
        StreakDay(dayNumber: 2, isCompleted: true, isToday: false),
        StreakDay(dayNumber: 3, isCompleted: true, isToday: false),
        StreakDay(dayNumber: 4, isCompleted: false, isToday: true),
        StreakDay(dayNumber: 5, isCompleted: false, isToday: false),
        StreakDay(dayNumber: 6, isCompleted: false, isToday: false),
        StreakDay(dayNumber: 7, isCompleted: false, isToday: false),
      ];

      await tester.pumpWidget(
        buildTestableWidget(
          child: const DayStreakBar(days: customDays),
        ),
      );

      // 3 completed days
      expect(find.byIcon(Icons.check_rounded), findsNWidgets(3));
      // Remaining 4 days
      expect(find.text('4'), findsOneWidget);
      expect(find.text('5'), findsOneWidget);
      expect(find.text('6'), findsOneWidget);
      expect(find.text('7'), findsOneWidget);
    });

    testWidgets('provides accessible semantics on every day', (tester) async {
      await tester.pumpWidget(buildTestableWidget());

      expect(
        find.bySemanticsLabel('Day 1, completed'),
        findsOneWidget,
      );
      expect(
        find.bySemanticsLabel('Day 2, today, active streak'),
        findsOneWidget,
      );
      expect(
        find.bySemanticsLabel('Day 3, upcoming'),
        findsOneWidget,
      );
    });
  });
}
