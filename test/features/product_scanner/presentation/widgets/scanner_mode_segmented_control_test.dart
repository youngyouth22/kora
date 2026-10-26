import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:kora/features/product_scanner/presentation/bloc/product_scanner_event.dart';
import 'package:kora/features/product_scanner/presentation/widgets/scanner_mode_segmented_control.dart';

void main() {
  group('ScannerModeSegmentedControl', () {
    testWidgets('renders Product and Barcode segments', (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: ScannerModeSegmentedControl(
              currentMode: ScannerCaptureMode.productPhoto,
              onModeChanged: (_) {},
            ),
          ),
        ),
      );

      expect(find.text('Product'), findsOneWidget);
      expect(find.text('Barcode'), findsOneWidget);
      expect(find.byIcon(Icons.camera_alt_outlined), findsOneWidget);
      expect(find.byIcon(Icons.qr_code_scanner_rounded), findsOneWidget);
    });

    testWidgets('tapping Barcode invokes callback with barcode mode', (
      tester,
    ) async {
      ScannerCaptureMode? selectedMode;

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: ScannerModeSegmentedControl(
              currentMode: ScannerCaptureMode.productPhoto,
              onModeChanged: (mode) => selectedMode = mode,
            ),
          ),
        ),
      );

      await tester.tap(find.text('Barcode'));
      await tester.pumpAndSettle();

      expect(selectedMode, ScannerCaptureMode.barcode);
    });

    testWidgets('tapping Product invokes callback with productPhoto mode', (
      tester,
    ) async {
      ScannerCaptureMode? selectedMode;

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: ScannerModeSegmentedControl(
              currentMode: ScannerCaptureMode.barcode,
              onModeChanged: (mode) => selectedMode = mode,
            ),
          ),
        ),
      );

      await tester.tap(find.text('Product'));
      await tester.pumpAndSettle();

      expect(selectedMode, ScannerCaptureMode.productPhoto);
    });
  });
}
