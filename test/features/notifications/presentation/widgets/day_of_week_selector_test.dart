import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:kora/features/notifications/presentation/widgets/day_of_week_selector.dart';

void main() {
  group('DayOfWeekSelector Widget Tests', () {
    testWidgets('renders all 7 days with Sunday selected by default', (
      tester,
    ) async {
      var selectedDay = DateTime.sunday;

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: StatefulBuilder(
              builder: (context, setState) {
                return DayOfWeekSelector(
                  selectedDay: selectedDay,
                  onDaySelected: (day) => setState(() => selectedDay = day),
                );
              },
            ),
          ),
        ),
      );

      expect(find.byType(DayOfWeekSelector), findsOneWidget);

      for (final label in ['Mon', 'Tue', 'Wed', 'Thu', 'Fri', 'Sat', 'Sun']) {
        expect(find.text(label), findsOneWidget);
      }

      // Tap Monday chip
      final mondayFinder = find.text('Mon');
      expect(mondayFinder, findsOneWidget);
      await tester.tap(mondayFinder);
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 130));
      await tester.pumpAndSettle();

      expect(selectedDay, equals(DateTime.monday));
    });

    testWidgets('renders properly with reduce motion enabled', (
      tester,
    ) async {
      var selectedDay = DateTime.friday;

      await tester.pumpWidget(
        MaterialApp(
          home: MediaQuery(
            data: const MediaQueryData(disableAnimations: true),
            child: Scaffold(
              body: StatefulBuilder(
                builder: (context, setState) {
                  return DayOfWeekSelector(
                    selectedDay: selectedDay,
                    onDaySelected: (day) => setState(() => selectedDay = day),
                  );
                },
              ),
            ),
          ),
        ),
      );

      final wednesdayFinder = find.text('Wed');
      await tester.tap(wednesdayFinder);
      await tester.pumpAndSettle();

      expect(selectedDay, equals(DateTime.wednesday));
    });
  });
}
