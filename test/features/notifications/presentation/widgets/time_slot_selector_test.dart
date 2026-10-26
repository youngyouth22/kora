import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:kora/features/notifications/presentation/widgets/time_slot_selector.dart';

void main() {
  group('TimeSlotSelector Widget Tests', () {
    testWidgets('renders evening, morning, and custom time slot options', (
      tester,
    ) async {
      var hour = 20;
      var minute = 0;

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: TimeSlotSelector(
              selectedHour: hour,
              selectedMinute: minute,
              onTimeSelected: (h, m) {
                hour = h;
                minute = m;
              },
            ),
          ),
        ),
      );

      expect(find.text('Preferred Reminder Time'), findsOneWidget);
      expect(find.text('Evening'), findsOneWidget);
      expect(find.text('8:00 PM'), findsOneWidget);
      expect(find.text('Morning'), findsOneWidget);
      expect(find.text('9:00 AM'), findsOneWidget);
      expect(find.text('Recommended'), findsOneWidget);

      // Tap Morning slot
      await tester.tap(find.text('Morning'));
      await tester.pump();

      expect(hour, equals(9));
      expect(minute, equals(0));
    });
  });
}
