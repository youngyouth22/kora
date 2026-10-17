import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:kora/core/router/app_router.dart';
import 'package:kora/core/router/app_routes.dart';
import 'package:kora/core/router/app_session_state.dart';
import 'package:kora/features/guided_capture/presentation/pages/photo_review_page.dart';
import 'package:kora/main.dart';

final Uint8List _kTransparentImage = Uint8List.fromList(<int>[
  0x89,
  0x50,
  0x4E,
  0x47,
  0x0D,
  0x0A,
  0x1A,
  0x0A,
  0x00,
  0x00,
  0x00,
  0x0D,
  0x49,
  0x48,
  0x44,
  0x52,
  0x00,
  0x00,
  0x00,
  0x01,
  0x00,
  0x00,
  0x00,
  0x01,
  0x08,
  0x06,
  0x00,
  0x00,
  0x00,
  0x1F,
  0x15,
  0xC4,
  0x89,
  0x00,
  0x00,
  0x00,
  0x0A,
  0x49,
  0x44,
  0x41,
  0x54,
  0x78,
  0x9C,
  0x63,
  0x00,
  0x01,
  0x00,
  0x00,
  0x05,
  0x00,
  0x01,
  0x0D,
  0x0A,
  0x2D,
  0xB4,
  0x00,
  0x00,
  0x00,
  0x00,
  0x49,
  0x45,
  0x4E,
  0x44,
  0xAE,
  0x42,
  0x60,
  0x82,
]);

void main() {
  group('PhotoReviewPage Widget Tests', () {
    testWidgets('renders photo preview and bottom action buttons', (
      tester,
    ) async {
      await tester.pumpWidget(
        MaterialApp(
          home: PhotoReviewPage(
            imagePath: '',
            imageProvider: MemoryImage(_kTransparentImage),
          ),
        ),
      );

      // Verify the two requested buttons are present
      expect(find.text('Use this photo'), findsOneWidget);
      expect(find.text('Retake'), findsOneWidget);

      // Verify zoom hint chip and InteractiveViewer
      expect(find.text('Pinch to inspect quality'), findsOneWidget);
      expect(find.byType(InteractiveViewer), findsOneWidget);

      // Verify 80% and 20% flex partitioning
      final expandedWidgets = tester
          .widgetList<Expanded>(find.byType(Expanded))
          .toList();
      expect(expandedWidgets.any((e) => e.flex == 8), isTrue);
      expect(expandedWidgets.any((e) => e.flex == 2), isTrue);
    });

    testWidgets('displays fallback view when image file does not exist', (
      tester,
    ) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: PhotoReviewPage(imagePath: '/non/existent/path/photo.jpg'),
        ),
      );

      expect(find.text('Photo preview unavailable'), findsOneWidget);
      expect(find.byIcon(Icons.broken_image_outlined), findsOneWidget);
    });

    testWidgets('triggers onRetake callback when Retake button is tapped', (
      tester,
    ) async {
      var retakeCalled = false;

      await tester.pumpWidget(
        MaterialApp(
          home: PhotoReviewPage(
            imagePath: '',
            imageProvider: MemoryImage(_kTransparentImage),
            onRetake: () => retakeCalled = true,
          ),
        ),
      );

      await tester.tap(find.text('Retake'));
      await tester.pump();

      expect(retakeCalled, isTrue);
    });

    testWidgets(
      'triggers onUsePhoto callback with imagePath '
      'when Use this photo is tapped',
      (tester) async {
        String? capturedPath;

        await tester.pumpWidget(
          MaterialApp(
            home: PhotoReviewPage(
              imagePath: '/tmp/test_captured_selfie.jpg',
              imageProvider: MemoryImage(_kTransparentImage),
              onUsePhoto: (path) => capturedPath = path,
            ),
          ),
        );

        await tester.tap(find.text('Use this photo'));
        await tester.pump();

        expect(capturedPath, equals('/tmp/test_captured_selfie.jpg'));
      },
    );

    testWidgets('has accessible Semantics on both buttons', (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: PhotoReviewPage(
            imagePath: '',
            imageProvider: MemoryImage(_kTransparentImage),
          ),
        ),
      );

      expect(
        find.byWidgetPredicate(
          (widget) =>
              widget is Semantics &&
              widget.properties.label == 'Retake photo' &&
              (widget.properties.button ?? false),
        ),
        findsOneWidget,
      );

      expect(
        find.byWidgetPredicate(
          (widget) =>
              widget is Semantics &&
              widget.properties.label == 'Use this photo for skin analysis' &&
              (widget.properties.button ?? false),
        ),
        findsOneWidget,
      );
    });

    testWidgets('integrates with AppRouter at AppRoutes.scanReview', (
      tester,
    ) async {
      final session = AppSessionState(
        isInitialized: true,
        isOnboardingCompleted: true,
      );
      final router = AppRouter(sessionState: session);

      await tester.pumpWidget(MainApp(appRouter: router));
      await tester.pumpAndSettle();

      router.router.go(
        AppRoutes.scanReview,
        extra: '/path/to/my_face_capture.jpg',
      );
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 300));

      expect(find.byType(PhotoReviewPage), findsOneWidget);
      expect(find.text('Use this photo'), findsOneWidget);
      expect(find.text('Retake'), findsOneWidget);
    });
  });
}
