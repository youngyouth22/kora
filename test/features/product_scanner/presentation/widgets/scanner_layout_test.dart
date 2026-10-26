import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:kora/features/product_scanner/domain/entities/scanner_bounding_box.dart';
import 'package:kora/features/product_scanner/presentation/widgets/scanner_layout.dart';

void main() {
  group('ScannerLayout Unit Tests', () {
    const screenSize = Size(390, 844);
    const topInset = 47.0;
    const bottomInset = 34.0;

    test('centers frame in regionRect for both product and barcode modes', () {
      final productLayout = ScannerLayout.compute(
        screenSize: screenSize,
        topInset: topInset,
        bottomInset: bottomInset,
        isBarcode: false,
      );

      final barcodeLayout = ScannerLayout.compute(
        screenSize: screenSize,
        topInset: topInset,
        bottomInset: bottomInset,
        isBarcode: true,
      );

      // Both centers must match the region center exactly (guaranteed)
      expect(
        productLayout.frameRect.center.dx,
        closeTo(productLayout.regionRect.center.dx, 0.001),
      );
      expect(
        productLayout.frameRect.center.dy,
        closeTo(productLayout.regionRect.center.dy, 0.001),
      );
      expect(
        barcodeLayout.frameRect.center.dx,
        closeTo(barcodeLayout.regionRect.center.dx, 0.001),
      );
      expect(
        barcodeLayout.frameRect.center.dy,
        closeTo(barcodeLayout.regionRect.center.dy, 0.001),
      );

      // Segmented control is below the frame with the proper gap
      expect(
        productLayout.segmentedTop,
        greaterThan(productLayout.frameRect.bottom),
      );
      expect(
        barcodeLayout.segmentedTop,
        greaterThan(barcodeLayout.frameRect.bottom),
      );

      // Hint pill is above the frame with the proper gap
      expect(productLayout.hintBottom, lessThan(productLayout.frameRect.top));
      expect(barcodeLayout.hintBottom, lessThan(barcodeLayout.frameRect.top));
    });

    test('mapNormalizedToScreen maps bounding box correctly onto preview', () {
      const box = ScannerBoundingBox(
        left: 0.2,
        top: 0.3,
        right: 0.8,
        bottom: 0.5,
      );

      final mapped = ScannerLayout.mapNormalizedToScreen(
        box: box,
        screenSize: screenSize,
        previewAspectRatio: 9 / 16, // typical portrait camera sensor
      );

      expect(mapped, isNotNull);
      expect(mapped!.width, greaterThan(0));
      expect(mapped.height, greaterThan(0));
      expect(mapped.left, greaterThanOrEqualTo(0));
      expect(mapped.right, lessThanOrEqualTo(screenSize.width));
    });

    test(
      'barcodeSourceRect falls back to frame if detection is degenerate',
      () {
        final layout = ScannerLayout.compute(
          screenSize: screenSize,
          topInset: topInset,
          bottomInset: bottomInset,
          isBarcode: true,
        );

        final fallback = layout.frameRect;

        final srcNull = ScannerLayout.barcodeSourceRect(
          detected: null,
          fallback: fallback,
          screenSize: screenSize,
        );
        expect(srcNull, equals(fallback));

        final srcTiny = ScannerLayout.barcodeSourceRect(
          detected: const Rect.fromLTWH(100, 100, 5, 5),
          fallback: fallback,
          screenSize: screenSize,
        );
        expect(srcTiny, equals(fallback));
      },
    );

    test(
      'barcodeTargetRect scales small barcode up without exceeding bounds',
      () {
        const source = Rect.fromLTWH(100, 300, 100, 40);
        const frame = Rect.fromLTWH(45, 250, 300, 150);

        final target = ScannerLayout.barcodeTargetRect(
          source: source,
          frame: frame,
          screenSize: screenSize,
        );

        expect(target.center, equals(frame.center));
        expect(target.width, greaterThan(source.width));
        expect(target.height, greaterThan(source.height));
      },
    );
  });
}
