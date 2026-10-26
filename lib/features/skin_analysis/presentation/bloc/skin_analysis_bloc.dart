// ignore_for_file: document_ignores, prefer_initializing_formals

import 'dart:async';

import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:kora/features/skin_analysis/domain/usecases/analyze_skin_usecase.dart';
import 'package:kora/features/skin_analysis/domain/usecases/preprocess_skin_image_usecase.dart';
import 'package:kora/features/skin_analysis/presentation/bloc/skin_analysis_event.dart';
import 'package:kora/features/skin_analysis/presentation/bloc/skin_analysis_state.dart';

/// BLoC orchestrating the 3-phase YouCam HD analysis pipeline:
/// 1. Isolate image optimization (HD dimensions & size constraint)
/// 2. Remote API dispatch & analysis
/// 3. Mask retrieval & skin report compilation
class SkinAnalysisBloc extends Bloc<SkinAnalysisEvent, SkinAnalysisState> {
  /// Creates a [SkinAnalysisBloc].
  SkinAnalysisBloc({
    required PreprocessSkinImageUseCase preprocessUseCase,
    required AnalyzeSkinUseCase analyzeUseCase,
  }) : _preprocessUseCase = preprocessUseCase,
       _analyzeUseCase = analyzeUseCase,
       super(const SkinAnalysisState()) {
    on<StartSkinAnalysisEvent>(_onStartSkinAnalysis);
    on<AnalysisProgressStepEvent>(_onProgressStep);
    on<LongProcessingTimeoutTriggeredEvent>(_onLongProcessingTimeout);
    on<ResetSkinAnalysisEvent>(_onReset);
  }

  final PreprocessSkinImageUseCase _preprocessUseCase;
  final AnalyzeSkinUseCase _analyzeUseCase;
  Timer? _longProcessingTimer;

  Future<void> _onStartSkinAnalysis(
    StartSkinAnalysisEvent event,
    Emitter<SkinAnalysisState> emit,
  ) async {
    _longProcessingTimer?.cancel();
    _longProcessingTimer = Timer(const Duration(seconds: 20), () {
      if (!isClosed) {
        add(const LongProcessingTimeoutTriggeredEvent());
      }
    });

    // Step 0: Preprocessing & Optimizing
    emit(
      state.copyWith(
        status: SkinAnalysisStatus.preprocessing,
        currentStepIndex: 0,
        isTakingLonger: false,
      ),
    );

    final preprocessResult = await _preprocessUseCase(
      PreprocessSkinImageParams(inputPath: event.imagePath),
    );

    String? processedImagePath;
    final preprocessFailed = preprocessResult.fold(
      (failure) {
        emit(
          state.copyWith(
            status: SkinAnalysisStatus.failure,
            errorMessage: failure.message,
          ),
        );
        return true;
      },
      (processedPath) {
        processedImagePath = processedPath;
        emit(
          state.copyWith(
            preprocessedPath: processedPath,
          ),
        );
        return false;
      },
    );

    if (preprocessFailed) {
      _longProcessingTimer?.cancel();
      return;
    }

    // Step 1: Analysing
    emit(
      state.copyWith(
        status: SkinAnalysisStatus.analyzing,
        currentStepIndex: 1,
      ),
    );

    // Simulated step transition to reflect real mask building
    unawaited(
      Future<void>.delayed(const Duration(milliseconds: 1400)).then((_) {
        if (!isClosed && state.status == SkinAnalysisStatus.analyzing) {
          add(const AnalysisProgressStepEvent(stepIndex: 2));
        }
      }),
    );

    final analysisResult = await _analyzeUseCase(
      AnalyzeSkinParams(
        imagePath: processedImagePath ?? event.imagePath,
        useMockIfOffline: event.useMock,
      ),
    );

    _longProcessingTimer?.cancel();

    analysisResult.fold(
      (failure) => emit(
        state.copyWith(
          status: SkinAnalysisStatus.failure,
          errorMessage: failure.message,
        ),
      ),
      (result) => emit(
        state.copyWith(
          status: SkinAnalysisStatus.success,
          currentStepIndex: 2,
          result: result,
        ),
      ),
    );
  }

  void _onProgressStep(
    AnalysisProgressStepEvent event,
    Emitter<SkinAnalysisState> emit,
  ) {
    if (state.status == SkinAnalysisStatus.analyzing ||
        state.status == SkinAnalysisStatus.buildingReport) {
      emit(
        state.copyWith(
          status: SkinAnalysisStatus.buildingReport,
          currentStepIndex: event.stepIndex,
        ),
      );
    }
  }

  void _onLongProcessingTimeout(
    LongProcessingTimeoutTriggeredEvent event,
    Emitter<SkinAnalysisState> emit,
  ) {
    if (state.status != SkinAnalysisStatus.success &&
        state.status != SkinAnalysisStatus.failure) {
      emit(state.copyWith(isTakingLonger: true));
    }
  }

  void _onReset(
    ResetSkinAnalysisEvent event,
    Emitter<SkinAnalysisState> emit,
  ) {
    _longProcessingTimer?.cancel();
    emit(const SkinAnalysisState());
  }

  @override
  Future<void> close() {
    _longProcessingTimer?.cancel();
    return super.close();
  }
}
