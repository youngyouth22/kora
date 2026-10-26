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
            body: DayOfWeekSelector(
              selectedDay: selectedDay,
              onDaySelected: (day) => selectedDay = day,
            ),
          ),
        ),
      );

      expect(find.text('Preferred Scan Day'), findsOneWidget);
      expect(find.byType(DayOfWeekSelector), findsOneWidget);

      // Tap Monday chip
      final mondayFinder = find.text('M');
      expect(mondayFinder, findsOneWidget);
      await tester.tap(mondayFinder);
      await tester.pump();

      expect(selectedDay, equals(DateTime.monday));
    });
  });
}
