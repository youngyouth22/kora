import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:kora/features/coach/presentation/widgets/coach_bottom_sheet.dart';

void main() {
  group('CoachBottomSheet Widget and Navigation Tests', () {
    Widget buildAppWithFab() {
      return MaterialApp(
        home: Scaffold(
          body: Center(
            child: Builder(
              builder: (context) {
                return ElevatedButton(
                  onPressed: () => showCoachBottomSheet<void>(context),
                  child: const Text('Open Coach Sheet'),
                );
              },
            ),
          ),
        ),
      );
    }

    testWidgets(
      'opens modal bottom sheet when showCoachBottomSheet is called',
      (
        tester,
      ) async {
        await tester.pumpWidget(buildAppWithFab());
        await tester.pumpAndSettle();

        await tester.tap(find.text('Open Coach Sheet'));
        await tester.pumpAndSettle();

        expect(find.byType(CoachBottomSheetContent), findsOneWidget);
        expect(
          find.text("Hi I'm Amie,\nyour skincare companion"),
          findsOneWidget,
        );
      },
    );

    testWidgets(
      'renders without overflow when bottom padding is 48px '
      '(e.g. Android nav bar)',
      (tester) async {
        tester.view.physicalSize = const Size(392, 800);
        tester.view.devicePixelRatio = 1.0;
        tester.view.padding = const FakeViewPadding(bottom: 48, top: 24);
        addTearDown(() {
          tester.view.resetPhysicalSize();
          tester.view.resetDevicePixelRatio();
          tester.view.resetPadding();
        });

        await tester.pumpWidget(buildAppWithFab());
        await tester.pumpAndSettle();

        await tester.tap(find.text('Open Coach Sheet'));
        await tester.pumpAndSettle();

        expect(find.byType(CoachBottomSheetContent), findsOneWidget);
        expect(tester.takeException(), isNull);
      },
    );

    testWidgets(
      'navigates to chat page on PageView when New Chat is tapped and back',
      (
        tester,
      ) async {
        await tester.pumpWidget(buildAppWithFab());
        await tester.pumpAndSettle();

        await tester.tap(find.text('Open Coach Sheet'));
        await tester.pumpAndSettle();

        // Page 0: Hub
        expect(find.text('Start a chat'), findsOneWidget);

        // Tap New Chat
        await tester.tap(find.text('New Chat'));
        await tester.pumpAndSettle();

        // Page 1: Chat page
        expect(find.text('Write your question...'), findsOneWidget);
        expect(find.bySemanticsLabel('Back to companion hub'), findsOneWidget);

        // Tap Back button
        await tester.tap(find.bySemanticsLabel('Back to companion hub'));
        await tester.pumpAndSettle();

        // Back to Page 0: Hub
        expect(find.text('Start a chat'), findsOneWidget);
      },
    );

    testWidgets('tapping quick prompt switches to chat and loads question', (
      tester,
    ) async {
      await tester.pumpWidget(buildAppWithFab());
      await tester.pumpAndSettle();

      await tester.tap(find.text('Open Coach Sheet'));
      await tester.pumpAndSettle();

      // Tap prompt card
      await tester.tap(
        find.text('✨ Why am I getting small breakouts lately?'),
      );
      await tester.pumpAndSettle();

      // Now on Page 1 with message bubble
      expect(find.text('Write your question...'), findsOneWidget);
      expect(
        find.text('Why am I getting small breakouts lately?'),
        findsOneWidget,
      );
    });

    testWidgets(
      'system back on chat page returns to companion hub instead of '
      'closing sheet',
      (tester) async {
        await tester.pumpWidget(buildAppWithFab());
        await tester.pumpAndSettle();

        await tester.tap(find.text('Open Coach Sheet'));
        await tester.pumpAndSettle();

        // Tap New Chat to go to Page 1
        await tester.tap(find.text('New Chat'));
        await tester.pumpAndSettle();
        expect(find.text('Write your question...'), findsOneWidget);

        // Simulate system back button via handlePopRoute
        await tester.binding.handlePopRoute();
        await tester.pumpAndSettle();

        // Bottom sheet is still open and navigated back to Page 0
        expect(find.byType(CoachBottomSheetContent), findsOneWidget);
        expect(find.text('Start a chat'), findsOneWidget);
      },
    );

    testWidgets('close icon dismisses the modal bottom sheet', (tester) async {
      await tester.pumpWidget(buildAppWithFab());
      await tester.pumpAndSettle();

      await tester.tap(find.text('Open Coach Sheet'));
      await tester.pumpAndSettle();

      expect(find.byType(CoachBottomSheetContent), findsOneWidget);

      await tester.tap(find.bySemanticsLabel('Close coach hub'));
      await tester.pumpAndSettle();

      expect(find.byType(CoachBottomSheetContent), findsNothing);
    });
  });
}
