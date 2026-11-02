import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:kora/common/widgets/primary_button.dart';
import 'package:kora/common/widgets/secondary_button.dart';
import 'package:kora/features/skin_analysis/presentation/bloc/skin_analysis_bloc.dart';
import 'package:kora/features/skin_analysis/presentation/bloc/skin_analysis_event.dart';
import 'package:kora/features/skin_analysis/presentation/bloc/skin_analysis_state.dart';
import 'package:kora/features/skin_analysis/presentation/pages/scan_analyzing_page.dart';
import 'package:kora/features/skin_analysis/presentation/widgets/face_sparkle_overlay.dart';

// Test double declared locally for widget testing.
// ignore: prefer_file_naming_conventions
class _FakeSkinAnalysisBloc extends Bloc<SkinAnalysisEvent, SkinAnalysisState>
    implements SkinAnalysisBloc {
  _FakeSkinAnalysisBloc([SkinAnalysisState? initialState])
    : super(initialState ?? const SkinAnalysisState()) {
    on<StartSkinAnalysisEvent>((event, emit) {
      emit(
        state.copyWith(
          status: SkinAnalysisStatus.preprocessing,
          currentStepIndex: 0,
        ),
      );
    });
  }
}

void main() {
  group('ScanAnalyzingPage Widget Tests', () {
    testWidgets(
      'renders face sparkle overlay, cancel button, and loading steps',
      (tester) async {
        final bloc = _FakeSkinAnalysisBloc(
          const SkinAnalysisState(
            status: SkinAnalysisStatus.analyzing,
            currentStepIndex: 1,
          ),
        );

        await tester.pumpWidget(
          MaterialApp(
            home: ScanAnalyzingPage(
              imagePath: '',
              bloc: bloc,
            ),
          ),
        );

        await tester.pump(const Duration(milliseconds: 50));

        // Face constellation overlay is present
        expect(find.byType(FaceSparkleOverlay), findsOneWidget);

        // Cancel button in top bar
        expect(find.byTooltip('Cancel scan'), findsOneWidget);

        // Bottom sheet header & steps
        expect(find.text('Dermatological Skin Analysis'), findsOneWidget);
        expect(
          find.text('Analyzing skin texture, pores & concerns...'),
          findsOneWidget,
        );
        expect(
          find.text('Optimizing & uploading HD image...'),
          findsOneWidget,
        );
        expect(find.text('Analysing scan results...'), findsOneWidget);
        expect(find.text('Building scan report...'), findsOneWidget);
      },
    );

    testWidgets(
      'displays taking longer notice when isTakingLonger is true',
      (tester) async {
        final bloc = _FakeSkinAnalysisBloc(
          const SkinAnalysisState(
            status: SkinAnalysisStatus.analyzing,
            currentStepIndex: 1,
            isTakingLonger: true,
          ),
        );

        await tester.pumpWidget(
          MaterialApp(
            home: ScanAnalyzingPage(
              imagePath: '',
              bloc: bloc,
            ),
          ),
        );

        await tester.pump(const Duration(milliseconds: 50));

        expect(
          find.text(
            'Taking a bit longer than usual... Your HD report is almost ready.',
          ),
          findsOneWidget,
        );
      },
    );

    testWidgets(
      'renders failure state with Try Again and Retake in bottom sheet',
      (tester) async {
        final bloc = _FakeSkinAnalysisBloc(
          const SkinAnalysisState(
            status: SkinAnalysisStatus.failure,
            errorMessage: 'Network connection lost.',
          ),
        );

        await tester.pumpWidget(
          MaterialApp(
            home: ScanAnalyzingPage(
              imagePath: '',
              bloc: bloc,
            ),
          ),
        );

        await tester.pump(const Duration(milliseconds: 50));

        // Face sparkles must be stopped and hidden on failure
        expect(find.byType(FaceSparkleOverlay), findsNothing);

        expect(find.text('Analysis Interrupted'), findsOneWidget);
        expect(find.text('Network connection lost.'), findsOneWidget);
        expect(find.byType(PrimaryButton), findsOneWidget);
        expect(find.text('Try Again'), findsOneWidget);
        expect(find.byType(SecondaryButton), findsOneWidget);
        expect(find.text('Retake'), findsOneWidget);
      },
    );
  });
}
