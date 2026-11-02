import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:kora/common/widgets/stepped_tutorial_sheet.dart';
import 'package:kora/core/router/app_session_state.dart';
import 'package:kora/features/routine/presentation/pages/product_scan_tutorial_page.dart';
import 'package:kora/features/routine/presentation/widgets/product_card_preview.dart';
import 'package:kora/features/routine/presentation/widgets/viewfinder_reticle_frame.dart';

final Uint8List _transparentPng = Uint8List.fromList(<int>[
  0x89, 0x50, 0x4E, 0x47, 0x0D, 0x0A, 0x1A, 0x0A, 0x00, 0x00, 0x00, 0x0D, //
  0x49, 0x48, 0x44, 0x52, 0x00, 0x00, 0x00, 0x01, 0x00, 0x00, 0x00, 0x01, //
  0x08, 0x06, 0x00, 0x00, 0x00, 0x1F, 0x15, 0xC4, 0x89, 0x00, 0x00, 0x00, //
  0x0A, 0x49, 0x44, 0x41, 0x54, 0x78, 0x9C, 0x63, 0x00, 0x01, 0x00, 0x00, //
  0x05, 0x00, 0x01, 0x0D, 0x0A, 0x2D, 0xB4, 0x00, 0x00, 0x00, 0x00, 0x49, //
  0x45, 0x4E, 0x44, 0xAE, 0x42, 0x60, 0x82,
]);

class _FakeAssetBundle extends CachingAssetBundle {
  @override
  Future<ByteData> load(String key) async {
    return ByteData.sublistView(_transparentPng);
  }

  @override
  Future<T> loadStructuredBinaryData<T>(
    String key,
    FutureOr<T> Function(ByteData data) parser,
  ) async {
    final data = const StandardMessageCodec().encodeMessage(
      <String, dynamic>{
        'assets/images/cerave_product.png': <dynamic>[],
        'assets/images/Cerave_product_bg.png': <dynamic>[],
      },
    )!;
    return parser(data);
  }
}

void main() {
  group('ProductScanTutorialPage Widget Tests', () {
    Widget buildTestableTutorialPage({
      AppSessionState? sessionState,
      VoidCallback? onTutorialFinished,
    }) {
      return MaterialApp(
        home: DefaultAssetBundle(
          bundle: _FakeAssetBundle(),
          child: ProductScanTutorialPage(
            sessionState: sessionState,
            onTutorialFinished: onTutorialFinished,
          ),
        ),
      );
    }

    testWidgets('renders Step 1 with ViewfinderReticleFrame and Next button', (
      tester,
    ) async {
      final session = AppSessionState();

      await tester.pumpWidget(
        buildTestableTutorialPage(
          sessionState: session,
        ),
      );

      // Verify step 1 title and elements
      expect(
        find.text('Take a picture of the\nproduct face...'),
        findsOneWidget,
      );
      expect(find.text('1'), findsOneWidget);
      expect(find.text('Next'), findsOneWidget);
      expect(find.byType(ViewfinderReticleFrame), findsOneWidget);
      expect(find.byType(ProductCardPreview), findsNothing);
      expect(session.hasSeenProductScanTutorial, isFalse);
    });

    testWidgets('advances to Step 2 on Next tap and completes on Got it tap', (
      tester,
    ) async {
      final session = AppSessionState();
      var finished = false;

      await tester.pumpWidget(
        buildTestableTutorialPage(
          sessionState: session,
          onTutorialFinished: () => finished = true,
        ),
      );

      expect(find.text('Next'), findsOneWidget);

      // Tap Next to advance to step 2
      await tester.tap(find.text('Next'));
      await tester.pumpAndSettle();

      // Verify step 2 title, badge, card preview and Got it CTA
      expect(
        find.text('... or upload a photo\nfrom your gallery'),
        findsOneWidget,
      );
      expect(find.text('2'), findsOneWidget);
      expect(find.text('Got it'), findsOneWidget);
      expect(find.byType(ProductCardPreview), findsOneWidget);

      // Tap Got it to finish tutorial
      await tester.tap(find.text('Got it'));
      await tester.pumpAndSettle();

      expect(finished, isTrue);
      expect(session.hasSeenProductScanTutorial, isTrue);
    });

    testWidgets(
      'tapping top-right close icon finishes tutorial and marks seen',
      (tester) async {
        final session = AppSessionState();
        var finished = false;

        await tester.pumpWidget(
          buildTestableTutorialPage(
            sessionState: session,
            onTutorialFinished: () => finished = true,
          ),
        );

        expect(session.hasSeenProductScanTutorial, isFalse);

        await tester.tap(find.byIcon(Icons.close_rounded));
        await tester.pumpAndSettle();

        expect(finished, isTrue);
        expect(session.hasSeenProductScanTutorial, isTrue);
      },
    );

    testWidgets('SteppedTutorialSheet standalone renders steps properly', (
      tester,
    ) async {
      var completed = false;

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: SteppedTutorialSheet(
              steps: const [
                TutorialStep(
                  stepNumber: 1,
                  title: 'Step One',
                  buttonText: 'Next',
                ),
                TutorialStep(
                  stepNumber: 2,
                  title: 'Step Two',
                  buttonText: 'Done',
                ),
              ],
              onComplete: () => completed = true,
            ),
          ),
        ),
      );

      expect(find.text('Step One'), findsOneWidget);
      expect(find.text('1'), findsOneWidget);

      await tester.tap(find.text('Next'));
      await tester.pumpAndSettle();

      expect(find.text('Step Two'), findsOneWidget);
      expect(find.text('2'), findsOneWidget);

      await tester.tap(find.text('Done'));
      await tester.pumpAndSettle();

      expect(completed, isTrue);
    });
  });
}
