import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:kora/features/guided_capture/presentation/widgets/bottom_guidance_panel.dart';

void main() {
  group('BottomGuidancePanel Widget Tests', () {
    testWidgets('renders message, chips, and prevents tap when invalid', (
      tester,
    ) async {
      var manualCaptureTapped = false;

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: BottomGuidancePanel(
              message: 'Position your face inside the oval',
              isPositionOk: false,
              isLightOk: true,
              isAngleOk: false,
              canManualCapture: false,
              onManualCapture: () => manualCaptureTapped = true,
            ),
          ),
        ),
      );

      expect(find.text('Position your face inside the oval'), findsOneWidget);
      expect(find.text('Position'), findsOneWidget);
      expect(find.text('Light'), findsOneWidget);
      expect(find.text('Angle'), findsOneWidget);

      await tester.tap(find.byType(GestureDetector).last);
      expect(manualCaptureTapped, isFalse);
    });

    testWidgets('triggers onManualCapture when canManualCapture is true', (
      tester,
    ) async {
      var manualCaptureTapped = false;

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: BottomGuidancePanel(
              message: 'Hold still...',
              isPositionOk: true,
              isLightOk: true,
              isAngleOk: true,
              canManualCapture: true,
              onManualCapture: () => manualCaptureTapped = true,
            ),
          ),
        ),
      );

      expect(find.text('Hold still...'), findsOneWidget);

      await tester.tap(find.byType(GestureDetector).last);
      expect(manualCaptureTapped, isTrue);
    });
  });
}
