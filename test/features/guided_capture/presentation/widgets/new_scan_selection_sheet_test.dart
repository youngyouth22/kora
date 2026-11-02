import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:kora/core/router/app_session_state.dart';
import 'package:kora/features/guided_capture/presentation/widgets/new_scan_selection_sheet.dart';
import 'package:kora/features/guided_capture/presentation/widgets/scan_option_card.dart';

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
        'assets/images/scan_product.png': <dynamic>[],
        'assets/images/scan_skin.png': <dynamic>[],
      },
    )!;
    return parser(data);
  }
}

void main() {
  group('NewScanSelectionSheet Widget Tests', () {
    Widget buildTestableWidget({required Widget child}) {
      return DefaultAssetBundle(
        bundle: _FakeAssetBundle(),
        child: MaterialApp(
          home: child,
        ),
      );
    }

    testWidgets(
      'renders title, subtitle, close icon, and 2 scan option cards',
      (tester) async {
        await tester.pumpWidget(
          buildTestableWidget(
            child: const Scaffold(
              body: NewScanSelectionSheet(),
            ),
          ),
        );

        expect(find.text('Make a New Scan'), findsOneWidget);
        expect(
          find.text('Choose what you want to scan with Amie'),
          findsOneWidget,
        );
        expect(find.text('Face'), findsOneWidget);
        expect(find.text('See the condition of your skin'), findsOneWidget);
        expect(find.text('Cosmetics'), findsOneWidget);
        expect(
          find.text('See if a skincare product fits you'),
          findsOneWidget,
        );
        expect(find.byType(ScanOptionCard), findsNWidgets(2));
        expect(find.byType(Image), findsNWidgets(2));
        expect(find.byIcon(Icons.close_rounded), findsOneWidget);
      },
    );

    testWidgets('tapping Face card invokes onFaceScanSelected callback', (
      tester,
    ) async {
      var faceSelected = false;

      await tester.pumpWidget(
        buildTestableWidget(
          child: Scaffold(
            body: Builder(
              builder: (context) => ElevatedButton(
                onPressed: () => NewScanSelectionSheet.show(
                  context,
                  onFaceScanSelected: () => faceSelected = true,
                ),
                child: const Text('Open'),
              ),
            ),
          ),
        ),
      );

      await tester.tap(find.text('Open'));
      await tester.pumpAndSettle();

      expect(find.text('Make a New Scan'), findsOneWidget);

      await tester.tap(find.text('Face'));
      await tester.pumpAndSettle();

      expect(faceSelected, isTrue);
      expect(find.text('Make a New Scan'), findsNothing);
    });

    testWidgets(
      'tapping Cosmetics invokes onProductScanSelected callback',
      (tester) async {
        var productSelected = false;

        await tester.pumpWidget(
          buildTestableWidget(
            child: Scaffold(
              body: Builder(
                builder: (context) => ElevatedButton(
                  onPressed: () => NewScanSelectionSheet.show(
                    context,
                    onProductScanSelected: () => productSelected = true,
                  ),
                  child: const Text('Open'),
                ),
              ),
            ),
          ),
        );

        await tester.tap(find.text('Open'));
        await tester.pumpAndSettle();

        await tester.tap(find.text('Cosmetics'));
        await tester.pumpAndSettle();

        expect(productSelected, isTrue);
        expect(find.text('Make a New Scan'), findsNothing);
      },
    );

    testWidgets('tapping close icon dismisses the modal', (tester) async {
      await tester.pumpWidget(
        buildTestableWidget(
          child: Scaffold(
            body: Builder(
              builder: (context) => ElevatedButton(
                onPressed: () => NewScanSelectionSheet.show(context),
                child: const Text('Open'),
              ),
            ),
          ),
        ),
      );

      await tester.tap(find.text('Open'));
      await tester.pumpAndSettle();

      expect(find.text('Make a New Scan'), findsOneWidget);

      await tester.tap(find.byIcon(Icons.close_rounded));
      await tester.pumpAndSettle();

      expect(find.text('Make a New Scan'), findsNothing);
    });

    testWidgets('session state tracks hasSeenProductScanTutorial', (
      tester,
    ) async {
      final session = AppSessionState();
      expect(session.hasSeenProductScanTutorial, isFalse);

      session.markProductScanTutorialSeen();
      expect(session.hasSeenProductScanTutorial, isTrue);

      session.reset();
      expect(session.hasSeenProductScanTutorial, isFalse);
    });
  });
}
