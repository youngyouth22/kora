import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:get_it/get_it.dart';
import 'package:kora/core/router/app_session_state.dart';
import 'package:kora/features/guided_capture/guided_capture_injection.dart';
import 'package:kora/features/guided_capture/presentation/pages/guided_capture_page.dart';
import 'package:kora/features/guided_capture/presentation/widgets/bottom_guidance_panel.dart';
import 'package:kora/features/guided_capture/presentation/widgets/capture_oval_guide.dart';
import 'package:kora/features/guided_capture/presentation/widgets/capture_tips_sheet.dart';

void main() {
  setUp(() {
    final getIt = GetIt.instance;
    if (!getIt.isRegistered<AppSessionState>()) {
      getIt.registerLazySingleton<AppSessionState>(AppSessionState.new);
    }
    initGuidedCaptureInjection(getIt);
  });

  group('GuidedCapturePage CaptureTipsSheet auto-display & interaction', () {
    testWidgets(
      'automatically shows 3-step tutorial on first visit, '
      'hides oval and guidance, and resumes scan once dismissed',
      (tester) async {
        final sessionState = AppSessionState();

        await tester.pumpWidget(
          MaterialApp(
            home: GuidedCapturePage(
              sessionState: sessionState,
              onCaptureSuccess: (_) async {},
            ),
          ),
        );

        // Allow postFrameCallback to fire
        await tester.pump();
        await tester.pump(const Duration(milliseconds: 300));

        // Bottomsheet is visible
        expect(find.byType(CaptureTipsSheet), findsOneWidget);
        expect(sessionState.hasSeenCaptureTips, isTrue);

        // Oval guide and bottom guidance panel must NOT be visible
        expect(find.byType(CaptureOvalGuide), findsNothing);
        expect(find.byType(BottomGuidancePanel), findsNothing);

        // Step 1 content
        expect(find.text('1'), findsOneWidget);
        expect(find.text('Find an area\nwith good lighting'), findsOneWidget);
        expect(find.text('Next'), findsOneWidget);

        // Advance to Step 2
        await tester.tap(find.text('Next'));
        await tester.pump();
        await tester.pump(const Duration(milliseconds: 350));

        // Step 2 content
        expect(find.text('2'), findsOneWidget);
        expect(
          find.text('For the best results\ntake everything off,\neven make up'),
          findsOneWidget,
        );
        expect(find.text('Next'), findsOneWidget);

        // Advance to Step 3
        await tester.tap(find.text('Next'));
        await tester.pump();
        await tester.pump(const Duration(milliseconds: 350));

        // Step 3 content
        expect(find.text('3'), findsOneWidget);
        expect(
          find.text(
            "Pull your hair back\nso it doesn't touch your face,\n"
            'and remove glasses',
          ),
          findsOneWidget,
        );
        expect(find.text('Got it'), findsOneWidget);

        // Tap Got it to dismiss tutorial
        await tester.tap(find.text('Got it'));
        await tester.pump();
        await tester.pump(const Duration(milliseconds: 350));

        // Bottomsheet is closed
        expect(find.byType(CaptureTipsSheet), findsNothing);
      },
    );

    testWidgets(
      'does NOT automatically show CaptureTipsSheet if already seen',
      (tester) async {
        final sessionState = AppSessionState(hasSeenCaptureTips: true);

        await tester.pumpWidget(
          MaterialApp(
            home: GuidedCapturePage(
              sessionState: sessionState,
              onCaptureSuccess: (_) async {},
            ),
          ),
        );

        // Allow postFrameCallback to fire
        await tester.pump();
        await tester.pump(const Duration(milliseconds: 300));

        expect(find.byType(CaptureTipsSheet), findsNothing);
      },
    );

    testWidgets(
      'presents CaptureTipsSheet via show() method with custom bottom sheet',
      (tester) async {
        await tester.pumpWidget(
          MaterialApp(
            home: Scaffold(
              body: Builder(
                builder: (context) => ElevatedButton(
                  onPressed: () => CaptureTipsSheet.show(context),
                  child: const Text('Open'),
                ),
              ),
            ),
          ),
        );

        await tester.tap(find.text('Open'));
        await tester.pump();
        await tester.pump(const Duration(milliseconds: 350));

        expect(find.byType(CaptureTipsSheet), findsOneWidget);
        expect(find.text('1'), findsOneWidget);
        expect(find.text('Find an area\nwith good lighting'), findsOneWidget);
        expect(find.text('Next'), findsOneWidget);

        // Drag to swipe to step 2
        await tester.drag(find.byType(PageView), const Offset(-400, 0));
        await tester.pump();
        await tester.pump(const Duration(milliseconds: 350));

        expect(find.text('2'), findsOneWidget);
        expect(
          find.text('For the best results\ntake everything off,\neven make up'),
          findsOneWidget,
        );
      },
    );
  });
}
