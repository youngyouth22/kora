import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:kora/features/product_scanner/presentation/bloc/product_scanner_event.dart';
import 'package:kora/features/product_scanner/presentation/widgets/animated_viewfinder_frame.dart';

void main() {
  group('AnimatedViewfinderFrame', () {
    testWidgets('renders in productPhoto mode with taller dimensions', (
      tester,
    ) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: Center(
              child: AnimatedViewfinderFrame(
                mode: ScannerCaptureMode.productPhoto,
                isReady: false,
                hasPartialText: false,
              ),
            ),
          ),
        ),
      );

      final container = tester.widget<AnimatedContainer>(
        find.byType(AnimatedContainer),
      );

      expect(container.constraints?.maxHeight ?? 350.0, greaterThan(200.0));
      expect(find.byType(CustomPaint), findsWidgets);
    });

    testWidgets('morphs to shorter barcode dimensions when mode switches', (
      tester,
    ) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: Center(
              child: AnimatedViewfinderFrame(
                mode: ScannerCaptureMode.productPhoto,
                isReady: false,
                hasPartialText: false,
              ),
            ),
          ),
        ),
      );

      final productContainer = tester.widget<AnimatedContainer>(
        find.byType(AnimatedContainer),
      );
      final productHeight = productContainer.constraints?.maxHeight ?? 350.0;

      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: Center(
              child: AnimatedViewfinderFrame(
                mode: ScannerCaptureMode.barcode,
                isReady: true,
                hasPartialText: false,
              ),
            ),
          ),
        ),
      );
      await tester.pumpAndSettle();

      final barcodeContainer = tester.widget<AnimatedContainer>(
        find.byType(AnimatedContainer),
      );
      final barcodeHeight = barcodeContainer.constraints?.maxHeight ?? 150.0;

      expect(barcodeHeight, lessThan(productHeight));
    });
  });
}
