import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:kora/core/router/app_session_state.dart';
import 'package:kora/features/guided_capture/presentation/widgets/new_scan_selection_sheet.dart';
import 'package:kora/features/guided_capture/presentation/widgets/scan_option_card.dart';

void main() {
  group('NewScanSelectionSheet Widget Tests', () {
    testWidgets(
      'renders title, subtitle, close icon, and 2 scan option cards',
      (tester) async {
        await tester.pumpWidget(
          const MaterialApp(
            home: Scaffold(
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
        expect(find.byType(Placeholder), findsNWidgets(2));
        expect(find.byIcon(Icons.close_rounded), findsOneWidget);
      },
    );

    testWidgets('tapping Face card invokes onFaceScanSelected callback', (
      tester,
    ) async {
      var faceSelected = false;

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
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
          MaterialApp(
            home: Scaffold(
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
        MaterialApp(
          home: Scaffold(
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
